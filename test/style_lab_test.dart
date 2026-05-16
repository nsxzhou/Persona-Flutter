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

      final tasks = await DriftWorkflowTaskRepository(
        database,
      ).watchRecentTasks().first;
      expect(tasks.single.kind, DriftStyleLabRepository.workflowTaskKind);
      expect(tasks.single.status, WorkflowTaskStatus.succeeded);

      await repository.deleteProfile(profile.id);
      expect(await repository.findProfile(profile.id), isNull);
      expect((await repository.findRun(run.id))!.profileId, isNull);

      await repository.deleteRun(run.id);
      expect(await repository.findRun(run.id), isNull);
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
    final prompt = builder.buildVoiceProfilePrompt(
      reportMarkdown: '# 执行摘要\n冷。',
      styleName: '冷雨风格',
    );

    expect(prompt, contains('YAML front matter'));
    expect(prompt, contains('voice_summary'));
    for (final section in styleAnalysisSections) {
      expect(prompt, contains(section));
    }
    expect(prompt, contains('Voice Profile 必须去样本化'));
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
        modelName: provider.defaultModel,
        styleName: '冷雨风格',
        characterCount: sample.characterCount,
      ),
    );

    final pipeline = StyleAnalysisPipeline(
      repository: repository,
      completionService: MarkdownCompletionService(
        invocation: LlmInvocationService(
          client: _QueuedLlmClient([
            '# 执行摘要\nchunk',
            '# 执行摘要\nreport',
            _validProfile,
          ]),
        ),
      ),
    );

    await pipeline.run(runId: run.id, provider: provider);

    final updated = await repository.findRun(run.id);
    expect(updated!.status, StyleAnalysisStatus.succeeded);
    expect(updated.analysisReportMarkdown, contains('report'));
    expect(updated.voiceProfileMarkdown, startsWith('---\nname: "冷雨风格"'));
    expect(updated.voiceProfileMarkdown, contains('# Voice Profile'));
  });
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

  @override
  Stream<LlmStreamEvent> streamChat({
    required ProviderConfig provider,
    required LlmRequest request,
  }) async* {
    if (_responses.isEmpty) {
      yield const LlmStreamDone();
      return;
    }
    yield LlmStreamDelta(_responses.removeAt(0));
    yield const LlmStreamDone();
  }
}
