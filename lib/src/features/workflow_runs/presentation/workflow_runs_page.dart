import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/tasks/application/workflow_task_providers.dart';
import '../../../core/tasks/domain/workflow_task.dart';
import '../../../core/ui/persona_page.dart';
import '../../../core/ui/skeleton_loader.dart';

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

class _WorkflowRunRow extends StatefulWidget {
  const _WorkflowRunRow({required this.item});

  final WorkflowTask item;

  @override
  State<_WorkflowRunRow> createState() => _WorkflowRunRowState();
}

class _WorkflowRunRowState extends State<_WorkflowRunRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(colorScheme, widget.item.status);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: _isHovered
              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
              : Colors.transparent,
          border:
              Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 126,
                child: PersonaStatusPill(
                  label: widget.item.status.name,
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
              Text(
                _formatRunTime(widget.item.updatedAt),
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _statusColor(ColorScheme colorScheme, WorkflowTaskStatus status) {
  return switch (status) {
    WorkflowTaskStatus.running => colorScheme.primary,
    WorkflowTaskStatus.failed => colorScheme.error,
    WorkflowTaskStatus.succeeded => const Color(0xFF16825D),
    WorkflowTaskStatus.paused => const Color(0xFF8C6A14),
    WorkflowTaskStatus.canceled => colorScheme.onSurfaceVariant,
    WorkflowTaskStatus.pending => colorScheme.tertiary,
  };
}

IconData _statusIcon(WorkflowTaskStatus status) {
  return switch (status) {
    WorkflowTaskStatus.running => Icons.sync,
    WorkflowTaskStatus.failed => Icons.error_outline,
    WorkflowTaskStatus.succeeded => Icons.check_circle_outline,
    WorkflowTaskStatus.paused => Icons.pause_circle_outline,
    WorkflowTaskStatus.canceled => Icons.cancel_outlined,
    WorkflowTaskStatus.pending => Icons.schedule,
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
