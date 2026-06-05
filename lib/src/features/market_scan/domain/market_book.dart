import 'package:freezed_annotation/freezed_annotation.dart';

part 'market_book.freezed.dart';
part 'market_book.g.dart';

enum MarketPlatform { qidian, fanqie, jinjiang }

enum BookStatus { ongoing, completed }

@freezed
abstract class MarketBook with _$MarketBook {
  const factory MarketBook({
    required String id,
    required MarketPlatform platform,
    required String platformBookId,
    required String title,
    required String author,
    @Default('') String description,
    @Default(<String>[]) List<String> categories,
    @Default(<String>[]) List<String> tags,
    @Default(0) int totalWordCount,
    @Default(BookStatus.ongoing) BookStatus status,
    DateTime? firstPublishDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MarketBook;

  factory MarketBook.fromJson(Map<String, Object?> json) =>
      _$MarketBookFromJson(json);
}

class MarketBookInput {
  const MarketBookInput({
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
}
