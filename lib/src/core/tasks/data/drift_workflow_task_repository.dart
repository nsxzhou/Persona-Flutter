import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../application/workflow_task_repository.dart';
import '../domain/workflow_prompt_trace.dart';
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
  Stream<WorkflowTask?> watchTask(String id) {
    final query = _database.select(_database.workflowTaskRecords)
      ..where((task) => task.id.equals(id))
      ..limit(1);
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapRecord(row),
    );
  }

  @override
  Future<WorkflowTask?> findTask(String id) async {
    final query = _database.select(_database.workflowTaskRecords)
      ..where((task) => task.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapRecord(row);
  }

  @override
  Future<void> abandonTask(String id) async {
    final now = DateTime.now();
    await _database.transaction(() async {
      final updated =
          await (_database.update(_database.workflowTaskRecords)..where(
                (task) =>
                    task.id.equals(id) &
                    task.status.isIn([
                      WorkflowTaskStatus.pending.name,
                      WorkflowTaskStatus.running.name,
                    ]),
              ))
              .write(
                WorkflowTaskRecordsCompanion(
                  status: Value(WorkflowTaskStatus.abandoned.name),
                  stage: const Value(null),
                  errorMessage: const Value(null),
                  updatedAt: Value(now),
                ),
              );
      if (updated == 0) {
        return;
      }
      await (_database.delete(
        _database.workflowPromptTraceRecords,
      )..where((trace) => trace.workflowTaskId.equals(id))).go();
    });
  }

  @override
  Stream<WorkflowPromptTrace?> watchPromptTrace(String workflowTaskId) {
    final query = _database.select(_database.workflowPromptTraceRecords)
      ..where((trace) => trace.workflowTaskId.equals(workflowTaskId))
      ..limit(1);
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapTrace(row),
    );
  }

  @override
  Future<void> upsertPromptTrace({
    required String workflowTaskId,
    required String traceMarkdown,
  }) async {
    final now = DateTime.now();
    final existingQuery = _database.select(_database.workflowPromptTraceRecords)
      ..where((trace) => trace.workflowTaskId.equals(workflowTaskId))
      ..limit(1);
    final existing = await existingQuery.getSingleOrNull();
    await _database
        .into(_database.workflowPromptTraceRecords)
        .insertOnConflictUpdate(
          WorkflowPromptTraceRecordsCompanion.insert(
            workflowTaskId: workflowTaskId,
            traceMarkdown: traceMarkdown,
            createdAt: existing?.createdAt ?? now,
            updatedAt: now,
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

  WorkflowPromptTrace _mapTrace(WorkflowPromptTraceRecord row) {
    return WorkflowPromptTrace(
      workflowTaskId: row.workflowTaskId,
      traceMarkdown: row.traceMarkdown,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
