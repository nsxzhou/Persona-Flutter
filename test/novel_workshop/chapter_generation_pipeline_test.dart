import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/core/database/app_database.dart';
import 'package:persona_flutter/src/core/llm/application/llm_invocation_service.dart';
import 'package:persona_flutter/src/core/llm/application/markdown_completion_service.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_client.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_request.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_stream_event.dart';
import 'package:persona_flutter/src/core/tasks/data/drift_workflow_task_repository.dart';
import 'package:persona_flutter/src/core/tasks/domain/workflow_task.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/chapter_generation_pipeline.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/project_prompt_asset_resolver.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/writing_context_assembler.dart';
import 'package:persona_flutter/src/features/novel_workshop/data/drift_novel_workshop_repository.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/novel_workshop.dart';
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
  test('generates chapter content and records workflow trace', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final fixture = await _Fixture.create(
      database,
      llmClient: _StaticLlmClient('```markdown\n雾气贴着码头爬上来。\n```'),
      withPromptAssets: true,
      withRuntimeMemory: true,
    );

    final result = await fixture.pipeline.generateChapter(
      projectId: fixture.project.id,
      chapterPlanId: fixture.plan.id,
    );

    expect(result.chapter.title, '第一章');
    expect(result.chapter.contentMarkdown, '雾气贴着码头爬上来。');
    expect(result.run.status, ChapterGenerationStatus.succeeded);
    expect(result.workflowTaskId, result.run.workflowTaskId);
    expect(result.contextWarnings, isEmpty);
    expect(fixture.llmClient.invocationCount, 1);
    expect(fixture.llmClient.lastPrompt, contains('## Output Contract'));
    expect(fixture.llmClient.lastPrompt, contains('# Voice Profile'));
    expect(fixture.llmClient.lastPrompt, contains('# Plot Writing Guide'));
    expect(fixture.llmClient.lastPrompt, contains('- Project Title: 雾港纪事'));
    expect(fixture.llmClient.lastPrompt, contains('只写当前章节正文'));

    final task = await fixture.workflowRepository.findTask(
      result.workflowTaskId,
    );
    expect(task!.kind, chapterGenerationWorkflowTaskKind);
    expect(task.status, WorkflowTaskStatus.succeeded);

    final trace = await fixture.workflowRepository
        .watchPromptTrace(result.workflowTaskId)
        .first;
    expect(trace!.traceMarkdown, contains('generate_chapter_draft'));
    expect(trace.traceMarkdown, contains('雾气贴着码头爬上来'));
    expect(trace.traceMarkdown, isNot(contains('sk-secret-test-key')));
    expect(trace.traceMarkdown, contains('[REDACTED]'));
  });

  test(
    'continues with warnings when prompt assets and memory are absent',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final fixture = await _Fixture.create(
        database,
        llmClient: _StaticLlmClient('正文。'),
      );

      final result = await fixture.pipeline.generateChapter(
        projectId: fixture.project.id,
        chapterPlanId: fixture.plan.id,
      );

      expect(result.chapter.contentMarkdown, '正文。');
      expect(result.contextWarnings, contains('项目未绑定 Voice Profile。'));
      expect(result.contextWarnings, contains('项目未绑定 Story Engine。'));
      expect(result.contextWarnings, contains('运行时记忆为空。'));
      expect(result.contextWarnings, contains('Voice Profile 为空。'));
      expect(result.contextWarnings, contains('Story Engine 为空。'));
      expect(result.run.contextWarningsMarkdown, contains('Voice Profile'));
    },
  );

  test('requires explicit replacement for existing chapter content', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final fixture = await _Fixture.create(
      database,
      llmClient: _StaticLlmClient('新正文。'),
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
        proposedMemory: const RuntimeMemoryState(storySummary: '旧摘要。'),
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
  });

  final WritingProject project;
  final ChapterPlan plan;
  final ChapterGenerationPipeline pipeline;
  final DriftNovelWorkshopRepository novelRepository;
  final DriftWorkflowTaskRepository workflowRepository;
  final _StaticLlmClient llmClient;

  static Future<_Fixture> create(
    AppDatabase database, {
    required _StaticLlmClient llmClient,
    bool withPromptAssets = false,
    bool withRuntimeMemory = false,
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
      ),
    );
    final project =
        (await projectRepository.watchProjects(ProjectStatus.active).first)
            .single;
    final novelRepository = DriftNovelWorkshopRepository(database);
    final plan = await novelRepository.saveChapterPlan(
      input: ChapterPlanInput(
        projectId: project.id,
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
    if (withRuntimeMemory) {
      await novelRepository.saveRuntimeMemory(
        projectId: project.id,
        state: const RuntimeMemoryState(
          charactersStatus: '- 林岚：刚抵达雾港。',
          runtimeState: '- 潮汐即将封城。',
          runtimeThreads: '- 港务处线索未解。',
          storySummary: '林岚追查失踪案。',
        ),
      );
    }
    final workflowRepository = DriftWorkflowTaskRepository(database);
    final pipeline = ChapterGenerationPipeline(
      repository: novelRepository,
      projectRepository: projectRepository,
      providerRepository: providerRepository,
      promptAssetResolver: ProjectPromptAssetResolver(
        projectRepository: projectRepository,
        styleLabRepository: styleRepository,
        plotLabRepository: plotRepository,
      ),
      contextAssembler: const WritingContextAssembler(),
      completionService: MarkdownCompletionService(
        invocation: LlmInvocationService(client: llmClient),
      ),
      workflowTaskRepository: workflowRepository,
    );
    return _Fixture(
      project: project,
      plan: plan,
      pipeline: pipeline,
      novelRepository: novelRepository,
      workflowRepository: workflowRepository,
      llmClient: llmClient,
    );
  }
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
  _StaticLlmClient(this.output);

  final String output;
  int invocationCount = 0;
  String? lastPrompt;

  @override
  Stream<LlmStreamEvent> streamChat({
    required ProviderConfig provider,
    required LlmRequest request,
  }) async* {
    invocationCount += 1;
    lastPrompt = request.messages.map((message) => message.content).join('\n');
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
