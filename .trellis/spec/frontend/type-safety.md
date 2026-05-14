# Type Safety

> Type safety patterns in this project.

---

## Overview

Use Dart's type system with generated model contracts for long-lived domain and persistence boundaries.

The baseline generator set is:

* `drift` / `drift_dev`
* `freezed`
* `json_serializable`
* `riverpod_generator`
* `build_runner`

---

## Type Organization

* Domain entities and value objects live in `features/<feature>/domain/` or `core/<area>/domain/`.
* Drift table records are persistence types and stay in `data/` or `core/database/`.
* Convert persistence types into domain types before exposing data to UI.

---

## Validation

Validate at application/service boundaries. Use explicit constructors, value objects, or use-case validation before writing to Drift.

---

## Common Patterns

Use `freezed` for immutable domain models and discriminated unions. Use `json_serializable` when a model crosses a JSON import/export/backup boundary.

---

## Forbidden Patterns

Avoid broad `dynamic`, unchecked casts, and passing Drift row types directly into presentation widgets.
