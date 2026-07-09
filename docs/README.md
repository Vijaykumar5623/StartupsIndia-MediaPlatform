# StartupsIndia — Documentation Index

This folder is the working source of truth for the StartupsIndia app. When the
app changes, update the relevant doc **in the same commit as the code change**.

The docs are grouped by purpose below. Files in `UPPERCASE` are the original,
continuously-maintained "living state" docs; lowercase files are the
onboarding / launch / process guides added during the v1.0.0 documentation pass.

New here? Read [HANDOFF.md](HANDOFF.md) first, then [APP_STATE.md](APP_STATE.md).
Building with an AI agent? Read [vibe-coding-guide.md](vibe-coding-guide.md) and
[ai-agent-context.md](ai-agent-context.md).

---

## 1. Product understanding

| Doc | One-line description |
|---|---|
| [APP_STATE.md](APP_STATE.md) | Current product behavior and all major user flows (the "what the app does today"). |
| [features.md](features.md) | Feature matrix: implemented / partial / planned, with status. |
| [HANDOFF.md](HANDOFF.md) | Quick briefing for a new person or chat session picking up the project. |

## 2. Developer onboarding

| Doc | One-line description |
|---|---|
| [setup.md](setup.md) | Install tools, Firebase config, and run the app locally. |
| [development-guide.md](development-guide.md) | Workflow, where to add screens/widgets/services, code style. |
| [../CONTRIBUTING.md](../CONTRIBUTING.md) | Branches, commit style, pre-PR checklist. |

## 3. Architecture and configuration

| Doc | One-line description |
|---|---|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Structure, bootstrap, routing, state management, repositories. |
| [DATA_CONTRACTS.md](DATA_CONTRACTS.md) | Firestore collections, model fields, and rules notes (the backend contract). |
| [configuration.md](configuration.md) | Env values, Firebase, package id, signing, assets, permissions. |
| [../.env.example](../.env.example) | Reference for build-time (`--dart-define`) configuration. |

## 4. Testing and troubleshooting

| Doc | One-line description |
|---|---|
| [testing-guide.md](testing-guide.md) | Manual test checklists, device matrix, smoke and regression tests. |
| [troubleshooting.md](troubleshooting.md) | Common build/run/Firebase problems and their fixes. |
| [known-issues.md](known-issues.md) | Current bugs, tech debt, and risk areas before launch. |
| [DECISIONS_AND_RISKS.md](DECISIONS_AND_RISKS.md) | Decisions already taken and the open-risk backlog. |

## 5. Release and Play Store

| Doc | One-line description |
|---|---|
| [release-plan.md](release-plan.md) | Version naming, build types, signing, release checklist, hotfixes. |
| [play-store-launch-checklist.md](play-store-launch-checklist.md) | Everything required before and during Play submission. |
| [v1-launch-scope.md](v1-launch-scope.md) | Exact scope of v1.0.0: must-have, nice-to-have, not-for-v1. |
| [../PLAY_STORE_AUDIT.md](../PLAY_STORE_AUDIT.md) | Detailed readiness audit with blockers and fixes. |

## 6. Project management and handover

| Doc | One-line description |
|---|---|
| [roadmap.md](roadmap.md) | Planned releases (v1.0.0 → v1.2.0) and a working timeline. |
| [handover-notes.md](handover-notes.md) | Ownership, accounts the company must hold, and handover items. |
| [../PROJECT_TODO.md](../PROJECT_TODO.md) | Long-form product/engineering backlog. |
| [decisions/0001-documentation-and-launch-readiness.md](decisions/0001-documentation-and-launch-readiness.md) | ADR for this documentation effort. |

## 7. Vibe coding workflow (AI)

| Doc | One-line description |
|---|---|
| [vibe-coding-guide.md](vibe-coding-guide.md) | How to use AI agents on this repo without breaking it. |
| [ai-agent-context.md](ai-agent-context.md) | A compact project briefing to paste into future AI sessions. |

---

## Update protocol

1. Change the code.
2. Update the relevant `docs/` file (product → `APP_STATE.md`; data/rules →
   `DATA_CONTRACTS.md`; decision/risk → `DECISIONS_AND_RISKS.md`).
3. Add a line to [../CHANGELOG.md](../CHANGELOG.md) under `Unreleased` for notable
   changes.
4. Run the narrowest useful check (`flutter analyze`, the affected screen) and
   note any known failure.

> Private or client-only requirement files must not be copied here verbatim if
> they are marked not-for-GitHub. Summarize the implemented behavior instead.
