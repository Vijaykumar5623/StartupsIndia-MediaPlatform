# Known Issues

A living list of known bugs, technical debt, and risk areas before launch. This
complements [DECISIONS_AND_RISKS.md](DECISIONS_AND_RISKS.md) (which explains the
*why* behind decisions and deeper risks) and [../PROJECT_TODO.md](../PROJECT_TODO.md)
(the long-form backlog).

Update this file when you find or fix something. Keep it honest.

---

## Current known bugs / correctness gaps

| Item | Where | Notes |
|---|---|---|
| Stale widget test | [../test/widget_test.dart](../test/widget_test.dart) | Calls `MyApp(isFirstRun:)` which no longer exists; will fail `flutter test`. Fix or replace. |
| `shareCount` vs `sharesCount` | code vs `firestore.rules` | Rules allow `sharesCount` but code writes `shareCount`; non-admin share increments may be blocked. |
| Nested comments rule | `firestore.rules` | A `match /comments/{commentId}` nested under article comments looks accidental — review. |
| Article comment count | `PostRepository`/article comments | Adding an article comment does not increment `articles/{id}.commentsCount` in the same method. |

## Technical debt

| Item | Notes |
|---|---|
| Duplicate article model | `lib/core/models/news_article_model.dart` vs `lib/features/home/domain/models/news_article.dart`. Pick one source of truth and remove conversions. |
| Direct Firebase in UI | Some screens (Splash, Home, MediaFeed, PersonalProfile, `user_topics_provider`) call Firebase directly instead of via providers/repositories. |
| `FirestoreRepository` is large | Consider splitting into User/Article/Interaction/Topic/Upload repositories. |
| Analyzer not clean | Deprecated `withOpacity`, unused imports, unnecessary nullability, Google Sign-In v7 cleanup. Don't add new warnings. |
| Encoding artifacts (mojibake) | Some older comments/strings contain corrupted characters. Don't spread; clean up in a dedicated pass. |
| Username uniqueness can race | App-level `usernameLower` check, not a DB constraint. A `usernames/{usernameLower}` reservation doc would be safer. |

## Incomplete / mock surfaces

| Item | Notes |
|---|---|
| Profile Activity tab | Populated with dummy items; real activity indexing planned. |
| Explore sample content | Sample topics/source profiles/follow state reachable in-app; replace with production data before review. |
| Create post | Hardcoded category; validation/publish flow incomplete. |
| Empty/error states | Several screens still show indefinite spinners instead of specific empty/error UI. |
| Home Funding/Events/Courses | Screens/routes exist but are largely mock data. |

## Security / launch risk areas (see [../SECURITY.md](../SECURITY.md))

| Item | Notes |
|---|---|
| Admin SDK key rotation | Rotate the key that previously sat in the repo root. |
| Weak local keystore password | Replace before the first Play upload. |
| Cloudinary preset unrestricted | Restrict formats/size/folder in the Cloudinary console. |
| Hardcoded admin UID in rules | Move to custom claims / `admins/{uid}` lookup later. |
| `ROLE_DETAILS.md` committed | `HANDOFF.md` marks it private/not-for-push; confirm whether it should be in git. |

## Things to test carefully before launch

- Auth/onboarding routing on fresh install and returning user.
- Google Sign-In on a **release** build (SHA fingerprints).
- Notifications deep-link on foreground/background/terminated.
- Firestore reads that need composite indexes (create any the console prompts).
- Release-build behavior differences (App Check / Play Integrity).

## Deferred improvements (post-launch)

- Consolidate models, split repositories, remove direct-Firebase-in-UI.
- Real personalization and follow-based feed ranking.
- Indexed search backend (Algolia/Typesense/Meilisearch).
- Automated test coverage + CI test gates.

---

## How to maintain this file

When you find an issue: add a row with **where** it is and a one-line note.
When you fix one: remove it (or move a notable fix to [../CHANGELOG.md](../CHANGELOG.md)).
If Firestore shapes/rules changed, also update [DATA_CONTRACTS.md](DATA_CONTRACTS.md).
