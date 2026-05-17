// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plot_sample.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlotSample _$PlotSampleFromJson(Map<String, dynamic> json) => _PlotSample(
  id: json['id'] as String,
  sourceType: $enumDecode(_$PlotSampleSourceTypeEnumMap, json['sourceType']),
  title: json['title'] as String,
  content: json['content'] as String,
  characterCount: (json['characterCount'] as num).toInt(),
  projectId: json['projectId'] as String?,
  sourceFilename: json['sourceFilename'] as String?,
  epubBookTitle: json['epubBookTitle'] as String?,
  epubAuthor: json['epubAuthor'] as String?,
  epubChapterCount: (json['epubChapterCount'] as num?)?.toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PlotSampleToJson(_PlotSample instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sourceType': _$PlotSampleSourceTypeEnumMap[instance.sourceType]!,
      'title': instance.title,
      'content': instance.content,
      'characterCount': instance.characterCount,
      'projectId': instance.projectId,
      'sourceFilename': instance.sourceFilename,
      'epubBookTitle': instance.epubBookTitle,
      'epubAuthor': instance.epubAuthor,
      'epubChapterCount': instance.epubChapterCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$PlotSampleSourceTypeEnumMap = {
  PlotSampleSourceType.txt: 'txt',
  PlotSampleSourceType.epub: 'epub',
};
