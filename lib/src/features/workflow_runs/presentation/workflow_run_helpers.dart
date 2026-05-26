import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/tasks/domain/workflow_task.dart';
import '../../novel_workshop/domain/novel_workshop.dart';
import '../../plot_lab/domain/plot_analysis_run.dart';
import '../../style_lab/domain/style_analysis_run.dart';

Color statusColor(ColorScheme colorScheme, WorkflowTaskStatus status) {
  return switch (status) {
    WorkflowTaskStatus.running => colorScheme.primary,
    WorkflowTaskStatus.failed => colorScheme.error,
    WorkflowTaskStatus.succeeded => const Color(0xFF16825D),
    WorkflowTaskStatus.pending => colorScheme.tertiary,
    WorkflowTaskStatus.abandoned => colorScheme.onSurfaceVariant,
  };
}

IconData statusIcon(WorkflowTaskStatus status) {
  return switch (status) {
    WorkflowTaskStatus.running => Icons.sync,
    WorkflowTaskStatus.failed => Icons.error_outline,
    WorkflowTaskStatus.succeeded => Icons.check_circle_outline,
    WorkflowTaskStatus.pending => Icons.schedule,
    WorkflowTaskStatus.abandoned => Icons.cancel_outlined,
  };
}

String statusLabel(WorkflowTaskStatus status) {
  return switch (status) {
    WorkflowTaskStatus.running => '运行中',
    WorkflowTaskStatus.failed => '失败',
    WorkflowTaskStatus.succeeded => '完成',
    WorkflowTaskStatus.pending => '排队中',
    WorkflowTaskStatus.abandoned => '已放弃',
  };
}

String kindLabel(String kind) {
  return switch (kind) {
    styleAnalysisWorkflowTaskKind => '风格分析',
    plotAnalysisWorkflowTaskKind => '剧情分析',
    assetGenerationWorkflowTaskKind => '资产生成',
    chapterGenerationWorkflowTaskKind => '章节生成',
    chapterGenerationBatchWorkflowTaskKind => '批量草稿',
    chapterEnrichmentWorkflowTaskKind => '章节加料',
    chapterIllustrationGenerationWorkflowTaskKind => '插图生成',
    _ => kind,
  };
}

bool canAbandon(WorkflowTask task) {
  return task.status == WorkflowTaskStatus.pending ||
      task.status == WorkflowTaskStatus.running;
}

bool hasWorkflowPreview(String kind) {
  return kind == assetGenerationWorkflowTaskKind ||
      kind == chapterGenerationWorkflowTaskKind ||
      kind == chapterEnrichmentWorkflowTaskKind ||
      kind == chapterIllustrationGenerationWorkflowTaskKind;
}

bool canApplyPreview(
  WorkflowTask task,
  AsyncValue<AssetGenerationRun?> assetRun,
  AsyncValue<List<ChapterEnrichmentItem>> enrichmentItems,
) {
  if (task.status != WorkflowTaskStatus.succeeded ||
      task.previewDismissedAt != null) {
    return false;
  }
  return switch (task.kind) {
    assetGenerationWorkflowTaskKind =>
      assetRun.hasValue &&
          assetRun.value?.status == AssetGenerationStatus.succeeded &&
          assetRun.value?.draftMarkdown.trim().isNotEmpty == true,
    chapterEnrichmentWorkflowTaskKind =>
      enrichmentItems.hasValue &&
          enrichmentItems.value?.any(
                (item) =>
                    item.status == ChapterEnrichmentItemStatus.generated &&
                    item.generatedContentMarkdown.trim().isNotEmpty,
              ) ==
              true,
    _ => false,
  };
}

bool canOpenPreview(
  WorkflowTask task,
  AsyncValue<AssetGenerationRun?> assetRun,
  AsyncValue<ChapterGenerationRun?> chapterRun,
  AsyncValue<List<ChapterEnrichmentItem>> enrichmentItems,
) {
  if (task.status != WorkflowTaskStatus.succeeded ||
      task.previewDismissedAt != null) {
    return false;
  }
  return switch (task.kind) {
    assetGenerationWorkflowTaskKind =>
      assetRun.hasValue &&
          assetRun.value?.draftMarkdown.trim().isNotEmpty == true,
    chapterGenerationWorkflowTaskKind =>
      chapterRun.hasValue &&
          (chapterRun.value?.draftMarkdown.trim().isNotEmpty == true ||
              chapterRun.value?.chapterId != null),
    chapterEnrichmentWorkflowTaskKind =>
      enrichmentItems.hasValue &&
          enrichmentItems.value?.any(
                (item) =>
                    item.status == ChapterEnrichmentItemStatus.generated &&
                    item.generatedContentMarkdown.trim().isNotEmpty,
              ) ==
              true,
    _ => false,
  };
}

bool hasVisibleWorkflowPreviewActions(
  WorkflowTask task,
  AsyncValue<AssetGenerationRun?> assetRun,
  AsyncValue<ChapterGenerationRun?> chapterRun,
  AsyncValue<ChapterEnrichmentBatch?> enrichmentBatch,
  AsyncValue<List<ChapterEnrichmentItem>> enrichmentItems,
) {
  if (task.status != WorkflowTaskStatus.succeeded ||
      task.previewDismissedAt != null ||
      !hasWorkflowPreview(task.kind)) {
    return false;
  }
  return switch (task.kind) {
    assetGenerationWorkflowTaskKind =>
      assetRun.hasValue &&
          assetRun.value?.status == AssetGenerationStatus.succeeded &&
          assetRun.value?.draftMarkdown.trim().isNotEmpty == true,
    chapterGenerationWorkflowTaskKind =>
      chapterRun.hasValue &&
          (chapterRun.value?.draftMarkdown.trim().isNotEmpty == true ||
              chapterRun.value?.chapterId != null),
    chapterEnrichmentWorkflowTaskKind =>
      enrichmentBatch.hasValue &&
          enrichmentBatch.value != null &&
          enrichmentItems.hasValue &&
          enrichmentItems.value?.any(
                (item) =>
                    item.status == ChapterEnrichmentItemStatus.generated &&
                    item.generatedContentMarkdown.trim().isNotEmpty,
              ) ==
              true,
    _ => false,
  };
}

String? businessDetailPath(
  WorkflowTask task,
  AsyncValue<StyleAnalysisRun?> styleRun,
  AsyncValue<PlotAnalysisRun?> plotRun,
) {
  return switch (task.kind) {
    styleAnalysisWorkflowTaskKind => switch (styleRun) {
      AsyncData(value: final run?) => '/style-lab/tasks/${run.id}',
      _ => null,
    },
    plotAnalysisWorkflowTaskKind => switch (plotRun) {
      AsyncData(value: final run?) => '/plot-lab/tasks/${run.id}',
      _ => null,
    },
    _ => null,
  };
}

String assetKindLabel(AssetGenerationKind kind) {
  return switch (kind) {
    AssetGenerationKind.worldBuilding => '世界观设定',
    AssetGenerationKind.charactersBlueprint => '角色索引与关系网',
    AssetGenerationKind.outlineMaster => '总纲',
    AssetGenerationKind.volumeBlueprintYaml => '分卷蓝图',
    AssetGenerationKind.outlineDetailYaml => '章节细纲',
  };
}

String enrichmentItemStatusLabel(ChapterEnrichmentItemStatus status) {
  return switch (status) {
    ChapterEnrichmentItemStatus.waiting => '等待中',
    ChapterEnrichmentItemStatus.running => '加料中',
    ChapterEnrichmentItemStatus.generated => '待应用',
    ChapterEnrichmentItemStatus.failed => '失败',
    ChapterEnrichmentItemStatus.applied => '已应用',
    ChapterEnrichmentItemStatus.abandoned => '已放弃',
  };
}

IconData enrichmentItemStatusIcon(ChapterEnrichmentItemStatus status) {
  return switch (status) {
    ChapterEnrichmentItemStatus.waiting => Icons.schedule_outlined,
    ChapterEnrichmentItemStatus.running => Icons.sync,
    ChapterEnrichmentItemStatus.generated => Icons.rate_review_outlined,
    ChapterEnrichmentItemStatus.failed => Icons.error_outline,
    ChapterEnrichmentItemStatus.applied => Icons.check_circle_outline,
    ChapterEnrichmentItemStatus.abandoned => Icons.cancel_outlined,
  };
}

Color enrichmentItemStatusColor(
  ColorScheme colorScheme,
  ChapterEnrichmentItemStatus status,
) {
  return switch (status) {
    ChapterEnrichmentItemStatus.waiting => colorScheme.onSurfaceVariant,
    ChapterEnrichmentItemStatus.running => colorScheme.primary,
    ChapterEnrichmentItemStatus.generated => const Color(0xFF16825D),
    ChapterEnrichmentItemStatus.failed => colorScheme.error,
    ChapterEnrichmentItemStatus.applied => colorScheme.primary,
    ChapterEnrichmentItemStatus.abandoned => colorScheme.onSurfaceVariant,
  };
}

String chapterBatchItemStatusLabel(ChapterGenerationBatchItemStatus status) {
  return switch (status) {
    ChapterGenerationBatchItemStatus.waiting => '等待中',
    ChapterGenerationBatchItemStatus.running => '运行中',
    ChapterGenerationBatchItemStatus.synced => '已同步',
    ChapterGenerationBatchItemStatus.failed => '失败',
    ChapterGenerationBatchItemStatus.abandoned => '已放弃',
  };
}

String formatRunTime(DateTime value) {
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$month-$day $hour:$minute';
}

String previewSummary(
  WorkflowTask task,
  AsyncValue<AssetGenerationRun?> assetRun,
  AsyncValue<ChapterGenerationRun?> chapterRun,
  AsyncValue<ChapterEnrichmentBatch?> enrichmentBatch,
) {
  return switch (task.kind) {
    assetGenerationWorkflowTaskKind => switch (assetRun) {
      AsyncData(value: final run?) when run.draftMarkdown.trim().isNotEmpty =>
        '资产草稿待审阅，${run.draftMarkdown.trim().length} 字符。',
      AsyncData() => '资产任务已完成，可查看 Prompt Trace。',
      AsyncLoading() => '正在定位资产草稿...',
      AsyncError(:final error) => '资产草稿加载失败：$error',
    },
    chapterGenerationWorkflowTaskKind => switch (chapterRun) {
      AsyncData(value: final run?) when run.chapterId != null =>
        '章节已生成，可从任务详情跳转到生成记录。',
      AsyncData(value: final run?) when run.draftMarkdown.trim().isNotEmpty =>
        '章节草稿待检查，${run.draftMarkdown.trim().length} 字符。',
      AsyncLoading() => '正在定位章节结果...',
      AsyncError(:final error) => '章节结果加载失败：$error',
      _ => '章节任务已完成。',
    },
    chapterEnrichmentWorkflowTaskKind => switch (enrichmentBatch) {
      AsyncData(value: final batch?) =>
        '章节加料完成：${batch.generatedCount} 个预览，${batch.appliedCount} 个已应用。',
      AsyncLoading() => '正在定位加料预览...',
      AsyncError(:final error) => '加料预览加载失败：$error',
      _ => '章节加料任务已完成。',
    },
    _ => '任务已完成，可查看详情与 Prompt Trace。',
  };
}
