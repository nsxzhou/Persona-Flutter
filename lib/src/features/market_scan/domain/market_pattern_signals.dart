/// Deterministic pattern signals computed from chart data before LLM analysis.
library;

class MarketPatternSignals {
  const MarketPatternSignals({
    required this.tagCoOccurrence,
    required this.titleKeywordFreq,
    required this.synopsisHookTokens,
    required this.chartWeightedHeat,
    required this.computedAt,
  });

  final List<TagCoOccurrenceEntry> tagCoOccurrence;
  final List<KeywordFreqEntry> titleKeywordFreq;
  final List<KeywordFreqEntry> synopsisHookTokens;
  final List<ChartWeightedHeatEntry> chartWeightedHeat;
  final DateTime computedAt;
}

class TagCoOccurrenceEntry {
  const TagCoOccurrenceEntry({
    required this.tags,
    required this.bookCount,
    required this.averageRank,
  });

  final List<String> tags;
  final int bookCount;
  final double averageRank;
}

class KeywordFreqEntry {
  const KeywordFreqEntry({
    required this.token,
    required this.count,
  });

  final String token;
  final int count;
}

class ChartWeightedHeatEntry {
  const ChartWeightedHeatEntry({
    required this.genre,
    required this.heatScore,
    required this.weightedAppearanceCount,
  });

  final String genre;
  final double heatScore;
  final double weightedAppearanceCount;
}
