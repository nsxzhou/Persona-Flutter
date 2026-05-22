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
