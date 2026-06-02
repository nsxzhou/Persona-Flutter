import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/core/llm/application/llm_invocation_service.dart';
import 'package:persona_flutter/src/core/llm/application/markdown_completion_service.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_client.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_request.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_stream_event.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/writing_context_retriever.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/novel_workshop.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/writing_context.dart';
import 'package:persona_flutter/src/features/projects/domain/writing_project.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';

void main() {
  test(
    'fallback includes nearby chapters and keyword-matched remote excerpt',
    () async {
      final retriever = WritingContextRetriever(
        completionService: MarkdownCompletionService(
          invocation: LlmInvocationService(
            client: _StaticLlmClient('not yaml'),
          ),
        ),
      );

      final result = await retriever.retrieve(
        project: _project,
        plan: _plan,
        baseSections: _sections,
        previousChapters: [
          _chapter(1, '沉船旧案', List.filled(80, '沉船账本第一次出现。').join()),
          _chapter(2, '雨夜追踪', '林岚在雨夜追踪港务处线人。'),
          _chapter(3, '码头回声', '向导提醒林岚潮汐即将封城。'),
        ],
        characters: const [],
        relationships: const [],
        provider: _provider,
        modelName: _provider.defaultModel,
      );

      expect(result.selectionWarnings.single, contains('上下文筛选器失败'));
      expect(result.selectedChapterExcerpts.map((e) => e.chapterIndex), [
        1,
        2,
        3,
      ]);
      expect(result.selectedChapterExcerpts.last.nearby, isTrue);
      expect(result.sections.retrievedReferencesMarkdown, contains('沉船账本'));
      expect(
        result.sections.retrievedReferencesMarkdown,
        contains('Mode: local fallback'),
      );
      expect(
        result.sections.retrievedReferencesMarkdown,
        isNot(contains('当前章旧稿')),
      );
    },
  );

  test('valid selector controls selected chapters and asset blocks', () async {
    final llmClient = _StaticLlmClient('''
selected_chapters:
  - chapter_index: 1
    reason: 沉船账本伏笔需要回收
selected_assets:
  - id: story_engine
    reason: 需要剧情推进规则
summary: 优先召回伏笔与推进规则
''');
    final retriever = WritingContextRetriever(
      completionService: MarkdownCompletionService(
        invocation: LlmInvocationService(client: llmClient),
      ),
    );

    final result = await retriever.retrieve(
      project: _project,
      plan: _plan,
      baseSections: _sections,
      previousChapters: [
        _chapter(1, '沉船旧案', List.filled(80, '沉船账本第一次出现。').join()),
        _chapter(2, '雨夜追踪', '林岚在雨夜追踪港务处线人。'),
      ],
      characters: const [],
      relationships: const [],
      provider: _provider,
      modelName: _provider.defaultModel,
    );

    expect(result.selectionWarnings, isEmpty);
    expect(llmClient.lastPrompt, contains('只输出 YAML'));
    expect(llmClient.lastPrompt, isNot(contains('只输出 JSON')));
    expect(llmClient.lastPrompt, isNot(contains('JSON 形状')));
    expect(result.selectedChapterExcerpts.map((e) => e.chapterIndex), [1]);
    expect(result.selectedAssetBlocks.map((e) => e.id), ['story_engine']);
    expect(result.sections.retrievedReferencesMarkdown, contains('沉船账本伏笔'));
    expect(
      result.sections.retrievedReferencesMarkdown,
      contains('Story Engine'),
    );
    expect(
      result.sections.retrievedReferencesMarkdown,
      isNot(contains('Voice Profile')),
    );
    expect(result.selectionReportMarkdown, contains('Mode: LLM selector'));
  });

  test('json selector output is rejected and falls back locally', () async {
    final retriever = WritingContextRetriever(
      completionService: MarkdownCompletionService(
        invocation: LlmInvocationService(
          client: _StaticLlmClient('''
{
  "selected_chapters": [
    {"chapter_index": 1, "reason": "沉船账本伏笔需要回收"}
  ],
  "selected_assets": [],
  "summary": "旧 JSON 契约"
}
'''),
        ),
      ),
    );

    final result = await retriever.retrieve(
      project: _project,
      plan: _plan,
      baseSections: _sections,
      previousChapters: [
        _chapter(1, '沉船旧案', List.filled(80, '沉船账本第一次出现。').join()),
      ],
      characters: const [],
      relationships: const [],
      provider: _provider,
      modelName: _provider.defaultModel,
    );

    expect(result.selectionWarnings.single, contains('must be YAML, not JSON'));
    expect(result.selectionReportMarkdown, contains('Mode: local fallback'));
  });
}

ProjectChapter _chapter(int index, String title, String content) {
  return ProjectChapter(
    id: 'chapter-$index',
    projectId: _project.id,
    chapterPlanId: 'plan-$index',
    chapterIndex: index,
    title: title,
    contentMarkdown: content,
    contentHash: 'hash-$index',
    continuityVerdict: ContinuityVerdict.pass,
    continuityReportMarkdown: '',
    memorySyncStatus: MemorySyncStatus.idle,
    memorySyncContentHash: '',
    memorySyncProposedRuntimeState: '',
    memorySyncProposedRuntimeThreads: '',
    memorySyncProposedStorySummary: '',
    createdAt: _now,
    updatedAt: _now,
  );
}

class _StaticLlmClient implements LlmClient {
  _StaticLlmClient(this.output);

  final String output;
  String? lastPrompt;

  @override
  Stream<LlmStreamEvent> streamChat({
    required ProviderConfig provider,
    required LlmRequest request,
  }) async* {
    lastPrompt = request.messages.map((message) => message.content).join('\n');
    yield LlmStreamDelta(output);
    yield const LlmStreamDone();
  }
}

final _now = DateTime(2026);

final _provider = ProviderConfig(
  id: 'provider-1',
  name: 'OpenAI',
  baseUrl: 'https://api.example.com/v1',
  apiKey: 'sk-test',
  defaultModel: 'gpt-4.1-mini',
  modelNames: ['gpt-4.1-mini'],
  systemPrompt: '',
  isEnabled: true,
  testStatus: ProviderTestStatus.untested,
  createdAt: _now,
  updatedAt: _now,
);

final _project = WritingProject(
  id: 'project-1',
  title: '雾港纪事',
  description: '潮湿港城里的长篇悬疑。',
  status: ProjectStatus.active,
  defaultProviderId: 'provider-1',
  defaultModelName: 'gpt-4.1-mini',
  language: '简体中文',
  targetLength: 3200,
  totalTargetLength: 100000,
  narrativePerspective: '第三人称有限视角',
  createdAt: _now,
  updatedAt: _now,
);

final _plan = ChapterPlan(
  id: 'plan-4',
  projectId: 'project-1',
  volumeId: 'volume-1',
  volumeIndex: 1,
  volumeTitle: '第一卷',
  chapterLocalIndex: 4,
  chapterIndex: 4,
  objectiveCard: const ChapterObjectiveCard(
    chapterTitle: '第四章',
    objective: '林岚追查沉船账本。',
    pressureSource: '港务处追兵逼近。',
  ),
  coreEvent: '沉船账本线索重新出现。',
  emotionArc: '',
  chapterHook: '',
  outlineMarkdown: '',
  createdAt: _now,
  updatedAt: _now,
);

const _sections = WritingContextSections(
  outputContract: '只输出正文。',
  projectBible: ProjectBiblePromptContext(descriptionMarkdown: '雾港长期被潮汐封锁。'),
  chapterPlan: ChapterPlanPromptContext(
    volumeIndex: 1,
    volumeTitle: '第一卷',
    chapterLocalIndex: 4,
    chapterIndex: 4,
    coreEvent: '沉船账本线索重新出现。',
  ),
  chapterObjectiveCard: ChapterObjectiveCard(
    chapterTitle: '第四章',
    objective: '林岚追查沉船账本。',
    pressureSource: '港务处追兵逼近。',
  ),
  voiceProfileMarkdown: '# Voice Profile\n\n短句。',
  storyEngineMarkdown: '# Plot Writing Guide\n\n目标 -> 阻碍 -> 半兑现。',
  projectContextMarkdown: '- Project Title: 雾港纪事',
  runtimeMemory: RuntimeMemoryState(
    runtimeThreads: '- 沉船账本待查。',
    continuityIndex: '- 港务处追兵',
  ),
  writingRulesMarkdown: '- 使用第三人称有限视角。',
);
