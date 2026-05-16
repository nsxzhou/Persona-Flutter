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

      _expectList(fields, 'characters_present');
      _expectList(fields, 'scene_units');
      _expectList(fields, 'main_events');
      _expectList(fields, 'side_threads');
      _expectList(fields, 'payoff_points');
      _expectList(fields, 'tension_points');
      _expectList(fields, 'hooks');
      _expectList(fields, 'setup_payoff_links');
      _expectString(fields, 'pacing_shift');
      _expectString(fields, 'time_marker');
      _expectList(fields, 'sample_coverage');
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

  void _expectList(Map<String, Object?> fields, String key) {
    if (fields[key] is! YamlList && fields[key] is! List) {
      throw PlotChunkSketchValidationException('YAML 字段 $key 必须是列表。');
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
