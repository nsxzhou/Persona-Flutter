import 'package:yaml/yaml.dart';

import '../domain/novel_workshop.dart';

class ChapterQualityReviewResult {
  const ChapterQualityReviewResult({
    required this.verdict,
    required this.needsRevision,
    required this.reportMarkdown,
    this.overallScore,
    this.dimensionScores = const {},
    this.majorIssues = const [],
    this.revisionInstructions = '',
  });

  final ChapterQualityVerdict verdict;
  final bool needsRevision;
  final String reportMarkdown;
  final int? overallScore;
  final Map<String, int> dimensionScores;
  final List<String> majorIssues;
  final String revisionInstructions;
}

class ChapterQualityReviewParser {
  const ChapterQualityReviewParser();

  ChapterQualityReviewResult parse(String generated) {
    final trimmed = _stripCodeFence(generated).trim();
    try {
      if (!trimmed.startsWith('---')) {
        throw const FormatException('缺少 YAML front matter。');
      }
      final close = trimmed.indexOf('\n---', 3);
      if (close < 0) {
        throw const FormatException('缺少 YAML 结束分隔符。');
      }
      final yamlText = trimmed.substring(3, close).trim();
      final body = trimmed.substring(close + 4).trim();
      final parsed = loadYaml(yamlText);
      if (parsed is! YamlMap) {
        throw const FormatException('YAML 根节点不是 mapping。');
      }
      final needsRevision = _yamlBool(parsed['needsRevision']);
      final verdict = _parseVerdict(parsed['verdict']?.toString());
      final majorIssues = _yamlStringList(parsed['majorIssues']);
      final revisionInstructions = _yamlString(parsed['revisionInstructions']);
      final effectiveNeedsRevision =
          needsRevision || verdict == ChapterQualityVerdict.needsRevision;
      final report = body.isEmpty
          ? _fallbackReport(
              verdict: verdict,
              summary: _yamlString(parsed['summary']),
            )
          : body;
      return ChapterQualityReviewResult(
        verdict: effectiveNeedsRevision
            ? ChapterQualityVerdict.needsRevision
            : verdict,
        needsRevision: effectiveNeedsRevision,
        overallScore: _yamlInt(parsed['overallScore']),
        dimensionScores: _yamlScoreMap(parsed['dimensions']),
        majorIssues: majorIssues,
        revisionInstructions: revisionInstructions,
        reportMarkdown: report.trim(),
      );
    } on Object catch (error) {
      return ChapterQualityReviewResult(
        verdict: ChapterQualityVerdict.warning,
        needsRevision: false,
        reportMarkdown:
            '''
# 质量评审报告

质量评审结果无法完整解析，已降级为 warning，不触发自动修订。

- 解析错误：$error
'''
                .trim(),
      );
    }
  }

  ChapterQualityVerdict _parseVerdict(String? raw) {
    final normalized = raw?.trim().toLowerCase().replaceAll('-', '_') ?? '';
    switch (normalized) {
      case 'pass':
        return ChapterQualityVerdict.pass;
      case 'needsrevision':
      case 'needs_revision':
      case 'revise':
      case 'revision':
      case 'fail':
        return ChapterQualityVerdict.needsRevision;
      case 'warning':
      case 'warn':
        return ChapterQualityVerdict.warning;
      default:
        return ChapterQualityVerdict.warning;
    }
  }

  bool _yamlBool(Object? value) {
    if (value is bool) {
      return value;
    }
    final text = value?.toString().trim().toLowerCase();
    return text == 'true' || text == 'yes' || text == '1';
  }

  int? _yamlInt(Object? value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString().trim() ?? '');
  }

  String _yamlString(Object? value) {
    if (value == null) {
      return '';
    }
    if (value is YamlScalar) {
      return value.value?.toString().trim() ?? '';
    }
    return value.toString().trim();
  }

  List<String> _yamlStringList(Object? value) {
    if (value == null) {
      return const [];
    }
    if (value is YamlList) {
      return value.nodes
          .map((node) => _yamlString(node.value))
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    if (value is List<Object?>) {
      return value
          .map(_yamlString)
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    final single = _yamlString(value);
    return single.isEmpty ? const [] : [single];
  }

  Map<String, int> _yamlScoreMap(Object? value) {
    final map = <String, int>{};
    if (value is YamlMap) {
      for (final entry in value.entries) {
        final score = _yamlInt(entry.value);
        if (score != null) {
          map[entry.key.toString()] = score;
        }
      }
    }
    return Map.unmodifiable(map);
  }

  String _stripCodeFence(String raw) {
    var text = raw.trim();
    final fencePattern = RegExp(
      r'^```(?:yaml|markdown|md)?\s*\n([\s\S]*?)\n```\s*',
      caseSensitive: false,
    );
    final match = fencePattern.firstMatch(text);
    if (match != null) {
      text = match.group(1) ?? '';
    }
    return text.trim();
  }

  String _fallbackReport({
    required ChapterQualityVerdict verdict,
    required String summary,
  }) {
    final normalized = summary.trim().isEmpty ? '未提供摘要。' : summary.trim();
    return '# 质量评审报告\n\n- 结论：${verdict.name}\n- 摘要：$normalized';
  }
}
