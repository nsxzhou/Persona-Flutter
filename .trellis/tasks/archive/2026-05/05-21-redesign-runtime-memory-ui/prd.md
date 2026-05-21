# Redesign runtime memory UI

## Goal

Improve the Novel Workshop Runtime Memory presentation so the overview page remains scannable and the dedicated Runtime Memory tab feels like a first-class writing-workbench surface rather than a dense set of repeated text cards.

## What I Already Know

* User provided screenshots showing the overview and Runtime Memory tab currently render the same detailed card grid.
* The overview page should not expose Runtime Memory in full detail.
* The Runtime Memory tab should be redesigned visually while keeping the existing edit flow.
* Relevant implementation is in `lib/src/features/novel_workshop/presentation/novel_workshop_page.dart`.
* Project frontend visual model is a calm, text-first writing desk using white/graphite/cobalt with restrained task-specific accents.

## Requirements

* Overview tab shows a compact Runtime Memory summary instead of full long-form details.
* Dedicated Runtime Memory tab gets a redesigned read-only view with clearer hierarchy, better density, and stronger scan affordances.
* Empty, loading, error, and edit modes continue to work.
* No persistence schema, provider, route, or backend behavior changes.
* Keep Runtime Memory as a first-class Workshop tab.

## Acceptance Criteria

* [ ] Overview page does not display full Runtime Memory text cards.
* [ ] Runtime Memory tab presents all five memory fields in a cleaner, differentiated layout.
* [ ] Existing edit button and edit form remain functional.
* [ ] Layout stays responsive without horizontal overflow.
* [ ] `dart format` and `flutter analyze` pass, or failures are reported with evidence.

## Out of Scope

* Changing generated Runtime Memory content semantics.
* Changing database schema or repository contracts.
* Redesigning unrelated Workshop tabs.

## Technical Notes

* UI fields: `runtimeState`, `runtimeThreads`, `storySummary`, `continuityIndex`, `chapterArchiveMarkdown`.
* Existing shared primitives: `PersonaPanel`, `PersonaSectionHeader`, `PersonaEmptyStateCard`, `SkeletonBox`.
* Frontend specs read: component, visual design, state management, quality, type safety.
