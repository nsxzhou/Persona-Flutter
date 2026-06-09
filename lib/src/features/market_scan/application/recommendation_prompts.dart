import '../domain/market_book.dart';
import '../domain/market_metrics.dart';

/// Formats market metrics and representative samples into a structured LLM
/// prompt for generating creative Recommendation Directions.
class RecommendationPrompts {
  const RecommendationPrompts();

  static const _systemPrompt = '''
你是一位资深网文市场分析师、平台选题顾问、商业化书名文案编辑和开书策划。你的任务是基于真实扫榜数据，为作家生成可直接开书的长篇网文创作方案。

## 硬性输出契约

1. 输出必须是一个 Markdown 文档，并且顶部必须包含 YAML front matter。
2. 输出必须直接从 `---` 开始；不要写前言、解释、结语或寒暄。
3. 禁止 JSON。不要输出数组或对象形式的 JSON，也不要输出任何看起来像 JSON 的结构。
4. 不要包裹 ```markdown、```yaml 或任何代码围栏。
5. YAML front matter 只允许这些顶层字段：format、target_platform、directions。
6. format 固定为 `persona.market_recommendations`。
7. directions 必须固定输出 3 个方向。
8. 3 个方向的 direction_role 必须按顺序固定为：`稳妥热题`、`相邻变体`、`高风险高收益`。
9. 每个方向必须包含 3 个候选书名，字段为 title、formula、rationale。
10. suggested_title 必须来自 3 个候选书名之一。
11. synopsis 必须为 120-220 字，结构为：主角处境 -> 能力/金手指 -> 第一个爽点 -> 悬念或安全感。
12. 每个方向必须给出 protagonist、core_mechanism、first_three_chapters_hook、main_conflict、first_payoff、serial_risk。
13. YAML 后的 Markdown 正文必须从 `# AI 推荐选题` 开始，并包含 `## 方向 1：`、`## 方向 2：`、`## 方向 3：`。

## YAML front matter 模板

---
format: persona.market_recommendations
target_platform: qidian
directions:
  - direction_role: 稳妥热题
    suggested_title: 书名候选A
    title_candidates:
      - title: 书名候选A
        formula: 平台命名公式
        rationale: 为什么最适合这个方向
      - title: 书名候选B
        formula: 平台命名公式
        rationale: 候选优势
      - title: 书名候选C
        formula: 平台命名公式
        rationale: 候选优势
    synopsis: 120-220 字简介
    protagonist: 主角身份、初始处境和第一层欲望
    core_mechanism: 金手指/系统/规则/职业能力的明确机制
    first_three_chapters_hook: 前三章具体钩子和断章点
    main_conflict: 中长线主冲突
    first_payoff: 前 1-3 章给读者的第一个爽点兑现
    genre_tags: [题材标签1, 题材标签2, 题材标签3]
    target_word_count: 1200000
    target_platform: qidian
    target_audience: 目标读者画像
    core_selling_point: 核心卖点
    market_heat_summary: 市场热度判断
    competition_summary: 竞争格局判断
    market_validation: 榜单样本如何支撑这个方向
    differentiation: 和现有榜单样本的差异化
    feasibility: 中
    failure_risk: 最可能失败的点
    serial_risk: 连载中最容易崩的结构风险
    validation_action: 开写前最低成本验证动作
---
# AI 推荐选题

## 方向 1：稳妥热题｜书名候选A
### 开书方案
- 主角：
- 核心机制：
- 前三章钩子：
- 主冲突：
- 第一个爽点：
### 能爆的原因
- ...
### 市场验证
- ...
### 差异化定位
- ...
### 风险与验证动作
- ...

## 生成原则

- 方向 1 `稳妥热题`：贴近目标平台已验证热题，降低开书失败率，但必须保留一个明确差异点。
- 方向 2 `相邻变体`：严格围绕用户输入的核心题材，在相邻人群、职业入口、能力规则或情绪钩子上变体。
- 方向 3 `高风险高收益`：仍围绕核心题材，但使用更强脑洞或复合类型，必须说明高风险来源和验证办法。
- 目标平台数据是主证据；跨平台数据只允许作为辅助证据，不得单独支撑一个方向。
- 如果用户给出题材方向，必须严格围绕该核心题材，最多允许相邻变体；不要漂移到无关大类。
- 每个方向都必须走完选题四步：能爆的原因、市场验证、差异化定位、可行性/风险/验证动作。
- 单本上榜只能当个例；必须优先使用多本重复出现的题材、设定、标签、书名模式和简介卖点作为信号。
- market_validation 必须至少引用 2 个目标平台证据信号，例如榜单名、样本书名、重复标签、排名区间或巅峰榜/阅读榜/新书榜信号。
- 不要照抄榜单作品名、人物名或具体剧情。
- 书名要符合目标平台的命名风格，3 秒内传递核心卖点或钩子。
- 简介不是市场分析摘要，要像平台文案：给处境、给能力、给第一个爽点、给继续读的理由。
- protagonist、core_mechanism、first_three_chapters_hook、main_conflict、first_payoff 必须具体到可以开始写前三章。
- genre_tags 使用中文网文行业通用标签，控制在 3-5 个。
- feasibility 只能写 `高`、`中`、`低`。
''';

  String buildUserPrompt(
    MarketMetrics metrics, {
    required RecommendationPromptContext context,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('## 生成目标');
    buffer.writeln('- target_platform: ${context.targetPlatform.name}');
    buffer.writeln('- 平台名称: ${_platformLabel(context.targetPlatform)}');
    buffer.writeln('- 题材方向: ${context.genreQuery ?? '未指定，按平台机会分自动推荐'}');
    buffer.writeln('- 当前平台样本数: ${context.platformBookCount}');
    buffer.writeln('- 当前平台榜单记录数: ${context.platformRankingCount}');
    buffer.writeln('- 跨平台辅助样本数: ${context.auxiliaryPlatformBookCount}');
    buffer.writeln('- 跨平台辅助榜单记录数: ${context.auxiliaryPlatformRankingCount}');
    buffer.writeln('- 输出形态: 固定 3 个可直接开书的创作方案，不要只写市场策略。');
    buffer.writeln('- 三个角色按顺序固定：方向 1 稳妥热题，方向 2 相邻变体，方向 3 高风险高收益。');
    buffer.writeln('- 证据优先级: 目标平台数据为主；跨平台数据只可作为辅助旁证。');
    if (context.genreQuery != null) {
      buffer.writeln('- 题材边界: 严格围绕“${context.genreQuery}”，允许相邻变体，但不得漂移到无关大类。');
    }
    buffer.writeln();

    buffer.writeln('## 平台命名与简介规则');
    buffer.writeln(_platformRules(context.targetPlatform));
    buffer.writeln();

    _writeGenreHeat(buffer, metrics);
    _writeWordCountDistribution(buffer, metrics);
    _writeCompetitionDensity(buffer, metrics);
    _writeOpportunities(buffer, metrics);
    _writeRepresentativeSamples(buffer, context);
    _writeAuxiliarySamples(buffer, context);

    buffer.writeln('## 输出要求复核');
    buffer.writeln('- 必须输出 YAML front matter + Markdown。');
    buffer.writeln('- 禁止 JSON。');
    buffer.writeln(
      '- directions 固定 3 个，direction_role 必须依次为 稳妥热题 / 相邻变体 / 高风险高收益。',
    );
    buffer.writeln('- 每个方向必须有 3 个候选书名。');
    buffer.writeln('- 每个 synopsis 必须是 120-220 字。');
    buffer.writeln('- 每个方向必须有主角、核心机制、前三章钩子、主冲突、第一个爽点和连载风险。');
    buffer.writeln('- market_validation 必须引用至少 2 个当前平台证据信号。');
    buffer.writeln('- target_platform 必须全部写 `${context.targetPlatform.name}`。');
    buffer.writeln('- Markdown 正文必须从 `# AI 推荐选题` 开始。');

    return buffer.toString();
  }

  String buildRepairPrompt({
    required String invalidOutput,
    required String parseError,
    required MarketPlatform targetPlatform,
  }) {
    return '''
你正在修复 Market Scan AI 推荐输出。上一轮输出没有通过 YAML+MD 校验。

错误原因：
$parseError

硬性要求：
1. 最终输出必须直接从 `---` 开始。
2. 禁止 JSON，禁止代码围栏，禁止解释说明。
3. YAML front matter 顶层只能包含 format、target_platform、directions。
4. format 固定为 `persona.market_recommendations`。
5. target_platform 必须是 `${targetPlatform.name}`。
6. directions 必须固定为 3 个方向。
7. direction_role 必须依次为 稳妥热题 / 相邻变体 / 高风险高收益。
8. 每个方向必须有 3 个候选书名，suggested_title 必须来自候选之一。
9. 每个方向必须有 protagonist、core_mechanism、first_three_chapters_hook、main_conflict、first_payoff、serial_risk。
10. synopsis 必须为 120-220 字。
11. YAML 后的 Markdown 正文必须从 `# AI 推荐选题` 开始。

请保留上一轮中可用的内容，只修复格式、字段、长度和质量问题。

上一轮输出：
$invalidOutput
''';
  }

  String buildQualityRepairPrompt({
    required String invalidOutput,
    required List<String> qualityErrors,
    required RecommendationPromptContext context,
  }) {
    final evidenceTokens = context.targetEvidenceTokens.take(24).join(' / ');
    return '''
你正在重写 Market Scan AI 推荐输出。上一轮格式已接近正确，但创作方案质量没有达标。

质量问题：
${qualityErrors.map((error) => '- $error').join('\n')}

必须重写为可直接开书的 3 个方向：
1. direction_role 依次为：稳妥热题、相邻变体、高风险高收益。
2. 每个方向都必须包含主角、核心机制、前三章钩子、主冲突、第一个爽点、连载风险。
3. market_validation 必须至少引用 2 个当前平台证据信号。可用证据信号包括：
$evidenceTokens
4. 目标平台 `${context.targetPlatform.name}` 的数据是主证据；跨平台数据只能做辅助。
${context.genreQuery == null ? '' : '5. 必须严格围绕核心题材“${context.genreQuery}”，只允许相邻变体。'}

只输出修复后的 YAML front matter + Markdown，直接从 `---` 开始。禁止 JSON、代码围栏、解释说明。

上一轮输出：
$invalidOutput
''';
  }

  String get systemPrompt => _systemPrompt;

  void _writeGenreHeat(StringBuffer buffer, MarketMetrics metrics) {
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
  }

  void _writeWordCountDistribution(StringBuffer buffer, MarketMetrics metrics) {
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
  }

  void _writeCompetitionDensity(StringBuffer buffer, MarketMetrics metrics) {
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
  }

  void _writeOpportunities(StringBuffer buffer, MarketMetrics metrics) {
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
    buffer.writeln();
  }

  void _writeRepresentativeSamples(
    StringBuffer buffer,
    RecommendationPromptContext context,
  ) {
    buffer.writeln('## 当前平台代表样本（主证据）');
    if (context.samples.isEmpty) {
      buffer.writeln('暂无可展示样本；只能基于统计指标输出，并在可行性中标注样本不足。');
    } else {
      for (final sample in context.samples.take(24)) {
        buffer.writeln(
          '### #${sample.rank} ${sample.title}（${sample.chartName}）',
        );
        buffer.writeln('- 作者: ${sample.author}');
        buffer.writeln('- 来源权重: ${sample.sourceRole}');
        buffer.writeln('- 标签: ${sample.combinedTags.join(" / ")}');
        buffer.writeln(
          '- 字数: ${sample.totalWordCount > 0 ? sample.totalWordCount : '未知'}',
        );
        if (sample.description.trim().isNotEmpty) {
          buffer.writeln('- 简介摘要: ${_truncate(sample.description, 110)}');
        }
      }
    }
    buffer.writeln();
  }

  void _writeAuxiliarySamples(
    StringBuffer buffer,
    RecommendationPromptContext context,
  ) {
    buffer.writeln('## 跨平台辅助样本（只作旁证）');
    if (context.auxiliarySamples.isEmpty) {
      buffer.writeln('暂无跨平台辅助样本。');
    } else {
      for (final sample in context.auxiliarySamples.take(8)) {
        buffer.writeln(
          '### #${sample.rank} ${sample.title}（${_platformLabel(sample.platform)} · ${sample.chartName}）',
        );
        buffer.writeln('- 标签: ${sample.combinedTags.join(" / ")}');
        if (sample.description.trim().isNotEmpty) {
          buffer.writeln('- 简介摘要: ${_truncate(sample.description, 90)}');
        }
      }
    }
    buffer.writeln();
  }

  String _platformRules(MarketPlatform platform) {
    return switch (platform) {
      MarketPlatform.qidian =>
        '- 起点：轻度反差 + 金手指/能力 + 主线目标 + 爽点暗示。不要文艺空泛，内容必须贴合书名承诺。',
      MarketPlatform.fanqie =>
        '- 番茄：噱头优先、强标签、快节奏、强情绪或强脑洞。书名要直接吸量，简介要快速给安全感和爽点。',
    };
  }

  String _platformLabel(MarketPlatform platform) {
    return switch (platform) {
      MarketPlatform.qidian => '起点中文网',
      MarketPlatform.fanqie => '番茄小说',
    };
  }

  String _truncate(String text, int maxLength) {
    final trimmed = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    final runes = trimmed.runes.toList(growable: false);
    if (runes.length <= maxLength) {
      return trimmed;
    }
    return '${String.fromCharCodes(runes.take(maxLength - 1))}…';
  }
}

class RecommendationPromptContext {
  const RecommendationPromptContext({
    required this.targetPlatform,
    required this.genreQuery,
    required this.platformBookCount,
    required this.platformRankingCount,
    required this.auxiliaryPlatformBookCount,
    required this.auxiliaryPlatformRankingCount,
    required this.samples,
    required this.auxiliarySamples,
  });

  final MarketPlatform targetPlatform;
  final String? genreQuery;
  final int platformBookCount;
  final int platformRankingCount;
  final int auxiliaryPlatformBookCount;
  final int auxiliaryPlatformRankingCount;
  final List<RecommendationPromptSample> samples;
  final List<RecommendationPromptSample> auxiliarySamples;

  List<String> get targetEvidenceTokens {
    final output = <String>[];
    void add(String value) {
      final normalized = value.trim();
      if (normalized.length >= 2 && !output.contains(normalized)) {
        output.add(normalized);
      }
    }

    for (final sample in samples) {
      add(sample.chartName);
      add(sample.chartFamily);
      add(sample.title);
      for (final tag in sample.combinedTags) {
        add(tag);
      }
    }
    return output;
  }
}

class RecommendationPromptSample {
  const RecommendationPromptSample({
    required this.platform,
    required this.title,
    required this.author,
    required this.categories,
    required this.tags,
    required this.totalWordCount,
    required this.description,
    required this.chartName,
    required this.rank,
  });

  final MarketPlatform platform;
  final String title;
  final String author;
  final List<String> categories;
  final List<String> tags;
  final int totalWordCount;
  final String description;
  final String chartName;
  final int rank;

  String get chartFamily {
    if (chartName.contains('巅峰')) return '巅峰榜';
    if (chartName.contains('阅读')) return '阅读榜';
    if (chartName.contains('新书') || chartName.contains('新人')) return '新书榜';
    if (chartName.contains('推荐位')) return '首页推荐位';
    if (chartName.contains('畅销')) return '畅销榜';
    if (chartName.contains('月票')) return '月票榜';
    return chartName;
  }

  String get sourceRole {
    if (chartName.contains('推荐位')) {
      return '低权重推荐位样本';
    }
    if (chartName.contains('巅峰')) {
      return '高权重平台头部榜';
    }
    if (chartName.contains('阅读') ||
        chartName.contains('畅销') ||
        chartName.contains('月票')) {
      return '高权重主榜';
    }
    if (chartName.contains('新书') || chartName.contains('新人')) {
      return '新书趋势证据';
    }
    return '普通榜单证据';
  }

  List<String> get combinedTags {
    final output = <String>[];
    for (final item in [...categories, ...tags]) {
      final normalized = item.trim();
      if (normalized.isNotEmpty && !output.contains(normalized)) {
        output.add(normalized);
      }
    }
    return output;
  }
}
