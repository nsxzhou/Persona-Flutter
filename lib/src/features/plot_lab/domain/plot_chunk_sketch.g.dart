// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plot_chunk_sketch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlotChunkSketch _$PlotChunkSketchFromJson(Map<String, dynamic> json) =>
    _PlotChunkSketch(
      chunkIndex: (json['chunk_index'] as num).toInt(),
      chunkCount: (json['chunk_count'] as num).toInt(),
      charactersPresent:
          (json['characters_present'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sceneUnits:
          (json['scene_units'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      mainEvents:
          (json['main_events'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sideThreads:
          (json['side_threads'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      payoffPoints:
          (json['payoff_points'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tensionPoints:
          (json['tension_points'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      hooks:
          (json['hooks'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      setupPayoffLinks:
          (json['setup_payoff_links'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      pacingShift: json['pacing_shift'] as String? ?? '',
      timeMarker: $enumDecode(
        _$PlotChunkTimeMarkerEnumMap,
        json['time_marker'],
      ),
      sampleCoverage:
          (json['sample_coverage'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$PlotSampleCoverageEnumMap, e))
              .toList() ??
          const [],
      bodyMarkdown: json['body_markdown'] as String? ?? '',
    );

Map<String, dynamic> _$PlotChunkSketchToJson(_PlotChunkSketch instance) =>
    <String, dynamic>{
      'chunk_index': instance.chunkIndex,
      'chunk_count': instance.chunkCount,
      'characters_present': instance.charactersPresent,
      'scene_units': instance.sceneUnits,
      'main_events': instance.mainEvents,
      'side_threads': instance.sideThreads,
      'payoff_points': instance.payoffPoints,
      'tension_points': instance.tensionPoints,
      'hooks': instance.hooks,
      'setup_payoff_links': instance.setupPayoffLinks,
      'pacing_shift': instance.pacingShift,
      'time_marker': _$PlotChunkTimeMarkerEnumMap[instance.timeMarker]!,
      'sample_coverage': instance.sampleCoverage
          .map((e) => _$PlotSampleCoverageEnumMap[e]!)
          .toList(),
      'body_markdown': instance.bodyMarkdown,
    };

const _$PlotChunkTimeMarkerEnumMap = {
  PlotChunkTimeMarker.linear: 'linear',
  PlotChunkTimeMarker.flashback: 'flashback',
  PlotChunkTimeMarker.unclear: 'unclear',
};

const _$PlotSampleCoverageEnumMap = {
  PlotSampleCoverage.openingSeen: 'opening_seen',
  PlotSampleCoverage.developmentSeen: 'development_seen',
  PlotSampleCoverage.climaxSeen: 'climax_seen',
  PlotSampleCoverage.endingSeen: 'ending_seen',
  PlotSampleCoverage.partialFragment: 'partial_fragment',
  PlotSampleCoverage.coverageUnclear: 'coverage_unclear',
};
