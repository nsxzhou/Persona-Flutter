# 生成前上下文预览

## Goal

在章节生成按钮真正调用模型前，先弹出“上下文预览”对话框，展示本次会进入最终 prompt 的上下文参与情况、结构化角色/关系数量、非阻断缺失提示，以及完整最终 prompt Markdown。用户确认后才继续生成；不做 token 精算。

## What I already know

* 现有章节生成流程在 `ChapterGenerationPipeline.generateChapter` 中组装 `WritingContextBundle`，随后调用 LLM。
* `WritingContextBundle.promptMarkdown` 已经是最终章节生成 prompt Markdown。
* `WritingContextAssembler` 已经会产生非阻断 warnings，例如 Voice Profile / Story Engine 缺失。
* UI 的“生成”入口在 `NovelWorkshopPage`，当前会先处理未保存正文和覆盖确认，然后直接调用 `generateChapter`。

## Requirements

* 新增只读预览能力：`previewGenerationContext(projectId, chapterPlanId)`。
* 预览不得创建生成 run、不得调用模型、不得写入数据库。
* 预览返回最终 prompt Markdown 与元信息：
  * `warnings`
  * `projectBibleIncluded`
  * `chapterObjectiveCardIncluded`
  * `runtimeMemoryIncluded`
  * `characterCount`
  * `relationshipCount`
  * `voiceProfileIncluded`
  * `storyEngineIncluded`
* 点击“生成”后、实际生成前展示预览对话框。
* 对话框展示 Project Bible / Chapter Objective Card / Runtime Memory 是否参与。
* 对话框展示 Characters / Relationships 数量。
* Voice Profile / Story Engine 缺失只提示，不阻断确认生成。
* 对话框展示最终 prompt Markdown 预览。
* 用户取消或关闭对话框时不生成。
* 不修改 Prompt Trace、生成 run 数据结构和数据库 schema。

## Acceptance Criteria

* [x] 管线预览方法能组装最终 prompt 并返回上下文状态。
* [x] 预览方法不触发 LLM 调用、不创建章节正文。
* [x] UI 点击生成会先展示上下文预览；确认后才调用现有生成流程。
* [x] Voice Profile / Story Engine 缺失时预览仍可确认生成。
* [x] 目标单测覆盖管线预览和 UI 确认/取消流程。

## Definition of Done

* Tests added/updated.
* Targeted Flutter tests pass.
* `flutter analyze` checked if feasible.
* No schema migration or generated database changes.

## Out of Scope

* Token 精算或 token 估算展示。
* Prompt Trace 结构调整。
* 生成 run 数据库字段调整。
* 资产自动修复或强制补齐。

## Technical Notes

* 主要文件：
  * `lib/src/features/novel_workshop/application/chapter_generation_pipeline.dart`
  * `lib/src/features/novel_workshop/domain/writing_context.dart`
  * `lib/src/features/novel_workshop/presentation/novel_workshop_page.dart`
* 测试文件：
  * `test/novel_workshop/chapter_generation_pipeline_test.dart`
  * `test/novel_workshop/novel_workshop_page_test.dart`
  * `test/novel_workshop/writing_context_assembler_test.dart`
