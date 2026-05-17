import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/tasks/domain/workflow_task.dart';
import '../domain/accepted_chapter.dart';
import '../domain/chapter_draft_run.dart';
import '../domain/chapter_plan.dart';
import '../domain/memory_projection.dart';
import '../domain/novel_workshop_repository.dart';
import '../domain/story_bible.dart';

class DriftNovelWorkshopRepository implements NovelWorkshopRepository {
  const DriftNovelWorkshopRepository(this._database);

  final AppDatabase _database;

  static const _uuid = Uuid();

  @override
  Stream<StoryBible?> watchStoryBible(String projectId) {
    final query = _database.select(_database.storyBibleRecords)
      ..where((bible) => bible.projectId.equals(projectId))
      ..limit(1);
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapStoryBible(row),
    );
  }

  @override
  Future<StoryBible?> findStoryBible(String projectId) async {
    final query = _database.select(_database.storyBibleRecords)
      ..where((bible) => bible.projectId.equals(projectId))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapStoryBible(row);
  }

  @override
  Future<StoryBible> upsertStoryBible(StoryBibleInput input) async {
    await _ensureProjectExists(input.projectId);
    final now = DateTime.now();
    final existing = await findStoryBible(input.projectId);
    final id = existing?.id ?? _uuid.v4();

    await _database
        .into(_database.storyBibleRecords)
        .insertOnConflictUpdate(
          StoryBibleRecordsCompanion(
            id: Value(id),
            projectId: Value(input.projectId),
            authorIntent: Value(input.authorIntent.trim()),
            currentFocus: Value(input.currentFocus.trim()),
            worldMarkdown: Value(input.worldMarkdown.trim()),
            charactersMarkdown: Value(input.charactersMarkdown.trim()),
            rulesMarkdown: Value(input.rulesMarkdown.trim()),
            createdAt: Value(existing?.createdAt ?? now),
            updatedAt: Value(now),
          ),
        );

    final saved = await findStoryBible(input.projectId);
    if (saved == null) {
      throw StateError('Story Bible was not saved.');
    }
    return saved;
  }

  @override
  Stream<List<ChapterPlan>> watchChapterPlans(String projectId) {
    final query = _database.select(_database.chapterPlanRecords)
      ..where((plan) => plan.projectId.equals(projectId))
      ..orderBy([
        (plan) => OrderingTerm(expression: plan.chapterIndex),
        (plan) => OrderingTerm(expression: plan.updatedAt),
      ]);
    return query.watch().map(
      (rows) => rows.map(_mapChapterPlan).toList(growable: false),
    );
  }

  @override
  Future<List<ChapterPlan>> findChapterPlans(String projectId) async {
    final query = _database.select(_database.chapterPlanRecords)
      ..where((plan) => plan.projectId.equals(projectId))
      ..orderBy([
        (plan) => OrderingTerm(expression: plan.chapterIndex),
        (plan) => OrderingTerm(expression: plan.updatedAt),
      ]);
    final rows = await query.get();
    return rows.map(_mapChapterPlan).toList(growable: false);
  }

  @override
  Stream<ChapterPlan?> watchChapterPlan(String id) {
    final query = _database.select(_database.chapterPlanRecords)
      ..where((plan) => plan.id.equals(id))
      ..limit(1);
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapChapterPlan(row),
    );
  }

  @override
  Future<ChapterPlan?> findChapterPlan(String id) async {
    final query = _database.select(_database.chapterPlanRecords)
      ..where((plan) => plan.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapChapterPlan(row);
  }

  @override
  Future<ChapterPlan> saveChapterPlan({
    String? id,
    required ChapterPlanInput input,
  }) async {
    await _ensureProjectExists(input.projectId);
    if (input.chapterIndex <= 0) {
      throw StateError('章节序号必须大于 0。');
    }
    final now = DateTime.now();
    final existing = id == null ? null : await findChapterPlan(id);
    final planId = id ?? _uuid.v4();

    await _database
        .into(_database.chapterPlanRecords)
        .insertOnConflictUpdate(
          ChapterPlanRecordsCompanion(
            id: Value(planId),
            projectId: Value(input.projectId),
            chapterIndex: Value(input.chapterIndex),
            title: Value(_normalizedChapterTitle(input)),
            goal: Value(input.goal.trim()),
            targetBeat: Value(input.targetBeat.trim()),
            mustInclude: Value(input.mustInclude.trim()),
            mustAvoid: Value(input.mustAvoid.trim()),
            hook: Value(input.hook.trim()),
            payoff: Value(input.payoff.trim()),
            status: Value(input.status.name),
            createdAt: Value(existing?.createdAt ?? now),
            updatedAt: Value(now),
          ),
        );

    final saved = await findChapterPlan(planId);
    if (saved == null) {
      throw StateError('Chapter plan was not saved.');
    }
    return saved;
  }

  @override
  Future<void> deleteChapterPlan(String id) async {
    final plan = await findChapterPlan(id);
    if (plan == null) {
      return;
    }
    final runs = await (_database.select(
      _database.chapterDraftRunRecords,
    )..where((run) => run.chapterPlanId.equals(id))).get();
    final acceptedChapters = await (_database.select(
      _database.acceptedChapterRecords,
    )..where((chapter) => chapter.chapterPlanId.equals(id))).get();
    final acceptedChapterIds = acceptedChapters.map((chapter) => chapter.id);

    await _database.transaction(() async {
      for (final run in runs) {
        await (_database.delete(_database.workflowPromptTraceRecords)..where(
              (trace) => trace.workflowTaskId.equals(run.workflowTaskId),
            ))
            .go();
      }
      if (acceptedChapterIds.isNotEmpty) {
        await (_database.update(_database.memoryProjectionRecords)..where(
              (projection) =>
                  projection.updatedFromChapterId.isIn(acceptedChapterIds),
            ))
            .write(
              const MemoryProjectionRecordsCompanion(
                updatedFromChapterId: Value(null),
              ),
            );
      }
      await (_database.delete(
        _database.acceptedChapterRecords,
      )..where((chapter) => chapter.chapterPlanId.equals(id))).go();
      await (_database.delete(
        _database.chapterDraftRunRecords,
      )..where((run) => run.chapterPlanId.equals(id))).go();
      for (final run in runs) {
        await (_database.delete(
          _database.workflowTaskRecords,
        )..where((task) => task.id.equals(run.workflowTaskId))).go();
      }
      await (_database.delete(
        _database.chapterPlanRecords,
      )..where((row) => row.id.equals(id))).go();
    });
  }

  @override
  Stream<List<ChapterDraftRun>> watchChapterDraftRuns(String chapterPlanId) {
    final query = _database.select(_database.chapterDraftRunRecords)
      ..where((run) => run.chapterPlanId.equals(chapterPlanId))
      ..orderBy([
        (run) =>
            OrderingTerm(expression: run.updatedAt, mode: OrderingMode.desc),
      ]);
    return query.watch().map(
      (rows) => rows.map(_mapChapterDraftRun).toList(growable: false),
    );
  }

  @override
  Stream<ChapterDraftRun?> watchChapterDraftRun(String id) {
    final query = _database.select(_database.chapterDraftRunRecords)
      ..where((run) => run.id.equals(id))
      ..limit(1);
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapChapterDraftRun(row),
    );
  }

  @override
  Future<ChapterDraftRun?> findChapterDraftRun(String id) async {
    final query = _database.select(_database.chapterDraftRunRecords)
      ..where((run) => run.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapChapterDraftRun(row);
  }

  @override
  Future<ChapterDraftRun> createChapterDraftRun(
    ChapterDraftRunInput input,
  ) async {
    final project = await _ensureProjectExists(input.projectId);
    final plan = await findChapterPlan(input.chapterPlanId);
    if (plan == null || plan.projectId != input.projectId) {
      throw StateError('Chapter plan does not belong to the project.');
    }
    await _ensureProviderModel(input.providerId, input.modelName);

    final now = DateTime.now();
    final runId = _uuid.v4();
    final taskId = _uuid.v4();
    final title = '章节生成：${project.title} · 第 ${plan.chapterIndex} 章';

    await _database.transaction(() async {
      await _database
          .into(_database.workflowTaskRecords)
          .insert(
            WorkflowTaskRecordsCompanion.insert(
              id: taskId,
              kind: chapterDraftWorkflowTaskKind,
              status: WorkflowTaskStatus.pending.name,
              title: title,
              stage: const Value('queued'),
              errorMessage: const Value(null),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _database
          .into(_database.chapterDraftRunRecords)
          .insert(
            ChapterDraftRunRecordsCompanion.insert(
              id: runId,
              workflowTaskId: taskId,
              projectId: input.projectId,
              chapterPlanId: input.chapterPlanId,
              providerId: input.providerId,
              modelName: input.modelName.trim(),
              status: ChapterDraftRunStatus.pending.name,
              stage: const Value(null),
              contractMarkdown: const Value(''),
              draftMarkdown: const Value(''),
              auditMarkdown: const Value(''),
              revisedMarkdown: const Value(''),
              errorMessage: const Value(null),
              logs: const Value(''),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await (_database.update(
        _database.chapterPlanRecords,
      )..where((row) => row.id.equals(plan.id))).write(
        ChapterPlanRecordsCompanion(
          status: Value(ChapterPlanStatus.drafting.name),
          updatedAt: Value(now),
        ),
      );
    });

    final run = await findChapterDraftRun(runId);
    if (run == null) {
      throw StateError('Chapter draft run was not created.');
    }
    return run;
  }

  @override
  Future<void> updateChapterDraftRunState({
    required String id,
    required ChapterDraftRunStatus status,
    ChapterDraftRunStage? stage,
    String? errorMessage,
    String? logs,
    String? contractMarkdown,
    String? draftMarkdown,
    String? auditMarkdown,
    String? revisedMarkdown,
  }) async {
    final run = await findChapterDraftRun(id);
    if (run == null) {
      throw StateError('Chapter draft run does not exist: $id');
    }
    final now = DateTime.now();

    await _database.transaction(() async {
      await (_database.update(
        _database.chapterDraftRunRecords,
      )..where((row) => row.id.equals(id))).write(
        ChapterDraftRunRecordsCompanion(
          status: Value(status.name),
          stage: Value(stage?.name),
          errorMessage: Value(errorMessage),
          logs: logs == null ? const Value.absent() : Value(logs),
          contractMarkdown: contractMarkdown == null
              ? const Value.absent()
              : Value(contractMarkdown),
          draftMarkdown: draftMarkdown == null
              ? const Value.absent()
              : Value(draftMarkdown),
          auditMarkdown: auditMarkdown == null
              ? const Value.absent()
              : Value(auditMarkdown),
          revisedMarkdown: revisedMarkdown == null
              ? const Value.absent()
              : Value(revisedMarkdown),
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
      if (status == ChapterDraftRunStatus.succeeded) {
        await (_database.update(
          _database.chapterPlanRecords,
        )..where((plan) => plan.id.equals(run.chapterPlanId))).write(
          ChapterPlanRecordsCompanion(
            status: Value(ChapterPlanStatus.reviewed.name),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }

  @override
  Future<int> markInterruptedRunsFailed() async {
    final query = _database.select(_database.chapterDraftRunRecords)
      ..where(
        (run) =>
            run.status.equals(ChapterDraftRunStatus.running.name) |
            run.status.equals(ChapterDraftRunStatus.pending.name),
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
          _database.chapterDraftRunRecords,
        )..where((row) => row.id.equals(run.id))).write(
          ChapterDraftRunRecordsCompanion(
            status: Value(ChapterDraftRunStatus.failed.name),
            stage: const Value(null),
            errorMessage: const Value(message),
            updatedAt: Value(now),
          ),
        );
        await _updateWorkflowTaskForRun(
          workflowTaskId: run.workflowTaskId,
          status: ChapterDraftRunStatus.failed,
          stage: null,
          errorMessage: message,
          updatedAt: now,
        );
      }
    });
    return interrupted.length;
  }

  @override
  Stream<List<AcceptedChapter>> watchAcceptedChapters(String projectId) {
    final query = _database.select(_database.acceptedChapterRecords)
      ..where((chapter) => chapter.projectId.equals(projectId))
      ..orderBy([
        (chapter) => OrderingTerm(expression: chapter.chapterIndex),
        (chapter) => OrderingTerm(expression: chapter.acceptedAt),
      ]);
    return query.watch().map(
      (rows) => rows.map(_mapAcceptedChapter).toList(growable: false),
    );
  }

  @override
  Stream<AcceptedChapter?> watchAcceptedChapterForPlan(String chapterPlanId) {
    final query = _database.select(_database.acceptedChapterRecords)
      ..where((chapter) => chapter.chapterPlanId.equals(chapterPlanId))
      ..limit(1);
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapAcceptedChapter(row),
    );
  }

  @override
  Future<AcceptedChapter?> findAcceptedChapterForPlan(
    String chapterPlanId,
  ) async {
    final query = _database.select(_database.acceptedChapterRecords)
      ..where((chapter) => chapter.chapterPlanId.equals(chapterPlanId))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapAcceptedChapter(row);
  }

  @override
  Future<AcceptedChapter> upsertAcceptedChapter(
    AcceptedChapterInput input,
  ) async {
    await _ensureProjectExists(input.projectId);
    final plan = await findChapterPlan(input.chapterPlanId);
    if (plan == null || plan.projectId != input.projectId) {
      throw StateError('Chapter plan does not belong to the project.');
    }
    final run = await findChapterDraftRun(input.sourceRunId);
    if (run == null || run.chapterPlanId != input.chapterPlanId) {
      throw StateError('Source run does not belong to the chapter plan.');
    }
    final content = input.contentMarkdown.trim();
    if (content.isEmpty) {
      throw StateError('正式章节正文不能为空。');
    }
    final now = DateTime.now();
    final existing = await findAcceptedChapterForPlan(input.chapterPlanId);
    final chapterId = existing?.id ?? _uuid.v4();
    final acceptedAt = input.acceptedAt ?? now;

    await _database.transaction(() async {
      await _database
          .into(_database.acceptedChapterRecords)
          .insertOnConflictUpdate(
            AcceptedChapterRecordsCompanion(
              id: Value(chapterId),
              projectId: Value(input.projectId),
              chapterPlanId: Value(input.chapterPlanId),
              sourceRunId: Value(input.sourceRunId),
              chapterIndex: Value(input.chapterIndex),
              title: Value(_normalizedAcceptedTitle(input, plan)),
              contentMarkdown: Value(content),
              acceptedAt: Value(acceptedAt),
              createdAt: Value(existing?.createdAt ?? now),
              updatedAt: Value(now),
            ),
          );
      await (_database.update(
        _database.chapterPlanRecords,
      )..where((row) => row.id.equals(input.chapterPlanId))).write(
        ChapterPlanRecordsCompanion(
          status: Value(ChapterPlanStatus.accepted.name),
          updatedAt: Value(now),
        ),
      );
    });

    final saved = await findAcceptedChapterForPlan(input.chapterPlanId);
    if (saved == null) {
      throw StateError('Accepted chapter was not saved.');
    }
    return saved;
  }

  @override
  Stream<MemoryProjection?> watchMemoryProjection(String projectId) {
    final query = _database.select(_database.memoryProjectionRecords)
      ..where((projection) => projection.projectId.equals(projectId))
      ..limit(1);
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapMemoryProjection(row),
    );
  }

  @override
  Future<MemoryProjection?> findMemoryProjection(String projectId) async {
    final query = _database.select(_database.memoryProjectionRecords)
      ..where((projection) => projection.projectId.equals(projectId))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapMemoryProjection(row);
  }

  @override
  Future<MemoryProjection> upsertMemoryProjection(
    MemoryProjectionInput input,
  ) async {
    await _ensureProjectExists(input.projectId);
    await _ensureAcceptedChapterBelongsToProject(
      input.updatedFromChapterId,
      input.projectId,
    );
    final now = DateTime.now();
    final existing = await findMemoryProjection(input.projectId);
    final id = existing?.id ?? _uuid.v4();

    await _database
        .into(_database.memoryProjectionRecords)
        .insertOnConflictUpdate(
          MemoryProjectionRecordsCompanion(
            id: Value(id),
            projectId: Value(input.projectId),
            recentSummary: Value(input.recentSummary.trim()),
            globalSummary: Value(input.globalSummary.trim()),
            factLedgerMarkdown: Value(input.factLedgerMarkdown.trim()),
            characterStatesMarkdown: Value(
              input.characterStatesMarkdown.trim(),
            ),
            unresolvedHooksMarkdown: Value(
              input.unresolvedHooksMarkdown.trim(),
            ),
            updatedFromChapterId: Value(
              _blankToNull(input.updatedFromChapterId),
            ),
            updatedAt: Value(now),
          ),
        );

    final saved = await findMemoryProjection(input.projectId);
    if (saved == null) {
      throw StateError('Memory projection was not saved.');
    }
    return saved;
  }

  StoryBible _mapStoryBible(StoryBibleRecord row) {
    return StoryBible(
      id: row.id,
      projectId: row.projectId,
      authorIntent: row.authorIntent,
      currentFocus: row.currentFocus,
      worldMarkdown: row.worldMarkdown,
      charactersMarkdown: row.charactersMarkdown,
      rulesMarkdown: row.rulesMarkdown,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  ChapterPlan _mapChapterPlan(ChapterPlanRecord row) {
    return ChapterPlan(
      id: row.id,
      projectId: row.projectId,
      chapterIndex: row.chapterIndex,
      title: row.title,
      goal: row.goal,
      targetBeat: row.targetBeat,
      mustInclude: row.mustInclude,
      mustAvoid: row.mustAvoid,
      hook: row.hook,
      payoff: row.payoff,
      status: ChapterPlanStatus.values.byName(row.status),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  ChapterDraftRun _mapChapterDraftRun(ChapterDraftRunRecord row) {
    return ChapterDraftRun(
      id: row.id,
      workflowTaskId: row.workflowTaskId,
      projectId: row.projectId,
      chapterPlanId: row.chapterPlanId,
      providerId: row.providerId,
      modelName: row.modelName,
      status: ChapterDraftRunStatus.values.byName(row.status),
      stage: row.stage == null
          ? null
          : ChapterDraftRunStage.values.byName(row.stage!),
      contractMarkdown: row.contractMarkdown,
      draftMarkdown: row.draftMarkdown,
      auditMarkdown: row.auditMarkdown,
      revisedMarkdown: row.revisedMarkdown,
      errorMessage: row.errorMessage,
      logs: row.logs,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  AcceptedChapter _mapAcceptedChapter(AcceptedChapterRecord row) {
    return AcceptedChapter(
      id: row.id,
      projectId: row.projectId,
      chapterPlanId: row.chapterPlanId,
      sourceRunId: row.sourceRunId,
      chapterIndex: row.chapterIndex,
      title: row.title,
      contentMarkdown: row.contentMarkdown,
      acceptedAt: row.acceptedAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  MemoryProjection _mapMemoryProjection(MemoryProjectionRecord row) {
    return MemoryProjection(
      id: row.id,
      projectId: row.projectId,
      recentSummary: row.recentSummary,
      globalSummary: row.globalSummary,
      factLedgerMarkdown: row.factLedgerMarkdown,
      characterStatesMarkdown: row.characterStatesMarkdown,
      unresolvedHooksMarkdown: row.unresolvedHooksMarkdown,
      updatedFromChapterId: row.updatedFromChapterId,
      updatedAt: row.updatedAt,
    );
  }

  WorkflowTaskStatus _workflowStatus(ChapterDraftRunStatus status) {
    return switch (status) {
      ChapterDraftRunStatus.pending => WorkflowTaskStatus.pending,
      ChapterDraftRunStatus.running => WorkflowTaskStatus.running,
      ChapterDraftRunStatus.succeeded => WorkflowTaskStatus.succeeded,
      ChapterDraftRunStatus.failed => WorkflowTaskStatus.failed,
      ChapterDraftRunStatus.abandoned => WorkflowTaskStatus.failed,
    };
  }

  Future<void> _updateWorkflowTaskForRun({
    required String workflowTaskId,
    required ChapterDraftRunStatus status,
    required ChapterDraftRunStage? stage,
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

  Future<ProjectRecord> _ensureProjectExists(String projectId) async {
    final query = _database.select(_database.projectRecords)
      ..where((project) => project.id.equals(projectId))
      ..limit(1);
    final project = await query.getSingleOrNull();
    if (project == null) {
      throw StateError('项目不存在。');
    }
    return project;
  }

  Future<void> _ensureProviderModel(String providerId, String modelName) async {
    final normalizedProviderId = providerId.trim();
    final normalizedModelName = modelName.trim();
    if (normalizedProviderId.isEmpty || normalizedModelName.isEmpty) {
      throw StateError('章节生成任务需要 Provider 和模型。');
    }
    final providerQuery = _database.select(_database.providerConfigRecords)
      ..where((provider) => provider.id.equals(normalizedProviderId))
      ..limit(1);
    final provider = await providerQuery.getSingleOrNull();
    if (provider == null) {
      throw StateError('Provider 不存在。');
    }

    final modelQuery = _database.select(_database.providerModelRecords)
      ..where(
        (model) =>
            model.providerId.equals(normalizedProviderId) &
            model.modelName.equals(normalizedModelName),
      )
      ..limit(1);
    final model = await modelQuery.getSingleOrNull();
    if (model == null && provider.defaultModel != normalizedModelName) {
      throw StateError('模型不属于所选 Provider。');
    }
  }

  Future<void> _ensureAcceptedChapterBelongsToProject(
    String? chapterId,
    String projectId,
  ) async {
    final normalizedId = _blankToNull(chapterId);
    if (normalizedId == null) {
      return;
    }
    final query = _database.select(_database.acceptedChapterRecords)
      ..where((chapter) => chapter.id.equals(normalizedId))
      ..limit(1);
    final chapter = await query.getSingleOrNull();
    if (chapter == null || chapter.projectId != projectId) {
      throw StateError('记忆投影引用的正式章节不存在。');
    }
  }

  String _normalizedChapterTitle(ChapterPlanInput input) {
    final trimmed = input.title.trim();
    return trimmed.isEmpty ? '第 ${input.chapterIndex} 章' : trimmed;
  }

  String _normalizedAcceptedTitle(
    AcceptedChapterInput input,
    ChapterPlan plan,
  ) {
    final trimmed = input.title.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    return plan.title.trim().isEmpty ? '第 ${plan.chapterIndex} 章' : plan.title;
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
