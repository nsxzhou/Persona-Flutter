import 'package:yaml/yaml.dart';

import 'plot_lab_prompts.dart';

class PlotStoryEngineDocument {
  const PlotStoryEngineDocument({
    required this.yamlText,
    required this.bodyMarkdown,
    required this.fields,
  });

  final String yamlText;
  final String bodyMarkdown;
  final Map<String, Object?> fields;
}

class StoryEngineNormalizer {
  const StoryEngineNormalizer();

  static const requiredFields = [
    'name',
    'tags',
    'plot_summary',
    'core_formula',
    'progression_loop',
    'tension_rhythm',
    'hook_strategy',
    'anti_drift',
    'intensity',
  ];

  String normalize(String markdown) {
    final stripped = markdown.trim();
    if (stripped.isEmpty) {
      return stripped;
    }

    final document = _parseDocument(stripped);
    final body = _normalizeBody(document.bodyMarkdown);
    if (body.isEmpty) {
      return '';
    }
    return '---\n${document.yamlText}\n---\n\n$body';
  }

  PlotStoryEngineDocument parse(String markdown) {
    final document = _parseDocument(markdown.trim());
    final body = _normalizeBody(document.bodyMarkdown);
    if (body.isEmpty) {
      throw const PlotStoryEngineValidationException(
        'YAML 后的正文必须包含 # Plot Writing Guide。',
      );
    }
    return PlotStoryEngineDocument(
      yamlText: document.yamlText,
      bodyMarkdown: body,
      fields: document.fields,
    );
  }

  _RawPlotStoryEngineDocument _parseDocument(String markdown) {
    final yamlStart = markdown.indexOf('---\n');
    if (yamlStart < 0) {
      throw const PlotStoryEngineValidationException(
        'Story Engine 必须以 YAML front matter 开头。',
      );
    }
    final normalized = markdown.substring(yamlStart).trimLeft();
    if (!normalized.startsWith('---\n')) {
      throw const PlotStoryEngineValidationException(
        'Story Engine 必须以 YAML front matter 开头。',
      );
    }
    final end = normalized.indexOf('\n---', 4);
    if (end < 0) {
      throw const PlotStoryEngineValidationException(
        'YAML front matter 缺少结束分隔符。',
      );
    }

    final yamlText = normalized.substring(4, end).trim();
    final bodyStart = normalized.indexOf('\n', end + 4);
    final body = bodyStart < 0 ? '' : normalized.substring(bodyStart).trim();
    final parsed = loadYaml(yamlText);
    if (parsed is! YamlMap) {
      throw const PlotStoryEngineValidationException(
        'YAML front matter 必须是键值对象。',
      );
    }

    final fields = <String, Object?>{};
    for (final entry in parsed.entries) {
      fields[entry.key.toString()] = entry.value;
    }

    for (final field in requiredFields) {
      if (!fields.containsKey(field)) {
        throw PlotStoryEngineValidationException('YAML 缺少必填字段：$field。');
      }
    }

    _expectString(fields, 'name');
    _expectList(fields, 'tags');
    _expectString(fields, 'plot_summary');
    _expectString(fields, 'core_formula');
    _expectString(fields, 'progression_loop');
    _expectString(fields, 'tension_rhythm');
    _expectString(fields, 'hook_strategy');
    _expectList(fields, 'anti_drift');
    _expectNumber(fields, 'intensity');

    return _RawPlotStoryEngineDocument(
      yamlText: yamlText,
      bodyMarkdown: body,
      fields: fields,
    );
  }

  String _normalizeBody(String markdown) {
    var stripped = markdown.trim();
    final firstHeader = storyEngineSectionHeaders.first;
    final start = stripped.indexOf(firstHeader);
    if (start >= 0) {
      stripped = stripped.substring(start);
    }

    final matches = RegExp(
      r'^(#|##) [^\n]+',
      multiLine: true,
    ).allMatches(stripped).toList();
    if (matches.isEmpty) {
      return '';
    }

    final sectionByHeader = <String, String>{};
    for (var index = 0; index < matches.length; index += 1) {
      final match = matches[index];
      final header = match.group(0)!.trim();
      if (!storyEngineSectionHeaders.contains(header)) {
        continue;
      }
      final sectionEnd = index + 1 < matches.length
          ? matches[index + 1].start
          : stripped.length;
      sectionByHeader[header] = stripped
          .substring(match.start, sectionEnd)
          .trim();
    }

    if (!sectionByHeader.containsKey(storyEngineSectionHeaders.first)) {
      return '';
    }

    final normalized = <String>[storyEngineSectionHeaders.first];
    for (final header in storyEngineSectionHeaders.skip(1)) {
      final section = sectionByHeader[header];
      if (section == null) {
        normalized.add('$header\n- 当前样本中证据有限。');
        continue;
      }
      normalized.add(section);
    }

    return normalized.join('\n\n').trim();
  }

  void _expectString(Map<String, Object?> fields, String key) {
    if (fields[key] is! String) {
      throw PlotStoryEngineValidationException('YAML 字段 $key 必须是字符串。');
    }
  }

  void _expectList(Map<String, Object?> fields, String key) {
    if (fields[key] is! YamlList && fields[key] is! List) {
      throw PlotStoryEngineValidationException('YAML 字段 $key 必须是列表。');
    }
  }

  void _expectNumber(Map<String, Object?> fields, String key) {
    if (fields[key] is! num) {
      throw PlotStoryEngineValidationException('YAML 字段 $key 必须是数字。');
    }
  }
}

class _RawPlotStoryEngineDocument {
  const _RawPlotStoryEngineDocument({
    required this.yamlText,
    required this.bodyMarkdown,
    required this.fields,
  });

  final String yamlText;
  final String bodyMarkdown;
  final Map<String, Object?> fields;
}

class PlotStoryEngineValidationException implements Exception {
  const PlotStoryEngineValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
