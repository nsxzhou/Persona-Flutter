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
  test(
    'generatePrompt uses selected text and adjacent chapter context',
    () async {
      final client = _RecordingLlmClient('''
Scene Analysis:
- Cultural Context: not specified
- Era/Time Period: not specified
- Location/Environment: sea fog around an old lighthouse
- Characters: a girl
- Facial Expression/Body Language: tense, stepping through a doorway
- Action: entering a blue door
- Lighting/Weather: lighthouse glow in fog
- Visual Evidence: selected text and adjacent chapter context
- Uncertain/Missing: exact clothing

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
          id: 'chapter-2',
          index: 2,
          title: '第二章',
          content: '''
第一段写少女停在蓝门前。

第二段写少女走进蓝门。
''',
        ),
        paragraphIndex: 1,
        selectedText: '少女走进蓝门',
        contextChapters: [
          _chapter(
            id: 'chapter-1',
            index: 1,
            title: '第一章',
            content: '前一章写雾港仍保留旧码头与煤气灯。',
          ),
          _chapter(
            id: 'chapter-2',
            index: 2,
            title: '第二章',
            content: '第二段写少女走进蓝门。',
          ),
          _chapter(
            id: 'chapter-3',
            index: 3,
            title: '第三章',
            content: '后一章写远处钟声穿过海雾。',
          ),
        ],
        provider: _provider(),
        modelName: 'gpt-4.1-mini',
      );

      expect(prompt, contains('a girl entering a blue door'));
      expect(prompt, isNot(contains('Avoid:')));
      expect(prompt, isNot(contains('Scene Analysis')));
      expect(prompt, isNot(contains('Visual Evidence')));
      expect(prompt, isNot(contains('text, watermark')));
      expect(client.request!.model, 'gpt-4.1-mini');
      expect(client.request!.temperature, 0.35);
      expect(
        client.request!.messages.first.content,
        contains('literary illustration prompt director'),
      );
      expect(client.request!.messages.last.content, contains('少女走进蓝门'));
      expect(
        client.request!.messages.last.content,
        contains('Scene Analysis:'),
      );
      expect(
        client.request!.messages.last.content,
        contains('Cultural Context'),
      );
      expect(
        client.request!.messages.last.content,
        contains('Eastern, Western, hybrid'),
      );
      expect(
        client.request!.messages.last.content,
        contains('Era/Time Period'),
      );
      expect(
        client.request!.messages.last.content,
        contains('Location/Environment'),
      );
      expect(
        client.request!.messages.last.content,
        contains('Facial Expression/Body Language'),
      );
      expect(
        client.request!.messages.last.content,
        contains('Visual Evidence'),
      );
      expect(
        client.request!.messages.last.content,
        contains('Uncertain/Missing'),
      );
      expect(
        client.request!.messages.last.content,
        isNot(contains('Negative Constraints')),
      );
      expect(
        client.request!.messages.last.content,
        contains('### Previous chapter [1] 第一章'),
      );
      expect(
        client.request!.messages.last.content,
        contains('前一章写雾港仍保留旧码头与煤气灯。'),
      );
      expect(
        client.request!.messages.last.content,
        contains('### Current chapter [2] 第二章'),
      );
      expect(client.request!.messages.last.content, contains('第二段写少女走进蓝门。'));
      expect(
        client.request!.messages.last.content,
        contains('### Next chapter [3] 第三章'),
      );
      expect(client.request!.messages.last.content, contains('后一章写远处钟声穿过海雾。'));
    },
  );

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
        contextChapters: const [],
        provider: _provider(),
      ),
      throwsStateError,
    );
  });
}

ProjectChapter _chapter({
  String id = 'chapter-1',
  int index = 1,
  String title = '第一章',
  String content = '旧灯塔映着海雾。',
}) {
  final now = DateTime(2026, 5, 26, 9);
  return ProjectChapter(
    id: id,
    projectId: 'project-1',
    chapterPlanId: 'plan-$index',
    chapterIndex: index,
    title: title,
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
