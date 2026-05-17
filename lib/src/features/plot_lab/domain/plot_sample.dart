import 'package:freezed_annotation/freezed_annotation.dart';

part 'plot_sample.freezed.dart';
part 'plot_sample.g.dart';

enum PlotSampleSourceType { txt, epub }

@freezed
abstract class PlotSample with _$PlotSample {
  const factory PlotSample({
    required String id,
    required PlotSampleSourceType sourceType,
    required String title,
    required String content,
    required int characterCount,
    String? projectId,
    String? sourceFilename,
    String? epubBookTitle,
    String? epubAuthor,
    int? epubChapterCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PlotSample;

  factory PlotSample.fromJson(Map<String, Object?> json) =>
      _$PlotSampleFromJson(json);
}

class PlotSampleInput {
  const PlotSampleInput({
    required this.sourceType,
    required this.title,
    required this.content,
    this.projectId,
    this.sourceFilename,
    this.epubBookTitle,
    this.epubAuthor,
    this.epubChapterCount,
  });

  final PlotSampleSourceType sourceType;
  final String title;
  final String content;
  final String? projectId;
  final String? sourceFilename;
  final String? epubBookTitle;
  final String? epubAuthor;
  final int? epubChapterCount;
}
