import '../../../core/analysis/sample_import_text_tools.dart';
import '../domain/novel_import.dart';

const maxImportedChapterContentChars = 300000;

final _chapterHeadingPattern = RegExp(
  r'^\s*(第\s*(?:\d+|[一二三四五六七八九十百千万零〇两]+)\s*[章节回卷]|Chapter\s*\d+)([^\n\r]*)$',
  caseSensitive: false,
  multiLine: true,
);

final _whitespaceLinePattern = RegExp(r'[ \t\f\v]+');

class NovelImportParser {
  const NovelImportParser();

  Future<NovelImportDraft> importFile(String path) async {
    final filename = importFilename(path);
    final lower = filename.toLowerCase();
    if (lower.endsWith('.txt')) {
      return importTxt(path);
    }
    if (lower.endsWith('.epub')) {
      return importEpub(path);
    }
    throw const NovelImportException('仅支持 TXT 和 EPUB 文件。');
  }

  Future<NovelImportDraft> importTxt(String path) async {
    final filename = importFilename(path);
    final content = await readImportedTextFile(path);
    return parseTxt(
      content,
      title: filename.replaceFirst(RegExp(r'\.txt$', caseSensitive: false), ''),
      sourceFilename: filename,
    );
  }

  NovelImportDraft parseTxt(
    String text, {
    required String title,
    required String sourceFilename,
  }) {
    final normalized = _normalizeTxt(text);
    if (normalized.trim().isEmpty) {
      throw const NovelImportException('上传的 TXT 文件为空。');
    }

    final matches = _chapterHeadingPattern.allMatches(normalized).toList();
    if (matches.isEmpty) {
      final chapter = _buildChapter(
        index: 1,
        title: '第1章',
        content: normalized,
      );
      return NovelImportDraft(
        sourceType: NovelImportSourceType.txt,
        title: title.trim().isEmpty ? '导入小说' : title.trim(),
        sourceFilename: sourceFilename,
        chapters: [chapter],
        warnings: const [NovelImportWarning.noStandardChapterHeadings],
      );
    }

    final chapters = <NovelImportChapterDraft>[];
    final warnings = <NovelImportWarning>[];
    final prefix = normalized.substring(0, matches.first.start).trim();
    for (var index = 0; index < matches.length; index += 1) {
      final match = matches[index];
      final start = match.end;
      final end = index + 1 < matches.length
          ? matches[index + 1].start
          : normalized.length;
      var content = normalized.substring(start, end).trim();
      if (prefix.isNotEmpty && index == 0) {
        content = '$prefix\n\n$content'.trim();
      }
      if (content.isEmpty) {
        warnings.add(NovelImportWarning.skippedEmptyChapter);
        continue;
      }
      chapters.add(
        _buildChapter(
          index: chapters.length + 1,
          title: _chapterHeadingTitle(match),
          content: content,
        ),
      );
    }
    if (chapters.isEmpty) {
      throw const NovelImportException('TXT 文件没有可导入的章节正文。');
    }
    return NovelImportDraft(
      sourceType: NovelImportSourceType.txt,
      title: title.trim().isEmpty ? '导入小说' : title.trim(),
      sourceFilename: sourceFilename,
      chapters: chapters,
      warnings: warnings,
    );
  }

  Future<NovelImportDraft> importEpub(String path) async {
    final filename = importFilename(path);
    final book = await readImportedEpubBook(path);
    final chapters = <NovelImportChapterDraft>[];
    final warnings = <NovelImportWarning>[];
    for (final chapter in book.chapters) {
      final text = _normalizeTxt(htmlToImportedText(chapter.html));
      if (text.isEmpty) {
        warnings.add(NovelImportWarning.skippedEmptyChapter);
        continue;
      }
      chapters.add(
        _buildChapter(
          index: chapters.length + 1,
          title: chapter.title.trim().isEmpty
              ? '章节 ${chapters.length + 1}'
              : chapter.title.trim(),
          content: text,
        ),
      );
    }
    if (chapters.isEmpty) {
      throw const NovelImportException('EPUB 中没有可导入的章节正文。');
    }
    final bookTitle = book.title?.trim();
    return NovelImportDraft(
      sourceType: NovelImportSourceType.epub,
      title: bookTitle == null || bookTitle.isEmpty
          ? filename.replaceFirst(RegExp(r'\.epub$', caseSensitive: false), '')
          : bookTitle,
      sourceFilename: filename,
      chapters: chapters,
      warnings: warnings,
    );
  }

  NovelImportChapterDraft _buildChapter({
    required int index,
    required String title,
    required String content,
  }) {
    final normalizedTitle = title.trim().replaceAll(RegExp(r'\s+'), ' ');
    final normalizedContent = content.trim();
    if (normalizedContent.length > maxImportedChapterContentChars) {
      throw const NovelImportException('单章内容过长，请拆分后再导入。');
    }
    return NovelImportChapterDraft(
      id: 'chapter-$index',
      title: normalizedTitle.isEmpty ? '第$index章' : normalizedTitle,
      contentMarkdown: normalizedContent,
    );
  }

  String _chapterHeadingTitle(RegExpMatch match) {
    final marker = match.group(1)?.replaceAll(RegExp(r'\s+'), '') ?? '';
    final tail = match.group(2)?.trim() ?? '';
    return '$marker $tail'.trim();
  }

  String _normalizeTxt(String text) {
    final lines = text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll('\x00', '')
        .split('\n')
        .map((line) => line.replaceAll(_whitespaceLinePattern, ' ').trim());
    final collapsed = <String>[];
    var blankSeen = false;
    for (final line in lines) {
      if (line.isEmpty) {
        if (!blankSeen) {
          collapsed.add('');
        }
        blankSeen = true;
        continue;
      }
      collapsed.add(line);
      blankSeen = false;
    }
    return collapsed.join('\n').trim();
  }
}
