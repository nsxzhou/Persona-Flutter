import 'package:yaml/yaml.dart';

class VoiceProfileFrontMatter {
  const VoiceProfileFrontMatter({
    required this.yamlText,
    required this.bodyMarkdown,
    required this.fields,
  });

  final String yamlText;
  final String bodyMarkdown;
  final Map<String, Object?> fields;
}

class VoiceProfileFrontMatterParser {
  const VoiceProfileFrontMatterParser();

  static const requiredFields = [
    'name',
    'tags',
    'voice_summary',
    'tone',
    'pacing',
    'diction',
    'syntax',
    'do',
    'avoid',
    'intensity',
  ];

  VoiceProfileFrontMatter parse(String markdown) {
    final normalized = markdown.trimLeft();
    if (!normalized.startsWith('---\n')) {
      throw const VoiceProfileValidationException(
        'Voice Profile 必须以 YAML front matter 开头。',
      );
    }

    final end = normalized.indexOf('\n---', 4);
    if (end < 0) {
      throw const VoiceProfileValidationException('YAML front matter 缺少结束分隔符。');
    }

    final yamlText = normalized.substring(4, end).trim();
    final bodyStart = normalized.indexOf('\n', end + 4);
    final body = bodyStart < 0 ? '' : normalized.substring(bodyStart).trim();
    final parsed = loadYaml(yamlText);
    if (parsed is! YamlMap) {
      throw const VoiceProfileValidationException('YAML front matter 必须是键值对象。');
    }

    final fields = <String, Object?>{};
    for (final entry in parsed.entries) {
      fields[entry.key.toString()] = entry.value;
    }

    for (final field in requiredFields) {
      if (!fields.containsKey(field)) {
        throw VoiceProfileValidationException('YAML 缺少必填字段：$field。');
      }
    }

    _expectString(fields, 'name');
    _expectList(fields, 'tags');
    _expectString(fields, 'voice_summary');
    _expectString(fields, 'tone');
    _expectString(fields, 'pacing');
    _expectString(fields, 'diction');
    _expectString(fields, 'syntax');
    _expectList(fields, 'do');
    _expectList(fields, 'avoid');
    _expectNumber(fields, 'intensity');

    if (!body.startsWith('# Voice Profile')) {
      throw const VoiceProfileValidationException(
        'YAML 后的正文必须以 “# Voice Profile” 开头。',
      );
    }

    return VoiceProfileFrontMatter(
      yamlText: yamlText,
      bodyMarkdown: body,
      fields: fields,
    );
  }

  void _expectString(Map<String, Object?> fields, String key) {
    if (fields[key] is! String) {
      throw VoiceProfileValidationException('YAML 字段 $key 必须是字符串。');
    }
  }

  void _expectList(Map<String, Object?> fields, String key) {
    if (fields[key] is! YamlList && fields[key] is! List) {
      throw VoiceProfileValidationException('YAML 字段 $key 必须是列表。');
    }
  }

  void _expectNumber(Map<String, Object?> fields, String key) {
    if (fields[key] is! num) {
      throw VoiceProfileValidationException('YAML 字段 $key 必须是数字。');
    }
  }
}

class VoiceProfileValidationException implements Exception {
  const VoiceProfileValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
