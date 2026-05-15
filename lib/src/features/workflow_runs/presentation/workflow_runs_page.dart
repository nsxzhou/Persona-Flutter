import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/tasks/application/workflow_task_providers.dart';
import '../../../core/tasks/domain/workflow_task.dart';
import '../../../core/ui/persona_page.dart';

class WorkflowRunsPage extends ConsumerWidget {
  const WorkflowRunsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(recentWorkflowTasksProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return PersonaPage(
      eyebrow: 'Operations console',
      title: 'Workflow Runs',
      description:
          'Inspect persisted task state for long-running local AI workflows, including queue state, failures, and recoverable runs.',
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
                        label: 'Recent runs',
                        value: '${items.length}',
                        detail: 'Persisted local workflow tasks.',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: PersonaMetric(
                        label: 'Running',
                        value: '$running',
                        detail: 'Tasks currently marked active.',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: PersonaMetric(
                        label: 'Needs review',
                        value: '$failed',
                        detail: 'Failed tasks with diagnostic detail.',
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
              'Unable to load workflow runs: $error',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
          loading: () => const PersonaPanel(child: LinearProgressIndicator()),
        ),
      ],
    );
  }
}

class _EmptyWorkflowRuns extends StatelessWidget {
  const _EmptyWorkflowRuns();

  @override
  Widget build(BuildContext context) {
    return PersonaPanel(
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('No local workflow runs have been created yet.'),
          ),
        ],
      ),
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
              title: 'Recent workflow activity',
              description:
                  'Dense task state for analysis, import, and generation jobs.',
            ),
          ),
          const Divider(height: 1),
          for (final item in items) _WorkflowRunRow(item: item),
        ],
      ),
    );
  }
}

class _WorkflowRunRow extends StatelessWidget {
  const _WorkflowRunRow({required this.item});

  final WorkflowTask item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(colorScheme, item.status);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 126,
              child: PersonaStatusPill(
                label: item.status.name,
                icon: _statusIcon(item.status),
                color: statusColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(
                    item.stage == null
                        ? item.kind
                        : '${item.kind} - ${item.stage}',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              _formatRunTime(item.updatedAt),
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
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
