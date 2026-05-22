# Retrieval-Based Chapter Generation Context

## Goal

Replace full prompt injection in ordinary chapter generation with retrieval-based context assembly. The generation pipeline should first select relevant prior chapter excerpts and relevant asset blocks, then inject only those references into the draft and continuity-audit prompts.

## Requirements

* Ordinary single-chapter generation and batch draft generation use retrieval-based context.
* Chapter enrichment remains unchanged.
* Current chapter old content is never injected when regenerating with replacement; only earlier saved chapters can be referenced.
* Do not add vector databases, embeddings, keyword retrieval tables, or a separate memory subsystem.
* Reuse existing Drift data: saved project chapters, Project Bible, Voice Profile, Story Engine, Runtime Memory, characters, and relationships.
* Always keep Output Contract, Chapter Objective Card, and Chapter Plan in the final prompt.
* Add a `WritingContextRetriever` application service that builds a retrieved context bundle.
* Local preselection always includes the nearest 1-2 previous chapters and scores older chapters by current chapter terms, character names, relationship labels, Runtime Memory clues, titles, and chapter snippets.
* Use an LLM selector before draft generation. Its input must be lightweight: all previous chapter directory entries/short summaries plus nearby and keyword candidate snippets, not full previous novel text.
* Retry selector parsing failures; if selector still fails or returns no useful selection, continue with deterministic local fallback and add a context warning.
* Final source excerpt injection follows near-long/far-short behavior: nearby chapters may contribute longer tail/key excerpts, while older selected chapters contribute short matched excerpts plus selection reason.
* Split Voice Profile, Story Engine, Project Bible, and Runtime Memory into selectable blocks; inject only selected blocks, with local fallback selecting high-signal blocks.
* Continuity audit reuses the same retrieved context used by draft generation instead of reconstructing full context.
* Memory Patch generation remains based on the generated chapter and current Runtime Memory.
* `previewGenerationContext` displays final prompt, selected chapter count, selected asset block count, selector/fallback warnings, and selection report.

## Acceptance Criteria

* [ ] Retrieval includes previous nearby chapters when present.
* [ ] Retrieval excludes the current chapter's existing content during replacement generation.
* [ ] Older chapters matching current character/plot terms can be selected without injecting full chapters.
* [ ] A valid selector response changes injected chapter excerpts and asset blocks.
* [ ] Invalid selector output is retried, then falls back without blocking generation.
* [ ] Generated draft prompt no longer contains unselected full Voice Profile, Story Engine, Project Bible, Runtime Memory, or prior chapters.
* [ ] Continuity audit prompt uses the retrieved references.
* [ ] Batch draft generation still works because it uses the ordinary generation path.
* [ ] Chapter enrichment behavior and tests remain unchanged.

## Definition of Done

* Tests added or updated for retrieval service, generation prompt behavior, fallback behavior, and regression coverage.
* `flutter test test/novel_workshop/chapter_generation_pipeline_test.dart test/novel_workshop/writing_context_assembler_test.dart` passes.
* Run broader `flutter test` if focused tests reveal cross-module risk.
* No Drift schema migration or generated database changes are introduced.

## Technical Approach

Implement the retriever in the Novel Workshop application layer. It will build deterministic candidates locally, ask the configured model to choose relevant sources and asset blocks using a strict JSON response, parse the selector response, and fall back to local selection after retry exhaustion.

The retrieved context will be represented in domain/application DTOs and rendered by `WritingContextAssembler` as a `Retrieved References` section. Existing `WritingContextSections` remains the transport object for prompt assembly, with an added retrieved references field.

## Decision (ADR-lite)

**Context**: Current generation fully appends prompt assets and Runtime Memory. The user wants retrieval-like behavior without introducing a RAG stack.

**Decision**: Use a lightweight LLM selector over local summaries/candidates, backed by deterministic local fallback, and store no retrieval index.

**Consequences**: This adds one selector LLM call per ordinary generation/preview path that needs live selector behavior. It avoids schema changes and keeps behavior explainable through selection reports, but semantic recall remains bounded by local candidate generation and the selector's short input.

## Out of Scope

* No vector database, embedding model, or persistent search index.
* No changes to chapter enrichment.
* No UI redesign beyond exposing fields already returned by context preview.
* No manual chapter selection controls.
* No schema migration.

## Technical Notes

* Existing `ProjectRuntimeMemoryRecords` spec forbids adding embedding/vector stores, keyword retrieval tables, or a separate long-term memory subsystem for this area.
* Key files:
  * `lib/src/features/novel_workshop/application/chapter_generation_pipeline.dart`
  * `lib/src/features/novel_workshop/application/writing_context_assembler.dart`
  * `lib/src/features/novel_workshop/domain/writing_context.dart`
  * `test/novel_workshop/chapter_generation_pipeline_test.dart`
  * `test/novel_workshop/writing_context_assembler_test.dart`
* Existing repository can obtain prior chapters through `watchChapters(projectId).first`, ordered by `chapterIndex`.
