import 'package:freezed_annotation/freezed_annotation.dart';

part 'writing_project.freezed.dart';
part 'writing_project.g.dart';

enum ProjectStatus { active, archived }

@freezed
abstract class WritingProject with _$WritingProject {
  const factory WritingProject({
    required String id,
    required String title,
    @Default('') String description,
    required ProjectStatus status,
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
  });

  final String title;
  final String description;
  final ProjectStatus status;
}
