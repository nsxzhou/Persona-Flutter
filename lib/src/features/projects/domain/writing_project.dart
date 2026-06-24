import 'package:freezed_annotation/freezed_annotation.dart';

part 'writing_project.freezed.dart';
part 'writing_project.g.dart';

enum ProjectStatus { active, archived }

enum ProjectOrigin { standard, importedEnrichment }

const defaultProjectLanguage = '简体中文';
const defaultProjectTargetLength = 3000;
const defaultProjectTotalTargetLength = 100000;
const defaultProjectNarrativePerspective = '第三人称有限视角';

@freezed
abstract class WritingProject with _$WritingProject {
  const factory WritingProject({
    required String id,
    required String title,
    @Default('') String description,
    required ProjectStatus status,
    String? defaultProviderId,
    String? defaultModelName,
    String? styleProfileId,
    String? plotProfileId,
    @Default(ProjectOrigin.standard) ProjectOrigin origin,
    @Default(defaultProjectLanguage) String language,
    @Default(defaultProjectTargetLength) int targetLength,
    @Default(defaultProjectTotalTargetLength) int totalTargetLength,
    @Default(defaultProjectNarrativePerspective) String narrativePerspective,
    @Default(true) bool useHighQualityGeneration,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _WritingProject;

  factory WritingProject.fromJson(Map<String, Object?> json) =>
      _$WritingProjectFromJson(json);
}

class WritingProjectInput {
  const WritingProjectInput({
    required this.title,
    required this.description,
    required this.status,
    required this.defaultProviderId,
    required this.defaultModelName,
    this.styleProfileId,
    this.plotProfileId,
    this.origin = ProjectOrigin.standard,
    this.language = defaultProjectLanguage,
    this.targetLength = defaultProjectTargetLength,
    this.totalTargetLength = defaultProjectTotalTargetLength,
    this.narrativePerspective = defaultProjectNarrativePerspective,
    this.useHighQualityGeneration = true,
  });

  final String title;
  final String description;
  final ProjectStatus status;
  final String defaultProviderId;
  final String defaultModelName;
  final String? styleProfileId;
  final String? plotProfileId;
  final ProjectOrigin origin;
  final String language;
  final int targetLength;
  final int totalTargetLength;
  final String narrativePerspective;
  final bool useHighQualityGeneration;
}
