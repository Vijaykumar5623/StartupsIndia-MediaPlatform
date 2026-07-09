# Troubleshooting

Common problems when building or running StartupsIndia, and how to fix them.
For setup basics see [setup.md](setup.md); for config see
[configuration.md](configuration.md).

---

## `flutter doctor` shows issues

**Problem:** Doctor reports missing Android toolchain or unaccepted licenses.
**Cause:** Android SDK/cmdline-tools not installed, or licenses not accepted.
**Fix:** Install via Android Studio → SDK Manager, then
`flutter doctor --android-licenses` and accept all.

---

## Dependency / version conflicts on `flutter pub get`

**Problem:** Resolution fails or a package needs a newer Dart SDK.
**Cause:** SDK constraint is `^3.9.2`; an older Flutter/Dart won't resolve.
**Fix:** Upgrade Flutter to a stable channel that ships Dart 3.9.2+
(`flutter upgrade`), then `flutter pub get`. Check `flutter --version`.

---

## Gradle build failure

**Problem:** Android build fails in Gradle.
**Cause:** Wrong JDK, stale caches, or missing `google-services.json`.
**Fix:**
- Use **JDK 17** (Android Studio → Settings → Build Tools → Gradle → Gradle JDK).
- Ensure `android/app/google-services.json` exists (see [setup.md](setup.md)).
- `flutter clean && flutter pub get`, then rebuild.

---

## Android SDK / NDK / CMake errors

**Problem:** Build complains about NDK or CMake versions.
**Cause:** Missing SDK components (CI installs `cmake;3.22.1` explicitly).
**Fix:** Install the required CMake/NDK from SDK Manager; let Flutter pick the
NDK version, or install the one the error names.

---

## App won't install on device

**Problem:** `INSTALL_FAILED_*` when installing.
**Cause:** An older build with a different signature, or an incompatible ABI.
**Fix:** Uninstall the existing app first. For release APKs, note CI builds
**ARM64-only** — install on an ARM64 device or build a universal APK
(`flutter build apk --release`).

---

## API / feed not loading (Firestore)

**Problem:** Home/Explore/Communities stay empty or spin forever.
**Cause:** No data in Firestore, a missing composite index, or rules blocking the
read.
**Fix:**
- Confirm the collection has documents (`articles`, `posts`, `communities`).
- Check the debug console for a Firestore "requires an index" link and create it;
  add it to `firestore.indexes.json`.
- Ensure `firestore.rules` are deployed (`firebase deploy --only firestore:rules`).
- Remember `orderBy('updatedAt')` excludes docs missing `updatedAt` — imports
  must set it ([DATA_CONTRACTS.md](DATA_CONTRACTS.md)).

---

## Images / media not loading

**Problem:** Images show as broken or never appear.
**Cause:** Cloudinary URL issue, network, or missing asset declaration.
**Fix:** Confirm the URL loads in a browser; confirm local assets are declared in
`pubspec.yaml`; check `cached_network_image` isn't caching a prior failure
(reinstall to clear).

---

## Google Sign-In fails / returns "canceled"

**Problem:** Google login immediately cancels, especially on release builds.
**Cause:** The build's SHA-1/SHA-256 is not registered in Firebase.
**Fix:** Add the debug **and** release fingerprints in Firebase Console → Project
Settings → Your Android app, then re-download `google-services.json`. See
[setup.md](setup.md).

---

## Release build fails or ships unsigned

**Problem:** Release build errors on signing, or installs but is debug-signed.
**Cause:** Missing/incorrect `android/key.properties` — the build falls back to
the debug key.
**Fix:** Create `android/key.properties` pointing at a valid keystore (see
[release-plan.md](release-plan.md)). Never commit it.

---

## Keystore / signing issues

**Problem:** "keystore was tampered with" or wrong password.
**Cause:** Wrong password/alias, or a corrupted base64 keystore in CI.
**Fix:** Verify with `keytool -list -v -keystore <file> -alias <alias>`. In CI,
re-encode the keystore to base64 and update the `KEYSTORE_BASE64` secret.

---

## Play Store upload rejected/blocked

**Problem:** Console rejects the AAB or the listing.
**Cause:** `versionCode` not incremented, debug signing, missing privacy/
deletion URL, Data Safety mismatch, or placeholder content.
**Fix:** Increment `versionCode`; ensure release signing; complete the
[play-store-launch-checklist.md](play-store-launch-checklist.md); re-check
[../PLAY_STORE_AUDIT.md](../PLAY_STORE_AUDIT.md).

---

## Emulator / device not detected

**Problem:** `flutter devices` doesn't list your device.
**Cause:** USB debugging off, missing drivers, or emulator not started.
**Fix:** Enable Developer Options + USB debugging; accept the RSA prompt; start an
emulator from Android Studio; run `adb devices` to confirm.

---

## `flutter analyze` reports many warnings

**Problem:** Analyze exits non-zero with warnings/infos.
**Cause:** The repo is not yet lint-clean (deprecated `withOpacity`, unused
imports, etc. — [known-issues.md](known-issues.md)).
**Fix:** This is expected today. Don't add **new** warnings; treat new **errors**
as blockers. A cleanup pass is planned.
