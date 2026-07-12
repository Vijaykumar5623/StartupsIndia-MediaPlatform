#!/usr/bin/env python3
"""Build the bundled college asset from an AISHE-based CSV.

The student/college college picker reads a local asset instead of Firestore, so
this script turns the raw CSV into a compact JSON grouped by state:

    { "Maharashtra": ["College A", "College B", ...], "Karnataka": [...], ... }

State names in each list are de-duplicated and sorted; state keys use the app's
canonical labels (matching lib/core/config/profile_field_options.dart) so the
in-app filter matches.

Data source
-----------
Government AISHE dataset via https://www.data.gov.in/catalog/institutions-aishe-survey
(Government Open Data License - India; attribution required). A convenient
ready-made CSV of ~43k colleges is published at
https://github.com/PriyanKishoreMS/colleges-api (see its /data directory).

Usage
-----
    python build_colleges_asset.py --csv scripts/colleges.csv \\
        --out assets/data/colleges_in.json

No credentials or network needed. Column names are detected case-insensitively;
override with --name-col/--state-col.
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import re
import sys
from collections import Counter

# Canonical states/UTs. MUST stay in sync with the app's state dropdown in
# lib/core/config/profile_field_options.dart (`_indianStates`) so the asset's
# state keys match what the picker filters on.
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


_STATE_LOOKUP: dict[str, str] = {_norm(s): s for s in CANONICAL_STATES}
_STATE_ALIASES = {
    "orissa": "Odisha",
    "pondicherry": "Puducherry",
    "nct of delhi": "Delhi",
    "delhi ncr": "Delhi",
    "national capital territory of delhi": "Delhi",
    "uttaranchal": "Uttarakhand",
    "uttrakhand": "Uttarakhand",
    "uttarkhand": "Uttarakhand",
    "jammu kashmir": "Jammu & Kashmir",
    "andaman nicobar islands": "Andaman & Nicobar Islands",
    "andaman and nicobar": "Andaman & Nicobar Islands",
    "dadra and nagar haveli": "Dadra & Nagar Haveli and Daman & Diu",
    "daman and diu": "Dadra & Nagar Haveli and Daman & Diu",
    "dadra and nagar haveli and daman and diu": "Dadra & Nagar Haveli and Daman & Diu",
    "telengana": "Telangana",
    "chattisgarh": "Chhattisgarh",
    "chhatisgarh": "Chhattisgarh",
}
for _alias, _canonical in _STATE_ALIASES.items():
    _STATE_LOOKUP[_norm(_alias)] = _canonical


def canonical_state(raw: str) -> str | None:
    return _STATE_LOOKUP.get(_norm(raw or ""))


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build the bundled college JSON asset.")
    parser.add_argument("--csv", required=True, help="Path to the colleges CSV file.")
    parser.add_argument(
        "--out",
        default="assets/data/colleges_in.json",
        help="Output JSON path (grouped by state).",
    )
    parser.add_argument("--limit", type=int, default=None, help="Max rows to process (for testing).")
    parser.add_argument("--name-col", default=None, help="Override the name column header.")
    parser.add_argument("--state-col", default=None, help="Override the state column header.")
    parser.add_argument("--pretty", action="store_true", help="Pretty-print JSON (larger file).")
    parser.add_argument(
        "--keep-unmatched-state",
        action="store_true",
        help="Keep rows whose state could not be normalized (grouped under the raw label).",
    )
    return parser.parse_args()


def detect_column(fieldnames: list[str], override: str | None, candidates: list[str]) -> str | None:
    if override:
        return override
    lowered = {name.lower().strip(): name for name in fieldnames}
    for candidate in candidates:
        if candidate in lowered:
            return lowered[candidate]
    return None


def run() -> int:
    args = parse_args()

    if not os.path.exists(args.csv):
        print(f"CSV not found: {args.csv}", file=sys.stderr)
        return 2

    by_state: dict[str, set[str]] = {}
    rows_read = 0
    skipped_no_name = 0
    unmatched_states: Counter = Counter()

    with open(args.csv, newline="", encoding="utf-8-sig") as handle:
        reader = csv.DictReader(handle)
        fieldnames = reader.fieldnames or []
        name_col = detect_column(fieldnames, args.name_col, ["name", "college", "college_name", "institution"])
        state_col = detect_column(fieldnames, args.state_col, ["state", "state_name"])

        if not name_col or not state_col:
            print(
                f"Could not detect name/state columns in headers {fieldnames}. "
                "Use --name-col/--state-col.",
                file=sys.stderr,
            )
            return 2

        for row in reader:
            if args.limit is not None and rows_read >= args.limit:
                break
            rows_read += 1

            name = " ".join((row.get(name_col) or "").split()).strip()
            if not name:
                skipped_no_name += 1
                continue

            raw_state = (row.get(state_col) or "").strip()
            state = canonical_state(raw_state)
            if state is None:
                unmatched_states[raw_state] += 1
                if not args.keep_unmatched_state:
                    continue
                state = raw_state

            by_state.setdefault(state, set()).add(name)

    # Deterministic output: states sorted, names sorted within each state.
    grouped = {
        state: sorted(by_state[state], key=str.casefold)
        for state in sorted(by_state.keys())
    }
    total_colleges = sum(len(names) for names in grouped.values())

    out_dir = os.path.dirname(args.out)
    if out_dir:
        os.makedirs(out_dir, exist_ok=True)
    with open(args.out, "w", encoding="utf-8") as out_handle:
        if args.pretty:
            json.dump(grouped, out_handle, ensure_ascii=False, indent=2, sort_keys=True)
        else:
            json.dump(grouped, out_handle, ensure_ascii=False, separators=(",", ":"), sort_keys=True)

    size_kb = os.path.getsize(args.out) / 1024
    print("\nAsset build summary")
    print(f"Rows read: {rows_read}")
    print(f"Skipped (no name): {skipped_no_name}")
    print(f"States: {len(grouped)}")
    print(f"Unique colleges: {total_colleges}")
    print(f"Output: {args.out} ({size_kb:.0f} KB)")
    unmatched_total = sum(unmatched_states.values())
    print(f"Unmatched state rows (dropped): {unmatched_total}")
    for raw_state, count in unmatched_states.most_common(25):
        print(f"  - {raw_state or '(blank)'}: {count}")
    return 0


if __name__ == "__main__":
    raise SystemExit(run())
