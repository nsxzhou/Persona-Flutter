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
import 'package:persona_flutter/src/features/novel_workshop/application/chapter_enrichment_pipeline.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/project_prompt_asset_resolver.dart';
import 'package:persona_flutter/src/features/novel_workshop/data/drift_novel_workshop_repository.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/novel_workshop.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/writing_context.dart';
import 'package:persona_flutter/src/features/plot_lab/data/drift_plot_lab_repository.dart';
import 'package:persona_flutter/src/features/projects/data/drift_project_repository.dart';
import 'package:persona_flutter/src/features/projects/domain/writing_project.dart';
import 'package:persona_flutter/src/features/settings/data/drift_provider_config_repository.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';
import 'package:persona_flutter/src/features/style_lab/data/drift_style_lab_repository.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_analysis_run.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_profile.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_sample.dart';

void main() {
  test(
    'enriches selected chapters and does not auto-apply generated text',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final fixture = await _Fixture.create(
        database,
        llmClient: _StaticLlmClient(['```markdown\n新正文一。\n```']),
      );

      final result = await fixture.pipeline.enrichChapters(
        projectId: fixture.project.id,
        chapterIds: [fixture.chapters.first.id],
        instruction: '增强心理描写。',
        expansionRatioPercent: 25,
      );

      expect(result.batch.status, ChapterEnrichmentBatchStatus.succeeded);
      expect(result.items.single.status, ChapterEnrichmentItemStatus.generated);
      expect(result.items.single.originalContentMarkdown, '旧正文1。');
      expect(result.items.single.generatedContentMarkdown, '新正文一。');
      expect(
        (await fixture.novelRepository.findChapter(
          fixture.chapters.first.id,
        ))!.contentMarkdown,
        '旧正文1。',
      );
      expect(fixture.llmClient.prompts.single, contains('# Voice Profile'));
      expect(fixture.llmClient.prompts.single, contains('增强心理描写'));
      expect(fixture.llmClient.prompts.single, isNot(contains('Story Engine')));
      expect(
        fixture.llmClient.prompts.single,
        isNot(contains('Runtime Memory')),
      );

      final task = await fixture.workflowRepository.findTask(
        result.batch.workflowTaskId,
      );
      expect(task!.kind, chapterEnrichmentWorkflowTaskKind);
      expect(task.status, WorkflowTaskStatus.succeeded);

      await fixture.novelRepository.applyChapterEnrichmentItem(
        result.items.single.id,
      );
      expect(
        (await fixture.novelRepository.findChapter(
          fixture.chapters.first.id,
        ))!.contentMarkdown,
        '新正文一。',
      );
    },
  );

  test('continues batch when one chapter enrichment fails', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final fixture = await _Fixture.create(
      database,
      llmClient: _StaticLlmClient(['新正文一。', '']),
    );

    final result = await fixture.pipeline.enrichChapters(
      projectId: fixture.project.id,
      chapterIds: fixture.chapters.map((chapter) => chapter.id).toList(),
      instruction: '补足环境压迫感。',
    );

    expect(result.batch.status, ChapterEnrichmentBatchStatus.partialFailed);
    expect(result.items, hasLength(2));
    expect(result.items.first.status, ChapterEnrichmentItemStatus.generated);
    expect(result.items.last.status, ChapterEnrichmentItemStatus.failed);
    expect(fixture.llmClient.invocationCount, 4);
  });

  test('rejects standard projects', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final fixture = await _Fixture.create(
      database,
      llmClient: _StaticLlmClient(['新正文。']),
      origin: ProjectOrigin.standard,
    );

    await expectLater(
      fixture.pipeline.enrichChapters(
        projectId: fixture.project.id,
        chapterIds: [fixture.chapters.first.id],
        instruction: '加料。',
      ),
      throwsStateError,
    );
    expect(fixture.llmClient.invocationCount, 0);
  });
}

class _Fixture {
  const _Fixture({
    required this.project,
    required this.chapters,
    required this.pipeline,
    required this.novelRepository,
    required this.workflowRepository,
    required this.llmClient,
  });

  final WritingProject project;
  final List<ProjectChapter> chapters;
  final ChapterEnrichmentPipeline pipeline;
  final DriftNovelWorkshopRepository novelRepository;
  final DriftWorkflowTaskRepository workflowRepository;
  final _StaticLlmClient llmClient;

  static Future<_Fixture> create(
    AppDatabase database, {
    required _StaticLlmClient llmClient,
    ProjectOrigin origin = ProjectOrigin.importedEnrichment,
  }) async {
    final providerRepository = DriftProviderConfigRepository(database);
    await providerRepository.saveProvider(
      input: const ProviderConfigInput(
        name: 'OpenAI',
        baseUrl: 'https://api.example.com/v1',
        apiKey: 'sk-secret-test-key',
        defaultModel: 'gpt-4.1-mini',
        systemPrompt: '',
        isEnabled: true,
      ),
    );
    final provider = (await providerRepository.watchProviders().first).single;
    final styleRepository = DriftStyleLabRepository(database);
    final styleProfile = await _saveStyleProfile(
      repository: styleRepository,
      provider: provider,
    );
    final plotRepository = DriftPlotLabRepository(database);
    final projectRepository = DriftProjectRepository(database);
    final project = await projectRepository.createProject(
      WritingProjectInput(
        title: '导入小说',
        description: '从 sample.txt 导入。',
        status: ProjectStatus.active,
        defaultProviderId: provider.id,
        defaultModelName: provider.defaultModel,
        styleProfileId: styleProfile.id,
        origin: origin,
      ),
    );
    final novelRepository = DriftNovelWorkshopRepository(database);
    final volume = await novelRepository.saveChapterVolume(
      input: ChapterVolumeInput(
        projectId: project.id,
        volumeIndex: 1,
        title: '导入正文',
      ),
    );
    final chapters = <ProjectChapter>[];
    for (var index = 1; index <= 2; index += 1) {
      final plan = await novelRepository.saveChapterPlan(
        input: ChapterPlanInput(
          projectId: project.id,
          volumeId: volume.id,
          volumeIndex: 1,
          volumeTitle: volume.title,
          chapterLocalIndex: index,
          chapterIndex: index,
          objectiveCard: ChapterObjectiveCard(chapterTitle: '第$index章'),
        ),
      );
      chapters.add(
        await novelRepository.saveChapter(
          input: ProjectChapterInput(
            projectId: project.id,
            chapterPlanId: plan.id,
            chapterIndex: index,
            title: '第$index章',
            contentMarkdown: '旧正文$index。',
          ),
        ),
      );
    }
    final workflowRepository = DriftWorkflowTaskRepository(database);
    final pipeline = ChapterEnrichmentPipeline(
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
      cancellationRegistry: WorkflowTaskCancellationRegistry(),
    );
    return _Fixture(
      project: project,
      chapters: chapters,
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

class _StaticLlmClient implements LlmClient {
  _StaticLlmClient(this.outputs);

  final List<String> outputs;
  int invocationCount = 0;
  final prompts = <String>[];

  @override
  Stream<LlmStreamEvent> streamChat({
    required ProviderConfig provider,
    required LlmRequest request,
  }) async* {
    prompts.add(request.messages.map((message) => message.content).join('\n'));
    final output = outputs[invocationCount.clamp(0, outputs.length - 1)];
    invocationCount += 1;
    if (output.isNotEmpty) {
      yield LlmStreamDelta(output);
    }
    yield const LlmStreamDone();
  }
}

const _validVoiceProfile = '''---
name: "雾港文风"
---

# Voice Profile

- 短句。
- 压迫感强。''';
