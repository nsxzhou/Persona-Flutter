import 'package:flutter/material.dart';

import '../../../core/tasks/domain/workflow_task.dart';
import '../../../core/ui/persona_page.dart';
import 'workflow_run_row.dart';

class WorkflowRunTable extends StatelessWidget {
  const WorkflowRunTable({required this.tasks, super.key});

  final List<WorkflowTask> tasks;

  @override
  Widget build(BuildContext context) {
    return PersonaPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const WorkbenchSectionLabel('工作流活动', major: true),
                Text(
                  '用于分析、导入和生成任务的紧凑状态视图。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) =>
                  WorkflowRunRow(task: tasks[index]),
            ),
          ),
        ],
      ),
    );
  }
}
