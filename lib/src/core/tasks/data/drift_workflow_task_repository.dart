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

  @override
  Future<void> upsertTask(WorkflowTask task) {
    return _database
        .into(_database.workflowTaskRecords)
        .insertOnConflictUpdate(
          WorkflowTaskRecordsCompanion(
            id: Value(task.id),
            kind: Value(task.kind),
            status: Value(task.status.name),
            title: Value(task.title),
            stage: Value(task.stage),
            errorMessage: Value(task.errorMessage),
            createdAt: Value(task.createdAt),
            updatedAt: Value(task.updatedAt),
          ),
        );
  }

  @override
  Future<void> updateTask({
    required String id,
    required WorkflowTaskStatus status,
    String? stage,
    String? errorMessage,
  }) {
    return (_database.update(
      _database.workflowTaskRecords,
    )..where((task) => task.id.equals(id))).write(
      WorkflowTaskRecordsCompanion(
        status: Value(status.name),
        stage: Value(stage),
        errorMessage: Value(errorMessage),
        updatedAt: Value(DateTime.now()),
      ),
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
