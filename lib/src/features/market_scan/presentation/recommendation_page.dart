import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_route.dart';
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
    // Re-check hasData after scan completes.
    if (mounted) {
      ref.invalidate(marketScanHasDataProvider);
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
        FilledButton.icon(
          onPressed:
              _generating ||
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
        // Scanning in progress — always show progress panel.
        if (scanState.isScanning)
          _ScanProgressPanel(scanState: scanState)
        else
          marketScanState.when(
            data: (hasData) => hasData
                ? _buildRecommendationContent()
                : _MarketDataMissing(onScanNow: _scanNow),
            loading: () => const _MarketDataLoading(),
            error: (error, _) => _MarketDataError(error: error),
          ),

        // Show completed scan results summary below content.
        if (!scanState.isScanning && scanState.platforms.isNotEmpty)
          _ScanResultSummary(scanState: scanState),

        // Show scanned data browser when data exists.
        if (!scanState.isScanning && marketScanState.value == true) ...[
          const SizedBox(height: 14),
          const ScanDataBrowser(),
        ],
      ],
    );
  }

  Widget _buildRecommendationContent() {
    return _state.when(
      data: (directions) {
        if (directions.isEmpty) {
          return const _RecommendationEmpty();
        }
        return _RecommendationList(directions: directions);
      },
      loading: () => const _RecommendationLoading(),
      error: (error, _) => _RecommendationError(error: error),
    );
  }
}

// --- Market data state widgets ---

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

// --- Scan progress panel (real-time) ---

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
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              PersonaStatusPill(
                label: '${scanState.completedCount}/${scanState.platforms.length}',
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
          Text(
            '等待中',
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
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
            entry.itemCount > 0
                ? '${entry.itemCount} 本'
                : '无新数据',
            style: textTheme.labelMedium?.copyWith(
              color: const Color(0xFF2E7D32),
            ),
          ),
        ),
      PlatformScanStatus.failed => (
          Icons.error_outline,
          colorScheme.error,
          Text(
            '失败',
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ),
      PlatformScanStatus.cdpRequired => (
          Icons.open_in_browser_outlined,
          colorScheme.tertiary,
          Text(
            '需要 Chrome',
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.tertiary,
            ),
          ),
        ),
    };

    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            entry.displayName,
            style: textTheme.bodyLarge,
          ),
        ),
        trailing,
      ],
    );
  }
}

// --- Scan result summary (shown after scan completes) ---

class _ScanResultSummary extends StatefulWidget {
  const _ScanResultSummary({required this.scanState});

  final MarketScanState scanState;

  @override
  State<_ScanResultSummary> createState() => _ScanResultSummaryState();
}

class _ScanResultSummaryState extends State<_ScanResultSummary> {
  bool _errorsExpanded = false;

  Color _platformColor(MarketScanState scanState, String platform) {
    return switch (platform) {
      'qidian' => const Color(0xFF2758D9),
      'fanqie' => const Color(0xFFE64A19),
      'jinjiang' => const Color(0xFFAD1457),
      _ => Theme.of(context).colorScheme.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final scanState = widget.scanState;
    final totalItems =
        scanState.platforms.fold<int>(0, (sum, p) => sum + p.itemCount);
    final succeeded = scanState.completedCount;
    final failed = scanState.failedCount;
    final allSuccess = failed == 0;
    final failedPlatforms = scanState.platforms
        .where((p) => p.status == PlatformScanStatus.failed)
        .toList();

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: (allSuccess
                              ? const Color(0xFF2E7D32)
                              : colorScheme.error)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        allSuccess
                            ? Icons.check_circle_outline
                            : Icons.warning_amber_outlined,
                        size: 16,
                        color: allSuccess
                            ? const Color(0xFF2E7D32)
                            : colorScheme.error,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      allSuccess ? '扫描完成' : '扫描完成（部分失败）',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: allSuccess
                            ? const Color(0xFF2E7D32)
                            : colorScheme.error,
                      ),
                    ),
                  ),
                  if (failed > 0)
                    GestureDetector(
                      onTap: () =>
                          setState(() => _errorsExpanded = !_errorsExpanded),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _errorsExpanded ? '收起' : '错误详情',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                          Icon(
                            _errorsExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              // Per-platform breakdown
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: scanState.platforms.map((p) {
                  final pColor = _platformColor(scanState, p.platform);
                  final isSuccess =
                      p.status == PlatformScanStatus.completed;
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSuccess
                                ? Icons.check_circle_outline
                                : Icons.error_outline,
                            size: 14,
                            color: isSuccess
                                ? const Color(0xFF2E7D32)
                                : colorScheme.error,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            p.displayName,
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: pColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              child: Text(
                                isSuccess
                                    ? '${p.itemCount} 本'
                                    : '—',
                                style: textTheme.labelSmall?.copyWith(
                                  color: pColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              // Total
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(width: 4),
                  Text(
                    '共采集 ',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '$totalItems',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    ' 条数据，',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '$succeeded/${scanState.platforms.length}',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: allSuccess
                          ? const Color(0xFF2E7D32)
                          : colorScheme.error,
                    ),
                  ),
                  Text(
                    ' 平台成功',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              // Error details
              if (_errorsExpanded && failedPlatforms.isNotEmpty) ...[
                const SizedBox(height: 12),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.error.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final platform in failedPlatforms)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 14,
                                  color: colorScheme.error,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  platform.displayName,
                                  style: textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    platform.errorMessage ?? '未知错误',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
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

// --- Recommendation state widgets ---

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
              Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
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
    return Column(
      children: [
        for (var i = 0; i < 3; i++) ...[
          const PersonaPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SkeletonBox(width: double.infinity, height: 20),
                    ),
                    SizedBox(width: 12),
                    SkeletonBox(width: 80, height: 24),
                    SizedBox(width: 8),
                    SkeletonBox(width: 60, height: 24),
                  ],
                ),
                SizedBox(height: 14),
                SkeletonBox(width: double.infinity, height: 14),
                SizedBox(height: 8),
                SkeletonBox(width: 400, height: 14),
                SizedBox(height: 8),
                SkeletonBox(width: 260, height: 14),
                SizedBox(height: 16),
                Row(
                  children: [
                    SkeletonBox(width: 100, height: 28),
                    SizedBox(width: 12),
                    SkeletonBox(width: 80, height: 28),
                    SizedBox(width: 12),
                    SkeletonBox(width: 90, height: 28),
                  ],
                ),
              ],
            ),
          ),
          if (i < 2) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

// --- Recommendation card list ---

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
            mainAxisExtent: 310,
          ),
          itemCount: directions.length,
          itemBuilder: (context, index) {
            return _RecommendationCard(direction: directions[index]);
          },
        );
      },
    );
  }
}

// --- Recommendation card ---

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.direction});

  final RecommendationDirection direction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PersonaPanel(
      hoverable: true,
      padding: const EdgeInsets.all(18),
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
            const SizedBox(height: 8),

            // Genre tags
            _GenreTagRow(tags: direction.genreTags),
            const SizedBox(height: 10),

            // Synopsis
            Expanded(
              child: Text(
                direction.synopsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),

            // Metrics row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricBadge(
                  icon: Icons.text_fields,
                  label: _formatWordCount(direction.targetWordCount),
                ),
                _MetricBadge(
                  icon: Icons.local_fire_department_outlined,
                  label: _heatLabel(direction.marketHeatSummary),
                  color: _heatColor(direction.marketHeatSummary, colorScheme),
                ),
                _MetricBadge(
                  icon: Icons.bar_chart_outlined,
                  label: _competitionLabel(direction.competitionSummary),
                  color: _competitionColor(
                    direction.competitionSummary,
                    colorScheme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Action button
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
                        'wordCount': direction.targetWordCount.toString(),
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
    );
  }
}

// --- Helper widgets ---

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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Text(
                tag,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final effectiveColor = color ?? colorScheme.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: effectiveColor.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: effectiveColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Utility functions ---

String _formatWordCount(int count) {
  if (count >= 10000) {
    final wan = count ~/ 10000;
    return '$wan万字';
  }
  return '$count 字';
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

Color _heatColor(String summary, ColorScheme colorScheme) {
  final lower = summary.toLowerCase();
  if (lower.contains('高') || lower.contains('hot') || lower.contains('强')) {
    return const Color(0xFFE65100);
  }
  if (lower.contains('低') || lower.contains('cold') || lower.contains('弱')) {
    return colorScheme.onSurfaceVariant;
  }
  return const Color(0xFFF9A825);
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

Color _competitionColor(String summary, ColorScheme colorScheme) {
  final lower = summary.toLowerCase();
  if (lower.contains('激') || lower.contains('high') || lower.contains('高')) {
    return colorScheme.error;
  }
  if (lower.contains('低') || lower.contains('low') || lower.contains('少')) {
    return const Color(0xFF2E7D32);
  }
  return colorScheme.onSurfaceVariant;
}
