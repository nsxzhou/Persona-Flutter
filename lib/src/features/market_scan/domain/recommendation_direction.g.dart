// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_direction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecommendationDirection _$RecommendationDirectionFromJson(
  Map<String, dynamic> json,
) => _RecommendationDirection(
  suggestedTitle: json['suggestedTitle'] as String,
  titleCandidates: (json['titleCandidates'] as List<dynamic>)
      .map(
        (e) => RecommendationTitleCandidate.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  synopsis: json['synopsis'] as String,
  genreTags: (json['genreTags'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  targetWordCount: (json['targetWordCount'] as num).toInt(),
  targetPlatform: $enumDecode(_$MarketPlatformEnumMap, json['targetPlatform']),
  targetAudience: json['targetAudience'] as String,
  coreSellingPoint: json['coreSellingPoint'] as String,
  marketHeatSummary: json['marketHeatSummary'] as String,
  competitionSummary: json['competitionSummary'] as String,
  marketValidation: json['marketValidation'] as String,
  differentiation: json['differentiation'] as String,
  feasibility: json['feasibility'] as String,
  failureRisk: json['failureRisk'] as String,
  validationAction: json['validationAction'] as String,
  detailMarkdown: json['detailMarkdown'] as String,
);

Map<String, dynamic> _$RecommendationDirectionToJson(
  _RecommendationDirection instance,
) => <String, dynamic>{
  'suggestedTitle': instance.suggestedTitle,
  'titleCandidates': instance.titleCandidates,
  'synopsis': instance.synopsis,
  'genreTags': instance.genreTags,
  'targetWordCount': instance.targetWordCount,
  'targetPlatform': _$MarketPlatformEnumMap[instance.targetPlatform]!,
  'targetAudience': instance.targetAudience,
  'coreSellingPoint': instance.coreSellingPoint,
  'marketHeatSummary': instance.marketHeatSummary,
  'competitionSummary': instance.competitionSummary,
  'marketValidation': instance.marketValidation,
  'differentiation': instance.differentiation,
  'feasibility': instance.feasibility,
  'failureRisk': instance.failureRisk,
  'validationAction': instance.validationAction,
  'detailMarkdown': instance.detailMarkdown,
};

const _$MarketPlatformEnumMap = {
  MarketPlatform.qidian: 'qidian',
  MarketPlatform.fanqie: 'fanqie',
  MarketPlatform.jinjiang: 'jinjiang',
};

_RecommendationTitleCandidate _$RecommendationTitleCandidateFromJson(
  Map<String, dynamic> json,
) => _RecommendationTitleCandidate(
  title: json['title'] as String,
  formula: json['formula'] as String,
  rationale: json['rationale'] as String,
);

Map<String, dynamic> _$RecommendationTitleCandidateToJson(
  _RecommendationTitleCandidate instance,
) => <String, dynamic>{
  'title': instance.title,
  'formula': instance.formula,
  'rationale': instance.rationale,
};
