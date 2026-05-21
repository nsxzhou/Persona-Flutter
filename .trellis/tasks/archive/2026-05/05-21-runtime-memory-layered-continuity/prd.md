# Runtime Memory layered continuity

## Goal

Extend Novel Workshop Runtime Memory with a layered long-form continuity model inspired by GenericAgent, while keeping Runtime Memory as the single project-level source for chapter-to-chapter continuity and preserving human-reviewed memory writes.

## Requirements

- Keep existing `RuntimeMemoryState.runtimeState`, `runtimeThreads`, and `storySummary`.
- Add `continuityIndex` as a short high-density continuity trigger index for unresolved threads, current state, and world-rule changes.
- Add `chapterArchiveMarkdown` as chapter-level continuity archive content for reviewed chapter memory history.
- Extend Drift persistence for `ProjectRuntimeMemoryRecords` with the two new text fields and migrate existing databases with empty defaults.
- Keep `ProjectRuntimeMemory` as one current row per project; do not introduce a separate memory subsystem, embedding store, vector search, or keyword retrieval.
- Extend memory sync proposals so generated chapters can propose a complete five-field Runtime Memory replacement plus the existing character/relationship YAML patch.
- Keep memory sync human-reviewed: generation creates a pending proposal; only applying the proposal writes Runtime Memory.
- Keep proposal staleness protection using the current chapter `contentHash`; editing/regenerating chapter content clears all proposed memory fields and patch YAML.
- Update writing context assembly so Runtime Memory renders five subsections: Runtime State, Runtime Threads, Story Summary, Continuity Index, and Chapter Archive.
- Chapter generation should normally inject full Runtime Memory.
- If prompt content is too large, create a temporary `Chapter Archive Digest` for the current generation prompt only, using the same provider/model and prompt tracing. Do not write the digest back to the database.
- Update Runtime Memory editing/review UI to show and edit the two new fields in the existing Runtime Memory surface.
- Do not put full character card or relationship state into `continuityIndex`; structured character/relationship tables remain the source of truth for those facts.

## Acceptance Criteria

- [x] Runtime Memory saves, reads, clears, and maps all five fields.
- [x] Drift schema version is upgraded and migration adds the two new columns.
- [x] Memory sync proposals persist all five proposed Runtime Memory fields.
- [x] Applying a valid pending memory sync proposal writes all five fields and still applies character/relationship YAML.
- [x] Editing chapter content clears proposed runtime state, threads, summary, continuity index, chapter archive, patch YAML, and resets status to idle.
- [x] Writing context output includes the five Runtime Memory subsections and omits empty subsections.
- [x] Chapter generation proposes five-field Runtime Memory and traces the proposal prompt.
- [x] Oversized chapter generation prompts use a traced temporary chapter archive digest and does not mutate stored Runtime Memory.
- [x] Novel Workshop UI exposes the two new Runtime Memory fields in edit and review surfaces.
- [x] Relevant repository, assembler, pipeline, and page/widget tests pass.

## Out of Scope

- Embedding/vector retrieval.
- Keyword retrieval or automatic historical archive search.
- Separate long-term memory database or standalone memory management panel.
- Automatic persistent compression/overwrite of Runtime Memory without human review.
- Reintroducing character status into runtime memory as a duplicate of structured character cards.

## Technical Notes

- Main domain files: `lib/src/features/novel_workshop/domain/writing_context.dart`, `lib/src/features/novel_workshop/domain/novel_workshop.dart`.
- Main persistence files: `lib/src/core/database/app_database.dart`, generated Drift code, `lib/src/features/novel_workshop/data/drift_novel_workshop_repository.dart`.
- Main generation files: `lib/src/features/novel_workshop/application/writing_context_assembler.dart`, `lib/src/features/novel_workshop/application/chapter_generation_pipeline.dart`.
- Main UI file: `lib/src/features/novel_workshop/presentation/novel_workshop_page.dart`.
- Existing design deliberately removed `charactersStatus` from Runtime Memory; preserve that boundary.
