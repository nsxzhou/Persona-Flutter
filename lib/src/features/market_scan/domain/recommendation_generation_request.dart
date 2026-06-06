import 'market_book.dart';

class RecommendationGenerationRequest {
  const RecommendationGenerationRequest({
    required this.targetPlatform,
    this.genreQuery,
  });

  final MarketPlatform targetPlatform;
  final String? genreQuery;

  String? get normalizedGenreQuery {
    final value = genreQuery?.trim();
    return value == null || value.isEmpty ? null : value;
  }
}
