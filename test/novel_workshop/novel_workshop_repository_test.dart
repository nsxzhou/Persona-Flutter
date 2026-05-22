import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/core/database/app_database.dart';
import 'package:persona_flutter/src/core/tasks/data/drift_workflow_task_repository.dart';
import 'package:persona_flutter/src/core/tasks/domain/workflow_task.dart';
import 'package:persona_flutter/src/features/novel_workshop/data/drift_novel_workshop_repository.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/outline_detail_parser.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/novel_workshop.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/writing_context.dart';
import 'package:persona_flutter/src/features/projects/data/drift_project_repository.dart';
import 'package:persona_flutter/src/features/projects/domain/writing_project.dart';
import 'package:persona_flutter/src/features/settings/data/drift_provider_config_repository.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('project bible initializes from project description', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final project = await _saveProject(database);
    final repository = DriftNovelWorkshopRepository(database);

    final bible = await repository.ensureProjectBible(project.id);

    expect(bible.projectId, project.id);
    expect(bible.descriptionMarkdown, project.description);
    expect(bible.outlineDetailYaml, isEmpty);
  });

  test('outline detail yaml projects volumes and chapter plans', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final project = await _saveProject(database);
    final repository = DriftNovelWorkshopRepository(database);

    final bible = await repository.saveOutlineDetailYaml(
      projectId: project.id,
      outlineDetailYaml: '''
volumes:
  - index: 1
    title: 第一卷
    chapters:
      - index: 1
        title: 第一章
        objective: 主角进入雾港。
        pressureSource: 追兵逼近。
        payoffTarget: 找到第一条线索。
        relationshipShift: 主角与向导临时合作。
        hookType: 信息差钩子。
        coreEvent: 抵达雾港。
        emotionArc: 警惕到被迫合作。
        chapterHook: 港务处灯灭。
        outlineMarkdown: |
          - 雾气压住码头。
          - 向导提出交易。
''',
    );

    final volumes = await repository.watchChapterVolumes(project.id).first;
    final plans = await repository.watchChapterPlans(project.id).first;

    expect(bible.outlineDetailYaml, contains('volumes:'));
    expect(volumes.single.title, '第一卷');
    expect(plans.single.volumeId, volumes.single.id);
    expect(plans.single.chapterLocalIndex, 1);
    expect(plans.single.objectiveCard.chapterTitle, '第一章');
    expect(plans.single.coreEvent, '抵达雾港。');
    expect(plans.single.outlineMarkdown, contains('雾气压住码头'));
  });

  test('manual outline detail yaml save remains a full overwrite', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final project = await _saveProject(database);
    final repository = DriftNovelWorkshopRepository(database);

    await repository.saveOutlineDetailYaml(
      projectId: project.id,
      outlineDetailYaml: '''
volumes:
  - index: 1
    title: 第一卷
    chapters:
      - index: 1
        title: 第一章
  - index: 2
    title: 第二卷
    chapters:
      - index: 1
        title: 第二卷第一章
''',
    );

    final saved = await repository.saveOutlineDetailYaml(
      projectId: project.id,
      outlineDetailYaml: '''
volumes:
  - index: 2
    title: 第二卷修订
    chapters:
      - index: 1
        title: 第二卷新第一章
''',
    );
    expect(saved.outlineDetailYaml, isNot(contains('第一卷')));
    expect(saved.outlineDetailYaml, contains('第二卷修订'));
  });

  test('target volume outline draft preserves other outline volumes', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final project = await _saveProject(database);
    final repository = DriftNovelWorkshopRepository(database);

    await repository.saveOutlineDetailYaml(
      projectId: project.id,
      outlineDetailYaml: '''
volumes:
  - index: 1
    title: 第一卷
    chapters:
      - index: 1
        title: 第一章
        objective: 旧第一卷目标。
  - index: 2
    title: 第二卷
    chapters:
      - index: 1
        title: 第二卷第一章
        objective: 保留第二卷目标。
''',
    );
    final targetVolume =
        (await repository.watchChapterVolumes(project.id).first).singleWhere(
          (volume) => volume.volumeIndex == 1,
        );
    final run = await repository.createVolumeDetailGenerationRun(
      projectId: project.id,
      volumeId: targetVolume.id,
    );
    await repository.updateAssetGenerationRunState(
      id: run.id,
      status: AssetGenerationStatus.succeeded,
      draftMarkdown: '''
volumes:
  - index: 1
    title: 第一卷修订
    chapters:
      - index: 1
        title: 第一章修订
        objective: 新第一卷目标。
''',
    );

    final saved = await repository.applyAssetGenerationDraft(run.id);
    final volumes = await repository.watchChapterVolumes(project.id).first;
    final plans = await repository.watchChapterPlans(project.id).first;

    expect(saved.outlineDetailYaml, contains('第一卷修订'));
    expect(saved.outlineDetailYaml, contains('第二卷'));
    expect(volumes.map((volume) => volume.volumeIndex), containsAll([1, 2]));
    expect(
      plans
          .singleWhere((plan) => plan.volumeIndex == 1)
          .objectiveCard
          .objective,
      '新第一卷目标。',
    );
    expect(
      plans
          .singleWhere((plan) => plan.volumeIndex == 2)
          .objectiveCard
          .objective,
      '保留第二卷目标。',
    );
  });

  test(
    'outline detail asset draft preserves omitted existing volumes',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final project = await _saveProject(database);
      final repository = DriftNovelWorkshopRepository(database);

      await repository.saveOutlineDetailYaml(
        projectId: project.id,
        outlineDetailYaml: '''
volumes:
  - index: 1
    title: 第一卷
    chapters:
      - index: 1
        title: 第一章
        objective: 旧第一卷目标。
  - index: 2
    title: 第二卷
    chapters:
      - index: 1
        title: 第二卷第一章
        objective: 保留第二卷目标。
''',
      );
      final run = await repository.createAssetGenerationRun(
        AssetGenerationRunInput(
          projectId: project.id,
          kind: AssetGenerationKind.outlineDetailYaml,
          providerId: project.defaultProviderId!,
          modelName: project.defaultModelName!,
        ),
      );
      await repository.updateAssetGenerationRunState(
        id: run.id,
        status: AssetGenerationStatus.succeeded,
        draftMarkdown: '''
volumes:
  - index: 1
    title: 第一卷修订
    chapters:
      - index: 1
        title: 第一章修订
        objective: 新第一卷目标。
''',
      );

      final saved = await repository.applyAssetGenerationDraft(run.id);

      expect(saved.outlineDetailYaml, contains('第一卷修订'));
      expect(saved.outlineDetailYaml, contains('第二卷'));
      expect(saved.outlineDetailYaml, contains('保留第二卷目标'));
    },
  );

  test(
    'tracks active whole-project asset generation by project and kind',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final project = await _saveProject(database);
      final repository = DriftNovelWorkshopRepository(database);

      expect(
        await repository.hasRunningAssetGeneration(
          projectId: project.id,
          kind: AssetGenerationKind.worldBuilding,
        ),
        isFalse,
      );

      final run = await repository.createAssetGenerationRun(
        AssetGenerationRunInput(
          projectId: project.id,
          kind: AssetGenerationKind.worldBuilding,
          providerId: project.defaultProviderId!,
          modelName: project.defaultModelName!,
        ),
      );

      expect(
        await repository.hasRunningAssetGeneration(
          projectId: project.id,
          kind: AssetGenerationKind.worldBuilding,
        ),
        isTrue,
      );
      expect(
        await repository.hasRunningAssetGeneration(
          projectId: project.id,
          kind: AssetGenerationKind.outlineMaster,
        ),
        isFalse,
      );

      await repository.updateAssetGenerationRunState(
        id: run.id,
        status: AssetGenerationStatus.failed,
      );

      expect(
        await repository.hasRunningAssetGeneration(
          projectId: project.id,
          kind: AssetGenerationKind.worldBuilding,
        ),
        isFalse,
      );
    },
  );

  test('tracks active volume detail generation by target volume', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final project = await _saveProject(database);
    final repository = DriftNovelWorkshopRepository(database);
    final first = await repository.saveChapterVolume(
      input: ChapterVolumeInput(
        projectId: project.id,
        volumeIndex: 1,
        title: '第一卷',
      ),
    );
    final second = await repository.saveChapterVolume(
      input: ChapterVolumeInput(
        projectId: project.id,
        volumeIndex: 2,
        title: '第二卷',
      ),
    );

    final run = await repository.createVolumeDetailGenerationRun(
      projectId: project.id,
      volumeId: first.id,
    );

    expect(
      await repository.hasRunningAssetGeneration(
        projectId: project.id,
        kind: AssetGenerationKind.outlineDetailYaml,
        targetVolumeId: first.id,
      ),
      isTrue,
    );
    expect(
      await repository.hasRunningAssetGeneration(
        projectId: project.id,
        kind: AssetGenerationKind.outlineDetailYaml,
        targetVolumeId: second.id,
      ),
      isFalse,
    );
    expect(
      await repository.hasRunningAssetGeneration(
        projectId: project.id,
        kind: AssetGenerationKind.outlineDetailYaml,
      ),
      isFalse,
    );

    await repository.updateAssetGenerationRunState(
      id: run.id,
      status: AssetGenerationStatus.succeeded,
    );

    expect(
      await repository.hasRunningAssetGeneration(
        projectId: project.id,
        kind: AssetGenerationKind.outlineDetailYaml,
        targetVolumeId: first.id,
      ),
      isFalse,
    );
  });

  test('outline parser reports missing required fields', () {
    expect(
      () => const OutlineDetailParser().parse('volumes: []'),
      throwsA(isA<OutlineDetailValidationException>()),
    );
    expect(
      () => const OutlineDetailParser().parse('''
volumes:
  - index: 1
    title: 第一卷
    chapters:
      - index: 1
'''),
      throwsA(isA<OutlineDetailValidationException>()),
    );
  });

  test('runtime memory initializes updates and clears per project', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final project = await _saveProject(database);
    final repository = DriftNovelWorkshopRepository(database);

    final initial = await repository.ensureRuntimeMemory(project.id);
    expect(initial.state.isEmpty, isTrue);

    final updated = await repository.saveRuntimeMemory(
      projectId: project.id,
      state: const RuntimeMemoryState(
        runtimeState: '- 潮汐封城。',
        runtimeThreads: '- 港务处线索未解。',
        storySummary: '林岚追查失踪案。',
        continuityIndex: '- 潮汐封城\n- 港务处线索',
        chapterArchiveMarkdown: '## 第 1 章\n\n林岚抵达雾港。',
      ),
    );
    expect(updated.state.runtimeState, contains('潮汐'));
    expect(updated.state.continuityIndex, contains('港务处'));
    expect(updated.state.chapterArchiveMarkdown, contains('第 1 章'));

    await repository.clearRuntimeMemory(project.id);
    final cleared = await repository.findRuntimeMemory(project.id);
    expect(cleared, isNotNull);
    expect(cleared!.state.isEmpty, isTrue);
  });

  test('character graph patch preserves omitted existing fields', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final project = await _saveProject(database);
    final repository = DriftNovelWorkshopRepository(database);

    final character = await repository.saveCharacter(
      input: NovelCharacterInput(
        projectId: project.id,
        name: '林岚',
        aliases: '林调查员',
        tags: '主角',
        faction: '外来调查者',
        role: '主线调查者',
        longTermGoal: '查清旧案真相。',
        currentStatus: '刚抵达雾港。',
        secrets: '隐瞒旧案证词。',
        firstChapterIndex: 1,
        lastChapterIndex: 1,
      ),
    );

    await repository.applyCharactersYaml(
      projectId: project.id,
      charactersYaml: '''
characters:
  - name: 林岚
    currentStatus: 拿到港务处线索。
    lastChapterIndex: 2
''',
    );
    final saved = await repository.findCharacter(character.id);

    expect(saved!.role, '主线调查者');
    expect(saved.longTermGoal, '查清旧案真相。');
    expect(saved.secrets, '隐瞒旧案证词。');
    expect(saved.currentStatus, '拿到港务处线索。');
    expect(saved.firstChapterIndex, 1);
    expect(saved.lastChapterIndex, 2);
  });

  test('relationship patch preserves omitted existing fields', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final project = await _saveProject(database);
    final repository = DriftNovelWorkshopRepository(database);

    final from = await repository.saveCharacter(
      input: NovelCharacterInput(projectId: project.id, name: '林岚'),
    );
    final to = await repository.saveCharacter(
      input: NovelCharacterInput(projectId: project.id, name: '向导'),
    );
    final relationship = await repository.saveRelationship(
      input: NovelRelationshipInput(
        projectId: project.id,
        fromCharacterId: from.id,
        toCharacterId: to.id,
        relationshipType: '临时合作',
        strength: 2,
        status: '互相试探',
        description: '林岚需要向导进入港务禁区。',
        lastChangedChapterIndex: 1,
      ),
    );

    await repository.applyCharactersYaml(
      projectId: project.id,
      charactersYaml: '''
relationships:
  - from: 林岚
    to: 向导
    status: 信任升温
    lastChangedChapterIndex: 2
''',
    );
    final saved = await repository.findRelationship(relationship.id);

    expect(saved!.relationshipType, '临时合作');
    expect(saved.strength, 2);
    expect(saved.description, '林岚需要向导进入港务禁区。');
    expect(saved.status, '信任升温');
    expect(saved.lastChangedChapterIndex, 2);
  });

  test('chapter plan and single chapter record round-trip', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final project = await _saveProject(database);
    final repository = DriftNovelWorkshopRepository(database);
    final volume = await repository.saveChapterVolume(
      input: ChapterVolumeInput(
        projectId: project.id,
        volumeIndex: 1,
        title: '第一卷',
      ),
    );

    final plan = await repository.saveChapterPlan(
      input: ChapterPlanInput(
        projectId: project.id,
        volumeId: volume.id,
        volumeIndex: volume.volumeIndex,
        volumeTitle: volume.title,
        chapterLocalIndex: 1,
        chapterIndex: 1,
        objectiveCard: const ChapterObjectiveCard(
          chapterTitle: '第一章',
          objective: '主角进入雾港。',
          pressureSource: '追兵逼近。',
          payoffTarget: '找到第一条线索。',
          relationshipShift: '主角与向导临时合作。',
          hookType: '信息差钩子。',
        ),
      ),
    );
    final chapter = await repository.saveChapter(
      input: ProjectChapterInput(
        projectId: project.id,
        chapterPlanId: plan.id,
        chapterIndex: plan.chapterIndex,
        title: plan.objectiveCard.chapterTitle,
        contentMarkdown: '雾气贴着码头爬上来。',
        continuityVerdict: ContinuityVerdict.warning,
        continuityReportMarkdown: '# 审校报告\n\n- 章末推动偏弱。',
      ),
    );

    expect(chapter.title, '第一章');
    expect(chapter.contentMarkdown, '雾气贴着码头爬上来。');
    expect(chapter.contentHash, isNotEmpty);
    expect(chapter.continuityVerdict, ContinuityVerdict.warning);
    expect(chapter.memorySyncStatus, MemorySyncStatus.idle);

    final plans = await repository.watchChapterPlans(project.id).first;
    final chapters = await repository.watchChapters(project.id).first;
    expect(plans.single.id, plan.id);
    expect(chapters.single.id, chapter.id);
  });

  test(
    'chapter enrichment batch persists preview and applies generated item',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final project = await _saveProject(database);
      final repository = DriftNovelWorkshopRepository(database);
      final workflowRepository = DriftWorkflowTaskRepository(database);
      final volume = await repository.saveChapterVolume(
        input: ChapterVolumeInput(
          projectId: project.id,
          volumeIndex: 1,
          title: '导入正文',
        ),
      );
      final plan = await repository.saveChapterPlan(
        input: ChapterPlanInput(
          projectId: project.id,
          volumeId: volume.id,
          volumeIndex: 1,
          volumeTitle: volume.title,
          chapterLocalIndex: 1,
          chapterIndex: 1,
          objectiveCard: const ChapterObjectiveCard(chapterTitle: '第一章'),
        ),
      );
      final chapter = await repository.saveChapter(
        input: ProjectChapterInput(
          projectId: project.id,
          chapterPlanId: plan.id,
          chapterIndex: 1,
          title: '第一章',
          contentMarkdown: '旧正文。',
        ),
      );

      final batch = await repository.createChapterEnrichmentBatch(
        ChapterEnrichmentBatchInput(
          projectId: project.id,
          chapterIds: [chapter.id],
          instruction: '增强心理描写。',
          expansionRatioPercent: 20,
          providerId: project.defaultProviderId!,
          modelName: project.defaultModelName!,
        ),
      );
      final items = await repository
          .watchChapterEnrichmentItems(batch.id)
          .first;
      expect(items.single.status, ChapterEnrichmentItemStatus.waiting);

      final generated = await repository.updateChapterEnrichmentItemState(
        id: items.single.id,
        status: ChapterEnrichmentItemStatus.generated,
        originalContentMarkdown: chapter.contentMarkdown,
        generatedContentMarkdown: '新正文。',
      );
      expect(generated.originalContentMarkdown, '旧正文。');
      expect(generated.generatedContentMarkdown, '新正文。');

      final updatedBatch = await repository.updateChapterEnrichmentBatchState(
        id: batch.id,
        status: ChapterEnrichmentBatchStatus.succeeded,
        completedAt: DateTime.now(),
      );
      expect(updatedBatch.generatedCount, 1);
      final task = await workflowRepository.findTask(batch.workflowTaskId);
      expect(task!.kind, chapterEnrichmentWorkflowTaskKind);
      expect(task.status, WorkflowTaskStatus.succeeded);

      final applied = await repository.applyChapterEnrichmentItem(generated.id);
      expect(applied.contentMarkdown, '新正文。');
      final appliedItem = await repository.findChapterEnrichmentItem(
        generated.id,
      );
      expect(appliedItem!.status, ChapterEnrichmentItemStatus.applied);
    },
  );

  test(
    'chapter enrichment item deletion removes preview and refreshes counts',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final project = await _saveProject(database);
      final repository = DriftNovelWorkshopRepository(database);
      final volume = await repository.saveChapterVolume(
        input: ChapterVolumeInput(
          projectId: project.id,
          volumeIndex: 1,
          title: '导入正文',
        ),
      );
      final plan = await repository.saveChapterPlan(
        input: ChapterPlanInput(
          projectId: project.id,
          volumeId: volume.id,
          volumeIndex: 1,
          volumeTitle: volume.title,
          chapterLocalIndex: 1,
          chapterIndex: 1,
          objectiveCard: const ChapterObjectiveCard(chapterTitle: '第一章'),
        ),
      );
      final chapter = await repository.saveChapter(
        input: ProjectChapterInput(
          projectId: project.id,
          chapterPlanId: plan.id,
          chapterIndex: 1,
          title: '第一章',
          contentMarkdown: '旧正文。',
        ),
      );

      final batch = await repository.createChapterEnrichmentBatch(
        ChapterEnrichmentBatchInput(
          projectId: project.id,
          chapterIds: [chapter.id],
          instruction: '增强心理描写。',
          expansionRatioPercent: 20,
          providerId: project.defaultProviderId!,
          modelName: project.defaultModelName!,
        ),
      );
      final item =
          (await repository.watchChapterEnrichmentItems(batch.id).first).single;
      final generated = await repository.updateChapterEnrichmentItemState(
        id: item.id,
        status: ChapterEnrichmentItemStatus.generated,
        originalContentMarkdown: chapter.contentMarkdown,
        generatedContentMarkdown: '新正文。',
      );
      expect(
        (await repository.findChapterEnrichmentBatch(batch.id))!.generatedCount,
        1,
      );

      await repository.deleteChapterEnrichmentItem(generated.id);

      expect(await repository.findChapterEnrichmentItem(generated.id), isNull);
      expect(
        await repository.watchChapterEnrichmentItems(batch.id).first,
        isEmpty,
      );
      final refreshedBatch = await repository.findChapterEnrichmentBatch(
        batch.id,
      );
      expect(refreshedBatch!.totalCount, 1);
      expect(refreshedBatch.generatedCount, 0);
      expect(refreshedBatch.failedCount, 0);
      expect(refreshedBatch.appliedCount, 0);
      expect(
        (await repository.findChapter(chapter.id))!.contentMarkdown,
        '旧正文。',
      );
    },
  );

  test(
    'editing chapter content clears previous memory sync proposal',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final project = await _saveProject(database);
      final repository = DriftNovelWorkshopRepository(database);
      final volume = await repository.saveChapterVolume(
        input: ChapterVolumeInput(
          projectId: project.id,
          volumeIndex: 1,
          title: '第一卷',
        ),
      );
      final plan = await repository.saveChapterPlan(
        input: ChapterPlanInput(
          projectId: project.id,
          volumeId: volume.id,
          volumeIndex: volume.volumeIndex,
          volumeTitle: volume.title,
          chapterLocalIndex: 1,
          chapterIndex: 1,
          objectiveCard: const ChapterObjectiveCard(objective: '推进调查。'),
        ),
      );
      final chapter = await repository.saveChapter(
        input: ProjectChapterInput(
          projectId: project.id,
          chapterPlanId: plan.id,
          chapterIndex: 1,
          title: '第一章',
          contentMarkdown: '旧正文。',
        ),
      );
      final proposal = await repository.saveMemorySyncProposal(
        MemorySyncProposalInput(
          chapterId: chapter.id,
          contentHash: chapter.contentHash,
          proposedMemory: const RuntimeMemoryState(
            runtimeState: '- 旧正文状态。',
            runtimeThreads: '- 旧伏笔。',
            storySummary: '旧摘要。',
            continuityIndex: '- 旧索引。',
            chapterArchiveMarkdown: '## 第 1 章\n\n旧归档。',
          ),
        ),
      );
      expect(proposal.memorySyncStatus, MemorySyncStatus.pendingReview);
      expect(proposal.memorySyncProposedStorySummary, '旧摘要。');
      expect(proposal.memorySyncProposedContinuityIndex, '- 旧索引。');
      expect(
        proposal.memorySyncProposedChapterArchiveMarkdown,
        contains('旧归档'),
      );

      final edited = await repository.saveChapter(
        id: chapter.id,
        input: ProjectChapterInput(
          projectId: project.id,
          chapterPlanId: plan.id,
          chapterIndex: 1,
          title: '第一章',
          contentMarkdown: '新正文。',
        ),
      );

      expect(edited.contentMarkdown, '新正文。');
      expect(edited.contentHash, isNot(chapter.contentHash));
      expect(edited.memorySyncStatus, MemorySyncStatus.idle);
      expect(edited.memorySyncContentHash, isEmpty);
      expect(edited.memorySyncProposedRuntimeState, isEmpty);
      expect(edited.memorySyncProposedRuntimeThreads, isEmpty);
      expect(edited.memorySyncProposedStorySummary, isEmpty);
      expect(edited.memorySyncProposedContinuityIndex, isEmpty);
      expect(edited.memorySyncProposedChapterArchiveMarkdown, isEmpty);
    },
  );

  test('memory sync patch merges layered runtime memory fields', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final project = await _saveProject(database);
    final repository = DriftNovelWorkshopRepository(database);
    await repository.saveRuntimeMemory(
      projectId: project.id,
      state: const RuntimeMemoryState(
        runtimeState: '- 旧状态。',
        runtimeThreads: '- 旧伏笔。',
        storySummary: '旧摘要。',
        continuityIndex: '- 旧索引。',
        chapterArchiveMarkdown: '## 第 0 章\n\n旧归档。',
      ),
    );
    final volume = await repository.saveChapterVolume(
      input: ChapterVolumeInput(
        projectId: project.id,
        volumeIndex: 1,
        title: '第一卷',
      ),
    );
    final plan = await repository.saveChapterPlan(
      input: ChapterPlanInput(
        projectId: project.id,
        volumeId: volume.id,
        volumeIndex: volume.volumeIndex,
        volumeTitle: volume.title,
        chapterLocalIndex: 1,
        chapterIndex: 1,
        objectiveCard: const ChapterObjectiveCard(objective: '推进调查。'),
      ),
    );
    final chapter = await repository.saveChapter(
      input: ProjectChapterInput(
        projectId: project.id,
        chapterPlanId: plan.id,
        chapterIndex: 1,
        title: '第一章',
        contentMarkdown: '正文。',
      ),
    );

    await repository.saveMemorySyncProposal(
      MemorySyncProposalInput(
        chapterId: chapter.id,
        contentHash: chapter.contentHash,
        patchYaml: '''
runtimeMemory:
  runtimeState: '- 抵达雾港。'
  chapterArchiveMarkdown: |-
    ## 第 1 章

    林岚抵达雾港。
''',
      ),
    );

    final synced = await repository.applyMemorySyncPatch(chapter.id);
    final memory = await repository.findRuntimeMemory(project.id);

    expect(synced.memorySyncStatus, MemorySyncStatus.synced);
    expect(memory!.state.runtimeState, '- 抵达雾港。');
    expect(memory.state.runtimeThreads, '- 旧伏笔。');
    expect(memory.state.storySummary, '旧摘要。');
    expect(memory.state.continuityIndex, '- 旧索引。');
    expect(memory.state.chapterArchiveMarkdown, contains('第 0 章'));
    expect(memory.state.chapterArchiveMarkdown, contains('第 1 章'));
  });

  test(
    'discarding memory sync patch preserves chapter and project state',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final fixture = await _saveChapterFixture(database);
      final repository = fixture.repository;
      await repository.saveRuntimeMemory(
        projectId: fixture.project.id,
        state: const RuntimeMemoryState(
          runtimeState: '- 旧状态。',
          storySummary: '旧摘要。',
        ),
      );

      await repository.saveMemorySyncProposal(
        MemorySyncProposalInput(
          chapterId: fixture.chapter.id,
          contentHash: fixture.chapter.contentHash,
          proposedMemory: const RuntimeMemoryState(
            runtimeState: '- 新状态。',
            storySummary: '新摘要。',
          ),
          patchYaml: '''
characters:
  - name: 林岚
    currentStatus: 错误状态。
runtimeMemory:
  runtimeState: '- 新状态。'
  storySummary: 新摘要。
''',
        ),
      );

      final discarded = await repository.discardMemorySyncPatch(
        fixture.chapter.id,
      );
      final memory = await repository.findRuntimeMemory(fixture.project.id);
      final characters = await repository
          .watchCharacters(fixture.project.id)
          .first;

      expect(discarded.memorySyncStatus, MemorySyncStatus.discarded);
      expect(discarded.contentMarkdown, fixture.chapter.contentMarkdown);
      expect(discarded.memorySyncPatchYaml, contains('错误状态'));
      expect(memory!.state.runtimeState, '- 旧状态。');
      expect(memory.state.storySummary, '旧摘要。');
      expect(characters, isEmpty);
    },
  );

  test('discarding non-pending memory sync patch is rejected', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final fixture = await _saveChapterFixture(database);

    expect(
      () => fixture.repository.discardMemorySyncPatch(fixture.chapter.id),
      throwsA(isA<StateError>()),
    );
  });

  test('discarded memory sync patch cannot be applied', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final fixture = await _saveChapterFixture(database);

    await fixture.repository.saveMemorySyncProposal(
      MemorySyncProposalInput(
        chapterId: fixture.chapter.id,
        contentHash: fixture.chapter.contentHash,
        patchYaml: '''
runtimeMemory:
  storySummary: 新摘要。
''',
      ),
    );
    await fixture.repository.discardMemorySyncPatch(fixture.chapter.id);

    expect(
      () => fixture.repository.applyMemorySyncPatch(fixture.chapter.id),
      throwsA(isA<StateError>()),
    );
  });

  test(
    'applying empty memory sync proposal preserves layered runtime memory',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final project = await _saveProject(database);
      final repository = DriftNovelWorkshopRepository(database);
      await repository.saveRuntimeMemory(
        projectId: project.id,
        state: const RuntimeMemoryState(
          runtimeState: '- 旧状态。',
          runtimeThreads: '- 旧伏笔。',
          storySummary: '旧摘要。',
          continuityIndex: '- 旧索引。',
          chapterArchiveMarkdown: '## 第 1 章\n\n旧归档。',
        ),
      );
      final volume = await repository.saveChapterVolume(
        input: ChapterVolumeInput(
          projectId: project.id,
          volumeIndex: 1,
          title: '第一卷',
        ),
      );
      final plan = await repository.saveChapterPlan(
        input: ChapterPlanInput(
          projectId: project.id,
          volumeId: volume.id,
          volumeIndex: volume.volumeIndex,
          volumeTitle: volume.title,
          chapterLocalIndex: 1,
          chapterIndex: 1,
          objectiveCard: const ChapterObjectiveCard(objective: '推进调查。'),
        ),
      );
      final chapter = await repository.saveChapter(
        input: ProjectChapterInput(
          projectId: project.id,
          chapterPlanId: plan.id,
          chapterIndex: 1,
          title: '第一章',
          contentMarkdown: '正文。',
        ),
      );

      await repository.saveMemorySyncProposal(
        MemorySyncProposalInput(
          chapterId: chapter.id,
          contentHash: chapter.contentHash,
        ),
      );

      final synced = await repository.applyMemorySyncPatch(chapter.id);
      final memory = await repository.findRuntimeMemory(project.id);

      expect(synced.memorySyncStatus, MemorySyncStatus.synced);
      expect(memory!.state.runtimeState, '- 旧状态。');
      expect(memory.state.runtimeThreads, '- 旧伏笔。');
      expect(memory.state.storySummary, '旧摘要。');
      expect(memory.state.continuityIndex, '- 旧索引。');
      expect(memory.state.chapterArchiveMarkdown, contains('旧归档'));
    },
  );

  test('chapter generation run syncs workflow task and prompt trace', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final project = await _saveProject(database);
    final repository = DriftNovelWorkshopRepository(database);
    final volume = await repository.saveChapterVolume(
      input: ChapterVolumeInput(
        projectId: project.id,
        volumeIndex: 1,
        title: '第一卷',
      ),
    );
    final workflowRepository = DriftWorkflowTaskRepository(database);
    final plan = await repository.saveChapterPlan(
      input: ChapterPlanInput(
        projectId: project.id,
        volumeId: volume.id,
        volumeIndex: volume.volumeIndex,
        volumeTitle: volume.title,
        chapterLocalIndex: 1,
        chapterIndex: 1,
        objectiveCard: const ChapterObjectiveCard(
          chapterTitle: '第一章',
          objective: '主角进入雾港。',
        ),
      ),
    );

    final run = await repository.createChapterGenerationRun(
      ChapterGenerationRunInput(
        projectId: project.id,
        chapterPlanId: plan.id,
        providerId: project.defaultProviderId!,
        modelName: project.defaultModelName!,
      ),
    );

    expect(run.status, ChapterGenerationStatus.pending);
    expect(await repository.hasRunningChapterGeneration(plan.id), isTrue);
    expect(
      await repository.hasRunningChapterGenerationForProject(project.id),
      isTrue,
    );

    final running = await repository.updateChapterGenerationRunState(
      id: run.id,
      status: ChapterGenerationStatus.running,
      stage: ChapterGenerationStage.generatingDraft,
      contextWarningsMarkdown: '- 运行时记忆为空。',
      draftMarkdown: '生成草稿。',
      continuityVerdict: ContinuityVerdict.warning,
      continuityReportMarkdown: '# 审计报告\n\n- 目标偏弱。',
      startedAt: DateTime.now(),
    );
    final task = await workflowRepository.findTask(run.workflowTaskId);
    expect(running.stage, ChapterGenerationStage.generatingDraft);
    expect(running.contextWarningsMarkdown, contains('运行时记忆'));
    expect(running.draftMarkdown, '生成草稿。');
    expect(running.continuityVerdict, ContinuityVerdict.warning);
    expect(running.continuityReportMarkdown, contains('目标偏弱'));
    expect(task!.kind, chapterGenerationWorkflowTaskKind);
    expect(task.status, WorkflowTaskStatus.running);
    expect(task.stage, ChapterGenerationStage.generatingDraft.name);

    await workflowRepository.upsertPromptTrace(
      workflowTaskId: run.workflowTaskId,
      traceMarkdown: '# Prompt Trace',
    );
    final trace = await workflowRepository
        .watchPromptTrace(run.workflowTaskId)
        .first;
    expect(trace!.traceMarkdown, '# Prompt Trace');

    final succeeded = await repository.updateChapterGenerationRunState(
      id: run.id,
      status: ChapterGenerationStatus.succeeded,
      stage: null,
      completedAt: DateTime.now(),
    );
    final completedTask = await workflowRepository.findTask(run.workflowTaskId);
    expect(succeeded.status, ChapterGenerationStatus.succeeded);
    expect(completedTask!.status, WorkflowTaskStatus.succeeded);
    expect(await repository.hasRunningChapterGeneration(plan.id), isFalse);
    expect(
      await repository.hasRunningChapterGenerationForProject(project.id),
      isFalse,
    );
  });

  test(
    'chapter generation batch persists items and syncs workflow task',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final project = await _saveProject(database);
      final repository = DriftNovelWorkshopRepository(database);
      final workflowRepository = DriftWorkflowTaskRepository(database);
      final volume = await repository.saveChapterVolume(
        input: ChapterVolumeInput(
          projectId: project.id,
          volumeIndex: 1,
          title: '第一卷',
        ),
      );
      final first = await repository.saveChapterPlan(
        input: ChapterPlanInput(
          projectId: project.id,
          volumeId: volume.id,
          volumeIndex: volume.volumeIndex,
          volumeTitle: volume.title,
          chapterLocalIndex: 1,
          chapterIndex: 1,
          objectiveCard: const ChapterObjectiveCard(
            chapterTitle: '第一章',
            objective: '进入雾港。',
          ),
        ),
      );
      final second = await repository.saveChapterPlan(
        input: ChapterPlanInput(
          projectId: project.id,
          volumeId: volume.id,
          volumeIndex: volume.volumeIndex,
          volumeTitle: volume.title,
          chapterLocalIndex: 2,
          chapterIndex: 2,
          objectiveCard: const ChapterObjectiveCard(
            chapterTitle: '第二章',
            objective: '调查港务处。',
          ),
        ),
      );

      final batch = await repository.createChapterGenerationBatch(
        ChapterGenerationBatchInput(
          projectId: project.id,
          chapterPlanIds: [first.id, second.id],
          providerId: project.defaultProviderId!,
          modelName: project.defaultModelName!,
        ),
      );

      expect(batch.status, ChapterGenerationBatchStatus.pending);
      expect(
        await repository.hasRunningChapterGenerationBatch(project.id),
        isTrue,
      );
      final items = await repository
          .watchChapterGenerationBatchItems(batch.id)
          .first;
      expect(items, hasLength(2));
      expect(items.first.chapterPlanId, first.id);
      expect(items.last.chapterPlanId, second.id);
      final task = await workflowRepository.findTask(batch.workflowTaskId);
      expect(task!.kind, chapterGenerationBatchWorkflowTaskKind);
      expect(task.status, WorkflowTaskStatus.pending);

      final updatedItem = await repository
          .updateChapterGenerationBatchItemState(
            id: items.first.id,
            status: ChapterGenerationBatchItemStatus.synced,
            draftAttemptCount: 1,
            patchAttemptCount: 1,
            logs: '已闭环。',
            syncedAt: DateTime.now(),
          );
      expect(updatedItem.status, ChapterGenerationBatchItemStatus.synced);
      final running = await repository.updateChapterGenerationBatchState(
        id: batch.id,
        status: ChapterGenerationBatchStatus.running,
        logs: '批量草稿运行中。',
        startedAt: DateTime.now(),
      );
      expect(running.syncedCount, 1);
      final runningTask = await workflowRepository.findTask(
        batch.workflowTaskId,
      );
      expect(runningTask!.status, WorkflowTaskStatus.running);

      final succeeded = await repository.updateChapterGenerationBatchState(
        id: batch.id,
        status: ChapterGenerationBatchStatus.succeeded,
        completedAt: DateTime.now(),
      );
      expect(succeeded.status, ChapterGenerationBatchStatus.succeeded);
      expect(
        await repository.hasRunningChapterGenerationBatch(project.id),
        isFalse,
      );
      final completedTask = await workflowRepository.findTask(
        batch.workflowTaskId,
      );
      expect(completedTask!.status, WorkflowTaskStatus.succeeded);
    },
  );

  test('migration creates novel workshop persistence tables', () async {
    final sqlite = sqlite3.openInMemory();
    addTearDown(sqlite.dispose);
    final now = DateTime.utc(2026, 5, 18).millisecondsSinceEpoch;
    _createSchema11Database(sqlite, now: now);
    sqlite.execute('PRAGMA user_version = 11;');

    final database = AppDatabase(
      NativeDatabase.opened(sqlite, closeUnderlyingOnClose: false),
    );
    addTearDown(database.close);
    await database.customSelect('SELECT 1').get();

    expect(
      await _tableExists(sqlite, 'project_runtime_memory_records'),
      isTrue,
    );
    expect(await _tableExists(sqlite, 'chapter_plan_records'), isTrue);
    expect(await _tableExists(sqlite, 'project_chapter_records'), isTrue);
    expect(
      await _tableExists(sqlite, 'chapter_generation_run_records'),
      isTrue,
    );
  });
}

Future<WritingProject> _saveProject(AppDatabase database) async {
  final providerRepository = DriftProviderConfigRepository(database);
  await providerRepository.saveProvider(
    input: const ProviderConfigInput(
      name: 'OpenAI',
      baseUrl: 'https://api.example.com/v1',
      apiKey: 'sk-test',
      defaultModel: 'gpt-4.1-mini',
      systemPrompt: '',
      isEnabled: true,
    ),
  );
  final provider = (await providerRepository.watchProviders().first).single;
  final projectRepository = DriftProjectRepository(database);
  await projectRepository.saveProject(
    input: WritingProjectInput(
      title: '雾港纪事',
      description: '',
      status: ProjectStatus.active,
      defaultProviderId: provider.id,
      defaultModelName: provider.defaultModel,
    ),
  );
  return (await projectRepository.watchProjects(ProjectStatus.active).first)
      .single;
}

Future<_ChapterFixture> _saveChapterFixture(AppDatabase database) async {
  final project = await _saveProject(database);
  final repository = DriftNovelWorkshopRepository(database);
  final volume = await repository.saveChapterVolume(
    input: ChapterVolumeInput(
      projectId: project.id,
      volumeIndex: 1,
      title: '第一卷',
    ),
  );
  final plan = await repository.saveChapterPlan(
    input: ChapterPlanInput(
      projectId: project.id,
      volumeId: volume.id,
      volumeIndex: volume.volumeIndex,
      volumeTitle: volume.title,
      chapterLocalIndex: 1,
      chapterIndex: 1,
      objectiveCard: const ChapterObjectiveCard(objective: '推进调查。'),
    ),
  );
  final chapter = await repository.saveChapter(
    input: ProjectChapterInput(
      projectId: project.id,
      chapterPlanId: plan.id,
      chapterIndex: 1,
      title: '第一章',
      contentMarkdown: '正文。',
    ),
  );
  return _ChapterFixture(
    project: project,
    repository: repository,
    plan: plan,
    chapter: chapter,
  );
}

class _ChapterFixture {
  const _ChapterFixture({
    required this.project,
    required this.repository,
    required this.plan,
    required this.chapter,
  });

  final WritingProject project;
  final DriftNovelWorkshopRepository repository;
  final ChapterPlan plan;
  final ProjectChapter chapter;
}

void _createSchema11Database(Database sqlite, {required int now}) {
  sqlite.execute('''
    CREATE TABLE workflow_task_records (
      id TEXT NOT NULL PRIMARY KEY,
      kind TEXT NOT NULL,
      status TEXT NOT NULL,
      title TEXT NOT NULL,
      stage TEXT,
      error_message TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    );
  ''');
  sqlite.execute('''
    CREATE TABLE workflow_prompt_trace_records (
      workflow_task_id TEXT NOT NULL
        REFERENCES workflow_task_records (id)
        PRIMARY KEY,
      trace_markdown TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    );
  ''');
  sqlite.execute('''
    CREATE TABLE provider_config_records (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      base_url TEXT NOT NULL,
      api_key TEXT NOT NULL,
      default_model TEXT NOT NULL,
      system_prompt TEXT NOT NULL DEFAULT '',
      is_enabled INTEGER NOT NULL DEFAULT 1,
      test_status TEXT NOT NULL,
      last_tested_at INTEGER,
      last_test_message TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    );
  ''');
  sqlite.execute('''
    CREATE TABLE provider_model_records (
      provider_id TEXT NOT NULL REFERENCES provider_config_records(id),
      model_name TEXT NOT NULL,
      sort_order INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      PRIMARY KEY (provider_id, model_name)
    );
  ''');
  sqlite.execute('''
    CREATE TABLE project_records (
      id TEXT NOT NULL PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT NOT NULL DEFAULT '',
      status TEXT NOT NULL,
      default_provider_id TEXT,
      default_model_name TEXT,
      style_profile_id TEXT,
      plot_profile_id TEXT,
      language TEXT NOT NULL DEFAULT '简体中文',
      target_length INTEGER NOT NULL DEFAULT 3000,
      narrative_perspective TEXT NOT NULL DEFAULT '第三人称有限视角',
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    );
  ''');
  sqlite.execute(
    '''
    INSERT INTO project_records (
      id, title, description, status, created_at, updated_at
    ) VALUES ('project-1', '旧项目', '', 'active', ?, ?);
  ''',
    [now, now],
  );
  sqlite.execute('''
    CREATE TABLE style_sample_records (
      id TEXT NOT NULL PRIMARY KEY,
      source_type TEXT NOT NULL,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      character_count INTEGER NOT NULL,
      project_id TEXT REFERENCES project_records(id),
      source_filename TEXT,
      epub_book_title TEXT,
      epub_author TEXT,
      epub_chapter_title TEXT,
      epub_chapter_index INTEGER,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    );
  ''');
  sqlite.execute('''
    CREATE TABLE style_analysis_run_records (
      id TEXT NOT NULL PRIMARY KEY,
      workflow_task_id TEXT NOT NULL REFERENCES workflow_task_records(id),
      sample_id TEXT NOT NULL REFERENCES style_sample_records(id),
      provider_id TEXT NOT NULL REFERENCES provider_config_records(id),
      model_name TEXT NOT NULL,
      style_name TEXT NOT NULL,
      project_id TEXT REFERENCES project_records(id),
      status TEXT NOT NULL,
      stage TEXT,
      error_message TEXT,
      logs TEXT NOT NULL DEFAULT '',
      analysis_report_markdown TEXT,
      voice_profile_markdown TEXT,
      profile_id TEXT,
      chunk_count INTEGER NOT NULL DEFAULT 0,
      character_count INTEGER NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      started_at INTEGER,
      completed_at INTEGER
    );
  ''');
  sqlite.execute('''
    CREATE TABLE style_profile_records (
      id TEXT NOT NULL PRIMARY KEY,
      source_run_id TEXT NOT NULL UNIQUE
        REFERENCES style_analysis_run_records(id),
      provider_id TEXT NOT NULL REFERENCES provider_config_records(id),
      model_name TEXT NOT NULL,
      style_name TEXT NOT NULL,
      profile_markdown TEXT NOT NULL,
      analysis_report_markdown TEXT NOT NULL,
      project_id TEXT REFERENCES project_records(id),
      source_sample_id TEXT REFERENCES style_sample_records(id),
      source_title TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    );
  ''');
  sqlite.execute('''
    CREATE TABLE plot_sample_records (
      id TEXT NOT NULL PRIMARY KEY,
      source_type TEXT NOT NULL,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      character_count INTEGER NOT NULL,
      project_id TEXT REFERENCES project_records(id),
      source_filename TEXT,
      epub_book_title TEXT,
      epub_author TEXT,
      epub_chapter_count INTEGER,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    );
  ''');
  sqlite.execute('''
    CREATE TABLE plot_analysis_run_records (
      id TEXT NOT NULL PRIMARY KEY,
      workflow_task_id TEXT NOT NULL REFERENCES workflow_task_records(id),
      sample_id TEXT NOT NULL REFERENCES plot_sample_records(id),
      provider_id TEXT NOT NULL REFERENCES provider_config_records(id),
      model_name TEXT NOT NULL,
      plot_name TEXT NOT NULL,
      project_id TEXT REFERENCES project_records(id),
      status TEXT NOT NULL,
      stage TEXT,
      error_message TEXT,
      logs TEXT NOT NULL DEFAULT '',
      analysis_report_markdown TEXT,
      plot_skeleton_markdown TEXT,
      story_engine_markdown TEXT,
      profile_id TEXT,
      chunk_count INTEGER NOT NULL DEFAULT 0,
      character_count INTEGER NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      started_at INTEGER,
      completed_at INTEGER
    );
  ''');
  sqlite.execute('''
    CREATE TABLE plot_profile_records (
      id TEXT NOT NULL PRIMARY KEY,
      source_run_id TEXT NOT NULL UNIQUE REFERENCES plot_analysis_run_records(id),
      provider_id TEXT NOT NULL REFERENCES provider_config_records(id),
      model_name TEXT NOT NULL,
      plot_name TEXT NOT NULL,
      story_engine_markdown TEXT NOT NULL,
      analysis_report_markdown TEXT NOT NULL,
      plot_skeleton_markdown TEXT NOT NULL,
      project_id TEXT REFERENCES project_records(id),
      source_sample_id TEXT REFERENCES plot_sample_records(id),
      source_title TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    );
  ''');
}

Future<bool> _tableExists(Database sqlite, String tableName) async {
  final result = sqlite.select(
    '''
    SELECT name
    FROM sqlite_master
    WHERE type = 'table' AND name = ?
    LIMIT 1
    ''',
    [tableName],
  );
  return result.isNotEmpty;
}
