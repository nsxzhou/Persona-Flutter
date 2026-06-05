import '../domain/market_book.dart';

/// Raw data extracted from a platform ranking page by a scraper script.
/// This is the intermediate DTO between scraper output and domain models.
class ScrapedBook {
  const ScrapedBook({
    required this.platform,
    required this.platformBookId,
    required this.title,
    required this.author,
    this.description = '',
    this.categories = const [],
    this.tags = const [],
    this.totalWordCount = 0,
    this.status = BookStatus.ongoing,
    this.firstPublishDate,
    required this.chartName,
    required this.rank,
    this.favorites,
    this.recommendVotes,
    this.monthlyTickets,
    this.commentCount,
    required this.scrapedAt,
  });

  final MarketPlatform platform;
  final String platformBookId;
  final String title;
  final String author;
  final String description;
  final List<String> categories;
  final List<String> tags;
  final int totalWordCount;
  final BookStatus status;
  final DateTime? firstPublishDate;

  // Ranking-specific fields (same book can appear on multiple charts).
  final String chartName;
  final int rank;
  final int? favorites;
  final int? recommendVotes;
  final int? monthlyTickets;
  final int? commentCount;
  final DateTime scrapedAt;

  factory ScrapedBook.fromJson(Map<String, Object?> json) {
    return ScrapedBook(
      platform: MarketPlatform.values.byName(json['platform'] as String),
      platformBookId: json['platformBookId'] as String,
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      description: json['description'] as String? ?? '',
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      totalWordCount: (json['totalWordCount'] as num?)?.toInt() ?? 0,
      status: _parseStatus(json['status'] as String?),
      firstPublishDate: _parseDate(json['firstPublishDate'] as String?),
      chartName: json['chartName'] as String,
      rank: (json['rank'] as num).toInt(),
      favorites: (json['favorites'] as num?)?.toInt(),
      recommendVotes: (json['recommendVotes'] as num?)?.toInt(),
      monthlyTickets: (json['monthlyTickets'] as num?)?.toInt(),
      commentCount: (json['commentCount'] as num?)?.toInt(),
      scrapedAt: DateTime.parse(json['scrapedAt'] as String),
    );
  }

  static BookStatus _parseStatus(String? value) {
    if (value == null) return BookStatus.ongoing;
    if (value.contains('完') || value.toLowerCase() == 'completed') {
      return BookStatus.completed;
    }
    return BookStatus.ongoing;
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
