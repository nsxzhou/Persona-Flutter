import '../../../core/analysis/sample_import_text_tools.dart';
import '../domain/style_sample.dart';

class StyleSampleImporter {
  const StyleSampleImporter();

  Future<List<StyleSampleInput>> importFile(String path) async {
    final filename = importFilename(path);
    final lower = filename.toLowerCase();
    if (lower.endsWith('.txt')) {
      return [await importTxt(path)];
    }
    if (lower.endsWith('.epub')) {
      return importEpub(path);
    }
    throw const StyleSampleImportException('仅支持 TXT 和 EPUB 文件。');
  }

  Future<StyleSampleInput> importTxt(String path) async {
    final filename = importFilename(path);
    final content = await readImportedTextFile(path);
    final text = normalizeText(content);
    if (text.isEmpty) {
      throw const StyleSampleImportException('TXT 文件没有可导入的正文。');
    }
    return StyleSampleInput(
      sourceType: StyleSampleSourceType.txt,
      title: filename.replaceFirst(RegExp(r'\.txt$', caseSensitive: false), ''),
      content: text,
      sourceFilename: filename,
    );
  }

  Future<List<StyleSampleInput>> importEpub(String path) async {
    final filename = importFilename(path);
    final book = await readImportedEpubBook(path);

    final inputs = <StyleSampleInput>[];
    for (var index = 0; index < book.chapters.length; index += 1) {
      final chapter = book.chapters[index];
      final text = chapter.text;
      if (text.isEmpty) {
        continue;
      }
      final chapterTitle = chapter.title.trim().isEmpty
          ? '章节 ${index + 1}'
          : chapter.title.trim();
      inputs.add(
        StyleSampleInput(
          sourceType: StyleSampleSourceType.epubChapter,
          title: '${book.title ?? filename} · $chapterTitle',
          content: text,
          sourceFilename: filename,
          epubBookTitle: book.title,
          epubAuthor: book.author,
          epubChapterTitle: chapterTitle,
          epubChapterIndex: index,
        ),
      );
    }

    if (inputs.isEmpty) {
      throw const StyleSampleImportException('EPUB 中没有可导入的章节正文。');
    }
    return inputs;
  }

  String normalizeText(String value) {
    return normalizeImportedText(value);
  }
}

class StyleSampleImportException implements Exception {
  const StyleSampleImportException(this.message);

  final String message;

  @override
  String toString() => message;
}
