# Testing Guide

How to verify the app before a release. The app currently relies mostly on
**manual testing**; automated coverage is minimal and is a known TODO.

Automated tests today:
- [../test/core/utils/phone_number_validator_test.dart](../test/core/utils/phone_number_validator_test.dart) — unit test.
- [../test/widget_test.dart](../test/widget_test.dart) — **stale** default counter
  test (references a `MyApp(isFirstRun:)` param that no longer exists); fix or
  replace it ([known-issues.md](known-issues.md)).

---

## 1. Testing goals

- No crashes or dead-ends in the core flows on a real device release build.
- No placeholder/fake data visible to users.
- Graceful behavior on slow/failed network.

## 2. Commands

```bash
flutter analyze                 # static analysis (review; no new errors)
dart format --set-exit-if-changed .   # formatting check
flutter test                    # run unit/widget tests
flutter run                     # manual run
flutter build apk --debug       # debug build sanity
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols --dart-define=ENV=prod
```

## 3. Device testing matrix

| Dimension | Cover at least |
|---|---|
| OS version | Android 8 (API 26) and a recent Android (13/14+) |
| Screen size | One small phone, one large phone |
| Theme | Light and dark |
| Network | Wi-Fi, slow 3G, offline |
| Account | New signup, returning user, guest |

## 4. Manual smoke test (run before every release)

Fresh install → walk the full happy path:

1. **Fresh install / splash** → correct route for a logged-out user (`/welcome`).
2. **Onboarding** → pick each of a couple of roles; interests; fill profile saves.
3. **Signup** → email/password validation; account created.
4. **Google Sign-In** → succeeds on a device with SHA-1 registered.
5. **Home** → feed loads; trending; category sections; open an article.
6. **Article** → media, body, like, comment, bookmark, share, related carousel.
7. **Explore** → media feed loads; like/comment/bookmark/share.
8. **Communities** → discover, join, read announcements, comment in bottom sheet.
9. **Profile** → tabs (Overview/Activity/Groups/Bookmarks); edit profile saves.
10. **Notifications** → receive an FCM message (foreground snackbar + tray); tap
    deep-links to `/notifications`.
11. **Settings** → toggle dark mode (persists); notification prefs; legal/about.
12. **App restart** → session persists; theme persists.
13. **Guest mode** → protected actions prompt sign-up instead of writing.
14. **Delete account** → re-auth + deletion works; user is signed out.

## 5. Failure-mode testing

- **Network failure**: enable airplane mode mid-flow — feeds/detail should show
  an error or cached state, not hang forever.
- **Slow internet**: throttle to slow 3G — loading (shimmer) states appear; no
  frozen UI.
- **API/Firestore errors**: e.g. open a screen needing a missing composite index
  — confirm a handled error, then add the index Firestore suggests.
- **Empty data**: a user with no bookmarks/groups — confirm empty states (some
  are still TODO, [known-issues.md](known-issues.md)).

## 6. Build testing

- Debug build installs and runs.
- Release AAB installs via `bundletool` and all flows work on the **release**
  build (App Check + Play Integrity behave differently from debug).

## 7. Pre-release smoke test (release build)

Run section 4 against the **release AAB on a physical device** — Google Sign-In,
App Check, notifications, and obfuscation only fully validate on release.

## 8. Regression checklist (after any change near core flows)

- [ ] Splash routing still correct (logged-out / logged-in / onboarding-incomplete)
- [ ] Login + Google Sign-In still work
- [ ] Home feed + article detail still load
- [ ] Like/bookmark/comment still persist
- [ ] Communities join/leave + comments still work
- [ ] Profile edit still saves
- [ ] Notifications still deep-link
- [ ] `flutter analyze` has no new errors

## 9. Automated testing — TODO

Priorities when adding tests (see [../PROJECT_TODO.md](../PROJECT_TODO.md)):
- Fix/replace the stale `widget_test.dart`.
- Model `fromFirestore`/`toFirestore` unit tests.
- Splash routing decision widget test.
- Login/signup validation tests.
- Repository tests against the Firebase emulator or fakes.
- Add `flutter analyze` + `flutter test` as CI gates.
