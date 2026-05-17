import 'package:yaml/yaml.dart';

import '../domain/plot_chunk_sketch.dart';

class PlotChunkSketchDocumentParser {
  const PlotChunkSketchDocumentParser();

  static const requiredFields = [
    'characters_present',
    'scene_units',
    'main_events',
    'side_threads',
    'payoff_points',
    'tension_points',
    'hooks',
    'setup_payoff_links',
    'pacing_shift',
    'time_marker',
    'sample_coverage',
  ];

  static const _listFields = [
    'characters_present',
    'scene_units',
    'main_events',
    'side_threads',
    'payoff_points',
    'tension_points',
    'hooks',
    'setup_payoff_links',
    'sample_coverage',
  ];

  static const _stringFields = ['pacing_shift', 'time_marker'];

  static const _allowedTimeMarkers = {'linear', 'flashback', 'unclear'};

  static const _allowedSampleCoverage = {
    'opening_seen',
    'development_seen',
    'climax_seen',
    'ending_seen',
    'partial_fragment',
    'coverage_unclear',
  };

  PlotChunkSketch parse({
    required String markdown,
    required int chunkIndex,
    required int chunkCount,
  }) {
    try {
      final normalized = markdown.trimLeft();
      if (!normalized.startsWith('---\n')) {
        throw const PlotChunkSketchValidationException(
          'Sketch 必须以 YAML front matter 开头。',
        );
      }

      final end = normalized.indexOf('\n---', 4);
      if (end < 0) {
        throw const PlotChunkSketchValidationException(
          'YAML front matter 缺少结束分隔符。',
        );
      }

      final yamlText = normalized.substring(4, end).trim();
      final bodyStart = normalized.indexOf('\n', end + 4);
      final body = bodyStart < 0 ? '' : normalized.substring(bodyStart).trim();
      final parsed = loadYaml(yamlText);
      if (parsed is! YamlMap) {
        throw const PlotChunkSketchValidationException(
          'YAML front matter 必须是键值对象。',
        );
      }

      final fields = <String, Object?>{};
      for (final entry in parsed.entries) {
        final key = entry.key.toString();
        if (!requiredFields.contains(key)) {
          throw PlotChunkSketchValidationException('YAML 包含未允许字段：$key。');
        }
        fields[key] = entry.value;
      }

      for (final field in requiredFields) {
        if (!fields.containsKey(field)) {
          throw PlotChunkSketchValidationException('YAML 缺少必填字段：$field。');
        }
      }

      for (final field in _listFields) {
        _expectStringList(fields, field);
      }
      for (final field in _stringFields) {
        _expectString(fields, field);
      }
      _expectEnumValue(fields, 'time_marker', _allowedTimeMarkers);
      _expectEnumList(fields, 'sample_coverage', _allowedSampleCoverage);
      if (!body.startsWith('# Chunk Sketch')) {
        throw const PlotChunkSketchValidationException(
          'YAML 后的正文必须以 “# Chunk Sketch” 开头。',
        );
      }

      return PlotChunkSketch.fromJson({
        'chunk_index': chunkIndex,
        'chunk_count': chunkCount,
        for (final entry in fields.entries)
          entry.key: _normalizeYaml(entry.value),
        'body_markdown': body,
      });
    } on PlotChunkSketchValidationException {
      rethrow;
    } on Object catch (error) {
      throw PlotChunkSketchValidationException('Sketch YAML 解析失败：$error');
    }
  }

  void _expectString(Map<String, Object?> fields, String key) {
    if (fields[key] is! String) {
      throw PlotChunkSketchValidationException('YAML 字段 $key 必须是字符串。');
    }
  }

  void _expectStringList(Map<String, Object?> fields, String key) {
    final value = fields[key];
    if (value is! YamlList && value is! List) {
      throw PlotChunkSketchValidationException('YAML 字段 $key 必须是列表。');
    }
    final items = value as Iterable<Object?>;
    for (final item in items) {
      if (item is! String) {
        throw PlotChunkSketchValidationException('YAML 字段 $key 的列表项必须是字符串。');
      }
    }
  }

  void _expectEnumValue(
    Map<String, Object?> fields,
    String key,
    Set<String> allowed,
  ) {
    final value = fields[key] as String;
    if (!allowed.contains(value)) {
      throw PlotChunkSketchValidationException('YAML 字段 $key 的值无效：$value。');
    }
  }

  void _expectEnumList(
    Map<String, Object?> fields,
    String key,
    Set<String> allowed,
  ) {
    final value = fields[key];
    final items = value as Iterable<Object?>;
    for (final item in items) {
      final text = item as String;
      if (!allowed.contains(text)) {
        throw PlotChunkSketchValidationException('YAML 字段 $key 包含无效值：$text。');
      }
    }
  }

  Object? _normalizeYaml(Object? value) {
    if (value is YamlList) {
      return value.map(_normalizeYaml).toList(growable: false);
    }
    if (value is YamlMap) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _normalizeYaml(entry.value),
      };
    }
    return value;
  }
}

class PlotChunkSketchValidationException implements Exception {
  const PlotChunkSketchValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
