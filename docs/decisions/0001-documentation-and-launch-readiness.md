# ADR 0001: Documentation and Launch Readiness

## Status

Accepted — 2026-07-09

## Context

StartupsIndia is feature-complete for its first Play Store release (v1.0.0) and
is being prepared for launch, with the company's DUNS number expected in early
August 2026. It is maintained by a single developer (now an intern) who works in
an AI-assisted ("vibe coding") style.

The repository already had good, actively-maintained "living state" docs
(`docs/APP_STATE.md`, `ARCHITECTURE.md`, `DATA_CONTRACTS.md`,
`DECISIONS_AND_RISKS.md`, `HANDOFF.md`), plus a strong `PLAY_STORE_AUDIT.md` and
`PROJECT_TODO.md`. However, it was missing standard onboarding, process, and
launch documentation (setup, contributing, security policy, changelog, release
plan, launch checklist, testing, troubleshooting, roadmap, handover, and an
explicit AI-usage guide), and it lacked common root files (`LICENSE`,
`CHANGELOG.md`, `CONTRIBUTING.md`, `SECURITY.md`, `.env.example`).

A key constraint: the existing docs use their own filenames and an explicit
"update in the same commit as the code" protocol. Blindly imposing a different
template would have duplicated content and fragmented the source of truth.

## Decision

Adopt a **keep-and-extend** documentation strategy:

1. **Preserve** the existing `docs/*.md` as the canonical living-state docs.
2. **Add** the missing onboarding/process/launch docs using clear, standard
   lowercase filenames, cross-linked to the existing docs rather than duplicating
   them (e.g. the new `configuration.md`/`known-issues.md` reference, not copy,
   `DATA_CONTRACTS.md`/`DECISIONS_AND_RISKS.md`).
3. **Unify** everything through a grouped `docs/README.md` index and a
   documentation section in the root `README.md`.
4. **Add** root files: `LICENSE` (proprietary placeholder, pending company
   confirmation), `CHANGELOG.md`, `CONTRIBUTING.md`, `SECURITY.md`, `.env.example`.
5. **Document, don't refactor:** no application logic was changed. Only docs,
   metadata, and a `.gitignore` exception (`!.env.example`) were added.
6. **Handle secrets safely:** existing security gaps (Admin SDK key rotation,
   weak keystore password, unrestricted Cloudinary preset, committed
   `ROLE_DETAILS.md`) are recorded as TODOs in `SECURITY.md`/`known-issues.md`;
   no secret values are printed.

## Consequences

**Positive**
- One coherent, cross-linked documentation set for developers, the company, and
  future AI sessions.
- The existing maintained docs and their update protocol are preserved.
- Launch readiness (scope, checklist, release process) is written down and
  actionable.
- AI-assisted work has explicit guardrails (`vibe-coding-guide.md`,
  `ai-agent-context.md`).

**Trade-offs**
- Two filename styles now coexist (`UPPERCASE` living docs + lowercase guides).
  Mitigated by the grouped index explaining the split.
- Some overlap between `known-issues.md` and `DECISIONS_AND_RISKS.md`; kept
  intentionally (different audiences) and cross-linked.

## Follow-ups

- Company to confirm the final license (replace the proprietary placeholder if
  open-sourcing).
- Decide whether `ROLE_DETAILS.md` should remain in git (`HANDOFF.md` marks it
  private).
- Close the security TODOs before tagging `1.0.0`.
- Keep `CHANGELOG.md` `Unreleased` current; add ADRs here for future significant
  decisions (`0002-…`, etc.).
