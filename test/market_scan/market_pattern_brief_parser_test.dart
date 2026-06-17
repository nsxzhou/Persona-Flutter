import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/core/utils/markdown_utils.dart';
import 'package:persona_flutter/src/features/market_scan/application/market_pattern_brief_parser.dart';
import 'package:persona_flutter/src/features/market_scan/domain/market_book.dart';

void main() {
  test('normalizeYamlMarkdownDocument strips yaml fences and fixes opening delimiter', () {
    const fenced = '''
```yaml
---
format: persona.market_pattern_brief
---
# 榜单模式分析
```
''';
    expect(
      normalizeYamlMarkdownDocument(fenced),
      startsWith('---\nformat: persona.market_pattern_brief'),
    );
  });

  test('parser accepts Chinese field aliases for validated_hot_patterns', () {
    final brief = const MarketPatternBriefParser().parse(
      markdown: _briefWithAliasFields(),
      expectedPlatform: MarketPlatform.qidian,
    );

    expect(brief.validatedHotPatterns.first.name, '都市悬疑强剧情');
    expect(brief.validatedHotPatterns.first.evidenceTitles, contains('旧港谜案录'));
  });

  test('parser coerces single-key validated_hot_patterns item into name field', () {
    final brief = const MarketPatternBriefParser().parse(
      markdown: _briefWithSingleKeyPattern(),
      expectedPlatform: MarketPlatform.qidian,
    );

    expect(brief.validatedHotPatterns.first.name, '都市悬疑强剧情');
    expect(brief.validatedHotPatterns.first.summary, isNotEmpty);
  });

  test('parser accepts yaml code fence wrapper', () {
    final brief = const MarketPatternBriefParser().parse(
      markdown: '```yaml\n${_validBriefDocument()}\n```',
      expectedPlatform: MarketPlatform.qidian,
    );

    expect(brief.referenceExemplars, isNotEmpty);
  });

  test('parser rejects missing name after alias normalization', () {
    expect(
      () => const MarketPatternBriefParser().parse(
        markdown: _briefMissingName(),
        expectedPlatform: MarketPlatform.qidian,
      ),
      throwsA(isA<MarketPatternBriefValidationException>()),
    );
  });
}

String _briefWithAliasFields() {
  return '''
---
format: persona.market_pattern_brief
target_platform: qidian
validated_hot_patterns:
  - 模式名称: 都市悬疑强剧情
    summary: 多本样本重复验证的热题模式摘要
    样本书名: [旧港谜案录, 档案归零]
    tags: [悬疑, 都市]
    榜单信号: [月榜]
title_naming_patterns:
  - name: 命名模式A
    formula: 地点+案件
    summary: 说明
synopsis_hook_patterns:
  - name: 钩子模式A
    formula: 处境->能力->爽点
    summary: 说明
saturated_areas: [纯刑侦]
opportunity_gaps: [记忆档案悬疑]
constraints_for_directions:
  稳妥热题: 约束A
  相邻变体: 约束B
  高风险高收益: 约束C
reference_exemplars:
  - title: 旧港谜案录
    简介: 完整简介原文
    榜单位置: 起点中文网 · 月榜 · #1
    tags: [悬疑]
similarity_guidance: 允许轻度相似，禁止整句照抄
---
# 榜单模式分析
''';
}

String _briefWithSingleKeyPattern() {
  return '''
---
format: persona.market_pattern_brief
target_platform: qidian
validated_hot_patterns:
  - 都市悬疑强剧情:
      summary: 多本样本重复验证的热题模式摘要
      evidence_titles: [旧港谜案录, 档案归零]
      tags: [悬疑, 都市]
      chart_signals: [月榜]
title_naming_patterns:
  - name: 命名模式A
    formula: 地点+案件
    summary: 说明
synopsis_hook_patterns:
  - name: 钩子模式A
    formula: 处境->能力->爽点
    summary: 说明
saturated_areas: [纯刑侦]
opportunity_gaps: [记忆档案悬疑]
constraints_for_directions:
  stable_hot_topic: 约束A
  adjacent_variant: 约束B
  high_risk_high_reward: 约束C
reference_exemplars:
  - title: 旧港谜案录
    description: 完整简介原文
    chart_placement: 起点中文网 · 月榜 · #1
    tags: [悬疑]
similarity_guidance: 允许轻度相似，禁止整句照抄
---
# 榜单模式分析
''';
}

String _briefMissingName() {
  return '''
---
format: persona.market_pattern_brief
target_platform: qidian
validated_hot_patterns:
  - summary: 缺少 name 字段
    evidence_titles: [旧港谜案录]
    tags: [悬疑]
    chart_signals: [月榜]
title_naming_patterns:
  - name: 命名模式A
    formula: 地点+案件
    summary: 说明
synopsis_hook_patterns:
  - name: 钩子模式A
    formula: 处境->能力->爽点
    summary: 说明
saturated_areas: [纯刑侦]
opportunity_gaps: [记忆档案悬疑]
constraints_for_directions:
  stable_hot_topic: 约束A
  adjacent_variant: 约束B
  high_risk_high_reward: 约束C
reference_exemplars:
  - title: 旧港谜案录
    description: 完整简介原文
    chart_placement: 起点中文网 · 月榜 · #1
    tags: [悬疑]
similarity_guidance: 允许轻度相似，禁止整句照抄
---
# 榜单模式分析
''';
}

String _validBriefDocument() {
  return '''
---
format: persona.market_pattern_brief
target_platform: qidian
validated_hot_patterns:
  - name: 都市悬疑强剧情
    summary: 多本样本重复验证的热题模式摘要
    evidence_titles: [旧港谜案录, 档案归零]
    tags: [悬疑, 都市]
    chart_signals: [月榜]
title_naming_patterns:
  - name: 命名模式A
    formula: 地点+案件
    summary: 说明
synopsis_hook_patterns:
  - name: 钩子模式A
    formula: 处境->能力->爽点
    summary: 说明
saturated_areas: [纯刑侦]
opportunity_gaps: [记忆档案悬疑]
constraints_for_directions:
  stable_hot_topic: 约束A
  adjacent_variant: 约束B
  high_risk_high_reward: 约束C
reference_exemplars:
  - title: 旧港谜案录
    description: 完整简介原文
    chart_placement: 起点中文网 · 月榜 · #1
    tags: [悬疑]
similarity_guidance: 允许轻度相似，禁止整句照抄
---
# 榜单模式分析
''';
}
