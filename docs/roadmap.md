# Roadmap

A planning document — direction and intent, **not** a strict promise. Dates are
targets and will move. Current context: July 2026, sole developer, preparing the
first Play Store release. Company DUNS expected early August 2026.

---

## Current phase — Documentation & stabilization (July 2026)

- Repository documentation and launch-readiness pass (this effort).
- Scope freeze for v1.0.0 ([v1-launch-scope.md](v1-launch-scope.md)).
- Close launch blockers from [../PLAY_STORE_AUDIT.md](../PLAY_STORE_AUDIT.md).

## v1.0.0 — First Play Store launch

First public production release (Android). Everything in the "Implemented"
column of [features.md](features.md), plus launch hardening (security items,
production content, store paperwork). See
[play-store-launch-checklist.md](play-store-launch-checklist.md).

## v1.0.1 — Hotfix release

Reserved for bugs found after launch: crashes, broken flows, review feedback.
Fast turnaround, no new features.

## v1.1.0 — UX improvement release

- Real empty/error states everywhere.
- Real Profile Activity feed (replace dummy items).
- Consolidate the duplicate article model.
- Polish based on early user feedback.

## v1.2.0 — Growth / features release

- Startup directory / search.
- Funding tracker with filters.
- Real personalization (interests + follows in feed ranking).
- Indexed search backend.

## Future ideas

- Direct messaging.
- StartupsIndia Pro subscription (monetization).
- Founder dashboard, events with RSVP, learning/playbooks.
- Admin/moderation panel maturity.
- iOS release (requires bundle id fix + Apple account).

---

## Working timeline (target)

| Window | Focus |
|---|---|
| Jul 9–14 | Documentation, audit, scope freeze |
| Jul 15–21 | v1.0.0 feature completion + launch hardening |
| Jul 22–27 | QA, stabilization, polish |
| Jul 28–31 | Play Store assets, listing, and submission prep |
| Aug (week 1) | DUNS expected → Play Console organization/developer account flow |

> The Play Console org verification and (for new accounts) closed-testing
> requirements can add days — see [release-plan.md](release-plan.md) and
> [play-store-launch-checklist.md](play-store-launch-checklist.md).
