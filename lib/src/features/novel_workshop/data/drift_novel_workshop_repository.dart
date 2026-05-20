import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/tasks/domain/workflow_task.dart';
import '../application/character_graph_parser.dart';
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
  Future<AssetGenerationRun?> findAssetGenerationRun(String id) async {
    final query = _database.select(_database.assetGenerationRunRecords)
      ..where((run) => run.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapAssetGenerationRun(row);
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
            charactersStatus: Value(state.charactersStatus.trim()),
            runtimeState: Value(state.runtimeState.trim()),
            runtimeThreads: Value(state.runtimeThreads.trim()),
            storySummary: Value(state.storySummary.trim()),
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
    final normalizedId = id ?? _uuid.v4();
    final existing = id == null ? null : await _findChapterVolume(id);
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
    });
    final saved = await findProjectBible(projectId);
    if (saved == null) {
      throw StateError('Project Bible was not saved.');
    }
    return saved;
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
                aliases: Value(draft.aliases),
                tags: Value(draft.tags),
                faction: Value(draft.faction),
                role: Value(draft.role),
                longTermGoal: Value(draft.longTermGoal),
                currentStatus: Value(draft.currentStatus),
                secrets: Value(draft.secrets),
                firstChapterIndex: Value(draft.firstChapterIndex),
                lastChapterIndex: Value(draft.lastChapterIndex),
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
                relationshipType: Value(draft.relationshipType),
                strength: Value(draft.strength.clamp(-5, 5)),
                status: Value(draft.status),
                description: Value(draft.description),
                lastChangedChapterIndex: Value(draft.lastChangedChapterIndex),
                createdAt: Value(existingRelationship?.createdAt ?? now),
                updatedAt: Value(now),
              ),
            );
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
            memorySyncProposedCharactersStatus: contentChanged
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
        memorySyncProposedCharactersStatus: Value(
          input.proposedMemory.charactersStatus.trim(),
        ),
        memorySyncProposedRuntimeState: Value(
          input.proposedMemory.runtimeState.trim(),
        ),
        memorySyncProposedRuntimeThreads: Value(
          input.proposedMemory.runtimeThreads.trim(),
        ),
        memorySyncProposedStorySummary: Value(
          input.proposedMemory.storySummary.trim(),
        ),
        memorySyncPatchYaml: Value(input.patchYaml.trim()),
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
    final patchYaml = chapter.memorySyncPatchYaml.trim();
    if (patchYaml.isNotEmpty) {
      await applyCharactersYaml(
        projectId: chapter.projectId,
        charactersYaml: patchYaml,
      );
    }
    if (!RuntimeMemoryState(
      charactersStatus: chapter.memorySyncProposedCharactersStatus,
      runtimeState: chapter.memorySyncProposedRuntimeState,
      runtimeThreads: chapter.memorySyncProposedRuntimeThreads,
      storySummary: chapter.memorySyncProposedStorySummary,
    ).isEmpty) {
      await saveRuntimeMemory(
        projectId: chapter.projectId,
        state: RuntimeMemoryState(
          charactersStatus: chapter.memorySyncProposedCharactersStatus,
          runtimeState: chapter.memorySyncProposedRuntimeState,
          runtimeThreads: chapter.memorySyncProposedRuntimeThreads,
          storySummary: chapter.memorySyncProposedStorySummary,
        ),
      );
    }
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
      AssetGenerationKind.outlineDetailYaml => await saveOutlineDetailYaml(
        projectId: run.projectId,
        outlineDetailYaml: draft,
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
    return bible;
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
        charactersStatus: row.charactersStatus,
        runtimeState: row.runtimeState,
        runtimeThreads: row.runtimeThreads,
        storySummary: row.storySummary,
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
      memorySyncProposedCharactersStatus:
          row.memorySyncProposedCharactersStatus,
      memorySyncProposedRuntimeState: row.memorySyncProposedRuntimeState,
      memorySyncProposedRuntimeThreads: row.memorySyncProposedRuntimeThreads,
      memorySyncProposedStorySummary: row.memorySyncProposedStorySummary,
      memorySyncPatchYaml: row.memorySyncPatchYaml,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
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
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
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
    };
  }

  WorkflowTaskStatus _assetWorkflowStatus(AssetGenerationStatus status) {
    return switch (status) {
      AssetGenerationStatus.pending => WorkflowTaskStatus.pending,
      AssetGenerationStatus.running => WorkflowTaskStatus.running,
      AssetGenerationStatus.succeeded => WorkflowTaskStatus.succeeded,
      AssetGenerationStatus.failed => WorkflowTaskStatus.failed,
      AssetGenerationStatus.applied => WorkflowTaskStatus.succeeded,
    };
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
