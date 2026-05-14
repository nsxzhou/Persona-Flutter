# Plan Persona Flutter Architecture And Initialize Git

## Goal

Plan the basic architecture for the Persona Flutter rewrite and initialize the repository so future implementation can proceed from a clean, reviewable foundation.

## What I Already Know

* Runtime platform confirmed from local evidence: macOS/Darwin ARM64, shell `/bin/zsh`, workspace `/Users/zhouzirui/code/AI/Persona-Flutter`.
* The repository was not a Git repository initially. `git init` has now created an empty `main` branch.
* The root PRD states the rewrite target is `Flutter + Dart + SQLite`, desktop-first with macOS first, Windows second, and mobile later with functional parity as a design goal.
* The product is single-user, local-first, BYOK, OpenAI-compatible only, and should remove login, cloud sync, remote backend, Redis/MQ, and SaaS deployment concerns.
* The old reference project lives under `Persona_副本/` and is a Next.js + FastAPI + Postgres project. It should be used as domain reference, not committed as part of the new repository.
* `.gitignore` now excludes `Persona_副本/`, macOS metadata, local AI/tool caches, secrets, logs, dependencies, build outputs, caches, SQLite databases, and storage/backup artifacts.
* Old project domains to preserve conceptually: Provider Config, Style Lab, Plot Lab, Project Workbench, Zen Editor, chapters, prompt assets, workflow runs, Memory Sync, import/export/backup.

## Assumptions

* The rewrite should prioritize architecture scaffolding and project layout before implementing full product features.
* The old project should remain available locally as a reference directory, but outside Git history.
* The initial architecture should avoid premature multi-user, cloud, or distributed-worker abstractions.

## Open Questions

* No open planning questions. User confirmed implementation scope.

## Requirements

* Initialize Git in the workspace.
* Configure `.gitignore` so old project files and local temporary artifacts are not staged.
* Produce an architecture plan that covers:
  * app/module directory structure,
  * local data and migration strategy,
  * long-running task execution and recovery,
  * Provider/API key handling,
  * domain module boundaries,
  * desktop-first UI structure with future mobile parity,
  * import/export/backup boundaries.
* Use an in-process Dart business layer instead of a separate bundled local HTTP service.
* Treat "local backend" as application/domain/data services running inside the Flutter process, with long-running tasks coordinated by Dart services and persisted task state in SQLite.
* First scaffold scope is architecture skeleton only:
  * Flutter project structure.
  * Layered directory layout.
  * SQLite initialization boundary.
  * Application service interfaces.
  * Task status base model.
  * Desktop-first navigation shell.
  * Code generation setup.
  * No Provider CRUD vertical slice yet.
  * No Project/Chapter CRUD vertical slice yet.
* Baseline library stack:
  * `go_router` for declarative routing.
  * `flutter_riverpod` / Riverpod for state management and dependency injection.
  * `drift` for typed SQLite persistence and migrations.
  * `freezed` for immutable models/unions.
  * `json_serializable` for JSON serialization.
  * `build_runner` for code generation.
  * Riverpod providers are generated with `riverpod_generator`.
* Directory architecture: mixed Clean Architecture + Feature Modules:
  * `core/` owns app-wide infrastructure: routing, database bootstrap, config, errors, logging, task primitives, shared widgets/theme.
  * `features/<domain>/` owns feature-specific `domain/`, `application/`, `data/`, and `presentation/` layers.
  * Feature modules must not freely import each other's presentation/data layers; cross-feature coordination goes through domain/application contracts or core abstractions.
* First-phase navigation and module placeholder set:
  * `Projects`
  * `Style Lab`
  * `Plot Lab`
  * `Workflow Runs`
  * `Settings`
* `Zen Editor` is not a top-level first-phase route. It should be introduced later as a project/chapter sub-route.

## Acceptance Criteria

* [x] Git repository exists at `/Users/zhouzirui/code/AI/Persona-Flutter`.
* [x] `git status` no longer shows `Persona_副本/`, `.DS_Store`, `.ace-tool/`, old `node_modules`, or old local databases as untracked files.
* [x] Architecture plan records the selected local-backend strategy.
* [x] Architecture plan defines a concrete first scaffold scope.
* [x] Architecture plan records the selected baseline Flutter package stack.
* [x] Architecture plan records the selected directory architecture.
* [x] Architecture plan records the selected first-phase navigation/module placeholder set.
* [x] User confirms the plan before implementation scaffolding begins.

## Definition Of Done

* Requirements decisions are recorded in this PRD.
* Architecture plan is concrete enough to drive scaffold implementation.
* Git ignore policy is verified with `git check-ignore`.
* No old project copy, dependency directory, local DB, cache, or secret file is staged.

## Technical Notes

* Root product PRD: `Persona Flutter 重写 PRD.md`.
* Flutter stack research: `research/flutter-stack.md`.
* Local toolchain: Flutter 3.41.6 stable, Dart 3.11.4 stable.
* Local toolchain limitation: `flutter doctor -v` reports incomplete Xcode installation and missing CocoaPods; macOS/iOS plugin builds may require local setup before full desktop verification.
* Old reference docs: `Persona_副本/wiki/README.md`, `Persona_副本/wiki/10-architecture/10-high-level-architecture.md`, `Persona_副本/wiki/10-architecture/13-data-model.md`, `Persona_副本/wiki/20-domains/19-novel-workflow.md`.
* Old reference source boundaries:
  * `Persona_副本/api/app/db/models.py` for domain data model reference.
  * `Persona_副本/api/app/services/` for service/workflow boundaries.
  * `Persona_副本/api/app/prompts/` for production prompt templates.
  * `Persona_副本/web/components/` and `Persona_副本/web/lib/` for UI/domain interaction patterns.

## Decision: In-Process Dart Business Layer

**Context**: The product PRD said both "Dart business layer" and "local backend". These can mean either an embedded service layer inside Flutter or a separate local HTTP process bundled with the desktop app.

**Decision**: Use an in-process Dart business layer. No separate FastAPI/local HTTP server is part of the Flutter rewrite baseline.

**Consequences**:

* Simpler packaging and startup: one app process initializes SQLite and services directly.
* Lower IPC/API duplication: UI can call application services through typed Dart interfaces rather than HTTP DTOs.
* Mobile parity is easier because the same Dart service layer can move with Flutter.
* The old FastAPI service/router/repository split remains useful as conceptual reference, but should be translated into Dart application/domain/data boundaries.
* Long-running jobs need explicit in-app scheduling, persistence, cancellation, and crash recovery because there is no separate worker process.

## Decision: First Scaffold Scope

**Context**: The rewrite could start from a pure architecture skeleton or immediately include a complete Provider/Project vertical slice.

**Decision**: Start with architecture skeleton only.

**Consequences**:

* Lower first-step risk and easier review.
* The scaffold can lock package layout, service boundaries, SQLite initialization, task primitives, and navigation structure before feature behavior is added.
* Provider, Project/Chapter, Style Lab, Plot Lab, and Zen Editor remain out of scope for the first implementation pass except as named module placeholders.

## Decision: Baseline Flutter Stack

**Context**: The architecture skeleton needs durable choices for navigation, state/dependency wiring, local persistence, and generated model contracts.

**Decision**: Use the more engineering-heavy baseline: `go_router + flutter_riverpod + drift + freezed + json_serializable + build_runner`.

**Consequences**:

* Stronger long-term type safety and explicit generated contracts.
* Better fit for local-first domain models, persisted tasks, and future backup/import JSON boundaries.
* First scaffold is heavier because generated files, build commands, and annotation discipline must be configured from day one.
* The first implementation must include code generation verification, not just `flutter analyze`.
* Current implementation note: the compatible generator set is `drift 2.31.0` / `drift_dev 2.31.0` / `json_serializable 6.13.0` / `riverpod_generator 4.0.3` under Flutter 3.41.6. That combination now resolves and generates code successfully.

## Decision: Directory Architecture

**Context**: Persona has several long-lived product domains: Provider, Style Lab, Plot Lab, Project Workbench, Zen Editor, workflows/tasks, import/export, and backup/restore. A purely technical-layer layout would mix these domains over time, while a purely feature-based layout would leave too much freedom around boundaries.

**Decision**: Use mixed Clean Architecture + Feature Modules.

**Consequences**:

* App-wide infrastructure belongs in `lib/core/`.
* Domain-specific code belongs in `lib/features/<domain>/`.
* Each feature follows a consistent internal shape:
  * `domain/` for entities, value objects, repository contracts, and domain services.
  * `application/` for use cases, app services, Riverpod providers, and orchestration.
  * `data/` for Drift DAOs, DTOs, mappers, repository implementations, and local data sources.
  * `presentation/` for pages, widgets, controllers, and UI state.
* The first scaffold should create placeholders and conventions without implementing full feature behavior.

## Decision: First-Phase Navigation And Modules

**Context**: The skeleton needs enough navigation structure to represent the product, but not so many placeholder pages that the first implementation becomes noisy.

**Decision**: Use the core product entry set: `Projects`, `Style Lab`, `Plot Lab`, `Workflow Runs`, and `Settings`.

**Consequences**:

* The skeleton covers the main product domains and the cross-cutting task system.
* `Zen Editor` remains a later project/chapter child route instead of a top-level navigation item.
* Import/export and backup/restore can initially live under `Settings` or later become dedicated routes when behavior is implemented.

## Out Of Scope

* Committing the old project copy.
* Implementing the full application in this planning step.
* Adding account/login, remote backend, cloud sync, SaaS deployment, Redis, MQ, or multi-user abstractions.
