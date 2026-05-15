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
* `lib/src/core/ui/feature_placeholder_page.dart`
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
* `PersonaMetric`, `PersonaActionTile`, and `PersonaStatusPill` — compact dashboard/workflow affordances.

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
