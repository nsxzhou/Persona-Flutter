import 'package:freezed_annotation/freezed_annotation.dart';

part 'market_ranking.freezed.dart';
part 'market_ranking.g.dart';

@freezed
abstract class MarketRanking with _$MarketRanking {
  const factory MarketRanking({
    required String id,
    required String bookId,
    required String chartName,
    required int rank,
    required String runId,
    int? favorites,
    int? recommendVotes,
    int? monthlyTickets,
    int? commentCount,
    required DateTime scrapedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MarketRanking;

  factory MarketRanking.fromJson(Map<String, Object?> json) =>
      _$MarketRankingFromJson(json);
}

class MarketRankingInput {
  const MarketRankingInput({
    required this.bookId,
    required this.chartName,
    required this.rank,
    required this.runId,
    this.favorites,
    this.recommendVotes,
    this.monthlyTickets,
    this.commentCount,
    required this.scrapedAt,
  });

  final String bookId;
  final String chartName;
  final int rank;
  final String runId;
  final int? favorites;
  final int? recommendVotes;
  final int? monthlyTickets;
  final int? commentCount;
  final DateTime scrapedAt;
}
