# Logging Guidelines

> How logging is done in this project.

---

## Overview

No logging package has been introduced in the scaffold. Prefer structured, explicit logging only when a feature needs diagnosability for long-running local tasks or provider calls.

Until a logging library is selected, avoid ad-hoc `print`/`debugPrint` in committed code.

---

## Log Levels

When logging is introduced:

* `debug`: local development details that are not needed by users.
* `info`: lifecycle events for user-visible long-running tasks.
* `warning`: recoverable failures, retries, or degraded local state.
* `error`: failed operations requiring user-visible feedback or repair.

---

## Structured Logging

Task logs should include task id, task kind, stage, and timestamp. Avoid free-form logs that cannot be tied back to a persisted task record.

---

## What to Log

Log long-running workflow lifecycle events when implemented:

* task queued,
* task started,
* stage changed,
* task paused/resumed,
* task failed/succeeded.

---

## What NOT to Log

Never log API keys, full provider credentials, manuscript content, imported source text, or prompt payloads by default.

---

## Scenario: Provider connectivity and credential handling

### 1. Scope / Trigger
- Trigger: The Provider settings slice persists API Keys in SQLite and performs real network connectivity tests.
- This increases the risk of leaking secrets through logs or diagnostics.

### 2. Validation & Error Matrix
- Test failure -> surface sanitized error text only.
- Unexpected exception -> truncate or sanitize the message before showing it to users.
- API Key present -> never emit it in logs, even in debug builds.

### 3. Good/Base/Bad Cases
- Good: log the Provider id, test status, and timestamp only.
- Base: log a short sanitized error reason when a probe fails.
- Bad: print the request headers, model list payload, or API Key value.

### 4. Wrong vs Correct
#### Wrong
`debugPrint('Provider test failed: $apiKey')`
#### Correct
Log only the Provider id and a sanitized failure reason, never the secret itself.

## Scenario: Workflow task detail logs

### 1. Scope / Trigger
- Trigger: A workflow task kind writes user-visible lifecycle logs into a feature-specific run table and the generic Workflow Runs page must display those logs.

### 2. Signatures
- Repository contract: `watch<Run>ByWorkflowTask(String workflowTaskId) -> Stream<Run?>`.
- Riverpod bridge: `<run>ByWorkflowTaskProvider(workflowTaskId)` wraps the repository stream.
- UI selector: Workflow Runs maps `WorkflowTask.kind` to the matching run provider and reads `run.logs`.
- Batch chapter generation: `watchChapterGenerationBatchByWorkflowTask(String workflowTaskId)` plus `chapterGenerationBatchItemsProvider(batchId)` exposes batch-level and per-chapter logs.

### 3. Contracts
- Workflow task records hold generic status, stage, title, and failure summary.
- Feature run records own detailed task logs.
- Presentation widgets must consume logs through repository and Riverpod contracts, not Drift tables.
- New task kinds that appear in Workflow Runs need an explicit log mapping, even when they do not have a business-detail route.
- `novel_chapter_generation_batch` details combine `ChapterGenerationBatch.logs` with ordered `ChapterGenerationBatchItem.logs`, attempt counters, and item error summaries so Patch retry failures remain diagnosable.

### 4. Validation & Error Matrix
- Missing run for task id -> render empty log text, not a repository error.
- Unknown task kind -> render empty log text.
- Provider stream error -> render the existing task-log error branch.

### 5. Good/Base/Bad Cases
- Good: `novel_asset_generation` resolves `AssetGenerationRun` by `workflowTaskId` and displays `AssetGenerationRun.logs`.
- Good: `novel_chapter_generation_batch` resolves its batch by `workflowTaskId` and renders the failed item's Memory Patch review error below batch lifecycle logs.
- Base: style and plot analysis keep their existing run-log mappings.
- Bad: Writing logs during pipeline execution but returning `AsyncValue.data('')` for that task kind in Workflow Runs.

### 6. Tests Required
- Widget test for every newly mapped task kind that opens `/workflow-runs/:taskId`, switches to `任务日志`, and asserts persisted log text is visible.
- Repository/provider tests or fakes must implement any new `watch<Run>ByWorkflowTask` or batch equivalent contract.

### 7. Wrong vs Correct
#### Wrong
```dart
_ => const AsyncValue.data('')
```

#### Correct
```dart
assetGenerationWorkflowTaskKind => assetRun.whenData(
  (run) => run?.logs ?? '',
)
```
