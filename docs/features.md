# Features

Status of features based on the current codebase. "Implemented" means present and
wired to Firebase/real logic; "Partial" means the UI exists but data/logic is
mock, local-only, or incomplete. Behavior detail lives in [APP_STATE.md](APP_STATE.md).

Legend: ✅ Implemented · 🟡 Partial · 🗓️ Planned · ❌ Not planned (now)

---

## Implemented features

| Feature | Status | Notes |
|---|---|---|
| Splash + session routing | ✅ | `/splash` checks Firebase user + `onboardingCompleted`, routes to welcome/role/home. |
| Email/password auth | ✅ | Sign up, sign in, password rules, forgot/change password. |
| Google Sign-In (v7) | ✅ | Requires SHA-1 in Firebase; guest fallback available. |
| Guest mode | ✅ | Browse with blur gate; protected actions prompt sign-up (`GuestGate`). |
| Role-based onboarding | ✅ | Role → account → interests → fill profile. 6 roles with role-specific fields. |
| Home news feed | ✅ | Firestore `articles`: top news, category sections, cursor pagination. |
| Trending | ✅ | `isTrending == true`, ordered by `updatedAt`. |
| Article detail | ✅ | Featured media, gallery, body, like/comment/share, related carousel. |
| Article comments | ✅ | `articles/{id}/comments` create/list. |
| Likes / bookmarks | ✅ | Transactional like; bookmark via array union/remove. |
| Reporting | ✅ | Articles/comments reported to `reports`. |
| Explore media feed | ✅ | Firestore `posts` with media, likes, bookmarks, comments, shares. |
| Communities | ✅ | Firestore-driven; join/leave, announcements, bottom-sheet comments, activity. |
| Profile (tabs) | ✅ | Overview / Activity / Groups / Bookmarks; role-specific detail rows. |
| Edit profile | ✅ | Role-specific fields; email read-only; live phone validation. |
| Delete account | ✅ | Re-auth + delete Firestore doc + Auth user. |
| Settings | ✅ | Dark mode (persisted), notification prefs (persisted), help, legal, about, Pro. |
| Push notifications | ✅ | FCM + local notifications; token sync to `users/{uid}.fcmTokens`; deep link to `/notifications`. |
| Theming | ✅ | Light/dark via `themeServiceProvider`, persisted in SharedPreferences. |
| Crashlytics + App Check | ✅ | Fatal/non-fatal reporting; Play Integrity in release. |
| CI builds | ✅ | GitHub Actions: signed ARM64 APK; manual AAB + Firebase App Distribution. |

## Partially implemented

| Feature | Status | Notes |
|---|---|---|
| Profile Activity tab | 🟡 | UI present but populated with dummy items; real activity indexing planned. |
| Explore content | 🟡 | Works, but includes sample topics/source profiles/follow state; needs production data before review. |
| Create post | 🟡 | Screen exists; hardcoded category and validation/publish flow need finishing (see [../PROJECT_TODO.md](../PROJECT_TODO.md)). |
| Empty/error states | 🟡 | Some screens still show indefinite spinners instead of specific empty/error UI. |
| Home extra sections (Funding/Events/Courses) | 🟡 | Screens/routes exist (`/funding-all`, `/events-all`, `/courses-all`); largely mock data. |
| Automated tests | 🟡 | Only a phone-validator test + a stale widget test. Coverage is a TODO. |

## Planned for v1.0.0

| Feature | Status | Notes |
|---|---|---|
| Production content seeding | 🗓️ | Real articles, sources, communities in Firestore before launch. |
| Replace remaining mock/sample data | 🗓️ | Explore samples, Activity dummy items. |
| Launch hardening | 🗓️ | Cloudinary preset restriction, key rotation, rules cleanup — [known-issues.md](known-issues.md). |

## Post-launch (v1.0.x / v1.1.0+)

| Feature | Status | Notes |
|---|---|---|
| Startup directory / search | 🗓️ | In README roadmap. |
| Funding tracker (real) | 🗓️ | Filters by stage/sector/location/deadline. |
| Direct messaging | 🗓️ | Post-launch. |
| StartupsIndia Pro subscription | 🗓️ | Pro screen exists as CTA; monetization later. |
| Real personalization / follow feed ranking | 🗓️ | Use interests + follows. |
| Indexed search (Algolia/Typesense) | 🗓️ | Current search fetches ~100 and filters client-side. |

## Not planned currently

| Item | Status | Notes |
|---|---|---|
| iOS App Store launch | ❌ | iOS scaffolding exists; not a v1 target. Bundle id still `com.example.*`. |
| Web/desktop release | ❌ | Flutter scaffolding present, not a product target. |

> TODO: confirm anything marked 🟡/🗓️ against your latest intent before scope
> freeze — see [v1-launch-scope.md](v1-launch-scope.md).
