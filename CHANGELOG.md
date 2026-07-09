# Changelog

All notable changes to the StartupsIndia app are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project aims to follow [Semantic Versioning](https://semver.org/).

Version numbers map to `pubspec.yaml` `version: <name>+<code>` (e.g. `1.0.0+1`),
where the name is the Play Store version and the `+code` is the Android
`versionCode`. See [docs/release-plan.md](docs/release-plan.md).

---

## [Unreleased]

### Added
- Repository documentation set for launch readiness: developer setup, development
  guide, vibe-coding guide, features matrix, roadmap, release plan, Play Store
  launch checklist, testing guide, configuration, troubleshooting, known issues,
  handover notes, AI-agent context, and v1 launch scope (see [docs/](docs/)).
- Root project files: `CHANGELOG.md`, `CONTRIBUTING.md`, `SECURITY.md`,
  `LICENSE` (proprietary placeholder), and `.env.example`.
- Architecture Decision Record 0001 documenting the documentation-and-launch
  readiness effort.

### Changed
- Expanded `README.md` with an explicit pre-launch status, a documentation index,
  and a security note.

### Notes
- No application logic changed in this documentation pass. Existing behavior is
  described, not modified.

---

## [1.0.0] - Planned (target: pre-DUNS, early August 2026)

First production Play Store release. See
[docs/v1-launch-scope.md](docs/v1-launch-scope.md) for the exact scope and
[docs/play-store-launch-checklist.md](docs/play-store-launch-checklist.md) for
launch gating items.

### Goal
- First public production release on Google Play (Android).

### Included (implemented in the codebase today)
- Role-based onboarding (Founder, Student, Mentor, Investor, College, Startup
  Enthusiast) with role-specific profile fields.
- Email/password and Google Sign-In via Firebase Auth; guest browsing mode.
- Home news feed with trending, category sections, article detail, comments,
  likes, bookmarks, share, and reporting.
- Explore media/reel feed backed by Firestore `posts`.
- Firestore-driven communities with announcements and bottom-sheet comments.
- Profile with Overview / Activity / Groups / Bookmarks tabs and edit profile.
- Push notifications (FCM + local notifications) with in-app notification list.
- Crashlytics, Firebase App Check, obfuscated signed release builds via CI.

### Known open items before tagging 1.0.0
- Rotate the Firebase Admin SDK key and replace the weak local keystore password.
- Restrict the Cloudinary unsigned upload preset.
- Resolve `firestore.rules` cleanups (`shareCount`/`sharesCount`, nested comments
  rule) noted in [docs/known-issues.md](docs/known-issues.md).
- Play Console store listing, Data Safety form, screenshots, and reviewer login.

---

## Versioning legend

| Version | Meaning |
|---|---|
| `1.0.0` | First production Play Store launch |
| `1.0.x` | Hotfix / bug-fix release |
| `1.x.0` | Minor feature / UX improvement release |
| `2.0.0` | Major redesign or architecture change |
