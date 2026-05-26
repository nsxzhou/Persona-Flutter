import '../../../core/llm/application/markdown_completion_service.dart';
import '../../settings/domain/provider_config.dart';
import '../domain/novel_workshop.dart';
import 'novel_export_service.dart';

class ChapterIllustrationPromptService {
  const ChapterIllustrationPromptService({
    required MarkdownCompletionService completionService,
  }) : _completionService = completionService;

  final MarkdownCompletionService _completionService;

  static const _businessSystemPrompt = '''
You are Persona's dedicated literary illustration prompt director.
Your job is to translate a selected passage from a serialized Chinese novel into a faithful, image-model-ready English prompt.
You must preserve narrative facts, avoid inventing unsupported details, and separate desired visual content from constraints that prevent unwanted artifacts.
''';

  Future<String> generatePrompt({
    required ProjectChapter chapter,
    required int paragraphIndex,
    required String selectedText,
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
  }) {
    final paragraphs = readerParagraphsFromMarkdown(chapter.contentMarkdown);
    final context = _nearbyParagraphs(
      paragraphs: paragraphs,
      paragraphIndex: paragraphIndex,
    );
    final chapterTitle = chapter.title.trim().isEmpty
        ? 'Untitled'
        : chapter.title.trim();

    return '''
Task:
Convert the selected Chinese novel text into an English text-to-image prompt.
Stay faithful to the text. Do not invent a fixed art style, genre, character appearance, era, or objects that are not supported by the provided context.

Output exactly these three sections, with no preface and no code fence:
Positive Prompt:
<one English paragraph or comma-separated phrase list describing the subject, setting, action, mood, light, composition, and important visual details>

Negative Constraints:
<short English comma-separated constraints for things to avoid, including text, watermark, unrelated objects, extra characters, and visual contradictions>

Visual Notes:
<one short English sentence explaining the key visual focus>

Chapter title: $chapterTitle
Paragraph anchor: ${paragraphIndex + 1}

Selected text:
$selectedText

Nearby chapter context:
$context
''';
  }

  String _nearbyParagraphs({
    required List<String> paragraphs,
    required int paragraphIndex,
  }) {
    if (paragraphs.isEmpty) {
      return '(No nearby context available.)';
    }
    final clamped = paragraphIndex.clamp(0, paragraphs.length - 1).toInt();
    final start = (clamped - 2).clamp(0, paragraphs.length - 1).toInt();
    final end = (clamped + 2).clamp(0, paragraphs.length - 1).toInt();
    final buffer = StringBuffer();
    for (var index = start; index <= end; index += 1) {
      buffer.writeln('[${index + 1}] ${_truncate(paragraphs[index], 360)}');
    }
    return buffer.toString().trim();
  }

  String _parsePromptOutput(String output) {
    final cleaned = _stripCodeFence(output).trim();
    final positive = _section(cleaned, 'Positive Prompt');
    if (positive.isEmpty) {
      return cleaned;
    }
    final negative = _section(cleaned, 'Negative Constraints');
    final prompt = StringBuffer(_singleLine(positive));
    final normalizedNegative = _singleLine(negative);
    if (normalizedNegative.isNotEmpty) {
      prompt
        ..write('\n\nAvoid: ')
        ..write(normalizedNegative);
    }
    return prompt.toString().trim();
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
      r'^\s*#{0,3}\s*(Positive Prompt|Negative Constraints|Visual Notes)\s*:?\s*$',
      multiLine: true,
      caseSensitive: false,
    ).firstMatch(value.substring(start));
    final end = next == null ? value.length : start + next.start;
    return value.substring(start, end).trim();
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
