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
    await _validateInput(input);
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
            defaultProviderId: Value(input.defaultProviderId.trim()),
            defaultModelName: Value(input.defaultModelName.trim()),
            styleProfileId: Value(_blankToNull(input.styleProfileId)),
            plotProfileId: Value(_blankToNull(input.plotProfileId)),
            language: Value(_normalizedLanguage(input.language)),
            targetLength: Value(_normalizedTargetLength(input.targetLength)),
            narrativePerspective: Value(
              _normalizedPerspective(input.narrativePerspective),
            ),
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
  Future<void> deleteProject(String id) async {
    await (_database.delete(
      _database.projectRecords,
    )..where((project) => project.id.equals(id))).go();
  }

  WritingProject _mapRecord(ProjectRecord row) {
    return WritingProject(
      id: row.id,
      title: row.title,
      description: row.description,
      status: ProjectStatus.values.byName(row.status),
      defaultProviderId: row.defaultProviderId,
      defaultModelName: row.defaultModelName,
      styleProfileId: row.styleProfileId,
      plotProfileId: row.plotProfileId,
      language: row.language,
      targetLength: row.targetLength,
      narrativePerspective: row.narrativePerspective,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Future<void> _validateInput(WritingProjectInput input) async {
    if (input.title.trim().isEmpty) {
      throw StateError('项目标题不能为空。');
    }
    final providerId = input.defaultProviderId.trim();
    if (providerId.isEmpty) {
      throw StateError('项目需要选择默认 Provider。');
    }
    final providerQuery = _database.select(_database.providerConfigRecords)
      ..where((provider) => provider.id.equals(providerId))
      ..limit(1);
    final provider = await providerQuery.getSingleOrNull();
    if (provider == null) {
      throw StateError('默认 Provider 不存在。');
    }

    final modelName = input.defaultModelName.trim();
    if (modelName.isEmpty) {
      throw StateError('项目需要选择默认模型。');
    }
    final modelQuery = _database.select(_database.providerModelRecords)
      ..where(
        (model) =>
            model.providerId.equals(providerId) &
            model.modelName.equals(modelName),
      )
      ..limit(1);
    final model = await modelQuery.getSingleOrNull();
    if (model == null && provider.defaultModel != modelName) {
      throw StateError('默认模型不属于所选 Provider。');
    }

    await _validateStyleProfile(_blankToNull(input.styleProfileId));
    await _validatePlotProfile(_blankToNull(input.plotProfileId));
    _normalizedTargetLength(input.targetLength);
  }

  Future<void> _validateStyleProfile(String? id) async {
    if (id == null) {
      return;
    }
    final query = _database.select(_database.styleProfileRecords)
      ..where((profile) => profile.id.equals(id))
      ..limit(1);
    final profile = await query.getSingleOrNull();
    if (profile == null) {
      throw StateError('Style Profile 不存在。');
    }
  }

  Future<void> _validatePlotProfile(String? id) async {
    if (id == null) {
      return;
    }
    final query = _database.select(_database.plotProfileRecords)
      ..where((profile) => profile.id.equals(id))
      ..limit(1);
    final profile = await query.getSingleOrNull();
    if (profile == null) {
      throw StateError('Plot Profile 不存在。');
    }
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

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  String _normalizedLanguage(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? defaultProjectLanguage : trimmed;
  }

  int _normalizedTargetLength(int value) {
    if (value <= 0) {
      throw StateError('目标长度必须大于 0。');
    }
    return value;
  }

  String _normalizedPerspective(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? defaultProjectNarrativePerspective : trimmed;
  }
}
