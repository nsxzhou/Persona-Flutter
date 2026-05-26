import '../../../core/llm/application/markdown_completion_service.dart';
import '../../settings/domain/provider_config.dart';
import '../domain/novel_workshop.dart';

class ChapterIllustrationPromptService {
  const ChapterIllustrationPromptService({
    required MarkdownCompletionService completionService,
  }) : _completionService = completionService;

  final MarkdownCompletionService _completionService;

  static const _maxChapterContextLength = 12000;

  static const _businessSystemPrompt = '''
You are Persona's dedicated literary illustration prompt director.
Your job is to translate a selected passage from a serialized Chinese novel into a faithful, image-model-ready English prompt.
You must infer visual facts only from the selected text and supplied chapter context, then omit unsupported details from the final prompt.
''';

  Future<String> generatePrompt({
    required ProjectChapter chapter,
    required int paragraphIndex,
    required String selectedText,
    required List<ProjectChapter> contextChapters,
    required ProviderConfig provider,
    String? modelName,
  }) async {
    final normalizedSelection = selectedText.trim();
    if (normalizedSelection.isEmpty) {
      throw StateError('选中文本不能为空。');
    }
    final raw = await _completionService.completeMarkdown(
      provider: provider,
      modelName: modelName,
      businessSystemPrompt: _businessSystemPrompt,
      temperature: 0.35,
      prompt: _buildPrompt(
        chapter: chapter,
        paragraphIndex: paragraphIndex,
        selectedText: normalizedSelection,
        contextChapters: contextChapters,
      ),
    );
    final finalPrompt = _parsePromptOutput(raw);
    if (finalPrompt.trim().isEmpty) {
      throw StateError('模型没有返回可用的插图提示词。');
    }
    return finalPrompt;
  }

  String _buildPrompt({
    required ProjectChapter chapter,
    required int paragraphIndex,
    required String selectedText,
    required List<ProjectChapter> contextChapters,
  }) {
    final chapterTitle = chapter.title.trim().isEmpty
        ? 'Untitled'
        : chapter.title.trim();
    final context = _chapterContext(
      targetChapter: chapter,
      contextChapters: contextChapters,
    );

    return '''
Task:
Convert the selected Chinese novel text into an English text-to-image prompt.
First analyze the scene from the selected text and the provided previous/current/next chapter context, then write the final image prompt.

Rules:
- You may infer era, environment, facial expression, body language, weather, and lighting from adjacent chapter context when the evidence supports it.
- If a detail is not supported, write "not specified" in Scene Analysis and omit that detail from Positive Prompt.
- If the selected text is abstract, dialogue-only, or mostly internal thought, use the nearest concrete visible scene from the context while preserving the selected text's emotion.
- Do not create symbolic or metaphor-only imagery unless the text itself describes it.
- Do not add a fixed art style, genre, camera brand, character appearance, era, clothing, props, or objects without textual support.
- Do not output any avoidance, artifact-prevention, or negative-prompt section.

Output exactly these three sections, with no preface and no code fence:
Scene Analysis:
- Era/Time Period: <supported era or "not specified">
- Location/Environment: <supported location and environment or "not specified">
- Characters: <visible characters and supported identity/role details or "not specified">
- Facial Expression/Body Language: <supported expression and posture or "not specified">
- Action: <main visible action or nearest visible scene>
- Lighting/Weather: <supported light, weather, time of day, atmosphere or "not specified">
- Visual Evidence: <brief source evidence from selected text or chapter context>
- Uncertain/Missing: <important visual details that are not supported>

Positive Prompt:
<one English paragraph or comma-separated phrase list describing the subject, setting, action, mood, light, composition, and important visual details>

Visual Notes:
<one short English sentence explaining the key visual focus>

Chapter title: $chapterTitle
Paragraph anchor: ${paragraphIndex + 1}

Selected text:
$selectedText

Chapter context:
$context
''';
  }

  String _chapterContext({
    required ProjectChapter targetChapter,
    required List<ProjectChapter> contextChapters,
  }) {
    final chaptersByKey = <String, ProjectChapter>{};
    for (final chapter in [targetChapter, ...contextChapters]) {
      final key = chapter.id.trim().isNotEmpty
          ? chapter.id
          : '${chapter.projectId}:${chapter.chapterPlanId}:${chapter.chapterIndex}';
      chaptersByKey[key] = chapter;
    }
    final chapters =
        chaptersByKey.values
            .where((chapter) => chapter.contentMarkdown.trim().isNotEmpty)
            .toList()
          ..sort((a, b) => a.chapterIndex.compareTo(b.chapterIndex));
    if (chapters.isEmpty) {
      return '(No chapter context available.)';
    }
    return chapters
        .map((chapter) {
          final title = chapter.title.trim().isEmpty
              ? 'Untitled'
              : chapter.title.trim();
          final relation = _chapterRelation(targetChapter, chapter);
          final content = _truncate(
            chapter.contentMarkdown,
            _maxChapterContextLength,
          );
          return '### $relation chapter [${chapter.chapterIndex}] $title\n$content';
        })
        .join('\n\n');
  }

  String _chapterRelation(
    ProjectChapter targetChapter,
    ProjectChapter chapter,
  ) {
    if (chapter.id == targetChapter.id ||
        chapter.chapterIndex == targetChapter.chapterIndex) {
      return 'Current';
    }
    if (chapter.chapterIndex < targetChapter.chapterIndex) {
      return 'Previous';
    }
    return 'Next';
  }

  String _parsePromptOutput(String output) {
    final cleaned = _stripCodeFence(output).trim();
    final positive = _section(cleaned, 'Positive Prompt');
    if (positive.isEmpty) {
      return _hasStructuredSections(cleaned) ? '' : _singleLine(cleaned).trim();
    }
    return _singleLine(positive).trim();
  }

  String _section(String value, String title) {
    final pattern = RegExp(
      '^\\s*#{0,3}\\s*${RegExp.escape(title)}\\s*:?\\s*\$',
      multiLine: true,
      caseSensitive: false,
    );
    final match = pattern.firstMatch(value);
    if (match == null) {
      return '';
    }
    final start = match.end;
    final next = RegExp(
      r'^\s*#{0,3}\s*(Scene Analysis|Positive Prompt|Negative Constraints|Visual Notes)\s*:?\s*$',
      multiLine: true,
      caseSensitive: false,
    ).firstMatch(value.substring(start));
    final end = next == null ? value.length : start + next.start;
    return value.substring(start, end).trim();
  }

  bool _hasStructuredSections(String value) {
    return RegExp(
      r'^\s*#{0,3}\s*(Scene Analysis|Positive Prompt|Negative Constraints|Visual Notes)\s*:?\s*$',
      multiLine: true,
      caseSensitive: false,
    ).hasMatch(value);
  }

  String _stripCodeFence(String value) {
    final trimmed = value.trim();
    final match = RegExp(
      r'^```(?:markdown|md|text)?\s*([\s\S]*?)\s*```$',
      caseSensitive: false,
    ).firstMatch(trimmed);
    return match?.group(1)?.trim() ?? trimmed;
  }

  String _singleLine(String value) {
    return value
        .split(RegExp(r'\s*\n+\s*'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .join(', ');
  }

  String _truncate(String value, int maxLength) {
    final normalized = value.trim();
    if (normalized.length <= maxLength) {
      return normalized;
    }
    return '${normalized.substring(0, maxLength)}...';
  }
}
