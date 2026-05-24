# Quality Guidelines

> Code quality standards for frontend development.

---

## Overview

Flutter UI quality is enforced with `flutter_lints`, generated-code freshness, analyzer checks, and focused widget tests.

---

## Forbidden Patterns

* Do not leave default Flutter counter scaffold code in product UI.
* Do not edit generated `*.g.dart` / `*.freezed.dart` files manually.
* Do not let widgets import Drift table records directly.
* Do not add routes without updating route metadata and shell navigation consistently.
* Do not keep unused route metadata fields, dead placeholder widgets, or placeholder-only files once the real screen exists.

---

## Required Patterns

* Wrap the app in `ProviderScope`.
* Use `MaterialApp.router` with `go_router`.
* Use `ConsumerWidget` when reading providers in widgets.
* Handle loading/error/data branches for async providers.
* Add or update widget tests when changing shell navigation, responsive layout behavior, or empty/loading/error states that users can see.
* Cache expensive pure theme objects at module scope when `MaterialApp.router` switches between them frequently; do not rebuild the full light/dark theme graph on every widget rebuild.
* Keep persistent shell blur and glass effects conservative; prefer lower blur values on large always-on surfaces when theme switching or navigation feels sluggish.

---

## Testing Requirements

Run before commit:

```bash
dart run build_runner build
dart format lib test .trellis/spec
flutter analyze
flutter test
```

Add widget tests for navigation, shell behavior, and user-visible feature state.

---

## Code Review Checklist

* Does the route appear in `AppRoute`, `app_router.dart`, and shell navigation if it is a top-level route?
* Does provider-based UI handle errors?
* Are generated files committed and current?
* Is feature code placed under the correct `features/<feature>/` layer?
* Have redundant helper layers, placeholder files, and duplicate state fragments been removed or justified?

## Scenario: Malformed memory patch preview

### 1. Scope / Trigger
- Trigger: A review panel renders persisted Memory Patch YAML for user inspection.
- This is a presentation-layer contract because preview must surface parse problems without hiding the raw source the user needs to inspect.

### 2. Signatures
- Preview builder: `_buildMemoryPatchPreview(...)`
- Error banner: `InlineError`
- Raw source block: `CodeBlock` / selectable YAML source

### 3. Contracts
- Preview must strip code fences only as a display cleanup step.
- Preview must not use storage-only normalization to rewrite stored YAML into a different structure before parsing.
- When parsing fails, the panel must still render the raw YAML and the diff sections that are still available.

### 4. Validation & Error Matrix
- Malformed stored YAML -> render `InlineError` with the parse message
- Valid stored YAML -> render diff sections normally
- Raw YAML non-empty but malformed -> do not fail the whole page or hide the source block

### 5. Good/Base/Bad Cases
- Good: preview shows `Patch YAML 解析失败` and keeps raw YAML visible.
- Base: preview can parse the runtime memory section but some character graph fields are missing.
- Bad: preview silently rewrites malformed stored YAML and hides the fact that persistence is dirty.

### 6. Tests Required
- Widget tests for parse warning rendering and raw YAML visibility.
- Regression tests for preserving diff output when parse errors occur.

### 7. Wrong vs Correct
#### Wrong
Treat preview as a repair step for persisted YAML.
#### Correct
Treat preview as a read-only inspection surface with explicit parse warnings and raw source visibility.
