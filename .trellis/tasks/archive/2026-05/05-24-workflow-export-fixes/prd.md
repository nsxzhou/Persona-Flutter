# 修复工作流任务页、关闭提醒与小说 TXT 导出

## Goal

修复 Persona Flutter 本地写作系统中的三个用户可见问题：关闭任务预览后不再弹出额外成功提醒；工作流任务页展示全部持久化任务并支持状态和类型筛选；写作工作台提供当前项目小说 TXT 导出能力。

## What I already know

* 用户明确要求关闭预览就是关闭，不需要额外提醒或处理。
* 工作流任务页当前只展示最近 20 条，因为 `DriftWorkflowTaskRepository.watchRecentTasks()` 查询包含 `limit(20)`。
* 当前已有设置页 SQLite 全库备份导出，但用户需要的是小说 TXT 导出。
* 导出入口应放在写作工作台顶部。
* TXT 导出应包含书名、卷名、所有章节标题；已有正文转纯文本；空章节只保留标题；只导出已保存内容。
* 筛选维度为状态和类型；顶部统计卡始终按全量任务统计。

## Requirements

* 成功忽略任务预览时只持久化 `previewDismissedAt`，不显示成功 `SnackBar`。
* 保留忽略失败时的错误 `SnackBar`。
* 工作流任务 repository 提供全量任务流，按 `updatedAt desc` 排序。
* 工作流任务页默认显示全部任务，支持按 `WorkflowTaskStatus` 和任务 kind 筛选。
* 工作流任务页顶部统计卡不受筛选影响。
* 写作工作台顶部新增“导出 TXT”按钮。
* 导出流程使用现有 `file_picker` 保存 `.txt` 文件。
* 导出内容按卷序和章节序组织，空章节只输出标题。
* Markdown 正文轻量清洗为纯文本后写入 TXT。

## Acceptance Criteria

* [ ] 点击“忽略”后不再出现“任务预览提醒已关闭，产出仍可在项目工作台查看。”。
* [ ] 工作流任务页可展示超过 20 条任务。
* [ ] 工作流任务页可按状态筛选。
* [ ] 工作流任务页可按类型筛选。
* [ ] 筛选后顶部统计仍为全量统计。
* [ ] 写作工作台顶部显示“导出 TXT”。
* [ ] 小说 TXT 导出包含书名、卷名、章节标题、已保存纯文本正文和空章节标题。

## Out of Scope

* 不新增导入 TXT 或项目数据包导入。
* 不修改现有 SQLite 全库备份能力。
* 不做搜索框、日期范围筛选或分页。
* 不导出编辑器未保存文本，也不在导出前自动保存。

## Technical Notes

* 主要影响文件预计包括：
  * `lib/src/core/tasks/application/workflow_task_repository.dart`
  * `lib/src/core/tasks/data/drift_workflow_task_repository.dart`
  * `lib/src/core/tasks/application/workflow_task_providers.dart`
  * `lib/src/features/workflow_runs/presentation/workflow_runs_page.dart`
  * `lib/src/features/novel_workshop/application/novel_workshop_providers.dart`
  * `lib/src/features/novel_workshop/presentation/novel_workshop_page.dart`
* 测试预计更新：
  * `test/workflow_runs_page_test.dart`
  * `test/novel_workshop/novel_workshop_page_test.dart`
  * 新增小说导出单元测试。

## Definition of Done

* Tests added/updated for changed behavior.
* Relevant generated Riverpod files are regenerated if provider names change.
* `flutter test test/workflow_runs_page_test.dart test/novel_workshop/novel_workshop_page_test.dart` passes.
* Full `flutter test` attempted and result reported.
