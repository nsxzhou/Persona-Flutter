import 'package:yaml/yaml.dart';

import '../domain/market_book.dart';
import '../domain/recommendation_direction.dart';

class RecommendationDirectionDocumentParser {
  const RecommendationDirectionDocumentParser();

  static const directionCount = 3;
  static const titleCandidateCount = 3;
  static const minSynopsisCharacters = 120;
  static const maxSynopsisCharacters = 220;
  static const _allowedTopLevelFields = {
    'format',
    'target_platform',
    'directions',
  };
  static const _allowedDirectionFields = {
    'suggested_title',
    'title_candidates',
    'synopsis',
    'genre_tags',
    'target_word_count',
    'target_platform',
    'target_audience',
    'core_selling_point',
    'market_heat_summary',
    'competition_summary',
    'market_validation',
    'differentiation',
    'feasibility',
    'failure_risk',
    'validation_action',
  };
  static const _allowedTitleCandidateFields = {'title', 'formula', 'rationale'};

  List<RecommendationDirection> parse({
    required String markdown,
    required MarketPlatform expectedPlatform,
  }) {
    final normalized = markdown.trimLeft();
    if (normalized.startsWith('[') || normalized.startsWith('{')) {
      throw const RecommendationDirectionValidationException(
        '推荐输出禁止使用 JSON，必须是 YAML front matter + Markdown。',
      );
    }
    if (normalized.startsWith('```')) {
      throw const RecommendationDirectionValidationException(
        '推荐输出不得包裹 Markdown/YAML 代码围栏。',
      );
    }
    if (!normalized.startsWith('---\n')) {
      throw const RecommendationDirectionValidationException(
        '推荐输出必须以 YAML front matter 开头。',
      );
    }

    final end = normalized.indexOf('\n---', 4);
    if (end < 0) {
      throw const RecommendationDirectionValidationException(
        'YAML front matter 缺少结束分隔符。',
      );
    }

    final yamlText = normalized.substring(4, end).trim();
    final bodyStart = normalized.indexOf('\n', end + 4);
    final body = bodyStart < 0 ? '' : normalized.substring(bodyStart).trim();
    if (!body.startsWith('# AI 推荐选题')) {
      throw const RecommendationDirectionValidationException(
        'YAML 后的 Markdown 正文必须从 “# AI 推荐选题” 开始。',
      );
    }

    try {
      final parsed = loadYaml(yamlText);
      if (parsed is! YamlMap) {
        throw const RecommendationDirectionValidationException(
          'YAML front matter 必须是对象。',
        );
      }
      final root = _normalizeMap(parsed, 'YAML front matter');
      _rejectExtraFields(
        fields: root.keys,
        allowed: _allowedTopLevelFields,
        scope: 'YAML front matter',
      );

      final format = _requiredString(root, 'format', 'YAML front matter');
      if (format != 'persona.market_recommendations') {
        throw RecommendationDirectionValidationException(
          'YAML format 必须是 persona.market_recommendations，实际为 $format。',
        );
      }
      final targetPlatform = _parsePlatform(
        _requiredString(root, 'target_platform', 'YAML front matter'),
        'YAML front matter.target_platform',
      );
      if (targetPlatform != expectedPlatform) {
        throw RecommendationDirectionValidationException(
          'YAML target_platform 必须是 ${expectedPlatform.name}。',
        );
      }

      final directionsValue = root['directions'];
      if (directionsValue is! YamlList && directionsValue is! List) {
        throw const RecommendationDirectionValidationException(
          'YAML directions 必须是列表。',
        );
      }
      final directionItems = (directionsValue as Iterable<Object?>).toList(
        growable: false,
      );
      if (directionItems.length != directionCount) {
        throw const RecommendationDirectionValidationException(
          'YAML directions 必须固定输出 3 个方向。',
        );
      }

      return [
        for (var index = 0; index < directionItems.length; index += 1)
          _parseDirection(directionItems[index], index, expectedPlatform, body),
      ];
    } on RecommendationDirectionValidationException {
      rethrow;
    } on Object catch (error) {
      throw RecommendationDirectionValidationException('推荐 YAML 解析失败：$error');
    }
  }

  RecommendationDirection _parseDirection(
    Object? value,
    int index,
    MarketPlatform expectedPlatform,
    String body,
  ) {
    if (value is! YamlMap && value is! Map) {
      throw RecommendationDirectionValidationException(
        '第 ${index + 1} 个推荐方向必须是对象。',
      );
    }
    final scope = '第 ${index + 1} 个推荐方向';
    final fields = _normalizeMap(value as Object, scope);
    _rejectExtraFields(
      fields: fields.keys,
      allowed: _allowedDirectionFields,
      scope: scope,
    );

    final titleCandidates = _parseTitleCandidates(
      fields['title_candidates'],
      index,
    );
    final suggestedTitle = _cleanTitle(
      _requiredString(fields, 'suggested_title', scope),
      '$scope.suggested_title',
    );
    if (!titleCandidates.any(
      (candidate) => candidate.title == suggestedTitle,
    )) {
      throw RecommendationDirectionValidationException(
        '$scope 的 suggested_title 必须来自 title_candidates。',
      );
    }

    final platform = _parsePlatform(
      _requiredString(fields, 'target_platform', scope),
      '$scope.target_platform',
    );
    if (platform != expectedPlatform) {
      throw RecommendationDirectionValidationException(
        '$scope 的 target_platform 必须是 ${expectedPlatform.name}。',
      );
    }

    final synopsis = _requiredString(fields, 'synopsis', scope);
    final synopsisLength = synopsis.runes.length;
    if (synopsisLength < minSynopsisCharacters ||
        synopsisLength > maxSynopsisCharacters) {
      throw RecommendationDirectionValidationException(
        '$scope 的 synopsis 必须为 '
        '$minSynopsisCharacters-$maxSynopsisCharacters 个字符。',
      );
    }

    final feasibility = _requiredString(fields, 'feasibility', scope);
    if (!const {'高', '中', '低'}.contains(feasibility)) {
      throw RecommendationDirectionValidationException(
        '$scope 的 feasibility 必须是 高/中/低。',
      );
    }

    return RecommendationDirection(
      suggestedTitle: suggestedTitle,
      titleCandidates: titleCandidates,
      synopsis: synopsis,
      genreTags: _requiredStringList(fields, 'genre_tags', scope),
      targetWordCount: _requiredPositiveInt(fields, 'target_word_count', scope),
      targetPlatform: platform,
      targetAudience: _requiredString(fields, 'target_audience', scope),
      coreSellingPoint: _requiredString(fields, 'core_selling_point', scope),
      marketHeatSummary: _requiredString(fields, 'market_heat_summary', scope),
      competitionSummary: _requiredString(fields, 'competition_summary', scope),
      marketValidation: _requiredString(fields, 'market_validation', scope),
      differentiation: _requiredString(fields, 'differentiation', scope),
      feasibility: feasibility,
      failureRisk: _requiredString(fields, 'failure_risk', scope),
      validationAction: _requiredString(fields, 'validation_action', scope),
      detailMarkdown: _extractDirectionMarkdown(
        body: body,
        index: index,
        title: suggestedTitle,
      ),
    );
  }

  List<RecommendationTitleCandidate> _parseTitleCandidates(
    Object? value,
    int directionIndex,
  ) {
    if (value is! YamlList && value is! List) {
      throw RecommendationDirectionValidationException(
        '第 ${directionIndex + 1} 个推荐方向的 title_candidates 必须是列表。',
      );
    }
    final items = (value as Iterable<Object?>).toList(growable: false);
    if (items.length != titleCandidateCount) {
      throw RecommendationDirectionValidationException(
        '第 ${directionIndex + 1} 个推荐方向必须包含 $titleCandidateCount 个候选书名。',
      );
    }

    final candidates = <RecommendationTitleCandidate>[];
    for (var index = 0; index < items.length; index += 1) {
      final item = items[index];
      if (item is! YamlMap && item is! Map) {
        throw RecommendationDirectionValidationException(
          '第 ${directionIndex + 1} 个推荐方向的第 ${index + 1} 个候选书名必须是对象。',
        );
      }
      final scope = '第 ${directionIndex + 1} 个推荐方向的第 ${index + 1} 个候选书名';
      final fields = _normalizeMap(item as Object, scope);
      _rejectExtraFields(
        fields: fields.keys,
        allowed: _allowedTitleCandidateFields,
        scope: scope,
      );
      final title = _cleanTitle(_requiredString(fields, 'title', scope), scope);
      if (candidates.any((candidate) => candidate.title == title)) {
        throw RecommendationDirectionValidationException('$scope 与其他候选书名重复。');
      }
      candidates.add(
        RecommendationTitleCandidate(
          title: title,
          formula: _requiredString(fields, 'formula', scope),
          rationale: _requiredString(fields, 'rationale', scope),
        ),
      );
    }
    return candidates;
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
    throw RecommendationDirectionValidationException('$scope 必须是对象。');
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
        throw RecommendationDirectionValidationException(
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
      throw RecommendationDirectionValidationException('$scope 缺少必填字段：$key。');
    }
    return value.trim();
  }

  List<String> _requiredStringList(
    Map<String, Object?> fields,
    String key,
    String scope,
  ) {
    final value = fields[key];
    if (value is! List) {
      throw RecommendationDirectionValidationException('$scope 的 $key 必须是列表。');
    }
    final output = <String>[];
    for (final item in value) {
      if (item is! String || item.trim().isEmpty) {
        throw RecommendationDirectionValidationException(
          '$scope 的 $key 列表项必须是非空字符串。',
        );
      }
      final normalized = item.trim();
      if (!output.contains(normalized)) {
        output.add(normalized);
      }
    }
    if (output.isEmpty) {
      throw RecommendationDirectionValidationException('$scope 的 $key 不能为空。');
    }
    return output;
  }

  int _requiredPositiveInt(
    Map<String, Object?> fields,
    String key,
    String scope,
  ) {
    final value = fields[key];
    final parsed = switch (value) {
      final int number => number,
      final num number => number.round(),
      final String text => _parseWordCountText(text),
      _ => null,
    };
    if (parsed == null || parsed <= 0) {
      throw RecommendationDirectionValidationException('$scope 的 $key 必须是正整数。');
    }
    return parsed;
  }

  int? _parseWordCountText(String text) {
    final normalized = text.replaceAll(',', '').trim();
    final tenThousandMatch = RegExp(
      r'(\d+(?:\.\d+)?)\s*万',
    ).firstMatch(normalized);
    if (tenThousandMatch != null) {
      final value = double.tryParse(tenThousandMatch.group(1)!);
      if (value != null) {
        return (value * 10000).round();
      }
    }
    final digits = RegExp(
      r'\d+',
    ).allMatches(normalized).map((m) => m.group(0)!).join();
    return digits.isEmpty ? null : int.tryParse(digits);
  }

  MarketPlatform _parsePlatform(String value, String scope) {
    try {
      return MarketPlatform.values.byName(value.trim());
    } on Object {
      throw RecommendationDirectionValidationException(
        '$scope 必须是 ${MarketPlatform.values.map((p) => p.name).join('/')}。',
      );
    }
  }

  String _cleanTitle(String value, String scope) {
    final title = value
        .replaceAll(RegExp(r'''^[《「『“”"']+|[》」』“”"']+$'''), '')
        .trim();
    final length = title.runes.length;
    if (length < 2 || length > 32) {
      throw RecommendationDirectionValidationException('$scope 必须为 2-32 个字符。');
    }
    const genericTerms = [
      '建议书名',
      '标题',
      '题材',
      '方向',
      '计划',
      '项目',
      '示例',
      '待定',
      '某某',
    ];
    if (genericTerms.any(title.contains)) {
      throw RecommendationDirectionValidationException('$scope 过于泛化。');
    }
    return title;
  }

  String _extractDirectionMarkdown({
    required String body,
    required int index,
    required String title,
  }) {
    final headingPattern = RegExp(
      '^##\\s+方向\\s*${index + 1}[：:]\\s*.*\$',
      multiLine: true,
    );
    final match = headingPattern.firstMatch(body);
    if (match == null) {
      return body;
    }
    final nextHeadingMatches = RegExp(
      r'^##\s+方向\s*\d+[：:].*$',
      multiLine: true,
    ).allMatches(body, match.end);
    RegExpMatch? nextHeading;
    for (final candidate in nextHeadingMatches) {
      nextHeading = candidate;
      break;
    }
    final section = body.substring(match.start, nextHeading?.start).trim();
    return section.contains(title) ? section : '$section\n\n> 选定书名：$title';
  }
}

class RecommendationDirectionValidationException implements Exception {
  const RecommendationDirectionValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
