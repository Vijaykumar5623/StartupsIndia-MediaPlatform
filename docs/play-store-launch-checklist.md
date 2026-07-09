# Play Store Launch Checklist

The gate for submitting StartupsIndia to Google Play. This complements the
detailed [../PLAY_STORE_AUDIT.md](../PLAY_STORE_AUDIT.md) (which tracks specific
code blockers and their fix status). Check items off as you complete them.

> **Ownership note:** Play Console, Firebase, Cloudinary, the backend, and the
> signing keystore should be owned by **Startups India (the company)**, not an
> individual developer. See [handover-notes.md](handover-notes.md).

---

## 1. Company / account readiness

- [ ] Google Play **Developer account** created under the company (org account).
- [ ] Payment/registration fee paid.
- [ ] Account owner + roles assigned to company stakeholders.

## 2. DUNS number

- [ ] DUNS number obtained (expected early August 2026).
- [ ] Organization verified in Play Console using the company legal details +
      DUNS (Google requires org verification for company developer accounts).

## 3. Developer account ownership

- [ ] Company holds the account owner role; developer has appropriate (not sole
      owner) access.
- [ ] Firebase project ownership transferred/shared to the company.

## 4. App identity

- [x] Application ID `in.startupsindia.app` (not `com.example.*`).
- [x] App display name `StartupsIndia`.
- [ ] `versionCode` / `versionName` set for this release (`1.0.0+1`).

## 5. Store listing

- [ ] App name (≤ 30 chars): `StartupsIndia`.
- [ ] Short description (≤ 80 chars).
- [ ] Full description (500–4000 chars): news, communities, mentorship, funding.
- [ ] Category: News & Magazines (primary).
- [ ] Tags: startup, news, India, funding, entrepreneur.
- [ ] Contact email: a real, monitored address.

## 6. Screenshots

- [ ] Minimum 2, recommended 8 phone screenshots.
- [ ] Captured on a real/emulated phone-sized device; light + dark variants.
- [ ] (Optional) 7-inch / 10-inch tablet screenshots.

## 7. App icon

- [ ] 512×512 hi-res icon (generated from `assets/startupsindia/Icon.png`).

## 8. Feature graphic

- [ ] 1024×500 feature graphic.

## 9. Privacy policy

- [ ] Live URL (e.g. `https://www.startupsindia.in/privacy`) covering: email,
      name, phone, photos, FCM tokens, uploaded content.

## 10. Data Safety form

- [ ] Declare personal info (email/name/phone), photos (uploaded), app activity
      (likes/bookmarks/comments), device identifiers (FCM token).
- [ ] "Encrypted in transit" ✓ and "Users can request deletion" ✓.
- [ ] Account-deletion URL live (e.g. `https://www.startupsindia.in/delete-account`).

## 11. Content rating

- [ ] Complete the IARC questionnaire. UGC (comments) likely means Teen/18+.
- [ ] Target audience set (recommend 18+ given community UGC).

## 12. Target SDK check

- [ ] `targetSdk` meets Google Play's current minimum for new apps (uses
      Flutter's default; confirm it satisfies the current Play requirement).

## 13. Permissions review

- [ ] Every permission in `AndroidManifest.xml` is justified (notably
      `POST_NOTIFICATIONS`). Remove anything unused.

## 14. Test account (App access)

- [ ] Provide a reviewer login (reviewers can't use Google Sign-In):
      e.g. `reviewer@startupsindia.in` + password, documented in "App access".

## 15. Production AAB

- [ ] Signed release AAB built with the **real upload keystore** (strong password).
- [ ] `--obfuscate --split-debug-info` used; symbols kept for Crashlytics.

## 16. Internal testing

- [ ] AAB uploaded to Internal testing; all flows verified on a real device from
      the release build ([testing-guide.md](testing-guide.md)).

## 17. Review submission

- [ ] Closed testing requirement satisfied if your account needs it (new accounts).
- [ ] Submit for review with reviewer login and complete listing.

## 18. Staged rollout

- [ ] Start Production at a partial rollout (e.g. 10–20%).

## 19. Post-launch monitoring

- [ ] Watch Crashlytics and Play vitals (ANRs, crashes).
- [ ] Watch reviews and the reviewer/resupport contact inbox.
- [ ] Have the [release-plan.md](release-plan.md) hotfix process ready.

---

## Pre-submission security gate (must be done first)

- [ ] Rotate the Firebase Admin SDK key.
- [ ] Strong release keystore password (replace the weak local one).
- [ ] Restrict the Cloudinary unsigned upload preset.
- [ ] `firestore.rules` cleaned and deployed.

See [../SECURITY.md](../SECURITY.md) and [known-issues.md](known-issues.md).
