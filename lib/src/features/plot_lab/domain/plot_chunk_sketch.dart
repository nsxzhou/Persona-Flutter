import 'package:freezed_annotation/freezed_annotation.dart';

part 'plot_chunk_sketch.freezed.dart';
part 'plot_chunk_sketch.g.dart';

@JsonEnum(fieldRename: FieldRename.snake)
enum PlotChunkTimeMarker { linear, flashback, unclear }

@JsonEnum(fieldRename: FieldRename.snake)
enum PlotSampleCoverage {
  openingSeen,
  developmentSeen,
  climaxSeen,
  endingSeen,
  partialFragment,
  coverageUnclear,
}

@freezed
abstract class PlotChunkSketch with _$PlotChunkSketch {
  const factory PlotChunkSketch({
    @JsonKey(name: 'chunk_index') required int chunkIndex,
    @JsonKey(name: 'chunk_count') required int chunkCount,
    @JsonKey(name: 'characters_present')
    @Default([])
    List<String> charactersPresent,
    @JsonKey(name: 'scene_units') @Default([]) List<String> sceneUnits,
    @JsonKey(name: 'main_events') @Default([]) List<String> mainEvents,
    @JsonKey(name: 'side_threads') @Default([]) List<String> sideThreads,
    @JsonKey(name: 'payoff_points') @Default([]) List<String> payoffPoints,
    @JsonKey(name: 'tension_points') @Default([]) List<String> tensionPoints,
    @Default([]) List<String> hooks,
    @JsonKey(name: 'setup_payoff_links')
    @Default([])
    List<String> setupPayoffLinks,
    @JsonKey(name: 'pacing_shift') @Default('') String pacingShift,
    @JsonKey(name: 'time_marker') required PlotChunkTimeMarker timeMarker,
    @JsonKey(name: 'sample_coverage')
    @Default([])
    List<PlotSampleCoverage> sampleCoverage,
    @JsonKey(name: 'body_markdown') @Default('') String bodyMarkdown,
  }) = _PlotChunkSketch;

  factory PlotChunkSketch.fromJson(Map<String, Object?> json) =>
      _$PlotChunkSketchFromJson(json);
}
