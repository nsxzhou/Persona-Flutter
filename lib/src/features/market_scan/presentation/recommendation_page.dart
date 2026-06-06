import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_route.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/persona_page.dart';
import '../../../core/ui/skeleton_loader.dart';
import '../application/market_scan_controller.dart';
import '../application/market_scan_providers.dart';
import '../domain/recommendation_direction.dart';
import 'scan_data_browser.dart';

class RecommendationPage extends ConsumerStatefulWidget {
  const RecommendationPage({super.key});

  @override
  ConsumerState<RecommendationPage> createState() =>
      _RecommendationPageState();
}

class _RecommendationPageState extends ConsumerState<RecommendationPage> {
  int _tabIndex = 0;
  AsyncValue<List<RecommendationDirection>> _state =
      const AsyncData(<RecommendationDirection>[]);
  bool _generating = false;

  Future<void> _generate() async {
    setState(() {
      _generating = true;
      _state = const AsyncLoading();
    });
    try {
      final service = ref.read(recommendationGenerationServiceProvider);
      final directions = await service.generate();
      if (mounted) {
        setState(() {
          _state = AsyncData(directions);
          _generating = false;
        });
      }
    } on Object catch (error, stackTrace) {
      if (mounted) {
        setState(() {
          _state = AsyncError(error, stackTrace);
          _generating = false;
        });
      }
    }
  }

  Future<void> _scanNow() async {
    await ref.read(marketScanControllerProvider.notifier).scanNow();
    if (mounted) {
      ref.invalidate(marketScanHasDataProvider);
      ref.invalidate(scanDataBundleProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final marketScanState = ref.watch(marketScanHasDataProvider);
    final scanState = ref.watch(marketScanControllerProvider);

    return PersonaPage(
      eyebrow: 'AI 推荐',
      title: '创作方向推荐',
      description:
          '基于当前市场扫描数据，由 AI 分析热门趋势和竞争格局，为下一个创作项目推荐方向。',
      actions: [
        OutlinedButton.icon(
          onPressed: () => context.go(AppRoute.projects.path),
          icon: const Icon(Icons.arrow_back),
          label: const Text('返回项目'),
        ),
        OutlinedButton.icon(
          onPressed: _generating || scanState.isScanning ? null : _scanNow,
          icon: scanState.isScanning
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.radar_outlined),
          label: Text(scanState.isScanning ? '扫描中...' : '重新扫描'),
        ),
        FilledButton.icon(
          onPressed: _generating ||
                  marketScanState.value != true ||
                  scanState.isScanning
              ? null
              : _generate,
          icon: _generating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome),
          label: Text(_generating ? '生成中...' : '生成推荐'),
        ),
      ],
      children: [
        if (scanState.isScanning)
          _ScanProgressPanel(scanState: scanState)
        else
          marketScanState.when(
            data: (hasData) =>
                hasData ? _buildMainContent(scanState) : _MarketDataMissing(onScanNow: _scanNow),
            loading: () => const _MarketDataLoading(),
            error: (error, _) => _MarketDataError(error: error),
          ),
      ],
    );
  }

  Widget _buildMainContent(MarketScanState scanState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageTabBar(
          selectedIndex: _tabIndex,
          labels: const ['创作推荐', '扫描数据概览'],
          onTap: (i) => setState(() => _tabIndex = i),
        ),
        const SizedBox(height: 20),
        Visibility(
          visible: _tabIndex == 0,
          maintainState: true,
          maintainAnimation: true,
          maintainSize: false,
          child: _buildRecommendationsTab(scanState),
        ),
        Visibility(
          visible: _tabIndex == 1,
          maintainState: true,
          maintainAnimation: true,
          maintainSize: false,
          child: const ScanDataBrowser(showHeader: false),
        ),
      ],
    );
  }

  Widget _buildRecommendationsTab(MarketScanState scanState) {
    return _state.when(
      data: (directions) {
        if (directions.isEmpty) return const _RecommendationEmpty();
        return _RecommendationList(directions: directions);
      },
      loading: () => const _RecommendationLoading(),
      error: (error, _) => _RecommendationError(error: error),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Tab Bar
// ═══════════════════════════════════════════════════════════════════

class _PageTabBar extends StatelessWidget {
  const _PageTabBar({
    required this.selectedIndex,
    required this.labels,
    required this.onTap,
  });

  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(kButtonRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            for (int i = 0; i < labels.length; i++)
              Expanded(
                child: _TabButton(
                  label: labels[i],
                  isSelected: i == selectedIndex,
                  onTap: () => onTap(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(kButtonRadius - 2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Market Data State Widgets
// ═══════════════════════════════════════════════════════════════════

class _MarketDataMissing extends StatelessWidget {
  const _MarketDataMissing({required this.onScanNow});
  final VoidCallback onScanNow;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.18),
                    ),
                  ),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: Icon(
                      Icons.radar_outlined,
                      color: colorScheme.primary,
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '尚无市场扫描数据',
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  'AI 推荐需要市场扫描数据作为基础。点击下方按钮立即采集起点、番茄、晋江三大平台的榜单数据。',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 26),
                FilledButton.icon(
                  onPressed: onScanNow,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('立即扫描市场数据'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanProgressPanel extends StatelessWidget {
  const _ScanProgressPanel({required this.scanState});
  final MarketScanState scanState;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: PersonaPanel(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '正在扫描市场数据',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 10),
                  PersonaStatusPill(
                    label:
                        '${scanState.completedCount}/${scanState.platforms.length}',
                    icon: Icons.radar_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < scanState.platforms.length; i++) ...[
                _PlatformProgressRow(entry: scanState.platforms[i]),
                if (i < scanState.platforms.length - 1)
                  const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlatformProgressRow extends StatelessWidget {
  const _PlatformProgressRow({required this.entry});
  final PlatformScanEntry entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (icon, iconColor, trailing) = switch (entry.status) {
      PlatformScanStatus.pending => (
          Icons.hourglass_empty_outlined,
          colorScheme.onSurfaceVariant,
          Text('等待中',
              style: textTheme.labelMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
        ),
      PlatformScanStatus.scanning => (
          Icons.sync_outlined,
          colorScheme.primary,
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      PlatformScanStatus.completed => (
          Icons.check_circle_outline,
          const Color(0xFF2E7D32),
          Text(
            entry.itemCount > 0 ? '${entry.itemCount} 本' : '无新数据',
            style: textTheme.labelMedium
                ?.copyWith(color: const Color(0xFF2E7D32)),
          ),
        ),
      PlatformScanStatus.failed => (
          Icons.error_outline,
          colorScheme.error,
          Text('失败',
              style:
                  textTheme.labelMedium?.copyWith(color: colorScheme.error)),
        ),
      PlatformScanStatus.cdpRequired => (
          Icons.open_in_browser_outlined,
          colorScheme.tertiary,
          Text('需要 Chrome',
              style:
                  textTheme.labelMedium?.copyWith(color: colorScheme.tertiary)),
        ),
    };

    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(entry.displayName, style: textTheme.bodyLarge),
        ),
        trailing,
      ],
    );
  }
}

class _MarketDataLoading extends StatelessWidget {
  const _MarketDataLoading();

  @override
  Widget build(BuildContext context) {
    return const PersonaPanel(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 14),
            Text('正在检查市场数据...'),
          ],
        ),
      ),
    );
  }
}

class _MarketDataError extends StatelessWidget {
  const _MarketDataError({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return PersonaPanel(
      child: Text(
        '无法加载市场数据状态：$error',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Recommendation State Widgets
// ═══════════════════════════════════════════════════════════════════

class _RecommendationEmpty extends StatelessWidget {
  const _RecommendationEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: const PersonaEmptyStateCard(
          icon: Icons.auto_awesome_outlined,
          title: '尚未生成推荐',
          description: '点击右上角「生成推荐」按钮，AI 将基于当前市场数据为你分析创作方向。',
          centered: true,
        ),
      ),
    );
  }
}

class _RecommendationError extends StatelessWidget {
  const _RecommendationError({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return PersonaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline,
                  color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 10),
              Text(
                '生成推荐失败',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$error',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationLoading extends StatelessWidget {
  const _RecommendationLoading();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth >= 700 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 290,
          ),
          itemCount: 4,
          itemBuilder: (context, _) => const _SkeletonCard(),
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return const PersonaPanel(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: double.infinity, height: 22),
          SizedBox(height: 10),
          SkeletonBox(width: 180, height: 14),
          SizedBox(height: 16),
          SkeletonBox(width: double.infinity, height: 12),
          SizedBox(height: 8),
          SkeletonBox(width: 400, height: 12),
          Spacer(),
          Row(children: [
            SkeletonBox(width: 90, height: 28),
            SizedBox(width: 10),
            SkeletonBox(width: 90, height: 28),
            SizedBox(width: 10),
            SkeletonBox(width: 90, height: 28),
          ]),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Recommendation List & Market Insight Cards
// ═══════════════════════════════════════════════════════════════════

class _RecommendationList extends StatelessWidget {
  const _RecommendationList({required this.directions});
  final List<RecommendationDirection> directions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth >= 700 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 290,
          ),
          itemCount: directions.length,
          itemBuilder: (context, index) => _MarketInsightCard(
            direction: directions[index],
            index: index,
          ),
        );
      },
    );
  }
}

class _MarketInsightCard extends StatelessWidget {
  const _MarketInsightCard({required this.direction, required this.index});

  final RecommendationDirection direction;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final heatClr = _heatColor(direction.marketHeatSummary);
    final compClr = _competitionColor(direction.competitionSummary, colorScheme);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) {
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - v)),
            child: child,
          ),
        );
      },
      child: PersonaPanel(
        hoverable: true,
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kPanelRadius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top accent bar
              Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [heatClr, compClr]),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        direction.suggestedTitle,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Genre tags
                      _GenreTagRow(tags: direction.genreTags),
                      const SizedBox(height: 10),

                      // Synopsis
                      Expanded(
                        child: Text(
                          direction.synopsis,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.55,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Metrics bar
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _CardMetric(
                              icon: Icons.text_fields,
                              label: '目标字数',
                              value: _formatWordCount(direction.targetWordCount),
                            ),
                            const SizedBox(width: 14),
                            _VerticalDivider(),
                            const SizedBox(width: 14),
                            _CardMetric(
                              icon: Icons.local_fire_department_outlined,
                              label: '市场热度',
                              value: _heatLabel(direction.marketHeatSummary),
                              valueColor: heatClr,
                            ),
                            const SizedBox(width: 14),
                            _VerticalDivider(),
                            const SizedBox(width: 14),
                            _CardMetric(
                              icon: Icons.bar_chart_outlined,
                              label: '竞争程度',
                              value: _competitionLabel(
                                  direction.competitionSummary),
                              valueColor: compClr,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Action
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: () {
                            final uri = Uri(
                              path: '/projects/create',
                              queryParameters: {
                                'title': direction.suggestedTitle,
                                'synopsis': direction.synopsis,
                                if (direction.genreTags.isNotEmpty)
                                  'tags': direction.genreTags.join(','),
                                if (direction.targetWordCount > 0)
                                  'wordCount':
                                      direction.targetWordCount.toString(),
                              },
                            );
                            context.go(uri.toString());
                          },
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: const Text('使用此方向'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 18,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}

class _CardMetric extends StatelessWidget {
  const _CardMetric({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final effectiveColor = valueColor ?? colorScheme.onSurfaceVariant;

    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: effectiveColor),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 9,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: effectiveColor,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreTagRow extends StatelessWidget {
  const _GenreTagRow({required this.tags});
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final visible = tags.take(3).toList();
    final remaining = tags.length - visible.length;

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        for (final tag in visible)
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              child: Text(
                tag,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (remaining > 0)
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              child: Text(
                '+$remaining',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }
}


String _formatWordCount(int count) {
  if (count >= 10000) {
    final wan = count ~/ 10000;
    final remainder = (count % 10000) ~/ 1000;
    return remainder > 0 ? '$wan.$remainder万字' : '$wan万字';
  }
  return '$count 字';
}

Color _heatColor(String summary) {
  final lower = summary.toLowerCase();
  if (lower.contains('高') || lower.contains('hot') || lower.contains('强')) {
    return const Color(0xFFE65100);
  }
  if (lower.contains('低') || lower.contains('cold') || lower.contains('弱')) {
    return const Color(0xFF78909C);
  }
  return const Color(0xFFF9A825);
}

String _heatLabel(String summary) {
  final lower = summary.toLowerCase();
  if (lower.contains('高') || lower.contains('hot') || lower.contains('强')) {
    return '热度高';
  }
  if (lower.contains('低') || lower.contains('cold') || lower.contains('弱')) {
    return '热度低';
  }
  return '热度中';
}

Color _competitionColor(String summary, ColorScheme colorScheme) {
  final lower = summary.toLowerCase();
  if (lower.contains('激') || lower.contains('high') || lower.contains('高')) {
    return colorScheme.error;
  }
  if (lower.contains('低') || lower.contains('low') || lower.contains('少')) {
    return const Color(0xFF2E7D32);
  }
  return const Color(0xFF78909C);
}

String _competitionLabel(String summary) {
  final lower = summary.toLowerCase();
  if (lower.contains('激') || lower.contains('high') || lower.contains('高')) {
    return '竞争激烈';
  }
  if (lower.contains('低') || lower.contains('low') || lower.contains('少')) {
    return '竞争较低';
  }
  return '竞争适中';
}
