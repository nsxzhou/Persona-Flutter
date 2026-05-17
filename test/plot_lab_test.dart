import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/features/plot_lab/application/plot_chunk_sketch_document.dart';
import 'package:persona_flutter/src/core/database/app_database.dart';
import 'package:persona_flutter/src/core/llm/application/llm_invocation_service.dart';
import 'package:persona_flutter/src/core/llm/application/markdown_completion_service.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_client.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_request.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_stream_event.dart';
import 'package:persona_flutter/src/core/tasks/data/drift_workflow_task_repository.dart';
import 'package:persona_flutter/src/core/tasks/domain/workflow_task.dart';
import 'package:persona_flutter/src/features/plot_lab/application/plot_analysis_pipeline.dart';
import 'package:persona_flutter/src/features/plot_lab/application/plot_input_classification.dart';
import 'package:persona_flutter/src/features/plot_lab/application/plot_lab_prompts.dart';
import 'package:persona_flutter/src/features/plot_lab/application/story_engine_normalizer.dart';
import 'package:persona_flutter/src/features/plot_lab/data/drift_plot_lab_repository.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_analysis_run.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_chunk_sketch.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_profile.dart';
import 'package:persona_flutter/src/features/plot_lab/domain/plot_sample.dart';
import 'package:persona_flutter/src/features/settings/data/drift_provider_config_repository.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';

void main() {
  test(
    'plot lab repository round-trips samples runs profiles and tasks',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final (provider, repository) = await _plotLabTestContext(database);

      final sample = await repository.saveSample(
        const PlotSampleInput(
          sourceType: PlotSampleSourceType.txt,
          title: '裂缝样本',
          content: '第一章 开端\n\n他被迫做出选择。',
          sourceFilename: 'sample.txt',
        ),
      );
      expect(sample.characterCount, greaterThan(0));

      final run = await repository.createRun(
        PlotAnalysisRunInput(
          sampleId: sample.id,
          providerId: provider.id,
          modelName: provider.defaultModel,
          plotName: '裂缝骨架',
          characterCount: sample.characterCount,
        ),
      );

      await repository.updateRunState(
        id: run.id,
        status: PlotAnalysisStatus.succeeded,
        analysisReportMarkdown: '# 执行摘要\n压力推进。',
        plotSkeletonMarkdown: '# 全书骨架\n## 主线推进链\n@chunk0',
        storyEngineMarkdown: _validStoryEngine,
        completedAt: DateTime.utc(2026, 5, 16),
      );

      final profile = await repository.saveProfileFromRun(
        PlotProfileInput(
          runId: run.id,
          plotName: '裂缝骨架',
          storyEngineMarkdown: _validStoryEngine,
        ),
      );

      expect(profile.plotName, '裂缝骨架');
      expect(profile.storyEngineMarkdown, contains('# Plot Writing Guide'));
      expect(profile.analysisReportMarkdown, contains('压力推进'));
      expect(profile.plotSkeletonMarkdown, contains('全书骨架'));

      final updated = await repository.updateProfile(
        id: profile.id,
        input: const PlotProfileUpdateInput(
          plotName: '裂缝骨架 v2',
          storyEngineMarkdown:
              '# Plot Writing Guide\n\n## Core Plot Formula\n- 新规则\n\n## Anti-Drift Rules\n- 不漂移',
        ),
      );
      expect(updated.plotName, '裂缝骨架 v2');
      expect(updated.storyEngineMarkdown, contains('新规则'));
      expect(updated.analysisReportMarkdown, profile.analysisReportMarkdown);

      final rerun = await repository.createRunFromExisting(run.id);
      expect(rerun.id, isNot(run.id));
      expect(rerun.status, PlotAnalysisStatus.pending);

      final tasks = await DriftWorkflowTaskRepository(
        database,
      ).watchRecentTasks().first;
      expect(tasks, hasLength(2));
      expect(tasks.first.kind, plotAnalysisWorkflowTaskKind);
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

  test('plot prompts preserve required sketch and Story Engine contracts', () {
    const builder = PlotLabPromptBuilder();
    const classification = PlotInputClassification(
      textType: '章节正文',
      hasTimestamps: false,
      hasSpeakerLabels: false,
      hasNoiseMarkers: false,
      usesBatchProcessing: true,
      locationIndexing: '章节或段落位置',
      noiseNotes: '未发现显著噪声。',
    );
    final sketchPrompt = builder.buildSketchPrompt(
      chunk: '主角被宗门压制。',
      chunkIndex: 0,
      chunkCount: 2,
      classification: classification,
    );
    final skeletonPrompt = builder.buildSkeletonPrompt(
      sketches: const [],
      classification: classification,
      chunkCount: 2,
    );
    final reportPrompt = builder.buildReportPrompt(
      plotSkeletonMarkdown: '# 全书骨架',
      classification: classification,
    );
    final storyPrompt = builder.buildStoryEnginePrompt(
      reportMarkdown: '# 执行摘要\n压力推进。',
      plotName: '宗门夺位',
    );

    expect(sketchPrompt, contains('YAML front matter'));
    expect(sketchPrompt, contains('characters_present'));
    expect(sketchPrompt, contains('# Chunk Sketch'));
    expect(sketchPrompt, contains('sample_coverage'));
    expect(sketchPrompt, contains('不得推断完整小说'));
    expect(sketchPrompt, contains('不要包裹 ```markdown'));
    expect(skeletonPrompt, contains('# 全书骨架'));
    expect(skeletonPrompt, contains('证据不足项'));
    expect(skeletonPrompt, contains('sub-skeletons'));
    expect(reportPrompt, contains('## 2.5.1 主线剧情分析'));
    expect(reportPrompt, contains('当前样本未覆盖'));
    expect(storyPrompt, contains('# Plot Writing Guide'));
    expect(storyPrompt, contains('YAML front matter'));
    expect(storyPrompt, contains('plot_summary'));
    expect(storyPrompt, contains('## Core Plot Formula'));
    expect(storyPrompt, contains('禁止保留样本人物名'));
  });

  test(
    'plot chunk sketch parser reads YAML front matter and Markdown body',
    () {
      const parser = PlotChunkSketchDocumentParser();
      final sketch = parser.parse(
        markdown: _sketchDocument(),
        chunkIndex: 0,
        chunkCount: 1,
      );

      expect(sketch.chunkIndex, 0);
      expect(sketch.chunkCount, 1);
      expect(sketch.charactersPresent, ['主角']);
      expect(sketch.timeMarker, PlotChunkTimeMarker.linear);
      expect(sketch.sampleCoverage, [PlotSampleCoverage.developmentSeen]);
      expect(sketch.bodyMarkdown, startsWith('# Chunk Sketch'));
    },
  );

  test('plot chunk sketch parser rejects malformed YAML contracts', () {
    const parser = PlotChunkSketchDocumentParser();

    expect(
      () => parser.parse(
        markdown: _sketchDocument(extraYaml: 'extra_field: nope\n'),
        chunkIndex: 0,
        chunkCount: 1,
      ),
      throwsA(
        isA<PlotChunkSketchValidationException>().having(
          (error) => error.message,
          'message',
          contains('未允许字段'),
        ),
      ),
    );
    expect(
      () => parser.parse(
        markdown: _sketchDocument(omitHooks: true),
        chunkIndex: 0,
        chunkCount: 1,
      ),
      throwsA(
        isA<PlotChunkSketchValidationException>().having(
          (error) => error.message,
          'message',
          contains('缺少必填字段：hooks'),
        ),
      ),
    );
    expect(
      () => parser.parse(
        markdown: _sketchDocument(timeMarker: 'sideways'),
        chunkIndex: 0,
        chunkCount: 1,
      ),
      throwsA(
        isA<PlotChunkSketchValidationException>().having(
          (error) => error.message,
          'message',
          contains('time_marker 的值无效'),
        ),
      ),
    );
    expect(
      () => parser.parse(
        markdown: _sketchDocument(sampleCoverage: 'unknown_seen'),
        chunkIndex: 0,
        chunkCount: 1,
      ),
      throwsA(
        isA<PlotChunkSketchValidationException>().having(
          (error) => error.message,
          'message',
          contains('sample_coverage 包含无效值'),
        ),
      ),
    );
    expect(
      () => parser.parse(
        markdown: _sketchDocument(charactersValue: '  - 主角\n  - 123\n'),
        chunkIndex: 0,
        chunkCount: 1,
      ),
      throwsA(
        isA<PlotChunkSketchValidationException>().having(
          (error) => error.message,
          'message',
          contains('列表项必须是字符串'),
        ),
      ),
    );
    expect(
      () => parser.parse(
        markdown: _sketchDocument(bodyHeading: '# Not Chunk Sketch'),
        chunkIndex: 0,
        chunkCount: 1,
      ),
      throwsA(
        isA<PlotChunkSketchValidationException>().having(
          (error) => error.message,
          'message',
          contains('# Chunk Sketch'),
        ),
      ),
    );
  });

  test('story engine normalizer keeps only allowed sections', () {
    const normalizer = StoryEngineNormalizer();
    final normalized = normalizer.normalize(
      '好的。\n\n$_validStoryEngine\n\n# 无关说明\n- 应移除',
    );

    expect(normalized.startsWith('---'), isTrue);
    expect(normalized, contains('plot_summary'));
    expect(normalized, contains('## Core Plot Formula'));
    expect(normalized, contains('## Anti-Drift Rules'));
    expect(normalized, isNot(contains('# 无关说明')));
  });

  test('story engine normalizer enforces required section order', () {
    const normalizer = StoryEngineNormalizer();
    final normalized = normalizer.normalize('''
---
name: "测试剧情"
tags:
  - 智谋
plot_summary: "压力推动行动。"
core_formula: "主角被压制后必须行动。"
progression_loop: "压力 -> 行动 -> 半兑现"
tension_rhythm: "压制后反击。"
hook_strategy: "用新压力收尾。"
anti_drift:
  - 不要空泛升级。
intensity: 0.7
---

# Plot Writing Guide

## Anti-Drift Rules
- 不漂移。

## Core Plot Formula
- 公式。

## Extra Section
- 删除。
''');

    expect(
      normalized,
      contains('# Plot Writing Guide\n\n## Core Plot Formula'),
    );
    expect(normalized, startsWith('---'));
    for (final header in storyEngineSectionHeaders) {
      expect(normalized, contains(header));
    }
    expect(normalized, contains('## Chapter Progression Loop'));
    expect(normalized, contains('当前样本中证据有限'));
    expect(normalized, isNot(contains('## Extra Section')));
  });

  test(
    'plot analysis pipeline builds skeleton report and story engine',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final (provider, repository) = await _plotLabTestContext(database);
      final sample = await repository.saveSample(
        const PlotSampleInput(
          sourceType: PlotSampleSourceType.txt,
          title: '样本',
          content: '第一段。\n\n第二段。',
        ),
      );
      final run = await repository.createRun(
        PlotAnalysisRunInput(
          sampleId: sample.id,
          providerId: provider.id,
          modelName: provider.defaultModel,
          plotName: '裂缝骨架',
          characterCount: sample.characterCount,
        ),
      );
      final client = _QueuedLlmClient([
        _sketchDocument(),
        '# 全书骨架\n## 主线推进链\n@chunk0 压力 -> 行动',
        '# 执行摘要\n压力迫使行动。',
        '前言\n\n$_validStoryEngine\n\n# 无关说明\n- 删除',
      ]);
      final pipeline = PlotAnalysisPipeline(
        repository: repository,
        workflowTaskRepository: DriftWorkflowTaskRepository(database),
        completionService: MarkdownCompletionService(
          invocation: LlmInvocationService(client: client),
        ),
      );

      await pipeline.run(runId: run.id, provider: provider);

      final updated = await repository.findRun(run.id);
      expect(updated!.status, PlotAnalysisStatus.succeeded);
      expect(updated.chunkCount, 1);
      expect(updated.plotSkeletonMarkdown, contains('全书骨架'));
      expect(updated.analysisReportMarkdown, contains('压力迫使行动'));
      expect(updated.storyEngineMarkdown, startsWith('---'));
      expect(updated.storyEngineMarkdown, contains('plot_summary'));
      expect(updated.storyEngineMarkdown, contains('# Plot Writing Guide'));
      expect(updated.storyEngineMarkdown, isNot(contains('# 无关说明')));
      final trace = await DriftWorkflowTaskRepository(
        database,
      ).watchPromptTrace(run.workflowTaskId).first;
      expect(trace, isNotNull);
      expect(trace!.traceMarkdown, contains('calls: 4'));
      expect(trace.traceMarkdown, contains('sketch_chunk_1'));
      expect(trace.traceMarkdown, contains('build_skeleton'));
      expect(trace.traceMarkdown, contains('build_report'));
      expect(trace.traceMarkdown, contains('build_story_engine'));
    },
  );

  test(
    'plot analysis pipeline strips markdown fences around sketch output',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final (provider, repository) = await _plotLabTestContext(database);
      final sample = await repository.saveSample(
        const PlotSampleInput(
          sourceType: PlotSampleSourceType.txt,
          title: '样本',
          content: '第一段。',
        ),
      );
      final run = await repository.createRun(
        PlotAnalysisRunInput(
          sampleId: sample.id,
          providerId: provider.id,
          modelName: provider.defaultModel,
          plotName: '裂缝骨架',
          characterCount: sample.characterCount,
        ),
      );
      final pipeline = PlotAnalysisPipeline(
        repository: repository,
        workflowTaskRepository: DriftWorkflowTaskRepository(database),
        completionService: MarkdownCompletionService(
          invocation: LlmInvocationService(
            client: _QueuedLlmClient([
              '```markdown\n${_sketchDocument()}\n```',
              '# 全书骨架\n## 主线推进链\n@chunk0',
              '# 执行摘要\n压力推进。',
              _validStoryEngine,
            ]),
          ),
        ),
      );

      await pipeline.run(runId: run.id, provider: provider);

      final updated = await repository.findRun(run.id);
      expect(updated!.status, PlotAnalysisStatus.succeeded);
      expect(updated.plotSkeletonMarkdown, contains('全书骨架'));
    },
  );

  test(
    'plot analysis pipeline uses hierarchical skeleton reduce for large sketch payloads',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final (provider, repository) = await _plotLabTestContext(database);
      final oversizedParagraph = '压力推进。' * 2000;
      final sample = await repository.saveSample(
        PlotSampleInput(
          sourceType: PlotSampleSourceType.txt,
          title: '大样本',
          content: '$oversizedParagraph\n\n$oversizedParagraph',
        ),
      );
      final run = await repository.createRun(
        PlotAnalysisRunInput(
          sampleId: sample.id,
          providerId: provider.id,
          modelName: provider.defaultModel,
          plotName: '大样本骨架',
          characterCount: sample.characterCount,
        ),
      );
      final verboseSketch = _sketchDocument(
        sceneValue: '  - ${'长场景描述' * 30000}\n',
      );
      final client = _QueuedLlmClient([
        verboseSketch,
        verboseSketch,
        '# 子骨架\n## 主线推进链\n@chunk0',
        '# 全书骨架\n## 主线推进链\n@chunk0 -> @chunk1',
        '# 执行摘要\n压力推进。',
        _validStoryEngine,
      ]);
      final pipeline = PlotAnalysisPipeline(
        repository: repository,
        workflowTaskRepository: DriftWorkflowTaskRepository(database),
        completionService: MarkdownCompletionService(
          invocation: LlmInvocationService(client: client),
        ),
      );

      await pipeline.run(runId: run.id, provider: provider);

      final updated = await repository.findRun(run.id);
      expect(updated!.status, PlotAnalysisStatus.succeeded);
      expect(updated.chunkCount, 2);
      expect(updated.plotSkeletonMarkdown, contains('@chunk0 -> @chunk1'));
      expect(client.invocationCount, 6);
    },
  );

  test(
    'plot analysis pipeline rejects invalid sketch YAML front matter',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final (provider, repository) = await _plotLabTestContext(database);
      final sample = await repository.saveSample(
        const PlotSampleInput(
          sourceType: PlotSampleSourceType.txt,
          title: '样本',
          content: '第一段。',
        ),
      );
      final run = await repository.createRun(
        PlotAnalysisRunInput(
          sampleId: sample.id,
          providerId: provider.id,
          modelName: provider.defaultModel,
          plotName: '裂缝骨架',
          characterCount: sample.characterCount,
        ),
      );
      final pipeline = PlotAnalysisPipeline(
        repository: repository,
        workflowTaskRepository: DriftWorkflowTaskRepository(database),
        completionService: MarkdownCompletionService(
          invocation: LlmInvocationService(
            client: _QueuedLlmClient(['not yaml front matter']),
          ),
        ),
      );

      await expectLater(
        pipeline.run(runId: run.id, provider: provider),
        throwsA(isA<FormatException>()),
      );

      final updated = await repository.findRun(run.id);
      expect(updated!.status, PlotAnalysisStatus.failed);
      expect(updated.errorMessage, contains('invalid YAML+MD'));
    },
  );
}

Future<(ProviderConfig, DriftPlotLabRepository)> _plotLabTestContext(
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
  return (provider, DriftPlotLabRepository(database));
}

String _sketchDocument({
  String extraYaml = '',
  bool omitHooks = false,
  String timeMarker = 'linear',
  String sampleCoverage = 'development_seen',
  String charactersValue = '  - 主角\n',
  String sceneValue = '  - 场景：主角被压力推入行动\n',
  String bodyHeading = '# Chunk Sketch',
}) {
  return '''---
characters_present:
$charactersValue
scene_units:
$sceneValue
main_events:
  - 主角遭遇压力
side_threads: []
payoff_points:
  - 小反击
tension_points:
  - 压力升级
${omitHooks ? '' : '''hooks:
  - 局面未解
'''}setup_payoff_links:
  - 压力铺垫 -> 小反击
pacing_shift: 压迫转入行动
time_marker: $timeMarker
sample_coverage:
  - $sampleCoverage
$extraYaml---

$bodyHeading
- 主角遭遇压力后进入行动位，当前 chunk 形成压迫到小反击的半兑现。
''';
}

const _validStoryEngine = '''---
name: "裂缝骨架"
tags:
  - 身份压力
  - 半兑现
plot_summary: "主角在身份压力下被迫行动，用半兑现维持追读。"
core_formula: "当主角遭遇身份压力，必须采取行动，否则失去关键关系。"
progression_loop: "目标 -> 阻碍 -> 行动 -> 半兑现 -> 新压力。"
tension_rhythm: "半兑现后追加代价。"
hook_strategy: "用信息差或资源诱惑制造下一步选择。"
anti_drift:
  - 不要把输出写成世界观说明。
intensity: 0.7
---

# Plot Writing Guide

## Core Plot Formula
- 当主角遭遇身份压力，必须采取行动，否则失去关键关系。

## Chapter Progression Loop
- 目标 -> 阻碍 -> 行动 -> 半兑现 -> 新压力。

## Scene Construction Rules
- 每场从欲望和压力开始，并以筹码变化结束。

## Setup and Payoff Rules
- 伏笔必须经历埋设 -> 强化 -> 回收。

## Payoff and Tension Rhythm
- 半兑现后追加代价。

## Side Plot Usage
- 支线必须回流主线。

## Hook Recipes
- 章末用信息差或资源诱惑制造下一步选择。

## Anti-Drift Rules
- 不要把输出写成世界观说明。
''';

class _QueuedLlmClient implements LlmClient {
  _QueuedLlmClient(this._responses);

  final List<String> _responses;
  int invocationCount = 0;

  @override
  Stream<LlmStreamEvent> streamChat({
    required ProviderConfig provider,
    required LlmRequest request,
  }) async* {
    invocationCount += 1;
    if (_responses.isEmpty) {
      yield const LlmStreamDone();
      return;
    }
    yield LlmStreamDelta(_responses.removeAt(0));
    yield const LlmStreamDone();
  }
}
