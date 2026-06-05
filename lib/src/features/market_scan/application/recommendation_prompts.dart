import '../domain/market_metrics.dart';

/// Formats [MarketMetrics] into a structured LLM prompt for generating
/// creative Recommendation Directions.
class RecommendationPrompts {
  const RecommendationPrompts();

  static const _systemPrompt = '''
你是一位资深网文市场分析师和创作顾问。你的任务是根据真实市场数据指标，为作家推荐最有潜力的创作方向。

## 输出规范

输出严格的 JSON 数组，包含 3-5 个推荐方向。每个方向的格式如下：

```json
[
  {
    "suggestedTitle": "建议书名（有吸引力，符合目标题材风格）",
    "synopsis": "一句话简介（20-40字，概括核心卖点）",
    "genreTags": ["题材标签1", "题材标签2", "题材标签3"],
    "targetWordCount": 1200000,
    "marketHeatSummary": "市场热度分析（2-3句话，说明为什么这个方向有机会）",
    "competitionSummary": "竞品分析（2-3句话，说明竞争格局和差异化切入点）"
  }
]
```

## 生成原则

1. 优先推荐市场机会评分高的题材（热度高 + 竞品密度低）
2. 字数目标应参考当前市场热门作品的字数分布
3. 每个推荐方向应该差异化，覆盖不同的题材和风格
4. 书名要有记忆点，避免泛泛而谈
5. 简介要突出核心冲突和卖点
6. genreTags 使用中文网文行业通用标签

只输出 JSON 数组，不要输出任何其他文字。不要用 markdown 代码块包裹。
''';

  /// Build the user prompt from market metrics.
  String buildUserPrompt(MarketMetrics metrics) {
    final buffer = StringBuffer();

    // Genre heat.
    buffer.writeln('## 题材热度排名');
    if (metrics.genreHeat.isEmpty) {
      buffer.writeln('暂无数据');
    } else {
      buffer.writeln('| 题材 | 热度分 | 出现次数 | 平均排名 | 覆盖平台 |');
      buffer.writeln('|------|--------|----------|----------|----------|');
      for (final entry in metrics.genreHeat.take(20)) {
        buffer.writeln(
          '| ${entry.genre} | ${entry.heatScore.toStringAsFixed(1)} '
          '| ${entry.appearanceCount} | ${entry.averageRank.toStringAsFixed(1)} '
          '| ${entry.platforms.join(", ")} |',
        );
      }
    }
    buffer.writeln();

    // Word count distribution.
    buffer.writeln('## 字数分布');
    if (metrics.wordCountDistribution.isEmpty) {
      buffer.writeln('暂无数据');
    } else {
      for (final bucket in metrics.wordCountDistribution) {
        buffer.writeln(
          '- ${bucket.rangeLabel}: ${bucket.bookCount} 本 '
          '(${bucket.percentage.toStringAsFixed(1)}%)',
        );
      }
    }
    buffer.writeln();

    // Competition density.
    buffer.writeln('## 竞品密度（近 90 天新书）');
    if (metrics.competitionDensity.isEmpty) {
      buffer.writeln('暂无数据');
    } else {
      buffer.writeln('| 题材 | 新书数 | 在榜数 | 密度分 |');
      buffer.writeln('|------|--------|--------|--------|');
      for (final entry in metrics.competitionDensity.take(15)) {
        buffer.writeln(
          '| ${entry.genre} | ${entry.newBookCount} '
          '| ${entry.onChartCount} | ${entry.densityScore.toStringAsFixed(2)} |',
        );
      }
    }
    buffer.writeln();

    // Market opportunities.
    buffer.writeln('## 市场机会评分 TOP 10');
    if (metrics.opportunities.isEmpty) {
      buffer.writeln('暂无数据');
    } else {
      for (final entry in metrics.opportunities.take(10)) {
        buffer.writeln(
          '- **${entry.genre}**: 机会分 ${entry.opportunityScore.toStringAsFixed(1)} '
          '(热度 ${entry.heatScore.toStringAsFixed(1)}, '
          '密度 ${entry.densityScore.toStringAsFixed(2)})',
        );
      }
    }

    return buffer.toString();
  }

  /// The system prompt for the LLM call.
  String get systemPrompt => _systemPrompt;
}
