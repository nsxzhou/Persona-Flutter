# Database Guidelines

> Database patterns and conventions for this project.

---

## Overview

Persona Flutter uses Drift over SQLite for local persistence. The database is initialized in-process from Dart; there is no separate local HTTP backend.

---

## Query Patterns

Keep raw Drift access behind repositories or data sources. UI and feature presentation code should consume domain/application contracts, not table records.

---

## Migrations

Schema changes must update Drift table definitions and generated files.

Run:

```bash
dart run build_runner build
flutter analyze
flutter test
```

---

## Naming Conventions

Use descriptive table class names ending in `Records` for persisted task-like records, for example `WorkflowTaskRecords`.

---

## Common Mistakes

* Do not expose Drift row types directly to UI.
* Do not edit generated `*.g.dart` files manually.

---

## Scenario: Local database backup and restore

### 1. Scope / Trigger
- Trigger: Settings exposes full local backup/restore for the app's Drift-backed SQLite database.
- This is a cross-layer infrastructure contract because the database file path, backup service, Riverpod database provider, Settings UI, and tests must agree on replacement semantics.

### 2. Signatures
- Database file resolver: `AppDatabase.databaseFile()`.
- Database provider: `appDatabaseProvider`.
- Backup service: `LocalBackupService`.
- Backup operations:
  - `LocalBackupService.exportBytes()`
  - `LocalBackupService.writeBackup(File destination)`
  - `LocalBackupService.restoreFrom(File source)`
  - `LocalBackupService.validateRestoreSource(File source)`

### 3. Contracts
- The canonical database path is `<application support>/Persona/persona.sqlite`.
- A backup is a full plain SQLite snapshot. It includes Provider API keys and must be treated as sensitive local data.
- Export must use SQLite `VACUUM INTO` through Drift instead of directly copying the live database file.
- Restore replaces the whole local database file. It is not a merge/import operation.
- Restore must close the active Drift database before replacing the file and refresh the Riverpod database provider afterward.
- Restore must create a timestamped `pre-restore-*.sqlite` rollback copy before replacing the current database.

### 4. Validation & Error Matrix
- Missing backup file -> throw before closing/replacing the current database.
- Corrupt or non-SQLite backup -> throw before closing/replacing the current database.
- Backup `PRAGMA user_version` greater than current `schemaVersion` -> reject as a future-version backup.
- Backup `user_version` less than or equal to current `schemaVersion` -> allow restore; existing Drift migrations upgrade older backups when reopened.
- File replacement failure after rollback copy -> restore the rollback copy, then rethrow.

### 5. Good/Base/Bad Cases
- Good: export via `VACUUM INTO`, validate restore input, keep rollback copy, replace the file, then invalidate the database provider.
- Base: user exports a plain `.sqlite` file and stores it outside the app.
- Bad: hot-copy `persona.sqlite` while Drift is open and assume the file is consistent.
- Bad: restore a future-version backup and let the app fail later during startup or queries.

### 6. Tests Required
- Service test that exported backup opens as SQLite and has the current `user_version`.
- Service test that corrupt backups and future-version backups are rejected.
- Service test that restore creates a rollback copy and replaces data.
- Widget test that Settings warns about API keys, confirms restore, and disables duplicate backup/restore actions while busy.

### 7. Wrong vs Correct
#### Wrong
Copy the live database file directly from the application support directory.
#### Correct
Use `VACUUM INTO` to create a consistent snapshot, then write that snapshot to the user-selected backup path.

---

## Scenario: Provider configuration storage

### 1. Scope / Trigger
- Trigger: Provider management now persists OpenAI-compatible connection settings, including API Key, in SQLite.
- This is a cross-layer persistence contract change and requires explicit storage, migration, and masking rules.

### 2. Signatures
- Drift table: `ProviderConfigRecords`
- Repository contract: `ProviderConfigRepository`
- Persistence fields:
  - `id: Text`
  - `name: Text`
  - `baseUrl: Text`
  - `apiKey: Text`
  - `defaultModel: Text`
  - `isEnabled: Bool`
  - `testStatus: Text`
  - `lastTestedAt: DateTime?`
  - `lastTestMessage: Text?`
  - `createdAt: DateTime`
  - `updatedAt: DateTime`

### 3. Contracts
- API Key is stored in SQLite and is treated as sensitive data.
- UI must not display the full API Key after save.
- Provider test state is persisted as a string enum name.
- On save, `testStatus` resets to `untested` and last test metadata clears.

### 4. Validation & Error Matrix
- Missing name/baseUrl/apiKey/defaultModel -> validation error before write.
- Invalid URL -> validation error before write.
- Failed connectivity test -> persist `failed` with sanitized message; do not delete the Provider.
- HTTP non-2xx -> record a readable failure message without the raw secret.

### 5. Good/Base/Bad Cases
- Good: save Provider metadata and API Key to SQLite, then run a real `GET /models` probe.
- Base: save Provider first, test later.
- Bad: log or render the full API Key in UI or diagnostics.

### 6. Tests Required
- Widget test for the Settings surface rendering the Provider area.
- Repository test for round-tripping `ProviderConfigRecords`.
- Connectivity test unit coverage for success, non-2xx, timeout, and invalid JSON.

### 7. Wrong vs Correct
#### Wrong
Store Provider metadata in SQLite but keep API Key in logs, snackbars, or plain text UI.
#### Correct
Store API Key only in SQLite, mask it in UI, and sanitize any test failure message.

## Scenario: Project CRUD storage

### 1. Scope / Trigger
- Trigger: The Projects feature persists local writing project records and exposes them through repository and Riverpod contracts.
- This is a cross-layer persistence contract because database schema, domain model, list filtering, route detail pages, and widget tests all depend on the same fields.

### 2. Signatures
- Drift table: `ProjectRecords`
- Domain model: `WritingProject`
- Repository contract: `ProjectRepository`
- Persistence fields:
  - `id: Text`
  - `title: Text`
  - `description: Text`
  - `status: Text`
  - `createdAt: DateTime`
  - `updatedAt: DateTime`

### 3. Contracts
- `status` is stored as the enum name of `ProjectStatus`.
- Valid status values are `active` and `archived`.
- The default Projects list reads only `active` projects.
- The archived Projects view reads only `archived` projects.
- Delete is a hard delete of the project record.
- `updatedAt` should advance on edits even when a test or fast local write happens within the same wall-clock tick. For SQLite-backed project records, use at least a one-second minimum increment over the existing stored value when the current wall clock has not passed that threshold.

### 4. Validation & Error Matrix
- Empty title -> validation error before write.
- Empty description -> allowed and rendered as an explicit empty-description state.
- Unknown status string in SQLite -> mapping fails at repository boundary; do not silently coerce.
- Missing project detail record -> render a friendly missing-project state.

### 5. Good/Base/Bad Cases
- Good: create a project, edit it, archive it out of the active list, restore it, then hard delete it.
- Base: create an active project with a title and optional description.
- Bad: let presentation widgets import Drift records or query `ProjectRecords` directly.

### 6. Tests Required
- Repository test for create/read/update/filter/delete.
- Widget test for empty Projects state.
- Widget test for active-vs-archived list switching.
- Widget test for project detail found and missing states.

### 7. Wrong vs Correct
#### Wrong
Render all projects in one list and let the UI infer hidden/archived behavior ad hoc.
#### Correct
Expose status-filtered streams through `ProjectRepository.watchProjects(ProjectStatus status)` and bind the Projects view to the selected status.

## Scenario: Lab profile deletion cascade

### 1. Scope / Trigger
- Trigger: Plot Lab or Style Lab deletes a saved Profile that was created from an analysis run.
- This is a persistence contract because the Profile list combines profile rows and draft-like run rows.

### 2. Signatures
- `PlotLabRepository.deleteProfile(String id)`
- `StyleLabRepository.deleteProfile(String id)`
- Affected records:
  - Profile row: `plotProfileRecords` / `styleProfileRecords`
  - Source run row: `plotAnalysisRunRecords` / `styleAnalysisRunRecords`
  - Source workflow task row: `workflowTaskRecords`

### 3. Contracts
- Deleting a saved Profile is a hard delete of the Profile and its source analysis run.
- The source run's workflow task must also be deleted in the same transaction.
- Do not clear `run.profileId` to restore the source run as a draft. The library builders treat succeeded runs with `profileId == null` and generated markdown as draft assets, so clearing the field makes a deleted Profile reappear as a draft.
- Deleting an unknown Profile id is a no-op.

### 4. Validation & Error Matrix
- Missing Profile row -> return without error.
- Missing source run row -> delete the Profile row and skip workflow task deletion.
- Transaction failure -> let the repository exception propagate through the Riverpod command provider.

### 5. Good/Base/Bad Cases
- Good: delete saved Profile, source run, and workflow task together so the asset disappears from library streams after one action.
- Base: deleting a standalone draft or task still uses `deleteRun(id)`.
- Bad: delete Profile and update the source run to `profileId = null`, because that resurrects the source run as a draft.

### 6. Tests Required
- Repository tests for Plot Lab and Style Lab must assert `findProfile(id) == null`, `findRun(sourceRunId) == null`, and workflow task count decreases.
- Widget tests may cover the list disappearance when deletion UI behavior changes.

### 7. Wrong vs Correct
#### Wrong
Clear `profileId` on the source run during Profile deletion.
#### Correct
Delete the Profile row, source run row, and source workflow task row in one transaction.

## Scenario: Analysis run and workflow task synchronization

### 1. Scope / Trigger
- Trigger: Style Lab, Plot Lab, or a future editor background job creates or updates a long-running analysis/task record.
- This is a cross-layer persistence contract because `workflowTaskRecords` drives the Workflow Runs overview while feature run tables drive detail pages.

### 2. Signatures
- Read repository: `WorkflowTaskRepository.watchRecentTasks()`
- Style run writer: `StyleLabRepository.createRun(...)` and `StyleLabRepository.updateRunState(...)`
- Plot run writer: `PlotLabRepository.createRun(...)` and `PlotLabRepository.updateRunState(...)`
- Drift table: `WorkflowTaskRecords`
- Feature task mapping fields:
  - Style: `styleAnalysisRunRecords.workflowTaskId`
  - Plot: `plotAnalysisRunRecords.workflowTaskId`

### 3. Contracts
- `WorkflowTaskRepository` is read-only for task overview screens.
- Feature repositories own creation and state updates for their run row and matching workflow task row.
- Run state and workflow task state must be updated in the same Drift transaction.
- `workflowTaskRecords` is a long-term overview table, not migration residue; do not remove it while Workflow Runs depends on it.
- Do not add generic `upsertTask` or `updateTask` methods without a concrete writer use case that preserves the feature run mapping.

### 4. Validation & Error Matrix
- Missing feature run on update -> throw at the feature repository boundary.
- Interrupted pending/running run after app restart -> mark both the feature run and workflow task as failed in the same transaction.
- Missing workflow task id for a feature run -> treat as persistence corruption; do not silently create an unlinked replacement task.

### 5. Good/Base/Bad Cases
- Good: `DriftStyleLabRepository.updateRunState` updates `styleAnalysisRunRecords` and its `workflowTaskRecords` row inside one transaction.
- Base: Workflow Runs reads `WorkflowTaskRepository.watchRecentTasks()` and opens a feature detail by `workflowTaskId`.
- Bad: Update only the feature run row and leave Workflow Runs showing stale status.

### 6. Tests Required
- Repository tests must assert workflow task status follows run status changes.
- Restart/interruption tests must assert both the run row and task row become failed.
- Workflow Runs widget tests must confirm Style/Plot task detail navigation still works by `workflowTaskId`.

### 7. Wrong vs Correct
#### Wrong
Expose a generic task writer and let UI or feature services update workflow tasks separately from analysis runs.
#### Correct
Keep `WorkflowTaskRepository` read-only and update run/task records together inside the owning feature repository.

## Scenario: Novel Workshop layered Runtime Memory

### 1. Scope / Trigger
- Trigger: Novel Workshop chapter generation persists and reuses project-level Runtime Memory for long-form continuity.
- This is a database schema and cross-layer contract because Drift tables, domain models, prompt assembly, LLM proposal parsing, review UI, and repository writes all depend on the same five Runtime Memory fields.

### 2. Signatures
- Drift schema version: `20`.
- Domain state: `RuntimeMemoryState`.
- Current memory table: `ProjectRuntimeMemoryRecords`, one row per `projectId`.
- Chapter proposal table: `ProjectChapterRecords`, one pending proposal per chapter row.
- Repository reads/writes:
  - `NovelWorkshopRepository.findRuntimeMemory(String projectId)`
  - `NovelWorkshopRepository.saveRuntimeMemory({required String projectId, required RuntimeMemoryState state})`
  - `NovelWorkshopRepository.saveMemorySyncProposal(MemorySyncProposalInput input)`
  - `NovelWorkshopRepository.applyMemorySyncPatch(String chapterId)`
  - `NovelWorkshopRepository.discardMemorySyncPatch(String chapterId)`
- Runtime Memory fields:
  - `runtimeState: Text`
  - `runtimeThreads: Text`
  - `storySummary: Text`
  - `continuityIndex: Text`
  - `chapterArchiveMarkdown: Text`
- Proposal fields on `ProjectChapterRecords`:
  - `memorySyncProposedRuntimeState: Text`
  - `memorySyncProposedRuntimeThreads: Text`
  - `memorySyncProposedStorySummary: Text`
  - `memorySyncProposedContinuityIndex: Text`
  - `memorySyncProposedChapterArchiveMarkdown: Text`
  - `memorySyncPatchYaml: Text`
  - `memorySyncContentHash: Text`
  - `memorySyncStatus: Text`

### 3. Contracts
- `ProjectRuntimeMemoryRecords` remains the single current project-level Runtime Memory source; do not add embedding/vector stores, keyword retrieval tables, or a separate long-term memory subsystem for this feature.
- Existing databases migrating to schema version 20 must add `continuity_index`, `chapter_archive_markdown`, `memory_sync_proposed_continuity_index`, and `memory_sync_proposed_chapter_archive_markdown` with empty-string defaults.
- `saveRuntimeMemory` trims and stores all five fields.
- `saveMemorySyncProposal` stores the model's Runtime Memory patch preview fields in `ProjectChapterRecords`, normalizes an optional whole-document `markdown`/`md`/`yaml`/`yml` code fence around `memorySyncPatchYaml`, and sets `memorySyncStatus` to `pendingReview`.
- `applyMemorySyncPatch` must require `memorySyncStatus == pendingReview` and `memorySyncContentHash == contentHash`, normalize the same optional whole-document code fence for existing proposals, then merge `memorySyncPatchYaml.runtimeMemory` into the current project Runtime Memory. Missing fields mean "preserve existing value"; explicit empty strings mean "clear this field". `chapterArchiveMarkdown` is appended to the existing archive unless explicitly empty.
- `discardMemorySyncPatch` must require `memorySyncStatus == pendingReview`, then set `memorySyncStatus` to `discarded` without mutating chapter prose, current Runtime Memory, characters, relationships, or the stored patch/proposed fields. `discarded` means "the model produced a proposal and the user rejected it"; do not reuse `noChange`, which means "the model produced no meaningful state change".
- Character and relationship updates remain in structured character/relationship tables through `memorySyncPatchYaml`. `continuityIndex` must not duplicate full character-card or relationship state.
- Editing or regenerating chapter content changes `contentHash` and must clear all pending proposed memory fields plus `memorySyncPatchYaml`, then reset `memorySyncStatus` to `idle`.
- `WritingContextAssembler` renders non-empty Runtime Memory fields as subsections named `Runtime State`, `Runtime Threads`, `Story Summary`, `Continuity Index`, and `Chapter Archive`.
- Chapter generation normally injects full Runtime Memory. If the assembled prompt exceeds the internal archive digest threshold, only the prompt-local `chapterArchiveMarkdown` value may be replaced with a `Chapter Archive Digest`; the database value must not change.
- Temporary archive digest calls must use the same provider/model for the generation run and write a prompt trace with label `digest_chapter_archive`.

### 4. Validation & Error Matrix
- Missing project on `saveRuntimeMemory` -> repository error before writing.
- `saveMemorySyncProposal` for missing chapter -> repository error.
- Proposal `contentHash` differs from the current chapter `contentHash` -> reject the proposal as stale.
- `applyMemorySyncPatch` when status is not `pendingReview` -> reject with "no pending review" behavior.
- `applyMemorySyncPatch` when proposal hash differs from chapter hash -> reject as stale and do not write Runtime Memory.
- `discardMemorySyncPatch` when status is not `pendingReview` -> reject with "no pending review" behavior.
- Applying a `discarded` proposal -> reject with "no pending review" behavior and do not write Runtime Memory or character/relationship rows.
- `memorySyncPatchYaml` with no non-empty `characters` or `relationships` patch -> skip character graph parsing; still apply the Runtime Memory field merge when `runtimeMemory` is present.
- Existing `memorySyncPatchYaml` wrapped in one complete Markdown/YAML code fence -> strip the wrapper before preview/apply parsing; do not require a data migration.
- Oversized prompt with empty `chapterArchiveMarkdown` -> skip temporary digest.
- Temporary digest failure -> generation run should fail through the normal LLM error path; do not persist partial digest content.

### 5. Good/Base/Bad Cases
- Good: generated chapter creates a pending proposal containing character/relationship YAML plus Runtime Memory patch fields; user review applies the proposal; the next chapter prompt includes the updated five subsections.
- Base: user manually edits Runtime Memory in the existing Runtime Memory surface and saves all five fields to the single project memory row.
- Bad: persist a generated `Chapter Archive Digest` back into `ProjectRuntimeMemoryRecords.chapter_archive_markdown`.
- Bad: add `charactersStatus` or full character-card facts back into Runtime Memory instead of using `NovelCharacterRecords` and `NovelRelationshipRecords`.
- Bad: treat omitted Runtime Memory fields as empty strings and clear old memory by accident.

### 6. Tests Required
- Repository test for saving, reading, clearing, and mapping all five `RuntimeMemoryState` fields.
- Migration test or schema smoke coverage that new Runtime Memory/proposal columns default to empty strings.
- Repository test for `saveMemorySyncProposal` persisting the patch preview fields.
- Repository test for `applyMemorySyncPatch` merging only present fields when `contentHash` matches.
- Repository and pipeline tests for fenced YAML proposal normalization, including an existing persisted fenced proposal.
- Repository test for `discardMemorySyncPatch` preserving Runtime Memory and character/relationship rows while moving the chapter proposal to `discarded`.
- Repository test that `discarded` proposals cannot be applied later.
- Repository test for applying an empty proposal preserving existing Runtime Memory.
- Repository test that chapter content edits clear proposed Runtime Memory fields, patch YAML, content hash binding, and status.
- Context assembler test that all five subsections render and empty fields are omitted.
- Pipeline test that proposal prompt requests patch-style `runtimeMemory` and parsed proposals are saved.
- Pipeline test that oversized prompts use traced temporary archive digest and leave stored `chapterArchiveMarkdown` unchanged.
- Widget tests for Runtime Memory editing and pending proposal review surfaces showing `continuityIndex` and `chapterArchiveMarkdown`.

### 7. Wrong vs Correct
#### Wrong
Parse missing `runtimeMemory` fields as empty strings and overwrite stored memory during patch application.
#### Correct
Merge only fields explicitly present in `memorySyncPatchYaml.runtimeMemory`; preserve omitted fields and use explicit empty strings for intentional clears.

#### Wrong
Use `continuityIndex` as another character sheet that repeats goals, injuries, alliances, and relationship strength from structured records.
#### Correct
Use `continuityIndex` only for compact continuity triggers such as unresolved promises, state/rule changes, active threats, and follow-up cues; keep character and relationship facts in structured tables.

## Scenario: Workflow Prompt Trace storage

### 1. Scope / Trigger
- Trigger: Style Lab, Plot Lab, or a future long-running workflow calls an LLM and needs user-visible prompt diagnostics.
- This is a cross-layer persistence contract because LLM invocation, workflow task records, feature run records, Drift storage, and Workflow Runs UI all depend on the same trace shape.

### 2. Signatures
- Drift table: `WorkflowPromptTraceRecords`
- Domain model: `WorkflowPromptTrace`
- Repository reads/writes:
  - `WorkflowTaskRepository.watchPromptTrace(String workflowTaskId)`
  - `WorkflowTaskRepository.upsertPromptTrace({required String workflowTaskId, required String traceMarkdown})`
- LLM trace hook:
  - `LlmInvocationService.streamChat(..., LlmPromptTraceConfig? promptTrace)`
  - `MarkdownCompletionService.completeMarkdown(..., LlmPromptTraceConfig? promptTrace)`
- Recorder: `PromptTraceRecorder.config(label: ...)`

### 3. Contracts
- One workflow task has at most one prompt trace row, keyed by `workflowTaskId`.
- Trace content is persisted as a `YAML front matter + Markdown body` document, not JSON-only.
- YAML front matter must include `format`, `version`, `workflow_task_id`, `workflow_kind`, `run_id`, `provider_id`, `model_name`, `calls`, `failed_calls`, `total_input_chars`, and `updated_at`.
- The Markdown body must include `# Prompt Trace`, a call summary table, and one section per LLM call.
- The LLM boundary records the actual messages after provider prompt composition.
- The recorder stores full input messages, output excerpts only, and basic redaction for provider API keys plus common bearer / `sk-*` token shapes.
- Prompt trace persistence is best-effort diagnostics. A trace write failure must not fail the LLM call or workflow.
- Deleting a feature run or source profile must delete the matching prompt trace before deleting the workflow task row.

### 4. Validation & Error Matrix
- Missing prompt trace row -> Workflow Runs detail renders an empty trace state, not an error.
- Trace write failure -> swallow at the trace boundary and preserve the main workflow result.
- LLM call failure -> record a failed trace call with the sent messages and sanitized error summary, then rethrow the original call failure to the pipeline.
- Provider API key in prompt/error/output -> replace before persistence.
- Prompt content contains Markdown fences -> render fenced code blocks with a dynamically longer fence.

### 5. Good/Base/Bad Cases
- Good: a Plot Lab run records sketch, skeleton, report, and Story Engine calls as one upserted workflow trace document.
- Base: a Style Lab run with one chunk records chunk analysis, report, and Voice Profile calls.
- Bad: store prompt trace inside each feature run table, because future workflow kinds would need duplicate columns and UI wiring.
- Bad: log prompt payloads with `print`/`debugPrint`; prompt trace belongs in the explicit local trace table only.

### 6. Tests Required
- Renderer tests for YAML front matter, dynamic fences, empty/failure calls, and long output excerpts.
- LLM invocation tests proving traces capture composed messages and redact provider API keys.
- Pipeline tests proving Style/Plot successful and failed runs write prompt trace rows.
- Repository/delete tests proving trace rows are removed with deleted runs or source profiles.
- Widget tests proving `/workflow-runs/:taskId` renders trace content, empty trace state, logs, and business detail navigation.

### 7. Wrong vs Correct
#### Wrong
Append full prompts to task logs or feature run `logs`, where they can mix with lifecycle messages and bypass redaction.
#### Correct
Use `PromptTraceRecorder` and `WorkflowTaskRepository.upsertPromptTrace` so prompt diagnostics are explicit, redacted, and queryable by workflow task id.

## Scenario: Novel chapter generation workflow persistence

### 1. Scope / Trigger
- Trigger: Novel Workshop creates an LLM-backed chapter generation workflow.
- This is a cross-layer persistence contract because `ChapterGenerationPipeline`, `ChapterGenerationRunRecords`, `ProjectChapterRecords`, `WorkflowTaskRecords`, and `WorkflowPromptTraceRecords` must stay synchronized.

### 2. Signatures
- Workflow kind: `novel_chapter_generation`.
- Drift table: `ChapterGenerationRunRecords`.
- Domain API: `NovelWorkshopRepository.createChapterGenerationRun(...)`, `updateChapterGenerationRunState(...)`, `hasRunningChapterGeneration(...)`, `findChapterByPlan(...)`.
- Application API: `ChapterGenerationPipeline.generateChapter({required projectId, required chapterPlanId, bool replaceExisting = false})`.

### 3. Contracts
- A generation run owns one `workflowTaskId`; run state and workflow task state are updated in the same Drift transaction.
- `ChapterGenerationRunRecords` is diagnostic as well as relational: `projectId`, `chapterPlanId`, `providerId`, and `modelName` preserve requested values so invalid input can still produce a failed run/task.
- `ProjectChapterRecords` remains the single current chapter body table; regeneration may overwrite the existing row only when `replaceExisting` is true.
- Prompt diagnostics must go through `PromptTraceRecorder`; do not store full prompts in run logs.
- Same `chapterPlanId` cannot have another pending/running generation run; different chapters may run independently.

### 4. Validation & Error Matrix
- Missing project -> create run/task when project id is non-empty, mark failed, and do not call the LLM.
- Missing chapter plan -> create run/task, mark failed, and do not call the LLM.
- Missing/default-invalid Provider or model -> mark failed before LLM invocation.
- Existing chapter content with `replaceExisting == false` -> mark failed and preserve the existing chapter.
- LLM returns empty content -> mark failed and do not save/overwrite chapter content.
- New content saved over an existing chapter -> clear stale memory-sync proposal through `saveChapter`.

### 5. Good/Base/Bad Cases
- Good: `ChapterGenerationPipeline` creates a run/task first, validates context, calls LLM with prompt trace, saves the chapter, and marks both run and task succeeded.
- Base: missing Voice Profile, Story Engine, or runtime memory records warnings but still generates when project, Provider/model, and Chapter Plan are valid.
- Bad: update only the run row and leave Workflow Runs showing stale task status.
- Bad: silently overwrite existing chapter content without explicit replacement.

### 6. Tests Required
- Repository tests must assert run/task state synchronization and `hasRunningChapterGeneration`.
- Migration tests must assert `chapter_generation_run_records` is created with schema upgrades.
- Pipeline tests must assert success path saves chapter content and prompt trace.
- Pipeline tests must assert validation failures create failed run/task without LLM calls.
- Pipeline tests must assert replacement clears stale memory-sync proposal.
- Prompt trace tests must assert provider API keys are redacted.

### 7. Wrong vs Correct
#### Wrong
Let UI create a workflow task and call `saveChapter` directly after an LLM response.
#### Correct
Route chapter generation through `ChapterGenerationPipeline`, and let `DriftNovelWorkshopRepository` own run/task creation and state synchronization.

## Scenario: Imported novel enrichment project persistence

### 1. Scope / Trigger
- Trigger: Projects can be created from imported TXT/EPUB manuscripts and then processed through whole-chapter enrichment batches.
- This is a cross-layer persistence contract because `ProjectRecords.origin`, imported `ChapterVolume` / `ChapterPlan` / `ProjectChapter` rows, enrichment batch/item records, workflow tasks, and prompt traces must stay synchronized.

### 2. Signatures
- Project origin enum: `ProjectOrigin.standard`, `ProjectOrigin.importedEnrichment`.
- Drift table/column: `ProjectRecords.origin`, default `standard`.
- Import API: `NovelImportParser.importFile(...)`, `NovelImportService.createImportedProject(...)`.
- Enrichment tables: `ChapterEnrichmentBatchRecords`, `ChapterEnrichmentItemRecords`.
- Repository APIs: `createChapterEnrichmentBatch`, `updateChapterEnrichmentBatchState`, `updateChapterEnrichmentItemState`, `applyChapterEnrichmentItem`, `deleteChapterEnrichmentItem`, `watchChapterEnrichmentBatches`, `watchChapterEnrichmentItems`.
- Application API: `ChapterEnrichmentPipeline.enrichChapters({projectId, chapterIds, instruction, expansionRatioPercent = 20})`.
- Workflow kind: `novel_chapter_enrichment`.

### 3. Contracts
- Legacy projects must read as `ProjectOrigin.standard` after migration.
- Imported projects store their manuscript in the existing chapter tree: one volume titled `导入正文`, one `ChapterPlan` per imported chapter, and one `ProjectChapter` containing the imported body.
- Enrichment is only valid for `ProjectOrigin.importedEnrichment` projects.
- Enrichment batch/item rows store preview output; generated text must not overwrite `ProjectChapterRecords` until `applyChapterEnrichmentItem` is called.
- `deleteChapterEnrichmentItem` hard-deletes only the preview item, never the chapter body or parent batch. Batch `totalCount` remains the original attempted item count; generated/failed/applied counts must refresh from remaining items.
- Each enrichment batch owns one workflow task. Batch state and workflow task state are updated together by the owning repository.
- Each enrichment item stores the original chapter snapshot and generated preview text for diff/preview surfaces.
- The enrichment prompt may use Voice Profile only. It must not inject Plot Profile, Story Engine, or Runtime Memory.

### 4. Validation & Error Matrix
- Unsupported import extension -> `NovelImportException`.
- Empty TXT/EPUB content -> `NovelImportException`.
- Imported draft with no non-empty chapters -> `StateError` in `NovelImportService`.
- Enrichment on a standard project -> `StateError` before LLM invocation.
- Empty chapter selection -> repository validation error.
- Expansion ratio outside `1..100` -> repository validation error.
- Empty instruction -> repository validation error.
- One item LLM failure -> mark that item failed and continue remaining items; final batch becomes `partialFailed` when at least one item succeeds.
- Applying a non-generated item or empty generated content -> repository validation error.
- Deleting a missing enrichment item id -> repository validation error.

### 5. Good/Base/Bad Cases
- Good: import TXT, preview/edit chapters, create imported project, run enrichment for selected chapters, preview generated items, then apply selected generated items or delete unwanted preview items.
- Base: imported project without Voice Profile can still run enrichment; prompt instructs the model to preserve original style.
- Bad: create separate manuscript storage tables for imported text when `ChapterVolume` / `ChapterPlan` / `ProjectChapter` already model the chapter tree.
- Bad: auto-overwrite chapter content immediately after LLM output.
- Bad: treat deleted preview items as applied/failed or decrement the batch `totalCount`.

### 6. Tests Required
- Parser tests for TXT heading split, no-heading fallback, and empty file rejection.
- Project repository tests for `origin` round-trip and legacy migration default.
- Repository tests for enrichment batch/item creation, counts, workflow task state sync, apply behavior, and preview deletion count refresh.
- Pipeline tests for success, standard-project rejection, prompt scope, and per-item failure continuation.
- Widget tests should use fakes and must not make live LLM calls.

### 7. Wrong vs Correct
#### Wrong
Run enrichment through the normal chapter generation pipeline and let it inject Project Bible, Story Engine, and Runtime Memory.
#### Correct
Use `ChapterEnrichmentPipeline`, which reads the selected imported chapter body, applies the user instruction and Voice Profile only, then stores a generated preview item until the user applies it.

## Scenario: Novel Workshop Project Bible and outline persistence

### 1. Scope / Trigger
- Trigger: Novel Workshop stores long-form fiction context as project bible fields plus volume-scoped chapter outline nodes.
- This is a cross-layer persistence contract because Drift schema, repository APIs, prompt assembly, and Workshop UI all depend on the same fields.

### 2. Signatures
- Drift tables: `ProjectBibleRecords`, `ChapterVolumeRecords`, `ChapterPlanRecords`.
- Domain models: `ProjectBible`, `ChapterVolume`, `ChapterPlan`.
- Repository APIs: `watchProjectBible`, `ensureProjectBible`, `saveProjectBible`, `watchChapterVolumes`, `saveChapterVolume`, `saveOutlineDetailYaml`, `saveChapterPlan`.
- Parser: `OutlineDetailParser.parse(String yamlText)` returns `OutlineDetailDocument`.

### 3. Contracts
- `ProjectBibleRecords.projectId` is the primary key and is created for existing projects during schema migration.
- `WritingProject.description` migrates into `ProjectBible.descriptionMarkdown`; future Workshop context reads the bible field, not the project list description.
- `ChapterPlan` must belong to a `ChapterVolume` through `volumeId`; new chapter plans cannot be saved without a valid volume.
- `outlineDetailYaml` is YAML-only. Saving it parses and projects records into `ChapterVolumeRecords` and `ChapterPlanRecords`.
- `plotSkeletonMarkdown` from Plot Lab is only reference input for creating outline detail; it is not a first-class Workshop tab.
- Existing chapter bodies and generation runs keep their `chapterPlanId` association during migration.

### 4. Validation & Error Matrix
- Missing project -> repository throws `StateError`.
- Missing volume on `saveChapterPlan` -> repository throws `章节计划需要有效分卷。`.
- Empty/invalid outline YAML -> `OutlineDetailValidationException`.
- Missing `volumes`, volume `index/title`, or chapter `index/title` -> explicit parser error with the failing path.
- Existing schema without Project tables during legacy cleanup migration -> skip bible backfill instead of querying absent tables.

### 5. Good/Base/Bad Cases
- Good: save a valid outline YAML with one volume and chapters, then assert volume and chapter plan projections are available from repository streams.
- Base: manually create a `ChapterVolume`, then create a `ChapterPlan` under it.
- Bad: store a free-text chapter list in UI and infer chapters at generation time.
- Bad: create a chapter plan with an empty `volumeId`.

### 6. Tests Required
- Repository tests for `ensureProjectBible`, `saveOutlineDetailYaml`, volume projection, and chapter plan projection.
- Parser tests for valid outline YAML and required-field failures.
- Migration tests for legacy default volume creation and guarded old-schema cleanup.
- Pipeline tests proving prompts include Project Bible, outline node fields, prompt assets, and Runtime Memory.

### 7. Wrong vs Correct
#### Wrong
Render or parse `plotSkeletonMarkdown` as the Workshop source of truth for chapters.
#### Correct
Keep `plotSkeletonMarkdown` as reference material only, and persist editable structure in `ProjectBible.outlineDetailYaml` plus projected `ChapterVolume` / `ChapterPlan` records.
