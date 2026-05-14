# Settings Feature

Owns local settings surfaces for Provider configuration, local data controls, import/export, and backup/restore entry points.

## Layers

* `domain/` — settings value objects, provider config contracts, and local data policies.
* `application/` — settings use cases and Riverpod providers.
* `data/` — encrypted local storage, Drift adapters, DTOs, mappers, and repositories.
* `presentation/` — settings pages, forms, dialogs, and UI state.
