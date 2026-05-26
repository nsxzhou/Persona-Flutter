# Component Guidelines

> How components are built in this project.

---

## Overview

Flutter presentation code is organized as widgets under `presentation/` for each feature or under `core/ui/` for shared shell components.

Use `StatelessWidget` for presentational components and `ConsumerWidget` when a widget reads Riverpod providers.

---

## Component Structure

Keep one primary widget per file. Private helper widgets can live below the main widget when they are only used by that file.

Examples:

* `lib/src/core/ui/app_shell.dart`
* `lib/src/core/ui/persona_page.dart`
* `lib/src/features/workflow_runs/presentation/workflow_runs_page.dart`

---

## Props Conventions

Widget constructor parameters should be `final`, typed, and marked `required` when there is no sensible default.

Use `const` constructors wherever possible.

---

## Styling Patterns

Use Material 3 theme values from `Theme.of(context)` instead of hard-coded one-off styling. Shared theme setup lives in `lib/src/core/theme/app_theme.dart`.

Shared route-level page composition should use `PersonaPage` and the small shared primitives in `lib/src/core/ui/persona_page.dart` when a feature needs the standard Persona desktop surface:

* `PersonaPage` — route header, max-width content column, scroll behavior.
* `PersonaPanel` — crisp bordered surface for one work area.
* `PersonaSectionHeader` — local section title and explanatory text.
* `PersonaMetric`, `PersonaActionTile`, `PersonaStatusPill`, and `PersonaEmptyStateCard` — compact dashboard/workflow affordances.

When the same empty state, skeleton block, metric strip, or action block appears in 2 or more pages, extract a shared primitive or a private helper instead of copying the widget tree again.

Keep shell-level controls responsive. If a sidebar, toolbar, or action row can collapse, it must still fit the narrow state without horizontal overflow; stack controls vertically when the width budget is tight.

Feature pages may compose these shared primitives, but feature-specific business meaning and data binding must remain in `features/<feature>/presentation/`.

---

## Accessibility

Prefer standard Material widgets (`NavigationRail`, `ListTile`, `Chip`, `Card`) because they carry baseline accessibility semantics.

Keep navigation labels visible in expanded desktop navigation. If the shell supports a collapsed mode, icon-only destinations must provide tooltips.

---

## Common Mistakes

* Do not put data access directly in widgets.
* Do not create feature-specific UI in `core/ui/`.
* Do not use large anonymous widget trees when a named widget improves readability.
* Do not copy the `PersonaPage` header/panel layout into individual feature pages; extend the shared primitives instead.
* Do not keep dead placeholder pages or placeholder route scaffolding after a real screen exists.
* Do not use `SingleTickerProviderStateMixin` when a `State` may recreate a `TabController` or `AnimationController` after `didUpdateWidget`. Use `TickerProviderStateMixin` for state objects that can create more than one ticker over their lifetime, even if only one controller is active at a time.

---

## Scenario: Settings Provider management surface

### 1. Scope / Trigger
- Trigger: The Settings page now renders a Provider list, create/edit dialog, delete action, and connectivity test actions.
- This is a feature-specific presentation surface that binds to Riverpod providers and must stay out of `core/ui/`.

### 2. Contracts
- Use `ConsumerWidget` or `ConsumerStatefulWidget` when reading provider state or dispatching commands.
- Keep masking logic local to presentation so API Keys are never shown in full after save.
- Surface async data with loading/error/data branches.

### 3. Validation & Error Matrix
- Empty form fields -> block submission in the dialog.
- Invalid URL -> block submission before save.
- Test failure -> show a sanitized snackbar or inline message.

### 4. Good/Base/Bad Cases
- Good: the list shows provider state, masked API Key, and test result.
- Base: provider dialog edits a single Provider record.
- Bad: widgets talk directly to Drift rows or print secret values.

### 5. Wrong vs Correct
#### Wrong
Hard-code Provider cards in `core/ui/` or bypass the repository layer from the widget.
#### Correct
Keep Provider management widgets in `features/settings/presentation/` and bind them through Riverpod providers.

## Scenario: Settings Image Provider management surface

### 1. Scope / Trigger
- Trigger: The Settings page renders text-to-image Provider management next to the existing text Provider console.
- This is a feature-specific presentation surface that binds to Riverpod providers and must stay under `features/settings/presentation/`.

### 2. Contracts
- Keep the existing text `Provider 控制台` panel unchanged. Add a separate `图像 Provider` panel below it and above `本地备份`; do not convert Settings to tabs without a separate task.
- Image Provider rows use a sample-generation test action, not a `/models` connectivity action.
- Detail UI exposes `prompt`, `model`, aspect ratio, size tier, `quality`, and `response_format` for text-to-image tests. `n` is fixed to 1; `style` and `user` are not shown in MVP.
- Supported visible aspect ratio presets are `自动`, `方形 1:1`, `竖版 3:4`, `故事版 9:16`, `横版 4:3`, and `宽屏 16:9`. Supported size tiers are `1K`, `2K`, and `4K`; quality options are `auto`, `low`, `medium`, and `high`.
- Generated images are memory-only previews. User-facing copy should not imply that the app saved or cached the image.
- Request and response inspectors must not show the full API Key.
- Keep file upload, mask controls, and image-to-image preview UI out of MVP even though the service layer has `/v1/images/edits` primitives.

### 3. Validation & Error Matrix
- Empty form fields -> block submission in the dialog.
- Invalid URL -> block submission before save.
- Sample generation failure -> show sanitized error state and persisted failed test message.
- Narrow viewport -> stack workbench and inspector vertically without layout overflow.

### 4. Good/Base/Bad Cases
- Good: Settings shows text Provider, image Provider, and local backup as separate local-control panels.
- Good: Image Provider detail renders a tool-like workbench with preview, prompt input, controls, and request/response inspector.
- Base: generated image is visible until leaving the page.
- Bad: present image Provider rows as normal text Providers or mix image-only models into project text model dropdowns.
- Bad: add upload/mask UI before a product workflow needs image-to-image editing.

### 5. Wrong vs Correct
#### Wrong
Add an `Image` tab inside the existing text Provider detail page and reuse the chat prompt/system prompt controls.
#### Correct
Route image Providers to their own detail page and use image-specific controls and inspectors.

## Scenario: Projects writing dossier surface

### 1. Scope / Trigger
- Trigger: The Projects page now renders persisted writing projects, a create/edit dialog, active/archived filtering, project actions, and a project detail route.
- This is a feature-specific presentation surface and must stay under `features/projects/presentation/`.

### 2. Contracts
- The Projects page reads `writingProjectsProvider(ProjectStatus status)`.
- The default selected status is `ProjectStatus.active`.
- The archived view is explicitly selected by the user; archived projects do not appear in the default view.
- Project detail pages read `writingProjectProvider(projectId)` and handle loading, data, missing, and error states.
- Dialog validation blocks empty project titles before saving.
- Projects overview surfaces should expose user-facing writing-workspace state, not implementation details such as `SQLite` or "local status".
- Empty Projects states should be lightweight content inside the list panel, not nested card surfaces inside another panel.

### 3. Validation & Error Matrix
- Empty active list -> show a create-project empty state.
- Empty archived list -> show an archived-empty state without a create CTA.
- Missing project detail -> show "项目不存在" and a return action.
- Repository/provider error -> render an error panel, not a blank page.

### 4. Good/Base/Bad Cases
- Good: list rows show title, description, status, update time, and action menu.
- Base: an active project can be created and opened into its detail dossier.
- Bad: keep the old placeholder action tiles after real project data exists.
- Bad: show database/storage implementation as a top-level status metric.

### 5. Wrong vs Correct
#### Wrong
Make Projects a generic card gallery or static placeholder wall after persistence exists.
#### Correct
Use a restrained writing-dossier layout: text-first list rows, compact status controls, and a detail page that reserves future workbench entry points without pretending they are implemented.

## Scenario: Preview-first patch review surfaces

### 1. Scope / Trigger
- Trigger: A generated patch is pending user review before it mutates persisted writing state.
- Keep preview composition in the feature presentation layer; do not change repository contracts just to support a richer read-only preview.

### 2. Contracts
- Review UI must show the effective result using the same merge semantics as the eventual apply path.
- Raw machine payloads such as YAML should be available in a collapsed code block, not the primary preview.
- If apply/discard is all-or-nothing, do not add row-level checkbox or partial-selection state in the preview.

### 3. Tests Required
- Widget tests should assert the visible preview sections, the collapsed raw payload behavior, and the absence of partial-selection controls.

## Scenario: Novel Reader text selection and illustration entry

### 1. Scope / Trigger
- Trigger: The Novel Reader lets users select manuscript text and create a chapter illustration draft from that exact selection.
- This is a feature-specific presentation contract under `features/novel_workshop/presentation/`.

### 2. Contracts
- Reader body text must be selectable through one reading-area `SelectionArea`, not separate paragraph-owned `SelectableText` menus. Separate selectable widgets prevent cross-paragraph selections from producing one selected text payload.
- Add the `生成插图` action through `SelectionArea.contextMenuBuilder` and read the selected text from `SelectionArea.onSelectionChanged`.
- Do not render a permanent per-paragraph `生成插图` button in the reading flow.
- When the selected text spans multiple paragraphs, the generated illustration draft anchors to the last selected paragraph.
- Accepted illustrations may render inline after their anchor paragraph; draft illustrations remain in the hidden illustration library drawer.
- Exclude inline illustration previews/captions from manuscript text selection with `SelectionContainer.disabled` when they appear inside the selectable reader body.

### 3. Validation & Error Matrix
- Empty selection -> do not add `生成插图` to the selection menu.
- No enabled image Provider -> keep the menu action visible for a non-empty selection, then show a lightweight snackbar when clicked.
- Missing chapter id -> show a lightweight snackbar and do not open the generation dialog.
- Cross-paragraph selection -> pass the full selected text to the dialog and use the last selected paragraph index.

### 4. Tests Required
- Widget test that the default reader shows manuscript text without a permanent `生成插图` button.
- Widget test that selecting text opens a context menu containing `生成插图`.
- Widget test that missing image Provider still shows the menu action and explains the missing Provider on click.
- Widget test that dragging a selection across paragraphs opens the dialog with the selected text and creates a draft anchored to the last selected paragraph.
