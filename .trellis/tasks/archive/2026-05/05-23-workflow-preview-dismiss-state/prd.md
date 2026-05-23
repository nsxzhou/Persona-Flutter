# Fix workflow preview actions and dismissal

## Goal

Fix Workflow Runs preview handling so completed preview actions live in the main workflow list, already-applied outputs do not keep showing apply controls, and ignored preview actions stay dismissed across app restarts.

## Requirements

* Remove the separate completed preview inbox from `WorkflowRunsPage`.
* Render review actions inline on eligible rows in the existing recent workflow activity list.
* Keep dismissed tasks visible in the list, but hide their preview action controls.
* Persist preview dismissal on `workflow_task_records.preview_dismissed_at`.
* Asset generation rows show `应用` only when the linked asset run is `succeeded` and has a non-empty draft.
* Already applied asset runs keep their detail preview content but do not render an apply-shaped disabled button.
* Chapter enrichment rows show batch apply only when there are generated, non-empty enrichment items.
* Update frontend state-management spec to document inline preview actions and persistent dismissal.

## Acceptance Criteria

* No `完成预览` section appears on Workflow Runs.
* Multiple completed Novel Workshop tasks can show preview actions in the main task list at the same time.
* Clicking `忽略` writes persistent task state and hides only the preview actions for that row.
* Reloading from repository streams preserves `previewDismissedAt`.
* Applied asset tasks do not show `应用` in the list or a disabled `已应用` button in detail.
* Drift schema is upgraded to v23 and generated files are current.
* Focused widget and repository/migration tests pass.

## Out of Scope

* Do not delete ignored tasks, prompt traces, generated drafts, or detail pages.
* Do not change repository behavior that currently allows re-applying an already-applied asset draft programmatically.
* Do not redesign the Workflow Runs page beyond the list/action consolidation.

## Technical Notes

* Main files: `lib/src/features/workflow_runs/presentation/workflow_runs_page.dart`, `lib/src/core/tasks/**`, `lib/src/core/database/app_database.dart`.
* Tests: `test/workflow_runs_page_test.dart`, `test/prompt_trace_test.dart`, database migration coverage in existing repository tests.
* Relevant specs: `.trellis/spec/backend/database-guidelines.md`, `.trellis/spec/backend/quality-guidelines.md`, `.trellis/spec/frontend/state-management.md`, `.trellis/spec/frontend/component-guidelines.md`, `.trellis/spec/frontend/quality-guidelines.md`.
