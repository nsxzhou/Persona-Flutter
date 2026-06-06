import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/tasks/application/workflow_task_providers.dart';
import '../../../core/tasks/domain/workflow_task.dart';
import '../../../core/ui/persona_page.dart';
import '../../../core/ui/skeleton_loader.dart';
import 'workflow_run_filters.dart';
import 'workflow_run_metrics.dart';
import 'workflow_run_row.dart';

class WorkflowRunsPage extends ConsumerStatefulWidget {
  const WorkflowRunsPage({super.key});

  @override
  ConsumerState<WorkflowRunsPage> createState() => _WorkflowRunsPageState();
}

class _WorkflowRunsPageState extends ConsumerState<WorkflowRunsPage> {
  WorkflowTaskStatus? _statusFilter;
  String? _kindFilter;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(workflowTasksProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: tasksAsync.when(
        data: (tasks) {
          final filteredTasks = tasks
              .where(
                (task) =>
                    (_statusFilter == null || task.status == _statusFilter) &&
                    (_kindFilter == null || task.kind == _kindFilter),
              )
              .toList(growable: false);

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1240),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '运维控制台'.toUpperCase(),
                                      style: textTheme.labelMedium?.copyWith(
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '工作流任务',
                                      style: textTheme.headlineMedium,
                                    ),
                                    const SizedBox(height: 10),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 700,
                                      ),
                                      child: Text(
                                        '查看本地长任务的持久化状态，包括队列、失败原因和可恢复任务。',
                                        style: textTheme.bodyLarge?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Metrics (also acts as status filter)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1240),
                      child: WorkflowRunMetrics(
                        items: tasks,
                        selectedStatus: _statusFilter,
                        onStatusChanged: (value) =>
                            setState(() => _statusFilter = value),
                      ),
                    ),
                  ),
                ),
              ),

              // Filters
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 18, 32, 0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1240),
                      child: WorkflowRunFilters(
                        items: tasks,
                        kindFilter: _kindFilter,
                        onKindChanged: (value) =>
                            setState(() => _kindFilter = value),
                      ),
                    ),
                  ),
                ),
              ),

              // Empty state
              if (tasks.isEmpty || filteredTasks.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 18, 32, 0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1240),
                        child: tasks.isEmpty
                            ? const _EmptyWorkflowRuns()
                            : const _EmptyFilteredWorkflowRuns(),
                      ),
                    ),
                  ),
                ),

              // Virtual list rows
              if (filteredTasks.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(32, 18, 32, 0),
                  sliver: SliverList.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) => Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1240),
                        child: WorkflowRunRow(
                          key: ValueKey(filteredTasks[index].id),
                          task: filteredTasks[index],
                        ),
                      ),
                    ),
                  ),
                ),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
        error: (error, stackTrace) => Center(
          child: PersonaPanel(
            child: Text(
              '无法加载工作流任务：$error',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ),
        loading: () => const _SkeletonLoading(),
      ),
    );
  }
}

class _EmptyWorkflowRuns extends StatelessWidget {
  const _EmptyWorkflowRuns();

  @override
  Widget build(BuildContext context) {
    return const PersonaEmptyStateCard(
      icon: Icons.check_circle_outline,
      title: '尚未创建本地工作流任务。',
      description: '这里会显示最近的本地长任务、失败原因和可恢复任务。',
    );
  }
}

class _EmptyFilteredWorkflowRuns extends StatelessWidget {
  const _EmptyFilteredWorkflowRuns();

  @override
  Widget build(BuildContext context) {
    return const PersonaEmptyStateCard(
      icon: Icons.filter_alt_off_outlined,
      title: '没有符合筛选条件的任务。',
      description: '调整状态或类型筛选后再查看。',
    );
  }
}

class _SkeletonLoading extends StatelessWidget {
  const _SkeletonLoading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonBox(width: 120, height: 12),
              const SizedBox(height: 10),
              const SkeletonBox(width: 200, height: 28),
              const SizedBox(height: 10),
              const SkeletonBox(width: 420, height: 16),
              const SizedBox(height: 28),
              const Row(
                children: [
                  Expanded(
                    child: PersonaPanel(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 80, height: 10),
                          SizedBox(height: 14),
                          SkeletonBox(width: 40, height: 28),
                          SizedBox(height: 6),
                          SkeletonBox(width: 160, height: 12),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: PersonaPanel(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 80, height: 10),
                          SizedBox(height: 14),
                          SkeletonBox(width: 40, height: 28),
                          SizedBox(height: 6),
                          SkeletonBox(width: 160, height: 12),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: PersonaPanel(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
              const PersonaPanel(
                child: Row(
                  children: [
                    Expanded(child: SkeletonBox(height: 40)),
                    SizedBox(width: 12),
                    Expanded(child: SkeletonBox(height: 40)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              PersonaPanel(
                child: Column(
                  children: List.generate(
                    5,
                    (_) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          SkeletonBox(width: 126, height: 28),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
          ),
        ),
      ),
    );
  }
}
