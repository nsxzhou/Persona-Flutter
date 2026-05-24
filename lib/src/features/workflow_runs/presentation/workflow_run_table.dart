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
          const Padding(
            padding: EdgeInsets.all(18),
            child: PersonaSectionHeader(
              title: '工作流活动',
              description: '用于分析、导入和生成任务的紧凑状态视图。',
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
