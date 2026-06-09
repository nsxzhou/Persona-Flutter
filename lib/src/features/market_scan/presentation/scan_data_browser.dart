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
  String? _selectedChartKey;
  final TextEditingController _searchController = TextEditingController();
  _RankingSort _sort = _RankingSort.rank;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                totalBooks: bundle.totalBookCount,
                rankingEntries: bundle.totalRankingEntryCount,
                platformCount: bundle.availablePlatforms.length,
                chartCount: bundle.chartCount,
                latestScanTime: bundle.runs.isNotEmpty
                    ? bundle.runs.first.startedAt
                    : null,
              ),
              const SizedBox(height: 20),
            ],
            _buildRankingsWorkspace(bundle),
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

  // ── Rankings Workspace ─────────────────────────────────────────

  Widget _buildRankingsWorkspace(ScanDataBundle bundle) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bookMap = bundle.bookById;
    final filters = <MarketPlatform?>[null, ...MarketPlatform.values];
    final groups = _buildChartGroups(bundle);
    final selectedGroup = groups.isEmpty ? null : _selectedGroup(groups);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '排行榜数据',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '按平台和榜单阅览 ${bundle.totalRankingEntryCount} 条榜单记录；书籍样本 ${bundle.totalBookCount} 本。',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            PersonaStatusPill(
              label: '${bundle.chartCount} 个榜单',
              icon: Icons.leaderboard_outlined,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filters.map((p) {
            final selected = _platformFilter == p;
            final count = p == null
                ? bundle.totalRankingEntryCount
                : bundle.rankingEntryCountForPlatform(p);
            final label = p == null ? '全部' : _platformLabel(p.name);

            return _PlatformFilterChip(
              key: ValueKey('ranking-platform-filter-${p?.name ?? 'all'}'),
              label: '$label $count条',
              icon: p == null ? Icons.library_books_outlined : _platformIcon(p),
              color: p == null
                  ? colorScheme.onSurfaceVariant
                  : _platformColor(p, colorScheme),
              selected: selected,
              onPressed: () => setState(() {
                _platformFilter = p;
                _selectedChartKey = null;
              }),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        _RankingToolbar(
          searchController: _searchController,
          sort: _sort,
          onSearchChanged: (_) => setState(() {}),
          onSortChanged: (sort) => setState(() => _sort = sort),
        ),
        const SizedBox(height: 12),
        if (groups.isEmpty)
          const _EmptyRankingsPlaceholder()
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 820;
              final group = selectedGroup!;
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MobileChartSelector(
                      groups: groups,
                      selectedKey: group.key,
                      onChanged: (key) =>
                          setState(() => _selectedChartKey = key),
                    ),
                    const SizedBox(height: 12),
                    _RankingDetailList(
                      group: group,
                      bookMap: bookMap,
                      searchQuery: _searchController.text,
                      sort: _sort,
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 282,
                    child: _RankingChartDirectory(
                      groups: groups,
                      selectedKey: group.key,
                      onSelected: (key) =>
                          setState(() => _selectedChartKey = key),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _RankingDetailList(
                      group: group,
                      bookMap: bookMap,
                      searchQuery: _searchController.text,
                      sort: _sort,
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  List<_RankingChartGroup> _buildChartGroups(ScanDataBundle bundle) {
    final bookMap = bundle.bookById;
    var filtered = bundle.rankings;
    if (_platformFilter != null) {
      filtered = bundle.rankings.where((r) {
        final book = bookMap[r.bookId];
        return book?.platform == _platformFilter;
      }).toList();
    }

    final grouped = <String, _MutableRankingChartGroup>{};
    for (final ranking in filtered) {
      final platform = bookMap[ranking.bookId]?.platform;
      if (platform == null) {
        continue;
      }
      final key = _chartKey(platform, ranking.chartName);
      grouped.putIfAbsent(
        key,
        () => _MutableRankingChartGroup(
          key: key,
          platform: platform,
          chartName: ranking.chartName,
        ),
      );
      grouped[key]!.rankings.add(ranking);
    }

    final groups = grouped.values
        .map(
          (group) => _RankingChartGroup(
            key: group.key,
            platform: group.platform,
            chartName: group.chartName,
            rankings: group.rankings..sort((a, b) => a.rank.compareTo(b.rank)),
          ),
        )
        .toList();
    groups.sort((a, b) {
      final platform = a.platform.index.compareTo(b.platform.index);
      if (platform != 0) return platform;
      return a.chartName.compareTo(b.chartName);
    });
    return groups;
  }

  _RankingChartGroup _selectedGroup(List<_RankingChartGroup> groups) {
    final selectedKey = _selectedChartKey;
    if (selectedKey != null) {
      for (final group in groups) {
        if (group.key == selectedKey) {
          return group;
        }
      }
    }
    return groups.first;
  }
}

String _chartKey(MarketPlatform platform, String chartName) {
  return '${platform.name}::$chartName';
}

class _MutableRankingChartGroup {
  _MutableRankingChartGroup({
    required this.key,
    required this.platform,
    required this.chartName,
  });

  final String key;
  final MarketPlatform platform;
  final String chartName;
  final List<MarketRanking> rankings = [];
}

class _RankingChartGroup {
  const _RankingChartGroup({
    required this.key,
    required this.platform,
    required this.chartName,
    required this.rankings,
  });

  final String key;
  final MarketPlatform platform;
  final String chartName;
  final List<MarketRanking> rankings;
}

class _PlatformFilterChip extends StatelessWidget {
  const _PlatformFilterChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final backgroundColor = selected
        ? color.withValues(alpha: 0.14)
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45);
    final borderColor = selected
        ? color.withValues(alpha: 0.55)
        : colorScheme.outlineVariant;
    final contentColor = selected ? color : colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 32,
          constraints: const BoxConstraints(minWidth: 76),
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: Icon(icon, size: 14, color: contentColor),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: contentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat Cards Row ────────────────────────────────────────────────────

class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow({
    required this.totalBooks,
    required this.rankingEntries,
    required this.platformCount,
    required this.chartCount,
    this.latestScanTime,
  });

  final int totalBooks;
  final int rankingEntries;
  final int platformCount;
  final int chartCount;
  final DateTime? latestScanTime;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 980
            ? 5
            : constraints.maxWidth >= 860
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
                label: '书籍样本',
                value: '$totalBooks 本',
                color: const Color(0xFF2758D9),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _StatCard(
                icon: Icons.list_alt_outlined,
                label: '榜单条目',
                value: '$rankingEntries 条',
                color: const Color(0xFFE64A19),
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

// ── Ranking Browser ───────────────────────────────────────────────────

enum _RankingSort {
  rank,
  wordCount,
  favorites,
  recommendVotes,
  monthlyTickets,
  comments,
}

class _RankingToolbar extends StatelessWidget {
  const _RankingToolbar({
    required this.searchController,
    required this.sort,
    required this.onSearchChanged,
    required this.onSortChanged,
  });

  final TextEditingController searchController;
  final _RankingSort sort;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<_RankingSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 680;
        final searchField = TextField(
          key: const ValueKey('ranking-search-field'),
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, size: 18),
            suffixIcon: searchController.text.isEmpty
                ? null
                : IconButton(
                    tooltip: '清空搜索',
                    onPressed: () {
                      searchController.clear();
                      onSearchChanged('');
                    },
                    icon: const Icon(Icons.close, size: 18),
                  ),
            labelText: '搜索书名 / 作者',
            border: const OutlineInputBorder(),
          ),
        );
        final sortField = DropdownButtonFormField<_RankingSort>(
          key: const ValueKey('ranking-sort-menu'),
          initialValue: sort,
          decoration: const InputDecoration(
            labelText: '排序',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final value in _RankingSort.values)
              DropdownMenuItem(value: value, child: Text(_sortLabel(value))),
          ],
          onChanged: (value) {
            if (value != null) {
              onSortChanged(value);
            }
          },
        );

        if (compact) {
          return Column(
            children: [searchField, const SizedBox(height: 10), sortField],
          );
        }

        return Row(
          children: [
            Expanded(child: searchField),
            const SizedBox(width: 10),
            SizedBox(width: 180, child: sortField),
          ],
        );
      },
    );
  }
}

class _RankingChartDirectory extends StatelessWidget {
  const _RankingChartDirectory({
    required this.groups,
    required this.selectedKey,
    required this.onSelected,
  });

  final List<_RankingChartGroup> groups;
  final String selectedKey;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final listHeight = (viewportHeight * 0.58).clamp(380.0, 680.0);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: SizedBox(
        height: listHeight,
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Text(
                '榜单目录',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            for (final platform in MarketPlatform.values) ...[
              if (groups.any((group) => group.platform == platform)) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
                  child: Text(
                    _platformLabel(platform.name),
                    style: textTheme.labelSmall?.copyWith(
                      color: _platformColor(platform, colorScheme),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                for (final group in groups.where(
                  (group) => group.platform == platform,
                ))
                  _RankingChartTile(
                    group: group,
                    selected: group.key == selectedKey,
                    onSelected: onSelected,
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _RankingChartTile extends StatelessWidget {
  const _RankingChartTile({
    required this.group,
    required this.selected,
    required this.onSelected,
  });

  final _RankingChartGroup group;
  final bool selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final platformColor = _platformColor(group.platform, colorScheme);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('ranking-chart-${group.key}'),
          onTap: () => onSelected(group.key),
          borderRadius: BorderRadius.circular(8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: selected
                  ? platformColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected
                    ? platformColor.withValues(alpha: 0.38)
                    : Colors.transparent,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      color: platformColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      group.chartName,
                      style: textTheme.labelMedium?.copyWith(
                        color: selected
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${group.rankings.length}条',
                    style: textTheme.labelSmall?.copyWith(
                      color: selected
                          ? platformColor
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileChartSelector extends StatelessWidget {
  const _MobileChartSelector({
    required this.groups,
    required this.selectedKey,
    required this.onChanged,
  });

  final List<_RankingChartGroup> groups;
  final String selectedKey;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: const ValueKey('ranking-chart-selector'),
      initialValue: selectedKey,
      decoration: const InputDecoration(
        labelText: '榜单',
        border: OutlineInputBorder(),
      ),
      items: [
        for (final group in groups)
          DropdownMenuItem(
            value: group.key,
            child: Text(
              '${_platformShortLabel(group.platform)} · ${group.chartName} · ${group.rankings.length}条',
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

class _RankingDetailList extends StatelessWidget {
  const _RankingDetailList({
    required this.group,
    required this.bookMap,
    required this.searchQuery,
    required this.sort,
  });

  final _RankingChartGroup group;
  final Map<String, MarketBook> bookMap;
  final String searchQuery;
  final _RankingSort sort;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final platformColor = _platformColor(group.platform, colorScheme);
    final rankings = _filteredRankings();
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final listHeight = (viewportHeight * 0.58).clamp(380.0, 680.0);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: SizedBox(
        height: listHeight,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  _PlatformBadge(platform: group.platform),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      group.chartName,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: platformColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      child: Text(
                        '${rankings.length}/${group.rankings.length} 条',
                        style: textTheme.labelSmall?.copyWith(
                          color: platformColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colorScheme.outlineVariant),
            Expanded(
              child: rankings.isEmpty
                  ? const _EmptyRankingsPlaceholder()
                  : ListView.builder(
                      key: ValueKey('ranking-detail-${group.key}'),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: rankings.length,
                      itemBuilder: (context, index) {
                        final ranking = rankings[index];
                        return _RankingItem(
                          ranking: ranking,
                          book: bookMap[ranking.bookId],
                          isLast: index == rankings.length - 1,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<MarketRanking> _filteredRankings() {
    final query = searchQuery.trim().toLowerCase();
    var rankings = group.rankings.where((ranking) {
      if (query.isEmpty) {
        return true;
      }
      final book = bookMap[ranking.bookId];
      final title = book?.title.toLowerCase() ?? '';
      final author = book?.author.toLowerCase() ?? '';
      return title.contains(query) || author.contains(query);
    }).toList();

    rankings.sort((a, b) {
      final metric = switch (sort) {
        _RankingSort.rank => a.rank.compareTo(b.rank),
        _RankingSort.wordCount => _metricCompare(
          bookMap[a.bookId]?.totalWordCount ?? 0,
          bookMap[b.bookId]?.totalWordCount ?? 0,
        ),
        _RankingSort.favorites => _metricCompare(
          a.favorites ?? 0,
          b.favorites ?? 0,
        ),
        _RankingSort.recommendVotes => _metricCompare(
          a.recommendVotes ?? 0,
          b.recommendVotes ?? 0,
        ),
        _RankingSort.monthlyTickets => _metricCompare(
          a.monthlyTickets ?? 0,
          b.monthlyTickets ?? 0,
        ),
        _RankingSort.comments => _metricCompare(
          a.commentCount ?? 0,
          b.commentCount ?? 0,
        ),
      };
      return metric == 0 ? a.rank.compareTo(b.rank) : metric;
    });
    return rankings;
  }
}

int _metricCompare(int a, int b) {
  return b.compareTo(a);
}

String _sortLabel(_RankingSort sort) {
  return switch (sort) {
    _RankingSort.rank => '排行顺序',
    _RankingSort.wordCount => '字数优先',
    _RankingSort.favorites => '收藏优先',
    _RankingSort.recommendVotes => '推荐票优先',
    _RankingSort.monthlyTickets => '月票优先',
    _RankingSort.comments => '评论优先',
  };
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
          '${run.itemCount} 条',
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
    _ => platform,
  };
}

String _platformShortLabel(MarketPlatform platform) {
  return switch (platform) {
    MarketPlatform.qidian => '起点',
    MarketPlatform.fanqie => '番茄',
  };
}

Color _platformColor(MarketPlatform platform, ColorScheme colorScheme) {
  return switch (platform) {
    MarketPlatform.qidian => const Color(0xFF2758D9),
    MarketPlatform.fanqie => const Color(0xFFE64A19),
  };
}

IconData _platformIcon(MarketPlatform platform) {
  return switch (platform) {
    MarketPlatform.qidian => Icons.auto_stories_outlined,
    MarketPlatform.fanqie => Icons.local_cafe_outlined,
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
