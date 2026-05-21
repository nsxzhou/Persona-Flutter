# 修复资产生成失败与日志缺失

## Goal

修复小说资产生成中角色索引与关系网任务因 `secrets` YAML 列表输出而失败的问题，并让工作流详情页能展示 `novel_asset_generation` 任务的运行日志。

## What I Already Know

* 当前截图中的失败任务类型是 `novel_asset_generation`，错误为 `secrets 必须是字符串。`
* `CharacterGraphParser` 目前对 `secrets` 使用严格字符串解析；模型可能输出 YAML 列表。
* 工作流详情页 `_logsForTask` 目前只读取 `style_analysis` 和 `plot_analysis` 的业务 run 日志，其他任务返回空字符串。
* `AssetGenerationPipeline` 已经通过 `AssetGenerationRun.logs` 记录阶段日志，失败时也会追加“资产草稿生成失败”。

## Requirements

* `secrets` 应支持字符串或字符串列表，列表按 `、` 合并为一个字符串存储，不修改数据库 schema。
* 其他严格字段保持原校验行为，不能吞掉无效 YAML。
* `novel_asset_generation` 工作流详情页的“任务日志”应读取资产生成 run 的 `logs`。
* 本次不新增资产生成详情页路由。

## Acceptance Criteria

* [ ] 角色资产生成返回 `secrets` 列表时，资产生成任务成功完成并记录 Prompt Trace。
* [ ] `secrets` 为对象等非法类型时仍报错，错误信息能定位到字段路径。
* [ ] `novel_asset_generation` 任务详情页切到“任务日志”时显示资产生成 run 日志。
* [ ] 现有 style/plot 工作流详情日志行为不回退。

## Definition of Done

* 添加或更新单元/Widget 测试覆盖上述行为。
* 运行针对性 Flutter 测试通过。
* 如 Riverpod 生成文件发生变化，运行 build runner 同步生成代码。

## Out of Scope

* 不新增资产生成业务详情页。
* 不调整数据库结构。
* 不更改 LLM prompt contract 以外的资产生成流程。

## Technical Notes

* 相关文件：`character_graph_parser.dart`、`novel_workshop_repository.dart`、`drift_novel_workshop_repository.dart`、`novel_workshop_providers.dart`、`workflow_runs_page.dart`。
* 测试重点：`asset_generation_pipeline_test.dart`、`workflow_runs_page_test.dart`，必要时新增解析器专用测试。
