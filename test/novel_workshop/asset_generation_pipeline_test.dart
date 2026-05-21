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
import 'package:persona_flutter/src/features/novel_workshop/application/asset_generation_pipeline.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/asset_generation_prompts.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/project_prompt_asset_resolver.dart';
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

void main() {
  test('prompt builder includes required context and output contracts', () {
    const builder = AssetGenerationPromptBuilder();
    final project = WritingProject(
      id: 'project-1',
      title: '雾港纪事',
      description: '潮湿港城里的长篇悬疑。',
      status: ProjectStatus.active,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    final bible = ProjectBible(
      projectId: project.id,
      descriptionMarkdown: project.description,
      worldBuildingMarkdown: '雾港长期被潮汐封锁。',
      charactersBlueprintMarkdown: '林岚：调查者。',
      outlineMasterMarkdown: '失踪案引出港务处阴谋。',
      outlineDetailYaml: '',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    final worldPrompt = builder.buildPrompt(
      kind: AssetGenerationKind.worldBuilding,
      project: project,
      bible: bible,
      assets: const ProjectPromptAssets(),
    );
    final outlinePrompt = builder.buildPrompt(
      kind: AssetGenerationKind.outlineDetailYaml,
      project: project,
      bible: bible,
      assets: const ProjectPromptAssets(
        storyEngineMarkdown: '# Plot Writing Guide',
      ),
    );
    final charactersPrompt = builder.buildPrompt(
      kind: AssetGenerationKind.charactersBlueprint,
      project: project,
      bible: bible,
      assets: const ProjectPromptAssets(),
    );
    final volumePrompt = builder.buildPrompt(
      kind: AssetGenerationKind.volumeBlueprintYaml,
      project: project,
      bible: bible,
      assets: const ProjectPromptAssets(
        storyEngineMarkdown: '# Plot Writing Guide',
      ),
    );

    expect(worldPrompt, contains('只输出 Markdown 文档'));
    expect(worldPrompt, contains('雾港纪事'));
    expect(worldPrompt, contains('不要输出代码围栏'));
    expect(worldPrompt, contains('核心 DNA'));
    expect(worldPrompt, contains('物理维度'));
    expect(worldPrompt, contains('社会维度'));
    expect(worldPrompt, contains('隐喻维度'));
    expect(charactersPrompt, contains('只输出 YAML'));
    expect(charactersPrompt, contains('根节点允许 `characters` 和 `relationships`'));
    expect(charactersPrompt, contains('三级驱动力'));
    expect(charactersPrompt, contains('权力差'));
    expect(charactersPrompt, contains('不要新增 schema 之外的字段'));
    expect(volumePrompt, contains('根节点必须是 `volumes`'));
    expect(volumePrompt, contains('核心 DNA'));
    expect(volumePrompt, contains('半兑现'));
    expect(volumePrompt, contains('反噬'));
    expect(outlinePrompt, contains('只输出 YAML'));
    expect(outlinePrompt, contains('根节点必须是 `volumes`'));
    expect(outlinePrompt, contains('草稿应用时系统只会合并这个目标卷'));
    expect(outlinePrompt, contains('3-5 章'));
    expect(outlinePrompt, contains('压力出现'));
    expect(outlinePrompt, contains('伏笔埋设或回收'));
    expect(outlinePrompt, contains('# Plot Writing Guide'));
  });

  test(
    'generates recoverable asset draft and applies to project bible',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final fixture = await _Fixture.create(
        database,
        llmClient: _StaticLlmClient('# 世界观\n\n雾港由七个港务家族控制。'),
      );

      final result = await fixture.pipeline.generateAsset(
        projectId: fixture.project.id,
        kind: AssetGenerationKind.worldBuilding,
      );

      expect(result.run.status, AssetGenerationStatus.succeeded);
      expect(result.run.draftMarkdown, contains('七个港务家族'));

      final recovered = await fixture.novelRepository.findAssetGenerationRun(
        result.run.id,
      );
      expect(recovered!.draftMarkdown, result.run.draftMarkdown);

      final saved = await fixture.novelRepository.applyAssetGenerationDraft(
        result.run.id,
      );
      expect(saved.worldBuildingMarkdown, contains('七个港务家族'));

      final task = await fixture.workflowRepository.findTask(
        result.workflowTaskId,
      );
      expect(task!.kind, assetGenerationWorkflowTaskKind);
      expect(task.status, WorkflowTaskStatus.succeeded);

      final trace = await fixture.workflowRepository
          .watchPromptTrace(result.workflowTaskId)
          .first;
      expect(trace!.traceMarkdown, contains('generate_worldBuilding'));
      expect(trace.traceMarkdown, isNot(contains('sk-secret-test-key')));
      expect(trace.traceMarkdown, contains('[REDACTED]'));
    },
  );

  test('validates generated outline yaml before saving draft', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final fixture = await _Fixture.create(
      database,
      llmClient: _StaticLlmClient('''
```yaml
volumes:
  - index: 1
    title: 第一卷
    chapters:
      - index: 1
        title: 第一章
        objective: 主角进入雾港。
```
'''),
      withPlotProfile: true,
    );

    final result = await fixture.pipeline.generateAsset(
      projectId: fixture.project.id,
      kind: AssetGenerationKind.outlineDetailYaml,
    );
    final saved = await fixture.novelRepository.applyAssetGenerationDraft(
      result.run.id,
    );

    expect(saved.outlineDetailYaml, contains('volumes:'));
    final plans = await fixture.novelRepository
        .watchChapterPlans(fixture.project.id)
        .first;
    expect(plans.single.objectiveCard.chapterTitle, '第一章');
  });

  test(
    'generates character asset when secrets are emitted as a list',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final fixture = await _Fixture.create(
        database,
        llmClient: _StaticLlmClient('''
characters:
  - name: 林岚
    aliases:
      - 林侦探
    tags:
      - 调查者
    faction: 港务处外部顾问
    role: 主角
    longTermGoal: 查清旧案真相。
    currentStatus: 抵达雾港。
    secrets:
      - 不要提前揭露旧案身份
      - 曾经隐瞒关键证词
    firstChapterIndex: 1
relationships:
  - from: 林岚
    to: 林岚
    type: 自我冲突
    strength: -2
    status: 回避真相
    description: 对旧案愧疚形成行动压力。
'''),
      );

      final result = await fixture.pipeline.generateAsset(
        projectId: fixture.project.id,
        kind: AssetGenerationKind.charactersBlueprint,
      );

      expect(result.run.status, AssetGenerationStatus.succeeded);
      expect(result.run.draftMarkdown, contains('secrets:'));

      final trace = await fixture.workflowRepository
          .watchPromptTrace(result.workflowTaskId)
          .first;
      expect(trace!.traceMarkdown, contains('generate_charactersBlueprint'));
      expect(trace.traceMarkdown, isNot(contains('sk-secret-test-key')));
      expect(trace.traceMarkdown, contains('[REDACTED]'));
    },
  );
}

class _Fixture {
  const _Fixture({
    required this.project,
    required this.pipeline,
    required this.novelRepository,
    required this.workflowRepository,
  });

  final WritingProject project;
  final AssetGenerationPipeline pipeline;
  final DriftNovelWorkshopRepository novelRepository;
  final DriftWorkflowTaskRepository workflowRepository;

  static Future<_Fixture> create(
    AppDatabase database, {
    required _StaticLlmClient llmClient,
    bool withPlotProfile = false,
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
    final projectRepository = DriftProjectRepository(database);
    final styleRepository = DriftStyleLabRepository(database);
    final plotRepository = DriftPlotLabRepository(database);
    PlotProfile? plotProfile;
    if (withPlotProfile) {
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
        plotProfileId: plotProfile?.id,
      ),
    );
    final project =
        (await projectRepository.watchProjects(ProjectStatus.active).first)
            .single;
    final novelRepository = DriftNovelWorkshopRepository(database);
    await novelRepository.ensureProjectBible(project.id);
    final workflowRepository = DriftWorkflowTaskRepository(database);
    final pipeline = AssetGenerationPipeline(
      repository: novelRepository,
      projectRepository: projectRepository,
      providerRepository: providerRepository,
      promptAssetResolver: ProjectPromptAssetResolver(
        projectRepository: projectRepository,
        styleLabRepository: styleRepository,
        plotLabRepository: plotRepository,
      ),
      completionService: MarkdownCompletionService(
        invocation: LlmInvocationService(client: llmClient),
      ),
      workflowTaskRepository: workflowRepository,
    );
    return _Fixture(
      project: project,
      pipeline: pipeline,
      novelRepository: novelRepository,
      workflowRepository: workflowRepository,
    );
  }
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
    plotSkeletonMarkdown: '# 全书骨架',
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

  @override
  Stream<LlmStreamEvent> streamChat({
    required ProviderConfig provider,
    required LlmRequest request,
  }) async* {
    yield LlmStreamDelta(output);
    yield const LlmStreamDone();
  }
}

const _validStoryEngine = '''---
name: "雾港剧情"
---

# Plot Writing Guide

- 目标 -> 阻碍 -> 半兑现。''';
