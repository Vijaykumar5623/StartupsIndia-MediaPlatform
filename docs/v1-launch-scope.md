# v1.0.0 Launch Scope

Defines exactly what "done" means for the first Play Store release, so scope
doesn't creep. Pair with [features.md](features.md) (what exists) and
[play-store-launch-checklist.md](play-store-launch-checklist.md) (submission gate).

---

## 1. v1.0.0 goal

Ship a stable, honest, production-signed Android app to Google Play that lets a
real user: sign up by role, browse a real news feed and Explore feed, join
communities, interact (like/comment/bookmark/share), manage their profile, and
receive notifications — with no placeholder/fake data visible.

## 2. Must-have before launch

Launch is blocked until these are true.

- [ ] All "Implemented" features in [features.md](features.md) work end-to-end on
      a release build.
- [ ] No visible placeholder/fake/mock data in user-facing surfaces (Explore
      samples, Activity dummy items, "coming soon" actions that look real).
- [ ] Real production content seeded (articles, sources, communities).
- [ ] Security items closed: rotate Admin SDK key, strong keystore password,
      restricted Cloudinary preset ([../SECURITY.md](../SECURITY.md)).
- [ ] `firestore.rules` deployed and cleaned (`shareCount` vs `sharesCount`,
      nested comments rule) ([known-issues.md](known-issues.md)).
- [ ] Production AAB builds signed with the real upload keystore.
- [ ] Privacy policy, account-deletion, and terms URLs live and correct.
- [ ] Play Console: listing, Data Safety, content rating, reviewer test login.
- [ ] Smoke test of every major flow on a real device from the release build
      ([testing-guide.md](testing-guide.md)).

## 3. Nice-to-have before launch (not blocking)

- [ ] Real empty/error states on all data-backed screens.
- [ ] A couple of automated smoke/model tests.
- [ ] Consolidated article model.
- [ ] Light-mode audit pass on every screen.
- [ ] 8 polished store screenshots (light + dark).

## 4. Not for v1.0.0

- Startup directory/search, funding tracker, direct messaging, Pro subscription.
- Real personalization / feed ranking.
- Indexed search backend.
- iOS / web / desktop release.
- Admin panel features beyond what already exists.

## 5. Post-launch backlog

Tracked in [roadmap.md](roadmap.md), [../PROJECT_TODO.md](../PROJECT_TODO.md),
and [known-issues.md](known-issues.md). First candidates: real Activity feed,
empty/error states, model consolidation, then growth features.

## 6. Final launch readiness checklist (one screen)

- [ ] Blockers in [../PLAY_STORE_AUDIT.md](../PLAY_STORE_AUDIT.md) resolved
- [ ] `flutter analyze` reviewed; no new errors
- [ ] Release AAB installs and runs on a physical device
- [ ] All must-have items above are checked
- [ ] Store listing + Data Safety + content rating complete
- [ ] Reviewer login provided
- [ ] Internal testing track validated before production rollout

> When every must-have box is checked and the checklist above is green, tag
> `1.0.0` and proceed to submission per [release-plan.md](release-plan.md).
