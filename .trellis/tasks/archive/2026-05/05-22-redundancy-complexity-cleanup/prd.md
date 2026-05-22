# redundancy complexity cleanup

## Goal

Reduce unnecessary complexity in the Flutter/Dart codebase without changing public behavior, data contracts, provider names, repository interfaces, or database schema.

## What I already know

* The repo is a Flutter/Dart single-repo app using Riverpod, Drift, Freezed, and generated providers.
* The working tree was clean before task creation.
* `flutter analyze` passed before implementation.
* Generated files and platform scaffolding are excluded from manual redundancy cleanup.
* The safest first cleanup target is duplicated TXT/EPUB parsing logic in Plot Lab and Style Lab importers.

## Assumptions

* Preserve all exception messages, return shapes, source metadata, and title/content formatting.
* Do not merge Plot Lab and Style Lab repository interfaces because their domain fields and behaviors differ.
* Avoid UI/page decomposition in this task unless required by the import cleanup.

## Requirements

* Extract shared TXT/EPUB parsing primitives used by both `PlotSampleImporter` and `StyleSampleImporter`.
* Keep Plot Lab EPUB behavior: one combined `PlotSampleInput` containing all non-empty chapters joined as Markdown sections.
* Keep Style Lab EPUB behavior: one `StyleSampleInput` per non-empty chapter.
* Preserve public importer methods including `normalizeText` if tests or callers rely on them.
* Do not edit generated files or database schema.

## Acceptance Criteria

* [ ] `PlotSampleImporter` and `StyleSampleImporter` no longer duplicate HTML-to-text, chapter collection, filename, and normalization internals.
* [ ] Public behavior remains unchanged for TXT imports, EPUB imports, empty inputs, unsupported files, and exceptions.
* [ ] Focused tests for Plot Lab and Style Lab pass.
* [ ] `flutter analyze` passes.

## Definition of Done

* Implementation follows existing layer boundaries.
* Focused tests and analyzer pass, or any inability to run them is explicitly reported.
* No generated files are hand-edited.

## Out of Scope

* Repository interface unification.
* Database schema changes.
* Riverpod provider renames.
* Large UI decomposition.
* Broad LLM pipeline abstraction beyond this first safe duplicate removal.

## Technical Notes

* Relevant specs: backend directory structure, backend quality, backend error handling, code reuse thinking guide.
* Shared backend/application utilities belong under `lib/src/core/` when reused by multiple features.
