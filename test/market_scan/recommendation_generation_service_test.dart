import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/core/llm/application/llm_invocation_service.dart';
import 'package:persona_flutter/src/core/llm/application/markdown_completion_service.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_client.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_message.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_request.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_stream_event.dart';
import 'package:persona_flutter/src/features/market_scan/application/recommendation_direction_document_parser.dart';
import 'package:persona_flutter/src/features/market_scan/application/recommendation_generation_service.dart';
import 'package:persona_flutter/src/features/market_scan/application/rule_engine.dart';
import 'package:persona_flutter/src/features/market_scan/domain/market_book.dart';
import 'package:persona_flutter/src/features/market_scan/domain/market_ranking.dart';
import 'package:persona_flutter/src/features/market_scan/domain/market_scan_repository.dart';
import 'package:persona_flutter/src/features/market_scan/domain/market_scan_run.dart';
import 'package:persona_flutter/src/features/market_scan/domain/recommendation_generation_request.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config.dart';
import 'package:persona_flutter/src/features/settings/domain/provider_config_repository.dart';

void main() {
  test('generate parses YAML+MD recommendation document', () async {
    final harness = _buildHarness([_validDocument()]);

    final directions = await harness.service.generate(
      request: const RecommendationGenerationRequest(
        targetPlatform: MarketPlatform.qidian,
        genreQuery: '悬疑',
      ),
    );

    expect(directions, hasLength(3));
    expect(directions.first.suggestedTitle, '雾港回声');
    expect(directions.first.titleCandidates, hasLength(3));
    expect(directions.first.targetPlatform, MarketPlatform.qidian);
    expect(directions.first.synopsis.runes.length, greaterThanOrEqualTo(120));
    expect(directions.first.synopsis.runes.length, lessThanOrEqualTo(220));
    expect(directions.first.detailMarkdown, startsWith('## 方向 1：雾港回声'));

    final systemPrompt = harness.client.requests.first.messages
        .singleWhere((message) => message.role == LlmMessageRole.system)
        .content;
    expect(systemPrompt, contains('YAML front matter'));
    expect(systemPrompt, contains('禁止 JSON'));
    expect(systemPrompt, contains('120-220 字'));
    expect(systemPrompt, contains('3 个候选书名'));
    expect(systemPrompt, isNot(contains('JSON 数组')));
    expect(systemPrompt, isNot(contains('20-40字')));
  });

  test('generate repairs JSON output once before parsing', () async {
    final harness = _buildHarness(['[{"bad":"json"}]', _validDocument()]);

    final directions = await harness.service.generate(
      request: const RecommendationGenerationRequest(
        targetPlatform: MarketPlatform.qidian,
      ),
    );

    expect(directions, hasLength(3));
    expect(harness.client.requests, hasLength(2));
    expect(
      harness.client.requests.last.messages.last.content,
      contains('上一轮输出'),
    );
    expect(
      harness.client.requests.last.messages.last.content,
      contains('禁止 JSON'),
    );
  });

  test('parser rejects missing YAML delimiter', () {
    expect(
      () => const RecommendationDirectionDocumentParser().parse(
        markdown: '# AI 推荐选题\n\n无 YAML。',
        expectedPlatform: MarketPlatform.qidian,
      ),
      throwsA(isA<RecommendationDirectionValidationException>()),
    );
  });

  test('parser rejects generic recommendation titles', () {
    expect(
      () => const RecommendationDirectionDocumentParser().parse(
        markdown: _validDocument(titleOverride: '都市悬疑方向'),
        expectedPlatform: MarketPlatform.qidian,
      ),
      throwsA(
        predicate(
          (error) =>
              error is RecommendationDirectionValidationException &&
              error.toString().contains('过于泛化'),
        ),
      ),
    );
  });

  test('parser rejects suggested title outside title candidates', () {
    expect(
      () => const RecommendationDirectionDocumentParser().parse(
        markdown: _validDocument(suggestedTitleOverride: '不在候选里'),
        expectedPlatform: MarketPlatform.qidian,
      ),
      throwsA(
        predicate(
          (error) =>
              error is RecommendationDirectionValidationException &&
              error.toString().contains('suggested_title 必须来自'),
        ),
      ),
    );
  });

  test('parser rejects short synopsis', () {
    expect(
      () => const RecommendationDirectionDocumentParser().parse(
        markdown: _validDocument(synopsisOverride: '旧案重启，主角追查真相。'),
        expectedPlatform: MarketPlatform.qidian,
      ),
      throwsA(
        predicate(
          (error) =>
              error is RecommendationDirectionValidationException &&
              error.toString().contains('synopsis 必须为'),
        ),
      ),
    );
  });
}

_RecommendationHarness _buildHarness(List<String> outputs) {
  final client = _QueuedLlmClient(outputs);
  final repository = _FakeMarketScanRepository();
  return _RecommendationHarness(
    client: client,
    service: RecommendationGenerationService(
      ruleEngine: RuleEngine(repository),
      marketRepository: repository,
      completionService: MarkdownCompletionService(
        invocation: LlmInvocationService(client: client),
      ),
      providerRepository: _FakeProviderConfigRepository(_provider()),
    ),
  );
}

ProviderConfig _provider() {
  final now = DateTime.utc(2026, 6, 6);
  return ProviderConfig(
    id: 'provider-1',
    name: 'Test Provider',
    baseUrl: 'https://example.test',
    apiKey: 'test-key',
    defaultModel: 'test-model',
    systemPrompt: '',
    isEnabled: true,
    testStatus: ProviderTestStatus.succeeded,
    createdAt: now,
    updatedAt: now,
  );
}

class _RecommendationHarness {
  const _RecommendationHarness({required this.client, required this.service});

  final _QueuedLlmClient client;
  final RecommendationGenerationService service;
}

class _QueuedLlmClient implements LlmClient {
  _QueuedLlmClient(this.outputs);

  final List<String> outputs;
  final requests = <LlmRequest>[];
  var index = 0;

  @override
  Stream<LlmStreamEvent> streamChat({
    required ProviderConfig provider,
    required LlmRequest request,
  }) async* {
    requests.add(request);
    final outputIndex = index >= outputs.length ? outputs.length - 1 : index;
    final output = outputs[outputIndex];
    index += 1;
    yield LlmStreamDelta(output);
    yield const LlmStreamDone();
  }
}

class _FakeProviderConfigRepository implements ProviderConfigRepository {
  const _FakeProviderConfigRepository(this.provider);

  final ProviderConfig provider;

  @override
  Stream<List<ProviderConfig>> watchProviders() => Stream.value([provider]);

  @override
  Future<void> saveProvider({
    String? id,
    required ProviderConfigInput input,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteProvider(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<ProviderConfig?> findProvider(String id) async {
    throw UnimplementedError();
  }

  @override
  Stream<ProviderConfig?> watchProvider(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateTestResult({
    required String id,
    required ProviderTestStatus status,
    required DateTime testedAt,
    String? message,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateSystemPrompt({
    required String id,
    required String systemPrompt,
    bool? isSystemPromptEnabled,
  }) async {
    throw UnimplementedError();
  }
}

class _FakeMarketScanRepository implements MarketScanRepository {
  _FakeMarketScanRepository() {
    final now = DateTime.now();
    books = [
      MarketBook(
        id: 'book-1',
        platform: MarketPlatform.qidian,
        platformBookId: 'qidian-1',
        title: '旧港谜案录',
        author: '作者甲',
        description: '退役调查员回到旧港区，发现所有旧案证据都被一套时间档案系统改写。',
        categories: const ['悬疑', '都市'],
        tags: const ['强剧情', '时间诡计'],
        totalWordCount: 860000,
        firstPublishDate: now.subtract(const Duration(days: 10)),
        createdAt: now,
        updatedAt: now,
      ),
      MarketBook(
        id: 'book-2',
        platform: MarketPlatform.qidian,
        platformBookId: 'qidian-2',
        title: '档案归零',
        author: '作者乙',
        categories: const ['悬疑', '科幻'],
        tags: const ['记忆改写'],
        totalWordCount: 1200000,
        firstPublishDate: now.subtract(const Duration(days: 20)),
        createdAt: now,
        updatedAt: now,
      ),
      MarketBook(
        id: 'book-3',
        platform: MarketPlatform.qidian,
        platformBookId: 'qidian-3',
        title: '夜巡者名单',
        author: '作者丙',
        categories: const ['都市', '异能'],
        tags: const ['调查员'],
        totalWordCount: 980000,
        firstPublishDate: now.subtract(const Duration(days: 30)),
        createdAt: now,
        updatedAt: now,
      ),
    ];
    rankings = [
      for (var i = 0; i < books.length; i += 1)
        MarketRanking(
          id: 'ranking-$i',
          bookId: books[i].id,
          chartName: '月榜',
          rank: i + 1,
          runId: 'run-1',
          scrapedAt: now,
          createdAt: now,
          updatedAt: now,
        ),
    ];
  }

  late final List<MarketBook> books;
  late final List<MarketRanking> rankings;

  @override
  Future<List<MarketBook>> findBooks({MarketPlatform? platform}) async {
    return books
        .where((book) => platform == null || book.platform == platform)
        .toList(growable: false);
  }

  @override
  Future<List<MarketRanking>> findLatestRankings({
    MarketPlatform? platform,
  }) async {
    if (platform == null) {
      return rankings;
    }
    final bookIds = books
        .where((book) => book.platform == platform)
        .map((book) => book.id)
        .toSet();
    return rankings
        .where((ranking) => bookIds.contains(ranking.bookId))
        .toList(growable: false);
  }

  @override
  Future<MarketBook> upsertBook(MarketBookInput input) async {
    throw UnimplementedError();
  }

  @override
  Future<int> upsertBooks(List<MarketBookInput> inputs) async {
    throw UnimplementedError();
  }

  @override
  Future<List<MarketRanking>> findRankings({
    required String runId,
    String? chartName,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> insertRankings(List<MarketRankingInput> inputs) async {
    throw UnimplementedError();
  }

  @override
  Future<List<MarketScanRun>> findRuns({int? limit}) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, MarketScanRun>> findLatestCompletedRuns() async {
    throw UnimplementedError();
  }

  @override
  Future<MarketScanRun> createRun(String platform) async {
    throw UnimplementedError();
  }

  @override
  Future<void> completeRun({
    required String runId,
    required int itemCount,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> failRun({
    required String runId,
    required String errorMessage,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> hasData() async => true;

  @override
  Future<void> clearAllData() async {
    throw UnimplementedError();
  }

  @override
  Future<void> cleanupOldRuns({int retainCount = 10}) async {
    throw UnimplementedError();
  }
}

String _validDocument({
  String titleOverride = '雾港回声',
  String suggestedTitleOverride = '雾港回声',
  String? synopsisOverride,
}) {
  final synopsis =
      synopsisOverride ??
      '退役调查员林砚被迫回到旧港区，接手一桩十年前已经结案的连环失踪案，却发现所有证词都被一套会自动改写记忆的档案系统覆盖。他能读取每次改写前残留的三分钟真相，于是用废弃码头、医院旧账和榜上热议的时间诡计逐步反杀幕后组织，并必须在下一轮全城失忆前公开第一名受害者的真实身份。';
  return '''
---
format: persona.market_recommendations
target_platform: qidian
directions:
  - suggested_title: $suggestedTitleOverride
    title_candidates:
      - title: $titleOverride
        formula: 意境地名+悬疑钩子
        rationale: 兼顾起点悬疑感和主线地点，辨识度最高。
      - title: 旧港档案
        formula: 地点+核心物件
        rationale: 直接交代案件抓手，适合强剧情读者。
      - title: 归零证词
        formula: 反义词+案件证据
        rationale: 暗示记忆被清空，保留悬念。
    synopsis: $synopsis
    genre_tags: [都市悬疑, 时间诡计, 强剧情]
    target_word_count: 860000
    target_platform: qidian
    target_audience: 起点偏好强主线、案件推进和轻科幻设定的悬疑读者。
    core_selling_point: 主角用三分钟残留真相对抗会改写记忆的档案系统。
    market_heat_summary: 悬疑和都市标签在样本中重复出现，强剧情样本排名靠前。
    competition_summary: 同类新书密度适中，时间诡计可以提供差异化。
    market_validation: 当前平台样本中悬疑、都市、记忆改写反复出现，榜单排名稳定。
    differentiation: 不做纯刑侦，改用记忆档案系统制造连续反转。
    feasibility: 中
    failure_risk: 设定解释过多会拖慢前三章爽点。
    validation_action: 先写黄金三章，测试读者是否能在第一章理解能力规则。
  - suggested_title: 星桥债主
    title_candidates:
      - title: 星桥债主
        formula: 奇观物件+身份反差
        rationale: 用债主身份制造爽点和升级期待。
      - title: 我在星桥收旧债
        formula: 主角行动+奇观场景
        rationale: 更口语化，适合轻松爽文。
      - title: 万界欠我一张票
        formula: 夸张利益点+悬念
        rationale: 吸量强，但更偏番茄风。
    synopsis: 失业修理工周泊在废弃天文馆接到一张跨世界欠条，发现每座星桥都记录着被诸天势力赖掉的旧债。他能把欠条兑换成一次临时天赋，于是从追回第一笔机甲船票开始，连续拆穿宗门、财阀和异界商会的账本骗局，在读者熟悉的升级节奏里不断获得资源，并要证明自己不是被星桥选中的替罪羊。
    genre_tags: [科幻玄幻, 经营升级, 万界]
    target_word_count: 1200000
    target_platform: qidian
    target_audience: 喜欢经营、升级和跨世界资源博弈的起点男频读者。
    core_selling_point: 欠条兑换天赋，把讨债写成升级和资源争夺。
    market_heat_summary: 科幻、玄幻和都市能力样本均有热度，可组合成轻奇观。
    competition_summary: 万界题材竞争高，需要用讨债机制区别于普通系统文。
    market_validation: 样本中能力成长和强剧情标签稳定出现，适合长线展开。
    differentiation: 主角目标不是救世，而是逐笔追债，单元目标清晰。
    feasibility: 中
    failure_risk: 讨债单元容易重复，后期需要更强主线债务。
    validation_action: 先设计前三个债务单元，检查每个单元是否有不同爽点。
  - suggested_title: 夜巡名单
    title_candidates:
      - title: 夜巡名单
        formula: 职业行动+危险名单
        rationale: 简洁、有都市悬疑感，能承接夜间单元。
      - title: 城市只在夜里认罪
        formula: 场景拟人+情绪钩子
        rationale: 文案感强，但书名略偏文艺。
      - title: 第七盏路灯
        formula: 具体物件+悬念
        rationale: 有画面感，适合悬疑线索。
    synopsis: 外卖夜班骑手许让意外进入一份只在凌晨更新的夜巡名单，名单上的地点会在天亮前发生被掩盖的罪案。他能提前看见一分钟后的现场残影，于是从救下第一位被栽赃的女孩开始，把城中村、写字楼和医院的夜间秘密串成主线，用每晚一案的快节奏兑现爽点，并逐步逼近名单创造者的真实目的。
    genre_tags: [都市异能, 单元案件, 悬疑]
    target_word_count: 980000
    target_platform: qidian
    target_audience: 偏好都市代入、单元案件和能力成长的读者。
    core_selling_point: 夜班骑手用一分钟残影提前介入城市罪案。
    market_heat_summary: 都市、异能、悬疑标签可形成稳定读者预期。
    competition_summary: 都市异能拥挤，夜巡名单和骑手职业能提供入口差异。
    market_validation: 样本里都市与调查员相关标签重复，说明读者接受现实入口。
    differentiation: 用夜班职业串联案件，不从警察或侦探身份切入。
    feasibility: 中
    failure_risk: 单元案件如果和主线弱关联，会变成流水账。
    validation_action: 先写案件列表和主线线索表，确保每三章推进一次名单真相。
---
# AI 推荐选题

## 方向 1：雾港回声
### 能爆的原因
- 时间档案改写把悬疑案件和轻科幻爽点绑定。
### 市场验证
- 当前样本重复出现悬疑、都市、强剧情。
### 差异化定位
- 用记忆残留而不是普通刑侦推进。
### 风险与验证动作
- 先写黄金三章测试规则理解度。

## 方向 2：星桥债主
### 能爆的原因
- 讨债机制天然提供升级目标。
### 市场验证
- 能力成长样本具备长线承载。
### 差异化定位
- 把万界资源争夺写成债务回收。
### 风险与验证动作
- 先验证前三个单元不重复。

## 方向 3：夜巡名单
### 能爆的原因
- 夜班职业和城市罪案提供现实代入。
### 市场验证
- 都市、异能、悬疑标签有稳定读者预期。
### 差异化定位
- 从骑手视角切入城市夜间秘密。
### 风险与验证动作
- 先做主线线索表，避免单元流水账。
''';
}
