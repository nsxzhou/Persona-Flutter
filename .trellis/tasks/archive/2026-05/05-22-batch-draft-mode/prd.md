# 批量草稿模式

## Goal

在 Novel Workshop 的单章生成闭环之上新增批量草稿模式。用户手动选择同一卷内连续章节后，系统按章节顺序生成草稿；每章必须通过正文连续性审计和 Memory Patch AI 审阅，并自动应用 Patch 后，才继续下一章，避免错误状态扩散。

## What I already know

* 当前单章 `ChapterGenerationPipeline.generateChapter` 已包含正文生成、连续性审计、保存章节、Memory Patch 提案流程。
* 连续性审计门禁任务已在工作区中引入 `draftMarkdown`、`continuityVerdict`、`continuityReportMarkdown` 和 warning/fail 行为。
* 现有 `ChapterEnrichmentBatch` 已提供 batch/item 状态、计数、日志、workflow task 同步等可复用模式。
* 单章生成仍应保留 `ChapterGenerationRun` 作为每次尝试的详细运行记录。

## Requirements

* 新增批量草稿领域模型、Drift 表、仓储接口、Provider 和应用层 pipeline。
* 用户只能选择同一项目、同一卷、按 `chapterIndex` 连续的章节计划。
* 启动前若选区内任一章节已有正文、项目存在待审 Memory Patch、项目存在运行中的单章生成或批量生成，则阻断。
* 批量启动前只预览首章上下文；后续章节基于上一章已应用后的 Runtime Memory 重新组装上下文。
* 每章正文审计必须 `pass`，否则最多自动重试 2 次；耗尽后批次失败并停止后续章节。
* 正文 `pass` 后生成 Memory Patch，并执行 AI Patch 审阅；只有 Patch 审阅 `pass` 才自动应用 Patch 并标记该章 `synced`。
* Patch 审阅 `warning/fail` 时只重试 Patch 生成与审阅，不重写正文；最多自动重试 2 次。
* 自动审阅报告只追加到 batch/item 日志，不新增结构化 report 字段。
* 自动重试只能覆盖本批次为该章节生成的未稳定产物，不覆盖批次启动前已有正文。
* v1 支持停止批次：停止后批次标 `failed`，已 `synced` 章节保留，后续章节不继续。
* UI 需要提供批量入口、起止章节选择、批次进度、章节 item 状态、尝试次数、错误、停止按钮和跳转/查看运行详情入口。

## Acceptance Criteria

* 连续章节成功路径会按顺序生成多章，并在每章 Patch 自动审阅通过后应用 Runtime Memory，再进入下一章。
* 启动校验覆盖非连续、跨卷、已有正文、pending Memory Patch、运行中生成任务。
* 正文审计 warning/fail 会自动重试，最多 2 次；耗尽后批次 failed，后续章节不生成。
* Patch 审阅 warning/fail 只重试 Patch，不重写正文；最多 2 次；耗尽后批次 failed。
* 停止批次后已 synced 章节保留，未完成 item 不继续。
* 批量主 workflow task 展示总进度，单章 run 保留明细。
* Drift generated 文件与 schema 变更同步。
* 相关单元测试、仓储测试、widget 测试通过。

## Out of Scope

* 不支持跨卷批量。
* 不支持已有正文批量覆盖。
* 不支持可恢复暂停。
* 不支持 imported enrichment 项目。
* 不新增 Patch 审阅报告结构化字段。
* 不实现多草稿版本管理。

## Technical Notes

* 主要涉及 `lib/src/features/novel_workshop/application/chapter_generation_pipeline.dart`、`novel_workshop_providers.dart`、`novel_workshop.dart`、`novel_workshop_repository.dart`、`drift_novel_workshop_repository.dart`、`app_database.dart`、`novel_workshop_page.dart`。
* 可参考 `ChapterEnrichmentPipeline`、`ChapterEnrichmentBatch`、`ChapterEnrichmentItem` 的 batch/item 持久化和 UI 模式。
* 验证命令：`dart run build_runner build`、`flutter test`。
