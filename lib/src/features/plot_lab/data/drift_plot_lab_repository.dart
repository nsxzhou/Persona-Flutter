import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/tasks/domain/workflow_task.dart';
import '../domain/plot_analysis_run.dart';
import '../domain/plot_lab_repository.dart';
import '../domain/plot_profile.dart';
import '../domain/plot_sample.dart';

class DriftPlotLabRepository implements PlotLabRepository {
  const DriftPlotLabRepository(this._database);

  final AppDatabase _database;

  static const _uuid = Uuid();

  @override
  Stream<List<PlotSample>> watchSamples() {
    final query = _database.select(_database.plotSampleRecords)
      ..orderBy([
        (sample) =>
            OrderingTerm(expression: sample.updatedAt, mode: OrderingMode.desc),
      ]);
    return query.watch().map(
      (rows) => rows.map(_mapSample).toList(growable: false),
    );
  }

  @override
  Stream<PlotSample?> watchSample(String id) {
    final query = _database.select(_database.plotSampleRecords)
      ..where((sample) => sample.id.equals(id))
      ..limit(1);
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapSample(row),
    );
  }

  @override
  Future<PlotSample?> findSample(String id) async {
    final query = _database.select(_database.plotSampleRecords)
      ..where((sample) => sample.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapSample(row);
  }

  @override
  Future<PlotSample> saveSample(PlotSampleInput input) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    final normalizedContent = input.content.trim();
    if (normalizedContent.isEmpty) {
      throw StateError('剧情样本没有可保存的正文。');
    }
    final title = input.title.trim().isEmpty ? '未命名剧情样本' : input.title.trim();

    await _database
        .into(_database.plotSampleRecords)
        .insert(
          PlotSampleRecordsCompanion.insert(
            id: id,
            sourceType: input.sourceType.name,
            title: title,
            content: normalizedContent,
            characterCount: normalizedContent.runes.length,
            sourceFilename: Value(_blankToNull(input.sourceFilename)),
            epubBookTitle: Value(_blankToNull(input.epubBookTitle)),
            epubAuthor: Value(_blankToNull(input.epubAuthor)),
            epubChapterCount: Value(input.epubChapterCount),
            createdAt: now,
            updatedAt: now,
          ),
        );

    final sample = await findSample(id);
    if (sample == null) {
      throw StateError('Plot sample was not saved.');
    }
    return sample;
  }

  @override
  Stream<List<PlotAnalysisRun>> watchRecentRuns() {
    final query = _database.select(_database.plotAnalysisRunRecords)
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
  Stream<PlotAnalysisRun?> watchRun(String id) {
    final query = _database.select(_database.plotAnalysisRunRecords)
      ..where((run) => run.id.equals(id))
      ..limit(1);
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapRun(row),
    );
  }

  @override
  Stream<PlotAnalysisRun?> watchRunByWorkflowTask(String workflowTaskId) {
    final query = _database.select(_database.plotAnalysisRunRecords)
      ..where((run) => run.workflowTaskId.equals(workflowTaskId))
      ..limit(1);
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapRun(row),
    );
  }

  @override
  Future<PlotAnalysisRun?> findRun(String id) async {
    final query = _database.select(_database.plotAnalysisRunRecords)
      ..where((run) => run.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapRun(row);
  }

  @override
  Future<PlotAnalysisRun> createRun(PlotAnalysisRunInput input) async {
    final now = DateTime.now();
    final runId = _uuid.v4();
    final taskId = _uuid.v4();
    final plotName = input.plotName.trim().isEmpty
        ? '未命名剧情档案'
        : input.plotName.trim();
    final title = '剧情分析：$plotName';

    await _database.transaction(() async {
      await _database
          .into(_database.workflowTaskRecords)
          .insert(
            WorkflowTaskRecordsCompanion.insert(
              id: taskId,
              kind: plotAnalysisWorkflowTaskKind,
              status: WorkflowTaskStatus.pending.name,
              title: title,
              stage: const Value('queued'),
              errorMessage: const Value(null),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _database
          .into(_database.plotAnalysisRunRecords)
          .insert(
            PlotAnalysisRunRecordsCompanion.insert(
              id: runId,
              workflowTaskId: taskId,
              sampleId: input.sampleId,
              providerId: input.providerId,
              modelName: input.modelName.trim(),
              plotName: plotName,
              status: PlotAnalysisStatus.pending.name,
              stage: const Value(null),
              errorMessage: const Value(null),
              logs: const Value(''),
              analysisReportMarkdown: const Value(null),
              plotSkeletonMarkdown: const Value(null),
              storyEngineMarkdown: const Value(null),
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
      throw StateError('Plot analysis run was not created.');
    }
    return run;
  }

  @override
  Future<PlotAnalysisRun> createRunFromExisting(String id) async {
    final existing = await findRun(id);
    if (existing == null) {
      throw StateError('Plot analysis run does not exist: $id');
    }
    return createRun(
      PlotAnalysisRunInput(
        sampleId: existing.sampleId,
        providerId: existing.providerId,
        modelName: existing.modelName,
        plotName: existing.plotName,
        characterCount: existing.characterCount,
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
      await (_database.delete(
        _database.plotProfileRecords,
      )..where((profile) => profile.sourceRunId.equals(id))).go();
      await (_database.delete(
        _database.plotAnalysisRunRecords,
      )..where((row) => row.id.equals(id))).go();
      await (_database.delete(
        _database.workflowTaskRecords,
      )..where((task) => task.id.equals(run.workflowTaskId))).go();
    });
  }

  @override
  Future<void> updateRunState({
    required String id,
    required PlotAnalysisStatus status,
    PlotAnalysisStage? stage,
    String? errorMessage,
    String? logs,
    String? analysisReportMarkdown,
    String? plotSkeletonMarkdown,
    String? storyEngineMarkdown,
    String? profileId,
    int? chunkCount,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    final run = await findRun(id);
    if (run == null) {
      throw StateError('Plot analysis run does not exist: $id');
    }
    final now = DateTime.now();
    final taskStatus = _workflowStatus(status);

    await _database.transaction(() async {
      await (_database.update(
        _database.plotAnalysisRunRecords,
      )..where((row) => row.id.equals(id))).write(
        PlotAnalysisRunRecordsCompanion(
          status: Value(status.name),
          stage: Value(stage?.name),
          errorMessage: Value(errorMessage),
          logs: logs == null ? const Value.absent() : Value(logs),
          analysisReportMarkdown: analysisReportMarkdown == null
              ? const Value.absent()
              : Value(analysisReportMarkdown),
          plotSkeletonMarkdown: plotSkeletonMarkdown == null
              ? const Value.absent()
              : Value(plotSkeletonMarkdown),
          storyEngineMarkdown: storyEngineMarkdown == null
              ? const Value.absent()
              : Value(storyEngineMarkdown),
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
      await (_database.update(
        _database.workflowTaskRecords,
      )..where((task) => task.id.equals(run.workflowTaskId))).write(
        WorkflowTaskRecordsCompanion(
          status: Value(taskStatus.name),
          stage: Value(stage?.name),
          errorMessage: Value(errorMessage),
          updatedAt: Value(now),
        ),
      );
    });
  }

  @override
  Future<int> markInterruptedRunsFailed() async {
    final query = _database.select(_database.plotAnalysisRunRecords)
      ..where(
        (run) =>
            run.status.equals(PlotAnalysisStatus.running.name) |
            run.status.equals(PlotAnalysisStatus.pending.name),
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
          _database.plotAnalysisRunRecords,
        )..where((row) => row.id.equals(run.id))).write(
          PlotAnalysisRunRecordsCompanion(
            status: Value(PlotAnalysisStatus.failed.name),
            stage: const Value(null),
            errorMessage: const Value(message),
            updatedAt: Value(now),
          ),
        );
        await (_database.update(
          _database.workflowTaskRecords,
        )..where((task) => task.id.equals(run.workflowTaskId))).write(
          WorkflowTaskRecordsCompanion(
            status: Value(WorkflowTaskStatus.failed.name),
            stage: const Value(null),
            errorMessage: const Value(message),
            updatedAt: Value(now),
          ),
        );
      }
    });
    return interrupted.length;
  }

  @override
  Stream<List<PlotProfile>> watchProfiles() {
    final query = _database.select(_database.plotProfileRecords)
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
  Stream<PlotProfile?> watchProfile(String id) {
    final query = _database.select(_database.plotProfileRecords)
      ..where((profile) => profile.id.equals(id))
      ..limit(1);
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapProfile(row),
    );
  }

  @override
  Future<PlotProfile?> findProfile(String id) async {
    final query = _database.select(_database.plotProfileRecords)
      ..where((profile) => profile.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapProfile(row);
  }

  @override
  Future<PlotProfile> saveProfileFromRun(PlotProfileInput input) async {
    final run = await findRun(input.runId);
    if (run == null) {
      throw StateError('Plot analysis run does not exist: ${input.runId}');
    }
    if (run.status != PlotAnalysisStatus.succeeded ||
        run.analysisReportMarkdown == null ||
        run.plotSkeletonMarkdown == null ||
        run.storyEngineMarkdown == null) {
      throw StateError('仅成功完成的分析任务可以保存为剧情档案。');
    }
    final sample = await findSample(run.sampleId);
    final now = DateTime.now();
    final existingQuery = _database.select(_database.plotProfileRecords)
      ..where((profile) => profile.sourceRunId.equals(run.id))
      ..limit(1);
    final existing = await existingQuery.getSingleOrNull();
    final profileId = existing?.id ?? _uuid.v4();
    final plotName = input.plotName.trim().isEmpty
        ? run.plotName
        : input.plotName.trim();

    await _database.transaction(() async {
      await _database
          .into(_database.plotProfileRecords)
          .insertOnConflictUpdate(
            PlotProfileRecordsCompanion(
              id: Value(profileId),
              sourceRunId: Value(run.id),
              providerId: Value(run.providerId),
              modelName: Value(run.modelName),
              plotName: Value(plotName),
              storyEngineMarkdown: Value(input.storyEngineMarkdown.trim()),
              analysisReportMarkdown: Value(run.analysisReportMarkdown!),
              plotSkeletonMarkdown: Value(run.plotSkeletonMarkdown!),
              sourceSampleId: Value(run.sampleId),
              sourceTitle: Value(sample?.title),
              createdAt: Value(existing?.createdAt ?? now),
              updatedAt: Value(now),
            ),
          );
      await (_database.update(
        _database.plotAnalysisRunRecords,
      )..where((row) => row.id.equals(run.id))).write(
        PlotAnalysisRunRecordsCompanion(
          profileId: Value(profileId),
          updatedAt: Value(now),
        ),
      );
    });

    final saved = await findProfile(profileId);
    if (saved == null) {
      throw StateError('Plot profile was not saved.');
    }
    return saved;
  }

  @override
  Future<PlotProfile> updateProfile({
    required String id,
    required PlotProfileUpdateInput input,
  }) async {
    final existing = await findProfile(id);
    if (existing == null) {
      throw StateError('Plot profile does not exist: $id');
    }
    final storyEngine = input.storyEngineMarkdown.trim();
    if (storyEngine.isEmpty) {
      throw StateError('Story Engine 不能为空。');
    }
    await (_database.update(
      _database.plotProfileRecords,
    )..where((profile) => profile.id.equals(id))).write(
      PlotProfileRecordsCompanion(
        plotName: Value(input.plotName.trim()),
        storyEngineMarkdown: Value(storyEngine),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final updated = await findProfile(id);
    if (updated == null) {
      throw StateError('Plot profile was not updated.');
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
        _database.plotProfileRecords,
      )..where((profile) => profile.id.equals(id))).go();
      await (_database.delete(
        _database.plotAnalysisRunRecords,
      )..where((row) => row.id.equals(existing.sourceRunId))).go();
      if (run != null) {
        await (_database.delete(
          _database.workflowTaskRecords,
        )..where((task) => task.id.equals(run.workflowTaskId))).go();
      }
    });
  }

  PlotSample _mapSample(PlotSampleRecord row) {
    return PlotSample(
      id: row.id,
      sourceType: PlotSampleSourceType.values.byName(row.sourceType),
      title: row.title,
      content: row.content,
      characterCount: row.characterCount,
      sourceFilename: row.sourceFilename,
      epubBookTitle: row.epubBookTitle,
      epubAuthor: row.epubAuthor,
      epubChapterCount: row.epubChapterCount,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  PlotAnalysisRun _mapRun(PlotAnalysisRunRecord row) {
    return PlotAnalysisRun(
      id: row.id,
      workflowTaskId: row.workflowTaskId,
      sampleId: row.sampleId,
      providerId: row.providerId,
      modelName: row.modelName,
      plotName: row.plotName,
      status: PlotAnalysisStatus.values.byName(row.status),
      stage: row.stage == null
          ? null
          : PlotAnalysisStage.values.byName(row.stage!),
      errorMessage: row.errorMessage,
      logs: row.logs,
      analysisReportMarkdown: row.analysisReportMarkdown,
      plotSkeletonMarkdown: row.plotSkeletonMarkdown,
      storyEngineMarkdown: row.storyEngineMarkdown,
      profileId: row.profileId,
      chunkCount: row.chunkCount,
      characterCount: row.characterCount,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
    );
  }

  PlotProfile _mapProfile(PlotProfileRecord row) {
    return PlotProfile(
      id: row.id,
      sourceRunId: row.sourceRunId,
      providerId: row.providerId,
      modelName: row.modelName,
      plotName: row.plotName,
      storyEngineMarkdown: row.storyEngineMarkdown,
      analysisReportMarkdown: row.analysisReportMarkdown,
      plotSkeletonMarkdown: row.plotSkeletonMarkdown,
      sourceSampleId: row.sourceSampleId,
      sourceTitle: row.sourceTitle,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  WorkflowTaskStatus _workflowStatus(PlotAnalysisStatus status) {
    return switch (status) {
      PlotAnalysisStatus.pending => WorkflowTaskStatus.pending,
      PlotAnalysisStatus.running => WorkflowTaskStatus.running,
      PlotAnalysisStatus.succeeded => WorkflowTaskStatus.succeeded,
      PlotAnalysisStatus.failed => WorkflowTaskStatus.failed,
    };
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
