// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_ranking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MarketRanking _$MarketRankingFromJson(Map<String, dynamic> json) =>
    _MarketRanking(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      chartName: json['chartName'] as String,
      rank: (json['rank'] as num).toInt(),
      runId: json['runId'] as String,
      favorites: (json['favorites'] as num?)?.toInt(),
      recommendVotes: (json['recommendVotes'] as num?)?.toInt(),
      monthlyTickets: (json['monthlyTickets'] as num?)?.toInt(),
      commentCount: (json['commentCount'] as num?)?.toInt(),
      scrapedAt: DateTime.parse(json['scrapedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MarketRankingToJson(_MarketRanking instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookId': instance.bookId,
      'chartName': instance.chartName,
      'rank': instance.rank,
      'runId': instance.runId,
      'favorites': instance.favorites,
      'recommendVotes': instance.recommendVotes,
      'monthlyTickets': instance.monthlyTickets,
      'commentCount': instance.commentCount,
      'scrapedAt': instance.scrapedAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
