import 'package:freezed_annotation/freezed_annotation.dart';

part 'plot_profile.freezed.dart';
part 'plot_profile.g.dart';

@freezed
abstract class PlotProfile with _$PlotProfile {
  const factory PlotProfile({
    required String id,
    required String sourceRunId,
    required String providerId,
    required String modelName,
    required String plotName,
    required String storyEngineMarkdown,
    required String analysisReportMarkdown,
    required String plotSkeletonMarkdown,
    String? sourceSampleId,
    String? sourceTitle,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PlotProfile;

  factory PlotProfile.fromJson(Map<String, Object?> json) =>
      _$PlotProfileFromJson(json);
}

class PlotProfileInput {
  const PlotProfileInput({
    required this.runId,
    required this.plotName,
    required this.storyEngineMarkdown,
  });

  final String runId;
  final String plotName;
  final String storyEngineMarkdown;
}

class PlotProfileUpdateInput {
  const PlotProfileUpdateInput({
    required this.plotName,
    required this.storyEngineMarkdown,
  });

  final String plotName;
  final String storyEngineMarkdown;
}
