import 'dart:convert';
import 'dart:io';

import 'package:epubx/epubx.dart';

import '../domain/plot_sample.dart';

class PlotSampleImporter {
  const PlotSampleImporter();

  Future<PlotSampleInput> importFile(String path) async {
    final file = File(path);
    final filename = file.uri.pathSegments.isEmpty
        ? path
        : file.uri.pathSegments.last;
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
    final file = File(path);
    final filename = file.uri.pathSegments.isEmpty
        ? path
        : file.uri.pathSegments.last;
    final content = await file.readAsString(encoding: utf8);
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
    final file = File(path);
    final filename = file.uri.pathSegments.isEmpty
        ? path
        : file.uri.pathSegments.last;
    final book = await EpubReader.readBook(await file.readAsBytes());
    final chapters = <_ChapterText>[];
    _collectChapters(book.Chapters ?? const [], chapters);

    final chapterTexts = <String>[];
    for (var index = 0; index < chapters.length; index += 1) {
      final chapter = chapters[index];
      final text = normalizeText(_htmlToText(chapter.html));
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

    final title = (book.Title?.trim().isNotEmpty ?? false)
        ? book.Title!.trim()
        : filename.replaceFirst(RegExp(r'\.epub$', caseSensitive: false), '');
    return PlotSampleInput(
      sourceType: PlotSampleSourceType.epub,
      title: title,
      content: chapterTexts.join('\n\n'),
      sourceFilename: filename,
      epubBookTitle: book.Title,
      epubAuthor: book.Author,
      epubChapterCount: chapterTexts.length,
    );
  }

  String normalizeText(String value) {
    return value
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .join('\n\n')
        .trim();
  }

  void _collectChapters(List<EpubChapter> source, List<_ChapterText> target) {
    for (final chapter in source) {
      target.add(
        _ChapterText(
          title: chapter.Title ?? '',
          html: chapter.HtmlContent ?? '',
        ),
      );
      final children = chapter.SubChapters;
      if (children != null && children.isNotEmpty) {
        _collectChapters(children, target);
      }
    }
  }

  String _htmlToText(String html) {
    if (html.trim().isEmpty) {
      return '';
    }
    return html
        .replaceAll(RegExp(r'<(script|style)[^>]*>.*?</\1>', dotAll: true), ' ')
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }
}

class _ChapterText {
  const _ChapterText({required this.title, required this.html});

  final String title;
  final String html;
}

class PlotSampleImportException implements Exception {
  const PlotSampleImportException(this.message);

  final String message;

  @override
  String toString() => message;
}
