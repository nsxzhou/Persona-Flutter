import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:persona_flutter/src/core/database/app_database.dart';
import 'package:persona_flutter/src/core/theme/app_theme.dart';
import 'package:persona_flutter/src/features/market_scan/application/market_recommendation_controller.dart';
import 'package:persona_flutter/src/features/market_scan/application/market_scan_controller.dart';
import 'package:persona_flutter/src/features/market_scan/application/market_scan_providers.dart';
import 'package:persona_flutter/src/features/market_scan/data/drift_market_scan_repository.dart';
import 'package:persona_flutter/src/features/market_scan/domain/market_book.dart';
import 'package:persona_flutter/src/features/market_scan/domain/market_ranking.dart';
import 'package:persona_flutter/src/features/market_scan/domain/market_scan_repository.dart';
import 'package:persona_flutter/src/features/market_scan/domain/recommendation_direction.dart';
import 'package:persona_flutter/src/features/market_scan/presentation/recommendation_page.dart';

void main() {
  testWidgets(
    'recommendation page keeps rankings behind workspace view switcher',
    (tester) async {
      await _setSurface(tester, const Size(1440, 900));
      final fixture = await _MarketScanFixture.withData();
      addTearDown(fixture.dispose);

      await tester.pumpWidget(_RecommendationTestApp(repository: fixture.repo));
      await tester.pumpAndSettle();

      expect(find.text('市场数据工作台'), findsOneWidget);
      expect(find.text('任务控制'), findsOneWidget);
      expect(find.text('市场数据已准备，可以生成推荐'), findsOneWidget);
      expect(find.text('目标平台'), findsOneWidget);
      expect(find.text('题材方向（可选）'), findsOneWidget);
      expect(find.text('查看完整榜单'), findsOneWidget);
      expect(find.text('生成推荐'), findsOneWidget);
      expect(find.text('排行榜数据'), findsNothing);
      expect(find.text('欢迎进入梦魇直播间'), findsNothing);

      await _tapWorkspaceView(tester, 'rankings');

      expect(find.text('排行榜数据'), findsOneWidget);
      expect(find.text('全球高考'), findsOneWidget);

      await tester.tap(find.text('番茄小说 1条'));
      await tester.pumpAndSettle();
      expect(find.text('欢迎进入梦魇直播间'), findsOneWidget);
      expect(find.text('全球高考'), findsNothing);

      await tester.tap(find.text('欢迎进入梦魇直播间').first);
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('分类'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('ranking platform filters keep stable chip dimensions', (
    tester,
  ) async {
    await _setSurface(tester, const Size(1440, 900));
    final fixture = await _MarketScanFixture.withData();
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_RecommendationTestApp(repository: fixture.repo));
    await tester.pumpAndSettle();

    await _tapWorkspaceView(tester, 'rankings');

    final allFilter = find.byKey(const ValueKey('ranking-platform-filter-all'));
    final qidianFilter = find.byKey(
      const ValueKey('ranking-platform-filter-qidian'),
    );
    final fanqieFilter = find.byKey(
      const ValueKey('ranking-platform-filter-fanqie'),
    );
    final allSize = tester.getSize(allFilter);
    final qidianSize = tester.getSize(qidianFilter);
    final fanqieSize = tester.getSize(fanqieFilter);

    await tester.tap(fanqieFilter);
    await tester.pumpAndSettle();

    expect(tester.getSize(allFilter), allSize);
    expect(tester.getSize(qidianFilter), qidianSize);
    expect(tester.getSize(fanqieFilter), fanqieSize);
    expect(find.text('欢迎进入梦魇直播间'), findsOneWidget);
    expect(find.text('全球高考'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('market summary separates book and ranking entry counts', (
    tester,
  ) async {
    await _setSurface(tester, const Size(1440, 900));
    final fixture = await _MarketScanFixture.withData();
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_RecommendationTestApp(repository: fixture.repo));
    await tester.pumpAndSettle();

    expect(find.text('书籍样本'), findsOneWidget);
    expect(find.text('3 本'), findsOneWidget);
    expect(find.text('榜单条目'), findsOneWidget);
    expect(find.text('4 条'), findsOneWidget);
    expect(find.text('起点中文网 2本 / 3条'), findsOneWidget);
    expect(find.text('番茄小说 1本 / 1条'), findsOneWidget);

    await _tapWorkspaceView(tester, 'rankings');

    expect(find.text('全部 4条'), findsOneWidget);
    expect(find.text('起点中文网 3条'), findsOneWidget);
    expect(find.text('番茄小说 1条'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ranking browser supports chart selection search and sorting', (
    tester,
  ) async {
    await _setSurface(tester, const Size(1440, 900));
    final fixture = await _MarketScanFixture.withData();
    addTearDown(fixture.dispose);

    await tester.pumpWidget(_RecommendationTestApp(repository: fixture.repo));
    await tester.pumpAndSettle();

    await _tapWorkspaceView(tester, 'rankings');
    await tester.tap(find.byKey(const ValueKey('ranking-chart-qidian::月榜')));
    await tester.pumpAndSettle();

    expect(find.text('全球高考'), findsOneWidget);
    expect(find.text('深海电台'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('ranking-search-field')),
      '深海',
    );
    await tester.pumpAndSettle();
    expect(find.text('深海电台'), findsOneWidget);
    expect(find.text('全球高考'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('ranking-search-field')),
      '',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('ranking-sort-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('收藏优先').last);
    await tester.pumpAndSettle();

    final deepTop = tester.getTopLeft(find.text('深海电台')).dy;
    final globalTop = tester.getTopLeft(find.text('全球高考')).dy;
    expect(deepTop, lessThan(globalTop));
    expect(tester.takeException(), isNull);
  });

  testWidgets('recommendation page keeps compact layout overflow-free', (
    tester,
  ) async {
    await _setSurface(tester, const Size(760, 780));
    final fixture = await _MarketScanFixture.withData();
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _RecommendationTestApp(
        repository: fixture.repo,
        recommendationState: MarketRecommendationState(
          directions: [_direction()],
          generatedAt: DateTime(2026, 6, 6, 12),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('市场数据工作台'), findsOneWidget);
    expect(find.text('任务控制'), findsOneWidget);
    await _dragPageDown(tester);
    expect(find.text('时序遗产'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('recommendation page switches narrow workspace views safely', (
    tester,
  ) async {
    await _setSurface(tester, const Size(390, 780));
    final fixture = await _MarketScanFixture.withData();
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      _RecommendationTestApp(
        repository: fixture.repo,
        recommendationState: MarketRecommendationState(
          directions: [_direction()],
          generatedAt: DateTime(2026, 6, 6, 12),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('市场数据工作台'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _tapWorkspaceView(tester, 'rankings');
    expect(find.text('排行榜数据'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _tapWorkspaceView(tester, 'history');
    expect(find.text('扫描历史'), findsWidgets);
    expect(tester.takeException(), isNull);

    await _tapWorkspaceView(tester, 'recommendations');
    expect(find.text('创作方向推荐'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'recommendation page renders scanning progress in command panel',
    (tester) async {
      await _setSurface(tester, const Size(1320, 860));
      final fixture = await _MarketScanFixture.withData();
      addTearDown(fixture.dispose);

      await tester.pumpWidget(
        _RecommendationTestApp(
          repository: fixture.repo,
          scanState: const MarketScanState(
            isScanning: true,
            workflowTaskId: 'scan-task-1',
            platforms: [
              PlatformScanEntry(
                platform: 'qidian',
                displayName: '起点中文网',
                status: PlatformScanStatus.completed,
                itemCount: 348,
              ),
              PlatformScanEntry(
                platform: 'fanqie',
                displayName: '番茄小说',
                status: PlatformScanStatus.scanning,
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('平台进度'), findsOneWidget);
      expect(find.text('1/2 已完成'), findsOneWidget);
      expect(find.text('放弃任务'), findsOneWidget);
      expect(find.text('番茄小说'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'recommendation result navigates to project creation with prefill',
    (tester) async {
      await _setSurface(tester, const Size(1320, 860));
      final fixture = await _MarketScanFixture.withData();
      addTearDown(fixture.dispose);

      await tester.pumpWidget(
        _RecommendationTestApp(
          repository: fixture.repo,
          recommendationState: MarketRecommendationState(
            directions: [_direction()],
            generatedAt: DateTime(2026, 6, 6, 12),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _tapWorkspaceView(tester, 'recommendations');
      await tester.tap(find.text('旧港档案'));
      await tester.pumpAndSettle();
      expect(find.text('开书方案'), findsWidgets);
      expect(find.text('前三章钩子'), findsOneWidget);
      expect(find.text('连载风险'), findsNothing);

      await _tapUseDirection(tester);
      await tester.pumpAndSettle();

      final createText = tester
          .widget<Text>(find.textContaining('create:'))
          .data!;
      expect(createText, contains('create:旧港档案|860000|科幻,悬疑'));
      expect(createText, contains('openBook:true'));
      expect(createText, contains('payoff:true'));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('recommendation page renders missing data state', (tester) async {
    await _setSurface(tester, const Size(1180, 820));
    final emptyFixture = await _MarketScanFixture.empty();
    addTearDown(emptyFixture.dispose);

    await tester.pumpWidget(
      _RecommendationTestApp(repository: emptyFixture.repo),
    );
    await tester.pumpAndSettle();

    expect(find.text('尚无市场扫描数据'), findsOneWidget);
    expect(find.text('扫描市场数据'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('recommendation page renders recommendation error state', (
    tester,
  ) async {
    await _setSurface(tester, const Size(1180, 820));
    final dataFixture = await _MarketScanFixture.withData();
    addTearDown(dataFixture.dispose);

    await tester.pumpWidget(
      _RecommendationTestApp(
        repository: dataFixture.repo,
        recommendationState: const MarketRecommendationState(
          errorMessage: '模型返回为空。',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('推荐任务失败'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Future<void> _dragPageDown(WidgetTester tester) async {
  await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -900));
  await tester.pumpAndSettle();
}

Future<void> _tapWorkspaceView(WidgetTester tester, String view) async {
  final finder = find.byKey(ValueKey('workspace-view-$view'));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _tapUseDirection(WidgetTester tester) async {
  final finder = find.byKey(const ValueKey('market-direction-use-时序遗产')).last;
  await tester.ensureVisible(finder);
  await tester.tap(finder);
}

class _RecommendationTestApp extends StatelessWidget {
  const _RecommendationTestApp({
    required this.repository,
    this.scanState = const MarketScanState(),
    this.recommendationState = const MarketRecommendationState(),
  });

  final MarketScanRepository repository;
  final MarketScanState scanState;
  final MarketRecommendationState recommendationState;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        marketScanRepositoryProvider.overrideWithValue(repository),
        marketScanControllerProvider.overrideWithValue(scanState),
        marketRecommendationControllerProvider.overrideWithValue(
          recommendationState,
        ),
      ],
      child: MaterialApp.router(
        theme: personaLightTheme,
        darkTheme: personaDarkTheme,
        routerConfig: GoRouter(
          initialLocation: '/projects/recommend',
          routes: [
            GoRoute(
              path: '/projects',
              builder: (context, state) =>
                  const Scaffold(body: Text('projects')),
              routes: [
                GoRoute(
                  path: 'recommend',
                  builder: (context, state) =>
                      const Scaffold(body: RecommendationPage()),
                ),
                GoRoute(
                  path: 'create',
                  builder: (context, state) {
                    final query = state.uri.queryParameters;
                    final synopsis = query['synopsis'] ?? '';
                    return Scaffold(
                      body: Text(
                        'create:${query['title']}|${query['wordCount']}|'
                        '${query['tags']}|openBook:${synopsis.contains('## 开书方案')}|'
                        'payoff:${synopsis.contains('第一个爽点')}',
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketScanFixture {
  _MarketScanFixture._(this.database, this.repo);

  final AppDatabase database;
  final DriftMarketScanRepository repo;

  static Future<_MarketScanFixture> empty() async {
    final database = AppDatabase(NativeDatabase.memory());
    return _MarketScanFixture._(database, DriftMarketScanRepository(database));
  }

  static Future<_MarketScanFixture> withData() async {
    final fixture = await empty();
    await fixture._seed();
    return fixture;
  }

  Future<void> _seed() async {
    final qidianRun = await repo.createRun(MarketPlatform.qidian.name);
    final globalExam = await repo.upsertBook(
      const MarketBookInput(
        platform: MarketPlatform.qidian,
        platformBookId: 'qidian-global-exam',
        title: '全球高考',
        author: '木苏里',
        categories: ['纯爱', '近代现代', '剧情'],
        tags: ['热度样本'],
        totalWordCount: 860000,
      ),
    );
    final deepRadio = await repo.upsertBook(
      const MarketBookInput(
        platform: MarketPlatform.qidian,
        platformBookId: 'qidian-deep-radio',
        title: '深海电台',
        author: '北城听潮',
        categories: ['科幻', '悬疑'],
        tags: ['热度样本'],
        totalWordCount: 720000,
      ),
    );
    await repo.insertRankings([
      MarketRankingInput(
        bookId: globalExam.id,
        chartName: '月榜',
        rank: 1,
        runId: qidianRun.id,
        favorites: 600000,
        scrapedAt: DateTime(2026, 6, 6, 11, 20),
      ),
      MarketRankingInput(
        bookId: deepRadio.id,
        chartName: '月榜',
        rank: 2,
        runId: qidianRun.id,
        favorites: 700000,
        scrapedAt: DateTime(2026, 6, 6, 11, 20),
      ),
      MarketRankingInput(
        bookId: globalExam.id,
        chartName: '新书榜',
        rank: 1,
        runId: qidianRun.id,
        favorites: 580000,
        scrapedAt: DateTime(2026, 6, 6, 11, 20),
      ),
    ]);
    await repo.completeRun(runId: qidianRun.id, itemCount: 3);

    await _seedPlatform(
      platform: MarketPlatform.fanqie,
      chartName: '热读榜',
      title: '欢迎进入梦魇直播间',
      author: '桑沃',
      categories: const ['悬疑', '无限流'],
      favorites: 4110000,
    );
  }

  Future<void> _seedPlatform({
    required MarketPlatform platform,
    required String chartName,
    required String title,
    required String author,
    required List<String> categories,
    required int favorites,
  }) async {
    final run = await repo.createRun(platform.name);
    final book = await repo.upsertBook(
      MarketBookInput(
        platform: platform,
        platformBookId: '$platform-book',
        title: title,
        author: author,
        categories: categories,
        tags: const ['热度样本'],
        totalWordCount: 860000,
      ),
    );
    await repo.insertRankings([
      MarketRankingInput(
        bookId: book.id,
        chartName: chartName,
        rank: 1,
        runId: run.id,
        favorites: favorites,
        scrapedAt: DateTime(2026, 6, 6, 11, 20),
      ),
    ]);
    await repo.completeRun(runId: run.id, itemCount: 1);
  }

  Future<void> dispose() => database.close();
}

RecommendationDirection _direction() {
  return const RecommendationDirection(
    directionRole: '稳妥热题',
    suggestedTitle: '时序遗产',
    titleCandidates: [
      RecommendationTitleCandidate(
        title: '时序遗产',
        formula: '意象+核心物件',
        rationale: '保留科幻悬疑感，适合起点强剧情读者。',
      ),
      RecommendationTitleCandidate(
        title: '旧港档案',
        formula: '地点+案件物件',
        rationale: '更直接传递案件抓手，适合预填项目标题。',
      ),
      RecommendationTitleCandidate(
        title: '归零证词',
        formula: '反义词+证据',
        rationale: '暗示记忆改写和证词失效。',
      ),
    ],
    synopsis:
        '旧城区的时间档案忽然被改写，退役调查员被迫重回十年前的失踪案现场，发现每个嫌疑人都能利用记忆偏移隐藏证据。他唯一的能力是在改写前读取三分钟残留真相，于是从第一份被抹掉的证词开始反击，并必须赶在下一轮全城失忆前找回真实案件。 ',
    protagonist: '退役调查员林砚，被十年前失踪案拖回旧城区，只想证明自己没有办错案。',
    coreMechanism: '主角能读取时间档案改写前三分钟的残留真相，但每次使用都会留下追踪痕迹。',
    firstThreeChaptersHook: '第一章证词被改写，第二章残留真相指向旧港，第三章主角救下被栽赃的证人。',
    mainConflict: '主角必须在全城记忆再次归零前，拆穿操控时间档案的幕后组织。',
    firstPayoff: '第三章主角用残留真相救出证人，并当场反制伪造证词的人。',
    genreTags: ['科幻', '悬疑'],
    targetWordCount: 860000,
    targetPlatform: MarketPlatform.qidian,
    targetAudience: '起点偏好强主线、轻科幻悬疑和案件推进的读者。',
    coreSellingPoint: '主角用三分钟残留真相对抗时间档案改写。',
    marketHeatSummary: '热度高',
    competitionSummary: '竞争适中',
    marketValidation: '扫榜样本中悬疑、都市和强剧情标签重复出现。',
    differentiation: '不做普通刑侦，用时间档案机制制造连续反转。',
    feasibility: '中',
    failureRisk: '设定解释过多会拖慢前三章。',
    serialRisk: '时间改写规则如果持续加码，容易削弱推理公平性。',
    validationAction: '先写黄金三章验证能力规则是否易懂。',
    detailMarkdown: '## 方向 1：时序遗产\n### 市场验证\n- 样本支持。',
  );
}
