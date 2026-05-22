# Patch 审阅闭环

## Goal

Stabilize the Novel Workshop chapter-writing loop by giving users an explicit way to reject AI-generated memory sync proposals. A generated chapter can remain useful even when its Runtime Memory / character / relationship patch is wrong; the product must let the user discard that patch without changing chapter prose or current project state.

This is the first implementation task in the broader "manual chapter writing loop stabilization" direction. It focuses only on closing the memory patch decision loop and reducing state-pollution risk.

## What I Already Know

* The product direction is a local-first AI long-form writing workspace.
* First-stage optimization target is the manual per-chapter loop, not automatic multi-chapter generation.
* `Voice Profile` and `Story Engine` are enhancement assets, not required prerequisites for chapter generation.
* The minimum usable generation context is `Project Bible` + `Chapter Objective Card` + progressively accumulated `Runtime Memory`.
* Users confirmed a two-track decision model:
  * chapter prose: keep / edit / regenerate
  * memory proposal: apply / discard / handle later
* The first-stage risk to reduce is state pollution: incorrect runtime memory, character state, relationship changes, or world-rule changes being carried into later chapters.
* Existing code already supports `pendingReview`, `synced`, `noChange`, `failed`, and `stale` memory sync statuses.
* Existing code already validates memory proposal freshness by comparing `memorySyncContentHash` with the current chapter `contentHash` before applying.
* Current UI exposes pending memory patches and an "应用 Patch" action, but there is no equivalent discard/reject action.

## Requirements

### Functional Requirements

* Add an explicit `discarded` memory sync status.
* Add a repository-level operation to discard a pending memory sync patch for a chapter.
* Discarding a patch must:
  * change only the chapter memory sync status;
  * not mutate chapter prose;
  * not mutate current Runtime Memory;
  * not apply character or relationship changes;
  * preserve the generated patch/proposed memory fields for auditability unless existing architecture strongly requires clearing them.
* Discarding is only valid for a pending review proposal. Invalid status transitions should fail clearly.
* UI must show both apply and discard actions for pending memory patches.
* UI must stop listing discarded patches as pending work.
* UI labels must distinguish:
  * `noChange`: the AI produced no meaningful state change;
  * `discarded`: the AI produced a proposal, but the user rejected it;
  * `stale`: the proposal no longer matches the current chapter content;
  * `synced`: the proposal was applied.
* Controller/provider layer must expose the discard operation and invalidate affected providers consistently with apply.

### Testing Requirements

* Repository tests must cover:
  * discarding a pending patch moves it to `discarded`;
  * discarding does not change Runtime Memory;
  * discarding does not apply character or relationship patch data;
  * discarding non-pending proposals fails clearly;
  * applying a discarded patch is not allowed.
* Widget tests must cover:
  * pending patch review shows both apply and discard actions;
  * discard action removes the patch from the pending review list;
  * status rendering distinguishes `discarded` from `noChange`.

## Acceptance Criteria

* [x] A chapter with `MemorySyncStatus.pendingReview` can be discarded from the Novel Workshop UI.
* [x] Discarded patches no longer appear in the pending review list.
* [x] Discarding a patch does not change Runtime Memory, characters, relationships, or chapter prose.
* [x] `discarded` is represented distinctly from `noChange`, `stale`, and `synced` in domain/status display code.
* [x] Existing apply-patch stale/content-hash behavior remains intact.
* [x] Relevant unit and widget tests pass.

## Out of Scope

* Git-style diff preview for memory patches.
* Per-field or per-line selective patch application.
* Generation-before-run context preview.
* Automatic multi-chapter generation.
* Continuity audit scoring.
* README / documentation refresh for the broader product roadmap.
* Token counting or provider-specific prompt budget estimation.

## Technical Notes

* Likely domain files:
  * `lib/src/features/novel_workshop/domain/novel_workshop.dart`
  * `lib/src/features/novel_workshop/domain/novel_workshop_repository.dart`
* Likely data/application files:
  * `lib/src/features/novel_workshop/data/drift_novel_workshop_repository.dart`
  * `lib/src/features/novel_workshop/application/novel_workshop_providers.dart`
* Likely UI file:
  * `lib/src/features/novel_workshop/presentation/novel_workshop_page.dart`
* Likely tests:
  * `test/novel_workshop/novel_workshop_repository_test.dart`
  * `test/novel_workshop/novel_workshop_page_test.dart`
* Current data-layer apply behavior already checks:
  * chapter exists;
  * `memorySyncStatus == pendingReview`;
  * `memorySyncContentHash == contentHash`.
* Existing `saveChapter` computes `contentHash` and detects content changes, so stale protection should be preserved, not redesigned in this task.
* `discarded` is an enum value persisted by name in existing text columns, so adding it should not require a database schema migration unless generated code or constraints reveal otherwise.

## Definition of Done

* Implementation follows existing Flutter/Riverpod/Drift layering.
* `dart format .` applied to touched Dart files.
* `flutter analyze` passes or any unrelated existing failures are explicitly reported.
* Targeted tests for Novel Workshop repository and page behavior pass.
* No unrelated `.trellis` or `.codex` worktree changes are modified or reverted.
