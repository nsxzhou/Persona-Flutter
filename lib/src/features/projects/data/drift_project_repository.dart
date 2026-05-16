import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/project_repository.dart';
import '../domain/writing_project.dart';

class DriftProjectRepository implements ProjectRepository {
  const DriftProjectRepository(this._database);

  final AppDatabase _database;

  static const _uuid = Uuid();

  @override
  Stream<List<WritingProject>> watchProjects(ProjectStatus status) {
    final query = _database.select(_database.projectRecords)
      ..where((project) => project.status.equals(status.name))
      ..orderBy([
        (project) => OrderingTerm(
          expression: project.updatedAt,
          mode: OrderingMode.desc,
        ),
      ]);

    return query.watch().map(
      (rows) => rows.map(_mapRecord).toList(growable: false),
    );
  }

  @override
  Stream<WritingProject?> watchProject(String id) {
    final query = _database.select(_database.projectRecords)
      ..where((project) => project.id.equals(id))
      ..limit(1);
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapRecord(row),
    );
  }

  @override
  Future<WritingProject?> findProject(String id) async {
    final query = _database.select(_database.projectRecords)
      ..where((project) => project.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapRecord(row);
  }

  @override
  Future<void> saveProject({
    String? id,
    required WritingProjectInput input,
  }) async {
    final now = DateTime.now();
    final normalizedId = id ?? _uuid.v4();
    final existing = id == null ? null : await findProject(id);
    final updatedAt = _nextUpdatedAt(now: now, existing: existing);

    await _database
        .into(_database.projectRecords)
        .insertOnConflictUpdate(
          ProjectRecordsCompanion(
            id: Value(normalizedId),
            title: Value(input.title.trim()),
            description: Value(input.description.trim()),
            status: Value(input.status.name),
            createdAt: Value(existing?.createdAt ?? now),
            updatedAt: Value(updatedAt),
          ),
        );
  }

  @override
  Future<void> updateStatus({
    required String id,
    required ProjectStatus status,
  }) async {
    final existing = await findProject(id);
    final updatedAt = _nextUpdatedAt(now: DateTime.now(), existing: existing);

    await (_database.update(
      _database.projectRecords,
    )..where((project) => project.id.equals(id))).write(
      ProjectRecordsCompanion(
        status: Value(status.name),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  @override
  Future<void> deleteProject(String id) {
    return (_database.delete(
      _database.projectRecords,
    )..where((project) => project.id.equals(id))).go();
  }

  WritingProject _mapRecord(ProjectRecord row) {
    return WritingProject(
      id: row.id,
      title: row.title,
      description: row.description,
      status: ProjectStatus.values.byName(row.status),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  DateTime _nextUpdatedAt({
    required DateTime now,
    required WritingProject? existing,
  }) {
    if (existing == null) {
      return now;
    }
    final minimumNext = existing.updatedAt.add(const Duration(seconds: 1));
    return now.isAfter(minimumNext) ? now : minimumNext;
  }
}
