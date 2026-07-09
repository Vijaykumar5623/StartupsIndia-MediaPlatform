# Vibe Coding Guide

This app is built partly with AI assistance ("vibe coding"). AI is a great
accelerator here, but on a real, launch-bound codebase it can also silently
introduce duplicate files, drift the architecture, break working screens, or
change production config. This guide keeps AI help fast **and** safe.

## Golden Rule

> Do not ask the AI agent to "improve the app" generally. Always give it a small,
> specific, testable task.

---

## 1. What vibe coding means for this project

- Small, scoped, reviewable changes driven by AI, on top of a stable structure.
- The human (you) stays the architect and reviewer. The AI is a fast pair of
  hands, not the decision-maker.
- The `docs/` folder is the AI's memory. Keep it accurate so every session starts
  with correct context. Start sessions by pointing the agent at
  [ai-agent-context.md](ai-agent-context.md).

## 2. When AI is a good fit

- A single screen's UI polish or copy.
- Adding one clearly-specified widget or provider.
- Writing a repository method with a known Firestore shape.
- Fixing a specific analyzer warning or bug you can describe.
- Writing/updating docs and tests.

## 3. When NOT to blindly trust AI

- Anything touching **auth/onboarding routing** (splash → welcome → role → …).
- **Firestore rules**, indexes, or data contracts (a wrong rule = security hole).
- **Build/signing/CI config**, `applicationId`, `firebase_options.dart`.
- Multi-file refactors, model consolidation, or navigation changes.
- Anything the AI claims is done but you haven't run.

---

## 4. Safe vs unsafe prompts

**Good (scoped, testable):**

```
Inspect the existing login flow and only improve the error messages shown on
invalid credentials. Do not change the API contract, navigation, or providers.
```

```
In lib/features/community/…, add an empty-state widget to the Discover grid when
there are no communities. Match existing theme tokens. Don't touch the repository.
```

**Bad (open-ended, dangerous):**

```
Make the app better and redesign everything.
```

```
Refactor the whole codebase to clean architecture and fix all the warnings.
```

## 5. Rules BEFORE asking AI to modify code

- State the exact file(s)/feature and the one outcome you want.
- State what must NOT change (routes, data shapes, config, other screens).
- Ask it to inspect existing code first and reuse it (avoid new duplicates).
- If the task is big, split it into small steps and do them one at a time.

## 6. Rules AFTER AI modifies code

- Read every changed file yourself. Do not accept blindly.
- Run `flutter analyze` and `dart format .`.
- Run the app and test the affected screen (and the auth path if near it).
- Confirm no new files duplicate existing widgets/models/services.
- Confirm no secrets or config were added/changed.
- Update the relevant `docs/` file and `CHANGELOG.md` if behavior changed.

## 7. How to review AI changes

- Use `git diff` / `git status` — know exactly what changed.
- Watch for: a second copy of an existing model (e.g. the known duplicate
  `NewsArticleModel` vs `news_article.dart`), a new navigation pattern, inline
  `MaterialPageRoute` instead of named routes, hardcoded colors/strings, direct
  Firebase calls in widgets.
- If the diff is bigger than the task, that's a red flag — revert and re-scope.

## 8. Keeping context docs updated

- After a meaningful change, update [APP_STATE.md](APP_STATE.md) (behavior),
  [DATA_CONTRACTS.md](DATA_CONTRACTS.md) (data), or
  [DECISIONS_AND_RISKS.md](DECISIONS_AND_RISKS.md) (decisions).
- Update [ai-agent-context.md](ai-agent-context.md) if the "allowed / not
  allowed" boundaries or the current focus change.
- Stale docs make the next AI session confidently wrong.

## 9. Preventing architecture drift

- One state management approach: **Riverpod**. Don't let AI add `setState`-heavy
  patterns, `Provider` package, Bloc, or GetX.
- One navigation approach: **named routes** in `main.dart`.
- One theme source: `AppColors` / `AppTypography`.
- Repositories for data, providers for exposure, widgets for UI — in that order.

## 10. Preventing duplicate files

- Before creating, ask the AI to search for an existing widget/model/service.
- Reuse `core/presentation/widgets` primitives (`AppTextField`,
  `ShimmerPlaceholder`, etc.).
- Prefer editing a file over adding a "v2" of it.

## 11. Protecting production config

Never let an AI change these without your explicit, reviewed intent:
`applicationId`/`namespace`, `firebase_options.dart`, `firestore.rules`,
`android/app/build.gradle.kts` signing, CI workflows, `pubspec.yaml` version.

---

## Before accepting AI changes

- [ ] I reviewed every changed file
- [ ] I ran `flutter analyze`
- [ ] I ran the app
- [ ] I tested the affected screen manually
- [ ] I checked that no secrets were added
- [ ] I checked no duplicate file/component/service was created
- [ ] I updated docs if behavior changed
