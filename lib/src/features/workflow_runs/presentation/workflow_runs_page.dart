import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/tasks/application/workflow_task_providers.dart';

class WorkflowRunsPage extends ConsumerWidget {
  const WorkflowRunsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(recentWorkflowTasksProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Workflow Runs', style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Persisted task state for long-running local AI workflows.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              tasks.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const _EmptyWorkflowRuns();
                  }
                  return Column(
                    children: [
                      for (final item in items)
                        ListTile(
                          title: Text(item.title),
                          subtitle: Text('${item.kind} • ${item.status.name}'),
                        ),
                    ],
                  );
                },
                error: (error, stackTrace) => Text(
                  'Unable to load workflow runs: $error',
                  style: TextStyle(color: colorScheme.error),
                ),
                loading: () => const LinearProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyWorkflowRuns extends StatelessWidget {
  const _EmptyWorkflowRuns();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
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
      ),
    );
  }
}
