# Frontend page redesign

## Goal

Refactor the current Flutter frontend into a more deliberate, production-grade desktop UI that follows `.trellis/spec/frontend/`, with a stronger app shell, clearer page hierarchy, and feature surfaces that match the project's writing-workspace product model.

## What I already know

* The app is a Flutter desktop-first single-repo project.
* Current routes are `Projects`, `Style Lab`, `Plot Lab`, `Workflow Runs`, and `Settings`.
* The existing shell uses a fixed `NavigationRail` with five labeled destinations.
* `Projects`, `Style Lab`, `Plot Lab`, and `Settings` are placeholder pages built on `FeaturePlaceholderPage`.
* `Workflow Runs` is the only page with real data binding; it reads `recentWorkflowTasksProvider`.
* The frontend spec defines three visual models: writing desk, creative canvas, and operations console.
* The global palette should stay white / graphite / cobalt, light-first, restrained, text-first.
* The current theme is minimal and generic; it does not yet express the project-specific visual language.
* `Projects` is the landing workspace and should lead with recent projects, quick actions, and a current workspace summary.

## Assumptions (temporary)

* The redesign can adjust page information architecture while keeping the current route set.
* The work should prioritize shared shell/theme/presentation polish over domain logic changes.
* The redesign should preserve existing navigation and task data behavior.
* The app should lean toward a structured creative command center: information-dense, crisp, and layered, while staying compatible with long-session writing.

## Open Questions

* None. Current scope is ready to implement.

## Requirements (evolving)

* Upgrade the app shell to better match the frontend visual spec.
* Make the desktop navigation feel more intentional than a fixed-width default `NavigationRail`.
* Replace placeholder-page repetition with stronger shared page structure.
* Keep `Workflow Runs` dense and operational, while letting creative areas feel more expressive.
* Ensure light and dark themes remain supported.
* Redesign page layout and information hierarchy without changing business/data-layer behavior.
* Treat `Projects` as the landing workspace with recent projects, quick actions, and current workspace summary.
* Use static presentation examples only where the business/data layer does not yet exist.

## Acceptance Criteria (evolving)

* [ ] The app shell matches the spec's desktop navigation direction.
* [ ] The pages no longer feel like untouched placeholders.
* [ ] The redesign uses the project's prescribed palette and density rules.
* [ ] `Workflow Runs` still renders actual provider data.
* [ ] The UI remains usable on desktop-sized layouts.

## Definition of Done

* Tests added/updated where behavior changes.
* `flutter analyze` and `flutter test` pass, or remaining failures are documented.
* Visual design choices align with `.trellis/spec/frontend/visual-design-guidelines.md`.
* Changes are limited to the frontend surface unless a deeper refactor is necessary.

## Out of Scope

* Provider CRUD and backend/domain feature implementation.
* Authentication, sync, cloud backend, or remote services.
* Route expansion beyond the current feature set unless explicitly requested.

## Technical Notes

* Entry point: `lib/main.dart`
* App root: `lib/src/app/persona_app.dart`
* Routing: `lib/src/core/router/app_router.dart`
* Shell: `lib/src/core/ui/app_shell.dart`
* Shared placeholder surface: `lib/src/core/ui/feature_placeholder_page.dart`
* Theme: `lib/src/core/theme/app_theme.dart`
* Feature pages: `lib/src/features/*/presentation/*.dart`
* Frontend spec: `.trellis/spec/frontend/index.md`
* Visual design spec: `.trellis/spec/frontend/visual-design-guidelines.md`
