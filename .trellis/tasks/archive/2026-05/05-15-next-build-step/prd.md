# brainstorm: next build step

## Goal

Decide and scope the next build step for Persona Flutter so the project moves from scaffolded shell and placeholder pages toward a usable local-first writing workflow.

## What I Already Know

* The app is a desktop-first Flutter rewrite of Persona, a single-user, local-first, BYOK AI long-form writing workspace.
* The current repository has a clean top-level shell with routes for Projects, Style Lab, Plot Lab, Workflow Runs, and Settings.
* Existing implemented persistence is limited to Drift database initialization and a read-only workflow task stream.
* Feature pages are mostly placeholders, except Workflow Runs already consumes a repository/provider stream.
* The product PRD lists the first core user flow as: open app, initialize SQLite, configure an OpenAI-compatible Provider, create/import a project, run Style Lab / Plot Lab, then write in the project workbench / Zen Editor.
* The sidebar context card currently says the local workspace is waiting for BYOK Provider configuration, which makes Provider setup a natural first usable business loop.

## Assumptions (Temporary)

* The next step should be a vertical slice, not another static placeholder.
* A Provider configuration slice likely unlocks later Style Lab, Plot Lab, and rewrite workflows.
* Scope should stay local-first and in-process Dart, with no remote backend or account system.

## Decisions

* First vertical slice: Provider configuration.
* Provider API Keys will be stored in SQLite together with Provider metadata.
  * Trade-off accepted: local database files and exported backups can contain usable API Keys.
  * Mitigations required in this slice: never log API Keys, mask them in UI after entry, and make the backup/export behavior explicit when implemented.
* Provider connectivity testing will make a real network request.
  * MVP target: request the OpenAI-compatible models endpoint, such as `GET /models`, to validate base URL, API Key, network reachability, and basic compatibility.
  * Saving a Provider must not require the connectivity test to pass.

## Open Questions

* None blocking at this stage.

## Requirements (Evolving)

* Follow the existing layered feature structure: `domain/`, `application/`, `data/`, `presentation/`.
* Use Riverpod providers for application state and Drift behind repository contracts for persisted local state.
* Preserve desktop-first UI density and the existing `PersonaPage` / `PersonaPanel` component style.
* Implement Provider configuration before Projects CRUD, sample import, Style Lab, Plot Lab, or Zen Editor execution.
* Persist Provider API Keys in SQLite, not OS secure storage.
* Treat API Keys as sensitive even though they are SQLite-backed: no logs, no plaintext display after save.
* Add Provider connectivity testing with a real OpenAI-compatible models endpoint request.
* Persist the latest test status, timestamp, and sanitized failure reason.
* Use `package:http` for the connectivity probe.

## Acceptance Criteria (Evolving)

* [ ] The chosen next build step is documented with scope and out-of-scope boundaries.
* [ ] Key product and architecture decisions are captured before implementation starts, including the accepted SQLite API Key storage trade-off.
* [ ] Provider connectivity test uses a real request against an OpenAI-compatible models endpoint.
* [ ] Provider configuration data and API Keys persist locally in SQLite.
* [ ] UI can show saved providers, edit/create flows, and the latest connection test result.
* [ ] Implementation context is curated for the relevant Trellis specs before Phase 2.

## Definition of Done (Team Quality Bar)

* Tests added/updated where appropriate.
* `dart format .`, `flutter analyze`, and `flutter test` pass before the implementation is considered complete.
* Generated files are updated through `dart run build_runner build` when Drift, Freezed, JSON, or Riverpod contracts change.
* Docs/notes updated if behavior changes.
* Rollback and local data migration impact considered if persistence schema changes.

## Out of Scope (Explicit)

* Cloud sync, login, multi-user collaboration, remote backend, Redis/MQ, or SaaS deployment.
* Full Style Lab / Plot Lab AI workflow execution unless explicitly selected as the first vertical slice.
* Full Zen Editor implementation in the first next-step task.

## Technical Notes

* Platform confirmed locally as macOS Darwin ARM64 with `zsh`; repository path is `/Users/zhouzirui/code/AI/Persona-Flutter`.
* Relevant product docs inspected: `README.md`, `Persona Flutter 重写 PRD.md`, feature README files.
* Relevant code inspected: app router, app shell, feature pages, Drift database, workflow task repository/providers, widget tests.
* Relevant Trellis specs discovered: `.trellis/spec/frontend/*`, `.trellis/spec/backend/*`, `.trellis/spec/guides/*`.
