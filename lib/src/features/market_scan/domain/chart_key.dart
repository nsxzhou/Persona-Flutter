import 'market_book.dart';
import 'market_ranking.dart';

String buildChartKey(MarketPlatform platform, String chartName) {
  return '${platform.name}::$chartName';
}

MarketPlatform? parseChartKeyPlatform(String key) {
  final separator = key.indexOf('::');
  if (separator <= 0) {
    return null;
  }
  final platformName = key.substring(0, separator);
  for (final platform in MarketPlatform.values) {
    if (platform.name == platformName) {
      return platform;
    }
  }
  return null;
}

String parseChartKeyName(String key) {
  final separator = key.indexOf('::');
  if (separator < 0) {
    return key;
  }
  return key.substring(separator + 2);
}

List<String> availableChartKeysFromRankings({
  required List<MarketRanking> rankings,
  required List<MarketBook> books,
}) {
  final bookById = {for (final book in books) book.id: book};
  final keys = <String>{};
  for (final ranking in rankings) {
    final book = bookById[ranking.bookId];
    if (book == null) {
      continue;
    }
    keys.add(buildChartKey(book.platform, ranking.chartName));
  }
  final sorted = keys.toList()..sort();
  return sorted;
}

List<MarketRanking> filterRankingsByChartKeys({
  required List<MarketRanking> rankings,
  required Map<String, MarketBook> bookById,
  required List<String> selectedChartKeys,
}) {
  if (selectedChartKeys.isEmpty) {
    return const [];
  }
  final allowed = selectedChartKeys.toSet();
  return rankings
      .where((ranking) {
        final book = bookById[ranking.bookId];
        if (book == null) {
          return false;
        }
        return allowed.contains(
          buildChartKey(book.platform, ranking.chartName),
        );
      })
      .toList(growable: false);
}
