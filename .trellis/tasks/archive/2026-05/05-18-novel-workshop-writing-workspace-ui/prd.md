# Novel Workshop Writing Workspace UI

## Goal

Add the first usable Novel Workshop workspace UI for active writing projects. The workspace must let a user open a project from the Projects page, create/edit manual chapter plans, edit Markdown chapter body content, trigger the existing chapter generation pipeline, and inspect generation diagnostics without duplicating the full Workflow Runs prompt trace screen.

## Requirements

- Add a project-scoped route at `/projects/:projectId/workshop`.
- Add an active-project-only Projects page action labeled `打开工作台` that navigates to the route.
- Do not add a new top-level sidebar destination or `AppRoute` item.
- Add `NovelWorkshopPage(projectId)` under the Novel Workshop presentation layer.
- The page must show:
  - chapter list from `chapterPlansProvider(projectId)`, ordered by `chapterIndex`;
  - a Markdown-only body editor for the selected chapter;
  - a right-side panel with chapter objective card, prompt asset/runtime memory status, latest generation run summary, warnings, and a link to Workflow Runs detail when available.
- Add manual chapter plan create/edit UI:
  - new plans default to `max(chapterIndex) + 1`;
  - editing cannot change `chapterIndex`;
  - fields map to `ChapterObjectiveCard`;
  - validate `chapterIndex > 0` and at least one objective-card field is non-empty before save.
- Add command handling through Riverpod/application contracts; presentation must not import Drift tables.
- Save chapter body only through explicit manual save using the existing single-current-chapter model.
- Trigger generation through `ChapterGenerationPipeline.generateChapter(...)`.
- If a selected chapter already has saved content, generation must confirm overwrite before calling the pipeline with `replaceExisting: true`.
- While the selected chapter is running generation, disable generation and body save for that chapter.
- If editor content is dirty, switching chapters or generating must first offer save, discard, or cancel.
- Preserve existing service-layer guarantees for same-chapter concurrency, prompt trace recording, warning collection, and explicit overwrite protection.

## Acceptance Criteria

- Active project rows expose `打开工作台`; archived rows do not.
- Opening `/projects/:projectId/workshop` renders the target active project, including empty chapter state and a chapter creation entry.
- Creating a chapter plan adds it to the chapter list with auto-incremented index.
- Editing a chapter plan renders the index as read-only.
- Saving Markdown chapter content persists through `NovelWorkshopRepository.saveChapter`.
- Generating a chapter with existing content shows overwrite confirmation before pipeline invocation.
- Dirty editor chapter switch and dirty editor generation show save/discard/cancel handling.
- Running generation disables selected-chapter save/generate controls and shows run status.
- Right panel links generation task summary to `/workflow-runs/:taskId`.
- Widget tests cover the visible flows above with fake repositories/services and no live LLM calls.
- `dart run build_runner build`, `dart format lib test .trellis/spec`, `flutter analyze`, and `flutter test` pass or any failure is explicitly reported.

## Out of Scope

- Continuity audit.
- Memory sync proposal generation or acceptance.
- Automatic chapter splitting from `plotSkeletonMarkdown`.
- Chapter delete, reorder, or version history.
- Fact snapshots, lightweight gates, long-range recall, or whole-book consistency scan.
- Full Prompt Trace rendering inside Novel Workshop.
- A permanent top-level sidebar entry for Novel Workshop.

## Technical Notes

- Reuse `ChapterGenerationPipeline.generateChapter({required projectId, required chapterPlanId, bool replaceExisting = false})`.
- Reuse `NovelWorkshopRepository.saveChapterPlan`, `saveChapter`, `watchChapterPlans`, `watchChapters`, `watchChapterGenerationRuns`, and `ensureRuntimeMemory`.
- Reuse existing Workflow Runs route for full Prompt Trace detail.
- Follow frontend specs under `.trellis/spec/frontend/` and Novel Workshop backend persistence contracts in `.trellis/spec/backend/database-guidelines.md`.
