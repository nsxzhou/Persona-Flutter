import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_route.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/persona_page.dart';
import '../../../core/ui/skeleton_loader.dart';
import '../../workflow_runs/application/workflow_task_controller.dart';
import '../application/market_recommendation_controller.dart';
import '../application/market_scan_controller.dart';
import '../application/market_scan_providers.dart';
import '../domain/market_book.dart';
import '../domain/market_scan_run.dart';
import '../domain/recommendation_direction.dart';
import '../domain/recommendation_generation_request.dart';
import 'scan_data_browser.dart';

enum _WorkspaceView { overview, rankings, recommendations, history }

class RecommendationPage extends ConsumerStatefulWidget {
  const RecommendationPage({super.key});

  @override
  ConsumerState<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends ConsumerState<RecommendationPage> {
  _WorkspaceView _activeView = _WorkspaceView.overview;
  final TextEditingController _genreQueryController = TextEditingController();
  MarketPlatform? _selectedPlatform;

  @override
  void dispose() {
    _genreQueryController.dispose();
    super.dispose();
  }

  void _setActiveView(_WorkspaceView view) {
    if (!mounted || _activeView == view) {
      return;
    }
    setState(() => _activeView = view);
  }

  Future<void> _generate() async {
    final bundle = ref.read(scanDataBundleProvider).value;
    final platforms = _availablePlatforms(bundle);
    final selected = _selectedPlatform;
    final platform = selected != null && platforms.contains(selected)
        ? selected
        : (platforms.isEmpty ? null : platforms.first);
    if (platform == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先选择有扫描数据的平台。')));
      return;
    }
    _setActiveView(_WorkspaceView.recommendations);
    await _runCommand(
      () => ref
          .read(marketRecommendationControllerProvider.notifier)
          .generate(
            RecommendationGenerationRequest(
              targetPlatform: platform,
              genreQuery: _genreQueryController.text,
            ),
          ),
    );
  }

  Future<void> _scanNow() async {
    _setActiveView(_WorkspaceView.overview);
    await _runCommand(
      () => ref.read(marketScanControllerProvider.notifier).scanNow(),
    );
  }

  Future<void> _clearScanData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空扫描数据'),
        content: const Text(
          '将删除所有市场书籍、榜单和扫描记录，同时清空当前推荐结果。Workflow Runs 中的任务审计记录会保留。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('确认清空'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    if (!mounted) {
      return;
    }
    _setActiveView(_WorkspaceView.overview);
    await _runCommand(
      () => ref.read(marketScanControllerProvider.notifier).clearAllData(),
    );
  }

  Future<void> _abandonTask(String taskId) async {
    await _runCommand(
      () => ref.read(workflowTaskControllerProvider.notifier).abandon(taskId),
    );
  }

  Future<void> _runCommand(Future<void> Function() command) async {
    try {
      await command();
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final marketScanState = ref.watch(marketScanHasDataProvider);
    final scanState = ref.watch(marketScanControllerProvider);
    final recommendationState = ref.watch(
      marketRecommendationControllerProvider,
    );
    final bundleState = ref.watch(scanDataBundleProvider);
    final availablePlatforms = _availablePlatforms(bundleState.value);
    final selected = _selectedPlatform;
    final effectivePlatform =
        selected != null && availablePlatforms.contains(selected)
        ? selected
        : (availablePlatforms.isEmpty ? null : availablePlatforms.first);
    final hasData = marketScanState.value == true;
    final runningTaskId = scanState.isScanning
        ? scanState.workflowTaskId
        : recommendationState.isGenerating
        ? recommendationState.workflowTaskId
        : null;

    return PersonaPage(
      eyebrow: 'AI 推荐',
      title: '创作方向推荐',
      description: '先审阅市场榜单和扫描质量，再基于可信数据生成创作方向。',
      maxWidth: 1380,
      actions: [
        OutlinedButton.icon(
          onPressed: () => context.go(AppRoute.projects.path),
          icon: const Icon(Icons.arrow_back),
          label: const Text('返回项目'),
        ),
      ],
      children: [
        _RecommendationWorkspace(
          hasData: marketScanState,
          bundle: bundleState,
          scanState: scanState,
          recommendationState: recommendationState,
          hasMarketData: hasData,
          runningTaskId: runningTaskId,
          activeView: _activeView,
          availablePlatforms: availablePlatforms,
          selectedPlatform: effectivePlatform,
          genreQueryController: _genreQueryController,
          onPlatformChanged: (platform) =>
              setState(() => _selectedPlatform = platform),
          onViewChanged: _setActiveView,
          onScanNow: _scanNow,
          onGenerate: _generate,
          onClearScanData: _clearScanData,
          onAbandonTask: _abandonTask,
        ),
      ],
    );
  }

  List<MarketPlatform> _availablePlatforms(ScanDataBundle? bundle) {
    if (bundle == null) {
      return const [];
    }
    final platforms = bundle.books.map((book) => book.platform).toSet();
    final ordered = <MarketPlatform>[
      MarketPlatform.qidian,
      MarketPlatform.fanqie,
    ];
    return ordered.where(platforms.contains).toList(growable: false);
  }
}

class _RecommendationWorkspace extends StatelessWidget {
  const _RecommendationWorkspace({
    required this.hasData,
    required this.bundle,
    required this.scanState,
    required this.recommendationState,
    required this.hasMarketData,
    required this.runningTaskId,
    required this.activeView,
    required this.availablePlatforms,
    required this.selectedPlatform,
    required this.genreQueryController,
    required this.onPlatformChanged,
    required this.onViewChanged,
    required this.onScanNow,
    required this.onGenerate,
    required this.onClearScanData,
    required this.onAbandonTask,
  });

  final AsyncValue<bool> hasData;
  final AsyncValue<ScanDataBundle> bundle;
  final MarketScanState scanState;
  final MarketRecommendationState recommendationState;
  final bool hasMarketData;
  final String? runningTaskId;
  final _WorkspaceView activeView;
  final List<MarketPlatform> availablePlatforms;
  final MarketPlatform? selectedPlatform;
  final TextEditingController genreQueryController;
  final ValueChanged<MarketPlatform> onPlatformChanged;
  final ValueChanged<_WorkspaceView> onViewChanged;
  final Future<void> Function() onScanNow;
  final Future<void> Function() onGenerate;
  final Future<void> Function() onClearScanData;
  final Future<void> Function(String taskId) onAbandonTask;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 1080;
        final genreOptions = _genreOptionsForPlatform(
          bundle.value?.books ?? const [],
          selectedPlatform,
        );
        final dataColumn = _WorkspaceMainPanel(
          hasData: hasData,
          bundle: bundle,
          scanState: scanState,
          recommendationState: recommendationState,
          activeView: activeView,
          onViewChanged: onViewChanged,
          onScanNow: onScanNow,
        );
        final commandPanel = _TaskCommandPanel(
          hasMarketData: hasMarketData,
          scanState: scanState,
          recommendationState: recommendationState,
          availablePlatforms: availablePlatforms,
          selectedPlatform: selectedPlatform,
          genreOptions: genreOptions,
          genreQueryController: genreQueryController,
          onPlatformChanged: onPlatformChanged,
          runningTaskId: runningTaskId,
          onScanNow: onScanNow,
          onGenerate: onGenerate,
          onClearScanData: onClearScanData,
          onAbandonTask: onAbandonTask,
        );

        if (!useRail) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [dataColumn, const SizedBox(height: 16), commandPanel],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: dataColumn),
            const SizedBox(width: 18),
            SizedBox(width: 348, child: commandPanel),
          ],
        );
      },
    );
  }

  List<String> _genreOptionsForPlatform(
    List<MarketBook> books,
    MarketPlatform? platform,
  ) {
    if (platform == null) {
      return const [];
    }
    final counts = <String, int>{};
    for (final book in books.where((book) => book.platform == platform)) {
      for (final tag in [...book.categories, ...book.tags]) {
        final normalized = tag.trim();
        if (normalized.isEmpty) {
          continue;
        }
        counts[normalized] = (counts[normalized] ?? 0) + 1;
      }
    }
    final entries = counts.entries.toList()
      ..sort((a, b) {
        final count = b.value.compareTo(a.value);
        return count == 0 ? a.key.compareTo(b.key) : count;
      });
    return entries.map((entry) => entry.key).take(8).toList(growable: false);
  }
}

class _WorkspaceMainPanel extends StatelessWidget {
  const _WorkspaceMainPanel({
    required this.hasData,
    required this.bundle,
    required this.scanState,
    required this.recommendationState,
    required this.activeView,
    required this.onViewChanged,
    required this.onScanNow,
  });

  final AsyncValue<bool> hasData;
  final AsyncValue<ScanDataBundle> bundle;
  final MarketScanState scanState;
  final MarketRecommendationState recommendationState;
  final _WorkspaceView activeView;
  final ValueChanged<_WorkspaceView> onViewChanged;
  final Future<void> Function() onScanNow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MarketSummaryPanel(
          hasData: hasData,
          bundle: bundle,
          scanState: scanState,
          recommendationState: recommendationState,
        ),
        const SizedBox(height: 12),
        _WorkspaceViewSwitcher(value: activeView, onChanged: onViewChanged),
        const SizedBox(height: 12),
        _WorkspaceViewBody(
          activeView: activeView,
          hasData: hasData,
          bundle: bundle,
          scanState: scanState,
          recommendationState: recommendationState,
          onScanNow: onScanNow,
          onViewChanged: onViewChanged,
        ),
      ],
    );
  }
}

class _WorkspaceViewBody extends StatelessWidget {
  const _WorkspaceViewBody({
    required this.activeView,
    required this.hasData,
    required this.bundle,
    required this.scanState,
    required this.recommendationState,
    required this.onScanNow,
    required this.onViewChanged,
  });

  final _WorkspaceView activeView;
  final AsyncValue<bool> hasData;
  final AsyncValue<ScanDataBundle> bundle;
  final MarketScanState scanState;
  final MarketRecommendationState recommendationState;
  final Future<void> Function() onScanNow;
  final ValueChanged<_WorkspaceView> onViewChanged;

  @override
  Widget build(BuildContext context) {
    return switch (activeView) {
      _WorkspaceView.overview => hasData.when(
        data: (hasMarketData) => hasMarketData
            ? bundle.when(
                data: (data) => _WorkspaceOverview(
                  bundle: data,
                  scanState: scanState,
                  recommendationState: recommendationState,
                  onOpenRankings: () => onViewChanged(_WorkspaceView.rankings),
                  onOpenRecommendations: () =>
                      onViewChanged(_WorkspaceView.recommendations),
                ),
                loading: () => const _MarketDataLoading(),
                error: (error, _) => _MarketDataError(error: error),
              )
            : _MarketDataMissing(onScanNow: onScanNow),
        loading: () => const _MarketDataLoading(),
        error: (error, _) => _MarketDataError(error: error),
      ),
      _WorkspaceView.rankings => hasData.when(
        data: (hasMarketData) => hasMarketData
            ? const ScanDataBrowser(
                showHeader: false,
                showStats: false,
                showHistory: false,
              )
            : _MarketDataMissing(onScanNow: onScanNow),
        loading: () => const _MarketDataLoading(),
        error: (error, _) => _MarketDataError(error: error),
      ),
      _WorkspaceView.recommendations => hasData.when(
        data: (hasMarketData) => hasMarketData
            ? _RecommendationSection(recommendationState: recommendationState)
            : _MarketDataMissing(onScanNow: onScanNow),
        loading: () => const _MarketDataLoading(),
        error: (error, _) => _MarketDataError(error: error),
      ),
      _WorkspaceView.history => bundle.when(
        data: (data) => _ScanHistoryWorkspace(runs: data.runs),
        loading: () => const _MarketDataLoading(),
        error: (error, _) => _MarketDataError(error: error),
      ),
    };
  }
}

class _WorkspaceViewSwitcher extends StatelessWidget {
  const _WorkspaceViewSwitcher({required this.value, required this.onChanged});

  final _WorkspaceView value;
  final ValueChanged<_WorkspaceView> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final view in _WorkspaceView.values)
          _WorkspaceViewChip(
            view: view,
            selected: value == view,
            onPressed: () => onChanged(view),
          ),
      ],
    );
  }
}

class _WorkspaceViewChip extends StatelessWidget {
  const _WorkspaceViewChip({
    required this.view,
    required this.selected,
    required this.onPressed,
  });

  final _WorkspaceView view;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = selected ? colorScheme.primary : colorScheme.outlineVariant;

    return Material(
      key: ValueKey('workspace-view-${view.name}'),
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.1)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_viewIcon(view), size: 15, color: color),
                const SizedBox(width: 7),
                Text(
                  _viewLabel(view),
                  style: textTheme.labelMedium?.copyWith(
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkspaceOverview extends StatelessWidget {
  const _WorkspaceOverview({
    required this.bundle,
    required this.scanState,
    required this.recommendationState,
    required this.onOpenRankings,
    required this.onOpenRecommendations,
  });

  final ScanDataBundle bundle;
  final MarketScanState scanState;
  final MarketRecommendationState recommendationState;
  final VoidCallback onOpenRankings;
  final VoidCallback onOpenRecommendations;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final platformCount = bundle.books
        .map((book) => book.platform)
        .toSet()
        .length;
    final chartCount = bundle.rankings.map((r) => r.chartName).toSet().length;
    final latestRun = bundle.runs.isNotEmpty ? bundle.runs.first : null;
    final hasRecommendationActivity =
        recommendationState.isGenerating ||
        recommendationState.hasDirections ||
        recommendationState.errorMessage != null;
    final readinessLabel = scanState.isScanning ? '更新中' : '可生成';
    final readinessTitle = scanState.isScanning ? '市场数据正在更新' : '市场数据已准备，可以生成推荐';
    final readinessDescription = latestRun == null
        ? '当前已有 ${bundle.books.length} 本书和 $chartCount 个榜单，可先审阅榜单质量。'
        : '覆盖 $platformCount 个平台、${bundle.books.length} 本书、$chartCount 个榜单；最近扫描 ${_formatRadarTime(latestRun.startedAt)}。';

    return PersonaPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    scanState.isScanning
                        ? Icons.sync_outlined
                        : Icons.task_alt_outlined,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      readinessTitle,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      readinessDescription,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              PersonaStatusPill(
                label: readinessLabel,
                icon: scanState.isScanning
                    ? Icons.sync
                    : Icons.check_circle_outline,
              ),
            ],
          ),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: _RecommendationOverviewSummary(
                state: recommendationState,
                onOpenRecommendations: onOpenRecommendations,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: onOpenRankings,
                icon: const Icon(Icons.leaderboard_outlined),
                label: const Text('查看完整榜单'),
              ),
              if (hasRecommendationActivity)
                FilledButton.tonalIcon(
                  onPressed: onOpenRecommendations,
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: const Text('查看推荐详情'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecommendationOverviewSummary extends StatelessWidget {
  const _RecommendationOverviewSummary({
    required this.state,
    required this.onOpenRecommendations,
  });

  final MarketRecommendationState state;
  final VoidCallback onOpenRecommendations;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (state.isGenerating) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '推荐正在生成',
            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          const LinearProgressIndicator(minHeight: 3),
          const SizedBox(height: 10),
          Text(
            '完成后可在「推荐」视图查看完整方向卡片。',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    if (state.errorMessage != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 18, color: colorScheme.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '推荐任务失败，可切到「推荐」视图查看错误详情。',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ],
      );
    }

    if (!state.hasDirections) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            size: 18,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '尚未生成创作方向。右侧生成后，这里只保留摘要，完整结果进入「推荐」视图查看。',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '最新推荐摘要',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${state.directions.length} 个方向',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final direction in state.directions.take(2)) ...[
          _RecommendationPreviewRow(direction: direction),
          const SizedBox(height: 8),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onOpenRecommendations,
            icon: const Icon(Icons.open_in_new_outlined, size: 16),
            label: const Text('打开完整推荐'),
          ),
        ),
      ],
    );
  }
}

class _RecommendationPreviewRow extends StatelessWidget {
  const _RecommendationPreviewRow({required this.direction});

  final RecommendationDirection direction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 7),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                direction.suggestedTitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (direction.genreTags.isNotEmpty)
                Text(
                  direction.genreTags.take(3).join(' / '),
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScanHistoryWorkspace extends StatelessWidget {
  const _ScanHistoryWorkspace({required this.runs});

  final List<MarketScanRun> runs;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final visibleRuns = runs.take(12).toList(growable: false);

    return PersonaPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history_outlined,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '扫描历史',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              PersonaStatusPill(label: '${runs.length} 条', icon: Icons.list),
            ],
          ),
          const SizedBox(height: 12),
          if (runs.isEmpty)
            Text(
              '暂无扫描记录',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          else
            for (var i = 0; i < visibleRuns.length; i++) ...[
              _ScanHistoryWorkspaceRow(run: visibleRuns[i]),
              if (i < visibleRuns.length - 1)
                Divider(height: 16, color: colorScheme.outlineVariant),
            ],
        ],
      ),
    );
  }
}

class _ScanHistoryWorkspaceRow extends StatelessWidget {
  const _ScanHistoryWorkspaceRow({required this.run});

  final MarketScanRun run;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColor = _scanRunStatusColor(run.status, colorScheme);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(_scanRunStatusIcon(run.status), size: 17, color: statusColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _platformDisplayName(run.platform),
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatRadarTime(run.startedAt),
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (run.errorMessage != null && run.errorMessage!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  run.errorMessage!,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          run.status == MarketScanRunStatus.completed
              ? '${run.itemCount} 本'
              : _scanRunStatusLabel(run.status),
          style: textTheme.labelMedium?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _MarketSummaryPanel extends StatelessWidget {
  const _MarketSummaryPanel({
    required this.hasData,
    required this.bundle,
    required this.scanState,
    required this.recommendationState,
  });

  final AsyncValue<bool> hasData;
  final AsyncValue<ScanDataBundle> bundle;
  final MarketScanState scanState;
  final MarketRecommendationState recommendationState;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final data = bundle.value;
    final platformCount =
        data?.books.map((book) => book.platform).toSet().length ?? 0;
    final chartCount =
        data?.rankings.map((r) => r.chartName).toSet().length ?? 0;
    final bookCount = data?.books.length ?? 0;
    final latestRun = data?.runs.isNotEmpty == true ? data!.runs.first : null;
    final hasMarketData = hasData.value == true;
    final scanLabel = scanState.isScanning
        ? '扫描中'
        : scanState.isClearing
        ? '清空中'
        : hasMarketData
        ? '可用'
        : '待扫描';
    final recommendationLabel = recommendationState.isGenerating
        ? '生成中'
        : recommendationState.hasDirections
        ? '${recommendationState.directions.length} 个方向'
        : '待生成';
    final totalPlatformCount = scanState.platforms.isNotEmpty
        ? scanState.platforms.length
        : 3;

    return PersonaPanel(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.16),
                  ),
                ),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.radar_outlined, color: colorScheme.primary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '市场数据工作台',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      latestRun == null
                          ? '先完成一次扫描，再用可用平台数据生成创作方向。'
                          : '最近扫描 ${_formatRadarTime(latestRun.startedAt)}，推荐可基于已完成平台生成。',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              PersonaStatusPill(
                label: scanLabel,
                icon: scanState.isScanning ? Icons.sync : Icons.insights,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SummaryPill(
                icon: Icons.public_outlined,
                label: '平台',
                value: hasMarketData
                    ? '$platformCount/$totalPlatformCount'
                    : '--',
              ),
              _SummaryPill(
                icon: Icons.menu_book_outlined,
                label: '书籍',
                value: hasMarketData ? '$bookCount' : '--',
              ),
              _SummaryPill(
                icon: Icons.leaderboard_outlined,
                label: '榜单',
                value: hasMarketData ? '$chartCount' : '--',
              ),
              _SummaryPill(
                icon: Icons.auto_awesome_outlined,
                label: '推荐',
                value: recommendationLabel,
              ),
              _SummaryPill(
                icon: Icons.history_outlined,
                label: '最近扫描',
                value: latestRun == null
                    ? '--'
                    : _formatRadarTime(latestRun.startedAt),
              ),
            ],
          ),
          if (scanState.platforms.isNotEmpty) ...[
            const SizedBox(height: 14),
            _PlatformCoverageStrip(platforms: scanState.platforms),
          ],
          if (scanState.error != null) ...[
            const SizedBox(height: 14),
            _WorkflowNotice(
              icon: Icons.error_outline,
              title: '扫描任务异常',
              message: scanState.error!,
              isError: true,
            ),
          ],
          if (recommendationState.errorMessage != null) ...[
            const SizedBox(height: 14),
            _WorkflowNotice(
              icon: Icons.error_outline,
              title: '推荐任务失败',
              message: recommendationState.errorMessage!,
              isError: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: colorScheme.primary),
            const SizedBox(width: 7),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCommandPanel extends StatelessWidget {
  const _TaskCommandPanel({
    required this.hasMarketData,
    required this.scanState,
    required this.recommendationState,
    required this.availablePlatforms,
    required this.selectedPlatform,
    required this.genreOptions,
    required this.genreQueryController,
    required this.onPlatformChanged,
    required this.runningTaskId,
    required this.onScanNow,
    required this.onGenerate,
    required this.onClearScanData,
    required this.onAbandonTask,
  });

  final bool hasMarketData;
  final MarketScanState scanState;
  final MarketRecommendationState recommendationState;
  final List<MarketPlatform> availablePlatforms;
  final MarketPlatform? selectedPlatform;
  final List<String> genreOptions;
  final TextEditingController genreQueryController;
  final ValueChanged<MarketPlatform> onPlatformChanged;
  final String? runningTaskId;
  final Future<void> Function() onScanNow;
  final Future<void> Function() onGenerate;
  final Future<void> Function() onClearScanData;
  final Future<void> Function(String taskId) onAbandonTask;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isRunning = scanState.isScanning || recommendationState.isGenerating;
    final commandsDisabled = isRunning || scanState.isClearing;
    final canGenerate =
        hasMarketData && selectedPlatform != null && !commandsDisabled;
    final taskLabel = isRunning
        ? '运行中'
        : scanState.isClearing
        ? '清空中'
        : '空闲';
    final recommendationLabel = recommendationState.isGenerating
        ? '生成中'
        : recommendationState.hasDirections
        ? '${recommendationState.directions.length} 个方向'
        : '待生成';

    return PersonaPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_outlined, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '任务控制',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              PersonaStatusPill(
                label: taskLabel,
                icon: isRunning ? Icons.sync : Icons.task_alt_outlined,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _StatusLine(
            icon: Icons.dataset_outlined,
            label: '市场数据',
            value: hasMarketData ? '可用' : '待扫描',
          ),
          _StatusLine(
            icon: Icons.radar_outlined,
            label: '扫描状态',
            value: scanState.isScanning
                ? '${scanState.completedCount}/${scanState.platforms.length} 已完成'
                : '未运行',
          ),
          _StatusLine(
            icon: Icons.auto_awesome_outlined,
            label: '推荐状态',
            value: recommendationLabel,
          ),
          if (hasMarketData) ...[
            const SizedBox(height: 14),
            Text(
              '推荐筛选',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<MarketPlatform>(
              key: ValueKey('recommendation-platform-$selectedPlatform'),
              initialValue: selectedPlatform,
              items: [
                for (final platform in availablePlatforms)
                  DropdownMenuItem(
                    value: platform,
                    child: Text(_platformDisplayName(platform.name)),
                  ),
              ],
              onChanged: commandsDisabled
                  ? null
                  : (platform) {
                      if (platform != null) {
                        onPlatformChanged(platform);
                      }
                    },
              decoration: const InputDecoration(
                labelText: '目标平台',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: genreQueryController,
              enabled: !commandsDisabled,
              decoration: const InputDecoration(
                labelText: '题材方向（可选）',
                hintText: '例如：悬疑、无限流、古言',
                border: OutlineInputBorder(),
              ),
            ),
            if (genreOptions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final genre in genreOptions)
                    ActionChip(
                      label: Text(genre),
                      onPressed: commandsDisabled
                          ? null
                          : () => genreQueryController.text = genre,
                    ),
                ],
              ),
            ],
          ],
          const SizedBox(height: 14),
          if (!hasMarketData)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: commandsDisabled ? null : onScanNow,
                icon: scanState.isScanning
                    ? const _ButtonSpinner()
                    : const Icon(Icons.play_arrow_rounded),
                label: Text(scanState.isScanning ? '扫描中...' : '扫描市场数据'),
              ),
            )
          else ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: canGenerate ? onGenerate : null,
                icon: recommendationState.isGenerating
                    ? const _ButtonSpinner()
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  recommendationState.isGenerating ? '生成中...' : '生成推荐',
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: commandsDisabled ? null : onScanNow,
                icon: scanState.isScanning
                    ? const _ButtonSpinner()
                    : const Icon(Icons.radar_outlined),
                label: Text(scanState.isScanning ? '扫描中...' : '重新扫描'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: commandsDisabled ? null : onClearScanData,
                icon: scanState.isClearing
                    ? const _ButtonSpinner()
                    : const Icon(Icons.delete_outline),
                label: Text(scanState.isClearing ? '清空中...' : '清空扫描数据'),
              ),
            ),
          ],
          if (runningTaskId != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => onAbandonTask(runningTaskId!),
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('放弃任务'),
              ),
            ),
          ],
          if (scanState.platforms.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(height: 1, color: colorScheme.outlineVariant),
            const SizedBox(height: 14),
            Text(
              '平台进度',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < scanState.platforms.length; i++) ...[
              _PlatformProgressRow(entry: scanState.platforms[i]),
              if (i < scanState.platforms.length - 1)
                const SizedBox(height: 10),
            ],
          ],
          const SizedBox(height: 16),
          Divider(height: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: 14),
          _RecommendationMiniSummary(state: recommendationState),
        ],
      ),
    );
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationMiniSummary extends StatelessWidget {
  const _RecommendationMiniSummary({required this.state});

  final MarketRecommendationState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (state.isGenerating) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('推荐摘要', style: textTheme.labelLarge),
          const SizedBox(height: 10),
          const LinearProgressIndicator(minHeight: 3),
          const SizedBox(height: 10),
          Text(
            '正在基于当前市场数据生成创作方向。',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    if (!state.hasDirections) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('推荐摘要', style: textTheme.labelLarge),
          const SizedBox(height: 8),
          Text(
            '生成后会在这里显示方向数量和最近结果，完整内容在「推荐」视图查看。',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('推荐摘要', style: textTheme.labelLarge)),
            Text(
              '${state.directions.length} 个方向',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final direction in state.directions.take(2)) ...[
          Text(
            direction.suggestedTitle,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
        ],
        if (state.generatedAt != null)
          Text(
            '生成于 ${_formatRadarTime(state.generatedAt!)}',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: 6),
        Text(
          '完整方向卡片在「推荐」视图中查看。',
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PlatformCoverageStrip extends StatelessWidget {
  const _PlatformCoverageStrip({required this.platforms});

  final List<PlatformScanEntry> platforms;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final entry in platforms) _PlatformCoverageChip(entry: entry),
      ],
    );
  }
}

class _PlatformCoverageChip extends StatelessWidget {
  const _PlatformCoverageChip({required this.entry});

  final PlatformScanEntry entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = switch (entry.status) {
      PlatformScanStatus.completed => const Color(0xFF16825D),
      PlatformScanStatus.failed => colorScheme.error,
      PlatformScanStatus.cdpRequired => colorScheme.tertiary,
      PlatformScanStatus.scanning => colorScheme.primary,
      PlatformScanStatus.abandoned => colorScheme.onSurfaceVariant,
      PlatformScanStatus.pending => colorScheme.onSurfaceVariant,
    };
    final label = switch (entry.status) {
      PlatformScanStatus.completed =>
        entry.itemCount > 0 ? '${entry.itemCount} 本' : '无数据',
      PlatformScanStatus.failed => '失败',
      PlatformScanStatus.cdpRequired => '需 Chrome',
      PlatformScanStatus.scanning => '扫描中',
      PlatformScanStatus.abandoned => '已放弃',
      PlatformScanStatus.pending => '等待',
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              '${entry.displayName} $label',
              style: textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkflowNotice extends StatelessWidget {
  const _WorkflowNotice({
    required this.icon,
    required this.title,
    required this.message,
    this.isError = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = isError ? colorScheme.error : colorScheme.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
  final Future<void> Function() onScanNow;

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
                  'AI 推荐需要市场扫描数据作为基础。点击下方按钮立即采集起点、番茄平台的榜单数据。',
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
          entry.itemCount > 0 ? '${entry.itemCount} 本' : '无新数据',
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
          style: textTheme.labelMedium?.copyWith(color: colorScheme.error),
        ),
      ),
      PlatformScanStatus.abandoned => (
        Icons.cancel_outlined,
        colorScheme.onSurfaceVariant,
        Text(
          '已放弃',
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      PlatformScanStatus.cdpRequired => (
        Icons.open_in_browser_outlined,
        colorScheme.tertiary,
        Text(
          '需要 Chrome',
          style: textTheme.labelMedium?.copyWith(color: colorScheme.tertiary),
        ),
      ),
    };

    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 10),
        Expanded(child: Text(entry.displayName, style: textTheme.bodyLarge)),
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

class _RecommendationSection extends StatelessWidget {
  const _RecommendationSection({required this.recommendationState});

  final MarketRecommendationState recommendationState;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusLabel = recommendationState.isGenerating
        ? '生成中'
        : recommendationState.hasDirections
        ? '${recommendationState.directions.length} 个方向'
        : '待生成';

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
                  Text('创作方向推荐', style: textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    '生成结果会保留完整摘要、市场热度和竞争判断，便于直接创建项目。',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            PersonaStatusPill(
              label: statusLabel,
              icon: recommendationState.isGenerating
                  ? Icons.sync
                  : Icons.auto_awesome_outlined,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recommendationState.isGenerating)
          const _RecommendationLoading()
        else if (recommendationState.errorMessage != null)
          _RecommendationError(error: recommendationState.errorMessage!)
        else if (recommendationState.directions.isEmpty)
          const _RecommendationEmpty()
        else
          _RecommendationList(directions: recommendationState.directions),
      ],
    );
  }
}

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
          description: '点击右侧「生成推荐」按钮，AI 将基于当前市场数据为你分析创作方向。',
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
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
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
        final columns = constraints.maxWidth >= 860 ? 2 : 1;
        final spacing = columns == 1 ? 0.0 : 14.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: 14,
          children: [
            for (var i = 0; i < 4; i++)
              SizedBox(width: itemWidth, child: const _SkeletonCard()),
          ],
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
          SizedBox(height: 22),
          Row(
            children: [
              SkeletonBox(width: 90, height: 28),
              SizedBox(width: 10),
              SkeletonBox(width: 90, height: 28),
              SizedBox(width: 10),
              SkeletonBox(width: 90, height: 28),
            ],
          ),
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
        final columns = constraints.maxWidth >= 900 ? 2 : 1;
        final spacing = columns == 1 ? 0.0 : 14.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: 14,
          children: [
            for (var i = 0; i < directions.length; i++)
              SizedBox(
                width: itemWidth,
                child: _MarketInsightCard(direction: directions[i], index: i),
              ),
          ],
        );
      },
    );
  }
}

class _MarketInsightCard extends StatefulWidget {
  const _MarketInsightCard({required this.direction, required this.index});

  final RecommendationDirection direction;
  final int index;

  @override
  State<_MarketInsightCard> createState() => _MarketInsightCardState();
}

class _MarketInsightCardState extends State<_MarketInsightCard> {
  late String _selectedTitle;

  RecommendationDirection get direction => widget.direction;

  @override
  void initState() {
    super.initState();
    _selectedTitle = direction.suggestedTitle;
  }

  @override
  void didUpdateWidget(_MarketInsightCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.direction != widget.direction) {
      _selectedTitle = widget.direction.suggestedTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    RecommendationTitleCandidate? selectedCandidate;
    for (final candidate in direction.titleCandidates) {
      if (candidate.title == _selectedTitle) {
        selectedCandidate = candidate;
        break;
      }
    }

    final heatClr = _heatColor(direction.marketHeatSummary);
    final compClr = _competitionColor(
      direction.competitionSummary,
      colorScheme,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + widget.index * 60),
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
              Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [heatClr, compClr]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedTitle,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _DirectionRolePill(role: direction.directionRole),
                        _GenreTagRow(tags: direction.genreTags),
                      ],
                    ),
                    if (direction.titleCandidates.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final candidate in direction.titleCandidates)
                            ChoiceChip(
                              label: Text(candidate.title),
                              selected: candidate.title == _selectedTitle,
                              onSelected: (_) => setState(
                                () => _selectedTitle = candidate.title,
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (selectedCandidate != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${selectedCandidate.formula} · ${selectedCandidate.rationale}',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      direction.synopsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.55,
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    _OpenBookPlanBlock(direction: direction),
                    const SizedBox(height: 12),
                    _InsightTextBlock(
                      label: '核心卖点',
                      value: direction.coreSellingPoint,
                    ),
                    const SizedBox(height: 8),
                    _InsightTextBlock(
                      label: '目标读者',
                      value: direction.targetAudience,
                    ),
                    const SizedBox(height: 14),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _CardMetric(
                              icon: Icons.public_outlined,
                              label: '平台',
                              value: _platformDisplayName(
                                direction.targetPlatform.name,
                              ),
                            ),
                            _CardMetric(
                              icon: Icons.text_fields,
                              label: '目标字数',
                              value: _formatWordCount(
                                direction.targetWordCount,
                              ),
                            ),
                            _CardMetric(
                              icon: Icons.verified_outlined,
                              label: '可行性',
                              value: direction.feasibility,
                            ),
                            _CardMetric(
                              icon: Icons.local_fire_department_outlined,
                              label: '市场热度',
                              value: _heatLabel(direction.marketHeatSummary),
                              valueColor: heatClr,
                            ),
                            _CardMetric(
                              icon: Icons.bar_chart_outlined,
                              label: '竞争程度',
                              value: _competitionLabel(
                                direction.competitionSummary,
                              ),
                              valueColor: compClr,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: EdgeInsets.zero,
                        title: Text(
                          '市场验证与风险',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        children: [
                          _InsightTextBlock(
                            label: '市场验证',
                            value: direction.marketValidation,
                          ),
                          const SizedBox(height: 8),
                          _InsightTextBlock(
                            label: '差异化定位',
                            value: direction.differentiation,
                          ),
                          const SizedBox(height: 8),
                          _InsightTextBlock(
                            label: '失败风险',
                            value: direction.failureRisk,
                          ),
                          const SizedBox(height: 8),
                          _InsightTextBlock(
                            label: '连载风险',
                            value: direction.serialRisk,
                          ),
                          const SizedBox(height: 8),
                          _InsightTextBlock(
                            label: '验证动作',
                            value: direction.validationAction,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        key: ValueKey(
                          'market-direction-use-${direction.suggestedTitle}',
                        ),
                        onPressed: () {
                          final uri = Uri(
                            path: '/projects/create',
                            queryParameters: {
                              'title': _selectedTitle,
                              'synopsis': _projectSynopsisForDirection(
                                direction,
                              ),
                              if (direction.genreTags.isNotEmpty)
                                'tags': direction.genreTags.join(','),
                              if (direction.targetWordCount > 0)
                                'wordCount': direction.targetWordCount
                                    .toString(),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _DirectionRolePill extends StatelessWidget {
  const _DirectionRolePill({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.22),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Text(
          role,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _OpenBookPlanBlock extends StatelessWidget {
  const _OpenBookPlanBlock({required this.direction});

  final RecommendationDirection direction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '开书方案',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _InsightTextBlock(label: '主角', value: direction.protagonist),
            const SizedBox(height: 8),
            _InsightTextBlock(label: '核心机制', value: direction.coreMechanism),
            const SizedBox(height: 8),
            _InsightTextBlock(
              label: '前三章钩子',
              value: direction.firstThreeChaptersHook,
            ),
            const SizedBox(height: 8),
            _InsightTextBlock(label: '主冲突', value: direction.mainConflict),
            const SizedBox(height: 8),
            _InsightTextBlock(label: '第一个爽点', value: direction.firstPayoff),
          ],
        ),
      ),
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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: effectiveColor),
            const SizedBox(width: 6),
            Text(
              '$label · ',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
            Text(
              value,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: effectiveColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightTextBlock extends StatelessWidget {
  const _InsightTextBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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

String _viewLabel(_WorkspaceView view) {
  return switch (view) {
    _WorkspaceView.overview => '概览',
    _WorkspaceView.rankings => '榜单',
    _WorkspaceView.recommendations => '推荐',
    _WorkspaceView.history => '历史',
  };
}

IconData _viewIcon(_WorkspaceView view) {
  return switch (view) {
    _WorkspaceView.overview => Icons.dashboard_outlined,
    _WorkspaceView.rankings => Icons.leaderboard_outlined,
    _WorkspaceView.recommendations => Icons.auto_awesome_outlined,
    _WorkspaceView.history => Icons.history_outlined,
  };
}

String _platformDisplayName(String platform) {
  return switch (platform) {
    'qidian' => '起点中文网',
    'fanqie' => '番茄小说',
    _ => platform,
  };
}

String _projectSynopsisForDirection(RecommendationDirection direction) {
  final buffer = StringBuffer()
    ..writeln(direction.synopsis.trim())
    ..writeln()
    ..writeln('## 开书方案')
    ..writeln('- 方向角色：${direction.directionRole}')
    ..writeln('- 主角：${direction.protagonist}')
    ..writeln('- 核心机制：${direction.coreMechanism}')
    ..writeln('- 前三章钩子：${direction.firstThreeChaptersHook}')
    ..writeln('- 主冲突：${direction.mainConflict}')
    ..writeln('- 第一个爽点：${direction.firstPayoff}')
    ..writeln()
    ..writeln('## 市场定位')
    ..writeln('- 目标平台：${_platformDisplayName(direction.targetPlatform.name)}')
    ..writeln('- 目标读者：${direction.targetAudience}')
    ..writeln('- 核心卖点：${direction.coreSellingPoint}')
    ..writeln('- 市场验证：${direction.marketValidation}')
    ..writeln('- 差异化：${direction.differentiation}')
    ..writeln()
    ..writeln('## 风险与验证')
    ..writeln('- 失败风险：${direction.failureRisk}')
    ..writeln('- 连载风险：${direction.serialRisk}')
    ..writeln('- 验证动作：${direction.validationAction}');
  return buffer.toString().trim();
}

IconData _scanRunStatusIcon(MarketScanRunStatus status) {
  return switch (status) {
    MarketScanRunStatus.running => Icons.sync_outlined,
    MarketScanRunStatus.completed => Icons.check_circle_outline,
    MarketScanRunStatus.failed => Icons.error_outline,
  };
}

Color _scanRunStatusColor(MarketScanRunStatus status, ColorScheme colorScheme) {
  return switch (status) {
    MarketScanRunStatus.running => colorScheme.primary,
    MarketScanRunStatus.completed => const Color(0xFF2E7D32),
    MarketScanRunStatus.failed => colorScheme.error,
  };
}

String _scanRunStatusLabel(MarketScanRunStatus status) {
  return switch (status) {
    MarketScanRunStatus.running => '运行中',
    MarketScanRunStatus.completed => '已完成',
    MarketScanRunStatus.failed => '失败',
  };
}

String _formatWordCount(int count) {
  if (count >= 10000) {
    final wan = count ~/ 10000;
    final remainder = (count % 10000) ~/ 1000;
    return remainder > 0 ? '$wan.$remainder万字' : '$wan万字';
  }
  return '$count 字';
}

String _formatRadarTime(DateTime value) {
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$month-$day $hour:$minute';
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
