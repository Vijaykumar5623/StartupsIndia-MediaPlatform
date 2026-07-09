# Handover Notes

For the company and any future developer taking over StartupsIndia. This
captures ownership, accounts, and what to read first — the things that aren't
obvious from the code alone.

---

## 1. Project ownership

- **App:** StartupsIndia — a Flutter (Android-first) startup ecosystem media +
  community app.
- **Owner:** Startups India (the company). The app, brand, assets, and source
  are company property (see [../LICENSE](../LICENSE)).
- **Current developer:** sole developer, working as an intern
  ([@saiusesgithub](https://github.com/saiusesgithub)). Started as a freelance
  developer; now internal.

## 2. Current launch status

Pre-launch, **v1.0.0** preparation (July 2026). Feature-complete for first
release; remaining work is stabilization, launch hardening, and Play Store
paperwork. Company DUNS expected early August 2026, which unlocks Play Console
organization verification.

## 3. Repository overview

- Flutter app in `lib/` (feature-first: `auth, onboarding, home, explore,
  community, profile, bookmark, build, notifications`).
- Backend: Firebase (Auth, Firestore, Messaging, App Check, Crashlytics) +
  Cloudinary for image uploads.
- CI: GitHub Actions (`.github/workflows/`) builds signed APK/AAB.
- Docs: [README.md](README.md) index in `docs/`.

## 4. Accounts and services in use

| Service | Identifier | Notes |
|---|---|---|
| Firebase | project `startupsindia-mediaplatform` | Auth, Firestore, FCM, App Check, Crashlytics, App Distribution. |
| Google Play | app id `in.startupsindia.app` | Developer account + org verification needed. |
| Cloudinary | cloud `dmrp1d1tv` | Unsigned upload preset (restrict before launch). |
| GitHub | `saiusesgithub/StartupsIndia-MediaPlatform` | Repo + Actions secrets. |
| Domain | `startupsindia.in` | Hosts privacy / terms / delete-account pages. |

## 5. Credentials the COMPANY must own

> **Critical:** production credentials should belong to the company, not an
> individual. Transfer/duplicate ownership of:

- Google Play Developer account (org, using company legal details + DUNS).
- Firebase project ownership.
- The **release signing keystore** and its passwords (losing this means you can
  never update the app under the same listing).
- Cloudinary account.
- The `startupsindia.in` domain and hosted legal pages.
- GitHub repository and Actions secrets.
- Firebase Admin SDK service account key.

See [../SECURITY.md](../SECURITY.md) for open credential items (key rotation,
keystore password, Cloudinary preset).

## 6. Build / release knowledge

- Release build: `flutter build appbundle --release --obfuscate
  --split-debug-info=build/symbols --dart-define=ENV=prod`.
- Signing config comes from `android/key.properties` (gitignored); absent → debug
  key fallback. Full flow in [release-plan.md](release-plan.md).
- Keep `build/symbols` for Crashlytics de-obfuscation.

## 7. Important docs (read in this order)

1. [HANDOFF.md](HANDOFF.md) — quick briefing.
2. [APP_STATE.md](APP_STATE.md) — what the app does today.
3. [ARCHITECTURE.md](ARCHITECTURE.md) — how it's built.
4. [DATA_CONTRACTS.md](DATA_CONTRACTS.md) — Firestore shapes.
5. [setup.md](setup.md) — run it locally.
6. [known-issues.md](known-issues.md) + [DECISIONS_AND_RISKS.md](DECISIONS_AND_RISKS.md) — risks and debt.
7. [play-store-launch-checklist.md](play-store-launch-checklist.md) — launch gate.

## 8. Pending launch items

- Security: rotate Admin SDK key, strong keystore password, restrict Cloudinary
  preset, clean/deploy Firestore rules.
- Replace remaining mock/sample data with production content.
- Complete Play Console listing, Data Safety, content rating, reviewer login.
- Resolve blockers tracked in [../PLAY_STORE_AUDIT.md](../PLAY_STORE_AUDIT.md).

## 9. Post-launch maintenance

- Monitor Crashlytics + Play vitals; use the hotfix process in
  [release-plan.md](release-plan.md).
- Keep `docs/` updated in the same commit as code changes.
- Work through [roadmap.md](roadmap.md) / [known-issues.md](known-issues.md).

## 10. What a new developer should read first

Start with [ai-agent-context.md](ai-agent-context.md) (fastest orientation),
then [setup.md](setup.md), then [development-guide.md](development-guide.md). If
using AI, read [vibe-coding-guide.md](vibe-coding-guide.md) before touching code.

---

> **Ownership reminder:** Play Console access, Firebase/backend services, signing
> keys, Cloudinary, the domain, and release credentials should be owned by the
> company — not held solely by an individual developer.
