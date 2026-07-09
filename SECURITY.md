# Security Policy

This document describes how secrets are handled in the StartupsIndia app and how
to report security issues. It is written for a small team preparing a Play Store
launch, not a large open-source project.

Related reading: [docs/configuration.md](docs/configuration.md) and the detailed
[PLAY_STORE_AUDIT.md](PLAY_STORE_AUDIT.md).

---

## 1. Never commit secrets

The following must **never** be committed to git. They are already listed in
[.gitignore](.gitignore):

| File / value | What it is | Where it belongs |
|---|---|---|
| `android/app/google-services.json` | Firebase Android config | Injected in CI via the `GOOGLE_SERVICES_JSON` secret; kept locally only |
| `android/key.properties` | Release signing config | Local machine + CI secrets |
| `*.jks`, `*.keystore` | Release signing keystore | Password manager / secure storage; never in git |
| `serviceAccount.json` | Firebase Admin SDK key | Outside the repo entirely |
| `.env`, `.env.*` | Local env notes | Local only (`.env.example` is the only committed example) |

If you ever commit one of these by accident, treat it as compromised: rotate the
credential and rewrite history. Do **not** just delete it in a later commit — it
stays in git history.

---

## 2. What is NOT a secret (safe by design)

- **`lib/firebase_options.dart`** — Firebase API keys here are public client
  identifiers, not secrets. They are protected by Firebase App Check and
  Firestore Security Rules, and can be restricted further in Google Cloud
  Console. This is expected Firebase behavior.
- **Cloudinary cloud name + unsigned upload preset** (in
  `lib/core/config/app_config.dart`) — these are meant to ship in the client.
  They are not secret keys, but the **preset must be restricted** (see below).

---

## 3. Open security items before launch

These are tracked in more detail in [PLAY_STORE_AUDIT.md](PLAY_STORE_AUDIT.md)
and [docs/known-issues.md](docs/known-issues.md):

- [ ] **Rotate the Firebase Admin SDK key.** `serviceAccount.json` previously sat
      in the project root; it was moved out, but the key should be rotated in
      Firebase Console → Project Settings → Service Accounts.
- [ ] **Replace the weak local keystore password** before uploading to Play.
      Use a strong password stored in a password manager.
- [ ] **Restrict the Cloudinary unsigned upload preset** (allowed formats, max
      size, dedicated folder) in the Cloudinary console to prevent abuse.
- [ ] **Firestore admin identity is a hardcoded UID** in `firestore.rules`.
      Move to custom claims or an `admins/{uid}` lookup before expanding admin
      access.
- [ ] Verify `ROLE_DETAILS.md` (a client requirements file) should be in the
      repo — `docs/HANDOFF.md` marks it as private/not-for-push.

---

## 4. Guidance for developers

- Read [SECURITY.md](SECURITY.md) and [CONTRIBUTING.md](CONTRIBUTING.md) before
  your first commit.
- Configurable values go through `--dart-define` / `AppConfig`, not hardcoded
  literals. See [docs/configuration.md](docs/configuration.md).
- Signing keys and production credentials should be owned by the **company**, not
  an individual developer. See [docs/handover-notes.md](docs/handover-notes.md).
- Be mindful of user data. The app collects email, name, phone, photo, bio,
  website, FCM tokens, uploaded images, and interaction history. All of this must
  be declared in the Play Console **Data Safety** form and covered by the privacy
  policy. See [docs/play-store-launch-checklist.md](docs/play-store-launch-checklist.md).

---

## 5. Reporting a security issue

If you find a security problem, report it **privately** to the project owner /
company — do not open a public GitHub issue.

- Maintainer: [@saiusesgithub](https://github.com/saiusesgithub)
- Company: Startups India — TODO: confirm a monitored security contact email.

Please include what you found, how to reproduce it, and the potential impact.
