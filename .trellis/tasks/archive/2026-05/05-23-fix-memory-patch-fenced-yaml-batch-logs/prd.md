# 修复 Memory Patch fenced YAML 与批量日志

## Goal

修复 Memory Patch 审阅和应用链路中无法处理 Markdown 代码围栏包裹 YAML 的问题，并让批量章节生成任务在 Workflow Runs 详情页展示批次和章节 item 日志，便于定位失败原因。

## What I already know

* Memory Patch 生成提示要求只输出 YAML，但实际 LLM 可能返回 ` ```yaml ... ``` `。
* 当前 `ChapterGenerationPipeline._cleanMarkdownDraft` 只剥离 `markdown/md` 围栏，导致 `yaml/yml` 围栏被原样保存到 `memorySyncPatchYaml`。
* `loadYaml` 遇到首行 ` ```yaml ` 会报 `Unexpected character`，截图里的 Runtime Memory 待审阅预览失败与此一致。
* Workflow Runs 详情页当前只映射 style/plot/asset 日志，`novel_chapter_generation_batch` 落到空字符串，所以显示“暂无日志”。
* 批量生成后端已经把 batch 日志写入 `ChapterGenerationBatch.logs`，把每章过程写入 `ChapterGenerationBatchItem.logs`。

## Requirements

* 新生成的 Memory Patch 即使被 LLM 包在 `yaml/yml/markdown/md` 代码围栏内，也要保存为纯 YAML。
* 既有已保存的 fenced YAML Patch 在预览、审阅和应用时都应被兼容清洗。
* `applyMemorySyncPatch` 仍需保持现有状态校验和 merge 语义，不改数据库 schema，不迁移历史数据。
* Workflow Runs 详情页必须能按 workflow task id 找到批量章节生成记录，并展示 batch 日志和 item 日志。
* 不能把 Prompt Trace 当任务日志来源；Prompt Trace 继续负责 LLM messages 与输出摘要。

## Acceptance Criteria

* [ ] Pipeline test 覆盖 fenced YAML Memory Patch 生成后保存为纯 YAML，并可通过批量 Memory Patch 审阅自动应用。
* [ ] Repository test 覆盖已保存 fenced YAML Patch 可以应用到 Runtime Memory。
* [ ] Widget test 覆盖 `novel_chapter_generation_batch` 详情页任务日志展示 batch/item 错误细节。
* [ ] Focused Flutter tests pass for changed pipeline, repository, and Workflow Runs UI.
* [ ] Riverpod generated provider file与新增 provider 保持同步。

## Out of Scope

* 不自动重跑已经失败的批量任务。
* 不新增数据库列或迁移。
* 不改变 Prompt Trace 存储结构。

## Technical Notes

* Shared cleanup should live in Novel Workshop application code so pipeline, repository, and preview can reuse it without duplicating regex behavior.
* Repository contract needs `watchChapterGenerationBatchByWorkflowTask(String workflowTaskId)`.
* Workflow Runs `_logsForTask` should compose batch logs with item logs while preserving empty-log behavior for unknown task kinds.
