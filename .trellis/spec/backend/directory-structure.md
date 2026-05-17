# Directory Structure

> How backend code is organized in this project.

---

## Overview

Persona Flutter does not have a separate HTTP backend. "Backend" code means the in-process Dart application/data layer that owns local persistence, repositories, long-running tasks, and service orchestration.

Backend-like infrastructure belongs under `lib/src/core/` when it is shared by multiple features. Feature-specific backend logic belongs under `lib/src/features/<feature>/application/` and `lib/src/features/<feature>/data/`.

---

## Directory Layout

```text
lib/src/
├── core/
│   ├── analysis/        # Shared local analysis utilities for Style/Plot pipelines
│   ├── database/        # AppDatabase, Drift table definitions, DB providers
│   ├── llm/             # Shared LLM ports, prompt composition, adapters
│   └── tasks/
│       ├── domain/      # Shared task entities/value objects
│       ├── application/ # Shared task repository contracts/providers
│       └── data/        # Drift repository implementations
└── features/<feature>/
    ├── domain/          # Feature entities and repository contracts
    ├── application/     # Use cases, app services, generated providers
    └── data/            # Drift DAOs, DTOs, mappers, repository implementations
```

---

## Module Organization

Keep application services independent of Flutter widgets. Presentation code calls Riverpod providers or use-case services; it must not reach directly into Drift tables.

Shared analysis utilities live in `lib/src/core/analysis/` when they are reused
by more than one analysis lab. Examples include text chunking, input signal
detection, and provider-error sanitization. Feature-specific prompt builders,
document parsers, and domain-specific classification wrappers stay in the
feature's `application/` directory.

Shared task primitives live in `lib/src/core/tasks/`, as shown by:

* `lib/src/core/tasks/domain/workflow_task.dart`
* `lib/src/core/tasks/application/workflow_task_repository.dart`
* `lib/src/core/tasks/data/drift_workflow_task_repository.dart`

Shared LLM primitives live in `lib/src/core/llm/` and must keep third-party
LLM framework types behind data adapters:

* `domain/` — Persona-owned request/message/event contracts such as `LlmClient`.
* `application/` — prompt composition and invocation orchestration.
* `data/` — concrete LangChain.dart/OpenAI-compatible adapter implementations.

---

## Naming Conventions

* Files and directories use lower snake case.
* Repository contracts end with `Repository`.
* Drift-backed repository implementations are prefixed with `Drift`, for example `DriftWorkflowTaskRepository`.
* Drift tables use descriptive plural record names, for example `WorkflowTaskRecords`.

---

## Examples

* `lib/src/core/database/app_database.dart`
* `lib/src/core/tasks/application/workflow_task_providers.dart`
* `lib/src/core/tasks/data/drift_workflow_task_repository.dart`
