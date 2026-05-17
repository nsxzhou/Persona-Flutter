# Workflow Prompt Trace

## Goal

Add a generic Workflow Prompt Trace capability so local long-running workflow tasks can show the actual runtime prompts sent to the configured LLM provider. The first implementation covers Style Lab and Plot Lab analysis workflows and exposes the trace from a new generic Workflow Run detail page.

## What I Already Know

- Current app is a Flutter/Dart local-first app using Drift over SQLite, Riverpod, GoRouter, and `flutter_markdown_plus`.
- Current database schema version is 6 and has `WorkflowTaskRecords`, Style Lab run tables, and Plot Lab run tables.
- Style and Plot pipelines build prompts at runtime and call `MarkdownCompletionService.completeMarkdown`, but currently persist only task logs and final artifacts.
- Persona copy implements Prompt Trace as an audit artifact that records injected LLM messages and output summaries; trace persistence failure must not mask the LLM result.
- The chosen product direction is a generic workflow-level Prompt Trace, stored as `YAML+MD`, visible from `/workflow-runs/:taskId`.

## Requirements

- Add a generic Prompt Trace persistence model for workflow tasks.
- Persist trace as one `YAML+MD` document per workflow task with YAML front matter fields:
  `format`, `version`, `workflow_task_id`, `workflow_kind`, `run_id`, `provider_id`, `model_name`, `calls`, `failed_calls`, `total_input_chars`, `updated_at`.
- Markdown body must include `# Prompt Trace`, `## Call summary`, and one section per call: `## Call N - stage / label`.
- Each call must record stage, label, model, temperature, started/completed time, duration, input/output char counts, and failure status.
- Each sent LLM message must be recorded in a fenced code block with a dynamic fence length that cannot be broken by prompt content containing backticks.
- Store full actual input messages after provider prompt composition. Store output excerpt only: short output complete, long output head/tail with omitted char marker.
- Apply basic redaction before persistence: current provider `apiKey`, common `Bearer ...`, and common `sk-...` token shapes.
- Trace must flush after every successful or failed LLM call. Trace write failure must not fail the workflow.
- Delete trace when deleting the owning Style/Plot run or profile source run.
- Add generic Workflow Run detail UI at `/workflow-runs/:taskId` with Prompt Trace, logs, task summary, raw/rendered trace controls, copy action, empty trace state, and a link to the Style/Plot business detail when available.
- Update Workflow Runs list so rows open the generic workflow detail page instead of directly opening business detail.

## Acceptance Criteria

- [ ] Style Lab successful analysis writes Prompt Trace calls for chunk analysis, merge/report/profile calls as applicable.
- [ ] Plot Lab successful analysis writes Prompt Trace calls for sketch, skeleton, report, and Story Engine calls as applicable.
- [ ] Failed LLM calls record the failed call with error summary and preserve already completed calls.
- [ ] Prompt Trace never exposes the provider API key in persisted markdown.
- [ ] Old workflow tasks without trace render a clear empty state.
- [ ] Deleting Style/Plot runs or source profiles deletes their workflow task trace.
- [ ] `/workflow-runs/:taskId` renders the trace and can navigate to the associated Style/Plot detail.
- [ ] `dart run build_runner build --delete-conflicting-outputs`, `flutter analyze`, and `flutter test` pass.

## Out of Scope

- No cloud sync, export file flow, encryption layer, or historical trace backfill.
- No strong redaction of manuscript/sample content; trace intentionally preserves prompt text for local debugging.
- No trace for provider chat-test UI unless it naturally uses the same optional LLM tracing path in a future task.

## Technical Notes

- Relevant specs:
  - `.trellis/spec/backend/database-guidelines.md`
  - `.trellis/spec/backend/quality-guidelines.md`
  - `.trellis/spec/frontend/component-guidelines.md`
  - `.trellis/spec/frontend/state-management.md`
  - `.trellis/spec/frontend/visual-design-guidelines.md`
- Relevant implementation areas:
  - `lib/src/core/database/app_database.dart`
  - `lib/src/core/tasks/**`
  - `lib/src/core/llm/application/llm_invocation_service.dart`
  - `lib/src/core/llm/application/markdown_completion_service.dart`
  - `lib/src/features/style_lab/application/style_analysis_pipeline.dart`
  - `lib/src/features/plot_lab/application/plot_analysis_pipeline.dart`
  - `lib/src/features/workflow_runs/presentation/workflow_runs_page.dart`
  - `lib/src/core/router/app_router.dart`
- Existing `yaml` dependency and YAML front matter parser patterns can be reused.
