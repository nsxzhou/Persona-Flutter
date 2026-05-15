# Optimize Settings UI

## Goal

Improve the Settings page so it feels like a professional local-first writing workspace control surface, with clearer information hierarchy, stronger Provider status scanning, and more deliberate treatment of local data / import / backup actions.

## What I Already Know

* The user wants a serious UI optimization of the Settings page shown in the screenshot, not a shallow cosmetic pass.
* The current route is implemented in `lib/src/features/settings/presentation/settings_page.dart`.
* Shared page primitives live in `lib/src/core/ui/persona_page.dart`.
* Theme tokens and typography are defined in `lib/src/core/theme/app_theme.dart`.
* Existing widget coverage includes `test/settings_page_test.dart`.
* Project visual direction is documented as a light-first, calm, precise, text-first desktop writing workspace using white / graphite / cobalt, with restrained shapes and no generic Material 3 look.

## Current UI Diagnosis

* The page title and Provider panel compete weakly: there is no strong page-level scan path from "what is configured" to "what needs attention" to "what can I do next".
* The Provider row is horizontally stretched across a large desktop width, so the meaningful details sit in a long flat line instead of a compact information object.
* Status is shown, but it does not explain operational meaning. A green "可用" pill confirms success, yet the user still has to parse URL, model, key, and test message manually.
* Actions are visually noisy. The primary page action, row test action, edit, and delete all sit in the same broad attention field, so destructive and routine actions are too close in perceived weight.
* The key storage warning is buried in regular body text. For a local-first BYOK product, API Key backup / persistence risk should be visible but calm.
* The three lower tiles are generic dashboard cards. They are secondary flows, but currently they repeat card styling without clarifying readiness, risk, or availability.
* Spacing is generous but not purposeful: large blank areas do not create stronger hierarchy or better task completion.

## Recommended Product Direction

Use a "local control console" treatment rather than a generic settings form. The user confirmed this direction:

* Top area should summarize Provider readiness and key-storage posture.
* Provider configuration should become the primary work area with compact, scan-friendly rows/cards.
* Status, default model, Base URL, masked key, and last test result should be visually grouped by operational meaning.
* Secondary data operations should be marked as "待开发" when unfinished, without extra explanatory modules.
* Keep the established white / graphite / cobalt palette. Use green/red only for status, and avoid decorative gradients or warm paper styling.

## Requirements (Evolving)

* Preserve existing Provider management behavior: list, empty state, add/edit dialog, delete confirmation, and connectivity test.
* Improve responsive behavior for desktop and narrow widths.
* Maintain local API Key masking after save.
* Render local data / import-export / backup-restore as simple pending items with a clear "待开发" state.
* Remove redundant introduction modules that repeat information already present in the page header or section headers.
* Avoid moving feature-specific Provider UI into `core/ui/`.
* Update or add widget tests for user-visible state if labels or structure change.

## Acceptance Criteria (Evolving)

* [ ] Settings page presents Provider readiness and data-risk context with a clear scan path.
* [ ] Provider rows/cards remain usable with long provider names, long Base URLs, and long model names.
* [ ] Test, edit, and delete actions are visually distinct and do not crowd provider details.
* [ ] Empty state still guides the user to add a Provider.
* [ ] Non-functional data operation items are visibly marked as pending development items rather than active navigation targets.
* [ ] Settings page keeps the page structure concise and avoids redundant introduction blocks.
* [ ] Existing tests pass, and updated tests reflect intentional UI changes.

## Out of Scope

* Changing persistence behavior for API Keys.
* Implementing actual import/export/backup flows.
* Adding a global theme switch.
* Reworking non-settings routes unless required by shared primitive compatibility.

## Technical Notes

* Relevant specs:
  * `.trellis/spec/frontend/index.md`
  * `.trellis/spec/frontend/component-guidelines.md`
  * `.trellis/spec/frontend/visual-design-guidelines.md`
  * `.trellis/spec/frontend/quality-guidelines.md`
* The existing page uses `PersonaPage`, `PersonaPanel`, `PersonaSectionHeader`, `PersonaActionTile`, and `PersonaStatusPill`.
* `settings_page.dart` currently contains both the Provider list surface and Provider dialog.

## Decisions

* UX posture: local control console.
* Data operation entries: status-type controls with explicit readiness labels; do not present them as completed clickable entry points.
* Provider action hierarchy: keep "新增 Provider" as the page-level primary action; make "测试连接" the primary per-Provider action; downgrade edit/delete to secondary actions.

## Open Questions

* None blocking before implementation.
