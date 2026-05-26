# fix: workbench multiple tickers error

## Goal

Fix the Flutter runtime error on the Novel Workshop page:
`_WorkbenchTabsState is a SingleTickerProviderStateMixin but multiple tickers were created.`

## What I already know

* The screenshot shows the error inside the project workbench page.
* `_WorkbenchTabsState` owns a `TabController`.
* `_WorkbenchTabsState.didUpdateWidget` disposes and recreates the `TabController` when the tab length changes.
* The state currently uses `SingleTickerProviderStateMixin`, which is incompatible with creating more than one ticker over the lifetime of the state.

## Requirements

* Fix the crash without changing the user-facing workshop tabs or routing behavior.
* Keep the fix minimal and aligned with Flutter tab controller patterns.

## Acceptance Criteria

* [ ] Opening or updating the Novel Workshop page no longer triggers the multiple ticker assertion.
* [ ] Flutter analyzer reports no new issue from the change.

## Out of Scope

* Redesigning the workbench UI.
* Changing tab labels, tab counts, or project-origin branching.

## Technical Notes

* Impacted file: `lib/src/features/novel_workshop/presentation/novel_workshop_page.dart`.
* Relevant frontend specs: `.trellis/spec/frontend/component-guidelines.md`, `.trellis/spec/frontend/state-management.md`, `.trellis/spec/frontend/quality-guidelines.md`, `.trellis/spec/frontend/type-safety.md`.
