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

## Scenario: Novel workshop persistence

### 1. Scope / Trigger
- Trigger: The Novel Workshop stores project-scoped long-form writing state under an existing `WritingProject`.
- This is a persistence contract because Drift schema, domain models, workflow task state, accepted chapter boundaries, and future UI/LLM pipelines all depend on the same records.

### 2. Signatures
- Drift tables:
  - `StoryBibleRecords`
  - `ChapterPlanRecords`
  - `ChapterDraftRunRecords`
  - `AcceptedChapterRecords`
  - `MemoryProjectionRecords`
- Repository contract: `NovelWorkshopRepository`
- Workflow kind: `chapterDraftWorkflowTaskKind = 'novel_chapter_draft'`

### 3. Contracts
- Do not create a separate novel-project table. Novel Workshop state belongs to `ProjectRecords` through `projectId`.
- One project has at most one `StoryBible` and one `MemoryProjection`; both are upserted by `projectId`.
- `ChapterPlanRecords` are unique by `(projectId, chapterIndex)` and are read in chapter-index order.
- `ChapterDraftRunRecords` are candidate workflow runs only. They must not be treated as official manuscript text.
- `AcceptedChapterRecords` are the official chapter boundary. One `chapterPlanId` has at most one accepted chapter; accepting again overwrites the same official row.
- Creating or updating a chapter draft run must update the matching `WorkflowTaskRecords` row in the same transaction.
- Project deletion must remove Novel Workshop child data, matching prompt traces, and matching workflow task rows in the same transaction.

### 4. Validation & Error Matrix
- Missing project -> throw before writing Novel Workshop state.
- Non-positive chapter index -> throw before writing a chapter plan.
- Duplicate `(projectId, chapterIndex)` -> let the SQLite uniqueness error surface.
- Source run does not belong to accepted chapter plan -> throw before saving the accepted chapter.
- `MemoryProjection.updatedFromChapterId` does not reference an accepted chapter in the same project -> throw before saving the projection.
- Interrupted `pending` or `running` chapter draft runs after app restart -> mark both the run and workflow task as failed.

### 5. Good/Base/Bad Cases
- Good: save chapter plans, create a draft run, write prompt trace through the workflow task, accept one revised chapter, then update projection from the accepted chapter.
- Base: manually edit Story Bible and Memory Projection Markdown without invoking an LLM.
- Bad: update memory projection from draft or revised run text before the user accepts a chapter.
- Bad: delete only the project row and leave chapter draft workflow tasks visible in Workflow Runs.

### 6. Tests Required
- Repository tests for round-tripping all five domain records.
- Repository tests for singleton Story Bible / Memory Projection upsert behavior.
- Repository tests for chapter plan ordering and uniqueness.
- Repository tests proving chapter run state and workflow task state remain synchronized.
- Repository tests proving accepted chapter overwrite semantics and project-delete cascade.
