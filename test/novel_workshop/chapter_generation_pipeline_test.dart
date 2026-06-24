import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/core/database/app_database.dart';
import 'package:persona_flutter/src/core/llm/application/llm_invocation_service.dart';
import 'package:persona_flutter/src/core/llm/application/markdown_completion_service.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_client.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_request.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_stream_event.dart';
import 'package:persona_flutter/src/core/tasks/application/workflow_task_cancellation_registry.dart';
import 'package:persona_flutter/src/core/tasks/data/drift_workflow_task_repository.dart';
import 'package:persona_flutter/src/core/tasks/domain/workflow_task.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/chapter_generation_pipeline.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/project_prompt_asset_resolver.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/writing_context_assembler.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/writing_context_retriever.dart';
import 'package:persona_flutter/src/features/novel_workshop/data/drift_novel_workshop_repository.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/novel_workshop.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/novel_workshop_repository.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/writing_context.dart';
import 'package:persona_flutter/src/features/plot_lab/data/drift_plot_lab_repository.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_analysis_run.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_profile.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_sample.dart';
import 'package:persona_flutter/src/features/projects/data/drift_project_repository.dart';
import 'package:persona_flutter/src/features/projects/domain/writing_project.dart';
import 'package:persona_flutter/src/features/settings/data/drift_provider_config_repository.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';
import 'package:persona_flutter/src/features/style_lab/data/drift_style_lab_repository.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_analysis_run.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_profile.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_sample.dart';

void main() {
  test('chapter length spec uses target ratio with default and floor', () {
    final defaultSpec = resolveChapterLengthSpec(0);
    expect(defaultSpec.targetChars, 3000);
    expect(defaultSpec.minCompletionChars, 2160);

    final lowSpec = resolveChapterLengthSpec(200);
    expect(lowSpec.targetChars, 200);
    expect(lowSpec.minCompletionChars, 300);

    final projectSpec = resolveChapterLengthSpec(3200);
    expect(projectSpec.targetChars, 3200);
    expect(projectSpec.minCompletionChars, 2304);
    expect(projectSpec.needsExpansion('短稿'), isTrue);
  });

  test('repeat tail trimming only cuts long repeated output', () {
    final shortRepeated = List.filled(100, '短').join();
    expect(trimRepeatedTail(shortRepeated).trimmed, isFalse);

    final uniqueLong = List.generate(
      700,
      (index) => String.fromCharCode(0x3400 + index),
    ).join();
    expect(trimRepeatedTail(uniqueLong).trimmed, isFalse);

    final repeatedWindow = List.filled(120, '复').join();
    final repeated =
        '开头$repeatedWindow$repeatedWindow$repeatedWindow$repeatedWindow$repeatedWindow';
    final trimmed = trimRepeatedTail(repeated);
    expect(trimmed.trimmed, isTrue);
    expect(trimmed.content, '开头$repeatedWindow');
    expect(trimmed.removedChars, greaterThan(0));
  });

  test(
    'previews generation context without creating run or calling llm',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final fixture = await _Fixture.create(
        database,
        llmClient: _StaticLlmClient('正文。'),
        withPromptAssets: true,
        withRuntimeMemory: true,
        withCharacterGraph: true,
      );
      final from =
          (await fixture.novelRepository
                  .watchCharacters(fixture.project.id)
                  .first)
              .single;
      final to = await fixture.novelRepository.saveCharacter(
        input: NovelCharacterInput(projectId: fixture.project.id, name: '向导'),
      );
      await fixture.novelRepository.saveRelationship(
        input: NovelRelationshipInput(
          projectId: fixture.project.id,
          fromCharacterId: from.id,
          toCharacterId: to.id,
          relationshipType: '临时合作',
        ),
      );

      final preview = await fixture.pipeline.previewGenerationContext(
        projectId: fixture.project.id,
        chapterPlanId: fixture.plan.id,
      );

      expect(preview.projectBibleIncluded, isTrue);
      expect(preview.chapterObjectiveCardIncluded, isTrue);
      expect(preview.runtimeMemoryIncluded, isTrue);
      expect(preview.characterCount, 2);
      expect(preview.relationshipCount, 1);
      expect(preview.voiceProfileIncluded, isTrue);
      expect(preview.storyEngineIncluded, isTrue);
      expect(preview.warnings, isEmpty);
      expect(preview.promptMarkdown, contains('## Output Contract'));
      expect(preview.promptMarkdown, contains('## Retrieved References'));
      expect(preview.promptMarkdown, contains('Source ID: voice_profile'));
      expect(preview.promptMarkdown, contains('Source ID: story_engine'));
      expect(preview.selectedAssetBlockCount, greaterThanOrEqualTo(2));
      expect(preview.promptMarkdown, contains('### Directed Relationships'));
      expect(fixture.llmClient.invocationCount, 0);
      expect(
        await fixture.novelRepository
            .watchChapterGenerationRuns(fixture.project.id)
            .first,
        isEmpty,
      );
      expect(
        await fixture.novelRepository.findChapterByPlan(fixture.plan.id),
        isNull,
      );
    },
  );

  test(
    'preview reports missing optional prompt assets without blocking',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final fixture = await _Fixture.create(
        database,
        llmClient: _StaticLlmClient('正文。'),
      );

      final preview = await fixture.pipeline.previewGenerationContext(
        projectId: fixture.project.id,
        chapterPlanId: fixture.plan.id,
      );

      expect(preview.voiceProfileIncluded, isFalse);
      expect(preview.storyEngineIncluded, isFalse);
      expect(preview.warnings, contains('项目未绑定 Voice Profile。'));
      expect(preview.warnings, contains('项目未绑定 Story Engine。'));
      expect(preview.promptMarkdown, contains('## Chapter Objective Card'));
      expect(fixture.llmClient.invocationCount, 0);
    },
  );

  test('generates chapter content and records workflow trace', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final fixture = await _Fixture.create(
      database,
      llmClient: _StaticLlmClient([
        _selectorAssets,
        '```markdown\n雾气贴着码头爬上来。\n```',
        _auditPass,
        '''
characters:
  - name: 林岚
    currentStatus: 抵达雾港。
runtimeMemory:
  runtimeState: 抵达雾港。
  runtimeThreads: 港务处线索待查。
  storySummary: 林岚抵达雾港。
  continuityIndex: 港务处线索
  chapterArchiveMarkdown: |-
    ## 第 1 章

    林岚抵达雾港。
''',
      ]),
      withPromptAssets: true,
      withRuntimeMemory: true,
      withCharacterGraph: true,
    );

    final result = await fixture.pipeline.generateChapter(
      projectId: fixture.project.id,
      chapterPlanId: fixture.plan.id,
    );

    expect(result.chapter.title, '第一章');
    expect(result.chapter.contentMarkdown, '雾气贴着码头爬上来。');
    expect(result.run.status, ChapterGenerationStatus.succeeded);
    expect(result.run.logs, contains('生成待审阅 Runtime Memory、角色卡片和关系图 Patch'));
    expect(result.workflowTaskId, result.run.workflowTaskId);
    expect(result.contextWarnings, isEmpty);
    expect(fixture.llmClient.invocationCount, 4);
    expect(fixture.llmClient.prompts.first, contains('上下文筛选器'));
    expect(fixture.llmClient.prompts[1], contains('## Output Contract'));
    expect(fixture.llmClient.prompts[1], contains('## Retrieved References'));
    expect(fixture.llmClient.prompts[1], contains('Source ID: voice_profile'));
    expect(fixture.llmClient.prompts[1], contains('Source ID: story_engine'));
    expect(
      fixture.llmClient.prompts[1],
      contains('Source ID: runtime_memory.threads'),
    );
    expect(
      fixture.llmClient.prompts[1],
      isNot(contains('Source ID: project_bible.description')),
    );
    expect(fixture.llmClient.prompts[1], contains('- Project Title: 雾港纪事'));
    expect(fixture.llmClient.prompts[1], contains('只写当前章节正文'));
    expect(fixture.llmClient.prompts[1], contains('上下文优先级'));
    expect(fixture.llmClient.prompts[1], contains('避免复读旧章节模式'));
    expect(fixture.llmClient.prompts[1], contains('伏笔'));
    expect(fixture.llmClient.prompts[2], contains('连续性审计员'));
    expect(fixture.llmClient.prompts[2], contains('Retrieved References'));
    expect(fixture.llmClient.prompts[2], contains('审美、文风、节奏'));
    expect(fixture.llmClient.prompts.last, contains('结构化记忆 Patch'));
    expect(fixture.llmClient.prompts.last, contains('只记录本章正文明确发生'));
    expect(fixture.llmClient.prompts.last, contains('不要输出全量快照'));
    expect(fixture.llmClient.prompts.last, contains('字段缺失表示保留旧值'));
    expect(fixture.llmClient.prompts.last, isNot(contains('必须输出更新后的完整五字段')));
    expect(fixture.llmClient.prompts.last, contains('未解决悬念'));
    expect(fixture.llmClient.prompts.last, contains('伏笔债务'));
    expect(fixture.llmClient.prompts.last, contains('storySummary'));
    expect(fixture.llmClient.prompts.last, contains('continuityIndex'));
    expect(fixture.llmClient.prompts.last, contains('chapterArchiveMarkdown'));
    expect(result.chapter.continuityVerdict, ContinuityVerdict.pass);
    expect(result.chapter.continuityReportMarkdown, contains('连续性审计报告'));
    expect(result.run.draftMarkdown, '雾气贴着码头爬上来。');
    expect(result.run.continuityVerdict, ContinuityVerdict.pass);
    final proposedChapter = await fixture.novelRepository.findChapter(
      result.chapter.id,
    );
    expect(proposedChapter!.memorySyncProposedContinuityIndex, '港务处线索');
    expect(
      proposedChapter.memorySyncProposedChapterArchiveMarkdown,
      contains('第 1 章'),
    );

    final task = await fixture.workflowRepository.findTask(
      result.workflowTaskId,
    );
    expect(task!.kind, chapterGenerationWorkflowTaskKind);
    expect(task.status, WorkflowTaskStatus.succeeded);

    final trace = await fixture.workflowRepository
        .watchPromptTrace(result.workflowTaskId)
        .first;
    expect(trace!.traceMarkdown, contains('generate_chapter_draft'));
    expect(trace.traceMarkdown, contains('audit_continuity'));
    expect(trace.traceMarkdown, contains('propose_memory_patch'));
    expect(trace.traceMarkdown, contains('雾气贴着码头爬上来'));
    expect(trace.traceMarkdown, isNot(contains('sk-secret-test-key')));
    expect(trace.traceMarkdown, contains('[REDACTED]'));
  });

  test(
    'high quality generation reviews revises polishes and persists report',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final fixture = await _Fixture.create(
        database,
        llmClient: _StaticLlmClient([
          _selectorAssets,
          '# 写作任务书\n\n- 强化章末钩子。',
          '初稿正文。',
          '扩写正文。',
          _qualityNeedsRevision,
          '修订正文。',
          _characterReviewWarning,
          '终稿正文。',
          _auditPass,
          _memoryPatchYaml,
        ]),
        withPromptAssets: true,
        withRuntimeMemory: true,
        withCharacterGraph: true,
        useHighQualityGeneration: true,
      );

      final result = await fixture.pipeline.generateChapter(
        projectId: fixture.project.id,
        chapterPlanId: fixture.plan.id,
      );

      expect(result.chapter.contentMarkdown, '终稿正文。');
      expect(result.run.draftMarkdown, '终稿正文。');
      expect(
        result.run.qualityReviewVerdict,
        ChapterQualityVerdict.needsRevision,
      );
      expect(result.run.qualityReviewReportMarkdown, contains('质量评审报告'));
      expect(result.run.qualityRevisionNotesMarkdown, contains('已执行一轮'));
      expect(result.run.qualityRevisionNotesMarkdown, contains('自动扩写一次'));
      expect(result.run.qualityRevisionNotesMarkdown, contains('返修后角色专项复审'));
      expect(result.run.qualityRevisionNotesMarkdown, contains('林岚台词偏硬'));
      expect(result.chapter.qualityReviewReportMarkdown, contains('追读钩子弱'));
      expect(result.chapter.qualityRevisionNotesMarkdown, contains('加强章末钩子'));
      expect(fixture.llmClient.invocationCount, 10);
      expect(fixture.llmClient.prompts[1], contains('章节策划编辑'));
      expect(fixture.llmClient.prompts[2], contains('Chapter Task Brief'));
      expect(fixture.llmClient.prompts[3], contains('扩写补足编辑'));
      expect(fixture.llmClient.prompts[4], contains('成稿质量编辑'));
      expect(fixture.llmClient.prompts[5], contains('改稿编辑'));
      expect(fixture.llmClient.prompts[6], contains('角色一致性专项审稿员'));
      expect(fixture.llmClient.prompts[7], contains('终稿润色编辑'));
      expect(fixture.llmClient.prompts[7], contains('林岚台词偏硬'));
      expect(fixture.llmClient.prompts[8], contains('连续性审计员'));

      final trace = await fixture.workflowRepository
          .watchPromptTrace(result.workflowTaskId)
          .first;
      expect(trace!.traceMarkdown, contains('plan_chapter_brief'));
      expect(trace.traceMarkdown, contains('expand_chapter_draft'));
      expect(trace.traceMarkdown, contains('review_chapter_quality'));
      expect(trace.traceMarkdown, contains('revise_chapter_quality'));
      expect(trace.traceMarkdown, contains('review_revision_character_hit'));
      expect(trace.traceMarkdown, contains('polish_chapter_draft'));
      expect(trace.traceMarkdown, contains('终稿正文'));
    },
  );

  test(
    'high quality generation skips expansion and revision on pass',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final longDraft = List.generate(
        2400,
        (index) => String.fromCharCode(0x3400 + index),
      ).join();
      final fixture = await _Fixture.create(
        database,
        llmClient: _StaticLlmClient([
          _selectorAssets,
          '# 写作任务书\n\n- 正常推进。',
          longDraft,
          _qualityPass,
          '润色后正文。',
          _auditPass,
          _memoryPatchYaml,
        ]),
        withPromptAssets: true,
        withRuntimeMemory: true,
        withCharacterGraph: true,
        useHighQualityGeneration: true,
      );

      final result = await fixture.pipeline.generateChapter(
        projectId: fixture.project.id,
        chapterPlanId: fixture.plan.id,
      );

      expect(result.chapter.contentMarkdown, '润色后正文。');
      expect(result.run.qualityReviewVerdict, ChapterQualityVerdict.pass);
      expect(result.run.qualityRevisionNotesMarkdown, contains('未执行'));
      expect(fixture.llmClient.invocationCount, 7);
      expect(
        fixture.llmClient.prompts.any((prompt) => prompt.contains('扩写补足编辑')),
        isFalse,
      );
      expect(
        fixture.llmClient.prompts.any((prompt) => prompt.contains('改稿编辑')),
        isFalse,
      );
      expect(
        fixture.llmClient.prompts.any(
          (prompt) => prompt.contains('角色一致性专项审稿员'),
        ),
        isFalse,
      );

      final trace = await fixture.workflowRepository
          .watchPromptTrace(result.workflowTaskId)
          .first;
      expect(trace!.traceMarkdown, isNot(contains('expand_chapter_draft')));
      expect(
        trace.traceMarkdown,
        isNot(contains('review_revision_character_hit')),
      );
    },
  );

  test('malformed post revision character review is non-blocking', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final longDraft = List.generate(
      2400,
      (index) => String.fromCharCode(0x3400 + index),
    ).join();
    final fixture = await _Fixture.create(
      database,
      llmClient: _StaticLlmClient([
        _selectorAssets,
        '# 写作任务书\n\n- 强化章末钩子。',
        longDraft,
        _qualityNeedsRevision,
        '修订正文。',
        '我忘了输出 YAML。',
        '终稿正文。',
        _auditPass,
        _memoryPatchYaml,
      ]),
      withPromptAssets: true,
      withRuntimeMemory: true,
      withCharacterGraph: true,
      useHighQualityGeneration: true,
    );

    final result = await fixture.pipeline.generateChapter(
      projectId: fixture.project.id,
      chapterPlanId: fixture.plan.id,
    );

    expect(result.chapter.contentMarkdown, '终稿正文。');
    expect(result.run.status, ChapterGenerationStatus.succeeded);
    expect(result.run.qualityRevisionNotesMarkdown, contains('复审输出解析失败'));
    expect(result.run.qualityRevisionNotesMarkdown, contains('已按非阻断处理'));
    expect(fixture.llmClient.invocationCount, 9);
    expect(fixture.llmClient.prompts[6], contains('复审输出解析失败'));
    expect(fixture.llmClient.prompts[7], contains('连续性审计员'));
  });

  test('single run can override project default high quality mode', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final fixture = await _Fixture.create(
      database,
      llmClient: _StaticLlmClient([
        _selectorAssets,
        '快速正文。',
        _auditPass,
        _memoryPatchYaml,
      ]),
      withPromptAssets: true,
      withRuntimeMemory: true,
      withCharacterGraph: true,
      useHighQualityGeneration: true,
    );

    final result = await fixture.pipeline.generateChapter(
      projectId: fixture.project.id,
      chapterPlanId: fixture.plan.id,
      useHighQualityGeneration: false,
    );

    expect(result.chapter.contentMarkdown, '快速正文。');
    expect(result.run.qualityReviewReportMarkdown, isEmpty);
    expect(fixture.llmClient.invocationCount, 4);
    expect(fixture.llmClient.prompts[1], contains('## Output Contract'));
    expect(fixture.llmClient.prompts[1], isNot(contains('Chapter Task Brief')));
  });

  test('batch generation syncs each chapter before continuing', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final fixture = await _Fixture.create(
      database,
      llmClient: _StaticLlmClient([
        _selectorAssets,
        '第一章正文。',
        _auditPass,
        '```yaml\n$_memoryPatchYaml\n```',
        _patchReviewPass,
        _selectorAssets,
        '第二章正文。',
        _auditPass,
        _secondMemoryPatchYaml,
        _patchReviewPass,
      ]),
      withRuntimeMemory: true,
      withCharacterGraph: true,
    );
    final firstPlan = fixture.plan;
    final secondPlan = await fixture.novelRepository.saveChapterPlan(
      input: ChapterPlanInput(
        projectId: fixture.project.id,
        volumeId: firstPlan.volumeId,
        volumeIndex: firstPlan.volumeIndex,
        volumeTitle: firstPlan.volumeTitle,
        chapterLocalIndex: 2,
        chapterIndex: 2,
        objectiveCard: const ChapterObjectiveCard(
          chapterTitle: '第二章',
          objective: '调查港务处。',
        ),
      ),
    );

    final result = await fixture.pipeline.startChapterGenerationBatch(
      projectId: fixture.project.id,
      chapterPlanIds: [firstPlan.id, secondPlan.id],
    );

    expect(result.batch.status, ChapterGenerationBatchStatus.succeeded);
    expect(result.items, hasLength(2));
    expect(
      result.items.map((item) => item.status),
      everyElement(ChapterGenerationBatchItemStatus.synced),
    );
    expect(fixture.llmClient.invocationCount, 10);
    expect(fixture.llmClient.prompts[4], contains('Memory Patch 审阅员'));
    final chapters = await fixture.novelRepository
        .watchChapters(fixture.project.id)
        .first;
    expect(chapters, hasLength(2));
    expect(
      chapters.map((chapter) => chapter.memorySyncStatus),
      everyElement(MemorySyncStatus.synced),
    );
    expect(chapters.first.memorySyncPatchYaml, isNot(contains('```')));
    expect(chapters.first.memorySyncPatchYaml, startsWith('runtimeMemory:'));
    final memory = await fixture.novelRepository.findRuntimeMemory(
      fixture.project.id,
    );
    expect(memory!.state.storySummary, '林岚调查港务处。');
  });

  test(
    'batch generation normalizes multiline runtime memory patch yaml',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final fixture = await _Fixture.create(
        database,
        llmClient: _StaticLlmClient([
          _selectorAssets,
          '第一章正文。',
          _auditPass,
          '''
runtimeMemory:
  runtimeState: 抵达雾港。
  runtimeThreads: 港务处线索待查。
  storySummary: 林岚抵达雾港。
  continuityIndex: 港务处线索
  chapterArchiveMarkdown:
  ## 第 1 章

  林岚抵达雾港。
''',
          _patchReviewPass,
        ]),
        withRuntimeMemory: true,
        withCharacterGraph: true,
      );

      final result = await fixture.pipeline.startChapterGenerationBatch(
        projectId: fixture.project.id,
        chapterPlanIds: [fixture.plan.id],
      );

      expect(result.batch.status, ChapterGenerationBatchStatus.succeeded);
      final chapters = await fixture.novelRepository
          .watchChapters(fixture.project.id)
          .first;
      expect(chapters.single.memorySyncPatchYaml, isNot(contains('```')));
      expect(
        chapters.single.memorySyncPatchYaml,
        contains('chapterArchiveMarkdown:'),
      );
      expect(
        chapters.single.memorySyncPatchYaml,
        contains('storySummary: 林岚抵达雾港。'),
      );
    },
  );

  test(
    'batch generation blocks when selected chapter already has content',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final fixture = await _Fixture.create(
        database,
        llmClient: _StaticLlmClient('正文。'),
      );
      await fixture.novelRepository.saveChapter(
        input: ProjectChapterInput(
          projectId: fixture.project.id,
          chapterPlanId: fixture.plan.id,
          chapterIndex: fixture.plan.chapterIndex,
          title: '第一章',
          contentMarkdown: '已有正文。',
        ),
      );

      await expectLater(
        fixture.pipeline.startChapterGenerationBatch(
          projectId: fixture.project.id,
          chapterPlanIds: [fixture.plan.id],
        ),
        throwsA(isA<StateError>()),
      );
      expect(fixture.llmClient.invocationCount, 0);
    },
  );

  test(
    'batch generation blocks when another chapter generation is running in project',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final fixture = await _Fixture.create(
        database,
        llmClient: _StaticLlmClient('正文。'),
      );
      final otherPlan = await fixture.novelRepository.saveChapterPlan(
        input: ChapterPlanInput(
          projectId: fixture.project.id,
          volumeId: fixture.plan.volumeId,
          volumeIndex: fixture.plan.volumeIndex,
          volumeTitle: fixture.plan.volumeTitle,
          chapterLocalIndex: 2,
          chapterIndex: 2,
          objectiveCard: const ChapterObjectiveCard(
            chapterTitle: '第二章',
            objective: '调查港务处。',
          ),
        ),
      );
      await fixture.novelRepository.createChapterGenerationRun(
        ChapterGenerationRunInput(
          projectId: fixture.project.id,
          chapterPlanId: otherPlan.id,
          providerId: fixture.project.defaultProviderId!,
          modelName: fixture.project.defaultModelName!,
        ),
      );

      await expectLater(
        fixture.pipeline.startChapterGenerationBatch(
          projectId: fixture.project.id,
          chapterPlanIds: [fixture.plan.id],
        ),
        throwsStateError,
      );
      expect(fixture.llmClient.invocationCount, 0);
    },
  );

  test('batch generation stop prevents subsequent waiting items', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final fixture = await _Fixture.create(
      database,
      llmClient: _StaticLlmClient('正文。'),
      withRuntimeMemory: true,
      withCharacterGraph: true,
    );
    final secondPlan = await fixture.novelRepository.saveChapterPlan(
      input: ChapterPlanInput(
        projectId: fixture.project.id,
        volumeId: fixture.plan.volumeId,
        volumeIndex: fixture.plan.volumeIndex,
        volumeTitle: fixture.plan.volumeTitle,
        chapterLocalIndex: 2,
        chapterIndex: 2,
        objectiveCard: const ChapterObjectiveCard(
          chapterTitle: '第二章',
          objective: '调查港务处。',
        ),
      ),
    );
    final batch = await fixture.novelRepository.createChapterGenerationBatch(
      ChapterGenerationBatchInput(
        projectId: fixture.project.id,
        chapterPlanIds: [fixture.plan.id, secondPlan.id],
        providerId: fixture.project.defaultProviderId!,
        modelName: fixture.project.defaultModelName!,
      ),
    );
    final firstItem =
        (await fixture.novelRepository
                .watchChapterGenerationBatchItems(batch.id)
                .first)
            .first;
    await fixture.novelRepository.updateChapterGenerationBatchItemState(
      id: firstItem.id,
      status: ChapterGenerationBatchItemStatus.synced,
      draftAttemptCount: 1,
      patchAttemptCount: 1,
      syncedAt: DateTime.now(),
      completedAt: DateTime.now(),
    );
    await fixture.pipeline.stopChapterGenerationBatch(batch.id);

    final result = await fixture.pipeline.processChapterGenerationBatch(
      batch.id,
    );

    expect(result.batch.status, ChapterGenerationBatchStatus.failed);
    expect(fixture.llmClient.invocationCount, 0);
    expect(result.items.first.status, ChapterGenerationBatchItemStatus.synced);
    expect(result.items.last.status, ChapterGenerationBatchItemStatus.waiting);
    expect(
      await fixture.novelRepository.findChapterByPlan(secondPlan.id),
      isNull,
    );
  });

  test('batch generation failure marks batch terminal', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final fixture = await _Fixture.create(
      database,
      llmClient: _StaticLlmClient('正文。'),
      withRuntimeMemory: true,
      withCharacterGraph: true,
    );
    final batch = await fixture.novelRepository.createChapterGenerationBatch(
      ChapterGenerationBatchInput(
        projectId: fixture.project.id,
        chapterPlanIds: [fixture.plan.id],
        providerId: fixture.project.defaultProviderId!,
        modelName: fixture.project.defaultModelName!,
      ),
    );
    final repository = _FailingBatchItemsRepository(
      delegate: fixture.novelRepository,
    );
    final pipeline = fixture.createPipeline(repository);

    await expectLater(
      pipeline.processChapterGenerationBatch(batch.id),
      throwsStateError,
    );

    final updated = await fixture.novelRepository.findChapterGenerationBatch(
      batch.id,
    );
    expect(updated!.status, ChapterGenerationBatchStatus.failed);
    expect(updated.errorMessage, contains('batch items stream failed'));
    expect(updated.completedAt, isNotNull);
    expect(
      await fixture.novelRepository.hasRunningChapterGenerationBatch(
        fixture.project.id,
      ),
      isFalse,
    );
    final task = await fixture.workflowRepository.findTask(
      batch.workflowTaskId,
    );
    expect(task!.status, WorkflowTaskStatus.failed);
  });

  test(
    'continues with warnings when prompt assets and memory are absent',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final fixture = await _Fixture.create(
        database,
        llmClient: _StaticLlmClient(['正文。', _auditPass, 'characters: []']),
      );

      final result = await fixture.pipeline.generateChapter(
        projectId: fixture.project.id,
        chapterPlanId: fixture.plan.id,
      );

      expect(result.chapter.contentMarkdown, '正文。');
      expect(result.contextWarnings, contains('项目未绑定 Voice Profile。'));
      expect(result.contextWarnings, contains('项目未绑定 Story Engine。'));
      expect(result.contextWarnings, contains('运行时记忆为空。'));
      expect(result.run.contextWarningsMarkdown, contains('Voice Profile'));
    },
  );

  test('warning audit saves chapter but pauses memory sync', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final fixture = await _Fixture.create(
      database,
      llmClient: _StaticLlmClient(['正文。', _auditWarning, 'characters: []']),
      withRuntimeMemory: false,
    );

    final result = await fixture.pipeline.generateChapter(
      projectId: fixture.project.id,
      chapterPlanId: fixture.plan.id,
    );

    expect(result.chapter.contentMarkdown, '正文。');
    expect(result.chapter.continuityVerdict, ContinuityVerdict.warning);
    expect(result.chapter.continuityReportMarkdown, contains('目标完成偏弱'));
    expect(result.chapter.memorySyncStatus, MemorySyncStatus.idle);
    expect(result.run.status, ChapterGenerationStatus.succeeded);
    expect(result.run.continuityVerdict, ContinuityVerdict.warning);
    expect(fixture.llmClient.invocationCount, 2);
    expect(fixture.llmClient.prompts.last, isNot(contains('结构化记忆 Patch')));
  });

  test('warning chapter can continue memory sync after review', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final fixture = await _Fixture.create(
      database,
      llmClient: _StaticLlmClient(['正文。', _auditWarning, _memoryPatchYaml]),
      withRuntimeMemory: false,
    );
    final result = await fixture.pipeline.generateChapter(
      projectId: fixture.project.id,
      chapterPlanId: fixture.plan.id,
    );

    final synced = await fixture.pipeline.proposeMemoryPatchForChapter(
      projectId: fixture.project.id,
      chapterId: result.chapter.id,
    );

    expect(synced.memorySyncStatus, MemorySyncStatus.pendingReview);
    expect(synced.memorySyncProposedStorySummary, '林岚抵达雾港。');
    expect(fixture.llmClient.invocationCount, 3);
    expect(fixture.llmClient.prompts.last, contains('结构化记忆 Patch'));
  });

  test(
    'fail audit blocks chapter save and keeps draft report on run',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final fixture = await _Fixture.create(
        database,
        llmClient: _StaticLlmClient(['冲突正文。', _auditFail]),
        withRuntimeMemory: false,
      );

      await expectLater(
        fixture.pipeline.generateChapter(
          projectId: fixture.project.id,
          chapterPlanId: fixture.plan.id,
        ),
        throwsStateError,
      );

      expect(
        await fixture.novelRepository.findChapterByPlan(fixture.plan.id),
        isNull,
      );
      final run =
          (await fixture.novelRepository
                  .watchChapterGenerationRuns(fixture.project.id)
                  .first)
              .single;
      expect(run.status, ChapterGenerationStatus.failed);
      expect(run.draftMarkdown, '冲突正文。');
      expect(run.continuityVerdict, ContinuityVerdict.fail);
      expect(run.continuityReportMarkdown, contains('世界规则被违反'));
      expect(run.errorMessage, contains('连续性审计未通过'));
      expect(fixture.llmClient.invocationCount, 2);
    },
  );

  test('malformed audit output downgrades to warning', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final fixture = await _Fixture.create(
      database,
      llmClient: _StaticLlmClient(['正文。', '我忘了输出 YAML。']),
      withRuntimeMemory: false,
    );

    final result = await fixture.pipeline.generateChapter(
      projectId: fixture.project.id,
      chapterPlanId: fixture.plan.id,
    );

    expect(result.chapter.contentMarkdown, '正文。');
    expect(result.chapter.continuityVerdict, ContinuityVerdict.warning);
    expect(result.chapter.continuityReportMarkdown, contains('审计输出解析失败'));
    expect(result.chapter.memorySyncStatus, MemorySyncStatus.idle);
    expect(fixture.llmClient.invocationCount, 2);
  });

  test(
    'injects chapter archive excerpt without mutating stored memory',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final fixture = await _Fixture.create(
        database,
        llmClient: _StaticLlmClient([
          _selectorArchive,
          '正文。',
          _auditPass,
          '''
runtimeMemory:
  runtimeState: 新状态。
  runtimeThreads: 新线索。
  storySummary: 新摘要。
  continuityIndex: 新索引。
  chapterArchiveMarkdown: 新归档。
''',
        ]),
        withRuntimeMemory: true,
        longChapterArchive: true,
      );

      final before = await fixture.novelRepository.findRuntimeMemory(
        fixture.project.id,
      );
      final result = await fixture.pipeline.generateChapter(
        projectId: fixture.project.id,
        chapterPlanId: fixture.plan.id,
      );
      final after = await fixture.novelRepository.findRuntimeMemory(
        fixture.project.id,
      );

      expect(result.chapter.contentMarkdown, '正文。');
      expect(fixture.llmClient.invocationCount, 4);
      expect(fixture.llmClient.prompts[0], contains('上下文筛选器'));
      expect(fixture.llmClient.prompts[0], contains('归档片段 0'));
      expect(fixture.llmClient.prompts[0], isNot(contains('归档片段 1999')));
      expect(
        fixture.llmClient.prompts[1],
        contains('Source ID: runtime_memory.archive'),
      );
      expect(fixture.llmClient.prompts[1], contains('归档片段 0'));
      expect(fixture.llmClient.prompts[1], isNot(contains('归档片段 1999')));
      expect(fixture.llmClient.prompts[2], contains('连续性审计员'));
      expect(
        fixture.llmClient.prompts[2],
        contains('Source ID: runtime_memory.archive'),
      );
      expect(fixture.llmClient.prompts[2], isNot(contains('归档片段 1999')));
      expect(before!.state.chapterArchiveMarkdown, contains('归档片段 1999'));
      expect(
        after!.state.chapterArchiveMarkdown,
        before.state.chapterArchiveMarkdown,
      );

      final trace = await fixture.workflowRepository
          .watchPromptTrace(result.workflowTaskId)
          .first;
      expect(trace!.traceMarkdown, contains('select_generation_context_1'));
      expect(trace.traceMarkdown, isNot(contains('digest_chapter_archive')));
    },
  );

  test('requires explicit replacement for existing chapter content', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final fixture = await _Fixture.create(
      database,
      llmClient: _StaticLlmClient(['新正文。', _auditPass, 'characters: []']),
      withRuntimeMemory: false,
    );
    final existing = await fixture.novelRepository.saveChapter(
      input: ProjectChapterInput(
        projectId: fixture.project.id,
        chapterPlanId: fixture.plan.id,
        chapterIndex: fixture.plan.chapterIndex,
        title: '第一章',
        contentMarkdown: '旧正文。',
      ),
    );
    await fixture.novelRepository.saveMemorySyncProposal(
      MemorySyncProposalInput(
        chapterId: existing.id,
        contentHash: existing.contentHash,
        proposedMemory: const RuntimeMemoryState(
          storySummary: '旧摘要。',
          continuityIndex: '旧索引。',
          chapterArchiveMarkdown: '旧归档。',
        ),
      ),
    );

    await expectLater(
      fixture.pipeline.generateChapter(
        projectId: fixture.project.id,
        chapterPlanId: fixture.plan.id,
      ),
      throwsStateError,
    );
    expect(fixture.llmClient.invocationCount, 0);

    final result = await fixture.pipeline.generateChapter(
      projectId: fixture.project.id,
      chapterPlanId: fixture.plan.id,
      replaceExisting: true,
    );

    expect(result.chapter.id, existing.id);
    expect(result.chapter.contentMarkdown, '新正文。');
    expect(result.chapter.memorySyncStatus, MemorySyncStatus.idle);
    expect(result.chapter.memorySyncProposedStorySummary, isEmpty);
    expect(result.chapter.memorySyncProposedContinuityIndex, isEmpty);
    expect(result.chapter.memorySyncProposedChapterArchiveMarkdown, isEmpty);
    expect(fixture.llmClient.prompts.join('\n'), isNot(contains('旧正文。')));
  });

  test(
    'records failed run when project or chapter plan validation fails',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final fixture = await _Fixture.create(
        database,
        llmClient: _StaticLlmClient('正文。'),
      );

      await expectLater(
        fixture.pipeline.generateChapter(
          projectId: fixture.project.id,
          chapterPlanId: 'missing-plan',
        ),
        throwsStateError,
      );

      expect(fixture.llmClient.invocationCount, 0);
      final runs = await fixture.novelRepository
          .watchChapterGenerationRuns(fixture.project.id)
          .first;
      final failed = runs.firstWhere(
        (run) => run.chapterPlanId == 'missing-plan',
      );
      expect(failed.status, ChapterGenerationStatus.failed);
      expect(failed.errorMessage, contains('Chapter Plan 不存在'));
      final task = await fixture.workflowRepository.findTask(
        failed.workflowTaskId,
      );
      expect(task!.status, WorkflowTaskStatus.failed);
    },
  );

  test('blocks concurrent generation for the same chapter plan', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final fixture = await _Fixture.create(
      database,
      llmClient: _StaticLlmClient('正文。'),
    );
    await fixture.novelRepository.createChapterGenerationRun(
      ChapterGenerationRunInput(
        projectId: fixture.project.id,
        chapterPlanId: fixture.plan.id,
        providerId: fixture.project.defaultProviderId!,
        modelName: fixture.project.defaultModelName!,
      ),
    );

    await expectLater(
      fixture.pipeline.generateChapter(
        projectId: fixture.project.id,
        chapterPlanId: fixture.plan.id,
      ),
      throwsStateError,
    );
    expect(fixture.llmClient.invocationCount, 0);
  });
}

class _Fixture {
  const _Fixture({
    required this.project,
    required this.plan,
    required this.pipeline,
    required this.novelRepository,
    required this.workflowRepository,
    required this.llmClient,
    required this.projectRepository,
    required this.providerRepository,
    required this.promptAssetResolver,
    required this.contextRetriever,
    required this.completionService,
  });

  final WritingProject project;
  final ChapterPlan plan;
  final ChapterGenerationPipeline pipeline;
  final DriftNovelWorkshopRepository novelRepository;
  final DriftWorkflowTaskRepository workflowRepository;
  final _StaticLlmClient llmClient;
  final DriftProjectRepository projectRepository;
  final DriftProviderConfigRepository providerRepository;
  final ProjectPromptAssetResolver promptAssetResolver;
  final WritingContextRetriever contextRetriever;
  final MarkdownCompletionService completionService;

  ChapterGenerationPipeline createPipeline(NovelWorkshopRepository repository) {
    return ChapterGenerationPipeline(
      repository: repository,
      projectRepository: projectRepository,
      providerRepository: providerRepository,
      promptAssetResolver: promptAssetResolver,
      contextAssembler: const WritingContextAssembler(),
      contextRetriever: contextRetriever,
      completionService: completionService,
      workflowTaskRepository: workflowRepository,
      cancellationRegistry: WorkflowTaskCancellationRegistry(),
    );
  }

  static Future<_Fixture> create(
    AppDatabase database, {
    required _StaticLlmClient llmClient,
    bool withPromptAssets = false,
    bool withRuntimeMemory = false,
    bool withCharacterGraph = false,
    bool longChapterArchive = false,
    bool useHighQualityGeneration = false,
  }) async {
    final providerRepository = DriftProviderConfigRepository(database);
    await providerRepository.saveProvider(
      input: const ProviderConfigInput(
        name: 'OpenAI',
        baseUrl: 'https://api.example.com/v1',
        apiKey: 'sk-secret-test-key',
        defaultModel: 'gpt-4.1-mini',
        systemPrompt: 'Never leak sk-secret-test-key.',
        isEnabled: true,
      ),
    );
    final provider = (await providerRepository.watchProviders().first).single;
    final styleRepository = DriftStyleLabRepository(database);
    final plotRepository = DriftPlotLabRepository(database);
    final projectRepository = DriftProjectRepository(database);
    StyleProfile? styleProfile;
    PlotProfile? plotProfile;
    if (withPromptAssets) {
      styleProfile = await _saveStyleProfile(
        repository: styleRepository,
        provider: provider,
      );
      plotProfile = await _savePlotProfile(
        repository: plotRepository,
        provider: provider,
      );
    }
    await projectRepository.saveProject(
      input: WritingProjectInput(
        title: '雾港纪事',
        description: '潮湿港城里的长篇悬疑。',
        status: ProjectStatus.active,
        defaultProviderId: provider.id,
        defaultModelName: provider.defaultModel,
        styleProfileId: styleProfile?.id,
        plotProfileId: plotProfile?.id,
        targetLength: 3200,
        narrativePerspective: '第三人称有限视角',
        useHighQualityGeneration: useHighQualityGeneration,
      ),
    );
    final project =
        (await projectRepository.watchProjects(ProjectStatus.active).first)
            .single;
    final novelRepository = DriftNovelWorkshopRepository(database);
    final volume = await novelRepository.saveChapterVolume(
      input: ChapterVolumeInput(
        projectId: project.id,
        volumeIndex: 1,
        title: '第一卷',
      ),
    );
    final plan = await novelRepository.saveChapterPlan(
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
    if (withCharacterGraph) {
      await novelRepository.saveCharacter(
        input: NovelCharacterInput(
          projectId: project.id,
          name: '林岚',
          tags: '主角,调查者',
          role: '调查失踪案的外来者',
          currentStatus: '刚抵达雾港。',
        ),
      );
    }
    if (withRuntimeMemory) {
      final archive = longChapterArchive
          ? List.generate(
              2000,
              (index) => '归档片段 $index：林岚继续追查港务处线索。',
            ).join('\n')
          : '## 第 0 章\n\n林岚收到失踪案委托。';
      await novelRepository.saveRuntimeMemory(
        projectId: project.id,
        state: RuntimeMemoryState(
          runtimeState: '- 潮汐即将封城。',
          runtimeThreads: '- 港务处线索未解。',
          storySummary: '林岚追查失踪案。',
          continuityIndex: '- 港务处线索',
          chapterArchiveMarkdown: archive,
        ),
      );
    }
    final workflowRepository = DriftWorkflowTaskRepository(database);
    final completionService = MarkdownCompletionService(
      invocation: LlmInvocationService(client: llmClient),
    );
    final promptAssetResolver = ProjectPromptAssetResolver(
      projectRepository: projectRepository,
      styleLabRepository: styleRepository,
      plotLabRepository: plotRepository,
    );
    final contextRetriever = WritingContextRetriever(
      completionService: completionService,
    );
    final pipeline = ChapterGenerationPipeline(
      repository: novelRepository,
      projectRepository: projectRepository,
      providerRepository: providerRepository,
      promptAssetResolver: promptAssetResolver,
      contextAssembler: const WritingContextAssembler(),
      contextRetriever: contextRetriever,
      completionService: completionService,
      workflowTaskRepository: workflowRepository,
      cancellationRegistry: WorkflowTaskCancellationRegistry(),
    );
    return _Fixture(
      project: project,
      plan: plan,
      pipeline: pipeline,
      novelRepository: novelRepository,
      workflowRepository: workflowRepository,
      llmClient: llmClient,
      projectRepository: projectRepository,
      providerRepository: providerRepository,
      promptAssetResolver: promptAssetResolver,
      contextRetriever: contextRetriever,
      completionService: completionService,
    );
  }
}

class _FailingBatchItemsRepository implements NovelWorkshopRepository {
  const _FailingBatchItemsRepository({required this.delegate});

  final DriftNovelWorkshopRepository delegate;

  @override
  Future<ChapterGenerationBatch?> findChapterGenerationBatch(String id) {
    return delegate.findChapterGenerationBatch(id);
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
  }) {
    return delegate.updateChapterGenerationBatchState(
      id: id,
      status: status,
      providerId: providerId,
      modelName: modelName,
      errorMessage: errorMessage,
      logs: logs,
      startedAt: startedAt,
      completedAt: completedAt,
    );
  }

  @override
  Stream<List<ChapterGenerationBatchItem>> watchChapterGenerationBatchItems(
    String batchId,
  ) async* {
    throw StateError('batch items stream failed');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<StyleProfile> _saveStyleProfile({
  required DriftStyleLabRepository repository,
  required ProviderConfig provider,
}) async {
  final sample = await repository.saveSample(
    const StyleSampleInput(
      sourceType: StyleSampleSourceType.txt,
      title: '风格样本',
      content: '第一段。\n\n第二段。',
    ),
  );
  final run = await repository.createRun(
    StyleAnalysisRunInput(
      sampleId: sample.id,
      providerId: provider.id,
      modelName: provider.defaultModel,
      styleName: '雾港文风',
      characterCount: sample.characterCount,
    ),
  );
  await repository.updateRunState(
    id: run.id,
    status: StyleAnalysisStatus.succeeded,
    analysisReportMarkdown: '# 风格报告',
    voiceProfileMarkdown: _validVoiceProfile,
  );
  return repository.saveProfileFromRun(
    StyleProfileInput(
      runId: run.id,
      styleName: '雾港文风',
      profileMarkdown: _validVoiceProfile,
    ),
  );
}

Future<PlotProfile> _savePlotProfile({
  required DriftPlotLabRepository repository,
  required ProviderConfig provider,
}) async {
  final sample = await repository.saveSample(
    const PlotSampleInput(
      sourceType: PlotSampleSourceType.txt,
      title: '剧情样本',
      content: '第一章。\n\n第二章。',
    ),
  );
  final run = await repository.createRun(
    PlotAnalysisRunInput(
      sampleId: sample.id,
      providerId: provider.id,
      modelName: provider.defaultModel,
      plotName: '雾港剧情',
      characterCount: sample.characterCount,
    ),
  );
  await repository.updateRunState(
    id: run.id,
    status: PlotAnalysisStatus.succeeded,
    analysisReportMarkdown: '# 剧情报告',
    plotSkeletonMarkdown: '# 全书骨架\n\n- 雾港失踪案持续升级。',
    storyEngineMarkdown: _validStoryEngine,
  );
  return repository.saveProfileFromRun(
    PlotProfileInput(
      runId: run.id,
      plotName: '雾港剧情',
      storyEngineMarkdown: _validStoryEngine,
    ),
  );
}

class _StaticLlmClient implements LlmClient {
  _StaticLlmClient(Object output)
    : outputs = output is List<Object> ? List<Object>.from(output) : [output];

  final List<Object> outputs;
  int invocationCount = 0;
  String? lastPrompt;
  final prompts = <String>[];

  @override
  Stream<LlmStreamEvent> streamChat({
    required ProviderConfig provider,
    required LlmRequest request,
  }) async* {
    invocationCount += 1;
    lastPrompt = request.messages.map((message) => message.content).join('\n');
    prompts.add(lastPrompt!);
    final output = outputs[(invocationCount - 1).clamp(0, outputs.length - 1)];
    if (output is! String) {
      throw output;
    }
    yield LlmStreamDelta(output);
    yield const LlmStreamDone();
  }
}

const _validVoiceProfile = '''---
name: "雾港文风"
---

# Voice Profile

- 短句。
- 压迫感强。''';

const _validStoryEngine = '''---
name: "雾港剧情"
---

# Plot Writing Guide

- 目标 -> 阻碍 -> 半兑现。''';

const _selectorAssets = '''
selected_chapters: []
selected_assets:
  - id: voice_profile
    reason: 保持项目文风
  - id: story_engine
    reason: 保持剧情推进规则
  - id: runtime_memory.threads
    reason: 承接未解决线索
summary: 第一章仅需要资产和运行时线索
''';

const _selectorArchive = '''
selected_chapters: []
selected_assets:
  - id: runtime_memory.archive
    reason: 长归档需要压缩后承接
summary: 使用章节归档作为承接依据
''';

const _auditPass = '''---
verdict: pass
summary: 未发现连续性硬冲突。
characterState: pass
worldRules: pass
foreshadowing: pass
chapterObjective: pass
blockingIssues: []
warningIssues: []
---
# 连续性审计报告

未发现连续性硬冲突。''';

const _auditWarning = '''---
verdict: warning
summary: 目标完成偏弱，但没有硬冲突。
characterState: pass
worldRules: pass
foreshadowing: warning
chapterObjective: warning
blockingIssues: []
warningIssues:
  - 目标完成偏弱
---
# 连续性审计报告

目标完成偏弱，需要人工确认后再同步记忆。''';

const _auditFail = '''---
verdict: fail
summary: 世界规则被违反。
characterState: pass
worldRules: fail
foreshadowing: pass
chapterObjective: warning
blockingIssues:
  - 世界规则被违反
warningIssues: []
---
# 连续性审计报告

世界规则被违反，不能保存为正式章节。''';

const _qualityNeedsRevision = '''---
verdict: needsRevision
needsRevision: true
overallScore: 62
dimensions:
  thrill: 70
  pacing: 65
  pull: 55
  characterHit: 72
  naturalLanguage: 68
majorIssues:
  - 追读钩子弱
revisionInstructions: |-
  加强章末钩子，压缩解释性段落。
---
# 质量评审报告

追读钩子弱，需要自动修订一轮。''';

const _qualityPass = '''---
verdict: pass
needsRevision: false
overallScore: 88
dimensions:
  thrill: 88
  pacing: 86
  pull: 87
  characterHit: 90
  naturalLanguage: 89
majorIssues: []
revisionInstructions: |-
  无需修订。
---
# 质量评审报告

读感稳定，无需自动修订。''';

const _characterReviewWarning = '''---
verdict: warning
issues:
  - 林岚台词偏硬
polishInstructions: |-
  终稿润色时把林岚的解释句改成更短的行动和对白。
---
# 返修后角色专项复审

- 林岚台词偏硬：修订稿中解释句偏多，润色时应压成更短的动作和对白。''';

const _patchReviewPass = '''---
verdict: pass
summary: Patch 可以安全应用。
characterGraph: pass
runtimeMemory: pass
chapterArchive: pass
blockingIssues: []
warningIssues: []
---
# Memory Patch 审阅报告

Patch 可以安全应用。''';

const _memoryPatchYaml = '''
runtimeMemory:
  runtimeState: 抵达雾港。
  runtimeThreads: 港务处线索待查。
  storySummary: 林岚抵达雾港。
  continuityIndex: 港务处线索
  chapterArchiveMarkdown: |-
    ## 第 1 章

    林岚抵达雾港。
''';

const _secondMemoryPatchYaml = '''
runtimeMemory:
  runtimeState: 港务处调查中。
  runtimeThreads: 沉船账本待查。
  storySummary: 林岚调查港务处。
  continuityIndex: 沉船账本
  chapterArchiveMarkdown: |-
    ## 第 2 章

    林岚调查港务处。
''';
