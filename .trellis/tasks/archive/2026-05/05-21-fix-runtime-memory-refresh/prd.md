# 修复运行时记忆应用后不刷新

## Goal

修复 Novel Workshop 中 Runtime Memory Patch 应用成功后页面仍显示旧记忆的问题，并让章节生成阶段日志准确表达“生成待审阅 Patch”而不是让用户误以为章节保存后已经自动写入最终记忆。

## What I already know

* 章节生成流程会先保存章节正文，再生成 `MemorySyncProposalInput`，把待审阅的 Runtime Memory / 角色关系 Patch 写回章节记录。
* 最终 Runtime Memory 只会在用户点击记忆页的“应用 Patch”后通过 `applyMemorySyncPatch` 写入。
* 手动编辑 Runtime Memory 的保存路径会 `ref.invalidate(projectRuntimeMemoryProvider(projectId))`。
* `applyMemorySyncPatch` 当前返回章节但没有刷新 `projectRuntimeMemoryProvider(projectId)`，会导致页面继续使用旧 `FutureProvider` 结果。
* 章节生成日志当前写成“生成角色卡片和关系图更新提案”，遗漏 Runtime Memory，容易造成流程理解偏差。

## Requirements

* 应用待审阅记忆 Patch 成功后，Runtime Memory 页必须刷新并展示已应用内容。
* 章节列表/待审阅 Patch 列表仍通过现有章节 stream 更新，不引入新的持久化表或 UI 流程。
* 章节生成日志文案必须明确这是“生成待审阅的 Runtime Memory / 角色关系 Patch”，而不是自动应用最终记忆。
* 保持现有手动 Runtime Memory 编辑保存行为不变。

## Acceptance Criteria

* [ ] 点击“应用 Patch”后，`projectRuntimeMemoryProvider(projectId)` 被失效并重新读取。
* [ ] 章节生成日志中的记忆阶段文案准确描述待审阅 Patch。
* [ ] 添加或更新测试覆盖 Patch 应用后的 provider 刷新行为。
* [ ] `flutter test` 的相关 Novel Workshop 测试通过。

## Definition of Done

* Tests added/updated where appropriate.
* Lint/typecheck status reported.
* No unrelated dirty worktree changes are reverted or staged.

## Out of Scope

* 不改成章节生成后自动应用记忆。
* 不重做 Runtime Memory 页面交互。
* 不调整角色关系 Patch 的解析/应用策略。

## Technical Notes

* Relevant code: `NovelWorkshopController.saveRuntimeMemory`, `NovelWorkshopController.applyMemorySyncPatch`, `_MemoryPatchReviewList._applyPatch`, `ChapterGenerationPipeline.generateChapter`.
* Specs read: backend error/quality/logging; frontend Riverpod hook/state management; shared cross-layer guide.
