import 'package:freezed_annotation/freezed_annotation.dart';

part 'style_sample.freezed.dart';
part 'style_sample.g.dart';

enum StyleSampleSourceType { txt, epubChapter }

@freezed
abstract class StyleSample with _$StyleSample {
  const factory StyleSample({
    required String id,
    required StyleSampleSourceType sourceType,
    required String title,
    required String content,
    required int characterCount,
    String? projectId,
    String? sourceFilename,
    String? epubBookTitle,
    String? epubAuthor,
    String? epubChapterTitle,
    int? epubChapterIndex,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _StyleSample;

  factory StyleSample.fromJson(Map<String, Object?> json) =>
      _$StyleSampleFromJson(json);
}

class StyleSampleInput {
  const StyleSampleInput({
    required this.sourceType,
    required this.title,
    required this.content,
    this.projectId,
    this.sourceFilename,
    this.epubBookTitle,
    this.epubAuthor,
    this.epubChapterTitle,
    this.epubChapterIndex,
  });

  final StyleSampleSourceType sourceType;
  final String title;
  final String content;
  final String? projectId;
  final String? sourceFilename;
  final String? epubBookTitle;
  final String? epubAuthor;
  final String? epubChapterTitle;
  final int? epubChapterIndex;
}
