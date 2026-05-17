import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/tasks/domain/workflow_task.dart';
import '../domain/style_analysis_run.dart';
import '../domain/style_lab_repository.dart';
import '../domain/style_profile.dart';
import '../domain/style_sample.dart';

class DriftStyleLabRepository implements StyleLabRepository {
  const DriftStyleLabRepository(this._database);

  final AppDatabase _database;

  static const _uuid = Uuid();

  @override
  Stream<List<StyleSample>> watchSamples() {
    final query = _database.select(_database.styleSampleRecords)
      ..orderBy([
        (sample) =>
            OrderingTerm(expression: sample.updatedAt, mode: OrderingMode.desc),
      ]);
    return query.watch().map(
      (rows) => rows.map(_mapSample).toList(growable: false),
    );
  }

  @override
  Stream<StyleSample?> watchSample(String id) {
    final query = _database.select(_database.styleSampleRecords)
      ..where((sample) => sample.id.equals(id))
      ..limit(1);
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapSample(row),
    );
  }

  @override
  Future<StyleSample?> findSample(String id) async {
    final query = _database.select(_database.styleSampleRecords)
      ..where((sample) => sample.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapSample(row);
  }

  @override
  Future<StyleSample> saveSample(StyleSampleInput input) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    final normalizedContent = input.content.trim();
    final title = input.title.trim().isEmpty ? '未命名样本' : input.title.trim();

    await _database
        .into(_database.styleSampleRecords)
        .insert(
          StyleSampleRecordsCompanion.insert(
            id: id,
            sourceType: input.sourceType.name,
            title: title,
            content: normalizedContent,
            characterCount: normalizedContent.runes.length,
            projectId: Value(_blankToNull(input.projectId)),
            sourceFilename: Value(_blankToNull(input.sourceFilename)),
            epubBookTitle: Value(_blankToNull(input.epubBookTitle)),
            epubAuthor: Value(_blankToNull(input.epubAuthor)),
            epubChapterTitle: Value(_blankToNull(input.epubChapterTitle)),
            epubChapterIndex: Value(input.epubChapterIndex),
            createdAt: now,
            updatedAt: now,
          ),
        );

    final sample = await findSample(id);
    if (sample == null) {
      throw StateError('Style sample was not saved.');
    }
    return sample;
  }

  @override
  Stream<List<StyleAnalysisRun>> watchRecentRuns() {
    final query = _database.select(_database.styleAnalysisRunRecords)
      ..orderBy([
        (run) =>
            OrderingTerm(expression: run.updatedAt, mode: OrderingMode.desc),
      ])
      ..limit(20);
    return query.watch().map(
      (rows) => rows.map(_mapRun).toList(growable: false),
    );
  }

  @override
  Stream<StyleAnalysisRun?> watchRun(String id) {
    final query = _database.select(_database.styleAnalysisRunRecords)
      ..where((run) => run.id.equals(id))
      ..limit(1);
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapRun(row),
    );
  }

  @override
  Stream<StyleAnalysisRun?> watchRunByWorkflowTask(String workflowTaskId) {
    final query = _database.select(_database.styleAnalysisRunRecords)
      ..where((run) => run.workflowTaskId.equals(workflowTaskId))
      ..limit(1);
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapRun(row),
    );
  }

  @override
  Future<StyleAnalysisRun?> findRun(String id) async {
    final query = _database.select(_database.styleAnalysisRunRecords)
      ..where((run) => run.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapRun(row);
  }

  @override
  Future<StyleAnalysisRun> createRun(StyleAnalysisRunInput input) async {
    final now = DateTime.now();
    final runId = _uuid.v4();
    final taskId = _uuid.v4();
    final title = input.styleName.trim().isEmpty
        ? '风格分析任务'
        : '风格分析：${input.styleName.trim()}';

    await _database.transaction(() async {
      await _database
          .into(_database.workflowTaskRecords)
          .insert(
            WorkflowTaskRecordsCompanion.insert(
              id: taskId,
              kind: styleAnalysisWorkflowTaskKind,
              status: WorkflowTaskStatus.pending.name,
              title: title,
              stage: const Value('queued'),
              errorMessage: const Value(null),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _database
          .into(_database.styleAnalysisRunRecords)
          .insert(
            StyleAnalysisRunRecordsCompanion.insert(
              id: runId,
              workflowTaskId: taskId,
              sampleId: input.sampleId,
              providerId: input.providerId,
              modelName: input.modelName.trim(),
              styleName: input.styleName.trim(),
              projectId: Value(_blankToNull(input.projectId)),
              status: StyleAnalysisStatus.pending.name,
              stage: const Value(null),
              errorMessage: const Value(null),
              logs: const Value(''),
              analysisReportMarkdown: const Value(null),
              voiceProfileMarkdown: const Value(null),
              profileId: const Value(null),
              chunkCount: const Value(0),
              characterCount: input.characterCount,
              createdAt: now,
              updatedAt: now,
              startedAt: const Value(null),
              completedAt: const Value(null),
            ),
          );
    });

    final run = await findRun(runId);
    if (run == null) {
      throw StateError('Style analysis run was not created.');
    }
    return run;
  }

  @override
  Future<StyleAnalysisRun> createRunFromExisting(String id) async {
    final existing = await findRun(id);
    if (existing == null) {
      throw StateError('Style analysis run does not exist: $id');
    }
    return createRun(
      StyleAnalysisRunInput(
        sampleId: existing.sampleId,
        providerId: existing.providerId,
        modelName: existing.modelName,
        styleName: existing.styleName,
        characterCount: existing.characterCount,
        projectId: existing.projectId,
      ),
    );
  }

  @override
  Future<void> deleteRun(String id) async {
    final run = await findRun(id);
    if (run == null) {
      return;
    }
    await _database.transaction(() async {
      await (_database.delete(_database.workflowPromptTraceRecords)
            ..where((trace) => trace.workflowTaskId.equals(run.workflowTaskId)))
          .go();
      await (_database.delete(
        _database.styleProfileRecords,
      )..where((profile) => profile.sourceRunId.equals(id))).go();
      await (_database.delete(
        _database.styleAnalysisRunRecords,
      )..where((row) => row.id.equals(id))).go();
      await (_database.delete(
        _database.workflowTaskRecords,
      )..where((task) => task.id.equals(run.workflowTaskId))).go();
    });
  }

  @override
  Future<void> updateRunState({
    required String id,
    required StyleAnalysisStatus status,
    StyleAnalysisStage? stage,
    String? errorMessage,
    String? logs,
    String? analysisReportMarkdown,
    String? voiceProfileMarkdown,
    String? profileId,
    int? chunkCount,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    final run = await findRun(id);
    if (run == null) {
      throw StateError('Style analysis run does not exist: $id');
    }
    final now = DateTime.now();

    await _database.transaction(() async {
      await (_database.update(
        _database.styleAnalysisRunRecords,
      )..where((row) => row.id.equals(id))).write(
        StyleAnalysisRunRecordsCompanion(
          status: Value(status.name),
          stage: Value(stage?.name),
          errorMessage: Value(errorMessage),
          logs: logs == null ? const Value.absent() : Value(logs),
          analysisReportMarkdown: analysisReportMarkdown == null
              ? const Value.absent()
              : Value(analysisReportMarkdown),
          voiceProfileMarkdown: voiceProfileMarkdown == null
              ? const Value.absent()
              : Value(voiceProfileMarkdown),
          profileId: profileId == null
              ? const Value.absent()
              : Value(profileId),
          chunkCount: chunkCount == null
              ? const Value.absent()
              : Value(chunkCount),
          startedAt: startedAt == null
              ? const Value.absent()
              : Value(startedAt),
          completedAt: completedAt == null
              ? const Value.absent()
              : Value(completedAt),
          updatedAt: Value(now),
        ),
      );
      await _updateWorkflowTaskForRun(
        workflowTaskId: run.workflowTaskId,
        status: status,
        stage: stage,
        errorMessage: errorMessage,
        updatedAt: now,
      );
    });
  }

  @override
  Future<int> markInterruptedRunsFailed() async {
    final query = _database.select(_database.styleAnalysisRunRecords)
      ..where(
        (run) =>
            run.status.equals(StyleAnalysisStatus.running.name) |
            run.status.equals(StyleAnalysisStatus.pending.name),
      );
    final interrupted = await query.get();
    if (interrupted.isEmpty) {
      return 0;
    }

    final now = DateTime.now();
    await _database.transaction(() async {
      for (final run in interrupted) {
        const message = '应用重启，任务已中断，可重跑。';
        await (_database.update(
          _database.styleAnalysisRunRecords,
        )..where((row) => row.id.equals(run.id))).write(
          StyleAnalysisRunRecordsCompanion(
            status: Value(StyleAnalysisStatus.failed.name),
            stage: const Value(null),
            errorMessage: const Value(message),
            updatedAt: Value(now),
          ),
        );
        await _updateWorkflowTaskForRun(
          workflowTaskId: run.workflowTaskId,
          status: StyleAnalysisStatus.failed,
          stage: null,
          errorMessage: message,
          updatedAt: now,
        );
      }
    });
    return interrupted.length;
  }

  @override
  Stream<List<StyleProfile>> watchProfiles() {
    final query = _database.select(_database.styleProfileRecords)
      ..orderBy([
        (profile) => OrderingTerm(
          expression: profile.updatedAt,
          mode: OrderingMode.desc,
        ),
      ]);
    return query.watch().map(
      (rows) => rows.map(_mapProfile).toList(growable: false),
    );
  }

  @override
  Stream<StyleProfile?> watchProfile(String id) {
    final query = _database.select(_database.styleProfileRecords)
      ..where((profile) => profile.id.equals(id))
      ..limit(1);
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapProfile(row),
    );
  }

  @override
  Future<StyleProfile?> findProfile(String id) async {
    final query = _database.select(_database.styleProfileRecords)
      ..where((profile) => profile.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapProfile(row);
  }

  @override
  Future<StyleProfile> saveProfileFromRun(StyleProfileInput input) async {
    final run = await findRun(input.runId);
    if (run == null) {
      throw StateError('Style analysis run does not exist: ${input.runId}');
    }
    if (run.status != StyleAnalysisStatus.succeeded ||
        run.analysisReportMarkdown == null) {
      throw StateError('仅成功完成的分析任务可以保存为风格档案。');
    }
    final sample = await findSample(run.sampleId);
    final now = DateTime.now();
    final existingQuery = _database.select(_database.styleProfileRecords)
      ..where((profile) => profile.sourceRunId.equals(run.id))
      ..limit(1);
    final existing = await existingQuery.getSingleOrNull();
    final profileId = existing?.id ?? _uuid.v4();

    await _database.transaction(() async {
      await _database
          .into(_database.styleProfileRecords)
          .insertOnConflictUpdate(
            StyleProfileRecordsCompanion(
              id: Value(profileId),
              sourceRunId: Value(run.id),
              providerId: Value(run.providerId),
              modelName: Value(run.modelName),
              styleName: Value(input.styleName.trim()),
              profileMarkdown: Value(input.profileMarkdown.trim()),
              analysisReportMarkdown: Value(run.analysisReportMarkdown!),
              projectId: Value(_blankToNull(input.projectId)),
              sourceSampleId: Value(run.sampleId),
              sourceTitle: Value(sample?.title),
              createdAt: Value(existing?.createdAt ?? now),
              updatedAt: Value(now),
            ),
          );
      await (_database.update(
        _database.styleAnalysisRunRecords,
      )..where((row) => row.id.equals(run.id))).write(
        StyleAnalysisRunRecordsCompanion(
          profileId: Value(profileId),
          updatedAt: Value(now),
        ),
      );
    });

    final saved = await findProfile(profileId);
    if (saved == null) {
      throw StateError('Style profile was not saved.');
    }
    return saved;
  }

  @override
  Future<StyleProfile> updateProfile({
    required String id,
    required StyleProfileUpdateInput input,
  }) async {
    final existing = await findProfile(id);
    if (existing == null) {
      throw StateError('Style profile does not exist: $id');
    }
    await (_database.update(
      _database.styleProfileRecords,
    )..where((profile) => profile.id.equals(id))).write(
      StyleProfileRecordsCompanion(
        styleName: Value(input.styleName.trim()),
        profileMarkdown: Value(input.profileMarkdown.trim()),
        projectId: Value(_blankToNull(input.projectId)),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final updated = await findProfile(id);
    if (updated == null) {
      throw StateError('Style profile was not updated.');
    }
    return updated;
  }

  @override
  Future<void> deleteProfile(String id) async {
    final existing = await findProfile(id);
    if (existing == null) {
      return;
    }
    final run = await findRun(existing.sourceRunId);
    await _database.transaction(() async {
      await (_database.delete(
        _database.styleProfileRecords,
      )..where((profile) => profile.id.equals(id))).go();
      await (_database.delete(
        _database.styleAnalysisRunRecords,
      )..where((row) => row.id.equals(existing.sourceRunId))).go();
      if (run != null) {
        await (_database.delete(_database.workflowPromptTraceRecords)..where(
              (trace) => trace.workflowTaskId.equals(run.workflowTaskId),
            ))
            .go();
        await (_database.delete(
          _database.workflowTaskRecords,
        )..where((task) => task.id.equals(run.workflowTaskId))).go();
      }
    });
  }

  StyleSample _mapSample(StyleSampleRecord row) {
    return StyleSample(
      id: row.id,
      sourceType: StyleSampleSourceType.values.byName(row.sourceType),
      title: row.title,
      content: row.content,
      characterCount: row.characterCount,
      projectId: row.projectId,
      sourceFilename: row.sourceFilename,
      epubBookTitle: row.epubBookTitle,
      epubAuthor: row.epubAuthor,
      epubChapterTitle: row.epubChapterTitle,
      epubChapterIndex: row.epubChapterIndex,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  StyleAnalysisRun _mapRun(StyleAnalysisRunRecord row) {
    return StyleAnalysisRun(
      id: row.id,
      workflowTaskId: row.workflowTaskId,
      sampleId: row.sampleId,
      providerId: row.providerId,
      modelName: row.modelName,
      styleName: row.styleName,
      projectId: row.projectId,
      status: StyleAnalysisStatus.values.byName(row.status),
      stage: row.stage == null
          ? null
          : StyleAnalysisStage.values.byName(row.stage!),
      errorMessage: row.errorMessage,
      logs: row.logs,
      analysisReportMarkdown: row.analysisReportMarkdown,
      voiceProfileMarkdown: row.voiceProfileMarkdown,
      profileId: row.profileId,
      chunkCount: row.chunkCount,
      characterCount: row.characterCount,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
    );
  }

  StyleProfile _mapProfile(StyleProfileRecord row) {
    return StyleProfile(
      id: row.id,
      sourceRunId: row.sourceRunId,
      providerId: row.providerId,
      modelName: row.modelName,
      styleName: row.styleName,
      profileMarkdown: row.profileMarkdown,
      analysisReportMarkdown: row.analysisReportMarkdown,
      projectId: row.projectId,
      sourceSampleId: row.sourceSampleId,
      sourceTitle: row.sourceTitle,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  WorkflowTaskStatus _workflowStatus(StyleAnalysisStatus status) {
    return switch (status) {
      StyleAnalysisStatus.pending => WorkflowTaskStatus.pending,
      StyleAnalysisStatus.running => WorkflowTaskStatus.running,
      StyleAnalysisStatus.succeeded => WorkflowTaskStatus.succeeded,
      StyleAnalysisStatus.failed => WorkflowTaskStatus.failed,
    };
  }

  Future<void> _updateWorkflowTaskForRun({
    required String workflowTaskId,
    required StyleAnalysisStatus status,
    required StyleAnalysisStage? stage,
    required String? errorMessage,
    required DateTime updatedAt,
  }) {
    return (_database.update(
      _database.workflowTaskRecords,
    )..where((task) => task.id.equals(workflowTaskId))).write(
      WorkflowTaskRecordsCompanion(
        status: Value(_workflowStatus(status).name),
        stage: Value(stage?.name),
        errorMessage: Value(errorMessage),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
