# Workflow Runs Feature

Owns workflow-run inspection UI for long-running local tasks. Shared task primitives live under `lib/src/core/tasks/`.

## Layers

* `domain/` — feature-specific workflow run filters or views.
* `application/` — query orchestration and Riverpod providers.
* `data/` — feature-specific persistence adapters when needed.
* `presentation/` — workflow run list, detail, retry, pause, and resume UI.
