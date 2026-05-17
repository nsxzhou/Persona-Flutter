# 分析功能清理与稳固

## Goal

稳固 Style Lab / Plot Lab 的本地分析流水线，保留 `YAML+MD` 作为 LLM 输出契约，减少重复实现和迁移残留，同时保留 `Workflow Runs` 作为未来后台任务统一入口。

## Requirements

* 保留 Plot sketch 的 `YAML front matter + # Chunk Sketch` 输出形态。
* 强化 `PlotChunkSketchDocumentParser` 对字段白名单、必填字段、枚举值、列表元素类型、正文标题的校验。
* 优化 Plot sketch prompt，减少长示例干扰，明确禁止代码围栏、额外字段和额外前后文。
* 抽出 Style/Plot 共享的文本切块、输入分类和错误脱敏截断逻辑。
* 为 Plot skeleton 增加分层归约兜底，避免 sketch payload 过大时单次聚合超上下文。
* 保留 `Workflow Runs` / `workflow_task_records`，但清理 `WorkflowTaskRepository` 当前无人调用的写接口。
* 收敛 Style/Plot repository 中同步更新 analysis run 与 workflow task 的重复逻辑。

## Acceptance Criteria

* [x] Plot pipeline 仍从 `YAML+MD` sketch 解析出 `PlotChunkSketch` 并生成 skeleton/report/story engine。
* [x] Plot sketch parser 对缺字段、额外字段、非法枚举、非字符串列表项、缺正文标题给出明确失败。
* [x] Style/Plot pipeline 共享切块、输入分类、错误脱敏实现。
* [x] `Workflow Runs` 页面仍能打开 Style/Plot 任务详情。
* [x] `dart format .`、`flutter analyze`、`flutter test` 通过。

## Out of Scope

* 不实现暂停/恢复。
* 不实现跨重启 checkpoint。
* 不引入 Worker、LangGraph、远程 API 或单独本地 HTTP 后端。
* 不删除 `workflow_task_records`，不做破坏性数据库迁移。

## Technical Notes

* 主要涉及 `lib/src/features/style_lab/application/`、`lib/src/features/plot_lab/application/`、`lib/src/features/*/data/`、`lib/src/core/tasks/` 和相关测试。
* 需遵守 `.trellis/spec/backend/` 与 `.trellis/spec/frontend/` 中的本地业务层、Drift、Riverpod 和测试规范。
