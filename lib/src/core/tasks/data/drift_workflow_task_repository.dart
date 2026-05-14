import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../application/workflow_task_repository.dart';
import '../domain/workflow_task.dart';

class DriftWorkflowTaskRepository implements WorkflowTaskRepository {
  const DriftWorkflowTaskRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<WorkflowTask>> watchRecentTasks() {
    final query = _database.select(_database.workflowTaskRecords)
      ..orderBy([
        (task) =>
            OrderingTerm(expression: task.updatedAt, mode: OrderingMode.desc),
      ])
      ..limit(20);

    return query.watch().map(
      (rows) => rows.map(_mapRecord).toList(growable: false),
    );
  }

  WorkflowTask _mapRecord(WorkflowTaskRecord row) {
    return WorkflowTask(
      id: row.id,
      kind: row.kind,
      status: WorkflowTaskStatus.values.byName(row.status),
      title: row.title,
      stage: row.stage,
      errorMessage: row.errorMessage,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
