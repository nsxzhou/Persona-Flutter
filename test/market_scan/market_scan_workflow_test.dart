import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/core/database/app_database.dart';
import 'package:persona_flutter/src/core/llm/domain/llm_cancellation.dart';
import 'package:persona_flutter/src/core/tasks/application/workflow_task_repository.dart';
import 'package:persona_flutter/src/core/tasks/data/drift_workflow_task_repository.dart';
import 'package:persona_flutter/src/core/tasks/domain/workflow_task.dart';
import 'package:persona_flutter/src/features/market_scan/application/market_scan_service.dart';
import 'package:persona_flutter/src/features/market_scan/application/scraper_process_runner.dart';
import 'package:persona_flutter/src/features/market_scan/data/drift_market_scan_repository.dart';
import 'package:persona_flutter/src/features/market_scan/domain/data_source_adapter.dart';
import 'package:persona_flutter/src/features/market_scan/domain/market_book.dart';
import 'package:persona_flutter/src/features/market_scan/domain/market_ranking.dart';
import 'package:persona_flutter/src/features/market_scan/domain/market_scan_repository.dart';
import 'package:persona_flutter/src/features/market_scan/domain/market_scan_run.dart';
import 'package:persona_flutter/src/features/market_scan/domain/market_scan_workflow.dart';
import 'package:persona_flutter/src/features/market_scan/domain/scraped_book.dart';

void main() {
  test(
    'clearAllData removes market data and preserves workflow tasks',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final marketRepository = DriftMarketScanRepository(database);
      final workflowRepository = DriftWorkflowTaskRepository(database);

      final task = await workflowRepository.createTask(
        const WorkflowTaskInput(
          kind: marketScanWorkflowTaskKind,
          title: '市场扫描',
          stage: 'queued',
        ),
      );
      await workflowRepository.updateTaskState(
        id: task.id,
        status: WorkflowTaskStatus.running,
        stage: 'scanning_platforms',
      );

      final run = await marketRepository.createRun(MarketPlatform.qidian.name);
      final book = await marketRepository.upsertBook(
        const MarketBookInput(
          platform: MarketPlatform.qidian,
          platformBookId: 'qidian-1',
          title: '榜首书',
          author: '作者',
        ),
      );
      await marketRepository.insertRankings([
        MarketRankingInput(
          bookId: book.id,
          chartName: '起点月票榜',
          rank: 1,
          runId: run.id,
          scrapedAt: DateTime.utc(2026, 6, 6),
        ),
      ]);
      await marketRepository.completeRun(runId: run.id, itemCount: 1);

      expect(await marketRepository.hasData(), isTrue);
      expect(await marketRepository.findBooks(), hasLength(1));
      expect(await marketRepository.findLatestRankings(), hasLength(1));
      expect(await workflowRepository.watchTasks().first, hasLength(1));

      await marketRepository.clearAllData();

      expect(await marketRepository.hasData(), isFalse);
      expect(await marketRepository.findBooks(), isEmpty);
      expect(await marketRepository.findLatestRankings(), isEmpty);
      expect(await marketRepository.findRuns(), isEmpty);
      expect(await workflowRepository.findTask(task.id), isNotNull);
    },
  );

  test(
    'workflow repository creates and updates generic market tasks',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftWorkflowTaskRepository(database);

      final created = await repository.createTask(
        const WorkflowTaskInput(
          kind: marketRecommendationWorkflowTaskKind,
          title: '创作方向推荐',
          stage: 'queued',
        ),
      );
      expect(created.status, WorkflowTaskStatus.pending);
      expect(created.stage, 'queued');

      final running = await repository.updateTaskState(
        id: created.id,
        status: WorkflowTaskStatus.running,
        stage: 'generating',
        clearErrorMessage: true,
      );
      expect(running!.status, WorkflowTaskStatus.running);
      expect(running.stage, 'generating');

      final succeeded = await repository.updateTaskState(
        id: created.id,
        status: WorkflowTaskStatus.succeeded,
        clearStage: true,
        clearErrorMessage: true,
      );
      expect(succeeded!.status, WorkflowTaskStatus.succeeded);
      expect(succeeded.stage, isNull);
      expect(succeeded.errorMessage, isNull);
    },
  );

  test('scanPlatform resolves platform books once after bulk upsert', () async {
    final repository = _FakeMarketScanRepository();
    final service = MarketScanService(
      repository: repository,
      adapters: const [],
      runner: ScraperProcessRunner(),
    );
    final adapter = _FakeAdapter([
      _scraped('book-1', chartName: '热销榜', rank: 1),
      _scraped('book-2', chartName: '热销榜', rank: 2),
      _scraped('book-1', chartName: '新书榜', rank: 1),
    ]);

    final result = await service.scanPlatform(adapter);

    expect(result.success, isTrue);
    expect(result.itemCount, 3);
    expect(repository.upsertedBookInputs, hasLength(2));
    expect(repository.findBooksByPlatformCalls, 1);
    expect(repository.rankings, hasLength(3));
    expect(repository.completedRuns.single.itemCount, 3);
  });
}

ScrapedBook _scraped(
  String platformBookId, {
  required String chartName,
  required int rank,
}) {
  return ScrapedBook(
    platform: MarketPlatform.qidian,
    platformBookId: platformBookId,
    title: '书 $platformBookId',
    author: '作者',
    chartName: chartName,
    rank: rank,
    scrapedAt: DateTime.utc(2026, 6, 6),
  );
}

class _FakeAdapter extends DataSourceAdapter {
  _FakeAdapter(this.books);

  final List<ScrapedBook> books;

  @override
  MarketPlatform get platform => MarketPlatform.qidian;

  @override
  String get displayName => '起点中文网';

  @override
  Future<List<ScrapedBook>> scrapeCoreCharts({
    LlmCancellationToken? cancellationToken,
  }) async {
    cancellationToken?.throwIfCancelled();
    return books;
  }
}

class _FakeMarketScanRepository implements MarketScanRepository {
  final books = <MarketBook>[];
  final rankings = <MarketRankingInput>[];
  final runs = <MarketScanRun>[];
  final completedRuns = <MarketScanRun>[];
  final upsertedBookInputs = <MarketBookInput>[];
  var findBooksByPlatformCalls = 0;

  @override
  Future<List<MarketBook>> findBooks({MarketPlatform? platform}) async {
    if (platform != null) {
      findBooksByPlatformCalls += 1;
    }
    return books
        .where((book) => platform == null || book.platform == platform)
        .toList(growable: false);
  }

  @override
  Future<MarketBook> upsertBook(MarketBookInput input) async {
    await upsertBooks([input]);
    return books.singleWhere(
      (book) =>
          book.platform == input.platform &&
          book.platformBookId == input.platformBookId,
    );
  }

  @override
  Future<int> upsertBooks(List<MarketBookInput> inputs) async {
    upsertedBookInputs.addAll(inputs);
    final now = DateTime.utc(2026, 6, 6);
    for (final input in inputs) {
      final existingIndex = books.indexWhere(
        (book) =>
            book.platform == input.platform &&
            book.platformBookId == input.platformBookId,
      );
      final book = MarketBook(
        id: '${input.platform.name}-${input.platformBookId}',
        platform: input.platform,
        platformBookId: input.platformBookId,
        title: input.title,
        author: input.author,
        description: input.description,
        categories: input.categories,
        tags: input.tags,
        totalWordCount: input.totalWordCount,
        status: input.status,
        firstPublishDate: input.firstPublishDate,
        createdAt: now,
        updatedAt: now,
      );
      if (existingIndex == -1) {
        books.add(book);
      } else {
        books[existingIndex] = book;
      }
    }
    return inputs.length;
  }

  @override
  Future<List<MarketRanking>> findRankings({
    required String runId,
    String? chartName,
  }) async {
    return const [];
  }

  @override
  Future<List<MarketRanking>> findLatestRankings({
    MarketPlatform? platform,
  }) async {
    return const [];
  }

  @override
  Future<void> insertRankings(List<MarketRankingInput> inputs) async {
    rankings.addAll(inputs);
  }

  @override
  Future<List<MarketScanRun>> findRuns({int? limit}) async => runs;

  @override
  Future<Map<String, MarketScanRun>> findLatestCompletedRuns() async => {
    for (final run in completedRuns) run.platform: run,
  };

  @override
  Future<MarketScanRun> createRun(String platform) async {
    final now = DateTime.utc(2026, 6, 6);
    final run = MarketScanRun(
      id: 'run-${runs.length + 1}',
      platform: platform,
      status: MarketScanRunStatus.running,
      startedAt: now,
      createdAt: now,
      updatedAt: now,
    );
    runs.add(run);
    return run;
  }

  @override
  Future<void> completeRun({
    required String runId,
    required int itemCount,
  }) async {
    final index = runs.indexWhere((run) => run.id == runId);
    final completed = runs[index].copyWith(
      status: MarketScanRunStatus.completed,
      completedAt: DateTime.utc(2026, 6, 6, 1),
      itemCount: itemCount,
      updatedAt: DateTime.utc(2026, 6, 6, 1),
    );
    runs[index] = completed;
    completedRuns.add(completed);
  }

  @override
  Future<void> failRun({
    required String runId,
    required String errorMessage,
  }) async {
    final index = runs.indexWhere((run) => run.id == runId);
    runs[index] = runs[index].copyWith(
      status: MarketScanRunStatus.failed,
      completedAt: DateTime.utc(2026, 6, 6, 1),
      errorMessage: errorMessage,
      updatedAt: DateTime.utc(2026, 6, 6, 1),
    );
  }

  @override
  Future<bool> hasData() async => completedRuns.isNotEmpty;

  @override
  Future<void> cleanupOldRuns({int retainCount = 10}) async {}

  @override
  Future<void> clearAllData() async {
    books.clear();
    rankings.clear();
    runs.clear();
    completedRuns.clear();
  }
}
