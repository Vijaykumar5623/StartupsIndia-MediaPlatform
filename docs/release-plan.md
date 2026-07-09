# Release Plan

Versioning and release workflow for the StartupsIndia Android app. For the
submission-day checklist see [play-store-launch-checklist.md](play-store-launch-checklist.md);
for scope see [v1-launch-scope.md](v1-launch-scope.md).

---

## 1. Version naming (Semantic Versioning)

Version lives in [../pubspec.yaml](../pubspec.yaml) as `version: <name>+<code>`.
The name becomes the Android `versionName`; the `+code` becomes `versionCode`
(must increase on every Play upload).

```
1.0.0 = first production Play Store launch
1.0.1 = hotfix / bug-fix
1.1.0 = minor feature / UX improvement
2.0.0 = major redesign or architecture change
```

Current: `1.0.0+1` (target for first release).

Bump rules:
- Every Play upload → increment the `+code` (e.g. `1.0.0+2`).
- User-facing changes → bump the name per SemVer.

## 2. APK vs AAB

| Format | Use |
|---|---|
| **APK** | Local install, quick device testing, Firebase App Distribution previews. |
| **AAB** (Android App Bundle) | **Required for Play Store production.** Google generates per-device APKs from it. |

## 3. Debug vs release builds

- **Debug**: fast, unoptimized, uses debug signing and the App Check debug
  provider. For development only.
- **Release**: optimized, obfuscated, uses the release keystore and Play
  Integrity App Check. What ships.

CI release build (matches production):

```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols --dart-define=ENV=prod
```

Keep the `build/symbols` output — it is needed to de-obfuscate Crashlytics stack
traces (CI uploads it as an artifact).

## 4. Signing

- Release signing is read from `android/key.properties` (gitignored). If absent,
  the build falls back to the **debug** key — never ship that.
- Keystore and passwords live in a password manager and in CI secrets, never in
  git. See [configuration.md](configuration.md#7-signing) and [../SECURITY.md](../SECURITY.md).

One-time keystore creation:

```powershell
keytool -genkey -v -keystore $env:USERPROFILE\upload-keystore.jks `
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Then create `android/key.properties`, and add the SHA-1 + SHA-256 to Firebase
(required for Google Sign-In in release), and re-download `google-services.json`.

> Open item: the current local keystore uses a weak password. Replace it with a
> strong one before the first production upload ([../PLAY_STORE_AUDIT.md](../PLAY_STORE_AUDIT.md)).

## 5. Release checklist

1. Freeze scope ([v1-launch-scope.md](v1-launch-scope.md)).
2. `flutter clean && flutter pub get`.
3. `flutter analyze` — review; no new errors.
4. `flutter test`.
5. Bump `version` in `pubspec.yaml` if needed.
6. Build the release AAB (command above).
7. Smoke-test the AAB on a real device (see below).
8. Update [../CHANGELOG.md](../CHANGELOG.md).
9. Upload to the Internal testing track first.

## 6. Pre-release testing (install the AAB locally)

```powershell
bundletool build-apks --bundle=build/app/outputs/bundle/release/app-release.aab --output=test.apks --mode=universal
bundletool install-apks --apks=test.apks
```

Then run the smoke test in [testing-guide.md](testing-guide.md).

## 7. Internal / closed testing

- Upload the AAB to **Internal testing**, add testers, verify all flows on the
  real release build.
- New Play developer accounts may require a **Closed testing** period with a
  minimum number of testers before Production is unlocked. Verify your account's
  current requirement in Play Console.
- The manual `android_firebase_release.yml` workflow can distribute preview APKs
  via Firebase App Distribution for testers.

## 8. Production rollout

- Promote the tested build to **Production** with a **staged rollout** (e.g.
  10–20%), monitor Crashlytics and Play vitals, then increase.

## 9. Hotfix process (1.0.x)

1. Branch `fix/…` from `main`.
2. Make the minimal fix; add a regression check.
3. Bump patch version + `versionCode`.
4. Build AAB, quick-test, ship through Internal → Production (can be faster for
   critical fixes).

## 10. If Play Store rejects the app

1. Read the rejection reason carefully (policy vs technical).
2. Common causes for a news/UGC app: missing/incorrect privacy policy or
   account-deletion URL, Data Safety mismatch, content rating, missing reviewer
   login, or leftover placeholder content.
3. Fix, bump `versionCode`, document the fix in `CHANGELOG.md`, resubmit.
4. Cross-check against [play-store-launch-checklist.md](play-store-launch-checklist.md)
   and [../PLAY_STORE_AUDIT.md](../PLAY_STORE_AUDIT.md) before resubmitting.
