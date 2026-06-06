import 'dart:math' as math;

import '../domain/market_book.dart';
import '../domain/market_metrics.dart';
import '../domain/market_ranking.dart';
import '../domain/market_scan_repository.dart';

/// Pure computation module: Market Scan Data → structured metrics.
/// No LLM calls, no side effects beyond reading from the repository.
class RuleEngine {
  const RuleEngine(this._repository);

  final MarketScanRepository _repository;

  /// Recency window for competition density calculation.
  static const _recencyWindow = Duration(days: 90);

  /// Word count bucket definitions.
  static const _buckets = [
    (label: '0-30万', min: 0, max: 300000),
    (label: '30-60万', min: 300000, max: 600000),
    (label: '60-100万', min: 600000, max: 1000000),
    (label: '100-200万', min: 1000000, max: 2000000),
    (label: '200万+', min: 2000000, max: 1 << 30),
  ];

  /// Compute all metrics from current market data.
  Future<MarketMetrics> compute({MarketPlatform? platform}) async {
    final books = await _repository.findBooks(platform: platform);
    final rankings = await _repository.findLatestRankings(platform: platform);

    if (books.isEmpty || rankings.isEmpty) {
      return MarketMetrics(
        genreHeat: const [],
        wordCountDistribution: const [],
        competitionDensity: const [],
        opportunities: const [],
        computedAt: DateTime.now(),
      );
    }

    // Build lookup: bookId → MarketBook.
    final bookById = {for (final b in books) b.id: b};

    final genreHeat = _computeGenreHeat(rankings, bookById);
    final wordCountDist = _computeWordCountDistribution(books);
    final competition = _computeCompetitionDensity(books, rankings, bookById);
    final opportunities = _computeOpportunities(genreHeat, competition);

    return MarketMetrics(
      genreHeat: genreHeat,
      wordCountDistribution: wordCountDist,
      competitionDensity: competition,
      opportunities: opportunities,
      computedAt: DateTime.now(),
    );
  }

  // ── Genre Heat ─────────────────────────────────────────────────

  List<GenreHeatEntry> _computeGenreHeat(
    List<MarketRanking> rankings,
    Map<String, MarketBook> bookById,
  ) {
    // Accumulate per-genre stats from rankings.
    final genreStats = <String, _GenreAccumulator>{};

    for (final ranking in rankings) {
      final book = bookById[ranking.bookId];
      if (book == null) continue;

      final allTags = [...book.categories, ...book.tags];
      for (final genre in allTags.toSet()) {
        if (genre.trim().isEmpty) continue;
        final acc = genreStats.putIfAbsent(genre, _GenreAccumulator.new);
        acc.appearanceCount++;
        acc.rankSum += ranking.rank;
        acc.platforms.add(book.platform.name);
      }
    }

    if (genreStats.isEmpty) return const [];

    // Find max for normalization.
    final maxAppearances = genreStats.values
        .map((a) => a.appearanceCount)
        .reduce(math.max);
    final maxAvgRank = genreStats.values
        .map((a) => a.appearanceCount > 0 ? a.rankSum / a.appearanceCount : 0.0)
        .reduce(math.max);

    final entries = genreStats.entries.map((e) {
      final acc = e.value;
      final avgRank = acc.appearanceCount > 0
          ? acc.rankSum / acc.appearanceCount
          : 0.0;
      // Heat = normalized(appearances) * 0.6 + normalized(1/avgRank) * 0.4
      final normAppear = maxAppearances > 0
          ? acc.appearanceCount / maxAppearances
          : 0.0;
      final normRank = maxAvgRank > 0 ? (1 - avgRank / maxAvgRank) : 0.0;
      final heatScore = (normAppear * 0.6 + normRank * 0.4) * 100;

      return GenreHeatEntry(
        genre: e.key,
        appearanceCount: acc.appearanceCount,
        averageRank: avgRank,
        platforms: acc.platforms.toList()..sort(),
        heatScore: _round2(heatScore),
      );
    }).toList();

    entries.sort((a, b) => b.heatScore.compareTo(a.heatScore));
    return entries;
  }

  // ── Word Count Distribution ────────────────────────────────────

  List<FrequencyBucket> _computeWordCountDistribution(List<MarketBook> books) {
    final booksWithWords = books.where((b) => b.totalWordCount > 0).toList();
    final total = booksWithWords.length;
    if (total == 0) return const [];

    return _buckets.map((bucket) {
      final count = booksWithWords
          .where(
            (b) =>
                b.totalWordCount >= bucket.min && b.totalWordCount < bucket.max,
          )
          .length;
      return FrequencyBucket(
        rangeLabel: bucket.label,
        minWordCount: bucket.min,
        maxWordCount: bucket.max,
        bookCount: count,
        percentage: _round2(count / total * 100),
      );
    }).toList();
  }

  // ── Competition Density ────────────────────────────────────────

  List<CompetitionDensityEntry> _computeCompetitionDensity(
    List<MarketBook> books,
    List<MarketRanking> rankings,
    Map<String, MarketBook> bookById,
  ) {
    final now = DateTime.now();
    final cutoff = now.subtract(_recencyWindow);

    // Books published within the recency window.
    final recentBooks = books
        .where(
          (b) =>
              b.firstPublishDate != null && b.firstPublishDate!.isAfter(cutoff),
        )
        .toList();

    // Set of bookIds currently on any chart.
    final onChartBookIds = rankings.map((r) => r.bookId).toSet();

    // Accumulate per-genre: new book count and on-chart count.
    final genreNewCount = <String, int>{};
    final genreOnChartCount = <String, int>{};

    for (final book in recentBooks) {
      final allTags = [...book.categories, ...book.tags];
      for (final genre in allTags.toSet()) {
        if (genre.trim().isEmpty) continue;
        genreNewCount[genre] = (genreNewCount[genre] ?? 0) + 1;
        if (onChartBookIds.contains(book.id)) {
          genreOnChartCount[genre] = (genreOnChartCount[genre] ?? 0) + 1;
        }
      }
    }

    if (genreNewCount.isEmpty) return const [];

    // Normalize density: ratio of on-chart books to new books, capped at 1.
    final entries = genreNewCount.entries.map((e) {
      final genre = e.key;
      final newCount = e.value;
      final onChart = genreOnChartCount[genre] ?? 0;
      // Density = onChart / newCount, but also factor in absolute volume.
      // A genre with 100 new books and 10 on chart is denser than 2 new / 1 on chart.
      final ratio = newCount > 0 ? onChart / newCount : 0.0;
      final volumeFactor =
          (math.log(newCount + 1) /
          math.log(genreNewCount.values.reduce(math.max) + 1));
      final densityScore = (ratio * 0.5 + volumeFactor * 0.5).clamp(0.0, 1.0);

      return CompetitionDensityEntry(
        genre: genre,
        newBookCount: newCount,
        onChartCount: onChart,
        densityScore: _round2(densityScore),
      );
    }).toList();

    entries.sort((a, b) => b.densityScore.compareTo(a.densityScore));
    return entries;
  }

  // ── Market Opportunity ─────────────────────────────────────────

  List<MarketOpportunityEntry> _computeOpportunities(
    List<GenreHeatEntry> genreHeat,
    List<CompetitionDensityEntry> competition,
  ) {
    final heatByGenre = {for (final h in genreHeat) h.genre: h.heatScore};
    final densityByGenre = {
      for (final c in competition) c.genre: c.densityScore,
    };

    // Union of all genres from both lists.
    final allGenres = {...heatByGenre.keys, ...densityByGenre.keys};

    final entries = allGenres.map((genre) {
      final heat = heatByGenre[genre] ?? 0;
      final density = densityByGenre[genre] ?? 0;
      final opportunity = heat * (1 - density);

      return MarketOpportunityEntry(
        genre: genre,
        heatScore: _round2(heat),
        densityScore: _round2(density),
        opportunityScore: _round2(opportunity),
      );
    }).toList();

    entries.sort((a, b) => b.opportunityScore.compareTo(a.opportunityScore));
    return entries;
  }

  double _round2(double value) {
    return (value * 100).roundToDouble() / 100;
  }
}

class _GenreAccumulator {
  int appearanceCount = 0;
  int rankSum = 0;
  final Set<String> platforms = {};
}
