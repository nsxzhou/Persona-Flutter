# Database Guidelines

> Database patterns and conventions for this project.

---

## Overview

Persona Flutter uses Drift over SQLite for local persistence. The database is initialized in-process from Dart; there is no separate local HTTP backend.

---

## Query Patterns

Keep raw Drift access behind repositories or data sources. UI and feature presentation code should consume domain/application contracts, not table records.

---

## Migrations

Schema changes must update Drift table definitions and generated files.

Run:

```bash
dart run build_runner build
flutter analyze
flutter test
```

---

## Naming Conventions

Use descriptive table class names ending in `Records` for persisted task-like records, for example `WorkflowTaskRecords`.

---

## Common Mistakes

* Do not expose Drift row types directly to UI.
* Do not edit generated `*.g.dart` files manually.
