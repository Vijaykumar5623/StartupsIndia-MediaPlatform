# AI Agent Context

A compact briefing to give a future AI coding session fast, correct context.
Paste or point the agent here at the start. Read together with
[vibe-coding-guide.md](vibe-coding-guide.md).

---

## 1. What this project is

StartupsIndia — a Flutter (Android-first) media + community app for India's
startup ecosystem: role-based onboarding, a news feed, an Explore media feed,
communities, profiles, bookmarks, and push notifications. Backend is Firebase.

## 2. Current status

Pre-launch, **v1.0.0 preparation** (as of July 2026). Feature-complete for first
release; focus is documentation, stabilization, and Play Store readiness. Company
DUNS expected early August 2026. Sole developer (intern).

## 3. Tech stack

- Flutter (Dart `^3.9.2`), Riverpod `^3.3.1` for state.
- Firebase: Auth, Cloud Firestore (offline persistence), Messaging (FCM),
  App Check, Crashlytics. Google Sign-In v7.
- Cloudinary for image uploads. Google Fonts (Poppins).
- App id: `in.startupsindia.app`. Firebase project: `startupsindia-mediaplatform`.

## 4. Important folders / files

- `lib/main.dart` — entry, Firebase/FCM init, named routes.
- `lib/core/` — shared models, providers, repositories, widgets, config.
- `lib/features/<feature>/{data,domain,presentation}/` — feature-first layout.
  Features: `auth, onboarding, home, explore, community, profile, bookmark,
  build, notifications`.
- `lib/theme/style_guide.dart`, `lib/theme/app_theme.dart` — design tokens.
- `firestore.rules`, `firestore.indexes.json` — backend contract (deploy-gated).
- `lib/core/config/app_config.dart` — build-time config.

## 5. Launch target

First Google Play production release (Android). Scope in
[v1-launch-scope.md](v1-launch-scope.md); gating in
[play-store-launch-checklist.md](play-store-launch-checklist.md).

## 6. What AI agents ARE allowed to do

- Small, scoped UI/logic changes within a single feature or file.
- Add a clearly-specified widget, provider, or repository method.
- Fix a named bug or analyzer warning.
- Write/update docs and tests.
- Reuse existing widgets/models; follow existing patterns.

## 7. What AI agents should NOT do (without explicit human intent)

- Change auth/onboarding routing, `firestore.rules`, indexes, or data contracts
  carelessly.
- Change `applicationId`/`namespace`, `firebase_options.dart`, signing, or CI.
- Introduce a new state management or navigation pattern.
- Create duplicate models/widgets/services (a duplicate `NewsArticleModel` /
  `news_article.dart` already exists — do not add more; consolidation is a
  planned, human-reviewed task).
- Hardcode colors/strings instead of theme tokens.
- Add or expose any secret / key / `google-services.json`.
- Do large multi-file refactors in one shot.

## 8. Documentation map

- Product behavior: [APP_STATE.md](APP_STATE.md)
- Architecture: [ARCHITECTURE.md](ARCHITECTURE.md)
- Data/Firestore: [DATA_CONTRACTS.md](DATA_CONTRACTS.md)
- Decisions/risks: [DECISIONS_AND_RISKS.md](DECISIONS_AND_RISKS.md)
- Known issues: [known-issues.md](known-issues.md)
- Setup/dev: [setup.md](setup.md), [development-guide.md](development-guide.md)
- Handoff: [HANDOFF.md](HANDOFF.md)

## 9. Safe coding rules

Riverpod only · named routes only · repositories for data · theme tokens only ·
handle loading/error/empty · one small task at a time · review every diff · run
`flutter analyze` and the app before accepting.

## 10. Common commands

```bash
flutter pub get
flutter analyze
dart format .
flutter run --dart-define=ENV=development
flutter test
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols --dart-define=ENV=prod
```

## 11. Current TODOs / watch-outs

- Duplicate article model to consolidate (`NewsArticleModel` vs `news_article.dart`).
- `firestore.rules`: `shareCount` (code) vs `sharesCount` (rules); review nested
  comments rule.
- Analyzer is not clean; existing mojibake in some comments/strings — don't spread.
- Some screens still need real empty/error states and real data (Explore samples,
  Activity dummy items).
- Security: rotate Admin SDK key, strong keystore password, restrict Cloudinary
  preset. See [../SECURITY.md](../SECURITY.md).

Full backlog: [../PROJECT_TODO.md](../PROJECT_TODO.md) and [known-issues.md](known-issues.md).
