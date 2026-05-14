# Persona Flutter

Persona Flutter is the desktop-first rewrite of Persona, a single-user, local-first, BYOK AI long-form writing workspace.

## Architecture Baseline

The first scaffold uses an in-process Dart business layer instead of a separate local HTTP backend.

```text
lib/src/
├── app/                 # Flutter app root
├── core/                # Cross-cutting infrastructure
│   ├── database/        # Drift SQLite database bootstrap
│   ├── router/          # go_router routes
│   ├── tasks/           # Shared long-running task primitives
│   ├── theme/           # App theme
│   └── ui/              # Shared shell and widgets
└── features/
    ├── projects/
    ├── style_lab/
    ├── plot_lab/
    ├── workflow_runs/
    └── settings/
```

Each feature follows the same internal layer contract:

```text
features/<name>/
├── domain/          # Entities, value objects, repository contracts
├── application/     # Use cases, services, Riverpod providers
├── data/            # Drift DAOs, DTOs, mappers, repository implementations
└── presentation/    # Pages, widgets, controllers, UI state
```

## Stack

* Flutter + Dart
* `go_router` for declarative routing
* `flutter_riverpod` for state and dependency wiring
* `drift` for typed SQLite persistence
* `freezed` and `json_serializable` for generated model contracts
* `riverpod_generator` for generated Riverpod providers
* `build_runner` for generation

The current compatible generator set pins `drift` / `drift_dev` to `2.31.0` and `json_serializable` to `^6.13.0` so `riverpod_generator 4.0.3` can share the analyzer dependency on Flutter 3.41.6.

## Commands

```bash
flutter pub get
dart run build_runner build
dart format .
flutter analyze
flutter test
```

## Current Scope

Included:

* Desktop-first app shell with core navigation entries
* `Projects`, `Style Lab`, `Plot Lab`, `Workflow Runs`, and `Settings` placeholders
* SQLite initialization boundary
* Shared workflow task model and repository contract
* Code generation setup for Drift, Freezed, and JSON

Not included yet:

* Provider CRUD
* Project/chapter CRUD
* Style/Plot AI workflow implementation
* Zen Editor
* Import/export/backup behavior
* Account, login, cloud sync, or remote backend
