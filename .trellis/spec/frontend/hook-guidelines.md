# Hook Guidelines

> How hooks are used in this project.

---

## Overview

This Flutter project does not use React hooks. The equivalent shared stateful logic is expressed with Riverpod providers, preferably generated via `riverpod_generator`.

---

## Custom Hook Patterns

Create providers in `application/` for feature-specific logic and in `core/<area>/application/` for shared logic.

Example:

* `lib/src/core/tasks/application/workflow_task_providers.dart`

---

## Data Fetching

Use repository contracts plus Riverpod providers. For persisted local streams, expose a `StreamProvider` generated from an `@riverpod` stream function.

Example: `recentWorkflowTasks` watches `WorkflowTaskRepository.watchRecentTasks()`.

---

## Naming Conventions

Provider functions use descriptive noun phrases:

* `appDatabase`
* `workflowTaskRepository`
* `recentWorkflowTasks`

The generated provider identifiers append `Provider`.

---

## Common Mistakes

* Do not create providers in presentation files unless they are strictly private UI state.
* Do not forget to run `dart run build_runner build` after adding or renaming `@riverpod` functions.
