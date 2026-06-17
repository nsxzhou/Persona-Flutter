import 'package:yaml/yaml.dart';

import '../../../core/utils/markdown_utils.dart';
import '../domain/market_book.dart';
import '../domain/market_pattern_brief.dart';

class MarketPatternBriefParser {
  const MarketPatternBriefParser();

  static const _allowedTopLevelFields = {
    'format',
    'target_platform',
    'validated_hot_patterns',
    'title_naming_patterns',
    'synopsis_hook_patterns',
    'saturated_areas',
    'opportunity_gaps',
    'constraints_for_directions',
    'reference_exemplars',
    'similarity_guidance',
  };

  static const _hotPatternAliases = {
    'pattern_name': 'name',
    'pattern': 'name',
    '模式名': 'name',
    '模式名称': 'name',
    'title': 'name',
    'evidence': 'evidence_titles',
    'books': 'evidence_titles',
    'samples': 'evidence_titles',
    'evidence_books': 'evidence_titles',
    '样本书名': 'evidence_titles',
    'chart_signal': 'chart_signals',
    'charts': 'chart_signals',
    '榜单信号': 'chart_signals',
  };

  static const _namedPatternAliases = {
    'pattern_name': 'name',
    'pattern': 'name',
    '模式名': 'name',
    '模式名称': 'name',
  };

  static const _exemplarAliases = {
    'desc': 'description',
    'synopsis': 'description',
    '简介': 'description',
    'chart': 'chart_placement',
    'ranking': 'chart_placement',
    'placement': 'chart_placement',
    '榜单位置': 'chart_placement',
  };

  static const _constraintAliases = {
    '稳妥热题': 'stable_hot_topic',
    '相邻变体': 'adjacent_variant',
    '高风险高收益': 'high_risk_high_reward',
  };

  MarketPatternBrief parse({
    required String markdown,
    required MarketPlatform expectedPlatform,
  }) {
    final normalized = normalizeYamlMarkdownDocument(markdown);
    if (normalized.startsWith('[') || normalized.startsWith('{')) {
      throw const MarketPatternBriefValidationException(
        '榜单模式分析输出禁止使用 JSON，必须是 YAML front matter + Markdown。',
      );
    }
    if (!normalized.startsWith('---\n')) {
      throw const MarketPatternBriefValidationException(
        '榜单模式分析输出必须以 YAML front matter 开头。',
      );
    }

    final end = normalized.indexOf('\n---', 4);
    if (end < 0) {
      throw const MarketPatternBriefValidationException(
        'YAML front matter 缺少结束分隔符。',
      );
    }

    final yamlText = normalized.substring(4, end).trim();
    final bodyStart = normalized.indexOf('\n', end + 4);
    final body = bodyStart < 0 ? '' : normalized.substring(bodyStart).trim();
    if (!body.startsWith('# 榜单模式分析')) {
      throw const MarketPatternBriefValidationException(
        'YAML 后的 Markdown 正文必须从 “# 榜单模式分析” 开始。',
      );
    }

    try {
      final parsed = loadYaml(yamlText);
      if (parsed is! YamlMap) {
        throw const MarketPatternBriefValidationException(
          'YAML front matter 必须是对象。',
        );
      }
      final root = _normalizeFieldMap(
        _normalizeMap(parsed, 'YAML front matter'),
        aliases: const {},
      );
      _rejectExtraFields(
        fields: root.keys,
        allowed: _allowedTopLevelFields,
        scope: 'YAML front matter',
      );

      final format = _requiredString(root, 'format', 'YAML front matter');
      if (format != 'persona.market_pattern_brief') {
        throw MarketPatternBriefValidationException(
          'YAML format 必须是 persona.market_pattern_brief，实际为 $format。',
        );
      }

      final targetPlatform = _parsePlatform(
        _requiredString(root, 'target_platform', 'YAML front matter'),
        'YAML front matter.target_platform',
      );
      if (targetPlatform != expectedPlatform) {
        throw MarketPatternBriefValidationException(
          'YAML target_platform 必须是 ${expectedPlatform.name}。',
        );
      }

      return MarketPatternBrief(
        targetPlatform: targetPlatform,
        validatedHotPatterns: _parseValidatedHotPatterns(
          root['validated_hot_patterns'],
        ),
        titleNamingPatterns: _parseNamedPatterns(
          root['title_naming_patterns'],
          'title_naming_patterns',
          aliases: _namedPatternAliases,
        ),
        synopsisHookPatterns: _parseNamedPatterns(
          root['synopsis_hook_patterns'],
          'synopsis_hook_patterns',
          aliases: _namedPatternAliases,
        ),
        saturatedAreas: _requiredStringList(root, 'saturated_areas'),
        opportunityGaps: _requiredStringList(root, 'opportunity_gaps'),
        constraintsForDirections: _parseConstraints(
          root['constraints_for_directions'],
        ),
        referenceExemplars: _parseReferenceExemplars(root['reference_exemplars']),
        similarityGuidance: _requiredString(
          root,
          'similarity_guidance',
          'YAML front matter',
        ),
        markdown: normalized,
      );
    } on MarketPatternBriefValidationException {
      rethrow;
    } on Object catch (error) {
      throw MarketPatternBriefValidationException('榜单模式 YAML 解析失败：$error');
    }
  }

  List<ValidatedHotPattern> _parseValidatedHotPatterns(Object? value) {
    if (value is! YamlList && value is! List) {
      throw const MarketPatternBriefValidationException(
        'validated_hot_patterns 必须是列表。',
      );
    }
    final items = (value as Iterable<Object?>).toList(growable: false);
    if (items.isEmpty) {
      throw const MarketPatternBriefValidationException(
        'validated_hot_patterns 不能为空。',
      );
    }
    return [
      for (var index = 0; index < items.length; index += 1)
        _parseValidatedHotPattern(items[index], index),
    ];
  }

  ValidatedHotPattern _parseValidatedHotPattern(Object? value, int index) {
    if (value is! YamlMap && value is! Map) {
      throw MarketPatternBriefValidationException(
        'validated_hot_patterns 第 ${index + 1} 项必须是对象。',
      );
    }
    final scope = 'validated_hot_patterns 第 ${index + 1} 项';
    final fields = _normalizeFieldMap(
      _coerceSingleKeyObject(_normalizeMap(value as Object, scope)),
      aliases: _hotPatternAliases,
    );
    return ValidatedHotPattern(
      name: _requiredString(fields, 'name', scope),
      summary: _requiredString(fields, 'summary', scope),
      evidenceTitles: _requiredStringList(fields, 'evidence_titles'),
      tags: _requiredStringList(fields, 'tags'),
      chartSignals: _requiredStringList(fields, 'chart_signals'),
    );
  }

  List<NamedPattern> _parseNamedPatterns(
    Object? value,
    String fieldName, {
    required Map<String, String> aliases,
  }) {
    if (value is! YamlList && value is! List) {
      throw MarketPatternBriefValidationException('$fieldName 必须是列表。');
    }
    final items = (value as Iterable<Object?>).toList(growable: false);
    if (items.isEmpty) {
      throw MarketPatternBriefValidationException('$fieldName 不能为空。');
    }
    return [
      for (var index = 0; index < items.length; index += 1)
        _parseNamedPattern(items[index], fieldName, index, aliases: aliases),
    ];
  }

  NamedPattern _parseNamedPattern(
    Object? value,
    String fieldName,
    int index, {
    required Map<String, String> aliases,
  }) {
    if (value is! YamlMap && value is! Map) {
      throw MarketPatternBriefValidationException(
        '$fieldName 第 ${index + 1} 项必须是对象。',
      );
    }
    final scope = '$fieldName 第 ${index + 1} 项';
    final fields = _normalizeFieldMap(
      _coerceSingleKeyObject(_normalizeMap(value as Object, scope)),
      aliases: aliases,
    );
    final counterExample = fields['counter_example'];
    return NamedPattern(
      name: _requiredString(fields, 'name', scope),
      formula: _requiredString(fields, 'formula', scope),
      summary: _requiredString(fields, 'summary', scope),
      counterExample: counterExample is String && counterExample.trim().isNotEmpty
          ? counterExample.trim()
          : null,
    );
  }

  DirectionConstraints _parseConstraints(Object? value) {
    if (value is! YamlMap && value is! Map) {
      throw const MarketPatternBriefValidationException(
        'constraints_for_directions 必须是对象。',
      );
    }
    const scope = 'constraints_for_directions';
    final fields = _normalizeFieldMap(
      _normalizeMap(value as Object, scope),
      aliases: _constraintAliases,
    );
    return DirectionConstraints(
      stableHotTopic: _requiredString(fields, 'stable_hot_topic', scope),
      adjacentVariant: _requiredString(fields, 'adjacent_variant', scope),
      highRiskHighReward: _requiredString(
        fields,
        'high_risk_high_reward',
        scope,
      ),
    );
  }

  List<ReferenceExemplar> _parseReferenceExemplars(Object? value) {
    if (value is! YamlList && value is! List) {
      throw const MarketPatternBriefValidationException(
        'reference_exemplars 必须是列表。',
      );
    }
    final items = (value as Iterable<Object?>).toList(growable: false);
    if (items.isEmpty) {
      throw const MarketPatternBriefValidationException(
        'reference_exemplars 不能为空。',
      );
    }
    return [
      for (var index = 0; index < items.length; index += 1)
        _parseReferenceExemplar(items[index], index),
    ];
  }

  ReferenceExemplar _parseReferenceExemplar(Object? value, int index) {
    if (value is! YamlMap && value is! Map) {
      throw MarketPatternBriefValidationException(
        'reference_exemplars 第 ${index + 1} 项必须是对象。',
      );
    }
    final scope = 'reference_exemplars 第 ${index + 1} 项';
    final fields = _normalizeFieldMap(
      _normalizeMap(value as Object, scope),
      aliases: _exemplarAliases,
    );
    return ReferenceExemplar(
      title: _requiredString(fields, 'title', scope),
      description: _requiredString(fields, 'description', scope),
      chartPlacement: _requiredString(fields, 'chart_placement', scope),
      tags: _requiredStringList(fields, 'tags'),
    );
  }

  Map<String, Object?> _coerceSingleKeyObject(Map<String, Object?> fields) {
    if (fields.containsKey('name') || fields.length != 1) {
      return fields;
    }
    final onlyEntry = fields.entries.first;
    final nested = onlyEntry.value;
    if (nested is! Map) {
      return {'name': onlyEntry.key, ...fields};
    }
    final nestedMap = Map<String, Object?>.from(
      nested.map((key, value) => MapEntry(key.toString(), value)),
    );
    return {'name': onlyEntry.key, ...nestedMap};
  }

  Map<String, Object?> _normalizeFieldMap(
    Map<String, Object?> fields, {
    required Map<String, String> aliases,
  }) {
    if (aliases.isEmpty) {
      return fields;
    }
    final output = <String, Object?>{};
    for (final entry in fields.entries) {
      final canonical = aliases[entry.key] ?? entry.key;
      output.putIfAbsent(canonical, () => entry.value);
    }
    return output;
  }

  Map<String, Object?> _normalizeMap(Object value, String scope) {
    if (value is YamlMap) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _normalizeYamlValue(entry.value),
      };
    }
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _normalizeYamlValue(entry.value),
      };
    }
    throw MarketPatternBriefValidationException('$scope 必须是对象。');
  }

  Object? _normalizeYamlValue(Object? value) {
    if (value is YamlMap) {
      return _normalizeMap(value, 'YAML 对象');
    }
    if (value is YamlList) {
      return value.map(_normalizeYamlValue).toList(growable: false);
    }
    return value;
  }

  void _rejectExtraFields({
    required Iterable<String> fields,
    required Set<String> allowed,
    required String scope,
  }) {
    for (final field in fields) {
      if (!allowed.contains(field)) {
        throw MarketPatternBriefValidationException(
          '$scope 包含未允许字段：$field。',
        );
      }
    }
  }

  String _requiredString(
    Map<String, Object?> fields,
    String key,
    String scope,
  ) {
    final value = fields[key];
    if (value is! String || value.trim().isEmpty) {
      throw MarketPatternBriefValidationException('$scope 缺少必填字段：$key。');
    }
    return value.trim();
  }

  List<String> _requiredStringList(
    Map<String, Object?> fields,
    String key,
  ) {
    final value = fields[key];
    if (value is! List) {
      throw MarketPatternBriefValidationException('$key 必须是列表。');
    }
    final output = <String>[];
    for (final item in value) {
      if (item is! String || item.trim().isEmpty) {
        throw MarketPatternBriefValidationException(
          '$key 列表项必须是非空字符串。',
        );
      }
      final normalized = item.trim();
      if (!output.contains(normalized)) {
        output.add(normalized);
      }
    }
    if (output.isEmpty) {
      throw MarketPatternBriefValidationException('$key 不能为空。');
    }
    return output;
  }

  MarketPlatform _parsePlatform(String value, String scope) {
    try {
      return MarketPlatform.values.byName(value.trim());
    } on Object {
      throw MarketPatternBriefValidationException(
        '$scope 必须是 ${MarketPlatform.values.map((p) => p.name).join('/')}。',
      );
    }
  }
}

class MarketPatternBriefValidationException implements Exception {
  const MarketPatternBriefValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
