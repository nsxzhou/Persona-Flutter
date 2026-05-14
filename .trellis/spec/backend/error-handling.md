# Error Handling

> How errors are handled in this project.

---

## Overview

The current scaffold has no custom error hierarchy yet. Errors from async repositories and providers are surfaced through Riverpod `AsyncValue` and rendered in presentation widgets.

Example: `lib/src/features/workflow_runs/presentation/workflow_runs_page.dart` handles `tasks.when(error: ...)`.

---

## Error Types

No project-specific error classes exist yet. When domain errors are introduced, define them in the owning feature's `domain/` layer or in `core/` if they are cross-cutting.

---

## Error Handling Patterns

Repository methods should expose typed results through `Future<T>` or `Stream<T>`. Let provider boundaries surface asynchronous failures unless the service can add domain-specific recovery or context.

Presentation widgets must handle loading, data, and error states for async providers.

---

## API Error Responses

Not applicable: there is no HTTP API in the Flutter rewrite baseline.

---

## Common Mistakes

* Do not swallow repository exceptions silently.
* Do not render async provider data without an error branch.
* Do not introduce HTTP-style error response DTOs unless a real API boundary is added.
