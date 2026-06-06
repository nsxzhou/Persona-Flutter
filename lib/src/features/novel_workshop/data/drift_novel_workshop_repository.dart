import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';

import '../../../core/database/app_database.dart';
import '../../../core/tasks/domain/workflow_task.dart';
import '../application/character_graph_parser.dart';
import '../application/memory_patch_document.dart';
import '../application/memory_patch_yaml.dart';
import '../application/outline_detail_parser.dart';
import '../application/volume_blueprint_parser.dart';
import '../domain/novel_workshop.dart';
import '../domain/novel_workshop_repository.dart';
import '../domain/writing_context.dart';

class DriftNovelWorkshopRepository implements NovelWorkshopRepository {
  const DriftNovelWorkshopRepository(this._database);

  final AppDatabase _database;

  static const _uuid = Uuid();
  @override
  Stream<ProjectBible> watchProjectBible(String projectId) async* {
    yield await ensureProjectBible(projectId);
    final query = _database.select(_database.projectBibleRecords)
      ..where((bible) => bible.projectId.equals(projectId))
      ..limit(1);
    yield* query.watchSingle().map(_mapBible);
  }

  @override
  Stream<List<ChapterVolume>> watchChapterVolumes(String projectId) {
    final query = _database.select(_database.chapterVolumeRecords)
      ..where((volume) => volume.projectId.equals(projectId))
      ..orderBy([(volume) => OrderingTerm.asc(volume.volumeIndex)]);
    return query.watch().map(
      (rows) => rows.map(_mapVolume).toList(growable: false),
    );
  }

  @override
  Stream<List<ChapterPlan>> watchChapterPlans(String projectId) {
    final query = _database.select(_database.chapterPlanRecords)
      ..where((plan) => plan.projectId.equals(projectId))
      ..orderBy([
        (plan) => OrderingTerm.asc(plan.volumeIndex),
        (plan) => OrderingTerm.asc(plan.chapterLocalIndex),
        (plan) => OrderingTerm.asc(plan.chapterIndex),
      ]);
    return query.watch().map(
      (rows) => rows.map(_mapPlan).toList(growable: false),
    );
  }

  @override
  Stream<List<ProjectChapter>> watchChapters(String projectId) {
    final query = _database.select(_database.projectChapterRecords)
      ..where((chapter) => chapter.projectId.equals(projectId))
      ..orderBy([(chapter) => OrderingTerm.asc(chapter.chapterIndex)]);
    return query.watch().map(
      (rows) => rows.map(_mapChapter).toList(growable: false),
    );
  }

  @override
  Stream<List<ChapterIllustration>> watchChapterIllustrations(
    String projectId,
  ) {
    final query = _database.select(_database.chapterIllustrationRecords)
      ..where((illustration) => illustration.projectId.equals(projectId))
      ..orderBy([
        (illustration) => OrderingTerm.asc(illustration.chapterPlanId),
        (illustration) => OrderingTerm.asc(illustration.paragraphIndex),
        (illustration) => OrderingTerm.asc(illustration.createdAt),
      ]);
    return query.watch().map(
      (rows) => rows.map(_mapIllustration).toList(growable: false),
    );
  }

  @override
  Stream<List<ChapterIllustrationGenerationRun>>
  watchChapterIllustrationGenerationRuns(String projectId) {
    final query =
        _database.select(_database.chapterIllustrationGenerationRunRecords)
          ..where((run) => run.projectId.equals(projectId))
          ..orderBy([
            (run) => OrderingTerm(
              expression: run.updatedAt,
              mode: OrderingMode.desc,
            ),
          ]);
    return query.watch().map(
      (rows) => rows.map(_mapIllustrationGenerationRun).toList(growable: false),
    );
  }

  @override
  Stream<List<NovelCharacter>> watchCharacters(String projectId) {
    final query = _database.select(_database.novelCharacterRecords)
      ..where((character) => character.projectId.equals(projectId))
      ..orderBy([(character) => OrderingTerm.asc(character.name)]);
    return query.watch().map(
      (rows) => rows.map(_mapCharacter).toList(growable: false),
    );
  }

  @override
  Stream<List<NovelRelationship>> watchRelationships(String projectId) {
    final query = _database.select(_database.novelRelationshipRecords)
      ..where((relationship) => relationship.projectId.equals(projectId))
      ..orderBy([
        (relationship) => OrderingTerm.asc(relationship.fromCharacterId),
        (relationship) => OrderingTerm.asc(relationship.toCharacterId),
      ]);
    return query.watch().map(
      (rows) => rows.map(_mapRelationship).toList(growable: false),
    );
  }

  @override
  Stream<List<ChapterGenerationRun>> watchChapterGenerationRuns(
    String projectId,
  ) {
    final query = _database.select(_database.chapterGenerationRunRecords)
      ..where((run) => run.projectId.equals(projectId))
      ..orderBy([
        (run) =>
            OrderingTerm(expression: run.updatedAt, mode: OrderingMode.desc),
      ]);
    return query.watch().map(
      (rows) => rows.map(_mapGenerationRun).toList(growable: false),
    );
  }

  @override
  Stream<List<ChapterGenerationBatch>> watchChapterGenerationBatches(
    String projectId,
  ) {
    final query = _database.select(_database.chapterGenerationBatchRecords)
      ..where((batch) => batch.projectId.equals(projectId))
      ..orderBy([
        (batch) =>
            OrderingTerm(expression: batch.updatedAt, mode: OrderingMode.desc),
      ]);
    return query.watch().map(
      (rows) => rows.map(_mapGenerationBatch).toList(growable: false),
    );
  }

  @override
  Stream<List<AssetGenerationRun>> watchAssetGenerationRuns(String projectId) {
    final query = _database.select(_database.assetGenerationRunRecords)
      ..where((run) => run.projectId.equals(projectId))
      ..orderBy([
        (run) =>
            OrderingTerm(expression: run.updatedAt, mode: OrderingMode.desc),
      ]);
    return query.watch().map(
      (rows) => rows.map(_mapAssetGenerationRun).toList(growable: false),
    );
  }

  @override
  Stream<List<ChapterEnrichmentBatch>> watchChapterEnrichmentBatches(
    String projectId,
  ) {
    final query = _database.select(_database.chapterEnrichmentBatchRecords)
      ..where((batch) => batch.projectId.equals(projectId))
      ..orderBy([
        (batch) =>
            OrderingTerm(expression: batch.updatedAt, mode: OrderingMode.desc),
      ]);
    return query.watch().map(
      (rows) => rows.map(_mapEnrichmentBatch).toList(growable: false),
    );
  }

  @override
  Stream<List<ChapterEnrichmentItem>> watchChapterEnrichmentItems(
    String batchId,
  ) {
    final query = _database.select(_database.chapterEnrichmentItemRecords)
      ..where((item) => item.batchId.equals(batchId))
      ..orderBy([(item) => OrderingTerm.asc(item.position)]);
    return query.watch().map(
      (rows) => rows.map(_mapEnrichmentItem).toList(growable: false),
    );
  }

  @override
  Stream<List<ChapterGenerationBatchItem>> watchChapterGenerationBatchItems(
    String batchId,
  ) {
    final query = _database.select(_database.chapterGenerationBatchItemRecords)
      ..where((item) => item.batchId.equals(batchId))
      ..orderBy([(item) => OrderingTerm.asc(item.position)]);
    return query.watch().map(
      (rows) => rows.map(_mapGenerationBatchItem).toList(growable: false),
    );
  }

  @override
  Stream<ChapterGenerationRun?> watchChapterGenerationRunByWorkflowTask(
    String workflowTaskId,
  ) {
    final query = _database.select(_database.chapterGenerationRunRecords)
      ..where((run) => run.workflowTaskId.equals(workflowTaskId))
      ..limit(1);
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapGenerationRun(row),
    );
  }

  @override
  Stream<ChapterGenerationBatch?> watchChapterGenerationBatchByWorkflowTask(
    String workflowTaskId,
  ) {
    final query = _database.select(_database.chapterGenerationBatchRecords)
      ..where((batch) => batch.workflowTaskId.equals(workflowTaskId))
      ..limit(1);
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapGenerationBatch(row),
    );
  }

  @override
  Stream<AssetGenerationRun?> watchAssetGenerationRunByWorkflowTask(
    String workflowTaskId,
  ) {
    final query = _database.select(_database.assetGenerationRunRecords)
      ..where((run) => run.workflowTaskId.equals(workflowTaskId))
      ..limit(1);
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapAssetGenerationRun(row),
    );
  }

  @override
  Stream<ChapterIllustrationGenerationRun?>
  watchChapterIllustrationGenerationRunByWorkflowTask(String workflowTaskId) {
    final query =
        _database.select(_database.chapterIllustrationGenerationRunRecords)
          ..where((run) => run.workflowTaskId.equals(workflowTaskId))
          ..limit(1);
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapIllustrationGenerationRun(row),
    );
  }

  @override
  Stream<ChapterEnrichmentBatch?> watchChapterEnrichmentBatchByWorkflowTask(
    String workflowTaskId,
  ) {
    final query = _database.select(_database.chapterEnrichmentBatchRecords)
      ..where((batch) => batch.workflowTaskId.equals(workflowTaskId))
      ..limit(1);
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapEnrichmentBatch(row),
    );
  }

  @override
  Future<ChapterPlan?> findChapterPlan(String id) async {
    final query = _database.select(_database.chapterPlanRecords)
      ..where((plan) => plan.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapPlan(row);
  }

  @override
  Future<ProjectChapter?> findChapter(String id) async {
    final query = _database.select(_database.projectChapterRecords)
      ..where((chapter) => chapter.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapChapter(row);
  }

  @override
  Future<ProjectChapter?> findChapterByPlan(String chapterPlanId) async {
    final query = _database.select(_database.projectChapterRecords)
      ..where((chapter) => chapter.chapterPlanId.equals(chapterPlanId))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapChapter(row);
  }

  @override
  Future<ChapterIllustration?> findChapterIllustration(String id) async {
    final query = _database.select(_database.chapterIllustrationRecords)
      ..where((row) => row.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapIllustration(row);
  }

  @override
  Future<ChapterIllustrationGenerationRun?>
  findChapterIllustrationGenerationRun(String id) async {
    final query =
        _database.select(_database.chapterIllustrationGenerationRunRecords)
          ..where((row) => row.id.equals(id))
          ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapIllustrationGenerationRun(row);
  }

  @override
  Future<NovelCharacter?> findCharacter(String id) async {
    final query = _database.select(_database.novelCharacterRecords)
      ..where((character) => character.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapCharacter(row);
  }

  @override
  Future<NovelRelationship?> findRelationship(String id) async {
    final query = _database.select(_database.novelRelationshipRecords)
      ..where((relationship) => relationship.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapRelationship(row);
  }

  @override
  Future<ChapterGenerationRun?> findChapterGenerationRun(String id) async {
    final query = _database.select(_database.chapterGenerationRunRecords)
      ..where((run) => run.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapGenerationRun(row);
  }

  @override
  Future<ChapterGenerationBatch?> findChapterGenerationBatch(String id) async {
    final query = _database.select(_database.chapterGenerationBatchRecords)
      ..where((batch) => batch.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapGenerationBatch(row);
  }

  @override
  Future<ChapterGenerationBatchItem?> findChapterGenerationBatchItem(
    String id,
  ) async {
    final query = _database.select(_database.chapterGenerationBatchItemRecords)
      ..where((item) => item.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapGenerationBatchItem(row);
  }

  @override
  Future<AssetGenerationRun?> findAssetGenerationRun(String id) async {
    final query = _database.select(_database.assetGenerationRunRecords)
      ..where((run) => run.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapAssetGenerationRun(row);
  }

  @override
  Future<ChapterEnrichmentBatch?> findChapterEnrichmentBatch(String id) async {
    final query = _database.select(_database.chapterEnrichmentBatchRecords)
      ..where((batch) => batch.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapEnrichmentBatch(row);
  }

  @override
  Future<ChapterEnrichmentItem?> findChapterEnrichmentItem(String id) async {
    final query = _database.select(_database.chapterEnrichmentItemRecords)
      ..where((item) => item.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapEnrichmentItem(row);
  }

  @override
  Future<void> abandonWorkflowTask(String workflowTaskId) async {
    final now = DateTime.now();
    await _database.transaction(() async {
      var handled = false;
      final generationRun =
          await (_database.select(_database.chapterGenerationRunRecords)
                ..where((run) => run.workflowTaskId.equals(workflowTaskId))
                ..limit(1))
              .getSingleOrNull();
      if (generationRun != null) {
        handled =
            await _abandonChapterGenerationRun(generationRun, now) || handled;
      }

      final generationBatch =
          await (_database.select(_database.chapterGenerationBatchRecords)
                ..where((batch) => batch.workflowTaskId.equals(workflowTaskId))
                ..limit(1))
              .getSingleOrNull();
      if (generationBatch != null) {
        handled =
            await _abandonChapterGenerationBatch(generationBatch, now) ||
            handled;
      }

      final assetRun =
          await (_database.select(_database.assetGenerationRunRecords)
                ..where((run) => run.workflowTaskId.equals(workflowTaskId))
                ..limit(1))
              .getSingleOrNull();
      if (assetRun != null) {
        handled = await _abandonAssetGenerationRun(assetRun, now) || handled;
      }

      final illustrationRun =
          await (_database.select(
                  _database.chapterIllustrationGenerationRunRecords,
                )
                ..where((run) => run.workflowTaskId.equals(workflowTaskId))
                ..limit(1))
              .getSingleOrNull();
      if (illustrationRun != null) {
        handled =
            await _abandonChapterIllustrationGenerationRun(
              illustrationRun,
              now,
            ) ||
            handled;
      }

      final enrichmentBatch =
          await (_database.select(_database.chapterEnrichmentBatchRecords)
                ..where((batch) => batch.workflowTaskId.equals(workflowTaskId))
                ..limit(1))
              .getSingleOrNull();
      if (enrichmentBatch != null) {
        handled =
            await _abandonChapterEnrichmentBatch(enrichmentBatch, now) ||
            handled;
      }

      if (handled) {
        await (_database.update(
          _database.workflowTaskRecords,
        )..where((task) => task.id.equals(workflowTaskId))).write(
          WorkflowTaskRecordsCompanion(
            status: Value(WorkflowTaskStatus.abandoned.name),
            stage: const Value(null),
            errorMessage: const Value(null),
            updatedAt: Value(now),
          ),
        );
        await (_database.delete(
          _database.workflowPromptTraceRecords,
        )..where((trace) => trace.workflowTaskId.equals(workflowTaskId))).go();
      }
    });
  }

  @override
  Future<ProjectBible?> findProjectBible(String projectId) async {
    final query = _database.select(_database.projectBibleRecords)
      ..where((bible) => bible.projectId.equals(projectId))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapBible(row);
  }

  @override
  Future<ProjectBible> ensureProjectBible(String projectId) async {
    await _requireProject(projectId);
    final existing = await findProjectBible(projectId);
    if (existing != null) {
      return existing;
    }
    final project = await _requireProjectRecord(projectId);
    final now = DateTime.now();
    await _database
        .into(_database.projectBibleRecords)
        .insert(
          ProjectBibleRecordsCompanion.insert(
            projectId: projectId,
            descriptionMarkdown: Value(project.description.trim()),
            worldBuildingMarkdown: const Value(''),
            charactersBlueprintMarkdown: const Value(''),
            outlineMasterMarkdown: const Value(''),
            outlineDetailYaml: const Value(''),
            createdAt: now,
            updatedAt: now,
          ),
        );
    final saved = await findProjectBible(projectId);
    if (saved == null) {
      throw StateError('Project Bible was not saved.');
    }
    return saved;
  }

  @override
  Future<ProjectBible> saveProjectBible(ProjectBibleInput input) async {
    await _requireProject(input.projectId);
    final now = DateTime.now();
    final existing = await findProjectBible(input.projectId);
    await _database
        .into(_database.projectBibleRecords)
        .insertOnConflictUpdate(
          ProjectBibleRecordsCompanion(
            projectId: Value(input.projectId),
            descriptionMarkdown: Value(input.descriptionMarkdown.trim()),
            worldBuildingMarkdown: Value(input.worldBuildingMarkdown.trim()),
            charactersBlueprintMarkdown: Value(
              input.charactersBlueprintMarkdown.trim(),
            ),
            outlineMasterMarkdown: Value(input.outlineMasterMarkdown.trim()),
            outlineDetailYaml: Value(input.outlineDetailYaml.trim()),
            createdAt: Value(existing?.createdAt ?? now),
            updatedAt: Value(now),
          ),
        );
    final saved = await findProjectBible(input.projectId);
    if (saved == null) {
      throw StateError('Project Bible was not saved.');
    }
    return saved;
  }

  @override
  Future<List<ChapterVolume>> watchChapterVolumesOnce(String projectId) {
    return watchChapterVolumes(projectId).first;
  }

  @override
  Future<bool> hasRunningChapterGeneration(String chapterPlanId) async {
    final query = _database.select(_database.chapterGenerationRunRecords)
      ..where(
        (run) =>
            run.chapterPlanId.equals(chapterPlanId) &
            (run.status.equals(ChapterGenerationStatus.pending.name) |
                run.status.equals(ChapterGenerationStatus.running.name)),
      )
      ..limit(1);
    return await query.getSingleOrNull() != null;
  }

  @override
  Future<bool> hasRunningChapterGenerationForProject(String projectId) async {
    final query = _database.select(_database.chapterGenerationRunRecords)
      ..where(
        (run) =>
            run.projectId.equals(projectId) &
            (run.status.equals(ChapterGenerationStatus.pending.name) |
                run.status.equals(ChapterGenerationStatus.running.name)),
      )
      ..limit(1);
    return await query.getSingleOrNull() != null;
  }

  @override
  Future<bool> hasRunningChapterGenerationBatch(String projectId) async {
    final query = _database.select(_database.chapterGenerationBatchRecords)
      ..where(
        (batch) =>
            batch.projectId.equals(projectId) &
            (batch.status.equals(ChapterGenerationBatchStatus.pending.name) |
                batch.status.equals(ChapterGenerationBatchStatus.running.name)),
      )
      ..limit(1);
    return await query.getSingleOrNull() != null;
  }

  @override
  Future<bool> hasRunningAssetGeneration({
    required String projectId,
    required AssetGenerationKind kind,
    String? targetVolumeId,
  }) async {
    final normalizedVolumeId = targetVolumeId?.trim();
    final query = _database.select(_database.assetGenerationRunRecords)
      ..where(
        (run) =>
            run.projectId.equals(projectId) &
            run.kind.equals(kind.name) &
            (run.status.equals(AssetGenerationStatus.pending.name) |
                run.status.equals(AssetGenerationStatus.running.name)),
      )
      ..limit(1);
    if (normalizedVolumeId == null || normalizedVolumeId.isEmpty) {
      query.where((run) => run.targetVolumeId.isNull());
    } else {
      query.where((run) => run.targetVolumeId.equals(normalizedVolumeId));
    }
    return await query.getSingleOrNull() != null;
  }

  @override
  Future<ProjectRuntimeMemory?> findRuntimeMemory(String projectId) async {
    final query = _database.select(_database.projectRuntimeMemoryRecords)
      ..where((memory) => memory.projectId.equals(projectId))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapMemory(row);
  }

  @override
  Future<ProjectRuntimeMemory> ensureRuntimeMemory(String projectId) async {
    final existing = await findRuntimeMemory(projectId);
    if (existing != null) {
      return existing;
    }
    return saveRuntimeMemory(
      projectId: projectId,
      state: const RuntimeMemoryState(),
    );
  }

  @override
  Future<ProjectRuntimeMemory> saveRuntimeMemory({
    required String projectId,
    required RuntimeMemoryState state,
  }) async {
    await _requireProject(projectId);
    final now = DateTime.now();
    final existing = await findRuntimeMemory(projectId);
    await _database
        .into(_database.projectRuntimeMemoryRecords)
        .insertOnConflictUpdate(
          ProjectRuntimeMemoryRecordsCompanion(
            projectId: Value(projectId),
            runtimeState: Value(state.runtimeState.trim()),
            runtimeThreads: Value(state.runtimeThreads.trim()),
            storySummary: Value(state.storySummary.trim()),
            continuityIndex: Value(state.continuityIndex.trim()),
            chapterArchiveMarkdown: Value(state.chapterArchiveMarkdown.trim()),
            createdAt: Value(existing?.createdAt ?? now),
            updatedAt: Value(now),
          ),
        );
    final saved = await findRuntimeMemory(projectId);
    if (saved == null) {
      throw StateError('Runtime memory was not saved.');
    }
    return saved;
  }

  @override
  Future<void> clearRuntimeMemory(String projectId) async {
    await saveRuntimeMemory(
      projectId: projectId,
      state: const RuntimeMemoryState(),
    );
  }

  @override
  Future<ChapterVolume> saveChapterVolume({
    String? id,
    required ChapterVolumeInput input,
  }) async {
    await _validateChapterVolumeInput(input);
    final now = DateTime.now();
    // 当未提供 id 时，按 (projectId, volumeIndex) 查找已有记录以复用 id，
    // 避免与唯一约束冲突。
    ChapterVolume? existing;
    if (id != null) {
      existing = await _findChapterVolume(id);
    } else {
      final row =
          await (_database.select(_database.chapterVolumeRecords)
                ..where(
                  (v) =>
                      v.projectId.equals(input.projectId) &
                      v.volumeIndex.equals(input.volumeIndex),
                )
                ..limit(1))
              .getSingleOrNull();
      if (row != null) {
        existing = _mapVolume(row);
      }
    }
    final normalizedId = existing?.id ?? id ?? _uuid.v4();
    await _database
        .into(_database.chapterVolumeRecords)
        .insertOnConflictUpdate(
          ChapterVolumeRecordsCompanion(
            id: Value(normalizedId),
            projectId: Value(input.projectId),
            volumeIndex: Value(input.volumeIndex),
            title: Value(input.title.trim()),
            targetLength: Value(input.targetLength),
            summary: Value(input.summary.trim()),
            centralConflict: Value(input.centralConflict.trim()),
            characterProgression: Value(input.characterProgression.trim()),
            endingHook: Value(input.endingHook.trim()),
            createdAt: Value(existing?.createdAt ?? now),
            updatedAt: Value(now),
          ),
        );
    final saved = await _findChapterVolume(normalizedId);
    if (saved == null) {
      throw StateError('Chapter volume was not saved.');
    }
    return saved;
  }

  @override
  Future<NovelCharacter> saveCharacter({
    String? id,
    required NovelCharacterInput input,
  }) async {
    await _validateCharacterInput(input);
    final now = DateTime.now();
    final normalizedId = id ?? _uuid.v4();
    final existing = id == null ? null : await findCharacter(id);
    await _database
        .into(_database.novelCharacterRecords)
        .insertOnConflictUpdate(
          NovelCharacterRecordsCompanion(
            id: Value(normalizedId),
            projectId: Value(input.projectId),
            name: Value(input.name.trim()),
            aliases: Value(input.aliases.trim()),
            tags: Value(input.tags.trim()),
            faction: Value(input.faction.trim()),
            role: Value(input.role.trim()),
            longTermGoal: Value(input.longTermGoal.trim()),
            currentStatus: Value(input.currentStatus.trim()),
            secrets: Value(input.secrets.trim()),
            firstChapterIndex: Value(input.firstChapterIndex),
            lastChapterIndex: Value(input.lastChapterIndex),
            createdAt: Value(existing?.createdAt ?? now),
            updatedAt: Value(now),
          ),
        );
    final saved = await findCharacter(normalizedId);
    if (saved == null) {
      throw StateError('Novel character was not saved.');
    }
    return saved;
  }

  @override
  Future<NovelRelationship> saveRelationship({
    String? id,
    required NovelRelationshipInput input,
  }) async {
    await _validateRelationshipInput(input);
    final now = DateTime.now();
    final normalizedId = id ?? _uuid.v4();
    final existing = id == null ? null : await findRelationship(id);
    await _database
        .into(_database.novelRelationshipRecords)
        .insertOnConflictUpdate(
          NovelRelationshipRecordsCompanion(
            id: Value(normalizedId),
            projectId: Value(input.projectId),
            fromCharacterId: Value(input.fromCharacterId),
            toCharacterId: Value(input.toCharacterId),
            relationshipType: Value(input.relationshipType.trim()),
            strength: Value(input.strength.clamp(-5, 5)),
            status: Value(input.status.trim()),
            description: Value(input.description.trim()),
            lastChangedChapterIndex: Value(input.lastChangedChapterIndex),
            createdAt: Value(existing?.createdAt ?? now),
            updatedAt: Value(now),
          ),
        );
    final saved = await findRelationship(normalizedId);
    if (saved == null) {
      throw StateError('Novel relationship was not saved.');
    }
    return saved;
  }

  @override
  Future<ChapterPlan> saveChapterPlan({
    String? id,
    required ChapterPlanInput input,
  }) async {
    await _validateChapterPlanInput(input);
    final now = DateTime.now();
    final normalizedId = id ?? _uuid.v4();
    final existing = id == null ? null : await findChapterPlan(id);
    await _database
        .into(_database.chapterPlanRecords)
        .insertOnConflictUpdate(
          ChapterPlanRecordsCompanion(
            id: Value(normalizedId),
            projectId: Value(input.projectId),
            volumeId: Value(input.volumeId),
            volumeIndex: Value(input.volumeIndex),
            volumeTitle: Value(input.volumeTitle.trim()),
            chapterLocalIndex: Value(input.chapterLocalIndex),
            chapterIndex: Value(input.chapterIndex),
            title: Value(input.objectiveCard.chapterTitle.trim()),
            objective: Value(input.objectiveCard.objective.trim()),
            pressureSource: Value(input.objectiveCard.pressureSource.trim()),
            payoffTarget: Value(input.objectiveCard.payoffTarget.trim()),
            relationshipShift: Value(
              input.objectiveCard.relationshipShift.trim(),
            ),
            hookType: Value(input.objectiveCard.hookType.trim()),
            coreEvent: Value(input.coreEvent.trim()),
            emotionArc: Value(input.emotionArc.trim()),
            chapterHook: Value(input.chapterHook.trim()),
            outlineMarkdown: Value(input.outlineMarkdown.trim()),
            createdAt: Value(existing?.createdAt ?? now),
            updatedAt: Value(now),
          ),
        );
    final saved = await findChapterPlan(normalizedId);
    if (saved == null) {
      throw StateError('Chapter plan was not saved.');
    }
    return saved;
  }

  @override
  Future<ProjectBible> saveOutlineDetailYaml({
    required String projectId,
    required String outlineDetailYaml,
  }) async {
    final bible = await ensureProjectBible(projectId);
    final document = const OutlineDetailParser().parse(outlineDetailYaml);
    final now = DateTime.now();
    await _database.transaction(() async {
      await _database
          .into(_database.projectBibleRecords)
          .insertOnConflictUpdate(
            ProjectBibleRecordsCompanion(
              projectId: Value(projectId),
              descriptionMarkdown: Value(bible.descriptionMarkdown),
              worldBuildingMarkdown: Value(bible.worldBuildingMarkdown),
              charactersBlueprintMarkdown: Value(
                bible.charactersBlueprintMarkdown,
              ),
              outlineMasterMarkdown: Value(bible.outlineMasterMarkdown),
              outlineDetailYaml: Value(outlineDetailYaml.trim()),
              createdAt: Value(bible.createdAt),
              updatedAt: Value(now),
            ),
          );

      final existingVolumes = await (_database.select(
        _database.chapterVolumeRecords,
      )..where((volume) => volume.projectId.equals(projectId))).get();
      final existingVolumeByIndex = {
        for (final volume in existingVolumes) volume.volumeIndex: volume,
      };
      final volumeIdsByIndex = <int, String>{};
      for (final draft in document.volumes) {
        final existing = existingVolumeByIndex[draft.volumeIndex];
        final volumeId = existing?.id ?? _uuid.v4();
        volumeIdsByIndex[draft.volumeIndex] = volumeId;
        await _database
            .into(_database.chapterVolumeRecords)
            .insertOnConflictUpdate(
              ChapterVolumeRecordsCompanion(
                id: Value(volumeId),
                projectId: Value(projectId),
                volumeIndex: Value(draft.volumeIndex),
                title: Value(draft.title),
                createdAt: Value(existing?.createdAt ?? now),
                updatedAt: Value(now),
              ),
            );
      }
      // 删除不在文档中的已有分卷
      final keptVolumeIndexes = {
        for (final v in document.volumes) v.volumeIndex,
      };
      for (final existing in existingVolumes) {
        if (!keptVolumeIndexes.contains(existing.volumeIndex)) {
          await (_database.delete(
            _database.chapterVolumeRecords,
          )..where((v) => v.id.equals(existing.id))).go();
        }
      }

      final existingPlans = await (_database.select(
        _database.chapterPlanRecords,
      )..where((plan) => plan.projectId.equals(projectId))).get();
      final existingPlanByChapterIndex = {
        for (final plan in existingPlans) plan.chapterIndex: plan,
      };
      for (final draft in document.chapters) {
        final existing = existingPlanByChapterIndex[draft.chapterIndex];
        final volumeId = volumeIdsByIndex[draft.volumeIndex];
        if (volumeId == null) {
          throw StateError('Chapter volume was not projected.');
        }
        final id = existing?.id ?? _uuid.v4();
        await _database
            .into(_database.chapterPlanRecords)
            .insertOnConflictUpdate(
              ChapterPlanRecordsCompanion(
                id: Value(id),
                projectId: Value(projectId),
                volumeId: Value(volumeId),
                volumeIndex: Value(draft.volumeIndex),
                volumeTitle: Value(draft.volumeTitle),
                chapterLocalIndex: Value(draft.chapterLocalIndex),
                chapterIndex: Value(draft.chapterIndex),
                title: Value(draft.objectiveCard.chapterTitle),
                objective: Value(draft.objectiveCard.objective),
                pressureSource: Value(draft.objectiveCard.pressureSource),
                payoffTarget: Value(draft.objectiveCard.payoffTarget),
                relationshipShift: Value(draft.objectiveCard.relationshipShift),
                hookType: Value(draft.objectiveCard.hookType),
                coreEvent: Value(draft.coreEvent),
                emotionArc: Value(draft.emotionArc),
                chapterHook: Value(draft.chapterHook),
                outlineMarkdown: Value(draft.outlineMarkdown),
                createdAt: Value(existing?.createdAt ?? now),
                updatedAt: Value(now),
              ),
            );
      }
      // 删除不在文档中的已有章节
      final keptChapterIndexes = {
        for (final c in document.chapters) c.chapterIndex,
      };
      for (final existing in existingPlans) {
        if (!keptChapterIndexes.contains(existing.chapterIndex)) {
          await (_database.delete(
            _database.chapterPlanRecords,
          )..where((p) => p.id.equals(existing.id))).go();
        }
      }
    });
    final saved = await findProjectBible(projectId);
    if (saved == null) {
      throw StateError('Project Bible was not saved.');
    }
    return saved;
  }

  Future<ProjectBible> _applyOutlineDetailDraft({
    required AssetGenerationRun run,
    required String draft,
    required ProjectBible bible,
  }) async {
    final incoming = const OutlineDetailParser().parse(draft);
    final targetVolumeId = run.targetVolumeId?.trim();
    if (bible.outlineDetailYaml.trim().isEmpty) {
      return saveOutlineDetailYaml(
        projectId: run.projectId,
        outlineDetailYaml: _outlineDetailYamlFromDocument(incoming),
      );
    }

    var incomingVolumes = incoming.volumes;
    if (targetVolumeId != null && targetVolumeId.isNotEmpty) {
      final targetVolume = await _findChapterVolume(targetVolumeId);
      if (targetVolume == null || targetVolume.projectId != run.projectId) {
        throw StateError('目标分卷不存在。');
      }
      incomingVolumes = incoming.volumes
          .where((volume) => volume.volumeIndex == targetVolume.volumeIndex)
          .toList(growable: false);
      if (incomingVolumes.length != 1) {
        throw StateError('章节细纲草稿必须只包含目标分卷。');
      }
    }

    final existing = const OutlineDetailParser().parse(bible.outlineDetailYaml);
    final incomingByIndex = {
      for (final volume in incomingVolumes) volume.volumeIndex: volume,
    };
    final volumes = <OutlineVolumeDraft>[];
    for (final volume in existing.volumes) {
      volumes.add(incomingByIndex.remove(volume.volumeIndex) ?? volume);
    }
    volumes.addAll(incomingByIndex.values);
    volumes.sort((a, b) => a.volumeIndex.compareTo(b.volumeIndex));
    final merged = OutlineDetailDocument(volumes: List.unmodifiable(volumes));

    return saveOutlineDetailYaml(
      projectId: run.projectId,
      outlineDetailYaml: _outlineDetailYamlFromDocument(merged),
    );
  }

  String _outlineDetailYamlFromDocument(OutlineDetailDocument document) {
    final buffer = StringBuffer('volumes:\n');
    for (final volume in document.volumes) {
      buffer
        ..writeln('  - index: ${volume.volumeIndex}')
        ..writeln('    title: ${_yamlScalar(volume.title)}');
      if (volume.chapters.isEmpty) {
        buffer.writeln('    chapters: []');
      } else {
        buffer.writeln('    chapters:');
      }
      for (final chapter in volume.chapters) {
        buffer
          ..writeln('      - index: ${chapter.chapterLocalIndex}')
          ..writeln(
            '        title: ${_yamlScalar(chapter.objectiveCard.chapterTitle)}',
          );
        _writeYamlScalarField(
          buffer,
          'objective',
          chapter.objectiveCard.objective,
        );
        _writeYamlScalarField(
          buffer,
          'pressureSource',
          chapter.objectiveCard.pressureSource,
        );
        _writeYamlScalarField(
          buffer,
          'payoffTarget',
          chapter.objectiveCard.payoffTarget,
        );
        _writeYamlScalarField(
          buffer,
          'relationshipShift',
          chapter.objectiveCard.relationshipShift,
        );
        _writeYamlScalarField(
          buffer,
          'hookType',
          chapter.objectiveCard.hookType,
        );
        _writeYamlScalarField(buffer, 'coreEvent', chapter.coreEvent);
        _writeYamlScalarField(buffer, 'emotionArc', chapter.emotionArc);
        _writeYamlScalarField(buffer, 'chapterHook', chapter.chapterHook);
        _writeYamlBlockField(
          buffer,
          'outlineMarkdown',
          chapter.outlineMarkdown,
        );
      }
    }
    return buffer.toString().trimRight();
  }

  void _writeYamlScalarField(StringBuffer buffer, String key, String value) {
    if (value.trim().isEmpty) {
      return;
    }
    buffer.writeln('        $key: ${_yamlScalar(value)}');
  }

  @override
  String charactersToYaml({
    required List<NovelCharacter> characters,
    required List<NovelRelationship> relationships,
  }) {
    if (characters.isEmpty && relationships.isEmpty) {
      return '';
    }
    final nameById = {for (final c in characters) c.id: c.name};
    final buffer = StringBuffer('characters:\n');
    for (final c in characters) {
      buffer
        ..writeln('  - name: ${_yamlScalar(c.name)}')
        ..writeln('    role: ${_yamlScalar(c.role)}');
      _writeCharYamlField(buffer, 'aliases', c.aliases);
      _writeCharYamlField(buffer, 'faction', c.faction);
      _writeCharYamlField(buffer, 'status', c.currentStatus);
      _writeCharYamlField(buffer, 'longTermGoal', c.longTermGoal);
      _writeCharYamlField(buffer, 'secrets', c.secrets);
      _writeCharYamlField(buffer, 'tags', c.tags);
    }
    if (relationships.isNotEmpty) {
      buffer.writeln('\nrelationships:');
      for (final r in relationships) {
        final fromName = nameById[r.fromCharacterId] ?? r.fromCharacterId;
        final toName = nameById[r.toCharacterId] ?? r.toCharacterId;
        buffer
          ..writeln('  - from: ${_yamlScalar(fromName)}')
          ..writeln('    to: ${_yamlScalar(toName)}')
          ..writeln('    type: ${_yamlScalar(r.relationshipType)}');
        _writeCharYamlField(buffer, 'status', r.status);
        _writeCharYamlField(buffer, 'description', r.description);
      }
    }
    return buffer.toString().trimRight();
  }

  void _writeCharYamlField(StringBuffer buffer, String key, String value) {
    if (value.trim().isEmpty) return;
    buffer.writeln('    $key: ${_yamlScalar(value)}');
  }

  void _writeYamlBlockField(StringBuffer buffer, String key, String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }
    buffer.writeln('        $key: |-');
    for (final line in trimmed.split('\n')) {
      buffer.writeln('          $line');
    }
  }

  String _yamlScalar(String value) {
    final escaped = value.trim().replaceAll("'", "''");
    return "'$escaped'";
  }

  Future<void> _saveVolumeBlueprintYaml({
    required String projectId,
    required String volumeBlueprintYaml,
  }) async {
    await _requireProject(projectId);
    final document = const VolumeBlueprintParser().parse(volumeBlueprintYaml);
    for (final draft in document.volumes) {
      await saveChapterVolume(input: draft.toInput(projectId));
    }
  }

  @override
  Future<void> applyCharactersYaml({
    required String projectId,
    required String charactersYaml,
  }) async {
    await _requireProject(projectId);
    final document = const CharacterGraphParser().parse(charactersYaml);
    final now = DateTime.now();
    await _database.transaction(() async {
      final existingRows = await (_database.select(
        _database.novelCharacterRecords,
      )..where((row) => row.projectId.equals(projectId))).get();
      final characterByName = {
        for (final row in existingRows) row.name.trim(): row,
      };
      final idByName = <String, String>{
        for (final row in existingRows) row.name.trim(): row.id,
      };

      for (final draft in document.characters) {
        final existing = characterByName[draft.name];
        final id = existing?.id ?? _uuid.v4();
        idByName[draft.name] = id;
        await _database
            .into(_database.novelCharacterRecords)
            .insertOnConflictUpdate(
              NovelCharacterRecordsCompanion(
                id: Value(id),
                projectId: Value(projectId),
                name: Value(draft.name),
                aliases: Value(
                  _mergeString(
                    draft.fields,
                    'aliases',
                    draft.aliases,
                    existing?.aliases,
                  ),
                ),
                tags: Value(
                  _mergeString(
                    draft.fields,
                    'tags',
                    draft.tags,
                    existing?.tags,
                  ),
                ),
                faction: Value(
                  _mergeString(
                    draft.fields,
                    'faction',
                    draft.faction,
                    existing?.faction,
                  ),
                ),
                role: Value(
                  _mergeString(
                    draft.fields,
                    'role',
                    draft.role,
                    existing?.role,
                  ),
                ),
                longTermGoal: Value(
                  _mergeString(
                    draft.fields,
                    'longTermGoal',
                    draft.longTermGoal,
                    existing?.longTermGoal,
                  ),
                ),
                currentStatus: Value(
                  _mergeString(
                    draft.fields,
                    'currentStatus',
                    draft.currentStatus,
                    existing?.currentStatus,
                  ),
                ),
                secrets: Value(
                  _mergeString(
                    draft.fields,
                    'secrets',
                    draft.secrets,
                    existing?.secrets,
                  ),
                ),
                firstChapterIndex: Value(
                  _mergeInt(
                    draft.fields,
                    'firstChapterIndex',
                    draft.firstChapterIndex,
                    existing?.firstChapterIndex,
                  ),
                ),
                lastChapterIndex: Value(
                  _mergeInt(
                    draft.fields,
                    'lastChapterIndex',
                    draft.lastChapterIndex,
                    existing?.lastChapterIndex,
                  ),
                ),
                createdAt: Value(existing?.createdAt ?? now),
                updatedAt: Value(now),
              ),
            );
      }

      for (final draft in document.relationships) {
        final fromId = idByName[draft.fromName];
        final toId = idByName[draft.toName];
        if (fromId == null || toId == null) {
          throw StateError('关系引用的角色不存在：${draft.fromName} -> ${draft.toName}');
        }
        final existingRelationship = await _findRelationshipByEndpoints(
          projectId: projectId,
          fromCharacterId: fromId,
          toCharacterId: toId,
        );
        final id = existingRelationship?.id ?? _uuid.v4();
        await _database
            .into(_database.novelRelationshipRecords)
            .insertOnConflictUpdate(
              NovelRelationshipRecordsCompanion(
                id: Value(id),
                projectId: Value(projectId),
                fromCharacterId: Value(fromId),
                toCharacterId: Value(toId),
                relationshipType: Value(
                  _mergeString(
                    draft.fields,
                    'type',
                    draft.relationshipType,
                    existingRelationship?.relationshipType,
                  ),
                ),
                strength: Value(
                  _mergeInt(
                        draft.fields,
                        'strength',
                        draft.strength.clamp(-5, 5),
                        existingRelationship?.strength,
                      ) ??
                      0,
                ),
                status: Value(
                  _mergeString(
                    draft.fields,
                    'status',
                    draft.status,
                    existingRelationship?.status,
                  ),
                ),
                description: Value(
                  _mergeString(
                    draft.fields,
                    'description',
                    draft.description,
                    existingRelationship?.description,
                  ),
                ),
                lastChangedChapterIndex: Value(
                  _mergeInt(
                    draft.fields,
                    'lastChangedChapterIndex',
                    draft.lastChangedChapterIndex,
                    existingRelationship?.lastChangedChapterIndex,
                  ),
                ),
                createdAt: Value(existingRelationship?.createdAt ?? now),
                updatedAt: Value(now),
              ),
            );
      }

      // 删除不在文档中的已有角色
      final keptCharacterNames = {for (final c in document.characters) c.name};
      for (final row in existingRows) {
        if (!keptCharacterNames.contains(row.name)) {
          await (_database.delete(
            _database.novelCharacterRecords,
          )..where((r) => r.id.equals(row.id))).go();
        }
      }

      // 删除不在文档中的已有关系
      final existingRelationships = await (_database.select(
        _database.novelRelationshipRecords,
      )..where((r) => r.projectId.equals(projectId))).get();
      final keptRelationshipKeys = {
        for (final d in document.relationships) '${d.fromName}|${d.toName}',
      };
      for (final rel in existingRelationships) {
        final fromName = existingRows
            .where((r) => r.id == rel.fromCharacterId)
            .map((r) => r.name)
            .firstOrNull;
        final toName = existingRows
            .where((r) => r.id == rel.toCharacterId)
            .map((r) => r.name)
            .firstOrNull;
        if (fromName != null &&
            toName != null &&
            !keptRelationshipKeys.contains('$fromName|$toName')) {
          await (_database.delete(
            _database.novelRelationshipRecords,
          )..where((r) => r.id.equals(rel.id))).go();
        }
      }
    });
  }

  @override
  Future<ProjectChapter> saveChapter({
    String? id,
    required ProjectChapterInput input,
  }) async {
    await _validateChapterInput(input);
    final now = DateTime.now();
    final normalizedId = id ?? _uuid.v4();
    final existing = id == null ? null : await findChapter(id);
    final normalizedContent = input.contentMarkdown.trim();
    final contentHash = _hashContent(normalizedContent);
    final contentChanged =
        existing != null && existing.contentHash != contentHash;

    await _database
        .into(_database.projectChapterRecords)
        .insertOnConflictUpdate(
          ProjectChapterRecordsCompanion(
            id: Value(normalizedId),
            projectId: Value(input.projectId),
            chapterPlanId: Value(input.chapterPlanId),
            chapterIndex: Value(input.chapterIndex),
            title: Value(input.title.trim()),
            contentMarkdown: Value(normalizedContent),
            contentHash: Value(contentHash),
            continuityVerdict: Value(input.continuityVerdict.name),
            continuityReportMarkdown: Value(
              input.continuityReportMarkdown.trim(),
            ),
            memorySyncStatus: contentChanged
                ? Value(MemorySyncStatus.idle.name)
                : const Value.absent(),
            memorySyncContentHash: contentChanged
                ? const Value('')
                : const Value.absent(),
            memorySyncProposedRuntimeState: contentChanged
                ? const Value('')
                : const Value.absent(),
            memorySyncProposedRuntimeThreads: contentChanged
                ? const Value('')
                : const Value.absent(),
            memorySyncProposedStorySummary: contentChanged
                ? const Value('')
                : const Value.absent(),
            memorySyncProposedContinuityIndex: contentChanged
                ? const Value('')
                : const Value.absent(),
            memorySyncProposedChapterArchiveMarkdown: contentChanged
                ? const Value('')
                : const Value.absent(),
            memorySyncPatchYaml: contentChanged
                ? const Value('')
                : const Value.absent(),
            createdAt: Value(existing?.createdAt ?? now),
            updatedAt: Value(now),
          ),
        );
    final saved = await findChapter(normalizedId);
    if (saved == null) {
      throw StateError('Project chapter was not saved.');
    }
    return saved;
  }

  @override
  Future<ChapterIllustration> createChapterIllustration(
    ChapterIllustrationInput input,
  ) async {
    await _validateIllustrationInput(input);
    final now = DateTime.now();
    final id = _uuid.v4();
    await _database
        .into(_database.chapterIllustrationRecords)
        .insert(
          ChapterIllustrationRecordsCompanion.insert(
            id: id,
            projectId: input.projectId,
            chapterId: input.chapterId,
            chapterPlanId: input.chapterPlanId,
            paragraphIndex: input.paragraphIndex,
            anchorTextHash: Value(input.anchorTextHash.trim()),
            selectedText: Value(input.selectedText.trim()),
            prompt: Value(input.prompt.trim()),
            providerId: Value(input.providerId.trim()),
            modelName: Value(input.modelName.trim()),
            localPath: Value(input.localPath.trim()),
            mimeType: Value(_normalizeMimeType(input.mimeType)),
            status: Value(ChapterIllustrationStatus.draft.name),
            createdAt: now,
            updatedAt: now,
            acceptedAt: const Value(null),
          ),
        );
    final saved = await findChapterIllustration(id);
    if (saved == null) {
      throw StateError('Chapter illustration was not saved.');
    }
    return saved;
  }

  @override
  Future<ChapterIllustration> insertChapterIllustration(String id) async {
    final illustration = await findChapterIllustration(id);
    if (illustration == null) {
      throw StateError('Chapter illustration does not exist: $id');
    }
    final now = DateTime.now();
    await (_database.update(
      _database.chapterIllustrationRecords,
    )..where((row) => row.id.equals(id))).write(
      ChapterIllustrationRecordsCompanion(
        status: Value(ChapterIllustrationStatus.inserted.name),
        acceptedAt: Value(illustration.acceptedAt ?? now),
        updatedAt: Value(now),
      ),
    );
    final saved = await findChapterIllustration(id);
    if (saved == null) {
      throw StateError('Chapter illustration was not updated.');
    }
    return saved;
  }

  @override
  Future<ChapterIllustration> removeChapterIllustrationFromText(
    String id,
  ) async {
    final illustration = await findChapterIllustration(id);
    if (illustration == null) {
      throw StateError('Chapter illustration does not exist: $id');
    }
    final now = DateTime.now();
    await (_database.update(
      _database.chapterIllustrationRecords,
    )..where((row) => row.id.equals(id))).write(
      ChapterIllustrationRecordsCompanion(
        status: Value(ChapterIllustrationStatus.unused.name),
        updatedAt: Value(now),
      ),
    );
    final saved = await findChapterIllustration(id);
    if (saved == null) {
      throw StateError('Chapter illustration was not updated.');
    }
    return saved;
  }

  @override
  Future<void> deleteChapterIllustration(String id) async {
    final illustration = await findChapterIllustration(id);
    await (_database.delete(
      _database.chapterIllustrationRecords,
    )..where((row) => row.id.equals(id))).go();
    if (illustration == null || illustration.localPath.trim().isEmpty) {
      return;
    }
    try {
      final file = File(illustration.localPath);
      if (await file.exists()) {
        await file.delete();
      }
    } on Object {
      // The database record is the source of truth; file cleanup is best effort.
    }
  }

  @override
  Future<ChapterIllustrationGenerationRun>
  createChapterIllustrationGenerationRun(
    ChapterIllustrationGenerationRunInput input,
  ) async {
    await _validateIllustrationGenerationInput(input);
    final now = DateTime.now();
    final runId = _uuid.v4();
    final taskId = _uuid.v4();
    final chapter = await findChapter(input.chapterId);
    final title = chapter?.title.trim();

    await _database.transaction(() async {
      await _database
          .into(_database.workflowTaskRecords)
          .insert(
            WorkflowTaskRecordsCompanion.insert(
              id: taskId,
              kind: chapterIllustrationGenerationWorkflowTaskKind,
              status: WorkflowTaskStatus.pending.name,
              title: title == null || title.isEmpty ? '插图生成任务' : '插图生成：$title',
              stage: const Value('queued'),
              errorMessage: const Value(null),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _database
          .into(_database.chapterIllustrationGenerationRunRecords)
          .insert(
            ChapterIllustrationGenerationRunRecordsCompanion.insert(
              id: runId,
              workflowTaskId: taskId,
              projectId: input.projectId,
              chapterId: input.chapterId,
              chapterPlanId: input.chapterPlanId,
              paragraphIndex: input.paragraphIndex,
              anchorTextHash: Value(input.anchorTextHash.trim()),
              selectedText: Value(input.selectedText.trim()),
              prompt: Value(input.prompt.trim()),
              providerId: Value(input.providerId.trim()),
              modelName: Value(input.modelName.trim()),
              aspectRatio: Value(input.aspectRatio.trim()),
              size: Value(input.size.trim()),
              quality: Value(input.quality.trim()),
              responseFormat: Value(input.responseFormat.trim()),
              status: ChapterIllustrationGenerationStatus.pending.name,
              stage: const Value(null),
              errorMessage: const Value(null),
              logs: const Value(''),
              illustrationId: const Value(null),
              createdAt: now,
              updatedAt: now,
              startedAt: const Value(null),
              completedAt: const Value(null),
            ),
          );
    });

    final saved = await findChapterIllustrationGenerationRun(runId);
    if (saved == null) {
      throw StateError('Chapter illustration generation run was not created.');
    }
    return saved;
  }

  @override
  Future<ChapterIllustrationGenerationRun>
  createChapterIllustrationGenerationRunFromExisting(String id) async {
    final existing = await findChapterIllustrationGenerationRun(id);
    if (existing == null) {
      throw StateError(
        'Chapter illustration generation run does not exist: $id',
      );
    }
    return createChapterIllustrationGenerationRun(
      ChapterIllustrationGenerationRunInput(
        projectId: existing.projectId,
        chapterId: existing.chapterId,
        chapterPlanId: existing.chapterPlanId,
        paragraphIndex: existing.paragraphIndex,
        anchorTextHash: existing.anchorTextHash,
        selectedText: existing.selectedText,
        prompt: existing.prompt,
        providerId: existing.providerId,
        modelName: existing.modelName,
        aspectRatio: existing.aspectRatio,
        size: existing.size,
        quality: existing.quality,
        responseFormat: existing.responseFormat,
      ),
    );
  }

  @override
  Future<ChapterIllustrationGenerationRun>
  updateChapterIllustrationGenerationRunState({
    required String id,
    required ChapterIllustrationGenerationStatus status,
    ChapterIllustrationGenerationStage? stage,
    String? errorMessage,
    String? logs,
    String? illustrationId,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    final run = await findChapterIllustrationGenerationRun(id);
    if (run == null) {
      throw StateError(
        'Chapter illustration generation run does not exist: $id',
      );
    }
    final now = DateTime.now();

    await _database.transaction(() async {
      await (_database.update(
        _database.chapterIllustrationGenerationRunRecords,
      )..where((row) => row.id.equals(id))).write(
        ChapterIllustrationGenerationRunRecordsCompanion(
          status: Value(status.name),
          stage: Value(stage?.name),
          errorMessage: Value(errorMessage),
          logs: logs == null ? const Value.absent() : Value(logs),
          illustrationId: illustrationId == null
              ? const Value.absent()
              : Value(illustrationId),
          startedAt: startedAt == null
              ? const Value.absent()
              : Value(startedAt),
          completedAt: completedAt == null
              ? const Value.absent()
              : Value(completedAt),
          updatedAt: Value(now),
        ),
      );
      await _updateWorkflowTaskForIllustrationGenerationRun(
        workflowTaskId: run.workflowTaskId,
        status: status,
        stage: stage,
        errorMessage: errorMessage,
        updatedAt: now,
      );
    });

    final saved = await findChapterIllustrationGenerationRun(id);
    if (saved == null) {
      throw StateError('Chapter illustration generation run was not updated.');
    }
    return saved;
  }

  @override
  Future<int> markInterruptedChapterIllustrationGenerationRunsFailed() async {
    final interrupted =
        await (_database.select(
              _database.chapterIllustrationGenerationRunRecords,
            )..where(
              (run) =>
                  run.status.equals(
                    ChapterIllustrationGenerationStatus.pending.name,
                  ) |
                  run.status.equals(
                    ChapterIllustrationGenerationStatus.running.name,
                  ),
            ))
            .get();
    if (interrupted.isEmpty) {
      return 0;
    }
    final now = DateTime.now();
    const message = '应用重启，任务已中断，可重试。';
    await _database.transaction(() async {
      for (final run in interrupted) {
        await (_database.update(
          _database.chapterIllustrationGenerationRunRecords,
        )..where((row) => row.id.equals(run.id))).write(
          ChapterIllustrationGenerationRunRecordsCompanion(
            status: Value(ChapterIllustrationGenerationStatus.failed.name),
            stage: const Value(null),
            errorMessage: const Value(message),
            updatedAt: Value(now),
            completedAt: Value(now),
          ),
        );
        await _updateWorkflowTaskForIllustrationGenerationRun(
          workflowTaskId: run.workflowTaskId,
          status: ChapterIllustrationGenerationStatus.failed,
          stage: null,
          errorMessage: message,
          updatedAt: now,
        );
      }
    });
    return interrupted.length;
  }

  @override
  Future<void> deleteChapterIllustrationGenerationRun(String id) async {
    final run = await findChapterIllustrationGenerationRun(id);
    if (run == null) {
      return;
    }
    await _database.transaction(() async {
      await (_database.delete(_database.workflowPromptTraceRecords)
            ..where((trace) => trace.workflowTaskId.equals(run.workflowTaskId)))
          .go();
      await (_database.delete(
        _database.chapterIllustrationGenerationRunRecords,
      )..where((row) => row.id.equals(id))).go();
      await (_database.delete(
        _database.workflowTaskRecords,
      )..where((task) => task.id.equals(run.workflowTaskId))).go();
    });
  }

  @override
  Future<ProjectChapter> saveMemorySyncProposal(
    MemorySyncProposalInput input,
  ) async {
    final chapter = await findChapter(input.chapterId);
    if (chapter == null) {
      throw StateError('Project chapter does not exist: ${input.chapterId}');
    }
    if (chapter.contentHash != input.contentHash) {
      throw StateError('Memory sync proposal does not match chapter content.');
    }
    final now = DateTime.now();
    await (_database.update(
      _database.projectChapterRecords,
    )..where((row) => row.id.equals(input.chapterId))).write(
      ProjectChapterRecordsCompanion(
        memorySyncStatus: Value(MemorySyncStatus.pendingReview.name),
        memorySyncContentHash: Value(input.contentHash),
        memorySyncProposedRuntimeState: Value(
          input.proposedMemory.runtimeState.trim(),
        ),
        memorySyncProposedRuntimeThreads: Value(
          input.proposedMemory.runtimeThreads.trim(),
        ),
        memorySyncProposedStorySummary: Value(
          input.proposedMemory.storySummary.trim(),
        ),
        memorySyncProposedContinuityIndex: Value(
          input.proposedMemory.continuityIndex.trim(),
        ),
        memorySyncProposedChapterArchiveMarkdown: Value(
          input.proposedMemory.chapterArchiveMarkdown.trim(),
        ),
        memorySyncPatchYaml: Value(normalizeMemoryPatchYaml(input.patchYaml)),
        updatedAt: Value(now),
      ),
    );
    final saved = await findChapter(input.chapterId);
    if (saved == null) {
      throw StateError('Project chapter was not updated.');
    }
    return saved;
  }

  @override
  Future<ProjectChapter> applyMemorySyncPatch(String chapterId) async {
    final chapter = await findChapter(chapterId);
    if (chapter == null) {
      throw StateError('Project chapter does not exist: $chapterId');
    }
    if (chapter.memorySyncStatus != MemorySyncStatus.pendingReview) {
      throw StateError('没有待审阅的记忆同步提案。');
    }
    if (chapter.memorySyncContentHash != chapter.contentHash) {
      throw StateError('记忆同步提案已过期。');
    }
    final patch = const MemoryPatchParser().parse(chapter.memorySyncPatchYaml);
    if (patch.hasCharacterGraphPatch) {
      await applyCharactersYaml(
        projectId: chapter.projectId,
        charactersYaml: patch.rawYaml,
      );
    }
    final currentMemory =
        (await findRuntimeMemory(chapter.projectId))?.state ??
        const RuntimeMemoryState();
    await saveRuntimeMemory(
      projectId: chapter.projectId,
      state: _mergeRuntimeMemoryPatch(currentMemory, patch.runtimeMemory),
    );
    final now = DateTime.now();
    await (_database.update(
      _database.projectChapterRecords,
    )..where((row) => row.id.equals(chapterId))).write(
      ProjectChapterRecordsCompanion(
        memorySyncStatus: Value(MemorySyncStatus.synced.name),
        updatedAt: Value(now),
      ),
    );
    final saved = await findChapter(chapterId);
    if (saved == null) {
      throw StateError('Project chapter was not updated.');
    }
    return saved;
  }

  @override
  Future<ProjectChapter> discardMemorySyncPatch(String chapterId) async {
    final chapter = await findChapter(chapterId);
    if (chapter == null) {
      throw StateError('Project chapter does not exist: $chapterId');
    }
    if (chapter.memorySyncStatus != MemorySyncStatus.pendingReview) {
      throw StateError('没有待审阅的记忆同步提案。');
    }
    final now = DateTime.now();
    await (_database.update(
      _database.projectChapterRecords,
    )..where((row) => row.id.equals(chapterId))).write(
      ProjectChapterRecordsCompanion(
        memorySyncStatus: Value(MemorySyncStatus.discarded.name),
        updatedAt: Value(now),
      ),
    );
    final saved = await findChapter(chapterId);
    if (saved == null) {
      throw StateError('Project chapter was not updated.');
    }
    return saved;
  }

  String _mergeString(
    Set<String> fields,
    String key,
    String patchValue,
    String? existingValue,
  ) {
    if (fields.contains(key)) {
      return patchValue.trim();
    }
    return existingValue?.trim() ?? '';
  }

  int? _mergeInt(
    Set<String> fields,
    String key,
    int? patchValue,
    int? existingValue,
  ) {
    if (fields.contains(key)) {
      return patchValue;
    }
    return existingValue;
  }

  RuntimeMemoryState _mergeRuntimeMemoryPatch(
    RuntimeMemoryState current,
    YamlMap? memory,
  ) {
    if (memory == null) {
      return current;
    }
    return RuntimeMemoryState(
      runtimeState:
          _yamlPatchString(memory, 'runtimeState') ?? current.runtimeState,
      runtimeThreads:
          _yamlPatchString(memory, 'runtimeThreads') ?? current.runtimeThreads,
      storySummary:
          _yamlPatchString(memory, 'storySummary') ?? current.storySummary,
      continuityIndex:
          _yamlPatchString(memory, 'continuityIndex') ??
          current.continuityIndex,
      chapterArchiveMarkdown: _mergeChapterArchive(
        current.chapterArchiveMarkdown,
        _yamlPatchString(memory, 'chapterArchiveMarkdown'),
      ),
    );
  }

  String? _yamlPatchString(YamlMap map, String key) {
    for (final entry in map.entries) {
      if (entry.key.toString() == key) {
        return _yamlString(entry.value);
      }
    }
    return null;
  }

  String _yamlString(Object? value) {
    if (value == null) {
      return '';
    }
    if (value is YamlScalar) {
      return value.value?.toString().trim() ?? '';
    }
    if (value is String) {
      return value.trim();
    }
    return value.toString().trim();
  }

  String _mergeChapterArchive(String current, String? patch) {
    final currentTrimmed = current.trim();
    final patchTrimmed = patch?.trim();
    if (patchTrimmed == null) {
      return currentTrimmed;
    }
    if (patchTrimmed.isEmpty) {
      return '';
    }
    if (currentTrimmed.isEmpty) {
      return patchTrimmed;
    }
    if (currentTrimmed.contains(patchTrimmed)) {
      return currentTrimmed;
    }
    return '$currentTrimmed\n\n$patchTrimmed';
  }

  @override
  Future<AssetGenerationRun> createAssetGenerationRun(
    AssetGenerationRunInput input,
  ) async {
    if (input.projectId.trim().isEmpty) {
      throw StateError('资产生成任务需要 Project。');
    }
    await _requireProject(input.projectId);
    final now = DateTime.now();
    final runId = _uuid.v4();
    final taskId = _uuid.v4();

    await _database.transaction(() async {
      if (await hasRunningAssetGeneration(
        projectId: input.projectId,
        kind: input.kind,
      )) {
        throw StateError('项目已有运行中的${_assetKindLabel(input.kind)}生成任务。');
      }
      await _database
          .into(_database.workflowTaskRecords)
          .insert(
            WorkflowTaskRecordsCompanion.insert(
              id: taskId,
              kind: assetGenerationWorkflowTaskKind,
              status: WorkflowTaskStatus.pending.name,
              title: _assetGenerationTaskTitle(input.kind),
              stage: const Value('queued'),
              errorMessage: const Value(null),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _database
          .into(_database.assetGenerationRunRecords)
          .insert(
            AssetGenerationRunRecordsCompanion.insert(
              id: runId,
              workflowTaskId: taskId,
              projectId: input.projectId,
              targetVolumeId: const Value(null),
              kind: input.kind.name,
              providerId: input.providerId.trim(),
              modelName: input.modelName.trim(),
              status: AssetGenerationStatus.pending.name,
              stage: const Value(null),
              errorMessage: const Value(null),
              logs: const Value(''),
              draftMarkdown: const Value(''),
              createdAt: now,
              updatedAt: now,
              startedAt: const Value(null),
              completedAt: const Value(null),
              previousRunId: Value(input.previousRunId),
              userFeedback: Value(input.userFeedback),
            ),
          );
    });

    final saved = await findAssetGenerationRun(runId);
    if (saved == null) {
      throw StateError('Asset generation run was not created.');
    }
    return saved;
  }

  @override
  Future<AssetGenerationRun> createVolumeDetailGenerationRun({
    required String projectId,
    required String volumeId,
  }) async {
    await _requireProject(projectId);
    final volume = await _findChapterVolume(volumeId);
    if (volume == null || volume.projectId != projectId) {
      throw StateError('分卷不存在。');
    }
    final now = DateTime.now();
    final runId = _uuid.v4();
    final taskId = _uuid.v4();
    await _database.transaction(() async {
      if (await hasRunningAssetGeneration(
        projectId: projectId,
        kind: AssetGenerationKind.outlineDetailYaml,
        targetVolumeId: volumeId,
      )) {
        throw StateError('该分卷已有运行中的章节细纲生成任务。');
      }
      await _database
          .into(_database.workflowTaskRecords)
          .insert(
            WorkflowTaskRecordsCompanion.insert(
              id: taskId,
              kind: assetGenerationWorkflowTaskKind,
              status: WorkflowTaskStatus.pending.name,
              title: '资产生成：${volume.title}章节细纲',
              stage: const Value('queued'),
              errorMessage: const Value(null),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _database
          .into(_database.assetGenerationRunRecords)
          .insert(
            AssetGenerationRunRecordsCompanion.insert(
              id: runId,
              workflowTaskId: taskId,
              projectId: projectId,
              targetVolumeId: Value(volumeId),
              kind: AssetGenerationKind.outlineDetailYaml.name,
              providerId: '',
              modelName: '',
              status: AssetGenerationStatus.pending.name,
              stage: const Value(null),
              errorMessage: const Value(null),
              logs: const Value(''),
              draftMarkdown: const Value(''),
              createdAt: now,
              updatedAt: now,
              startedAt: const Value(null),
              completedAt: const Value(null),
            ),
          );
    });
    final saved = await findAssetGenerationRun(runId);
    if (saved == null) {
      throw StateError('Asset generation run was not created.');
    }
    return saved;
  }

  @override
  Future<AssetGenerationRun> updateAssetGenerationRunState({
    required String id,
    required AssetGenerationStatus status,
    AssetGenerationStage? stage,
    String? providerId,
    String? modelName,
    String? errorMessage,
    String? logs,
    String? draftMarkdown,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    final run = await findAssetGenerationRun(id);
    if (run == null) {
      throw StateError('Asset generation run does not exist: $id');
    }
    final now = DateTime.now();

    await _database.transaction(() async {
      await (_database.update(
        _database.assetGenerationRunRecords,
      )..where((row) => row.id.equals(id))).write(
        AssetGenerationRunRecordsCompanion(
          status: Value(status.name),
          stage: Value(stage?.name),
          providerId: providerId == null
              ? const Value.absent()
              : Value(providerId.trim()),
          modelName: modelName == null
              ? const Value.absent()
              : Value(modelName.trim()),
          errorMessage: Value(errorMessage),
          logs: logs == null ? const Value.absent() : Value(logs),
          draftMarkdown: draftMarkdown == null
              ? const Value.absent()
              : Value(draftMarkdown.trim()),
          startedAt: startedAt == null
              ? const Value.absent()
              : Value(startedAt),
          completedAt: completedAt == null
              ? const Value.absent()
              : Value(completedAt),
          updatedAt: Value(now),
        ),
      );
      await _updateWorkflowTaskForAssetGenerationRun(
        workflowTaskId: run.workflowTaskId,
        status: status,
        stage: stage,
        errorMessage: errorMessage,
        updatedAt: now,
      );
    });

    final saved = await findAssetGenerationRun(id);
    if (saved == null) {
      throw StateError('Asset generation run was not updated.');
    }
    return saved;
  }

  @override
  Future<ProjectBible> applyAssetGenerationDraft(String runId) async {
    final run = await findAssetGenerationRun(runId);
    if (run == null) {
      throw StateError('Asset generation run does not exist: $runId');
    }
    if (run.status != AssetGenerationStatus.succeeded &&
        run.status != AssetGenerationStatus.applied) {
      throw StateError('只有已生成的资产草稿可以应用。');
    }
    final draft = run.draftMarkdown.trim();
    if (draft.isEmpty) {
      throw StateError('资产草稿为空，无法应用。');
    }

    final bible = await ensureProjectBible(run.projectId);
    final saved = switch (run.kind) {
      AssetGenerationKind.worldBuilding => await saveProjectBible(
        ProjectBibleInput(
          projectId: run.projectId,
          descriptionMarkdown: bible.descriptionMarkdown,
          worldBuildingMarkdown: draft,
          charactersBlueprintMarkdown: bible.charactersBlueprintMarkdown,
          outlineMasterMarkdown: bible.outlineMasterMarkdown,
          outlineDetailYaml: bible.outlineDetailYaml,
        ),
      ),
      AssetGenerationKind.charactersBlueprint =>
        await _applyCharacterDraftAndReturnBible(run.projectId, draft, bible),
      AssetGenerationKind.outlineMaster => await saveProjectBible(
        ProjectBibleInput(
          projectId: run.projectId,
          descriptionMarkdown: bible.descriptionMarkdown,
          worldBuildingMarkdown: bible.worldBuildingMarkdown,
          charactersBlueprintMarkdown: bible.charactersBlueprintMarkdown,
          outlineMasterMarkdown: draft,
          outlineDetailYaml: bible.outlineDetailYaml,
        ),
      ),
      AssetGenerationKind.volumeBlueprintYaml =>
        await _applyVolumeBlueprintAndReturnBible(run.projectId, draft, bible),
      AssetGenerationKind.outlineDetailYaml => await _applyOutlineDetailDraft(
        run: run,
        draft: draft,
        bible: bible,
      ),
    };

    await updateAssetGenerationRunState(
      id: run.id,
      status: AssetGenerationStatus.applied,
      stage: null,
      errorMessage: null,
      completedAt: run.completedAt,
    );
    return saved;
  }

  Future<ProjectBible> _applyCharacterDraftAndReturnBible(
    String projectId,
    String draft,
    ProjectBible bible,
  ) async {
    await applyCharactersYaml(projectId: projectId, charactersYaml: draft);
    return bible;
  }

  Future<ProjectBible> _applyVolumeBlueprintAndReturnBible(
    String projectId,
    String draft,
    ProjectBible bible,
  ) async {
    await _saveVolumeBlueprintYaml(
      projectId: projectId,
      volumeBlueprintYaml: draft,
    );
    // 同步 outline detail YAML，使 YAML 编辑器显示分卷结构
    final document = const VolumeBlueprintParser().parse(draft);
    final outlineDoc = OutlineDetailDocument(
      volumes: [
        for (final v in document.volumes)
          OutlineVolumeDraft(
            volumeIndex: v.volumeIndex,
            title: v.title,
            chapters: const [],
          ),
      ],
    );
    final outlineYaml = _outlineDetailYamlFromDocument(outlineDoc);
    return saveOutlineDetailYaml(
      projectId: projectId,
      outlineDetailYaml: outlineYaml,
    );
  }

  @override
  Future<ChapterGenerationRun> createChapterGenerationRun(
    ChapterGenerationRunInput input,
  ) async {
    if (input.projectId.trim().isEmpty) {
      throw StateError('章节生成任务需要 Project。');
    }
    if (input.chapterPlanId.trim().isEmpty) {
      throw StateError('章节生成任务需要 Chapter Plan。');
    }
    final now = DateTime.now();
    final runId = _uuid.v4();
    final taskId = _uuid.v4();
    final plan = await findChapterPlan(input.chapterPlanId);
    final title = _generationTaskTitle(plan);

    await _database.transaction(() async {
      await _database
          .into(_database.workflowTaskRecords)
          .insert(
            WorkflowTaskRecordsCompanion.insert(
              id: taskId,
              kind: chapterGenerationWorkflowTaskKind,
              status: WorkflowTaskStatus.pending.name,
              title: title,
              stage: const Value('queued'),
              errorMessage: const Value(null),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _database
          .into(_database.chapterGenerationRunRecords)
          .insert(
            ChapterGenerationRunRecordsCompanion.insert(
              id: runId,
              workflowTaskId: taskId,
              projectId: input.projectId,
              chapterPlanId: input.chapterPlanId,
              chapterId: const Value(null),
              providerId: input.providerId.trim(),
              modelName: input.modelName.trim(),
              status: ChapterGenerationStatus.pending.name,
              stage: const Value(null),
              errorMessage: const Value(null),
              logs: const Value(''),
              contextWarningsMarkdown: const Value(''),
              draftMarkdown: const Value(''),
              continuityVerdict: Value(ContinuityVerdict.pass.name),
              continuityReportMarkdown: const Value(''),
              createdAt: now,
              updatedAt: now,
              startedAt: const Value(null),
              completedAt: const Value(null),
            ),
          );
    });

    final saved = await findChapterGenerationRun(runId);
    if (saved == null) {
      throw StateError('Chapter generation run was not created.');
    }
    return saved;
  }

  @override
  Future<ChapterGenerationRun> updateChapterGenerationRunState({
    required String id,
    required ChapterGenerationStatus status,
    ChapterGenerationStage? stage,
    String? chapterId,
    String? providerId,
    String? modelName,
    String? errorMessage,
    String? logs,
    String? contextWarningsMarkdown,
    String? draftMarkdown,
    ContinuityVerdict? continuityVerdict,
    String? continuityReportMarkdown,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    final run = await findChapterGenerationRun(id);
    if (run == null) {
      throw StateError('Chapter generation run does not exist: $id');
    }
    if (chapterId != null) {
      final chapter = await findChapter(chapterId);
      if (chapter == null) {
        throw StateError('Project chapter does not exist: $chapterId');
      }
      if (chapter.projectId != run.projectId ||
          chapter.chapterPlanId != run.chapterPlanId) {
        throw StateError('Chapter generation run does not match chapter.');
      }
    }
    final now = DateTime.now();

    await _database.transaction(() async {
      await (_database.update(
        _database.chapterGenerationRunRecords,
      )..where((row) => row.id.equals(id))).write(
        ChapterGenerationRunRecordsCompanion(
          status: Value(status.name),
          stage: Value(stage?.name),
          chapterId: chapterId == null
              ? const Value.absent()
              : Value(chapterId),
          providerId: providerId == null
              ? const Value.absent()
              : Value(providerId.trim()),
          modelName: modelName == null
              ? const Value.absent()
              : Value(modelName.trim()),
          errorMessage: Value(errorMessage),
          logs: logs == null ? const Value.absent() : Value(logs),
          contextWarningsMarkdown: contextWarningsMarkdown == null
              ? const Value.absent()
              : Value(contextWarningsMarkdown),
          draftMarkdown: draftMarkdown == null
              ? const Value.absent()
              : Value(draftMarkdown.trim()),
          continuityVerdict: continuityVerdict == null
              ? const Value.absent()
              : Value(continuityVerdict.name),
          continuityReportMarkdown: continuityReportMarkdown == null
              ? const Value.absent()
              : Value(continuityReportMarkdown.trim()),
          startedAt: startedAt == null
              ? const Value.absent()
              : Value(startedAt),
          completedAt: completedAt == null
              ? const Value.absent()
              : Value(completedAt),
          updatedAt: Value(now),
        ),
      );
      await _updateWorkflowTaskForGenerationRun(
        workflowTaskId: run.workflowTaskId,
        status: status,
        stage: stage,
        errorMessage: errorMessage,
        updatedAt: now,
      );
    });

    final saved = await findChapterGenerationRun(id);
    if (saved == null) {
      throw StateError('Chapter generation run was not updated.');
    }
    return saved;
  }

  @override
  Future<ChapterGenerationBatch> createChapterGenerationBatch(
    ChapterGenerationBatchInput input,
  ) async {
    await _validateChapterGenerationBatchInput(input);
    final now = DateTime.now();
    final batchId = _uuid.v4();
    final taskId = _uuid.v4();

    await _database.transaction(() async {
      await _database
          .into(_database.workflowTaskRecords)
          .insert(
            WorkflowTaskRecordsCompanion.insert(
              id: taskId,
              kind: chapterGenerationBatchWorkflowTaskKind,
              status: WorkflowTaskStatus.pending.name,
              title: '批量草稿：${input.chapterPlanIds.length} 章',
              stage: const Value('queued'),
              errorMessage: const Value(null),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _database
          .into(_database.chapterGenerationBatchRecords)
          .insert(
            ChapterGenerationBatchRecordsCompanion.insert(
              id: batchId,
              workflowTaskId: taskId,
              projectId: input.projectId,
              providerId: input.providerId.trim(),
              modelName: input.modelName.trim(),
              status: ChapterGenerationBatchStatus.pending.name,
              errorMessage: const Value(null),
              totalCount: Value(input.chapterPlanIds.length),
              syncedCount: const Value(0),
              failedCount: const Value(0),
              logs: const Value(''),
              createdAt: now,
              updatedAt: now,
              startedAt: const Value(null),
              completedAt: const Value(null),
            ),
          );
      for (var index = 0; index < input.chapterPlanIds.length; index += 1) {
        await _database
            .into(_database.chapterGenerationBatchItemRecords)
            .insert(
              ChapterGenerationBatchItemRecordsCompanion.insert(
                id: _uuid.v4(),
                batchId: batchId,
                projectId: input.projectId,
                chapterPlanId: input.chapterPlanIds[index],
                chapterId: const Value(null),
                latestRunId: const Value(null),
                position: index,
                status: ChapterGenerationBatchItemStatus.waiting.name,
                errorMessage: const Value(null),
                draftAttemptCount: const Value(0),
                patchAttemptCount: const Value(0),
                logs: const Value(''),
                createdAt: now,
                updatedAt: now,
                startedAt: const Value(null),
                completedAt: const Value(null),
                syncedAt: const Value(null),
              ),
            );
      }
    });

    final saved = await findChapterGenerationBatch(batchId);
    if (saved == null) {
      throw StateError('Chapter generation batch was not created.');
    }
    return saved;
  }

  @override
  Future<ChapterGenerationBatch> updateChapterGenerationBatchState({
    required String id,
    required ChapterGenerationBatchStatus status,
    String? providerId,
    String? modelName,
    String? errorMessage,
    String? logs,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    final batch = await findChapterGenerationBatch(id);
    if (batch == null) {
      throw StateError('Chapter generation batch does not exist: $id');
    }
    final now = DateTime.now();
    final counts = await _chapterGenerationBatchCounts(id);
    await _database.transaction(() async {
      await (_database.update(
        _database.chapterGenerationBatchRecords,
      )..where((row) => row.id.equals(id))).write(
        ChapterGenerationBatchRecordsCompanion(
          status: Value(status.name),
          providerId: providerId == null
              ? const Value.absent()
              : Value(providerId.trim()),
          modelName: modelName == null
              ? const Value.absent()
              : Value(modelName.trim()),
          errorMessage: Value(errorMessage),
          logs: logs == null ? const Value.absent() : Value(logs),
          syncedCount: Value(counts.syncedCount),
          failedCount: Value(counts.failedCount),
          startedAt: startedAt == null
              ? const Value.absent()
              : Value(startedAt),
          completedAt: completedAt == null
              ? const Value.absent()
              : Value(completedAt),
          updatedAt: Value(now),
        ),
      );
      await _updateWorkflowTaskForGenerationBatch(
        workflowTaskId: batch.workflowTaskId,
        status: status,
        errorMessage: errorMessage,
        updatedAt: now,
      );
    });
    final saved = await findChapterGenerationBatch(id);
    if (saved == null) {
      throw StateError('Chapter generation batch was not updated.');
    }
    return saved;
  }

  @override
  Future<ChapterGenerationBatchItem> updateChapterGenerationBatchItemState({
    required String id,
    required ChapterGenerationBatchItemStatus status,
    String? errorMessage,
    String? chapterId,
    String? latestRunId,
    int? draftAttemptCount,
    int? patchAttemptCount,
    String? logs,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? syncedAt,
    bool clearStartedAt = false,
    bool clearCompletedAt = false,
    bool clearSyncedAt = false,
  }) async {
    final item = await findChapterGenerationBatchItem(id);
    if (item == null) {
      throw StateError('Chapter generation batch item does not exist: $id');
    }
    if (chapterId != null) {
      final chapter = await findChapter(chapterId);
      if (chapter == null ||
          chapter.projectId != item.projectId ||
          chapter.chapterPlanId != item.chapterPlanId) {
        throw StateError(
          'Chapter generation batch item does not match chapter.',
        );
      }
    }
    if (latestRunId != null) {
      final run = await findChapterGenerationRun(latestRunId);
      if (run == null ||
          run.projectId != item.projectId ||
          run.chapterPlanId != item.chapterPlanId) {
        throw StateError('Chapter generation batch item does not match run.');
      }
    }
    final now = DateTime.now();
    await (_database.update(
      _database.chapterGenerationBatchItemRecords,
    )..where((row) => row.id.equals(id))).write(
      ChapterGenerationBatchItemRecordsCompanion(
        status: Value(status.name),
        errorMessage: Value(errorMessage),
        chapterId: chapterId == null ? const Value.absent() : Value(chapterId),
        latestRunId: latestRunId == null
            ? const Value.absent()
            : Value(latestRunId),
        draftAttemptCount: draftAttemptCount == null
            ? const Value.absent()
            : Value(draftAttemptCount),
        patchAttemptCount: patchAttemptCount == null
            ? const Value.absent()
            : Value(patchAttemptCount),
        logs: logs == null ? const Value.absent() : Value(logs),
        startedAt: clearStartedAt
            ? const Value(null)
            : startedAt == null
            ? const Value.absent()
            : Value(startedAt),
        completedAt: clearCompletedAt
            ? const Value(null)
            : completedAt == null
            ? const Value.absent()
            : Value(completedAt),
        syncedAt: clearSyncedAt
            ? const Value(null)
            : syncedAt == null
            ? const Value.absent()
            : Value(syncedAt),
        updatedAt: Value(now),
      ),
    );
    await _refreshChapterGenerationBatchCounts(item.batchId);
    final saved = await findChapterGenerationBatchItem(id);
    if (saved == null) {
      throw StateError('Chapter generation batch item was not updated.');
    }
    return saved;
  }

  @override
  Future<ChapterEnrichmentBatch> createChapterEnrichmentBatch(
    ChapterEnrichmentBatchInput input,
  ) async {
    await _validateChapterEnrichmentBatchInput(input);
    final now = DateTime.now();
    final batchId = _uuid.v4();
    final taskId = _uuid.v4();

    await _database.transaction(() async {
      await _database
          .into(_database.workflowTaskRecords)
          .insert(
            WorkflowTaskRecordsCompanion.insert(
              id: taskId,
              kind: chapterEnrichmentWorkflowTaskKind,
              status: WorkflowTaskStatus.pending.name,
              title: '章节加料：${input.chapterIds.length} 章',
              stage: const Value('queued'),
              errorMessage: const Value(null),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _database
          .into(_database.chapterEnrichmentBatchRecords)
          .insert(
            ChapterEnrichmentBatchRecordsCompanion.insert(
              id: batchId,
              workflowTaskId: taskId,
              projectId: input.projectId,
              instruction: input.instruction.trim(),
              expansionRatioPercent: Value(input.expansionRatioPercent),
              providerId: input.providerId.trim(),
              modelName: input.modelName.trim(),
              status: ChapterEnrichmentBatchStatus.pending.name,
              errorMessage: const Value(null),
              totalCount: Value(input.chapterIds.length),
              generatedCount: const Value(0),
              failedCount: const Value(0),
              appliedCount: const Value(0),
              logs: const Value(''),
              createdAt: now,
              updatedAt: now,
              startedAt: const Value(null),
              completedAt: const Value(null),
            ),
          );
      for (var index = 0; index < input.chapterIds.length; index += 1) {
        await _database
            .into(_database.chapterEnrichmentItemRecords)
            .insert(
              ChapterEnrichmentItemRecordsCompanion.insert(
                id: _uuid.v4(),
                batchId: batchId,
                projectId: input.projectId,
                chapterId: input.chapterIds[index],
                position: index,
                status: ChapterEnrichmentItemStatus.waiting.name,
                errorMessage: const Value(null),
                originalContentMarkdown: const Value(''),
                generatedContentMarkdown: const Value(''),
                providerId: Value(input.providerId.trim()),
                modelName: Value(input.modelName.trim()),
                logs: const Value(''),
                createdAt: now,
                updatedAt: now,
                startedAt: const Value(null),
                completedAt: const Value(null),
                appliedAt: const Value(null),
              ),
            );
      }
    });

    final saved = await findChapterEnrichmentBatch(batchId);
    if (saved == null) {
      throw StateError('Chapter enrichment batch was not created.');
    }
    return saved;
  }

  @override
  Future<ChapterEnrichmentBatch> updateChapterEnrichmentBatchState({
    required String id,
    required ChapterEnrichmentBatchStatus status,
    String? providerId,
    String? modelName,
    String? errorMessage,
    String? logs,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    final batch = await findChapterEnrichmentBatch(id);
    if (batch == null) {
      throw StateError('Chapter enrichment batch does not exist: $id');
    }
    final now = DateTime.now();
    final counts = await _chapterEnrichmentCounts(id);
    await _database.transaction(() async {
      await (_database.update(
        _database.chapterEnrichmentBatchRecords,
      )..where((row) => row.id.equals(id))).write(
        ChapterEnrichmentBatchRecordsCompanion(
          status: Value(status.name),
          providerId: providerId == null
              ? const Value.absent()
              : Value(providerId.trim()),
          modelName: modelName == null
              ? const Value.absent()
              : Value(modelName.trim()),
          errorMessage: Value(errorMessage),
          logs: logs == null ? const Value.absent() : Value(logs),
          generatedCount: Value(counts.generatedCount),
          failedCount: Value(counts.failedCount),
          appliedCount: Value(counts.appliedCount),
          startedAt: startedAt == null
              ? const Value.absent()
              : Value(startedAt),
          completedAt: completedAt == null
              ? const Value.absent()
              : Value(completedAt),
          updatedAt: Value(now),
        ),
      );
      await _updateWorkflowTaskForEnrichmentBatch(
        workflowTaskId: batch.workflowTaskId,
        status: status,
        errorMessage: errorMessage,
        updatedAt: now,
      );
    });
    final saved = await findChapterEnrichmentBatch(id);
    if (saved == null) {
      throw StateError('Chapter enrichment batch was not updated.');
    }
    return saved;
  }

  @override
  Future<ChapterEnrichmentItem> updateChapterEnrichmentItemState({
    required String id,
    required ChapterEnrichmentItemStatus status,
    String? errorMessage,
    String? originalContentMarkdown,
    String? generatedContentMarkdown,
    String? providerId,
    String? modelName,
    String? logs,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? appliedAt,
    bool clearStartedAt = false,
    bool clearCompletedAt = false,
    bool clearAppliedAt = false,
  }) async {
    final item = await findChapterEnrichmentItem(id);
    if (item == null) {
      throw StateError('Chapter enrichment item does not exist: $id');
    }
    final now = DateTime.now();
    await (_database.update(
      _database.chapterEnrichmentItemRecords,
    )..where((row) => row.id.equals(id))).write(
      ChapterEnrichmentItemRecordsCompanion(
        status: Value(status.name),
        errorMessage: Value(errorMessage),
        originalContentMarkdown: originalContentMarkdown == null
            ? const Value.absent()
            : Value(originalContentMarkdown.trim()),
        generatedContentMarkdown: generatedContentMarkdown == null
            ? const Value.absent()
            : Value(generatedContentMarkdown.trim()),
        providerId: providerId == null
            ? const Value.absent()
            : Value(providerId.trim()),
        modelName: modelName == null
            ? const Value.absent()
            : Value(modelName.trim()),
        logs: logs == null ? const Value.absent() : Value(logs),
        startedAt: clearStartedAt
            ? const Value(null)
            : startedAt == null
            ? const Value.absent()
            : Value(startedAt),
        completedAt: clearCompletedAt
            ? const Value(null)
            : completedAt == null
            ? const Value.absent()
            : Value(completedAt),
        appliedAt: clearAppliedAt
            ? const Value(null)
            : appliedAt == null
            ? const Value.absent()
            : Value(appliedAt),
        updatedAt: Value(now),
      ),
    );
    await _refreshChapterEnrichmentBatchCounts(item.batchId);
    final saved = await findChapterEnrichmentItem(id);
    if (saved == null) {
      throw StateError('Chapter enrichment item was not updated.');
    }
    return saved;
  }

  @override
  Future<ProjectChapter> applyChapterEnrichmentItem(String itemId) async {
    final item = await findChapterEnrichmentItem(itemId);
    if (item == null) {
      throw StateError('Chapter enrichment item does not exist: $itemId');
    }
    if (item.status != ChapterEnrichmentItemStatus.generated) {
      throw StateError('只有已生成的加料结果可以应用。');
    }
    final generated = item.generatedContentMarkdown.trim();
    if (generated.isEmpty) {
      throw StateError('加料结果为空，无法应用。');
    }
    final chapter = await findChapter(item.chapterId);
    if (chapter == null) {
      throw StateError('Project chapter does not exist: ${item.chapterId}');
    }
    final saved = await saveChapter(
      id: chapter.id,
      input: ProjectChapterInput(
        projectId: chapter.projectId,
        chapterPlanId: chapter.chapterPlanId,
        chapterIndex: chapter.chapterIndex,
        title: chapter.title,
        contentMarkdown: generated,
      ),
    );
    await updateChapterEnrichmentItemState(
      id: item.id,
      status: ChapterEnrichmentItemStatus.applied,
      errorMessage: null,
      appliedAt: DateTime.now(),
    );
    return saved;
  }

  @override
  Future<void> deleteChapterEnrichmentItem(String itemId) async {
    final item = await findChapterEnrichmentItem(itemId);
    if (item == null) {
      throw StateError('Chapter enrichment item does not exist: $itemId');
    }
    await (_database.delete(
      _database.chapterEnrichmentItemRecords,
    )..where((row) => row.id.equals(itemId))).go();
    await _refreshChapterEnrichmentBatchCounts(item.batchId);
  }

  Future<void> _validateChapterPlanInput(ChapterPlanInput input) async {
    await _requireProject(input.projectId);
    final volume = await _findChapterVolume(input.volumeId);
    if (volume == null || volume.projectId != input.projectId) {
      throw StateError('章节计划需要有效分卷。');
    }
    if (input.volumeIndex <= 0 || input.chapterLocalIndex <= 0) {
      throw StateError('分卷序号和卷内章节序号必须大于 0。');
    }
    if (input.chapterIndex <= 0) {
      throw StateError('章节序号必须大于 0。');
    }
    if (input.objectiveCard.isEmpty) {
      throw StateError('章节目标卡不能为空。');
    }
  }

  Future<void> _validateChapterInput(ProjectChapterInput input) async {
    await _requireProject(input.projectId);
    if (input.chapterIndex <= 0) {
      throw StateError('章节序号必须大于 0。');
    }
    final plan = await findChapterPlan(input.chapterPlanId);
    if (plan == null) {
      throw StateError('Chapter Plan 不存在。');
    }
    if (plan.projectId != input.projectId ||
        plan.chapterIndex != input.chapterIndex) {
      throw StateError('章节正文与 Chapter Plan 不匹配。');
    }
  }

  Future<void> _validateChapterGenerationBatchInput(
    ChapterGenerationBatchInput input,
  ) async {
    await _requireProject(input.projectId);
    if (input.chapterPlanIds.isEmpty) {
      throw StateError('请选择需要批量生成的章节。');
    }
    if (input.providerId.trim().isEmpty || input.modelName.trim().isEmpty) {
      throw StateError('批量草稿任务需要 Provider 和模型。');
    }
    if (await hasRunningChapterGenerationForProject(input.projectId)) {
      throw StateError('项目已有运行中的单章生成任务。');
    }
    final seen = <String>{};
    final plans = <ChapterPlan>[];
    for (final id in input.chapterPlanIds) {
      if (!seen.add(id)) {
        throw StateError('批量生成章节不能重复。');
      }
      final plan = await findChapterPlan(id);
      if (plan == null || plan.projectId != input.projectId) {
        throw StateError('批量生成章节计划不存在：$id');
      }
      plans.add(plan);
    }
    final sorted = [...plans]
      ..sort((a, b) => a.chapterIndex.compareTo(b.chapterIndex));
    for (var index = 0; index < sorted.length; index += 1) {
      if (sorted[index].id != plans[index].id) {
        throw StateError('批量生成章节必须按章节顺序选择。');
      }
    }
    final volumeId = sorted.first.volumeId;
    for (var index = 0; index < sorted.length; index += 1) {
      final plan = sorted[index];
      if (plan.volumeId != volumeId) {
        throw StateError('批量生成仅支持同一卷内连续章节。');
      }
      if (index > 0 &&
          plan.chapterIndex != sorted[index - 1].chapterIndex + 1) {
        throw StateError('批量生成章节必须连续，不能跳章。');
      }
      final chapter = await findChapterByPlan(plan.id);
      if (chapter != null && chapter.contentMarkdown.trim().isNotEmpty) {
        throw StateError('选区内已有正文：${chapter.title}');
      }
      if (await hasRunningChapterGeneration(plan.id)) {
        final title = plan.objectiveCard.chapterTitle.trim();
        throw StateError(
          '章节已有运行中的生成任务：${title.isEmpty ? '第${plan.chapterIndex}章' : title}',
        );
      }
    }
  }

  Future<void> _validateChapterEnrichmentBatchInput(
    ChapterEnrichmentBatchInput input,
  ) async {
    await _requireProject(input.projectId);
    if (input.chapterIds.isEmpty) {
      throw StateError('请选择需要加料的章节。');
    }
    if (input.instruction.trim().isEmpty) {
      throw StateError('请输入加料要求。');
    }
    if (input.expansionRatioPercent < 1 || input.expansionRatioPercent > 100) {
      throw StateError('扩写比例必须在 1 到 100 之间。');
    }
    if (input.providerId.trim().isEmpty || input.modelName.trim().isEmpty) {
      throw StateError('加料任务需要 Provider 和模型。');
    }
    final seen = <String>{};
    for (final id in input.chapterIds) {
      if (!seen.add(id)) {
        throw StateError('加料章节不能重复。');
      }
      final chapter = await findChapter(id);
      if (chapter == null || chapter.projectId != input.projectId) {
        throw StateError('加料章节不存在：$id');
      }
      if (chapter.contentMarkdown.trim().isEmpty) {
        throw StateError('章节正文为空，无法加料：${chapter.title}');
      }
    }
  }

  Future<void> _validateChapterVolumeInput(ChapterVolumeInput input) async {
    await _requireProject(input.projectId);
    if (input.volumeIndex <= 0) {
      throw StateError('分卷序号必须大于 0。');
    }
    if (input.targetLength < 0) {
      throw StateError('分卷目标字数不能小于 0。');
    }
    if (input.title.trim().isEmpty) {
      throw StateError('分卷标题不能为空。');
    }
  }

  Future<void> _validateCharacterInput(NovelCharacterInput input) async {
    await _requireProject(input.projectId);
    if (input.name.trim().isEmpty) {
      throw StateError('角色姓名不能为空。');
    }
    if ((input.firstChapterIndex ?? 1) <= 0 ||
        (input.lastChapterIndex ?? 1) <= 0) {
      throw StateError('角色出场章节必须大于 0。');
    }
  }

  Future<void> _validateRelationshipInput(NovelRelationshipInput input) async {
    await _requireProject(input.projectId);
    if (input.fromCharacterId == input.toCharacterId) {
      throw StateError('关系两端不能是同一个角色。');
    }
    final from = await findCharacter(input.fromCharacterId);
    final to = await findCharacter(input.toCharacterId);
    if (from == null || to == null) {
      throw StateError('关系需要有效角色。');
    }
    if (from.projectId != input.projectId || to.projectId != input.projectId) {
      throw StateError('关系角色不属于当前项目。');
    }
    if ((input.lastChangedChapterIndex ?? 1) <= 0) {
      throw StateError('关系变更章节必须大于 0。');
    }
  }

  Future<void> _validateIllustrationInput(
    ChapterIllustrationInput input,
  ) async {
    await _requireProject(input.projectId);
    final chapter = await findChapter(input.chapterId);
    if (chapter == null || chapter.projectId != input.projectId) {
      throw StateError('插图章节不存在。');
    }
    if (chapter.chapterPlanId != input.chapterPlanId) {
      throw StateError('插图章节计划不匹配。');
    }
    if (input.paragraphIndex < 0) {
      throw StateError('插图段落位置不能小于 0。');
    }
    if (input.selectedText.trim().isEmpty) {
      throw StateError('插图需要选中文本。');
    }
    if (input.prompt.trim().isEmpty) {
      throw StateError('插图提示词不能为空。');
    }
    if (input.providerId.trim().isEmpty || input.modelName.trim().isEmpty) {
      throw StateError('插图需要图像 Provider 和模型。');
    }
    if (input.localPath.trim().isEmpty) {
      throw StateError('插图文件路径不能为空。');
    }
  }

  Future<void> _validateIllustrationGenerationInput(
    ChapterIllustrationGenerationRunInput input,
  ) async {
    await _requireProject(input.projectId);
    final chapter = await findChapter(input.chapterId);
    if (chapter == null || chapter.projectId != input.projectId) {
      throw StateError('插图章节不存在。');
    }
    if (chapter.chapterPlanId != input.chapterPlanId) {
      throw StateError('插图章节计划不匹配。');
    }
    if (input.paragraphIndex < 0) {
      throw StateError('插图段落位置不能小于 0。');
    }
    if (input.selectedText.trim().isEmpty) {
      throw StateError('插图需要选中文本。');
    }
    if (input.prompt.trim().isEmpty) {
      throw StateError('插图提示词不能为空。');
    }
    if (input.providerId.trim().isEmpty || input.modelName.trim().isEmpty) {
      throw StateError('插图需要图像 Provider 和模型。');
    }
    if (input.aspectRatio.trim().isEmpty ||
        input.size.trim().isEmpty ||
        input.quality.trim().isEmpty ||
        input.responseFormat.trim().isEmpty) {
      throw StateError('插图生成参数不完整。');
    }
  }

  String _normalizeMimeType(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized.isEmpty ? 'image/png' : normalized;
  }

  Future<void> _requireProject(String id) async {
    await _requireProjectRecord(id);
  }

  Future<ProjectRecord> _requireProjectRecord(String id) async {
    final query = _database.select(_database.projectRecords)
      ..where((project) => project.id.equals(id))
      ..limit(1);
    final project = await query.getSingleOrNull();
    if (project == null) {
      throw StateError('Project does not exist: $id');
    }
    return project;
  }

  Future<ChapterVolume?> _findChapterVolume(String id) async {
    final query = _database.select(_database.chapterVolumeRecords)
      ..where((volume) => volume.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapVolume(row);
  }

  Future<NovelRelationship?> _findRelationshipByEndpoints({
    required String projectId,
    required String fromCharacterId,
    required String toCharacterId,
  }) async {
    final query = _database.select(_database.novelRelationshipRecords)
      ..where(
        (relationship) =>
            relationship.projectId.equals(projectId) &
            relationship.fromCharacterId.equals(fromCharacterId) &
            relationship.toCharacterId.equals(toCharacterId),
      )
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapRelationship(row);
  }

  ProjectBible _mapBible(ProjectBibleRecord row) {
    return ProjectBible(
      projectId: row.projectId,
      descriptionMarkdown: row.descriptionMarkdown,
      worldBuildingMarkdown: row.worldBuildingMarkdown,
      charactersBlueprintMarkdown: row.charactersBlueprintMarkdown,
      outlineMasterMarkdown: row.outlineMasterMarkdown,
      outlineDetailYaml: row.outlineDetailYaml,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  ChapterVolume _mapVolume(ChapterVolumeRecord row) {
    return ChapterVolume(
      id: row.id,
      projectId: row.projectId,
      volumeIndex: row.volumeIndex,
      title: row.title,
      targetLength: row.targetLength,
      summary: row.summary,
      centralConflict: row.centralConflict,
      characterProgression: row.characterProgression,
      endingHook: row.endingHook,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  NovelCharacter _mapCharacter(NovelCharacterRecord row) {
    return NovelCharacter(
      id: row.id,
      projectId: row.projectId,
      name: row.name,
      aliases: row.aliases,
      tags: row.tags,
      faction: row.faction,
      role: row.role,
      longTermGoal: row.longTermGoal,
      currentStatus: row.currentStatus,
      secrets: row.secrets,
      firstChapterIndex: row.firstChapterIndex,
      lastChapterIndex: row.lastChapterIndex,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  NovelRelationship _mapRelationship(NovelRelationshipRecord row) {
    return NovelRelationship(
      id: row.id,
      projectId: row.projectId,
      fromCharacterId: row.fromCharacterId,
      toCharacterId: row.toCharacterId,
      relationshipType: row.relationshipType,
      strength: row.strength,
      status: row.status,
      description: row.description,
      lastChangedChapterIndex: row.lastChangedChapterIndex,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  ProjectRuntimeMemory _mapMemory(ProjectRuntimeMemoryRecord row) {
    return ProjectRuntimeMemory(
      projectId: row.projectId,
      state: RuntimeMemoryState(
        runtimeState: row.runtimeState,
        runtimeThreads: row.runtimeThreads,
        storySummary: row.storySummary,
        continuityIndex: row.continuityIndex,
        chapterArchiveMarkdown: row.chapterArchiveMarkdown,
      ),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  ChapterPlan _mapPlan(ChapterPlanRecord row) {
    return ChapterPlan(
      id: row.id,
      projectId: row.projectId,
      volumeId: row.volumeId,
      volumeIndex: row.volumeIndex,
      volumeTitle: row.volumeTitle,
      chapterLocalIndex: row.chapterLocalIndex,
      chapterIndex: row.chapterIndex,
      objectiveCard: ChapterObjectiveCard(
        chapterTitle: row.title,
        objective: row.objective,
        pressureSource: row.pressureSource,
        payoffTarget: row.payoffTarget,
        relationshipShift: row.relationshipShift,
        hookType: row.hookType,
      ),
      coreEvent: row.coreEvent,
      emotionArc: row.emotionArc,
      chapterHook: row.chapterHook,
      outlineMarkdown: row.outlineMarkdown,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  ProjectChapter _mapChapter(ProjectChapterRecord row) {
    return ProjectChapter(
      id: row.id,
      projectId: row.projectId,
      chapterPlanId: row.chapterPlanId,
      chapterIndex: row.chapterIndex,
      title: row.title,
      contentMarkdown: row.contentMarkdown,
      contentHash: row.contentHash,
      continuityVerdict: ContinuityVerdict.values.byName(row.continuityVerdict),
      continuityReportMarkdown: row.continuityReportMarkdown,
      memorySyncStatus: MemorySyncStatus.values.byName(row.memorySyncStatus),
      memorySyncContentHash: row.memorySyncContentHash,
      memorySyncProposedRuntimeState: row.memorySyncProposedRuntimeState,
      memorySyncProposedRuntimeThreads: row.memorySyncProposedRuntimeThreads,
      memorySyncProposedStorySummary: row.memorySyncProposedStorySummary,
      memorySyncProposedContinuityIndex: row.memorySyncProposedContinuityIndex,
      memorySyncProposedChapterArchiveMarkdown:
          row.memorySyncProposedChapterArchiveMarkdown,
      memorySyncPatchYaml: row.memorySyncPatchYaml,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  ChapterIllustration _mapIllustration(ChapterIllustrationRecord row) {
    return ChapterIllustration(
      id: row.id,
      projectId: row.projectId,
      chapterId: row.chapterId,
      chapterPlanId: row.chapterPlanId,
      paragraphIndex: row.paragraphIndex,
      anchorTextHash: row.anchorTextHash,
      selectedText: row.selectedText,
      prompt: row.prompt,
      providerId: row.providerId,
      modelName: row.modelName,
      localPath: row.localPath,
      mimeType: row.mimeType,
      status: _mapIllustrationStatus(row.status),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      acceptedAt: row.acceptedAt,
    );
  }

  ChapterIllustrationStatus _mapIllustrationStatus(String value) {
    if (value == 'accepted') {
      return ChapterIllustrationStatus.inserted;
    }
    return ChapterIllustrationStatus.values.byName(value);
  }

  ChapterIllustrationGenerationRun _mapIllustrationGenerationRun(
    ChapterIllustrationGenerationRunRecord row,
  ) {
    return ChapterIllustrationGenerationRun(
      id: row.id,
      workflowTaskId: row.workflowTaskId,
      projectId: row.projectId,
      chapterId: row.chapterId,
      chapterPlanId: row.chapterPlanId,
      paragraphIndex: row.paragraphIndex,
      anchorTextHash: row.anchorTextHash,
      selectedText: row.selectedText,
      prompt: row.prompt,
      providerId: row.providerId,
      modelName: row.modelName,
      aspectRatio: row.aspectRatio,
      size: row.size,
      quality: row.quality,
      responseFormat: row.responseFormat,
      status: ChapterIllustrationGenerationStatus.values.byName(row.status),
      stage: row.stage == null
          ? null
          : ChapterIllustrationGenerationStage.values.byName(row.stage!),
      errorMessage: row.errorMessage,
      logs: row.logs,
      illustrationId: row.illustrationId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
    );
  }

  ChapterGenerationRun _mapGenerationRun(ChapterGenerationRunRecord row) {
    return ChapterGenerationRun(
      id: row.id,
      workflowTaskId: row.workflowTaskId,
      projectId: row.projectId,
      chapterPlanId: row.chapterPlanId,
      chapterId: row.chapterId,
      providerId: row.providerId,
      modelName: row.modelName,
      status: ChapterGenerationStatus.values.byName(row.status),
      stage: row.stage == null
          ? null
          : ChapterGenerationStage.values.byName(row.stage!),
      errorMessage: row.errorMessage,
      logs: row.logs,
      contextWarningsMarkdown: row.contextWarningsMarkdown,
      draftMarkdown: row.draftMarkdown,
      continuityVerdict: ContinuityVerdict.values.byName(row.continuityVerdict),
      continuityReportMarkdown: row.continuityReportMarkdown,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
    );
  }

  ChapterGenerationBatch _mapGenerationBatch(ChapterGenerationBatchRecord row) {
    return ChapterGenerationBatch(
      id: row.id,
      workflowTaskId: row.workflowTaskId,
      projectId: row.projectId,
      providerId: row.providerId,
      modelName: row.modelName,
      status: ChapterGenerationBatchStatus.values.byName(row.status),
      errorMessage: row.errorMessage,
      totalCount: row.totalCount,
      syncedCount: row.syncedCount,
      failedCount: row.failedCount,
      logs: row.logs,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
    );
  }

  ChapterGenerationBatchItem _mapGenerationBatchItem(
    ChapterGenerationBatchItemRecord row,
  ) {
    return ChapterGenerationBatchItem(
      id: row.id,
      batchId: row.batchId,
      projectId: row.projectId,
      chapterPlanId: row.chapterPlanId,
      chapterId: row.chapterId,
      latestRunId: row.latestRunId,
      position: row.position,
      status: ChapterGenerationBatchItemStatus.values.byName(row.status),
      errorMessage: row.errorMessage,
      draftAttemptCount: row.draftAttemptCount,
      patchAttemptCount: row.patchAttemptCount,
      logs: row.logs,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
      syncedAt: row.syncedAt,
    );
  }

  AssetGenerationRun _mapAssetGenerationRun(AssetGenerationRunRecord row) {
    return AssetGenerationRun(
      id: row.id,
      workflowTaskId: row.workflowTaskId,
      projectId: row.projectId,
      targetVolumeId: row.targetVolumeId,
      kind: AssetGenerationKind.values.byName(row.kind),
      providerId: row.providerId,
      modelName: row.modelName,
      status: AssetGenerationStatus.values.byName(row.status),
      stage: row.stage == null
          ? null
          : AssetGenerationStage.values.byName(row.stage!),
      errorMessage: row.errorMessage,
      logs: row.logs,
      draftMarkdown: row.draftMarkdown,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
      previousRunId: row.previousRunId,
      userFeedback: row.userFeedback,
    );
  }

  ChapterEnrichmentBatch _mapEnrichmentBatch(ChapterEnrichmentBatchRecord row) {
    return ChapterEnrichmentBatch(
      id: row.id,
      workflowTaskId: row.workflowTaskId,
      projectId: row.projectId,
      instruction: row.instruction,
      expansionRatioPercent: row.expansionRatioPercent,
      providerId: row.providerId,
      modelName: row.modelName,
      status: ChapterEnrichmentBatchStatus.values.byName(row.status),
      errorMessage: row.errorMessage,
      totalCount: row.totalCount,
      generatedCount: row.generatedCount,
      failedCount: row.failedCount,
      appliedCount: row.appliedCount,
      logs: row.logs,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
    );
  }

  ChapterEnrichmentItem _mapEnrichmentItem(ChapterEnrichmentItemRecord row) {
    return ChapterEnrichmentItem(
      id: row.id,
      batchId: row.batchId,
      projectId: row.projectId,
      chapterId: row.chapterId,
      position: row.position,
      status: ChapterEnrichmentItemStatus.values.byName(row.status),
      errorMessage: row.errorMessage,
      originalContentMarkdown: row.originalContentMarkdown,
      generatedContentMarkdown: row.generatedContentMarkdown,
      providerId: row.providerId,
      modelName: row.modelName,
      logs: row.logs,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
      appliedAt: row.appliedAt,
    );
  }

  String _generationTaskTitle(ChapterPlan? plan) {
    final title = plan?.objectiveCard.chapterTitle.trim();
    if (title == null || title.isEmpty) {
      return '章节生成任务';
    }
    return '章节生成：$title';
  }

  String _assetGenerationTaskTitle(AssetGenerationKind kind) {
    return '资产生成：${_assetKindLabel(kind)}';
  }

  String _assetKindLabel(AssetGenerationKind kind) {
    return switch (kind) {
      AssetGenerationKind.worldBuilding => '世界观设定',
      AssetGenerationKind.charactersBlueprint => '角色索引与关系网',
      AssetGenerationKind.outlineMaster => '总纲',
      AssetGenerationKind.volumeBlueprintYaml => '分卷规划',
      AssetGenerationKind.outlineDetailYaml => '分卷与章节细纲',
    };
  }

  WorkflowTaskStatus _workflowStatus(ChapterGenerationStatus status) {
    return switch (status) {
      ChapterGenerationStatus.pending => WorkflowTaskStatus.pending,
      ChapterGenerationStatus.running => WorkflowTaskStatus.running,
      ChapterGenerationStatus.succeeded => WorkflowTaskStatus.succeeded,
      ChapterGenerationStatus.failed => WorkflowTaskStatus.failed,
      ChapterGenerationStatus.abandoned => WorkflowTaskStatus.abandoned,
    };
  }

  WorkflowTaskStatus _generationBatchWorkflowStatus(
    ChapterGenerationBatchStatus status,
  ) {
    return switch (status) {
      ChapterGenerationBatchStatus.pending => WorkflowTaskStatus.pending,
      ChapterGenerationBatchStatus.running => WorkflowTaskStatus.running,
      ChapterGenerationBatchStatus.succeeded => WorkflowTaskStatus.succeeded,
      ChapterGenerationBatchStatus.failed => WorkflowTaskStatus.failed,
      ChapterGenerationBatchStatus.abandoned => WorkflowTaskStatus.abandoned,
    };
  }

  WorkflowTaskStatus _assetWorkflowStatus(AssetGenerationStatus status) {
    return switch (status) {
      AssetGenerationStatus.pending => WorkflowTaskStatus.pending,
      AssetGenerationStatus.running => WorkflowTaskStatus.running,
      AssetGenerationStatus.succeeded => WorkflowTaskStatus.succeeded,
      AssetGenerationStatus.failed => WorkflowTaskStatus.failed,
      AssetGenerationStatus.applied => WorkflowTaskStatus.succeeded,
      AssetGenerationStatus.abandoned => WorkflowTaskStatus.abandoned,
    };
  }

  WorkflowTaskStatus _illustrationGenerationWorkflowStatus(
    ChapterIllustrationGenerationStatus status,
  ) {
    return switch (status) {
      ChapterIllustrationGenerationStatus.pending => WorkflowTaskStatus.pending,
      ChapterIllustrationGenerationStatus.running => WorkflowTaskStatus.running,
      ChapterIllustrationGenerationStatus.succeeded =>
        WorkflowTaskStatus.succeeded,
      ChapterIllustrationGenerationStatus.failed => WorkflowTaskStatus.failed,
      ChapterIllustrationGenerationStatus.abandoned =>
        WorkflowTaskStatus.abandoned,
    };
  }

  WorkflowTaskStatus _enrichmentWorkflowStatus(
    ChapterEnrichmentBatchStatus status,
  ) {
    return switch (status) {
      ChapterEnrichmentBatchStatus.pending => WorkflowTaskStatus.pending,
      ChapterEnrichmentBatchStatus.running => WorkflowTaskStatus.running,
      ChapterEnrichmentBatchStatus.succeeded => WorkflowTaskStatus.succeeded,
      ChapterEnrichmentBatchStatus.partialFailed => WorkflowTaskStatus.failed,
      ChapterEnrichmentBatchStatus.failed => WorkflowTaskStatus.failed,
      ChapterEnrichmentBatchStatus.abandoned => WorkflowTaskStatus.abandoned,
    };
  }

  Future<bool> _abandonChapterGenerationRun(
    ChapterGenerationRunRecord run,
    DateTime now,
  ) async {
    if (run.status == ChapterGenerationStatus.succeeded.name) {
      return false;
    }
    await (_database.update(
      _database.chapterGenerationRunRecords,
    )..where((row) => row.id.equals(run.id))).write(
      ChapterGenerationRunRecordsCompanion(
        status: Value(ChapterGenerationStatus.abandoned.name),
        stage: const Value(null),
        errorMessage: const Value(null),
        contextWarningsMarkdown: const Value(''),
        draftMarkdown: const Value(''),
        continuityVerdict: Value(ContinuityVerdict.pass.name),
        continuityReportMarkdown: const Value(''),
        completedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    return true;
  }

  Future<bool> _abandonChapterIllustrationGenerationRun(
    ChapterIllustrationGenerationRunRecord run,
    DateTime now,
  ) async {
    if (run.status == ChapterIllustrationGenerationStatus.succeeded.name) {
      return false;
    }
    await (_database.update(
      _database.chapterIllustrationGenerationRunRecords,
    )..where((row) => row.id.equals(run.id))).write(
      ChapterIllustrationGenerationRunRecordsCompanion(
        status: Value(ChapterIllustrationGenerationStatus.abandoned.name),
        stage: const Value(null),
        errorMessage: const Value(null),
        updatedAt: Value(now),
        completedAt: Value(now),
      ),
    );
    return true;
  }

  Future<bool> _abandonChapterGenerationBatch(
    ChapterGenerationBatchRecord batch,
    DateTime now,
  ) async {
    if (batch.status == ChapterGenerationBatchStatus.succeeded.name) {
      return false;
    }
    await (_database.update(_database.chapterGenerationBatchItemRecords)..where(
          (item) =>
              item.batchId.equals(batch.id) &
              item.status.isIn([
                ChapterGenerationBatchItemStatus.waiting.name,
                ChapterGenerationBatchItemStatus.running.name,
                ChapterGenerationBatchItemStatus.failed.name,
              ]),
        ))
        .write(
          ChapterGenerationBatchItemRecordsCompanion(
            status: Value(ChapterGenerationBatchItemStatus.abandoned.name),
            errorMessage: const Value(null),
            logs: const Value(''),
            completedAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    final counts = await _chapterGenerationBatchCounts(batch.id);
    await (_database.update(
      _database.chapterGenerationBatchRecords,
    )..where((row) => row.id.equals(batch.id))).write(
      ChapterGenerationBatchRecordsCompanion(
        status: Value(ChapterGenerationBatchStatus.abandoned.name),
        errorMessage: const Value(null),
        syncedCount: Value(counts.syncedCount),
        failedCount: Value(counts.failedCount),
        logs: const Value(''),
        completedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    return true;
  }

  Future<bool> _abandonAssetGenerationRun(
    AssetGenerationRunRecord run,
    DateTime now,
  ) async {
    if (run.status == AssetGenerationStatus.applied.name) {
      return false;
    }
    await (_database.update(
      _database.assetGenerationRunRecords,
    )..where((row) => row.id.equals(run.id))).write(
      AssetGenerationRunRecordsCompanion(
        status: Value(AssetGenerationStatus.abandoned.name),
        stage: const Value(null),
        errorMessage: const Value(null),
        logs: const Value(''),
        draftMarkdown: const Value(''),
        completedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    return true;
  }

  Future<bool> _abandonChapterEnrichmentBatch(
    ChapterEnrichmentBatchRecord batch,
    DateTime now,
  ) async {
    if (batch.status == ChapterEnrichmentBatchStatus.succeeded.name) {
      return false;
    }
    await (_database.update(_database.chapterEnrichmentItemRecords)..where(
          (item) =>
              item.batchId.equals(batch.id) &
              item.status.isIn([
                ChapterEnrichmentItemStatus.waiting.name,
                ChapterEnrichmentItemStatus.running.name,
                ChapterEnrichmentItemStatus.generated.name,
                ChapterEnrichmentItemStatus.failed.name,
              ]),
        ))
        .write(
          ChapterEnrichmentItemRecordsCompanion(
            status: Value(ChapterEnrichmentItemStatus.abandoned.name),
            errorMessage: const Value(null),
            originalContentMarkdown: const Value(''),
            generatedContentMarkdown: const Value(''),
            logs: const Value(''),
            completedAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    final counts = await _chapterEnrichmentCounts(batch.id);
    await (_database.update(
      _database.chapterEnrichmentBatchRecords,
    )..where((row) => row.id.equals(batch.id))).write(
      ChapterEnrichmentBatchRecordsCompanion(
        status: Value(ChapterEnrichmentBatchStatus.abandoned.name),
        errorMessage: const Value(null),
        generatedCount: Value(counts.generatedCount),
        failedCount: Value(counts.failedCount),
        appliedCount: Value(counts.appliedCount),
        logs: const Value(''),
        completedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    return true;
  }

  Future<void> _updateWorkflowTaskForGenerationRun({
    required String workflowTaskId,
    required ChapterGenerationStatus status,
    required ChapterGenerationStage? stage,
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

  Future<void> _updateWorkflowTaskForGenerationBatch({
    required String workflowTaskId,
    required ChapterGenerationBatchStatus status,
    required String? errorMessage,
    required DateTime updatedAt,
  }) {
    return (_database.update(
      _database.workflowTaskRecords,
    )..where((task) => task.id.equals(workflowTaskId))).write(
      WorkflowTaskRecordsCompanion(
        status: Value(_generationBatchWorkflowStatus(status).name),
        stage: Value(status.name),
        errorMessage: Value(errorMessage),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<void> _updateWorkflowTaskForAssetGenerationRun({
    required String workflowTaskId,
    required AssetGenerationStatus status,
    required AssetGenerationStage? stage,
    required String? errorMessage,
    required DateTime updatedAt,
  }) {
    return (_database.update(
      _database.workflowTaskRecords,
    )..where((task) => task.id.equals(workflowTaskId))).write(
      WorkflowTaskRecordsCompanion(
        status: Value(_assetWorkflowStatus(status).name),
        stage: Value(stage?.name),
        errorMessage: Value(errorMessage),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<void> _updateWorkflowTaskForIllustrationGenerationRun({
    required String workflowTaskId,
    required ChapterIllustrationGenerationStatus status,
    required ChapterIllustrationGenerationStage? stage,
    required String? errorMessage,
    required DateTime updatedAt,
  }) {
    return (_database.update(
      _database.workflowTaskRecords,
    )..where((task) => task.id.equals(workflowTaskId))).write(
      WorkflowTaskRecordsCompanion(
        status: Value(_illustrationGenerationWorkflowStatus(status).name),
        stage: Value(stage?.name),
        errorMessage: Value(errorMessage),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<void> _updateWorkflowTaskForEnrichmentBatch({
    required String workflowTaskId,
    required ChapterEnrichmentBatchStatus status,
    required String? errorMessage,
    required DateTime updatedAt,
  }) {
    return (_database.update(
      _database.workflowTaskRecords,
    )..where((task) => task.id.equals(workflowTaskId))).write(
      WorkflowTaskRecordsCompanion(
        status: Value(_enrichmentWorkflowStatus(status).name),
        stage: Value(status.name),
        errorMessage: Value(errorMessage),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<_ChapterEnrichmentCounts> _chapterEnrichmentCounts(
    String batchId,
  ) async {
    final rows = await (_database.select(
      _database.chapterEnrichmentItemRecords,
    )..where((row) => row.batchId.equals(batchId))).get();
    return _ChapterEnrichmentCounts(
      generatedCount: rows
          .where(
            (row) => row.status == ChapterEnrichmentItemStatus.generated.name,
          )
          .length,
      failedCount: rows
          .where((row) => row.status == ChapterEnrichmentItemStatus.failed.name)
          .length,
      appliedCount: rows
          .where(
            (row) => row.status == ChapterEnrichmentItemStatus.applied.name,
          )
          .length,
    );
  }

  Future<_ChapterGenerationBatchCounts> _chapterGenerationBatchCounts(
    String batchId,
  ) async {
    final rows = await (_database.select(
      _database.chapterGenerationBatchItemRecords,
    )..where((row) => row.batchId.equals(batchId))).get();
    return _ChapterGenerationBatchCounts(
      syncedCount: rows
          .where(
            (row) => row.status == ChapterGenerationBatchItemStatus.synced.name,
          )
          .length,
      failedCount: rows
          .where(
            (row) => row.status == ChapterGenerationBatchItemStatus.failed.name,
          )
          .length,
    );
  }

  Future<void> _refreshChapterGenerationBatchCounts(String batchId) async {
    final counts = await _chapterGenerationBatchCounts(batchId);
    await (_database.update(
      _database.chapterGenerationBatchRecords,
    )..where((row) => row.id.equals(batchId))).write(
      ChapterGenerationBatchRecordsCompanion(
        syncedCount: Value(counts.syncedCount),
        failedCount: Value(counts.failedCount),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> _refreshChapterEnrichmentBatchCounts(String batchId) async {
    final counts = await _chapterEnrichmentCounts(batchId);
    await (_database.update(
      _database.chapterEnrichmentBatchRecords,
    )..where((row) => row.id.equals(batchId))).write(
      ChapterEnrichmentBatchRecordsCompanion(
        generatedCount: Value(counts.generatedCount),
        failedCount: Value(counts.failedCount),
        appliedCount: Value(counts.appliedCount),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  String _hashContent(String content) {
    const offsetBasis = 0xcbf29ce484222325;
    const prime = 0x100000001b3;
    var hash = offsetBasis;
    for (final byte in utf8.encode(content)) {
      hash ^= byte;
      hash = (hash * prime) & 0xffffffffffffffff;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }
}

class _ChapterEnrichmentCounts {
  const _ChapterEnrichmentCounts({
    required this.generatedCount,
    required this.failedCount,
    required this.appliedCount,
  });

  final int generatedCount;
  final int failedCount;
  final int appliedCount;
}

class _ChapterGenerationBatchCounts {
  const _ChapterGenerationBatchCounts({
    required this.syncedCount,
    required this.failedCount,
  });

  final int syncedCount;
  final int failedCount;
}
