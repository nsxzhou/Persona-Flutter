import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/core/database/app_database.dart';
import 'package:persona_flutter/src/core/llm/application/markdown_completion_service.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_client.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_request.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_stream_event.dart';
import 'package:persona_flutter/src/core/tasks/data/drift_workflow_task_repository.dart';
import 'package:persona_flutter/src/features/settings/data/drift_provider_config_repository.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';
import 'package:persona_flutter/src/features/style_lab/application/style_input_classification.dart';
import 'package:persona_flutter/src/features/style_lab/application/style_analysis_pipeline.dart';
import 'package:persona_flutter/src/features/style_lab/application/style_lab_prompts.dart';
import 'package:persona_flutter/src/features/style_lab/application/voice_profile_front_matter.dart';
import 'package:persona_flutter/src/features/style_lab/data/drift_style_lab_repository.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_analysis_run.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_profile.dart';
import 'package:persona_flutter/src/features/style_lab/domain/style_sample.dart';

import 'package:persona_flutter/src/core/llm/application/llm_invocation_service.dart';
import 'package:persona_flutter/src/core/tasks/domain/workflow_task.dart';

void main() {
  test(
    'style lab repository round-trips samples runs profiles and tasks',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final providerRepository = DriftProviderConfigRepository(database);
      await providerRepository.saveProvider(
        input: const ProviderConfigInput(
          name: 'deepseek',
          baseUrl: 'https://api.example.com/v1',
          apiKey: 'sk-secret',
          defaultModel: 'deepseek-chat',
          systemPrompt: '',
          isEnabled: true,
        ),
      );
      final provider = (await providerRepository.watchProviders().first).single;
      final repository = DriftStyleLabRepository(database);

      final sample = await repository.saveSample(
        const StyleSampleInput(
          sourceType: StyleSampleSourceType.txt,
          title: '冷雨样本',
          content: '雨落在玻璃上。\n\n他没有回头。',
          sourceFilename: 'sample.txt',
        ),
      );

      final run = await repository.createRun(
        StyleAnalysisRunInput(
          sampleId: sample.id,
          providerId: provider.id,
          modelName: provider.defaultModel,
          styleName: '冷雨风格',
          characterCount: sample.characterCount,
        ),
      );

      await repository.updateRunState(
        id: run.id,
        status: StyleAnalysisStatus.succeeded,
        analysisReportMarkdown: '# 执行摘要\n冷。',
        voiceProfileMarkdown: _validProfile,
        completedAt: DateTime.utc(2026, 5, 16),
      );

      final profile = await repository.saveProfileFromRun(
        StyleProfileInput(
          runId: run.id,
          styleName: '冷雨风格',
          profileMarkdown: _validProfile,
        ),
      );

      expect(profile.styleName, '冷雨风格');
      expect(profile.profileMarkdown, startsWith('---\nname: "冷雨风格"'));
      expect(profile.profileMarkdown, contains('# Voice Profile'));

      final rerun = await repository.createRunFromExisting(run.id);
      expect(rerun.id, isNot(run.id));
      expect(rerun.sampleId, run.sampleId);
      expect(rerun.providerId, run.providerId);
      expect(rerun.status, StyleAnalysisStatus.pending);
      expect(rerun.logs, isEmpty);
      expect(rerun.analysisReportMarkdown, isNull);
      expect(rerun.voiceProfileMarkdown, isNull);
      expect(
        (await repository.findRun(run.id))!.status,
        StyleAnalysisStatus.succeeded,
      );

      final tasks = await DriftWorkflowTaskRepository(
        database,
      ).watchRecentTasks().first;
      expect(tasks, hasLength(2));
      expect(tasks.first.kind, styleAnalysisWorkflowTaskKind);
      expect(
        tasks.map((task) => task.status),
        contains(WorkflowTaskStatus.succeeded),
      );
      expect(
        tasks.map((task) => task.status),
        contains(WorkflowTaskStatus.pending),
      );

      await repository.deleteProfile(profile.id);
      expect(await repository.findProfile(profile.id), isNull);
      expect(await repository.findRun(run.id), isNull);
      expect(
        await DriftWorkflowTaskRepository(database).watchRecentTasks().first,
        hasLength(1),
      );

      await repository.deleteRun(rerun.id);
      expect(
        await DriftWorkflowTaskRepository(database).watchRecentTasks().first,
        isEmpty,
      );
    },
  );

  test('voice profile front matter validates required YAML fields', () {
    const parser = VoiceProfileFrontMatterParser();

    final parsed = parser.parse(_validProfile);
    expect(parsed.fields['name'], '冷雨风格');
    expect(parsed.bodyMarkdown, startsWith('# Voice Profile'));

    expect(
      () => parser.parse('# Voice Profile\n正文'),
      throwsA(isA<VoiceProfileValidationException>()),
    );
    expect(
      () => parser.parse('---\nname: only\n---\n# Voice Profile'),
      throwsA(isA<VoiceProfileValidationException>()),
    );
  });

  test('style lab prompts preserve old Persona sections and YAML contract', () {
    const builder = StyleLabPromptBuilder();
    const classification = StyleInputClassification(
      textType: '混合文本',
      hasTimestamps: false,
      hasSpeakerLabels: true,
      hasNoiseMarkers: false,
      usesBatchProcessing: true,
      locationIndexing: '章节或段落位置',
      noiseNotes: '未发现显著噪声。',
    );
    final chunkPrompt = builder.buildChunkAnalysisPrompt(
      chunk: '甲：他说话很短。',
      chunkIndex: 0,
      chunkCount: 2,
      classification: classification,
    );
    final mergePrompt = builder.buildMergePrompt(
      chunkAnalyses: const ['# 执行摘要\nchunk'],
      classification: classification,
    );
    final reportPrompt = builder.buildReportPrompt(
      mergedAnalysisMarkdown: '# 执行摘要\nmerged',
      classification: classification,
    );
    final prompt = builder.buildVoiceProfilePrompt(
      reportMarkdown: '# 执行摘要\n冷。',
      styleName: '冷雨风格',
    );

    expect(chunkPrompt, contains('输入判定'));
    expect(chunkPrompt, contains('has_speaker_labels'));
    expect(mergePrompt, contains('多说话人差异不抹平'));
    expect(reportPrompt, contains('是否多说话人'));
    expect(prompt, contains('YAML front matter'));
    expect(prompt, contains('voice_summary'));
    for (final section in styleAnalysisSections) {
      expect(prompt, contains(section));
    }
    expect(prompt, contains('Voice Profile 必须去样本化'));
    expect(prompt, contains('YAML front matter 和 Markdown 正文都不得保留样本人物名'));
    expect(prompt, contains('具体角色名'));
    expect(
      builder.buildVoiceProfileRepairPrompt(
        invalidProfileMarkdown: 'missing closing delimiter',
        parseError: 'YAML front matter 缺少结束分隔符。',
      ),
      allOf(
        contains('只修复格式'),
        contains('YAML front matter 结束分隔符'),
        contains('# Voice Profile'),
      ),
    );
  });

  test('style analysis pipeline runs simplified chunk workflow', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final providerRepository = DriftProviderConfigRepository(database);
    await providerRepository.saveProvider(
      input: const ProviderConfigInput(
        name: 'deepseek',
        baseUrl: 'https://api.example.com/v1',
        apiKey: 'sk-secret',
        defaultModel: 'deepseek-chat',
        systemPrompt: '',
        isEnabled: true,
      ),
    );
    final provider = (await providerRepository.watchProviders().first).single;
    final repository = DriftStyleLabRepository(database);
    final sample = await repository.saveSample(
      const StyleSampleInput(
        sourceType: StyleSampleSourceType.txt,
        title: '样本',
        content: '第一段。\n\n第二段。',
      ),
    );
    final run = await repository.createRun(
      StyleAnalysisRunInput(
        sampleId: sample.id,
        providerId: provider.id,
        modelName: 'deepseek-reasoner',
        styleName: '冷雨风格',
        characterCount: sample.characterCount,
      ),
    );
    final client = _QueuedLlmClient([
      '# 执行摘要\nchunk',
      '# 执行摘要\nreport',
      _validProfile,
    ]);

    final pipeline = StyleAnalysisPipeline(
      repository: repository,
      workflowTaskRepository: DriftWorkflowTaskRepository(database),
      completionService: MarkdownCompletionService(
        invocation: LlmInvocationService(client: client),
      ),
    );

    await pipeline.run(runId: run.id, provider: provider);

    final updated = await repository.findRun(run.id);
    expect(updated!.status, StyleAnalysisStatus.succeeded);
    expect(updated.analysisReportMarkdown, contains('report'));
    expect(updated.voiceProfileMarkdown, startsWith('---\nname: "冷雨风格"'));
    expect(updated.voiceProfileMarkdown, contains('# Voice Profile'));
    final trace = await DriftWorkflowTaskRepository(
      database,
    ).watchPromptTrace(run.workflowTaskId).first;
    expect(trace, isNotNull);
    expect(trace!.traceMarkdown, contains('calls: 3'));
    expect(trace.traceMarkdown, contains('chunk_analysis_1'));
    expect(trace.traceMarkdown, contains('build_report'));
    expect(trace.traceMarkdown, contains('build_voice_profile'));
    expect(client.modelNames, [
      'deepseek-reasoner',
      'deepseek-reasoner',
      'deepseek-reasoner',
    ]);
    expect(trace.traceMarkdown, contains('model_name: "deepseek-reasoner"'));
  });

  test(
    'style analysis pipeline fails empty samples before LLM calls',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final (provider, repository) = await _styleLabTestContext(database);
      final sample = await repository.saveSample(
        const StyleSampleInput(
          sourceType: StyleSampleSourceType.txt,
          title: '空样本',
          content: '   ',
        ),
      );
      final run = await repository.createRun(
        StyleAnalysisRunInput(
          sampleId: sample.id,
          providerId: provider.id,
          modelName: provider.defaultModel,
          styleName: '空样本',
          characterCount: 0,
        ),
      );
      final client = _QueuedLlmClient(const []);
      final pipeline = StyleAnalysisPipeline(
        repository: repository,
        workflowTaskRepository: DriftWorkflowTaskRepository(database),
        completionService: MarkdownCompletionService(
          invocation: LlmInvocationService(client: client),
        ),
      );

      await expectLater(
        pipeline.run(runId: run.id, provider: provider),
        throwsA(isA<StateError>()),
      );

      final updated = await repository.findRun(run.id);
      expect(updated!.status, StyleAnalysisStatus.failed);
      expect(updated.errorMessage, contains('没有可分析的有效内容'));
      expect(client.invocationCount, 0);
    },
  );

  test(
    'style analysis pipeline repairs voice profile missing YAML delimiter',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final (provider, repository) = await _styleLabTestContext(database);
      final sample = await repository.saveSample(
        const StyleSampleInput(
          sourceType: StyleSampleSourceType.txt,
          title: '样本',
          content: '第一段。\n\n第二段。',
        ),
      );
      final run = await repository.createRun(
        StyleAnalysisRunInput(
          sampleId: sample.id,
          providerId: provider.id,
          modelName: provider.defaultModel,
          styleName: '冷雨风格',
          characterCount: sample.characterCount,
        ),
      );
      final client = _QueuedLlmClient([
        '# 执行摘要\nchunk',
        '# 执行摘要\nreport',
        _validProfile.replaceFirst('\n---\n\n# Voice Profile', ''),
        _validProfile,
      ]);
      final pipeline = StyleAnalysisPipeline(
        repository: repository,
        workflowTaskRepository: DriftWorkflowTaskRepository(database),
        completionService: MarkdownCompletionService(
          invocation: LlmInvocationService(client: client),
        ),
      );

      await pipeline.run(runId: run.id, provider: provider);

      final updated = await repository.findRun(run.id);
      expect(updated!.status, StyleAnalysisStatus.succeeded);
      expect(updated.voiceProfileMarkdown, startsWith('---'));
      expect(updated.voiceProfileMarkdown, contains('# Voice Profile'));
      expect(client.invocationCount, 4);
      final trace = await DriftWorkflowTaskRepository(
        database,
      ).watchPromptTrace(run.workflowTaskId).first;
      expect(trace, isNotNull);
      expect(trace!.traceMarkdown, contains('calls: 4'));
      expect(trace.traceMarkdown, contains('repair_voice_profile'));
    },
  );

  test(
    'style analysis pipeline does not reject common wording in voice profile',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final (provider, repository) = await _styleLabTestContext(database);
      final sample = await repository.saveSample(
        const StyleSampleInput(
          sourceType: StyleSampleSourceType.txt,
          title: '口语样本',
          content: '知不知我们除非什么一个你知不知不是。',
        ),
      );
      final run = await repository.createRun(
        StyleAnalysisRunInput(
          sampleId: sample.id,
          providerId: provider.id,
          modelName: provider.defaultModel,
          styleName: '冷雨风格',
          characterCount: sample.characterCount,
        ),
      );
      final profileWithCommonWords = _validProfile.replaceFirst(
        '短句推进。',
        '知不知、我们、除非、什么、一个、你知、不知、不是都可以作为口语节奏证据。',
      );
      final client = _QueuedLlmClient([
        '# 执行摘要\nchunk',
        '# 执行摘要\nreport',
        profileWithCommonWords,
      ]);
      final pipeline = StyleAnalysisPipeline(
        repository: repository,
        workflowTaskRepository: DriftWorkflowTaskRepository(database),
        completionService: MarkdownCompletionService(
          invocation: LlmInvocationService(client: client),
        ),
      );

      await pipeline.run(runId: run.id, provider: provider);

      final updated = await repository.findRun(run.id);
      expect(updated!.status, StyleAnalysisStatus.succeeded);
      expect(updated.voiceProfileMarkdown, contains('知不知、我们、除非'));
      expect(client.invocationCount, 3);
      final trace = await DriftWorkflowTaskRepository(
        database,
      ).watchPromptTrace(run.workflowTaskId).first;
      expect(trace, isNotNull);
      expect(trace!.traceMarkdown, contains('calls: 3'));
      expect(
        trace.traceMarkdown,
        isNot(contains('repair_voice_profile_desample')),
      );
    },
  );

  test(
    'style analysis pipeline rejects invalid voice profile markdown',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final (provider, repository) = await _styleLabTestContext(database);
      final sample = await repository.saveSample(
        const StyleSampleInput(
          sourceType: StyleSampleSourceType.txt,
          title: '样本',
          content: '第一段。\n\n第二段。',
        ),
      );
      final run = await repository.createRun(
        StyleAnalysisRunInput(
          sampleId: sample.id,
          providerId: provider.id,
          modelName: provider.defaultModel,
          styleName: '冷雨风格',
          characterCount: sample.characterCount,
        ),
      );
      final pipeline = StyleAnalysisPipeline(
        repository: repository,
        workflowTaskRepository: DriftWorkflowTaskRepository(database),
        completionService: MarkdownCompletionService(
          invocation: LlmInvocationService(
            client: _QueuedLlmClient([
              '# 执行摘要\nchunk',
              '# 执行摘要\nreport',
              '# Voice Profile\n缺 YAML。',
              '# Voice Profile\n仍然缺 YAML。',
            ]),
          ),
        ),
      );

      await expectLater(
        pipeline.run(runId: run.id, provider: provider),
        throwsA(isA<VoiceProfileValidationException>()),
      );

      final updated = await repository.findRun(run.id);
      expect(updated!.status, StyleAnalysisStatus.failed);
      expect(updated.analysisReportMarkdown, contains('report'));
      expect(updated.voiceProfileMarkdown, isNull);
      expect(updated.errorMessage, contains('YAML front matter'));
      final trace = await DriftWorkflowTaskRepository(
        database,
      ).watchPromptTrace(run.workflowTaskId).first;
      expect(trace, isNotNull);
      expect(trace!.traceMarkdown, contains('calls: 4'));
      expect(trace.traceMarkdown, contains('repair_voice_profile'));
    },
  );
}

Future<(ProviderConfig, DriftStyleLabRepository)> _styleLabTestContext(
  AppDatabase database,
) async {
  final providerRepository = DriftProviderConfigRepository(database);
  await providerRepository.saveProvider(
    input: const ProviderConfigInput(
      name: 'deepseek',
      baseUrl: 'https://api.example.com/v1',
      apiKey: 'sk-secret',
      defaultModel: 'deepseek-chat',
      systemPrompt: '',
      isEnabled: true,
    ),
  );
  final provider = (await providerRepository.watchProviders().first).single;
  return (provider, DriftStyleLabRepository(database));
}

const _validProfile = '''---
name: "冷雨风格"
tags: ["冷感", "短句"]
voice_summary: "低温、克制、短句推进。"
tone: "冷静"
pacing: "短句推进"
diction: "冷色词汇"
syntax: "短句和停顿"
do: ["压迫场景用短句"]
avoid: ["过度解释"]
intensity: 0.7
---

# Voice Profile

## 3.1 口头禅与常用表达
- 执行规则：短句推进。
''';

class _QueuedLlmClient implements LlmClient {
  _QueuedLlmClient(this._responses);

  final List<String> _responses;
  var invocationCount = 0;
  final modelNames = <String>[];

  @override
  Stream<LlmStreamEvent> streamChat({
    required ProviderConfig provider,
    required LlmRequest request,
  }) async* {
    invocationCount += 1;
    modelNames.add(request.model);
    if (_responses.isEmpty) {
      yield const LlmStreamDone();
      return;
    }
    yield LlmStreamDelta(_responses.removeAt(0));
    yield const LlmStreamDone();
  }
}
