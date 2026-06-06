import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/persona_page.dart';
import '../application/market_scan_providers.dart';
import '../domain/market_book.dart';
import '../domain/market_ranking.dart';
import '../domain/market_scan_run.dart';

// ── Widget ──────────────────────────────────────────────────────────

/// Displays scan data overview: optional stat cards, platform filter, rankings
/// list, and optional scan history.
///
/// When [showHeader] is true (default), renders as a collapsible panel with
/// a clickable header. When false, renders always-expanded without the header
/// (suitable for embedding as a tab body).
class ScanDataBrowser extends ConsumerStatefulWidget {
  const ScanDataBrowser({
    super.key,
    this.showHeader = true,
    this.showStats = true,
    this.showHistory = true,
  });

  final bool showHeader;
  final bool showStats;
  final bool showHistory;

  @override
  ConsumerState<ScanDataBrowser> createState() => _ScanDataBrowserState();
}

class _ScanDataBrowserState extends ConsumerState<ScanDataBrowser> {
  bool _expanded = false;
  MarketPlatform? _platformFilter;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // When showHeader is false, always render expanded content directly.
    if (!widget.showHeader) {
      return _buildExpandedContent(context);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(kPanelRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(kPanelRadius),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.dataset_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '扫描数据概览',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            _buildExpandedContent(context),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    final bundleAsync = ref.watch(scanDataBundleProvider);

    return bundleAsync.when(
      data: (bundle) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showStats) ...[
              _StatCardsRow(
                totalBooks: bundle.books.length,
                platformCount: bundle.books
                    .map((b) => b.platform)
                    .toSet()
                    .length,
                chartCount: bundle.rankings
                    .map((r) => r.chartName)
                    .toSet()
                    .length,
                latestScanTime: bundle.runs.isNotEmpty
                    ? bundle.runs.first.startedAt
                    : null,
              ),
              const SizedBox(height: 20),
            ],
            _buildPlatformFilter(bundle.books),
            const SizedBox(height: 20),
            _buildRankingsList(bundle),
            if (widget.showHistory) ...[
              const SizedBox(height: 20),
              _ScanHistorySection(runs: bundle.runs),
            ],
          ],
        ),
      ),
      loading: () =>
          const Padding(padding: EdgeInsets.all(16), child: _ContentLoading()),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('加载失败: $e', style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }

  // ── Platform Filter ────────────────────────────────────────────

  Widget _buildPlatformFilter(List<MarketBook> books) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final platformCounts = <MarketPlatform, int>{};
    for (final book in books) {
      platformCounts[book.platform] = (platformCounts[book.platform] ?? 0) + 1;
    }

    final filters = <MarketPlatform?>[null, ...MarketPlatform.values];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '排行榜数据',
          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filters.map((p) {
            final selected = _platformFilter == p;
            final count = p == null ? books.length : (platformCounts[p] ?? 0);
            final label = p == null ? '全部' : _platformLabel(p.name);

            return ChoiceChip(
              label: Text('$label ($count)'),
              selected: selected,
              onSelected: (_) => setState(() => _platformFilter = p),
              visualDensity: VisualDensity.compact,
              avatar: p != null
                  ? Icon(
                      _platformIcon(p),
                      size: 14,
                      color: selected
                          ? colorScheme.onPrimary
                          : _platformColor(p, colorScheme),
                    )
                  : null,
              labelStyle: textTheme.labelSmall?.copyWith(
                color: selected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Rankings List (virtualized) ──────────────────────────────

  Widget _buildRankingsList(ScanDataBundle bundle) {
    final bookMap = {for (final b in bundle.books) b.id: b};

    var filtered = bundle.rankings;
    if (_platformFilter != null) {
      filtered = bundle.rankings.where((r) {
        final book = bookMap[r.bookId];
        return book?.platform == _platformFilter;
      }).toList();
    }

    final grouped = <String, List<MarketRanking>>{};
    for (final r in filtered) {
      grouped.putIfAbsent(r.chartName, () => []).add(r);
    }

    if (grouped.isEmpty) {
      return const _EmptyRankingsPlaceholder();
    }

    final rows = <_RankingListRow>[];
    for (final entry in grouped.entries) {
      final firstBook = entry.value.isNotEmpty
          ? bookMap[entry.value.first.bookId]
          : null;
      rows.add(
        _RankingHeaderListRow(
          chartName: entry.key,
          count: entry.value.length,
          platform: firstBook?.platform,
        ),
      );
      for (final ranking in entry.value) {
        rows.add(_RankingBookListRow(ranking: ranking));
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportHeight = MediaQuery.sizeOf(context).height;
        final listHeight = (viewportHeight * 0.56).clamp(360.0, 720.0);

        // Keep the inner list bounded so ListView.builder can virtualize rows
        // instead of forcing every ranking item to build in the outer scroll view.
        return SizedBox(
          height: listHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: ListView.builder(
              itemCount: rows.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final row = rows[index];
                return switch (row) {
                  _RankingHeaderListRow() => _RankingListHeader(row: row),
                  _RankingBookListRow() => _RankingItem(
                    ranking: row.ranking,
                    book: bookMap[row.ranking.bookId],
                    isLast:
                        index == rows.length - 1 ||
                        rows[index + 1] is _RankingHeaderListRow,
                  ),
                };
              },
            ),
          ),
        );
      },
    );
  }
}

sealed class _RankingListRow {
  const _RankingListRow();
}

class _RankingHeaderListRow extends _RankingListRow {
  const _RankingHeaderListRow({
    required this.chartName,
    required this.count,
    required this.platform,
  });

  final String chartName;
  final int count;
  final MarketPlatform? platform;
}

class _RankingBookListRow extends _RankingListRow {
  const _RankingBookListRow({required this.ranking});

  final MarketRanking ranking;
}

// ── Stat Cards Row ────────────────────────────────────────────────────

class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow({
    required this.totalBooks,
    required this.platformCount,
    required this.chartCount,
    this.latestScanTime,
  });

  final int totalBooks;
  final int platformCount;
  final int chartCount;
  final DateTime? latestScanTime;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 860
            ? 4
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        final spacing = columns == 1 ? 0.0 : 10.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: 10,
          children: [
            SizedBox(
              width: itemWidth,
              child: _StatCard(
                icon: Icons.menu_book_outlined,
                label: '扫描书籍',
                value: '$totalBooks',
                color: const Color(0xFF2758D9),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _StatCard(
                icon: Icons.public_outlined,
                label: '覆盖平台',
                value: '$platformCount',
                color: const Color(0xFF00897B),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _StatCard(
                icon: Icons.leaderboard_outlined,
                label: '榜单数量',
                value: '$chartCount',
                color: const Color(0xFFF57C00),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _StatCard(
                icon: Icons.history_outlined,
                label: '最近扫描',
                value: latestScanTime != null
                    ? _compactTime(latestScanTime!)
                    : '—',
                color: const Color(0xFF7B1FA2),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 82),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(icon, size: 14, color: color),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentLoading extends StatelessWidget {
  const _ContentLoading();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 860
            ? 4
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        final spacing = columns == 1 ? 0.0 : 10.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: 10,
          children: List.generate(
            4,
            (_) => SizedBox(
              width: itemWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const SizedBox(
                  height: 82,
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Ranking List Header ───────────────────────────────────────────────

class _RankingListHeader extends StatelessWidget {
  const _RankingListHeader({required this.row});

  final _RankingHeaderListRow row;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final platformClr = row.platform != null
        ? _platformColor(row.platform!, colorScheme)
        : colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: platformClr,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                row.chartName,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: platformClr.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Text(
                  '${row.count} 本',
                  style: textTheme.labelSmall?.copyWith(
                    color: platformClr,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ranking Item ──────────────────────────────────────────────────────

class _RankingItem extends StatelessWidget {
  const _RankingItem({
    required this.ranking,
    required this.book,
    this.isLast = false,
  });

  final MarketRanking ranking;
  final MarketBook? book;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        InkWell(
          onTap: book != null
              ? () => _showBookDetail(context, book!, ranking)
              : null,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RankBadge(rank: ranking.rank),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book?.title ?? '未知书籍',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              book?.author ?? '未知作者',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (book != null) ...[
                            const SizedBox(width: 8),
                            _PlatformDot(platform: book!.platform),
                          ],
                        ],
                      ),
                      if (book != null && book!.categories.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 3,
                          children: book!.categories.take(3).map((c) {
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.07,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                child: Text(
                                  c,
                                  style: textTheme.labelSmall?.copyWith(
                                    fontSize: 10,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: _buildMetrics(context),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 60,
            color: colorScheme.outlineVariant.withValues(alpha: 0.7),
          ),
      ],
    );
  }

  Widget _buildMetrics(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final metrics = <Widget>[];
    if (ranking.favorites != null && ranking.favorites! > 0) {
      metrics.add(
        _MiniMetric(
          icon: Icons.favorite_border,
          value: _formatCount(ranking.favorites!),
          color: const Color(0xFFE53935),
        ),
      );
    }
    if (ranking.recommendVotes != null && ranking.recommendVotes! > 0) {
      metrics.add(
        _MiniMetric(
          icon: Icons.thumb_up_outlined,
          value: _formatCount(ranking.recommendVotes!),
          color: const Color(0xFF1E88E5),
        ),
      );
    }
    if (ranking.monthlyTickets != null && ranking.monthlyTickets! > 0) {
      metrics.add(
        _MiniMetric(
          icon: Icons.confirmation_number_outlined,
          value: _formatCount(ranking.monthlyTickets!),
          color: const Color(0xFFF9A825),
        ),
      );
    }
    if (ranking.commentCount != null && ranking.commentCount! > 0) {
      metrics.add(
        _MiniMetric(
          icon: Icons.chat_bubble_outline,
          value: _formatCount(ranking.commentCount!),
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (book != null && book!.totalWordCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              _formatWordCount(book!.totalWordCount),
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (metrics.isNotEmpty)
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: metrics,
          ),
      ],
    );
  }
}

// ── Rank Badge ────────────────────────────────────────────────────────

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    final color = isTop3 ? _rankColor(rank) : null;
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = color ?? colorScheme.surfaceContainerHighest;
    final fgColor = color ?? colorScheme.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: isTop3 ? 0.12 : 0.5),
        borderRadius: BorderRadius.circular(8),
        border: isTop3
            ? Border.all(color: bgColor.withValues(alpha: 0.35))
            : null,
      ),
      child: SizedBox(
        width: 34,
        height: 28,
        child: Center(
          child: isTop3
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events, size: 12, color: fgColor),
                    const SizedBox(width: 2),
                    Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: fgColor,
                      ),
                    ),
                  ],
                )
              : Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: fgColor,
                  ),
                ),
        ),
      ),
    );
  }

  Color _rankColor(int rank) {
    return switch (rank) {
      1 => const Color(0xFFD4A017),
      2 => const Color(0xFF78909C),
      3 => const Color(0xFFA1887F),
      _ => const Color(0xFF9E9E9E),
    };
  }
}

// ── Mini Metric ───────────────────────────────────────────────────────

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ── Platform Dot ──────────────────────────────────────────────────────

class _PlatformDot extends StatelessWidget {
  const _PlatformDot({required this.platform});

  final MarketPlatform platform;

  @override
  Widget build(BuildContext context) {
    final color = _platformColor(platform, Theme.of(context).colorScheme);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          _platformShortLabel(platform),
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Scan History ──────────────────────────────────────────────────────

class _ScanHistorySection extends StatelessWidget {
  const _ScanHistorySection({required this.runs});
  final List<MarketScanRun> runs;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '扫描历史',
          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        if (runs.isEmpty)
          Text('暂无扫描记录', style: textTheme.bodySmall)
        else
          ...runs.take(10).map((run) => _ScanHistoryRow(run: run)),
      ],
    );
  }
}

class _ScanHistoryRow extends StatelessWidget {
  const _ScanHistoryRow({required this.run});

  final MarketScanRun run;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (icon, statusColor, trailing) = switch (run.status) {
      MarketScanRunStatus.completed => (
        Icons.check_circle_outline,
        const Color(0xFF2E7D32),
        Text(
          '${run.itemCount} 本',
          style: textTheme.labelSmall?.copyWith(
            color: const Color(0xFF2E7D32),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      MarketScanRunStatus.failed => (
        Icons.error_outline,
        colorScheme.error,
        Text(
          '失败',
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      MarketScanRunStatus.running => (
        Icons.sync_outlined,
        colorScheme.primary,
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorScheme.primary,
          ),
        ),
      ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: statusColor),
          const SizedBox(width: 8),
          Text(
            _platformLabel(run.platform),
            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 10),
          Text(
            _formatTime(run.startedAt),
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }
}

// ── Empty / Loading Placeholders ──────────────────────────────────────

class _EmptyRankingsPlaceholder extends StatelessWidget {
  const _EmptyRankingsPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.leaderboard_outlined,
              size: 32,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            Text(
              '暂无排行数据',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Book Detail Dialog ────────────────────────────────────────────────

void _showBookDetail(
  BuildContext context,
  MarketBook book,
  MarketRanking ranking,
) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  final platformClr = _platformColor(book.platform, colorScheme);

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: PersonaPanel(
          padding: EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540, maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: platformClr,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(kPanelRadius),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _PlatformBadge(platform: book.platform),
                          const SizedBox(width: 8),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              child: Text(
                                ranking.chartName,
                                style: textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '扫描于 ${_formatTime(ranking.scrapedAt)}',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        book.title,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.author,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_hasAnyMetric(ranking)) ...[
                          _DialogMetricsGrid(ranking: ranking),
                          const SizedBox(height: 16),
                        ],
                        _DialogInfoRow(
                          wordCount: book.totalWordCount,
                          status: book.status,
                          publishDate: book.firstPublishDate,
                        ),
                        if (book.totalWordCount > 0 ||
                            book.firstPublishDate != null)
                          const SizedBox(height: 16),
                        if (book.categories.isNotEmpty) ...[
                          Text(
                            '分类',
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: book.categories.map((c) {
                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.18,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    c,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (book.tags.isNotEmpty) ...[
                          Text(
                            '标签',
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: book.tags.take(8).map((t) {
                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  child: Text(
                                    t,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (book.description.isNotEmpty) ...[
                          Text(
                            '简介',
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            book.description,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

bool _hasAnyMetric(MarketRanking r) {
  return (r.favorites != null && r.favorites! > 0) ||
      (r.recommendVotes != null && r.recommendVotes! > 0) ||
      (r.monthlyTickets != null && r.monthlyTickets! > 0) ||
      (r.commentCount != null && r.commentCount! > 0);
}

class _DialogMetricsGrid extends StatelessWidget {
  const _DialogMetricsGrid({required this.ranking});

  final MarketRanking ranking;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (ranking.favorites != null && ranking.favorites! > 0)
          _DialogMetricCard(
            icon: Icons.favorite_border,
            label: '收藏',
            value: _formatCountFull(ranking.favorites!),
            color: const Color(0xFFE53935),
          ),
        if (ranking.recommendVotes != null && ranking.recommendVotes! > 0)
          _DialogMetricCard(
            icon: Icons.thumb_up_outlined,
            label: '推荐票',
            value: _formatCountFull(ranking.recommendVotes!),
            color: const Color(0xFF1E88E5),
          ),
        if (ranking.monthlyTickets != null && ranking.monthlyTickets! > 0)
          _DialogMetricCard(
            icon: Icons.confirmation_number_outlined,
            label: '月票',
            value: _formatCountFull(ranking.monthlyTickets!),
            color: const Color(0xFFF9A825),
          ),
        if (ranking.commentCount != null && ranking.commentCount! > 0)
          _DialogMetricCard(
            icon: Icons.chat_bubble_outline,
            label: '评论',
            value: _formatCountFull(ranking.commentCount!),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
      ],
    );
  }
}

class _DialogMetricCard extends StatelessWidget {
  const _DialogMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: color.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogInfoRow extends StatelessWidget {
  const _DialogInfoRow({
    required this.wordCount,
    required this.status,
    this.publishDate,
  });

  final int wordCount;
  final BookStatus status;
  final DateTime? publishDate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        if (wordCount > 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.text_fields,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                _formatWordCount(wordCount),
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              status == BookStatus.completed
                  ? Icons.check_circle_outline
                  : Icons.edit_outlined,
              size: 14,
              color: status == BookStatus.completed
                  ? const Color(0xFF2E7D32)
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              status == BookStatus.completed ? '已完结' : '连载中',
              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        if (publishDate != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                '${publishDate!.year}-${publishDate!.month.toString().padLeft(2, '0')}-${publishDate!.day.toString().padLeft(2, '0')}',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _PlatformBadge extends StatelessWidget {
  const _PlatformBadge({required this.platform});

  final MarketPlatform platform;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _platformColor(platform, colorScheme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_platformIcon(platform), size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              _platformShortLabel(platform),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Utility ─────────────────────────────────────────────────────────

String _platformLabel(String platform) {
  return switch (platform) {
    'qidian' => '起点中文网',
    'fanqie' => '番茄小说',
    'jinjiang' => '晋江文学城',
    _ => platform,
  };
}

String _platformShortLabel(MarketPlatform platform) {
  return switch (platform) {
    MarketPlatform.qidian => '起点',
    MarketPlatform.fanqie => '番茄',
    MarketPlatform.jinjiang => '晋江',
  };
}

Color _platformColor(MarketPlatform platform, ColorScheme colorScheme) {
  return switch (platform) {
    MarketPlatform.qidian => const Color(0xFF2758D9),
    MarketPlatform.fanqie => const Color(0xFFE64A19),
    MarketPlatform.jinjiang => const Color(0xFFAD1457),
  };
}

IconData _platformIcon(MarketPlatform platform) {
  return switch (platform) {
    MarketPlatform.qidian => Icons.auto_stories_outlined,
    MarketPlatform.fanqie => Icons.local_cafe_outlined,
    MarketPlatform.jinjiang => Icons.local_florist_outlined,
  };
}

String _formatTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return '刚刚';
  if (diff.inMinutes < 60) return '${diff.inMinutes} 分钟前';
  if (diff.inHours < 24) return '${diff.inHours} 小时前';
  return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
}

String _compactTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return '刚刚';
  if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
  if (diff.inHours < 24) return '${diff.inHours}小时前';
  if (diff.inDays < 7) return '${diff.inDays}天前';
  return '${dt.month}/${dt.day}';
}

String _formatCount(int count) {
  if (count >= 100000) return '${count ~/ 10000}万';
  if (count >= 10000) return '${(count / 10000).toStringAsFixed(1)}万';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
  return '$count';
}

String _formatCountFull(int count) {
  if (count >= 100000000) return '${count ~/ 100000000}亿';
  if (count >= 10000) {
    final wan = count ~/ 10000;
    final remainder = (count % 10000) ~/ 1000;
    return remainder > 0 ? '$wan.$remainder万' : '$wan万';
  }
  return count.toString();
}

String _formatWordCount(int count) {
  if (count >= 10000) {
    final wan = count ~/ 10000;
    final remainder = (count % 10000) ~/ 1000;
    return remainder > 0 ? '$wan.$remainder万字' : '$wan万字';
  }
  return '$count 字';
}
