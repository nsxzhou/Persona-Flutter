// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MarketBook _$MarketBookFromJson(Map<String, dynamic> json) => _MarketBook(
  id: json['id'] as String,
  platform: $enumDecode(_$MarketPlatformEnumMap, json['platform']),
  platformBookId: json['platformBookId'] as String,
  title: json['title'] as String,
  author: json['author'] as String,
  description: json['description'] as String? ?? '',
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  totalWordCount: (json['totalWordCount'] as num?)?.toInt() ?? 0,
  status:
      $enumDecodeNullable(_$BookStatusEnumMap, json['status']) ??
      BookStatus.ongoing,
  firstPublishDate: json['firstPublishDate'] == null
      ? null
      : DateTime.parse(json['firstPublishDate'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$MarketBookToJson(_MarketBook instance) =>
    <String, dynamic>{
      'id': instance.id,
      'platform': _$MarketPlatformEnumMap[instance.platform]!,
      'platformBookId': instance.platformBookId,
      'title': instance.title,
      'author': instance.author,
      'description': instance.description,
      'categories': instance.categories,
      'tags': instance.tags,
      'totalWordCount': instance.totalWordCount,
      'status': _$BookStatusEnumMap[instance.status]!,
      'firstPublishDate': instance.firstPublishDate?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$MarketPlatformEnumMap = {
  MarketPlatform.qidian: 'qidian',
  MarketPlatform.fanqie: 'fanqie',
  MarketPlatform.jinjiang: 'jinjiang',
};

const _$BookStatusEnumMap = {
  BookStatus.ongoing: 'ongoing',
  BookStatus.completed: 'completed',
};
