# Fix Sidebar Switching Ghosting And Width Jitter

## Goal

Fix two desktop shell visual regressions: page content should not leave a ghosted overlap when switching sidebar destinations, and the sidebar width should stay stable when `Workflow Runs` is selected.

## What I Already Know

* The issue is visible during `NavigationRail` destination switching.
* `Workflow Runs` is the longest sidebar label and currently causes width jitter.
* The shell implementation lives in `lib/src/core/ui/app_shell.dart`.
* `AnimatedSwitcher` currently wraps routed child content with the default transition/layout behavior.
* `NavigationRail` currently uses only `minWidth: 92`, so its actual width can grow to satisfy label layout.

## Assumptions

* This task should preserve the existing visible labels and Material `NavigationRail` component.
* A stable, non-ghosting switch is preferable to a cross-fade animation that overlays old and new page content.
* No route contract or feature page behavior should change.

## Requirements

* Keep the sidebar width constant across all destinations.
* Prevent old and new page bodies from being painted on top of each other during route changes.
* Keep the existing route list, labels, icons, and destination selection behavior.
* Keep the fix scoped to the shared app shell unless verification reveals a broader cause.

## Acceptance Criteria

* [ ] Switching between `Projects`, `Style Lab`, `Plot Lab`, `Workflow Runs`, and `Settings` does not show overlapping page text.
* [ ] Selecting `Workflow Runs` does not change sidebar width.
* [ ] Existing widget tests pass.
* [ ] `flutter analyze` passes.

## Definition Of Done

* Shell implementation is updated with minimal changes.
* Formatting, analyzer, and widget tests are green or any failures are documented.
* Existing unrelated worktree changes are not reverted or included in this task.

## Out Of Scope

* Redesigning the sidebar.
* Adding new navigation destinations.
* Changing placeholder page content.

## Technical Notes

* Relevant specs read:
  * `.trellis/spec/frontend/index.md`
  * `.trellis/spec/frontend/component-guidelines.md`
  * `.trellis/spec/frontend/directory-structure.md`
  * `.trellis/spec/guides/index.md`
  * `.trellis/spec/guides/code-reuse-thinking-guide.md`
* Main file: `lib/src/core/ui/app_shell.dart`.
