# Fix sidebar animation and collapsed alignment

## Goal

Fix two visible desktop sidebar issues: expanded-state flicker during the collapse/expand animation, and collapsed-state brand logo alignment being offset from the navigation icons.

## What I already know

* The sidebar implementation lives in `lib/src/core/ui/app_shell.dart`.
* The sidebar uses collapsed and expanded widths (`76.0` and `238.0`).
* Current implementation toggles `isExpanded` immediately while `AnimatedContainer` is still animating width.
* Collapsed navigation icons are centered in the rail, while the brand logo is left-aligned inside the sidebar padding.

## Requirements

* Sidebar expansion must not visibly flash, overflow, or abruptly show expanded-only content before enough width is available.
* Collapsed brand logo must align on the same vertical axis as the other sidebar icons.
* Existing desktop shell routes and selected-state behavior must remain unchanged.
* Keep the visual direction consistent with the existing white/graphite/cobalt writing workspace.

## Acceptance Criteria

* [ ] Toggling from collapsed to expanded animates smoothly without expanded labels/card flashing at the narrow width.
* [ ] Toggling from expanded to collapsed keeps icon alignment visually stable.
* [ ] Collapsed brand logo center aligns with collapsed navigation, context, and toggle icons.
* [ ] Existing widget tests pass, with focused coverage added for collapsed alignment and expand/collapse labels.

## Out of Scope

* No navigation route changes.
* No palette, typography, or page layout redesign outside the sidebar.
* No persistence of sidebar expanded/collapsed state.

## Technical Notes

* Relevant specs read: `.trellis/spec/frontend/component-guidelines.md`, `.trellis/spec/frontend/visual-design-guidelines.md`, `.trellis/spec/frontend/quality-guidelines.md`.
* The fix should avoid conditional insertion of expanded-only content at the start of the width animation; content reveal should be clipped/faded based on animation progress.
