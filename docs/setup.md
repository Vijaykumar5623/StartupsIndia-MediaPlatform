# Setup Guide

How to get the StartupsIndia app running on a new machine. Target platform is
**Android**; the repo also contains iOS/web/desktop scaffolding, but Android is
the launch target.

---

## 1. Prerequisites

| Tool | Version | Notes |
|---|---|---|
| Flutter SDK | stable channel (Dart `^3.9.2`) | `environment.sdk` in [pubspec.yaml](../pubspec.yaml) requires Dart 3.9.2+. CI uses Flutter stable. |
| Dart | bundled with Flutter | No separate install needed. |
| Android Studio | latest | For the Android SDK, emulator, and platform tools. |
| Java (JDK) | 17 | CI builds on Temurin 17. Android Gradle uses Java 11 source compatibility, but build with JDK 17. |
| Android SDK | via Android Studio | Min SDK 21 (see `flutter_launcher_icons.min_sdk_android`). |
| Git | any recent | To clone and manage branches. |

Verify your toolchain:

```bash
flutter doctor
```

Resolve anything Flutter Doctor flags before continuing. Common issues are in
[troubleshooting.md](troubleshooting.md).

---

## 2. Clone the repo

```bash
git clone https://github.com/saiusesgithub/StartupsIndia-MediaPlatform.git
cd StartupsIndia-MediaPlatform
```

---

## 3. Add Firebase config (required)

`android/app/google-services.json` is **gitignored** and is not in the repo. Get
it from the project owner (Firebase project `startupsindia-mediaplatform`) or
download it from the Firebase Console → Project Settings → Your Apps → Android
(`in.startupsindia.app`), then place it at:

```
android/app/google-services.json
```

For **Google Sign-In** to work, your machine's SHA-1 must be registered in
Firebase. Get your debug SHA-1:

```powershell
keytool -list -keystore $env:USERPROFILE\.android\debug.keystore -alias androiddebugkey -storepass android
```

Add it in Firebase Console → Project Settings → Your Android app → Add
fingerprint, then re-download `google-services.json`.

See [configuration.md](configuration.md) for the full config picture.

---

## 4. Install dependencies

```bash
flutter pub get
```

---

## 5. Run the app

```bash
# List connected devices/emulators
flutter devices

# Run in debug on the default device
flutter run
```

The app starts at the `/splash` route and decides where to go based on auth
state (see [ARCHITECTURE.md](ARCHITECTURE.md) → Routing).

Optional configuration is passed with `--dart-define` (see [../.env.example](../.env.example)):

```bash
flutter run --dart-define=ENV=development
```

---

## 6. Building

| Goal | Command |
|---|---|
| Debug APK | `flutter build apk --debug` |
| Release APK (universal) | `flutter build apk --release` |
| Release APK (ARM64, like CI) | `flutter build apk --release --target-platform=android-arm64 --obfuscate --split-debug-info=build/symbols --dart-define=ENV=prod` |
| Release AAB (Play Store) | `flutter build appbundle --release --obfuscate --split-debug-info=build/symbols --dart-define=ENV=prod` |

Release builds require signing config. If `android/key.properties` is absent, the
release build falls back to the debug signing key (see
[android/app/build.gradle.kts](../android/app/build.gradle.kts)). For a real
Play upload you must provide a proper keystore — see
[release-plan.md](release-plan.md).

> There are **no build flavors** in this project. Environment differences are
> handled at build time through `--dart-define`, not Gradle product flavors.

---

## 7. Common setup issues

- **`flutter doctor` Android licenses not accepted** → `flutter doctor --android-licenses`.
- **Build fails: missing `google-services.json`** → complete step 3.
- **Google Sign-In returns "canceled"** → your SHA-1 is not registered in Firebase (step 3).
- **Gradle/JDK errors** → ensure JDK 17 is selected in Android Studio → Settings → Build Tools → Gradle.

More in [troubleshooting.md](troubleshooting.md).

---

## 8. Device / emulator notes

- Use a physical device or an emulator running **Android 8.0+ (API 26+)**; min
  supported is API 21.
- Push notifications and App Check behave best on a real device.
- For release-bundle testing, install the AAB with `bundletool` (see
  [release-plan.md](release-plan.md)).
