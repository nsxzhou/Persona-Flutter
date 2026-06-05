// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_direction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecommendationDirection _$RecommendationDirectionFromJson(
  Map<String, dynamic> json,
) => _RecommendationDirection(
  suggestedTitle: json['suggestedTitle'] as String,
  synopsis: json['synopsis'] as String,
  genreTags: (json['genreTags'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  targetWordCount: (json['targetWordCount'] as num).toInt(),
  marketHeatSummary: json['marketHeatSummary'] as String,
  competitionSummary: json['competitionSummary'] as String,
);

Map<String, dynamic> _$RecommendationDirectionToJson(
  _RecommendationDirection instance,
) => <String, dynamic>{
  'suggestedTitle': instance.suggestedTitle,
  'synopsis': instance.synopsis,
  'genreTags': instance.genreTags,
  'targetWordCount': instance.targetWordCount,
  'marketHeatSummary': instance.marketHeatSummary,
  'competitionSummary': instance.competitionSummary,
};
