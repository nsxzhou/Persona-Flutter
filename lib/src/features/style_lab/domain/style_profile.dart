import 'package:freezed_annotation/freezed_annotation.dart';

part 'style_profile.freezed.dart';
part 'style_profile.g.dart';

@freezed
abstract class StyleProfile with _$StyleProfile {
  const factory StyleProfile({
    required String id,
    required String sourceRunId,
    required String providerId,
    required String modelName,
    required String styleName,
    required String profileMarkdown,
    required String analysisReportMarkdown,
    String? projectId,
    String? sourceSampleId,
    String? sourceTitle,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _StyleProfile;

  factory StyleProfile.fromJson(Map<String, Object?> json) =>
      _$StyleProfileFromJson(json);
}

class StyleProfileInput {
  const StyleProfileInput({
    required this.runId,
    required this.styleName,
    required this.profileMarkdown,
    this.projectId,
  });

  final String runId;
  final String styleName;
  final String profileMarkdown;
  final String? projectId;
}

class StyleProfileUpdateInput {
  const StyleProfileUpdateInput({
    required this.styleName,
    required this.profileMarkdown,
    this.projectId,
  });

  final String styleName;
  final String profileMarkdown;
  final String? projectId;
}
