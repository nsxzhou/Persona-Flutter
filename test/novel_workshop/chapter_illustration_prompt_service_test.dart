import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/core/llm/application/llm_invocation_service.dart';
import 'package:persona_flutter/src/core/llm/application/markdown_completion_service.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_client.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_request.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_stream_event.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/chapter_illustration_prompt_service.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/novel_workshop.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';

void main() {
  test('generatePrompt uses selected text and nearby paragraphs', () async {
    final client = _RecordingLlmClient('''
Positive Prompt:
a girl entering a blue door in sea fog, old lighthouse glow, tense quiet mood

Negative Constraints:
text, watermark, unrelated objects, extra characters

Visual Notes:
Focus on the threshold and the foggy light.
''');
    final service = ChapterIllustrationPromptService(
      completionService: MarkdownCompletionService(
        invocation: LlmInvocationService(client: client),
      ),
    );

    final prompt = await service.generatePrompt(
      chapter: _chapter(
        content: '''
第一段有海雾与灯塔。

第二段写少女走进蓝门。

第三段写远处的钟声。
''',
      ),
      paragraphIndex: 1,
      selectedText: '少女走进蓝门',
      provider: _provider(),
      modelName: 'gpt-4.1-mini',
    );

    expect(prompt, contains('a girl entering a blue door'));
    expect(prompt, contains('Avoid: text, watermark'));
    expect(client.request!.model, 'gpt-4.1-mini');
    expect(client.request!.temperature, 0.35);
    expect(
      client.request!.messages.first.content,
      contains('literary illustration prompt director'),
    );
    expect(client.request!.messages.last.content, contains('少女走进蓝门'));
    expect(client.request!.messages.last.content, contains('[1] 第一段有海雾与灯塔。'));
    expect(client.request!.messages.last.content, contains('[2] 第二段写少女走进蓝门。'));
    expect(client.request!.messages.last.content, contains('[3] 第三段写远处的钟声。'));
  });

  test('generatePrompt rejects empty selected text', () async {
    final service = ChapterIllustrationPromptService(
      completionService: MarkdownCompletionService(
        invocation: LlmInvocationService(client: _RecordingLlmClient('')),
      ),
    );

    await expectLater(
      service.generatePrompt(
        chapter: _chapter(),
        paragraphIndex: 0,
        selectedText: '  ',
        provider: _provider(),
      ),
      throwsStateError,
    );
  });
}

ProjectChapter _chapter({String content = '旧灯塔映着海雾。'}) {
  final now = DateTime(2026, 5, 26, 9);
  return ProjectChapter(
    id: 'chapter-1',
    projectId: 'project-1',
    chapterPlanId: 'plan-1',
    chapterIndex: 1,
    title: '第一章',
    contentMarkdown: content,
    contentHash: '',
    continuityVerdict: ContinuityVerdict.pass,
    continuityReportMarkdown: '',
    memorySyncStatus: MemorySyncStatus.idle,
    memorySyncContentHash: '',
    memorySyncProposedRuntimeState: '',
    memorySyncProposedRuntimeThreads: '',
    memorySyncProposedStorySummary: '',
    createdAt: now,
    updatedAt: now,
  );
}

ProviderConfig _provider() {
  return ProviderConfig(
    id: 'provider-1',
    name: 'OpenAI',
    baseUrl: 'https://api.example.com/v1',
    apiKey: 'sk-test',
    defaultModel: 'gpt-4.1-mini',
    modelNames: const ['gpt-4.1-mini'],
    systemPrompt: '',
    isEnabled: true,
    testStatus: ProviderTestStatus.untested,
    createdAt: DateTime(2026, 5, 26, 9),
    updatedAt: DateTime(2026, 5, 26, 10),
  );
}

class _RecordingLlmClient implements LlmClient {
  _RecordingLlmClient(this.response);

  final String response;
  LlmRequest? request;

  @override
  Stream<LlmStreamEvent> streamChat({
    required ProviderConfig provider,
    required LlmRequest request,
  }) async* {
    this.request = request;
    yield LlmStreamDelta(response);
    yield const LlmStreamDone();
  }
}
