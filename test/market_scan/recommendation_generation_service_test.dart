import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/core/llm/application/llm_invocation_service.dart';
import 'package:persona_flutter/src/core/llm/application/markdown_completion_service.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_client.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_message.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_request.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_stream_event.dart';
import 'package:persona_flutter/src/features/market_scan/application/recommendation_direction_document_parser.dart';
import 'package:persona_flutter/src/features/market_scan/application/recommendation_generation_service.dart';
import 'package:persona_flutter/src/features/market_scan/application/recommendation_prompts.dart';
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
        targetPlatforms: [MarketPlatform.qidian],
        selectedGenres: ['悬疑'],
      ),
    );

    expect(directions, hasLength(6));
    expect(directions.first.suggestedTitle, '雾港回声');
    expect(directions.first.titleCandidates, hasLength(3));
    expect(directions.first.targetPlatform, MarketPlatform.qidian);
    expect(directions.first.synopsis.runes.length, greaterThanOrEqualTo(80));
    expect(directions.first.synopsis.runes.length, lessThanOrEqualTo(300));
    expect(directions.first.protagonist, contains('林砚'));
    expect(directions.first.coreMechanism, contains('三分钟真相'));
    expect(directions.first.firstThreeChaptersHook, contains('第三章'));
    expect(directions.first.mainConflict, contains('幕后组织'));
    expect(directions.first.firstPayoff, contains('女孩'));
    expect(directions.first.serialRisk, contains('公平性'));
    expect(directions.first.detailMarkdown, startsWith('## 方向 1：雾港回声'));

    final systemPrompt = harness.client.requests.first.messages
        .singleWhere((message) => message.role == LlmMessageRole.system)
        .content;
    expect(systemPrompt, contains('YAML front matter'));
    expect(systemPrompt, contains('禁止 JSON'));
    expect(systemPrompt, contains('80-300'));
    expect(systemPrompt, contains('3 个候选书名'));
    expect(systemPrompt, contains('6 个方向'));
    expect(systemPrompt, contains('first_three_chapters_hook'));
    expect(systemPrompt, isNot(contains('JSON 数组')));
    expect(systemPrompt, isNot(contains('20-40字')));
  });

  test('generate repairs JSON output once before parsing', () async {
    final harness = _buildHarness(['[{"bad":"json"}]', _validDocument()]);

    final directions = await harness.service.generate(
      request: const RecommendationGenerationRequest(
        targetPlatforms: [MarketPlatform.qidian],
      ),
    );

    expect(directions, hasLength(6));
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

  test('generate rewrites parsed output when quality gate fails', () async {
    final harness = _buildHarness([_lowQualityDocument(), _validDocument()]);

    final directions = await harness.service.generate(
      request: const RecommendationGenerationRequest(
        targetPlatforms: [MarketPlatform.qidian],
      ),
    );

    expect(directions, hasLength(6));
    expect(harness.client.requests, hasLength(2));
    final repairPrompt = harness.client.requests.last.messages.last.content;
    expect(repairPrompt, contains('质量问题'));
    expect(repairPrompt, contains('market_validation'));
    expect(repairPrompt, contains('6 个方向'));
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

  test('parser rejects document with wrong number of directions', () {
    final threeDirectionDoc = _validDocument().replaceAll(
      RegExp(r'  - suggested_title: 星桥债主[\s\S]*validation_action: .+(?=\n---)'),
      '',
    );
    expect(
      () => const RecommendationDirectionDocumentParser().parse(
        markdown: threeDirectionDoc,
        expectedPlatform: MarketPlatform.qidian,
      ),
      throwsA(
        predicate(
          (error) =>
              error is RecommendationDirectionValidationException &&
              error.toString().contains('6'),
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
              error.toString().contains('80-300'),
        ),
      ),
    );
  });

  test('parser accepts feasibility with qualifiers and stores normalized value',
      () {
    final raw = _validDocument().replaceAll(
      'feasibility: 中',
      'feasibility: 中（推荐）',
    );
    final directions = const RecommendationDirectionDocumentParser().parse(
      markdown: raw,
      expectedPlatform: MarketPlatform.qidian,
    );
    expect(directions.first.feasibility, '中');
  });

  test('parser normalizes 较高 / 中等 / 较低 to standard levels', () {
    final parsed = const RecommendationDirectionDocumentParser();
    final base = _validDocument();

    final upHigh = base.replaceAll('feasibility: 中', 'feasibility: 较高');
    expect(
      parsed
          .parse(markdown: upHigh, expectedPlatform: MarketPlatform.qidian)
          .first
          .feasibility,
      '高',
    );

    final medium = base.replaceAll('feasibility: 中', 'feasibility: 中等');
    expect(
      parsed
          .parse(markdown: medium, expectedPlatform: MarketPlatform.qidian)
          .first
          .feasibility,
      '中',
    );

    final downLow = base.replaceAll('feasibility: 中', 'feasibility: 较低');
    expect(
      parsed
          .parse(markdown: downLow, expectedPlatform: MarketPlatform.qidian)
          .first
          .feasibility,
      '低',
    );
  });

  test('parser rejects feasibility that does not map to a level', () {
    final raw = _validDocument().replaceAll(
      'feasibility: 中',
      'feasibility: 不确定',
    );
    expect(
      () => const RecommendationDirectionDocumentParser().parse(
        markdown: raw,
        expectedPlatform: MarketPlatform.qidian,
      ),
      throwsA(
        predicate(
          (error) =>
              error is RecommendationDirectionValidationException &&
              error.toString().contains('feasibility'),
        ),
      ),
    );
  });

  test('user prompt no longer embeds heatScore / densityScore / '
      'opportunityScore / appearanceCount / averageRank', () {
    final harness = _buildHarness([_validDocument()]);
    final systemPrompt = harness.client.requests.first.messages
        .singleWhere((message) => message.role == LlmMessageRole.system)
        .content;
    final userPrompt = harness.client.requests.first.messages.last.content;

    for (final token in const [
      'heatScore',
      'densityScore',
      'opportunityScore',
      'appearanceCount',
      'averageRank',
      '题材热度排名',
      '竞品密度',
      '市场机会评分',
    ]) {
      expect(systemPrompt, isNot(contains(token)),
          reason: 'system prompt 不应再含 $token');
      expect(userPrompt, isNot(contains(token)),
          reason: 'user prompt 不应再含 $token');
    }
  });

  test('buildRepairPrompt lists actionable fix per error', () {
    const prompts = RecommendationPrompts();
    final repair = prompts.buildRepairPrompt(
      invalidOutput: '--- previous broken output ---',
      parseError: '第 1 个推荐方向的 feasibility 必须是 高/中/低。',
      targetPlatform: MarketPlatform.qidian,
    );
    expect(repair, contains('feasibility'));
    expect(repair, contains('80-300'));
    expect(repair, contains('上一轮输出'));
    expect(repair, contains('禁止 JSON'));
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
    protagonist: 退役调查员林砚，被旧港十年前失踪案拖回现场，只想证明自己没有办错案。
    core_mechanism: 主角能读取每次记忆改写前残留的三分钟真相，但每次读取都会暴露自己的位置。
    first_three_chapters_hook: 第一章旧案证词变空白，第二章码头残影指出新受害者，第三章主角反用残影救人后被系统标记。
    main_conflict: 主角必须在全城记忆被重置前，拆穿控制档案系统的幕后组织。
    first_payoff: 第一名被栽赃的女孩在第三章获救，主角当场反杀伪造证词的人。
    genre_tags: [都市悬疑, 时间诡计, 强剧情]
    target_word_count: 860000
    target_platform: qidian
    target_audience: 起点偏好强主线、案件推进和轻科幻设定的悬疑读者。
    core_selling_point: 主角用三分钟残留真相对抗会改写记忆的档案系统。
    market_heat_summary: 悬疑和都市标签在样本中重复出现，强剧情样本排名靠前。
    competition_summary: 同类新书密度适中，时间诡计可以提供差异化。
    market_validation: 当前平台月榜样本《旧港谜案录》和《档案归零》都带悬疑信号，都市、强剧情、记忆改写标签重复出现。
    differentiation: 不做纯刑侦，改用记忆档案系统制造连续反转。
    feasibility: 中
    failure_risk: 设定解释过多会拖慢前三章爽点。
    serial_risk: 记忆改写规则如果不断加码，容易让案件推理失去公平性。
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
    protagonist: 失业修理工周泊，欠债缠身但熟悉旧设备维修，第一目标是拿回被赖掉的工资。
    core_mechanism: 每张跨世界欠条都能兑换一次临时天赋，讨回债务后转化为长期升级资源。
    first_three_chapters_hook: 第一章发现星桥欠条，第二章用临时天赋修好废机甲，第三章讨回第一笔船票债并解锁债务名单。
    main_conflict: 主角要追完诸天旧债，同时查清星桥为何把他设成唯一债权人。
    first_payoff: 主角用一张欠条逆转追债现场，从被赶走的修理工变成掌握机甲启动权的人。
    genre_tags: [科幻玄幻, 经营升级, 万界]
    target_word_count: 1200000
    target_platform: qidian
    target_audience: 喜欢经营、升级和跨世界资源博弈的起点男频读者。
    core_selling_point: 欠条兑换天赋，把讨债写成升级和资源争夺。
    market_heat_summary: 科幻、玄幻和都市能力样本均有热度，可组合成轻奇观。
    competition_summary: 万界题材竞争高，需要用讨债机制区别于普通系统文。
    market_validation: 当前平台月榜里《旧港谜案录》的强剧情和《档案归零》的记忆改写证明机制型悬念可跑长线，科幻标签也有样本支撑。
    differentiation: 主角目标不是救世，而是逐笔追债，单元目标清晰。
    feasibility: 中
    failure_risk: 讨债单元容易重复，后期需要更强主线债务。
    serial_risk: 债务单元如果只有换地图，会削弱升级线和主线债主身份的粘性。
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
    protagonist: 夜班骑手许让，熟悉城市暗巷和楼宇动线，只想还清母亲住院费。
    core_mechanism: 凌晨名单会刷新将要出事的地点，主角能看到一分钟后的现场残影。
    first_three_chapters_hook: 第一章名单点亮城中村，第二章残影显示女孩被栽赃，第三章主角用送餐路线提前截住真凶。
    main_conflict: 主角要在每晚名单刷新中救人，同时查清名单创造者为什么选择他。
    first_payoff: 第三章主角利用一分钟残影救下受害者，并拿到第一条指向幕后人的线索。
    genre_tags: [都市异能, 单元案件, 悬疑]
    target_word_count: 980000
    target_platform: qidian
    target_audience: 偏好都市代入、单元案件和能力成长的读者。
    core_selling_point: 夜班骑手用一分钟残影提前介入城市罪案。
    market_heat_summary: 都市、异能、悬疑标签可形成稳定读者预期。
    competition_summary: 都市异能拥挤，夜巡名单和骑手职业能提供入口差异。
    market_validation: 当前平台月榜样本《旧港谜案录》包含都市、悬疑、强剧情信号，《夜巡者名单》也验证调查员式现实入口可读。
    differentiation: 用夜班职业串联案件，不从警察或侦探身份切入。
    feasibility: 中
    failure_risk: 单元案件如果和主线弱关联，会变成流水账。
    serial_risk: 每晚一案容易变成重复救场，必须每三章推进名单真相。
    validation_action: 先写案件列表和主线线索表，确保每三章推进一次名单真相。
  - suggested_title: 深海信号
    title_candidates:
      - title: 深海信号
        formula: 环境+悬念物件
        rationale: 海洋场景加信号谜题，兼具奇观感和悬疑张力。
      - title: 深渊回声
        formula: 意象+声音线索
        rationale: 暗示深海不可见世界的回声，保留悬念。
      - title: 72小时声呐
        formula: 时间限制+核心道具
        rationale: 直接传递能力规则和时间紧迫感。
    synopsis: 海洋声呐工程师沈潮在一次深海勘探中截获一段来自72小时后的声呐回波，发现每段信号都预示一场即将发生的海上事故。他能把回波拆解成具体坐标和时间，于是从阻止第一次钻井平台泄漏开始，在远洋货轮、海底实验室和废弃潜艇之间追踪信号源头，并必须在信号指向的最后一场灾难前揭开海底数据中心的真正用途。
    protagonist: 声呐工程师沈潮，常年驻守海上平台，只想查清父亲十年前在海难中失踪的真相。
    core_mechanism: 主角能截获来自72小时后的声呐回波，每段回波预示一场海上事故的具体位置和时间。
    first_three_chapters_hook: 第一章截获异常回波并验证第一次预兆，第二章用坐标阻止钻井平台泄漏，第三章发现回波中藏着父亲失踪海域的编码。
    main_conflict: 主角要在72小时窗口内阻止连环海上事故，同时追查信号源头背后操控海底数据中心的组织。
    first_payoff: 主角用声呐回波提前定位事故现场，救下整船船员并拿到第一条指向幕后人的深海坐标。
    genre_tags: [科幻悬疑, 海洋冒险, 强剧情]
    target_word_count: 900000
    target_platform: qidian
    target_audience: 偏好技术流悬疑、海洋奇观和强主线推进的起点读者。
    core_selling_point: 声呐工程师用未来回波阻止海上灾难，技术细节硬核且爽点密集。
    market_heat_summary: 科幻悬疑标签在样本中持续出现，海洋题材提供差异化入口。
    competition_summary: 海洋题材新书较少，声呐工程师职业设定可形成辨识度。
    market_validation: 当前平台月榜样本《旧港谜案录》的强剧情和《档案归零》的机制型悬念证明技术流悬疑有稳定读者基础。
    differentiation: 不做传统刑侦或都市异能，用海洋声呐技术制造信息差和连续反转。
    feasibility: 中
    failure_risk: 技术设定解释过多可能拖慢前三章节奏。
    serial_risk: 每次事故的救援模式如果重复，会削弱紧张感和读者期待。
    validation_action: 先写前三次事故救援，确保每次都有不同的技术手段和情感爽点。
  - suggested_title: 纸上江湖
    title_candidates:
      - title: 纸上江湖
        formula: 载体+意象世界
        rationale: 古书载体暗示隐藏世界，兼顾文化感和悬疑感。
      - title: 残卷猎人
        formula: 身份+行动
        rationale: 直接传递主角职业和行动线，适合强剧情读者。
      - title: 字里藏刀
        formula: 成语变体+危险暗示
        rationale: 暗示文字中隐藏杀机，保留悬念和文化底蕴。
    synopsis: 古籍修复师顾九辞在修补一本明代残卷时发现夹层中藏着一份活的江湖名册，名册上的人物至今仍在暗中活动。她能通过修复不同古书触发名册上的线索更新，于是从追查第一桩与残卷关联的现代失踪案开始，在拍卖行、私人藏书楼和地下书商之间拼凑真相，并必须在名册最后一页被销毁前揭露操控古籍流通网络的幕后势力。
    protagonist: 古籍修复师顾九辞，师承老一辈修复名家，只想守住师父留下的修复工坊。
    core_mechanism: 每修复一本特定古书，名册上就会更新一条线索，指向当前仍在活动的江湖人物和未结悬案。
    first_three_chapters_hook: 第一章修复残卷触发名册更新，第二章线索指向一桩现代失踪案，第三章主角用古籍知识识破拍卖行伪造品并救下被追杀的书商。
    main_conflict: 主角要在名册被销毁前追完所有线索，同时查清谁在系统性地销毁与名册关联的古籍。
    first_payoff: 主角用修复技术还原被涂改的名册条目，当场揭露拍卖行内鬼并救下掌握关键残卷的线人。
    genre_tags: [文化悬疑, 古玩江湖, 强剧情]
    target_word_count: 850000
    target_platform: qidian
    target_audience: 偏好文化底蕴、悬疑推理和职业流的起点读者。
    core_selling_point: 古籍修复师用修复技术破解活的名册，把文化知识和悬疑爽点绑定。
    market_heat_summary: 文化悬疑和职业流标签在样本中有稳定热度，古玩题材提供差异化入口。
    competition_summary: 古玩鉴定类新书有一定密度，但古籍修复视角较为稀缺。
    market_validation: 当前平台月榜样本《旧港谜案录》的强剧情和职业代入感证明技术流主角有市场基础。
    differentiation: 不做传统鉴宝文，用修复技术和活名册制造连续悬疑线。
    feasibility: 中
    failure_risk: 古籍知识过多可能让非文化向读者失去耐心。
    serial_risk: 每本书修复触发线索的模式如果重复，会削弱新鲜感。
    validation_action: 先设计前四本古书和对应线索，确保每条线索推动不同层面的真相。
  - suggested_title: 倒计时棋盘
    title_candidates:
      - title: 倒计时棋盘
        formula: 时间机制+核心道具
        rationale: 直接传递紧迫感和博弈属性，吸引策略向读者。
      - title: 终局推演
        formula: 棋类术语+悬念
        rationale: 暗示终局博弈，保留悬疑和智力对抗感。
      - title: 每步都在倒数
        formula: 行动+紧迫感
        rationale: 口语化表达紧迫节奏，适合爽文读者。
    synopsis: 围棋天才陆弈在一次网络对局中被拉入一个实时倒计时棋盘，棋盘上每一步落子都会在现实中触发对应的事件。他能通过棋局推演提前48小时看到事件走向，于是从阻止第一起被棋局操控的商战阴谋开始，在地下棋局、金融暗盘和科技公司的博弈中反向追踪设局者，并必须在最后一手棋落下前揭开棋盘背后的真实赌注。
    protagonist: 围棋天才陆弈，因心理障碍退出职业棋坛，靠在网上下彩棋谋生。
    core_mechanism: 倒计时棋盘上的每步落子对应现实事件，主角能通过棋局推演提前48小时预判事件走向。
    first_three_chapters_hook: 第一章网络对局触发倒计时棋盘，第二章棋局推演验证第一次商战事件，第三章主角用反向落子救下被棋局锁定的举报人。
    main_conflict: 主角要在棋局终盘前破解设局者的真正意图，同时阻止棋盘操控的最后一场现实灾难。
    first_payoff: 主角用一手反直觉的弃子打破棋局预设路径，救下被锁定的举报人并拿到第一条指向设局者的线索。
    genre_tags: [都市悬疑, 智力博弈, 强剧情]
    target_word_count: 920000
    target_platform: qidian
    target_audience: 偏好智力对抗、策略博弈和都市悬疑的起点读者。
    core_selling_point: 围棋天才用棋局推演预判现实阴谋，每步棋都攸关人命和真相。
    market_heat_summary: 智力博弈和都市悬疑标签在样本中有交叉热度，棋类设定提供差异化。
    competition_summary: 棋类题材新书极少，倒计时机制和围棋推演可形成强辨识度。
    market_validation: 当前平台月榜样本《旧港谜案录》的强剧情和《夜巡者名单》的能力成长线证明机制型主角有长线承载力。
    differentiation: 不做传统系统文或重生文，用围棋推演和倒计时制造独特博弈感。
    feasibility: 中
    failure_risk: 棋局规则解释过多可能拖慢前三章爽点密度。
    serial_risk: 每次棋局对应现实事件的模式如果过于雷同，会削弱博弈新鲜感。
    validation_action: 先设计前三盘棋局和对应现实事件，确保每盘棋的策略维度不同。
---
# AI 推荐选题

## 方向 1：雾港回声
### 开书方案
- 主角：退役调查员林砚。
- 核心机制：三分钟残留真相。
- 前三章钩子：证词清空、码头残影、救人反杀。
### 能爆的原因
- 时间档案改写把悬疑案件和轻科幻爽点绑定。
### 市场验证
- 当前样本重复出现悬疑、都市、强剧情。
### 差异化定位
- 用记忆残留而不是普通刑侦推进。
### 风险与验证动作
- 先写黄金三章测试规则理解度。

## 方向 2：星桥债主
### 开书方案
- 主角：失业修理工周泊。
- 核心机制：欠条兑换临时天赋。
- 前三章钩子：欠条、机甲、第一笔债。
### 能爆的原因
- 讨债机制天然提供升级目标。
### 市场验证
- 能力成长样本具备长线承载。
### 差异化定位
- 把万界资源争夺写成债务回收。
### 风险与验证动作
- 先验证前三个单元不重复。

## 方向 3：夜巡名单
### 开书方案
- 主角：夜班骑手许让。
- 核心机制：凌晨名单和一分钟残影。
- 前三章钩子：名单刷新、残影救人、幕后线索。
### 能爆的原因
- 夜班职业和城市罪案提供现实代入。
### 市场验证
- 都市、异能、悬疑标签有稳定读者预期。
### 差异化定位
- 从骑手视角切入城市夜间秘密。
### 风险与验证动作
- 先做主线线索表，避免单元流水账。

## 方向 4：深海信号
### 开书方案
- 主角：声呐工程师沈潮。
- 核心机制：72小时后声呐回波预判海上事故。
- 前三章钩子：异常回波、钻井平台救援、父亲海域编码。
### 能爆的原因
- 海洋声呐技术制造信息差，硬核且爽点密集。
### 市场验证
- 科幻悬疑标签持续出现，海洋题材提供差异化入口。
### 差异化定位
- 用海洋技术流悬疑替代传统刑侦或都市异能。
### 风险与验证动作
- 先写前三次事故救援，确保技术和情感爽点不重复。

## 方向 5：纸上江湖
### 开书方案
- 主角：古籍修复师顾九辞。
- 核心机制：修复古书触发活名册线索更新。
- 前三章钩子：残卷夹层、失踪案关联、拍卖行识伪。
### 能爆的原因
- 古籍修复知识和悬疑线绑定，文化底蕴加爽点。
### 市场验证
- 文化悬疑和职业流标签有稳定热度。
### 差异化定位
- 用修复技术和活名册替代传统鉴宝文套路。
### 风险与验证动作
- 先设计前四本古书和线索，控制知识密度。

## 方向 6：倒计时棋盘
### 开书方案
- 主角：围棋天才陆弈。
- 核心机制：棋局落子对应现实事件，提前48小时推演。
- 前三章钩子：倒计时触发、商战验证、弃子救举报人。
### 能爆的原因
- 围棋推演和倒计时制造独特智力博弈感。
### 市场验证
- 智力博弈和都市悬疑标签有交叉热度。
### 差异化定位
- 用棋局博弈替代传统系统文或重生文套路。
### 风险与验证动作
- 先设计前三盘棋局，确保策略维度各不相同。
''';
}

String _lowQualityDocument() {
  return _validDocument().replaceAll(
    RegExp(r'market_validation: .+'),
    'market_validation: 样本支持，值得尝试。',
  );
}
