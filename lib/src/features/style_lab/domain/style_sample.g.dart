// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'style_sample.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StyleSample _$StyleSampleFromJson(Map<String, dynamic> json) => _StyleSample(
  id: json['id'] as String,
  sourceType: $enumDecode(_$StyleSampleSourceTypeEnumMap, json['sourceType']),
  title: json['title'] as String,
  content: json['content'] as String,
  characterCount: (json['characterCount'] as num).toInt(),
  projectId: json['projectId'] as String?,
  sourceFilename: json['sourceFilename'] as String?,
  epubBookTitle: json['epubBookTitle'] as String?,
  epubAuthor: json['epubAuthor'] as String?,
  epubChapterTitle: json['epubChapterTitle'] as String?,
  epubChapterIndex: (json['epubChapterIndex'] as num?)?.toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$StyleSampleToJson(_StyleSample instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sourceType': _$StyleSampleSourceTypeEnumMap[instance.sourceType]!,
      'title': instance.title,
      'content': instance.content,
      'characterCount': instance.characterCount,
      'projectId': instance.projectId,
      'sourceFilename': instance.sourceFilename,
      'epubBookTitle': instance.epubBookTitle,
      'epubAuthor': instance.epubAuthor,
      'epubChapterTitle': instance.epubChapterTitle,
      'epubChapterIndex': instance.epubChapterIndex,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$StyleSampleSourceTypeEnumMap = {
  StyleSampleSourceType.txt: 'txt',
  StyleSampleSourceType.epubChapter: 'epubChapter',
};
