# 连续性审计生成门禁

## Goal

在 Novel Workshop 章节生成流程中加入连续性审计门禁。生成正文后先审计人物状态、世界规则、伏笔和章节目标，再决定是否保存章节、是否继续生成 Runtime Memory Patch。

## What I already know

* 当前 `ChapterGenerationPipeline.generateChapter` 的流程是组装上下文、生成正文、保存章节、生成 Memory Patch。
* 领域层已有 `ContinuityVerdict { pass, warning, fail }`，`ProjectChapter` 已有 `continuityVerdict` 和 `continuityReportMarkdown` 字段。
* `ChapterGenerationRun` 目前只有状态、日志、上下文 warnings、错误信息和 `chapterId`，没有失败草稿或审计报告字段。
* Drift 当前 `schemaVersion` 是 20，修改表结构后需要升版本并运行 `dart run build_runner build`。
* UI 已有生成任务列表、编辑器失败提示、Prompt Trace 链接和 Runtime Memory Patch 审阅流程。

## Requirements

* 在章节正文生成后、保存章节前新增 `auditContinuity` 阶段。
* 审计模型输出 `pass / warning / fail`，检查：
  * 人物状态漂移。
  * 世界规则冲突。
  * 伏笔遗漏。
  * 章节目标完成度。
* 审美、文风、节奏、描写质量不得作为 `fail` 原因。
* 审计输出格式为 YAML 头 + Markdown 报告。
* YAML 字段至少包含 `verdict`、四类检查结果、阻断问题、警告问题、摘要。
* 审计输出解析失败时按 `warning` 处理，并在报告中标注解析失败。
* `pass`：保存章节，写入审计报告，继续生成 Memory Patch。
* `warning`：保存章节，写入审计报告，暂停 Memory Patch，并在 UI 提供继续生成 Memory Patch 的入口。
* `fail`：不保存章节，把生成 run 标失败；保留失败草稿和审计报告，允许用户重新生成。
* `ChapterGenerationRun` 需要持久化：
  * `draftMarkdown`
  * `continuityVerdict`
  * `continuityReportMarkdown`
* 新增从已保存章节触发 Memory Patch 的应用层方法。
* 继续同步前校验章节属于当前项目、正文非空、contentHash 与当前章节一致。
* UI 需要在编辑器/任务区展示最近章节或 run 的审计 verdict/report 摘要；失败 run 需要展示失败草稿和审计报告入口。

## Acceptance Criteria

* `pass` 章节保存成功，并继续生成待审阅 Memory Patch。
* `warning` 章节保存成功，报告可见，不自动生成 Memory Patch；用户点击继续同步后可以生成 Memory Patch。
* `fail` 不创建或覆盖章节正文，生成任务为失败，失败草稿和报告可见，再次生成不被阻塞。
* 审计输出解析失败会降级为 `warning`。
* 数据库迁移和 generated Drift 文件保持同步。
* 相关单元测试和 widget 测试覆盖新增行为。

## Out of Scope

* 不新增独立审计历史表。
* 不实现多版本章节草稿管理。
* 不把 `warning` 自动推进 Runtime Memory。
* 不把审美判断作为硬失败。

## Technical Notes

* 主要涉及 `lib/src/features/novel_workshop/application/chapter_generation_pipeline.dart`。
* 领域和持久化涉及 `novel_workshop.dart`、`novel_workshop_repository.dart`、`drift_novel_workshop_repository.dart`、`app_database.dart`。
* UI 涉及 `novel_workshop_page.dart` 和相关测试 fake repository。
* 验证命令：`dart run build_runner build`、`flutter test`。
