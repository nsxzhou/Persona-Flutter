# 修复批量草稿终态面板无法清除

## Goal

编辑器右侧的批量草稿面板应只作为临时任务状态提醒。批量草稿成功、失败或放弃后，用户可以在当前编辑器会话中手动关闭该面板；任务历史、日志和 Prompt Trace 继续通过工作流任务列表查看。批量流水线异常结束时必须写入终态，不能留下 `pending` / `running` 记录阻塞下一批。

## What I already know

* 编辑器当前直接取 `generationBatchItems.firstOrNull` 作为右侧面板数据。
* Drift 仓储按 `updatedAt desc` 返回批量草稿批次，所以成功/失败的最新终态批次会稳定成为 `firstOrNull` 并常驻右侧。
* `hasRunningChapterGenerationBatch` 只把 `pending` 和 `running` 视为运行中；正常成功/失败不会阻塞下一批。
* `ChapterGenerationPipeline.processChapterGenerationBatch` 进入 `running` 后只特殊处理 `LlmCancellationException`，缺少非取消异常的批次失败兜底。
* `ChapterEnrichmentPipeline.processBatch` 存在相同类别的非取消异常兜底缺口。

## Requirements

* 编辑器优先显示 `pending` / `running` 批量草稿批次。
* 没有运行中批次时，显示最近一个未被当前编辑器会话关闭的终态批次。
* 终态批次面板提供关闭按钮；关闭只影响当前编辑器 widget 生命周期，不写数据库，不使用 `previewDismissedAt`。
* 终态批次面板提供进入 `/workflow-runs/{workflowTaskId}` 的入口。
* 批量草稿流水线的非取消异常必须把已进入处理的批次标记为 `failed`，写入 `errorMessage`、日志和 `completedAt`，然后重新抛出异常给 UI。
* LLM 取消仍保持 `abandoned` 语义，不被通用失败兜底覆盖。
* 章节加料批次补同类非取消异常兜底，避免加料批次卡在 `running`。

## Acceptance Criteria

* [ ] 成功或失败的终态批量草稿面板会显示，点击关闭后从编辑器右侧消失。
* [ ] 关闭终态面板后，“批量草稿”按钮仍可继续启动下一批。
* [ ] 新运行中的批次优先显示，即使旧终态批次此前被关闭。
* [ ] 批量草稿非取消异常后，批次为 `failed`，项目不再被识别为存在运行中的批量草稿。
* [ ] 加料批次非取消异常后也落到终态。

## Definition of Done

* Widget tests cover terminal panel close behavior and next batch visibility.
* Pipeline tests cover non-cancellation failure fallback for batch draft and enrichment batch.
* Relevant Flutter tests pass.
* No database schema or repository public interface changes.

## Out of Scope

* Deleting or archiving workflow task records.
* Persisting editor-side terminal panel dismissal.
* Changing imported enrichment project overview's "最近加料批次" result preview.

## Technical Notes

* Main UI file: `lib/src/features/novel_workshop/presentation/novel_workshop_page.dart`.
* Batch draft pipeline: `lib/src/features/novel_workshop/application/chapter_generation_pipeline.dart`.
* Enrichment pipeline: `lib/src/features/novel_workshop/application/chapter_enrichment_pipeline.dart`.
* Existing tests: `test/novel_workshop/novel_workshop_page_test.dart`, `test/novel_workshop/chapter_generation_pipeline_test.dart`, `test/novel_workshop/chapter_enrichment_pipeline_test.dart`.
