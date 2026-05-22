import 'dart:convert';
import 'dart:io';

import 'package:epubx/epubx.dart';

String importFilename(String path) {
  final file = File(path);
  return file.uri.pathSegments.isEmpty ? path : file.uri.pathSegments.last;
}

Future<String> readImportedTextFile(String path) {
  return File(path).readAsString(encoding: utf8);
}

Future<ImportedEpubBook> readImportedEpubBook(String path) async {
  final book = await EpubReader.readBook(await File(path).readAsBytes());
  final chapters = <ImportedEpubChapter>[];
  _collectChapters(book.Chapters ?? const [], chapters);
  return ImportedEpubBook(
    title: book.Title,
    author: book.Author,
    chapters: chapters,
  );
}

String normalizeImportedText(String value) {
  return value
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .join('\n\n')
      .trim();
}

String htmlToImportedText(String html) {
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

void _collectChapters(
  List<EpubChapter> source,
  List<ImportedEpubChapter> target,
) {
  for (final chapter in source) {
    target.add(
      ImportedEpubChapter(
        title: chapter.Title ?? '',
        html: chapter.HtmlContent ?? '',
        text: normalizeImportedText(
          htmlToImportedText(chapter.HtmlContent ?? ''),
        ),
      ),
    );
    final children = chapter.SubChapters;
    if (children != null && children.isNotEmpty) {
      _collectChapters(children, target);
    }
  }
}

class ImportedEpubBook {
  const ImportedEpubBook({
    required this.title,
    required this.author,
    required this.chapters,
  });

  final String? title;
  final String? author;
  final List<ImportedEpubChapter> chapters;
}

class ImportedEpubChapter {
  const ImportedEpubChapter({
    required this.title,
    required this.html,
    required this.text,
  });

  final String title;
  final String html;
  final String text;
}
