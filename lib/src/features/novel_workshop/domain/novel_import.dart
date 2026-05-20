enum NovelImportSourceType { txt, epub }

enum NovelImportWarning {
  noStandardChapterHeadings,
  skippedEmptyChapter,
  titleTooLong,
}

class NovelImportDraft {
  const NovelImportDraft({
    required this.sourceType,
    required this.title,
    required this.sourceFilename,
    required this.chapters,
    this.warnings = const [],
  });

  final NovelImportSourceType sourceType;
  final String title;
  final String sourceFilename;
  final List<NovelImportChapterDraft> chapters;
  final List<NovelImportWarning> warnings;

  int get totalCharacterCount =>
      chapters.fold(0, (total, chapter) => total + chapter.characterCount);
}

class NovelImportChapterDraft {
  const NovelImportChapterDraft({
    required this.id,
    required this.title,
    required this.contentMarkdown,
  });

  final String id;
  final String title;
  final String contentMarkdown;

  int get characterCount => contentMarkdown.trim().length;

  NovelImportChapterDraft copyWith({String? title, String? contentMarkdown}) {
    return NovelImportChapterDraft(
      id: id,
      title: title ?? this.title,
      contentMarkdown: contentMarkdown ?? this.contentMarkdown,
    );
  }
}

class NovelImportException implements Exception {
  const NovelImportException(this.message);

  final String message;

  @override
  String toString() => message;
}
