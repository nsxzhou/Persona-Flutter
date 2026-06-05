// Output of the Rule Engine — structured market metrics consumed by the LLM
// to generate Recommendation Directions.

class MarketMetrics {
  const MarketMetrics({
    required this.genreHeat,
    required this.wordCountDistribution,
    required this.competitionDensity,
    required this.opportunities,
    required this.computedAt,
  });

  final List<GenreHeatEntry> genreHeat;
  final List<FrequencyBucket> wordCountDistribution;
  final List<CompetitionDensityEntry> competitionDensity;
  final List<MarketOpportunityEntry> opportunities;
  final DateTime computedAt;
}

/// How hot a genre/category is across all platforms.
class GenreHeatEntry {
  const GenreHeatEntry({
    required this.genre,
    required this.appearanceCount,
    required this.averageRank,
    required this.platforms,
    required this.heatScore,
  });

  final String genre;

  /// Number of times this genre appears across all ranking data.
  final int appearanceCount;

  /// Mean rank position (lower = better).
  final double averageRank;

  /// Which platforms feature this genre.
  final List<String> platforms;

  /// Normalized heat score in [0, 100].
  /// Higher = hotter. Computed from appearance count + inverse average rank.
  final double heatScore;
}

/// Book count distribution across word-count ranges.
class FrequencyBucket {
  const FrequencyBucket({
    required this.rangeLabel,
    required this.minWordCount,
    required this.maxWordCount,
    required this.bookCount,
    required this.percentage,
  });

  final String rangeLabel;
  final int minWordCount;
  final int maxWordCount;
  final int bookCount;

  /// Percentage of total books in this bucket (0-100).
  final double percentage;
}

/// Competition density per genre — how crowded a genre is.
class CompetitionDensityEntry {
  const CompetitionDensityEntry({
    required this.genre,
    required this.newBookCount,
    required this.onChartCount,
    required this.densityScore,
  });

  final String genre;

  /// Books published within the last [recencyWindowDays] in this genre.
  final int newBookCount;

  /// How many of those new books are currently on any chart.
  final int onChartCount;

  /// Normalized density score in [0, 1]. Higher = more competitive.
  final double densityScore;
}

/// Cross-calculated market opportunity: high heat + low competition = opportunity.
class MarketOpportunityEntry {
  const MarketOpportunityEntry({
    required this.genre,
    required this.heatScore,
    required this.densityScore,
    required this.opportunityScore,
  });

  final String genre;
  final double heatScore;
  final double densityScore;

  /// opportunityScore = heatScore * (1 - densityScore).
  /// Higher = better opportunity.
  final double opportunityScore;
}
