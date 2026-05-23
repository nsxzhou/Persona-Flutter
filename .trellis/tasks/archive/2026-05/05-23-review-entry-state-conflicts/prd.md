# 修复审阅入口状态冲突

## Goal

统一“待审阅产出”的可操作状态：只有真正未处理的产出才显示待处理入口；已应用内容仍可在详情页查看，但不再从工作台或任务列表表现为“还可审阅/应用”。`忽略`保持为 Workflow Runs 的任务提醒级关闭，不影响项目工作台里的草稿数据。

## What I already know

* 当前资产草稿审阅判断在 `novel_workshop_page.dart` 和 `character_graph_tab.dart` 各有一份 `_canReview`，且都允许 `AssetGenerationStatus.applied`。
* Workflow Runs 行内预览入口目前只按 task 状态、预览类型、`previewDismissedAt` 做首层显示判断，未完全结合底层产出是否仍可处理。
* `/workflow-runs/:taskId` 详情页已支持已应用资产展示“已应用”并隐藏应用按钮。
* `dismissTaskPreview` 只写 `workflow_task_records.preview_dismissed_at`，需求确认其语义仅为关闭任务提醒。
* 章节规划页当前传入 `outlineDetailYaml` 最新 run，但“生成全部分卷”实际创建 `volumeBlueprintYaml` run，可能造成入口语义错配。

## Requirements

* 资产草稿审阅规则只对 `AssetGenerationStatus.succeeded` 且 `draftMarkdown` 非空显示“查看草稿”。
* `AssetGenerationStatus.applied` 不再作为工作台待审阅入口，也不能从工作台弹窗再次应用。
* 统一资产草稿可审阅判断，覆盖 `novel_workshop_page.dart` 和 `character_graph_tab.dart`，避免重复逻辑分叉。
* Workflow Runs 行内预览操作只在存在可处理产出时展示：可应用资产草稿、可应用加料条目，或章节生成可打开预览。
* 已应用资产、无可应用加料项、已关闭提醒、已放弃任务不显示 Workflow Runs 行内预览操作。
* 任务详情页继续可查看历史产出：已应用资产显示“已应用”但无应用按钮；章节生成继续展示结果和跳转；加料只对 `generated + 非空` 条目显示应用/忽略。
* 分卷规划入口按 `AssetGenerationKind.volumeBlueprintYaml` 读取和展示最近草稿；单卷“生成本卷细纲”继续使用 `outlineDetailYaml`。
* `dismissTaskPreview` 不改变数据范围，只关闭 Workflow Runs 行内提醒；提示文案需明确产出仍可在项目工作台查看。
* 不引入新数据库字段，不做 migration。

## Acceptance Criteria

* [ ] 已应用资产不再在项目工作台资产 tab 显示“查看草稿”。
* [ ] 已应用资产任务不再在 Workflow Runs 列表中贡献 `打开预览`、`应用`、`忽略` 行内操作。
* [ ] Workflow Runs 任务详情仍能显示已应用资产的历史产出和“已应用”状态。
* [ ] 加料批次全部已应用或没有 `generated + 非空` 条目时，不显示 Workflow Runs 行内预览操作。
* [ ] `忽略` snackbar 明确说明只是关闭任务预览提醒。
* [ ] “生成全部分卷”入口只匹配 `volumeBlueprintYaml` 草稿；单卷细纲入口继续匹配 `outlineDetailYaml`。
* [ ] Focused widget tests pass: `flutter test test/workflow_runs_page_test.dart test/novel_workshop/novel_workshop_page_test.dart`.

## Out of Scope

* 不删除已应用草稿内容。
* 不改变 Workflow Runs 详情页查看历史产出的能力。
* 不新增产出级 dismissal 状态。
* 不做数据库 schema / migration 变更。

## Technical Notes

* Main implementation files: `lib/src/features/novel_workshop/presentation/novel_workshop_page.dart`, `lib/src/features/novel_workshop/presentation/character/character_graph_tab.dart`, `lib/src/features/workflow_runs/presentation/workflow_runs_page.dart`.
* Main tests: `test/workflow_runs_page_test.dart`, `test/novel_workshop/novel_workshop_page_test.dart`.
* Existing related PRD: `.trellis/tasks/archive/2026-05/05-23-workflow-preview-dismiss-state/prd.md`.
