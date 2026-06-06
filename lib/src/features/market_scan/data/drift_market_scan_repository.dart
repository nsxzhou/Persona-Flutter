import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/market_book.dart';
import '../domain/market_ranking.dart';
import '../domain/market_scan_repository.dart';
import '../domain/market_scan_run.dart';

class DriftMarketScanRepository implements MarketScanRepository {
  const DriftMarketScanRepository(this._database);

  final AppDatabase _database;

  static const _uuid = Uuid();

  // ── Books ────────────────────────────────────────────────────────

  @override
  Future<List<MarketBook>> findBooks({MarketPlatform? platform}) async {
    final query = _database.select(_database.marketBookRecords);
    if (platform != null) {
      query.where((t) => t.platform.equals(platform.name));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    final rows = await query.get();
    return rows.map(_mapBook).toList(growable: false);
  }

  @override
  Future<MarketBook> upsertBook(MarketBookInput input) async {
    final existing = await _findBookByPlatformId(
      input.platform,
      input.platformBookId,
    );
    final now = DateTime.now();
    final id = existing?.id ?? _uuid.v4();

    await _database.into(_database.marketBookRecords).insertOnConflictUpdate(
      MarketBookRecordsCompanion(
        id: Value(id),
        platform: Value(input.platform.name),
        platformBookId: Value(input.platformBookId),
        title: Value(input.title.trim()),
        author: Value(input.author.trim()),
        description: Value(input.description.trim()),
        categories: Value(jsonEncode(input.categories)),
        tags: Value(jsonEncode(input.tags)),
        totalWordCount: Value(input.totalWordCount),
        status: Value(input.status.name),
        firstPublishDate: Value(input.firstPublishDate),
        createdAt: Value(existing?.createdAt ?? now),
        updatedAt: Value(now),
      ),
    );

    final saved = await _findBookByPlatformId(
      input.platform,
      input.platformBookId,
    );
    if (saved == null) {
      throw StateError('MarketBook was not saved.');
    }
    return saved;
  }

  @override
  Future<int> upsertBooks(List<MarketBookInput> inputs) async {
    var count = 0;
    await _database.transaction(() async {
      for (final input in inputs) {
        await upsertBook(input);
        count++;
      }
    });
    return count;
  }

  Future<MarketBook?> _findBookByPlatformId(
    MarketPlatform platform,
    String platformBookId,
  ) async {
    final query = _database.select(_database.marketBookRecords)
      ..where(
        (t) =>
            t.platform.equals(platform.name) &
            t.platformBookId.equals(platformBookId),
      )
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _mapBook(row);
  }

  // ── Rankings ─────────────────────────────────────────────────────

  @override
  Future<List<MarketRanking>> findRankings({
    required String runId,
    String? chartName,
  }) async {
    final query = _database.select(_database.marketRankingRecords)
      ..where((t) {
        if (chartName != null) {
          return t.runId.equals(runId) & t.chartName.equals(chartName);
        }
        return t.runId.equals(runId);
      })
      ..orderBy([(t) => OrderingTerm.asc(t.rank)]);
    final rows = await query.get();
    return rows.map(_mapRanking).toList(growable: false);
  }

  @override
  Future<List<MarketRanking>> findLatestRankings({
    MarketPlatform? platform,
  }) async {
    // Find the latest completed run per platform (or all platforms).
    final latestRuns = await findLatestCompletedRuns();
    final relevantRunIds = latestRuns.entries
        .where((e) => platform == null || e.key == platform.name)
        .map((e) => e.value.id)
        .toList();

    if (relevantRunIds.isEmpty) {
      return const [];
    }

    final query = _database.select(_database.marketRankingRecords)
      ..where((t) => t.runId.isIn(relevantRunIds))
      ..orderBy([(t) => OrderingTerm.asc(t.rank)]);
    final rows = await query.get();
    return rows.map(_mapRanking).toList(growable: false);
  }

  @override
  Future<void> insertRankings(List<MarketRankingInput> inputs) async {
    await _database.transaction(() async {
      for (final input in inputs) {
        await _database.into(_database.marketRankingRecords).insert(
          MarketRankingRecordsCompanion(
            id: Value(_uuid.v4()),
            bookId: Value(input.bookId),
            chartName: Value(input.chartName),
            rank: Value(input.rank),
            runId: Value(input.runId),
            favorites: Value(input.favorites),
            recommendVotes: Value(input.recommendVotes),
            monthlyTickets: Value(input.monthlyTickets),
            commentCount: Value(input.commentCount),
            scrapedAt: Value(input.scrapedAt),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    });
  }

  // ── Runs ─────────────────────────────────────────────────────────

  @override
  Future<List<MarketScanRun>> findRuns({int? limit}) async {
    final query = _database.select(_database.marketScanRunRecords)
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    if (limit != null) {
      query.limit(limit);
    }
    final rows = await query.get();
    return rows.map(_mapRun).toList(growable: false);
  }

  @override
  Future<Map<String, MarketScanRun>> findLatestCompletedRuns() async {
    final rows = await _database.customSelect(
      '''
      SELECT r.*
      FROM market_scan_run_records r
      INNER JOIN (
        SELECT platform, MAX(completed_at) AS max_completed
        FROM market_scan_run_records
        WHERE status = 'completed'
        GROUP BY platform
      ) latest ON r.platform = latest.platform
              AND r.completed_at = latest.max_completed
              AND r.status = 'completed'
      ''',
      readsFrom: {_database.marketScanRunRecords},
    ).get();

    final result = <String, MarketScanRun>{};
    for (final row in rows) {
      final run = _mapRunFromRow(row);
      result[run.platform] = run;
    }
    return result;
  }

  @override
  Future<MarketScanRun> createRun(String platform) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    await _database.into(_database.marketScanRunRecords).insert(
      MarketScanRunRecordsCompanion(
        id: Value(id),
        platform: Value(platform),
        status: Value(MarketScanRunStatus.running.name),
        startedAt: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    final query = _database.select(_database.marketScanRunRecords)
      ..where((t) => t.id.equals(id))
      ..limit(1);
    final row = await query.getSingle();
    return _mapRun(row);
  }

  @override
  Future<void> completeRun({
    required String runId,
    required int itemCount,
  }) async {
    final now = DateTime.now();
    await (_database.update(_database.marketScanRunRecords)
          ..where((t) => t.id.equals(runId)))
        .write(
      MarketScanRunRecordsCompanion(
        status: Value(MarketScanRunStatus.completed.name),
        completedAt: Value(now),
        itemCount: Value(itemCount),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> failRun({
    required String runId,
    required String errorMessage,
  }) async {
    final now = DateTime.now();
    await (_database.update(_database.marketScanRunRecords)
          ..where((t) => t.id.equals(runId)))
        .write(
      MarketScanRunRecordsCompanion(
        status: Value(MarketScanRunStatus.failed.name),
        completedAt: Value(now),
        errorMessage: Value(errorMessage),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<bool> hasData() async {
    final query = _database.select(_database.marketScanRunRecords)
      ..where((t) => t.status.equals(MarketScanRunStatus.completed.name))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row != null;
  }

  @override
  Future<void> cleanupOldRuns({int retainCount = 10}) async {
    // Find run IDs to keep: the most recent [retainCount] per platform.
    final allRuns = await findRuns();
    final runsByPlatform = <String, List<MarketScanRun>>{};
    for (final run in allRuns) {
      runsByPlatform.putIfAbsent(run.platform, () => []).add(run);
    }

    final idsToDelete = <String>[];
    for (final runs in runsByPlatform.values) {
      // Runs are already sorted newest-first from findRuns().
      if (runs.length > retainCount) {
        idsToDelete.addAll(runs.skip(retainCount).map((r) => r.id));
      }
    }

    if (idsToDelete.isEmpty) return;

    await _database.transaction(() async {
      // Delete associated rankings first.
      await (_database.delete(_database.marketRankingRecords)
            ..where((t) => t.runId.isIn(idsToDelete)))
          .go();
      // Then delete the runs.
      await (_database.delete(_database.marketScanRunRecords)
            ..where((t) => t.id.isIn(idsToDelete)))
          .go();
    });
  }

  // ── Mapping ──────────────────────────────────────────────────────

  MarketBook _mapBook(MarketBookRecord row) {
    return MarketBook(
      id: row.id,
      platform: MarketPlatform.values.byName(row.platform),
      platformBookId: row.platformBookId,
      title: row.title,
      author: row.author,
      description: row.description,
      categories: _decodeStringList(row.categories),
      tags: _decodeStringList(row.tags),
      totalWordCount: row.totalWordCount,
      status: BookStatus.values.byName(row.status),
      firstPublishDate: row.firstPublishDate,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  MarketRanking _mapRanking(MarketRankingRecord row) {
    return MarketRanking(
      id: row.id,
      bookId: row.bookId,
      chartName: row.chartName,
      rank: row.rank,
      runId: row.runId,
      favorites: row.favorites,
      recommendVotes: row.recommendVotes,
      monthlyTickets: row.monthlyTickets,
      commentCount: row.commentCount,
      scrapedAt: row.scrapedAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  MarketScanRun _mapRun(MarketScanRunRecord row) {
    return MarketScanRun(
      id: row.id,
      platform: row.platform,
      status: MarketScanRunStatus.values.byName(row.status),
      startedAt: row.startedAt,
      completedAt: row.completedAt,
      itemCount: row.itemCount,
      errorMessage: row.errorMessage,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  MarketScanRun _mapRunFromRow(QueryRow row) {
    final data = row.data;
    return MarketScanRun(
      id: data['id'] as String,
      platform: data['platform'] as String,
      status: MarketScanRunStatus.values.byName(data['status'] as String),
      startedAt: _toDateTime(data['started_at'])!,
      completedAt: _toDateTime(data['completed_at']),
      itemCount: data['item_count'] as int,
      errorMessage: data['error_message'] as String?,
      createdAt: _toDateTime(data['created_at'])!,
      updatedAt: _toDateTime(data['updated_at'])!,
    );
  }

  /// Convert a raw SQLite value to DateTime.
  /// customSelect bypasses Drift type converters, so DateTime columns
  /// come back as int (milliseconds since epoch).
  DateTime? _toDateTime(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  List<String> _decodeStringList(String json) {
    if (json.isEmpty) return const [];
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded.cast<String>();
      }
    } catch (_) {}
    return const [];
  }
}
