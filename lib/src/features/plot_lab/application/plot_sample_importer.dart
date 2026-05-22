import '../../../core/analysis/sample_import_text_tools.dart';
import '../domain/plot_sample.dart';

class PlotSampleImporter {
  const PlotSampleImporter();

  Future<PlotSampleInput> importFile(String path) async {
    final filename = importFilename(path);
    final lower = filename.toLowerCase();
    if (lower.endsWith('.txt')) {
      return importTxt(path);
    }
    if (lower.endsWith('.epub')) {
      return importEpub(path);
    }
    throw const PlotSampleImportException('仅支持 TXT 和 EPUB 文件。');
  }

  Future<PlotSampleInput> importTxt(String path) async {
    final filename = importFilename(path);
    final content = await readImportedTextFile(path);
    final text = normalizeText(content);
    if (text.isEmpty) {
      throw const PlotSampleImportException('TXT 文件没有可导入的正文。');
    }
    return PlotSampleInput(
      sourceType: PlotSampleSourceType.txt,
      title: filename.replaceFirst(RegExp(r'\.txt$', caseSensitive: false), ''),
      content: text,
      sourceFilename: filename,
    );
  }

  Future<PlotSampleInput> importEpub(String path) async {
    final filename = importFilename(path);
    final book = await readImportedEpubBook(path);

    final chapterTexts = <String>[];
    for (var index = 0; index < book.chapters.length; index += 1) {
      final chapter = book.chapters[index];
      final text = chapter.text;
      if (text.isEmpty) {
        continue;
      }
      final chapterTitle = chapter.title.trim().isEmpty
          ? '章节 ${index + 1}'
          : chapter.title.trim();
      chapterTexts.add('# $chapterTitle\n\n$text');
    }

    if (chapterTexts.isEmpty) {
      throw const PlotSampleImportException('EPUB 中没有可导入的章节正文。');
    }

    final title = (book.title?.trim().isNotEmpty ?? false)
        ? book.title!.trim()
        : filename.replaceFirst(RegExp(r'\.epub$', caseSensitive: false), '');
    return PlotSampleInput(
      sourceType: PlotSampleSourceType.epub,
      title: title,
      content: chapterTexts.join('\n\n'),
      sourceFilename: filename,
      epubBookTitle: book.title,
      epubAuthor: book.author,
      epubChapterCount: chapterTexts.length,
    );
  }

  String normalizeText(String value) {
    return normalizeImportedText(value);
  }
}

class PlotSampleImportException implements Exception {
  const PlotSampleImportException(this.message);

  final String message;

  @override
  String toString() => message;
}
