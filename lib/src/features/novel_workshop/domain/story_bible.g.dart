// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_bible.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StoryBible _$StoryBibleFromJson(Map<String, dynamic> json) => _StoryBible(
  id: json['id'] as String,
  projectId: json['projectId'] as String,
  authorIntent: json['authorIntent'] as String? ?? '',
  currentFocus: json['currentFocus'] as String? ?? '',
  worldMarkdown: json['worldMarkdown'] as String? ?? '',
  charactersMarkdown: json['charactersMarkdown'] as String? ?? '',
  rulesMarkdown: json['rulesMarkdown'] as String? ?? '',
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$StoryBibleToJson(_StoryBible instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'authorIntent': instance.authorIntent,
      'currentFocus': instance.currentFocus,
      'worldMarkdown': instance.worldMarkdown,
      'charactersMarkdown': instance.charactersMarkdown,
      'rulesMarkdown': instance.rulesMarkdown,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
