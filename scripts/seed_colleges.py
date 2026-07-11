#!/usr/bin/env python3
"""Seed the Firestore `colleges` collection from an AISHE-based CSV.

The student college picker in the app searches this collection filtered by the
student's selected state, so each document stores:

    name       - display name of the college/institution
    nameLower  - lowercase name (used for prefix search + ordering)
    state      - canonical Indian state/UT label (matches the app's state list)
    city       - city/town, if available (display only)

Data source
-----------
Government AISHE dataset via https://www.data.gov.in/catalog/institutions-aishe-survey
(Government Open Data License - India; attribution required). A convenient
ready-made CSV of ~43k colleges (columns: name, state, city, ...) is published at
https://github.com/PriyanKishoreMS/colleges-api (see its /data directory).

Download the CSV, then run this script pointing at it. Column names are detected
case-insensitively; override with --name-col/--state-col/--city-col if needed.

Usage
-----
Dry run (no credentials, prints a sample + state-normalization report):
    python seed_colleges.py --csv colleges.csv --dry-run --sample

Write to Firestore (service account required):
    python seed_colleges.py --csv colleges.csv \\
        --service-account serviceAccount.json

Re-running is idempotent: each doc id is derived from name+state, so repeated
runs update rather than duplicate.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import os
import re
import sys
from collections import Counter
from dataclasses import dataclass, field

COLLECTION = "colleges"
BATCH_SIZE = 400  # Firestore hard limit is 500 writes per batch.

# Canonical states/UTs. MUST stay in sync with the app's state dropdown in
# lib/core/config/profile_field_options.dart (`_indianStates`) so college
# `state` values match what the picker filters on.
CANONICAL_STATES = [
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
    "Andaman & Nicobar Islands",
    "Chandigarh",
    "Dadra & Nagar Haveli and Daman & Diu",
    "Delhi",
    "Jammu & Kashmir",
    "Ladakh",
    "Lakshadweep",
    "Puducherry",
]


def _norm(value: str) -> str:
    """Normalize a state name for matching: lowercase, drop punctuation, collapse."""
    text = value.lower().replace("&", " and ")
    text = re.sub(r"[^a-z0-9]+", " ", text)
    return re.sub(r"\s+", " ", text).strip()


# Map normalized source names → canonical label. Built from the canonical list
# plus known AISHE/legacy aliases.
_STATE_LOOKUP: dict[str, str] = {_norm(s): s for s in CANONICAL_STATES}
_STATE_ALIASES = {
    "orissa": "Odisha",
    "pondicherry": "Puducherry",
    "nct of delhi": "Delhi",
    "delhi ncr": "Delhi",
    "national capital territory of delhi": "Delhi",
    "uttaranchal": "Uttarakhand",
    "jammu kashmir": "Jammu & Kashmir",
    "andaman nicobar islands": "Andaman & Nicobar Islands",
    "andaman and nicobar": "Andaman & Nicobar Islands",
    "dadra and nagar haveli": "Dadra & Nagar Haveli and Daman & Diu",
    "daman and diu": "Dadra & Nagar Haveli and Daman & Diu",
    "dadra and nagar haveli and daman and diu": "Dadra & Nagar Haveli and Daman & Diu",
    "telengana": "Telangana",
    "chattisgarh": "Chhattisgarh",
}
for _alias, _canonical in _STATE_ALIASES.items():
    _STATE_LOOKUP[_norm(_alias)] = _canonical


def canonical_state(raw: str) -> str | None:
    return _STATE_LOOKUP.get(_norm(raw or ""))


@dataclass
class SeedStats:
    rows_read: int = 0
    written: int = 0
    skipped_no_name: int = 0
    unmatched_states: Counter = field(default_factory=Counter)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Seed the Firestore colleges collection.")
    parser.add_argument("--csv", required=True, help="Path to the colleges CSV file.")
    parser.add_argument("--dry-run", action="store_true", help="Parse only; do not write to Firestore.")
    parser.add_argument("--limit", type=int, default=None, help="Max rows to process.")
    parser.add_argument("--sample", action="store_true", help="Print one transformed sample document.")
    parser.add_argument("--name-col", default=None, help="Override the name column header.")
    parser.add_argument("--state-col", default=None, help="Override the state column header.")
    parser.add_argument("--city-col", default=None, help="Override the city column header.")
    parser.add_argument(
        "--keep-unmatched-state",
        action="store_true",
        help="Write rows whose state could not be normalized (state stored as-is). Default skips them.",
    )
    parser.add_argument("--service-account", default=None, help="Path to Firebase service account JSON.")
    parser.add_argument("--project-id", default=None, help="Optional Firebase project id override.")
    return parser.parse_args()


def detect_column(fieldnames: list[str], override: str | None, candidates: list[str]) -> str | None:
    if override:
        return override
    lowered = {name.lower().strip(): name for name in fieldnames}
    for candidate in candidates:
        if candidate in lowered:
            return lowered[candidate]
    return None


def doc_id_for(name_lower: str, state: str) -> str:
    return hashlib.md5(f"{name_lower}|{state}".encode("utf-8")).hexdigest()[:20]


def init_firestore(service_account_path: str | None, project_id: str | None):
    import firebase_admin
    from firebase_admin import credentials, firestore

    credential_path = service_account_path or os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
    if not credential_path:
        raise RuntimeError(
            "Firebase credentials required for write mode. Pass --service-account "
            "or set GOOGLE_APPLICATION_CREDENTIALS."
        )
    cred = credentials.Certificate(credential_path)
    options = {"projectId": project_id} if project_id else None
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred, options)
    return firestore.client()


def run() -> int:
    args = parse_args()
    stats = SeedStats()

    if not os.path.exists(args.csv):
        print(f"CSV not found: {args.csv}", file=sys.stderr)
        return 2

    db = None
    batch = None
    batch_count = 0
    if not args.dry_run:
        db = init_firestore(args.service_account, args.project_id)
        batch = db.batch()

    sample_printed = False

    with open(args.csv, newline="", encoding="utf-8-sig") as handle:
        reader = csv.DictReader(handle)
        fieldnames = reader.fieldnames or []
        name_col = detect_column(fieldnames, args.name_col, ["name", "college", "college_name", "institution"])
        state_col = detect_column(fieldnames, args.state_col, ["state", "state_name"])
        city_col = detect_column(fieldnames, args.city_col, ["city", "district", "town"])

        if not name_col or not state_col:
            print(
                f"Could not detect name/state columns in headers {fieldnames}. "
                "Use --name-col/--state-col.",
                file=sys.stderr,
            )
            return 2

        for row in reader:
            if args.limit is not None and stats.rows_read >= args.limit:
                break
            stats.rows_read += 1

            name = (row.get(name_col) or "").strip()
            if not name:
                stats.skipped_no_name += 1
                continue

            raw_state = (row.get(state_col) or "").strip()
            state = canonical_state(raw_state)
            if state is None:
                stats.unmatched_states[raw_state] += 1
                if not args.keep_unmatched_state:
                    continue
                state = raw_state  # store as-is when explicitly kept

            city = (row.get(city_col) or "").strip() if city_col else ""
            name_lower = name.lower()
            document = {
                "name": name,
                "nameLower": name_lower,
                "state": state,
                "city": city,
            }

            if args.sample and not sample_printed:
                print("\nSample document:")
                print(f"  doc id: {doc_id_for(name_lower, state)}")
                for key, value in document.items():
                    print(f"  {key}: {value}")
                sample_printed = True

            if not args.dry_run:
                assert db is not None and batch is not None
                ref = db.collection(COLLECTION).document(doc_id_for(name_lower, state))
                batch.set(ref, document)
                batch_count += 1
                stats.written += 1
                if batch_count >= BATCH_SIZE:
                    batch.commit()
                    batch = db.batch()
                    batch_count = 0

        if not args.dry_run and batch is not None and batch_count > 0:
            batch.commit()

    print("\nSeed summary")
    print(f"Rows read: {stats.rows_read}")
    print(f"Documents written: {stats.written}")
    print(f"Skipped (no name): {stats.skipped_no_name}")
    unmatched_total = sum(stats.unmatched_states.values())
    print(f"Unmatched state rows: {unmatched_total}")
    for raw_state, count in stats.unmatched_states.most_common(25):
        print(f"  - {raw_state or '(blank)'}: {count}")
    if len(stats.unmatched_states) > 25:
        print(f"  ... {len(stats.unmatched_states) - 25} more distinct states")
    if args.dry_run:
        print("\nDry-run complete. No Firestore writes were made.")

    return 0


if __name__ == "__main__":
    raise SystemExit(run())
