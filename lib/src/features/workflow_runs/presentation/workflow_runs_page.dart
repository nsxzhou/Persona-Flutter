import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:yaml/yaml.dart';

import '../../../core/tasks/application/workflow_task_providers.dart';
import '../../../core/tasks/domain/workflow_prompt_trace.dart';
import '../../../core/tasks/domain/workflow_task.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/persona_page.dart';
import '../../../core/ui/skeleton_loader.dart';
import '../../../core/utils/markdown_utils.dart';
import '../../novel_workshop/application/novel_workshop_providers.dart';
import '../../novel_workshop/domain/novel_workshop.dart';
import '../../plot_lab/application/plot_lab_providers.dart';
import '../../plot_lab/domain/plot_analysis_run.dart';
import '../../style_lab/application/style_lab_providers.dart';
import '../../style_lab/domain/style_analysis_run.dart';
import '../application/workflow_task_controller.dart';

class WorkflowRunsPage extends ConsumerWidget {
  const WorkflowRunsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(recentWorkflowTasksProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return PersonaPage(
      eyebrow: '运维控制台',
      title: '工作流任务',
      description: '查看本地长任务的持久化状态，包括队列、失败原因和可恢复任务。',
      children: [
        tasks.when(
          data: (items) {
            final running = items
                .where((item) => item.status == WorkflowTaskStatus.running)
                .length;
            final failed = items
                .where((item) => item.status == WorkflowTaskStatus.failed)
                .length;

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: PersonaMetric(
                        label: '最近任务',
                        value: '${items.length}',
                        detail: '已持久化的本地工作流任务。',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: PersonaMetric(
                        label: '运行中',
                        value: '$running',
                        detail: '当前标记为活跃的任务。',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: PersonaMetric(
                        label: '待检查',
                        value: '$failed',
                        detail: '包含诊断信息的失败任务。',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (items.isEmpty)
                  const _EmptyWorkflowRuns()
                else
                  _WorkflowRunTable(items: items),
              ],
            );
          },
          error: (error, stackTrace) => PersonaPanel(
            child: Text(
              '无法加载工作流任务：$error',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
          loading: () => const _SkeletonLoading(),
        ),
      ],
    );
  }
}

class _EmptyWorkflowRuns extends StatelessWidget {
  const _EmptyWorkflowRuns();

  @override
  Widget build(BuildContext context) {
    return PersonaEmptyStateCard(
      icon: Icons.check_circle_outline,
      title: '尚未创建本地工作流任务。',
      description: '这里会显示最近的本地长任务、失败原因和可恢复任务。',
    );
  }
}

class _WorkflowPreviewActions extends ConsumerWidget {
  const _WorkflowPreviewActions({required this.task});

  final WorkflowTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (task.status != WorkflowTaskStatus.succeeded ||
        !_hasWorkflowPreview(task.kind) ||
        task.previewDismissedAt != null) {
      return const SizedBox.shrink();
    }
    final assetRun = task.kind == assetGenerationWorkflowTaskKind
        ? ref.watch(assetGenerationRunByWorkflowTaskProvider(task.id))
        : const AsyncValue<AssetGenerationRun?>.data(null);
    final enrichmentBatch = task.kind == chapterEnrichmentWorkflowTaskKind
        ? ref.watch(chapterEnrichmentBatchByWorkflowTaskProvider(task.id))
        : const AsyncValue<ChapterEnrichmentBatch?>.data(null);
    final enrichmentItems =
        task.kind == chapterEnrichmentWorkflowTaskKind &&
            enrichmentBatch.hasValue &&
            enrichmentBatch.value != null
        ? ref.watch(chapterEnrichmentItemsProvider(enrichmentBatch.value!.id))
        : const AsyncValue<List<ChapterEnrichmentItem>>.data([]);
    final canApply = _canApplyPreview(task, assetRun, enrichmentItems);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: () => context.go('/workflow-runs/${task.id}'),
          icon: const Icon(Icons.visibility_outlined, size: 16),
          label: const Text('打开预览'),
          style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
        ),
        if (canApply)
          FilledButton.icon(
            onPressed: () =>
                _applyPreview(context, ref, task, assetRun, enrichmentItems),
            icon: const Icon(Icons.check_outlined, size: 16),
            label: const Text('应用'),
            style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
          ),
        TextButton(
          onPressed: () => _dismissPreview(context, ref, task.id),
          child: const Text('忽略'),
        ),
      ],
    );
  }

  bool _canApplyPreview(
    WorkflowTask task,
    AsyncValue<AssetGenerationRun?> assetRun,
    AsyncValue<List<ChapterEnrichmentItem>> enrichmentItems,
  ) {
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

  Future<void> _applyPreview(
    BuildContext context,
    WidgetRef ref,
    WorkflowTask task,
    AsyncValue<AssetGenerationRun?> assetRun,
    AsyncValue<List<ChapterEnrichmentItem>> enrichmentItems,
  ) async {
    try {
      switch (task.kind) {
        case assetGenerationWorkflowTaskKind:
          final run = assetRun.value;
          if (run == null || run.draftMarkdown.trim().isEmpty) return;
          await ref
              .read(novelWorkshopControllerProvider.notifier)
              .applyAssetDraft(run.id);
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('资产草稿已应用。')));
        case chapterEnrichmentWorkflowTaskKind:
          final ids = enrichmentItems.value
              ?.where(
                (item) =>
                    item.status == ChapterEnrichmentItemStatus.generated &&
                    item.generatedContentMarkdown.trim().isNotEmpty,
              )
              .map((item) => item.id)
              .toList(growable: false);
          if (ids == null || ids.isEmpty) return;
          await ref
              .read(novelWorkshopControllerProvider.notifier)
              .applyChapterEnrichmentItems(ids);
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('已应用 ${ids.length} 个加料结果。')));
        default:
          return;
      }
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('应用失败：$error')));
    }
  }

  Future<void> _dismissPreview(
    BuildContext context,
    WidgetRef ref,
    String taskId,
  ) async {
    try {
      await ref.read(workflowTaskRepositoryProvider).dismissTaskPreview(taskId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('预览操作已忽略。')));
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('忽略失败：$error')));
    }
  }
}

class _WorkflowRunTable extends StatelessWidget {
  const _WorkflowRunTable({required this.items});

  final List<WorkflowTask> items;

  @override
  Widget build(BuildContext context) {
    return PersonaPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(18),
            child: PersonaSectionHeader(
              title: '最近工作流活动',
              description: '用于分析、导入和生成任务的紧凑状态视图。',
            ),
          ),
          const Divider(height: 1),
          for (final item in items) _WorkflowRunRow(item: item),
        ],
      ),
    );
  }
}

class _SkeletonLoading extends StatelessWidget {
  const _SkeletonLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PersonaPanel(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonBox(width: 80, height: 10),
                    SizedBox(height: 14),
                    SkeletonBox(width: 40, height: 28),
                    SizedBox(height: 6),
                    SkeletonBox(width: 160, height: 12),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: PersonaPanel(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonBox(width: 80, height: 10),
                    SizedBox(height: 14),
                    SkeletonBox(width: 40, height: 28),
                    SizedBox(height: 6),
                    SkeletonBox(width: 160, height: 12),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: PersonaPanel(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonBox(width: 80, height: 10),
                    SizedBox(height: 14),
                    SkeletonBox(width: 40, height: 28),
                    SizedBox(height: 6),
                    SkeletonBox(width: 160, height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        PersonaPanel(
          child: Column(
            children: List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    const SkeletonBox(width: 126, height: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SkeletonBox(width: 180, height: 14),
                          SizedBox(height: 4),
                          SkeletonBox(width: 120, height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkflowRunRow extends ConsumerStatefulWidget {
  const _WorkflowRunRow({required this.item});

  final WorkflowTask item;

  @override
  ConsumerState<_WorkflowRunRow> createState() => _WorkflowRunRowState();
}

class _WorkflowRunRowState extends ConsumerState<_WorkflowRunRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(colorScheme, widget.item.status);
    final styleRun = widget.item.kind == styleAnalysisWorkflowTaskKind
        ? ref.watch(styleAnalysisRunByWorkflowTaskProvider(widget.item.id))
        : const AsyncValue<StyleAnalysisRun?>.data(null);
    final plotRun = widget.item.kind == plotAnalysisWorkflowTaskKind
        ? ref.watch(plotAnalysisRunByWorkflowTaskProvider(widget.item.id))
        : const AsyncValue<PlotAnalysisRun?>.data(null);
    final assetRun = widget.item.kind == assetGenerationWorkflowTaskKind
        ? ref.watch(assetGenerationRunByWorkflowTaskProvider(widget.item.id))
        : const AsyncValue<AssetGenerationRun?>.data(null);
    final chapterRun = widget.item.kind == chapterGenerationWorkflowTaskKind
        ? ref.watch(chapterGenerationRunByWorkflowTaskProvider(widget.item.id))
        : const AsyncValue<ChapterGenerationRun?>.data(null);
    final enrichmentBatch =
        widget.item.kind == chapterEnrichmentWorkflowTaskKind
        ? ref.watch(
            chapterEnrichmentBatchByWorkflowTaskProvider(widget.item.id),
          )
        : const AsyncValue<ChapterEnrichmentBatch?>.data(null);
    final businessDetailPath = switch (widget.item.kind) {
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
    final canOpenBusinessDetail = businessDetailPath != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/workflow-runs/${widget.item.id}'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: _isHovered
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : Colors.transparent,
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 126,
                    child: PersonaStatusPill(
                      label: _statusLabel(widget.item.status),
                      icon: _statusIcon(widget.item.status),
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.item.title, style: textTheme.titleMedium),
                        const SizedBox(height: 3),
                        Text(
                          widget.item.stage == null
                              ? widget.item.kind
                              : '${widget.item.kind} - ${widget.item.stage}',
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (widget.item.kind == styleAnalysisWorkflowTaskKind) ...[
                    _WorkflowDetailState(run: styleRun),
                    const SizedBox(width: 14),
                  ],
                  if (widget.item.kind == plotAnalysisWorkflowTaskKind) ...[
                    _WorkflowDetailState(run: plotRun),
                    const SizedBox(width: 14),
                  ],
                  if (_canAbandon(widget.item)) ...[
                    OutlinedButton.icon(
                      onPressed: () => _confirmAbandon(context),
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('放弃'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        side: BorderSide(color: colorScheme.error),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                  _WorkflowPreviewActions(task: widget.item),
                  if (_hasVisibleWorkflowPreviewActions(widget.item)) ...[
                    const SizedBox(width: 14),
                  ],
                  Text(
                    _formatRunTime(widget.item.updatedAt),
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Tooltip(
                    message: _previewSummary(
                      widget.item,
                      assetRun,
                      chapterRun,
                      enrichmentBatch,
                    ),
                    child: Icon(
                      canOpenBusinessDetail ||
                              _hasVisibleWorkflowPreviewActions(widget.item)
                          ? Icons.chevron_right
                          : Icons.radio_button_unchecked,
                      size: 18,
                      color:
                          canOpenBusinessDetail ||
                              _hasVisibleWorkflowPreviewActions(widget.item)
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.45,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAbandon(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('放弃任务'),
        content: Text('将终止「${widget.item.title}」并清空该任务尚未应用的产出。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('放弃任务'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    try {
      await ref
          .read(workflowTaskControllerProvider.notifier)
          .abandon(widget.item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        this.context,
      ).showSnackBar(const SnackBar(content: Text('任务已放弃。')));
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        this.context,
      ).showSnackBar(SnackBar(content: Text('放弃失败：$error')));
    }
  }
}

class WorkflowRunDetailPage extends ConsumerWidget {
  const WorkflowRunDetailPage({required this.taskId, super.key});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(workflowTaskProvider(taskId));
    return task.when(
      data: (item) {
        if (item == null) {
          return PersonaPage(
            eyebrow: '运维控制台',
            title: '任务不存在',
            description: '该工作流任务可能已被删除。',
            actions: [
              OutlinedButton.icon(
                onPressed: () => context.go('/workflow-runs'),
                icon: const Icon(Icons.arrow_back_outlined),
                label: const Text('返回任务列表'),
              ),
            ],
            children: const [
              PersonaEmptyStateCard(
                icon: Icons.link_off_outlined,
                title: '无法找到任务',
                description: '没有可展示的状态、日志或 Prompt Trace。',
              ),
            ],
          );
        }
        return _WorkflowRunDetailScaffold(task: item);
      },
      loading: () => PersonaPage(
        eyebrow: '运维控制台',
        title: '读取工作流任务',
        description: taskId,
        children: const [
          PersonaPanel(
            child: SizedBox(
              height: 260,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
      error: (error, stackTrace) => PersonaPage(
        eyebrow: '运维控制台',
        title: '无法读取任务',
        description: '$error',
        actions: [
          OutlinedButton.icon(
            onPressed: () => context.go('/workflow-runs'),
            icon: const Icon(Icons.arrow_back_outlined),
            label: const Text('返回任务列表'),
          ),
        ],
        children: [
          PersonaPanel(
            child: Text(
              '$error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkflowRunDetailScaffold extends ConsumerStatefulWidget {
  const _WorkflowRunDetailScaffold({required this.task});

  final WorkflowTask task;

  @override
  ConsumerState<_WorkflowRunDetailScaffold> createState() =>
      _WorkflowRunDetailScaffoldState();
}

class _WorkflowRunDetailScaffoldState
    extends ConsumerState<_WorkflowRunDetailScaffold>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  var _traceMode = _TraceMode.rendered;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final trace = ref.watch(workflowPromptTraceProvider(task.id));
    final styleRun = task.kind == styleAnalysisWorkflowTaskKind
        ? ref.watch(styleAnalysisRunByWorkflowTaskProvider(task.id))
        : const AsyncValue<StyleAnalysisRun?>.data(null);
    final plotRun = task.kind == plotAnalysisWorkflowTaskKind
        ? ref.watch(plotAnalysisRunByWorkflowTaskProvider(task.id))
        : const AsyncValue<PlotAnalysisRun?>.data(null);
    final assetRun = task.kind == assetGenerationWorkflowTaskKind
        ? ref.watch(assetGenerationRunByWorkflowTaskProvider(task.id))
        : const AsyncValue<AssetGenerationRun?>.data(null);
    final chapterRun = task.kind == chapterGenerationWorkflowTaskKind
        ? ref.watch(chapterGenerationRunByWorkflowTaskProvider(task.id))
        : const AsyncValue<ChapterGenerationRun?>.data(null);
    final enrichmentBatch = task.kind == chapterEnrichmentWorkflowTaskKind
        ? ref.watch(chapterEnrichmentBatchByWorkflowTaskProvider(task.id))
        : const AsyncValue<ChapterEnrichmentBatch?>.data(null);
    final statusColor = _statusColor(
      Theme.of(context).colorScheme,
      task.status,
    );
    final businessDetailPath = _businessDetailPath(task, styleRun, plotRun);
    final logs = _logsForTask(task, styleRun, plotRun, assetRun);

    return PersonaPage(
      eyebrow: '',
      title: '',
      description: '',
      maxWidth: 1280,
      children: [
        _WorkflowDetailHeader(
          task: task,
          statusColor: statusColor,
          businessDetailPath: businessDetailPath,
          onAbandon: _canAbandon(task) ? () => _confirmAbandon(task) : null,
        ),
        _WorkflowOutputPreviewPanel(
          task: task,
          assetRun: assetRun,
          chapterRun: chapterRun,
          enrichmentBatch: enrichmentBatch,
        ),
        PersonaPanel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: PersonaSectionHeader(
                        title: '运行时 Prompt Trace',
                        description: '记录注入后的实际 LLM messages、输出摘要和失败摘要。',
                      ),
                    ),
                    const SizedBox(width: 12),
                    trace.when(
                      data: (item) => OutlinedButton.icon(
                        onPressed: item == null
                            ? null
                            : () => _copyTrace(item.traceMarkdown),
                        icon: const Icon(Icons.content_copy_outlined),
                        label: const Text('复制全文'),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (error, stackTrace) => const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 8),
                    SegmentedButton<_TraceMode>(
                      segments: const [
                        ButtonSegment(
                          value: _TraceMode.rendered,
                          label: Text('结构化'),
                        ),
                        ButtonSegment(
                          value: _TraceMode.raw,
                          label: Text('Raw'),
                        ),
                      ],
                      selected: {_traceMode},
                      showSelectedIcon: false,
                      onSelectionChanged: (value) =>
                          setState(() => _traceMode = value.single),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Prompt Trace'),
                  Tab(text: '任务日志'),
                ],
              ),
              SizedBox(
                height: 720,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _PromptTraceTab(trace: trace, mode: _traceMode),
                    _WorkflowLogTab(logs: logs),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _copyTrace(String markdown) async {
    await Clipboard.setData(ClipboardData(text: markdown));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Prompt Trace 已复制。')));
  }

  Future<void> _confirmAbandon(WorkflowTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('放弃任务'),
        content: Text('将终止「${task.title}」并清空该任务尚未应用的产出。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('放弃任务'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    try {
      await ref.read(workflowTaskControllerProvider.notifier).abandon(task.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('任务已放弃。')));
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('放弃失败：$error')));
    }
  }
}

enum _TraceMode { rendered, raw }

class _WorkflowDetailHeader extends StatelessWidget {
  const _WorkflowDetailHeader({
    required this.task,
    required this.statusColor,
    required this.businessDetailPath,
    required this.onAbandon,
  });

  final WorkflowTask task;
  final Color statusColor;
  final String? businessDetailPath;
  final VoidCallback? onAbandon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hasErrorMessage = task.errorMessage?.trim().isNotEmpty == true;
    final stage = task.stage?.trim().isNotEmpty == true ? task.stage! : '未记录阶段';

    return PersonaPanel(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Top row: eyebrow + status (left) | action buttons (right)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'PROMPT TRACE',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 12),
              PersonaStatusPill(
                label: _statusLabel(task.status),
                icon: _statusIcon(task.status),
                color: statusColor,
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => context.go('/workflow-runs'),
                icon: const Icon(Icons.arrow_back_outlined),
                label: const Text('返回任务列表'),
              ),
              if (onAbandon != null) ...[
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: onAbandon,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('放弃任务'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                  ),
                ),
              ],
              if (businessDetailPath != null) ...[
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: () => context.go(businessDetailPath!),
                  icon: const Icon(Icons.open_in_new_outlined),
                  label: const Text('业务详情'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          // -- Title
          Text(task.title, style: textTheme.headlineMedium),
          const SizedBox(height: 10),
          // -- Metadata row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _MetadataChip(label: stage),
              _MetaDot(color: colorScheme.onSurfaceVariant),
              _MetadataChip(label: task.kind),
              _MetaDot(color: colorScheme.onSurfaceVariant),
              _MetadataChip(label: _formatRunTime(task.updatedAt)),
            ],
          ),
          // -- Error / task ID
          if (hasErrorMessage) ...[
            const SizedBox(height: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: colorScheme.error.withValues(alpha: 0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 15,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.errorMessage!.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              '任务 ID：${task.id}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _MetaDot extends StatelessWidget {
  const _MetaDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Icon(Icons.circle, size: 4, color: color.withValues(alpha: 0.4)),
    );
  }
}

class _WorkflowOutputPreviewPanel extends ConsumerWidget {
  const _WorkflowOutputPreviewPanel({
    required this.task,
    required this.assetRun,
    required this.chapterRun,
    required this.enrichmentBatch,
  });

  final WorkflowTask task;
  final AsyncValue<AssetGenerationRun?> assetRun;
  final AsyncValue<ChapterGenerationRun?> chapterRun;
  final AsyncValue<ChapterEnrichmentBatch?> enrichmentBatch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!_hasWorkflowPreview(task.kind)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: PersonaPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PersonaSectionHeader(
              title: '任务产出预览',
              description: '查看并处理该任务生成的可审阅内容。',
            ),
            const SizedBox(height: 12),
            if (task.status == WorkflowTaskStatus.abandoned)
              const PersonaEmptyStateCard(
                icon: Icons.cancel_outlined,
                title: '任务已放弃',
                description: '该任务尚未应用的草稿、预览和 trace 已清空。',
              )
            else
              switch (task.kind) {
                assetGenerationWorkflowTaskKind => _AssetWorkflowOutputPreview(
                  run: assetRun,
                ),
                chapterGenerationWorkflowTaskKind =>
                  _ChapterWorkflowOutputPreview(run: chapterRun),
                chapterEnrichmentWorkflowTaskKind =>
                  _EnrichmentWorkflowOutputPreview(batch: enrichmentBatch),
                _ => const SizedBox.shrink(),
              },
          ],
        ),
      ),
    );
  }
}

class _AssetWorkflowOutputPreview extends ConsumerWidget {
  const _AssetWorkflowOutputPreview({required this.run});

  final AsyncValue<AssetGenerationRun?> run;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return run.when(
      data: (item) {
        if (item == null) {
          return const PersonaEmptyStateCard(
            icon: Icons.link_off_outlined,
            title: '资产任务记录缺失',
            description: '仍可在下方查看 Prompt Trace。',
          );
        }
        final draft = item.draftMarkdown.trim();
        if (draft.isEmpty) {
          return const PersonaEmptyStateCard(
            icon: Icons.rate_review_outlined,
            title: '暂无资产草稿',
            description: '该任务没有可应用的资产草稿，可继续查看 trace。',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PreviewMetadataRow(
              children: [
                _CompactMeta(label: '类型', value: _assetKindLabel(item.kind)),
                _CompactMeta(label: '字符', value: '${draft.length}'),
              ],
            ),
            const SizedBox(height: 10),
            _PreviewMarkdownSurface(text: draft),
            if (item.status == AssetGenerationStatus.applied) ...[
              const SizedBox(height: 12),
              PersonaStatusPill(
                label: '已应用',
                icon: Icons.check_circle_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
            ] else ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => _applyAssetDraft(context, ref, item.id),
                  icon: const Icon(Icons.check_outlined, size: 18),
                  label: const Text('应用草稿'),
                ),
              ),
            ],
          ],
        );
      },
      error: (error, stackTrace) => _InlineError(message: '无法加载资产草稿：$error'),
      loading: () => const SkeletonBox(width: 260, height: 16),
    );
  }

  Future<void> _applyAssetDraft(
    BuildContext context,
    WidgetRef ref,
    String runId,
  ) async {
    try {
      await ref
          .read(novelWorkshopControllerProvider.notifier)
          .applyAssetDraft(runId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('资产草稿已应用。')));
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('应用失败：$error')));
    }
  }
}

class _ChapterWorkflowOutputPreview extends StatelessWidget {
  const _ChapterWorkflowOutputPreview({required this.run});

  final AsyncValue<ChapterGenerationRun?> run;

  @override
  Widget build(BuildContext context) {
    return run.when(
      data: (item) {
        if (item == null) {
          return const PersonaEmptyStateCard(
            icon: Icons.link_off_outlined,
            title: '章节生成记录缺失',
            description: '仍可在下方查看 Prompt Trace。',
          );
        }
        final draft = item.draftMarkdown.trim();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PreviewMetadataRow(
              children: [
                _CompactMeta(label: '连续性', value: item.continuityVerdict.name),
                if (item.chapterId != null)
                  _CompactMeta(label: '章节', value: item.chapterId!),
                _CompactMeta(label: '字符', value: '${draft.length}'),
              ],
            ),
            if (draft.isNotEmpty) ...[
              const SizedBox(height: 10),
              _PreviewMarkdownSurface(text: draft),
            ] else
              const PersonaEmptyStateCard(
                icon: Icons.article_outlined,
                title: '章节已生成',
                description: '正文已写入章节记录，可从项目工作台进入编辑器查看。',
              ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () =>
                    context.go('/projects/${item.projectId}/workshop/editor'),
                icon: const Icon(Icons.edit_note_outlined, size: 18),
                label: const Text('打开生成章节'),
              ),
            ),
          ],
        );
      },
      error: (error, stackTrace) => _InlineError(message: '无法加载章节结果：$error'),
      loading: () => const SkeletonBox(width: 260, height: 16),
    );
  }
}

class _EnrichmentWorkflowOutputPreview extends ConsumerWidget {
  const _EnrichmentWorkflowOutputPreview({required this.batch});

  final AsyncValue<ChapterEnrichmentBatch?> batch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return batch.when(
      data: (item) {
        if (item == null) {
          return const PersonaEmptyStateCard(
            icon: Icons.link_off_outlined,
            title: '加料批次缺失',
            description: '仍可在下方查看 Prompt Trace。',
          );
        }
        final items = ref.watch(chapterEnrichmentItemsProvider(item.id));
        return items.when(
          data: (itemList) {
            final generated = itemList
                .where(
                  (item) =>
                      item.status == ChapterEnrichmentItemStatus.generated &&
                      item.generatedContentMarkdown.trim().isNotEmpty,
                )
                .toList(growable: false);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PreviewMetadataRow(
                  children: [
                    _CompactMeta(label: '总数', value: '${item.totalCount}'),
                    _CompactMeta(label: '预览', value: '${item.generatedCount}'),
                    _CompactMeta(label: '已应用', value: '${item.appliedCount}'),
                  ],
                ),
                const SizedBox(height: 10),
                if (itemList.isEmpty)
                  const PersonaEmptyStateCard(
                    icon: Icons.library_add_check_outlined,
                    title: '暂无加料条目',
                    description: '该批次没有可展示的逐项预览。',
                  )
                else
                  Column(
                    children: [
                      for (final entry in itemList)
                        _EnrichmentOutputTile(item: entry),
                    ],
                  ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: generated.isEmpty
                        ? null
                        : () => _applyGenerated(context, ref, generated),
                    icon: const Icon(Icons.done_all_outlined, size: 18),
                    label: const Text('应用全部可用预览'),
                  ),
                ),
              ],
            );
          },
          error: (error, stackTrace) =>
              _InlineError(message: '无法加载加料条目：$error'),
          loading: () => const SkeletonBox(width: 260, height: 16),
        );
      },
      error: (error, stackTrace) => _InlineError(message: '无法加载加料批次：$error'),
      loading: () => const SkeletonBox(width: 260, height: 16),
    );
  }

  Future<void> _applyGenerated(
    BuildContext context,
    WidgetRef ref,
    List<ChapterEnrichmentItem> items,
  ) async {
    try {
      await ref
          .read(novelWorkshopControllerProvider.notifier)
          .applyChapterEnrichmentItems(
            items.map((item) => item.id).toList(growable: false),
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已应用 ${items.length} 个加料结果。')));
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('应用失败：$error')));
    }
  }
}

class _EnrichmentOutputTile extends ConsumerWidget {
  const _EnrichmentOutputTile({required this.item});

  final ChapterEnrichmentItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final canApply =
        item.status == ChapterEnrichmentItemStatus.generated &&
        item.generatedContentMarkdown.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '章节 ${item.position + 1}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  PersonaStatusPill(
                    label: _enrichmentItemStatusLabel(item.status),
                    icon: _enrichmentItemStatusIcon(item.status),
                    color: _enrichmentItemStatusColor(colorScheme, item.status),
                  ),
                ],
              ),
              if (item.generatedContentMarkdown.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  item.generatedContentMarkdown.trim(),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (canApply) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: () => _deleteItem(context, ref, item.id),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('忽略'),
                      ),
                      FilledButton.icon(
                        onPressed: () => _applyItem(context, ref, item.id),
                        icon: const Icon(Icons.check_outlined, size: 18),
                        label: const Text('应用'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _applyItem(
    BuildContext context,
    WidgetRef ref,
    String itemId,
  ) async {
    try {
      await ref
          .read(novelWorkshopControllerProvider.notifier)
          .applyChapterEnrichmentItem(itemId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('加料结果已应用。')));
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('应用失败：$error')));
    }
  }

  Future<void> _deleteItem(
    BuildContext context,
    WidgetRef ref,
    String itemId,
  ) async {
    try {
      await ref
          .read(novelWorkshopControllerProvider.notifier)
          .deleteChapterEnrichmentItem(itemId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('加料结果已忽略。')));
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('忽略失败：$error')));
    }
  }
}

class _PreviewMetadataRow extends StatelessWidget {
  const _PreviewMetadataRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 12, runSpacing: 8, children: children);
  }
}

class _PreviewMarkdownSurface extends StatelessWidget {
  const _PreviewMarkdownSurface({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 360),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: SelectableText(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.55),
          ),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error_outline, size: 18, color: colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromptTraceTab extends StatelessWidget {
  const _PromptTraceTab({required this.trace, required this.mode});

  final AsyncValue<WorkflowPromptTrace?> trace;
  final _TraceMode mode;

  @override
  Widget build(BuildContext context) {
    return trace.when(
      data: (item) {
        final markdown = item?.traceMarkdown;
        if (markdown == null || markdown.trim().isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(18),
            child: PersonaEmptyStateCard(
              icon: Icons.manage_search_outlined,
              title: '暂无 Prompt Trace',
              description: '旧任务、未触发 LLM 的任务或 trace 写入失败时会出现此状态。',
            ),
          );
        }
        if (mode == _TraceMode.raw) {
          return Padding(
            padding: const EdgeInsets.all(18),
            child: _WorkflowCodeBlock(text: markdown, expand: true),
          );
        }
        final parsedTrace = _parsePromptTraceMarkdown(markdown);
        if (parsedTrace != null) {
          return Padding(
            padding: const EdgeInsets.all(18),
            child: _PromptTraceStructuredView(trace: parsedTrace),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(18),
          child: _TraceCodeSurface(
            text: stripFrontMatter(markdown),
            renderMarkdown: true,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          '无法读取 Prompt Trace：$error',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}

class _WorkflowLogTab extends StatelessWidget {
  const _WorkflowLogTab({required this.logs});

  final AsyncValue<String> logs;

  @override
  Widget build(BuildContext context) {
    return logs.when(
      data: (value) => Padding(
        padding: const EdgeInsets.all(18),
        child: _WorkflowCodeBlock(
          key: const ValueKey('workflow-log-code-block'),
          text: value.trim().isEmpty ? '暂无日志。' : value,
          expand: true,
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          '无法读取任务日志：$error',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}

class _PromptTraceStructuredView extends StatelessWidget {
  const _PromptTraceStructuredView({required this.trace});

  final _ParsedPromptTrace trace;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TraceSummaryChip(
                icon: Icons.format_list_numbered_outlined,
                label: '${trace.callsCount} calls',
              ),
              _TraceSummaryChip(
                icon: Icons.error_outline,
                label: '${trace.failedCallsCount} failed',
              ),
              if (trace.modelName != null)
                _TraceSummaryChip(
                  icon: Icons.memory_outlined,
                  label: trace.modelName!,
                ),
              _TraceSummaryChip(
                icon: Icons.notes_outlined,
                label: '${trace.totalInputChars} input chars',
              ),
              if (trace.updatedAt != null)
                _TraceSummaryChip(
                  icon: Icons.schedule_outlined,
                  label: _formatIsoRunTime(trace.updatedAt!),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (trace.calls.isEmpty)
            const PersonaEmptyStateCard(
              icon: Icons.manage_search_outlined,
              title: '暂无 LLM 调用',
              description: 'Trace 已创建，但当前还没有完成或失败的调用记录。',
            )
          else
            Column(
              children: [
                for (final call in trace.calls)
                  _PromptTraceCallTile(call: call),
              ],
            ),
        ],
      ),
    );
  }
}

class _TraceSummaryChip extends StatelessWidget {
  const _TraceSummaryChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _PromptTraceCallTile extends StatelessWidget {
  const _PromptTraceCallTile({required this.call});

  final _ParsedPromptTraceCall call;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColor = call.failed
        ? colorScheme.error
        : const Color(0xFF16825D);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          collapsedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          leading: CircleAvatar(
            radius: 16,
            backgroundColor: colorScheme.surfaceContainerHighest,
            child: Text(
              '${call.index}',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          title: Text(
            '${call.stage} / ${call.label}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleSmall,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              spacing: 10,
              runSpacing: 4,
              children: [
                _CompactMeta(label: 'model', value: call.model),
                _CompactMeta(label: 'duration', value: call.duration),
                _CompactMeta(label: 'input', value: call.inputChars),
                _CompactMeta(label: 'output', value: call.outputChars),
              ],
            ),
          ),
          trailing: PersonaStatusPill(
            label: call.failed ? 'failed' : 'ok',
            icon: call.failed
                ? Icons.error_outline
                : Icons.check_circle_outline,
            color: statusColor,
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _CompactMeta(label: 'temperature', value: call.temperature),
                  _CompactMeta(label: 'started', value: call.startedAt),
                  _CompactMeta(label: 'completed', value: call.completedAt),
                ],
              ),
            ),
            const SizedBox(height: 12),
            for (final message in call.messages)
              _PromptTraceSection(
                title: '${message.role} message',
                detail: '${message.chars} chars',
                text: message.content,
              ),
            if (call.outputExcerpt != null)
              _PromptTraceSection(
                title: 'Output excerpt',
                detail: call.outputChars,
                text: call.outputExcerpt!,
              ),
            if (call.errorSummary != null)
              _PromptTraceSection(
                title: 'Error summary',
                detail: 'failed call',
                text: call.errorSummary!,
              ),
          ],
        ),
      ),
    );
  }
}

class _CompactMeta extends StatelessWidget {
  const _CompactMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return RichText(
      text: TextSpan(
        style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurface),
        children: [
          TextSpan(
            text: '$label ',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _PromptTraceSection extends StatelessWidget {
  const _PromptTraceSection({
    required this.title,
    required this.detail,
    required this.text,
  });

  final String title;
  final String detail;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Text(
                detail,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _WorkflowCodeBlock(text: text),
        ],
      ),
    );
  }
}

class _WorkflowCodeBlock extends StatelessWidget {
  const _WorkflowCodeBlock({
    required this.text,
    this.expand = false,
    super.key,
  });

  final String text;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(kPanelRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: expand
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                text,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5),
              ),
            )
          : ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 84, maxHeight: 280),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  text,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
    );
    return SizedBox(width: double.infinity, child: content);
  }
}

class _TraceCodeSurface extends StatelessWidget {
  const _TraceCodeSurface({required this.text, required this.renderMarkdown});

  final String text;
  final bool renderMarkdown;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: renderMarkdown ? colorScheme.surface : const Color(0xFF101318),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: renderMarkdown
            ? Markdown(
                data: text,
                selectable: true,
                padding: const EdgeInsets.all(16),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  text,
                  style: const TextStyle(
                    color: Color(0xFFE5E7EB),
                    fontFamily: 'monospace',
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ),
      ),
    );
  }
}

String? _businessDetailPath(
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

AsyncValue<String> _logsForTask(
  WorkflowTask task,
  AsyncValue<StyleAnalysisRun?> styleRun,
  AsyncValue<PlotAnalysisRun?> plotRun,
  AsyncValue<AssetGenerationRun?> assetRun,
) {
  return switch (task.kind) {
    styleAnalysisWorkflowTaskKind => styleRun.whenData(
      (run) => run?.logs ?? '',
    ),
    plotAnalysisWorkflowTaskKind => plotRun.whenData((run) => run?.logs ?? ''),
    assetGenerationWorkflowTaskKind => assetRun.whenData(
      (run) => run?.logs ?? '',
    ),
    _ => const AsyncValue.data(''),
  };
}

_ParsedPromptTrace? _parsePromptTraceMarkdown(String markdown) {
  try {
    final frontMatter = _extractYamlFrontMatter(markdown);
    if (frontMatter == null) return null;
    final yaml = loadYaml(frontMatter.yaml);
    if (yaml is! YamlMap) return null;
    final calls = _parsePromptTraceCalls(frontMatter.body);
    return _ParsedPromptTrace(
      callsCount: _yamlInt(yaml['calls']) ?? calls.length,
      failedCallsCount:
          _yamlInt(yaml['failed_calls']) ??
          calls.where((call) => call.failed).length,
      totalInputChars: _yamlInt(yaml['total_input_chars']) ?? 0,
      modelName: _yamlString(yaml['model_name']),
      updatedAt: _yamlString(yaml['updated_at']),
      calls: calls,
    );
  } on Object {
    return null;
  }
}

_TraceFrontMatter? _extractYamlFrontMatter(String markdown) {
  final normalized = markdown.trimLeft();
  if (!normalized.startsWith('---\n')) return null;
  final end = normalized.indexOf('\n---', 4);
  if (end < 0) return null;
  final bodyStart = normalized.indexOf('\n', end + 4);
  if (bodyStart < 0) return null;
  return _TraceFrontMatter(
    yaml: normalized.substring(4, end),
    body: normalized.substring(bodyStart).trimLeft(),
  );
}

List<_ParsedPromptTraceCall> _parsePromptTraceCalls(String body) {
  final callHeading = RegExp(
    r'^## Call (\d+) - ([^/\n]+) / (.+)$',
    multiLine: true,
  );
  final matches = callHeading.allMatches(body).toList();
  final calls = <_ParsedPromptTraceCall>[];
  for (var index = 0; index < matches.length; index += 1) {
    final match = matches[index];
    final nextStart = index + 1 < matches.length
        ? matches[index + 1].start
        : body.length;
    final section = body.substring(match.end, nextStart);
    final fields = _parseFieldTable(section);
    final messages = _parsePromptTraceMessages(section);
    final outputExcerpt = _parseNamedCodeBlock(section, 'Output excerpt');
    final failed = fields['Failed']?.toLowerCase() == 'yes';
    final tableError = fields['Error']?.trimOrNull;
    final errorSummary = failed
        ? (tableError == '-' ? null : tableError) ??
              _parseFailedOutputSummary(section).trimOrNull
        : null;
    calls.add(
      _ParsedPromptTraceCall(
        index: int.tryParse(match.group(1) ?? '') ?? calls.length + 1,
        stage: match.group(2)?.trim() ?? 'unknown-stage',
        label: match.group(3)?.trim() ?? 'unknown-label',
        model: fields['Model'] ?? '-',
        temperature: fields['Temperature'] ?? '-',
        startedAt: _formatIsoRunTime(fields['Started at']),
        completedAt: _formatIsoRunTime(fields['Completed at']),
        duration: _formatDuration(fields['Duration']),
        inputChars: fields['Input chars'] ?? '-',
        outputChars: fields['Output chars'] ?? '-',
        failed: failed,
        errorSummary: errorSummary,
        outputExcerpt: outputExcerpt,
        messages: messages,
      ),
    );
  }
  return calls;
}

Map<String, String> _parseFieldTable(String section) {
  final fields = <String, String>{};
  for (final line in section.split('\n')) {
    if (!line.startsWith('|')) continue;
    final cells = line
        .split('|')
        .skip(1)
        .take(2)
        .map((cell) => _cleanMarkdownCell(cell))
        .toList();
    if (cells.length != 2) continue;
    final key = cells[0];
    final value = cells[1];
    if (key == '---' || key == 'Field' || key.isEmpty) continue;
    fields[key] = value;
  }
  return fields;
}

List<_ParsedPromptTraceMessage> _parsePromptTraceMessages(String section) {
  final messageHeading = RegExp(
    r'^### (System|User|Assistant) message$',
    multiLine: true,
  );
  final matches = messageHeading.allMatches(section).toList();
  final messages = <_ParsedPromptTraceMessage>[];
  for (var index = 0; index < matches.length; index += 1) {
    final match = matches[index];
    final nextStart = index + 1 < matches.length
        ? matches[index + 1].start
        : _nextOutputStart(section, match.end);
    final messageSection = section.substring(match.end, nextStart);
    final content = _firstFencedCodeContent(messageSection);
    if (content == null) continue;
    messages.add(
      _ParsedPromptTraceMessage(
        role: match.group(1) ?? 'Message',
        chars: content.length,
        content: content,
      ),
    );
  }
  return messages;
}

String? _parseNamedCodeBlock(String section, String title) {
  final heading = RegExp('^### ${RegExp.escape(title)}\$', multiLine: true);
  final match = heading.firstMatch(section);
  if (match == null) return null;
  return _firstFencedCodeContent(section.substring(match.end));
}

String _parseFailedOutputSummary(String section) {
  final heading = RegExp(r'^### Output excerpt$', multiLine: true);
  final match = heading.firstMatch(section);
  if (match == null) return '';
  final rest = section.substring(match.end);
  final nextHeading = RegExp(r'^### ', multiLine: true).firstMatch(rest);
  final chunk = nextHeading == null
      ? rest
      : rest.substring(0, nextHeading.start);
  return chunk
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .join('\n');
}

int _nextOutputStart(String section, int start) {
  final outputHeading = RegExp(r'^### Output excerpt$', multiLine: true);
  final match = outputHeading.firstMatch(section.substring(start));
  if (match == null) return section.length;
  return start + match.start;
}

String? _firstFencedCodeContent(String markdown) {
  final fenceStart = RegExp(
    r'(^|\n)(`{3,}|~{3,})[^\n]*\n',
  ).firstMatch(markdown);
  if (fenceStart == null) return null;
  final fence = fenceStart.group(2)!;
  final contentStart = fenceStart.end;
  final closePattern = RegExp('(^|\\n)${RegExp.escape(fence)}\\s*(?=\\n|\$)');
  final close = closePattern.firstMatch(markdown.substring(contentStart));
  if (close == null) return markdown.substring(contentStart).trimRight();
  return markdown
      .substring(contentStart, contentStart + close.start)
      .trimRight();
}

String _cleanMarkdownCell(String value) {
  final trimmed = value.trim();
  if (trimmed.length >= 2 && trimmed.startsWith('`') && trimmed.endsWith('`')) {
    return trimmed.substring(1, trimmed.length - 1);
  }
  return trimmed;
}

String? _yamlString(Object? value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

int? _yamlInt(Object? value) {
  if (value is int) return value;
  if (value == null) return null;
  return int.tryParse(value.toString());
}

String _formatIsoRunTime(String? value) {
  if (value == null || value.trim().isEmpty || value == '-') return '-';
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  return _formatRunTime(parsed);
}

String _formatDuration(String? value) {
  if (value == null || value.isEmpty || value == '-') return '-';
  return value.endsWith('ms') ? value : '${value.replaceAll(' ms', '')} ms';
}

class _TraceFrontMatter {
  const _TraceFrontMatter({required this.yaml, required this.body});

  final String yaml;
  final String body;
}

class _ParsedPromptTrace {
  const _ParsedPromptTrace({
    required this.callsCount,
    required this.failedCallsCount,
    required this.totalInputChars,
    required this.calls,
    this.modelName,
    this.updatedAt,
  });

  final int callsCount;
  final int failedCallsCount;
  final int totalInputChars;
  final String? modelName;
  final String? updatedAt;
  final List<_ParsedPromptTraceCall> calls;
}

class _ParsedPromptTraceCall {
  const _ParsedPromptTraceCall({
    required this.index,
    required this.stage,
    required this.label,
    required this.model,
    required this.temperature,
    required this.startedAt,
    required this.completedAt,
    required this.duration,
    required this.inputChars,
    required this.outputChars,
    required this.failed,
    required this.messages,
    this.errorSummary,
    this.outputExcerpt,
  });

  final int index;
  final String stage;
  final String label;
  final String model;
  final String temperature;
  final String startedAt;
  final String completedAt;
  final String duration;
  final String inputChars;
  final String outputChars;
  final bool failed;
  final String? errorSummary;
  final String? outputExcerpt;
  final List<_ParsedPromptTraceMessage> messages;
}

class _ParsedPromptTraceMessage {
  const _ParsedPromptTraceMessage({
    required this.role,
    required this.chars,
    required this.content,
  });

  final String role;
  final int chars;
  final String content;
}

extension on String {
  String? get trimOrNull {
    final value = trim();
    return value.isEmpty ? null : value;
  }
}

class _WorkflowDetailState<T> extends StatelessWidget {
  const _WorkflowDetailState({required this.run});

  final AsyncValue<T?> run;

  @override
  Widget build(BuildContext context) {
    return run.when(
      data: (item) {
        if (item == null) {
          return const PersonaStatusPill(
            label: '详情缺失',
            icon: Icons.link_off_outlined,
          );
        }
        return const PersonaStatusPill(
          label: '打开详情',
          icon: Icons.open_in_new_outlined,
        );
      },
      loading: () => const PersonaStatusPill(label: '定位中', icon: Icons.sync),
      error: (error, stackTrace) => PersonaStatusPill(
        label: '详情错误',
        icon: Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

Color _statusColor(ColorScheme colorScheme, WorkflowTaskStatus status) {
  return switch (status) {
    WorkflowTaskStatus.running => colorScheme.primary,
    WorkflowTaskStatus.failed => colorScheme.error,
    WorkflowTaskStatus.succeeded => const Color(0xFF16825D),
    WorkflowTaskStatus.pending => colorScheme.tertiary,
    WorkflowTaskStatus.abandoned => colorScheme.onSurfaceVariant,
  };
}

IconData _statusIcon(WorkflowTaskStatus status) {
  return switch (status) {
    WorkflowTaskStatus.running => Icons.sync,
    WorkflowTaskStatus.failed => Icons.error_outline,
    WorkflowTaskStatus.succeeded => Icons.check_circle_outline,
    WorkflowTaskStatus.pending => Icons.schedule,
    WorkflowTaskStatus.abandoned => Icons.cancel_outlined,
  };
}

String _statusLabel(WorkflowTaskStatus status) {
  return switch (status) {
    WorkflowTaskStatus.running => '运行中',
    WorkflowTaskStatus.failed => '失败',
    WorkflowTaskStatus.succeeded => '完成',
    WorkflowTaskStatus.pending => '排队中',
    WorkflowTaskStatus.abandoned => '已放弃',
  };
}

bool _canAbandon(WorkflowTask task) {
  return task.status == WorkflowTaskStatus.pending ||
      task.status == WorkflowTaskStatus.running;
}

bool _hasWorkflowPreview(String kind) {
  return kind == assetGenerationWorkflowTaskKind ||
      kind == chapterGenerationWorkflowTaskKind ||
      kind == chapterEnrichmentWorkflowTaskKind;
}

bool _hasVisibleWorkflowPreviewActions(WorkflowTask task) {
  return task.status == WorkflowTaskStatus.succeeded &&
      _hasWorkflowPreview(task.kind) &&
      task.previewDismissedAt == null;
}

String _assetKindLabel(AssetGenerationKind kind) {
  return switch (kind) {
    AssetGenerationKind.worldBuilding => '世界观设定',
    AssetGenerationKind.charactersBlueprint => '角色索引与关系网',
    AssetGenerationKind.outlineMaster => '总纲',
    AssetGenerationKind.volumeBlueprintYaml => '分卷蓝图',
    AssetGenerationKind.outlineDetailYaml => '章节细纲',
  };
}

String _enrichmentItemStatusLabel(ChapterEnrichmentItemStatus status) {
  return switch (status) {
    ChapterEnrichmentItemStatus.waiting => '等待中',
    ChapterEnrichmentItemStatus.running => '加料中',
    ChapterEnrichmentItemStatus.generated => '待应用',
    ChapterEnrichmentItemStatus.failed => '失败',
    ChapterEnrichmentItemStatus.applied => '已应用',
    ChapterEnrichmentItemStatus.abandoned => '已放弃',
  };
}

IconData _enrichmentItemStatusIcon(ChapterEnrichmentItemStatus status) {
  return switch (status) {
    ChapterEnrichmentItemStatus.waiting => Icons.schedule_outlined,
    ChapterEnrichmentItemStatus.running => Icons.sync,
    ChapterEnrichmentItemStatus.generated => Icons.rate_review_outlined,
    ChapterEnrichmentItemStatus.failed => Icons.error_outline,
    ChapterEnrichmentItemStatus.applied => Icons.check_circle_outline,
    ChapterEnrichmentItemStatus.abandoned => Icons.cancel_outlined,
  };
}

Color _enrichmentItemStatusColor(
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

String _previewSummary(
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

String _formatRunTime(DateTime value) {
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');

  return '$month-$day $hour:$minute';
}
