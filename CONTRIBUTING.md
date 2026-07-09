# Contributing to StartupsIndia

Welcome! This guide is for future developers and interns working on the
StartupsIndia Flutter app. It keeps the codebase consistent and safe to change
while the app is being prepared for its v1.0.0 Play Store launch.

If you only read one thing: **make small, scoped changes, run `flutter analyze`,
test the screen you touched, and update the docs in the same commit.**

---

## 1. Set up the project

Follow [docs/setup.md](docs/setup.md) for the full setup (Flutter, Android, Java,
Firebase config, running the app). Quick version:

```bash
flutter pub get
flutter run
```

You will need `android/app/google-services.json` from the Firebase project — it
is gitignored and must be obtained from the project owner. See
[docs/configuration.md](docs/configuration.md).

---

## 2. Branch naming

Work on a branch, not directly on `main`.

| Prefix | Use for | Example |
|---|---|---|
| `feat/` | New feature or screen | `feat/funding-tracker` |
| `fix/` | Bug fix | `fix/comment-count-mismatch` |
| `docs/` | Documentation only | `docs/release-plan` |
| `chore/` | Tooling, deps, config | `chore/bump-riverpod` |
| `refactor/` | Internal change, no behavior change | `refactor/split-firestore-repo` |

---

## 3. Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(optional scope): short summary

optional body explaining what and why
```

Examples:

```
feat(community): add leave-community confirmation dialog
fix(auth): validate pre-filled phone field without user interaction
docs(readme): add documentation index
```

Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `ci`, `style`.

> Do not add AI co-authorship trailers to commit messages.

---

## 4. Code style

- Follow the lint rules in [analysis_options.yaml](analysis_options.yaml)
  (`flutter_lints`). Run `flutter analyze` before every commit.
- Format with `dart format .`.
- Use the existing theme tokens (`AppColors`, `AppTypography` in
  `lib/theme/style_guide.dart`) — do not hardcode colors or text styles.
- Keep UI out of Firebase where practical: prefer providers/repositories. See
  [docs/architecture.md](docs/architecture.md) → repository pattern.
- Match the surrounding code's naming, structure, and comment density.
- Do not spread the existing mojibake/encoding artifacts found in some older
  comments and strings (see [docs/known-issues.md](docs/known-issues.md)).

---

## 5. Adding things — where they go

The app uses a **feature-first** layout under `lib/features/<feature>/` with
`data/`, `domain/`, and `presentation/` subfolders. Details and "where do I add
X" guidance are in [docs/development-guide.md](docs/development-guide.md).

- New screen → `lib/features/<feature>/presentation/screens/` + register a route
  in `lib/main.dart`.
- Reusable widget → feature `presentation/widgets/` or `lib/core/presentation/widgets/`.
- Data access → a repository under `data/repositories/`, exposed via a Riverpod
  provider. Do not call Firebase directly from widgets.
- Assets → `assets/...` and declare them in `pubspec.yaml`.

---

## 6. Before you open a PR / checkpoint

Run through this checklist:

- [ ] `flutter analyze` — no new errors (the repo is not warning-clean yet; do
      not add new warnings).
- [ ] `dart format .` applied.
- [ ] App runs and the affected screen works (see [docs/testing-guide.md](docs/testing-guide.md)).
- [ ] No secrets, keys, or `google-services.json` committed (see [SECURITY.md](SECURITY.md)).
- [ ] Docs updated if behavior, data shape, or a decision changed:
  - Product behavior → `docs/APP_STATE.md`
  - Firestore shapes/rules → `docs/DATA_CONTRACTS.md`
  - A decision or risk → `docs/DECISIONS_AND_RISKS.md`
  - Notable change → `CHANGELOG.md` (Unreleased)
- [ ] Commit message follows Conventional Commits.

---

## 7. Working with AI / vibe coding

This repo is developed partly with AI assistance. There are firm rules to avoid
architecture drift, duplicate files, and broken flows. **Read
[docs/vibe-coding-guide.md](docs/vibe-coding-guide.md) before using an AI agent
on this codebase.** The short version: give the agent one small, specific,
testable task and review every changed file.

---

## 8. Suggested issue labels

If you use GitHub Issues, a small, practical label set:

`bug`, `feature`, `docs`, `tech-debt`, `launch-blocker`, `firebase`, `good-first-issue`.

Existing backlogs live in [PROJECT_TODO.md](PROJECT_TODO.md) and
[docs/known-issues.md](docs/known-issues.md).
