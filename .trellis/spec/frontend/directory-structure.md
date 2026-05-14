# Directory Structure

> How frontend code is organized in this project.

---

## Overview

Flutter UI and in-process Dart application code use a mixed Clean Architecture + Feature Modules layout.

App-wide infrastructure lives under `lib/src/core/`. Domain-specific code lives under `lib/src/features/<feature>/`.

---

## Directory Layout

```text
lib/src/
├── app/                 # Flutter app root
├── core/                # Cross-cutting infrastructure
│   ├── database/        # Drift SQLite bootstrap and database providers
│   ├── router/          # go_router routes and route metadata
│   ├── tasks/           # Shared long-running task primitives
│   ├── theme/           # ThemeData factories
│   └── ui/              # Shared shell/widgets
└── features/
    └── <feature>/
        ├── domain/      # Entities, value objects, repository contracts
        ├── application/ # Use cases, services, Riverpod providers
        ├── data/        # Drift DAOs, DTOs, mappers, repository implementations
        └── presentation/# Pages, widgets, controllers, UI state
```

---

## Module Organization

Each feature owns its internal `domain/application/data/presentation` layers. Feature code must not import another feature's `presentation/` or `data/` layer directly.

Cross-feature coordination goes through:

* `core/` abstractions, or
* another feature's `domain/` / `application/` contract when a dependency is intentional.

---

## Naming Conventions

Use lower snake case for Dart files and feature folders.

Generated files stay next to their source:

* `*.g.dart`
* `*.freezed.dart`

Do not edit generated files manually.

---

## Examples

Current examples:

* `lib/src/core/router/`
* `lib/src/core/tasks/`
* `lib/src/features/projects/`
