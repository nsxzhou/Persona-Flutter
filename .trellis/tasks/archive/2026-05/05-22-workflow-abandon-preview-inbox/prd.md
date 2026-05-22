# Workflow abandon and preview inbox

## Goal

Add abandon support for running workflow tasks and replace competing completion popups with a workflow preview inbox that can display multiple completed task outputs at once.

## Requirements

* Running workflow tasks can be abandoned from the Workflow Runs list and detail page.
* Abandoning a task force-stops the active LLM request where possible, stops follow-up pipeline writes, marks task/run records as abandoned, and clears recoverable outputs such as drafts, generated previews, logs, and prompt trace.
* Already applied user-facing project mutations are not implicitly rolled back.
* Recent succeeded tasks with reviewable output appear in a preview inbox on the Workflow Runs page, sorted newest first.
* The preview inbox supports multiple completed tasks without stacking modal dialogs.

## Acceptance Criteria

* `WorkflowTaskStatus` includes `abandoned`, and task rows render a user-facing abandoned state.
* Novel workflow statuses include abandoned variants and map to workflow task state consistently.
* `WorkflowTaskRepository.abandonTask(taskId)` performs task-level cleanup and persistence.
* Long-running novel pipelines receive a cancellation token and stop at cancellation boundaries.
* Workflow Runs list exposes an abandon action for pending/running tasks with confirmation.
* Preview inbox shows succeeded asset generation, chapter generation, and enrichment outputs without including abandoned tasks.
* Focused tests cover cancellation, output cleanup, abandoned rendering, and multiple inbox previews.

## Technical Notes

* Shared task primitives live under `lib/src/core/tasks/`.
* Shared LLM abstractions live under `lib/src/core/llm/`; LangChain types must remain behind the data adapter.
* Novel workflow persistence is owned by `DriftNovelWorkshopRepository`.
* Workflow Runs UI is an operations console and should stay compact.
