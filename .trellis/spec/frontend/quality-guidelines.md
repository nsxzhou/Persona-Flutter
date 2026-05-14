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

---

## Required Patterns

* Wrap the app in `ProviderScope`.
* Use `MaterialApp.router` with `go_router`.
* Use `ConsumerWidget` when reading providers in widgets.
* Handle loading/error/data branches for async providers.

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
