import 'package:freezed_annotation/freezed_annotation.dart';

part 'story_bible.freezed.dart';
part 'story_bible.g.dart';

@freezed
abstract class StoryBible with _$StoryBible {
  const factory StoryBible({
    required String id,
    required String projectId,
    @Default('') String authorIntent,
    @Default('') String currentFocus,
    @Default('') String worldMarkdown,
    @Default('') String charactersMarkdown,
    @Default('') String rulesMarkdown,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _StoryBible;

  factory StoryBible.fromJson(Map<String, Object?> json) =>
      _$StoryBibleFromJson(json);
}

class StoryBibleInput {
  const StoryBibleInput({
    required this.projectId,
    this.authorIntent = '',
    this.currentFocus = '',
    this.worldMarkdown = '',
    this.charactersMarkdown = '',
    this.rulesMarkdown = '',
  });

  final String projectId;
  final String authorIntent;
  final String currentFocus;
  final String worldMarkdown;
  final String charactersMarkdown;
  final String rulesMarkdown;
}
