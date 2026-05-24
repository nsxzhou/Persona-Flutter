import 'package:flutter/material.dart';

import '../../../core/tasks/domain/workflow_task.dart';
import '../../../core/ui/persona_page.dart';
import 'workflow_run_helpers.dart';

class WorkflowRunFilters extends StatelessWidget {
  const WorkflowRunFilters({
    required this.items,
    required this.kindFilter,
    required this.onKindChanged,
    super.key,
  });

  final List<WorkflowTask> items;
  final String? kindFilter;
  final ValueChanged<String?> onKindChanged;

  @override
  Widget build(BuildContext context) {
    final kinds = items.map((item) => item.kind).toSet().toList()
      ..sort((a, b) => kindLabel(a).compareTo(kindLabel(b)));
    return PersonaPanel(
      padding: const EdgeInsets.all(14),
      child: DropdownButtonFormField<String?>(
        initialValue: kindFilter,
        decoration: const InputDecoration(
          labelText: '任务类型',
          isDense: true,
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem(value: null, child: Text('全部类型')),
          for (final kind in kinds)
            DropdownMenuItem(value: kind, child: Text(kindLabel(kind))),
        ],
        onChanged: onKindChanged,
      ),
    );
  }
}
