import 'package:flutter/material.dart';

import '../../../core/tasks/domain/workflow_task.dart';

class WorkflowRunMetrics extends StatelessWidget {
  const WorkflowRunMetrics({
    required this.items,
    required this.selectedStatus,
    required this.onStatusChanged,
    super.key,
  });

  final List<WorkflowTask> items;
  final WorkflowTaskStatus? selectedStatus;
  final ValueChanged<WorkflowTaskStatus?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final running = items
        .where((item) => item.status == WorkflowTaskStatus.running)
        .length;
    final failed = items
        .where((item) => item.status == WorkflowTaskStatus.failed)
        .length;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _FilterMetric(
            label: '全部任务',
            value: '${items.length}',
            detail: '点击查看全部',
            accentColor: colorScheme.primary,
            isSelected: selectedStatus == null,
            onTap: () => onStatusChanged(null),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _FilterMetric(
            label: '运行中',
            value: '$running',
            detail: running > 0 ? '正在进行的任务' : '暂无运行中任务',
            accentColor: colorScheme.primary,
            isActive: running > 0,
            isSelected: selectedStatus == WorkflowTaskStatus.running,
            onTap: () => onStatusChanged(WorkflowTaskStatus.running),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _FilterMetric(
            label: '待检查',
            value: '$failed',
            detail: failed > 0 ? '需要关注的失败任务' : '暂无失败任务',
            accentColor: colorScheme.error,
            isActive: failed > 0,
            isSelected: selectedStatus == WorkflowTaskStatus.failed,
            onTap: () => onStatusChanged(WorkflowTaskStatus.failed),
          ),
        ),
      ],
    );
  }
}

class _FilterMetric extends StatelessWidget {
  const _FilterMetric({
    required this.label,
    required this.value,
    required this.detail,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
    this.isActive = false,
  });

  final String label;
  final String value;
  final String detail;
  final Color accentColor;
  final bool isActive;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final borderColor = isSelected
        ? accentColor
        : isActive
            ? accentColor.withValues(alpha: 0.35)
            : colorScheme.outlineVariant;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            color: isSelected
                ? accentColor.withValues(alpha: 0.08)
                : colorScheme.surface,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? accentColor
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? accentColor
                        : isActive
                            ? accentColor
                            : colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  detail,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
