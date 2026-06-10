import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_route.dart';
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

enum _WorkspaceView { overview, marketData, rankings, recommendations, history }

class RecommendationPage extends ConsumerStatefulWidget {
  const RecommendationPage({super.key});

  @override
  ConsumerState<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends ConsumerState<RecommendationPage> {
  _WorkspaceView _activeView = _WorkspaceView.overview;
  bool _hasViewPreference = false;
  final TextEditingController _genreQueryController = TextEditingController();
  MarketPlatform? _selectedPlatform;

  @override
  void dispose() {
    _genreQueryController.dispose();
    super.dispose();
  }

  void _setActiveView(_WorkspaceView view) {
    if (!mounted) {
      return;
    }
    if (_activeView == view && _hasViewPreference) {
      return;
    }
    setState(() {
      _activeView = view;
      _hasViewPreference = true;
    });
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
    final effectiveActiveView =
        !_hasViewPreference &&
            (recommendationState.isGenerating ||
                recommendationState.hasDirections ||
                recommendationState.errorMessage != null)
        ? _WorkspaceView.recommendations
        : _activeView;

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
          activeView: effectiveActiveView,
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
    return bundle.availablePlatforms;
  }
}

class _RecommendationWorkspace extends StatefulWidget {
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
  State<_RecommendationWorkspace> createState() =>
      _RecommendationWorkspaceState();
}

class _RecommendationWorkspaceState extends State<_RecommendationWorkspace>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  static const _views = [
    _WorkspaceView.overview,
    _WorkspaceView.marketData,
    _WorkspaceView.rankings,
    _WorkspaceView.recommendations,
    _WorkspaceView.history,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _views.length,
      vsync: this,
      initialIndex: _viewIndex(widget.activeView),
    );
  }

  @override
  void didUpdateWidget(_RecommendationWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    final targetIndex = _viewIndex(widget.activeView);
    if (_tabController.index != targetIndex) {
      _tabController.animateTo(targetIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final genreOptions = _genreOptionsForPlatform(
      widget.bundle.value?.books ?? const [],
      widget.selectedPlatform,
    );
    final commandPanel = _TaskCommandPanel(
      hasMarketData: widget.hasMarketData,
      scanState: widget.scanState,
      recommendationState: widget.recommendationState,
      availablePlatforms: widget.availablePlatforms,
      selectedPlatform: widget.selectedPlatform,
      genreOptions: genreOptions,
      genreQueryController: widget.genreQueryController,
      onPlatformChanged: widget.onPlatformChanged,
      runningTaskId: widget.runningTaskId,
      onScanNow: widget.onScanNow,
      onGenerate: widget.onGenerate,
      onClearScanData: widget.onClearScanData,
      onAbandonTask: widget.onAbandonTask,
    );
    final workbenchHeight = (MediaQuery.sizeOf(context).height - 220).clamp(
      560.0,
      920.0,
    );

    return PersonaPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          commandPanel,
          Divider(height: 1, color: colorScheme.outlineVariant),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                onTap: (index) => widget.onViewChanged(_views[index]),
                tabs: [
                  for (final view in _views)
                    Tab(
                      key: ValueKey('workspace-view-${view.name}'),
                      icon: Icon(_viewIcon(view), size: 18),
                      text: _viewLabel(view),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: workbenchHeight,
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final view in _views)
                  _WorkspaceTabViewport(
                    view: view,
                    child: _WorkspaceViewBody(
                      activeView: view,
                      hasData: widget.hasData,
                      bundle: widget.bundle,
                      scanState: widget.scanState,
                      recommendationState: widget.recommendationState,
                      onScanNow: widget.onScanNow,
                      onViewChanged: widget.onViewChanged,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static int _viewIndex(_WorkspaceView view) {
    final index = _views.indexOf(view);
    return index < 0 ? 0 : index;
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

class _WorkspaceTabViewport extends StatelessWidget {
  const _WorkspaceTabViewport({required this.view, required this.child});

  final _WorkspaceView view;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: PageStorageKey('recommendation-workspace-tab-${view.name}'),
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }
}

class _MarketDataTab extends StatelessWidget {
  const _MarketDataTab({
    required this.bundle,
    required this.scanState,
    required this.recommendationState,
  });

  final ScanDataBundle bundle;
  final MarketScanState scanState;
  final MarketRecommendationState recommendationState;

  @override
  Widget build(BuildContext context) {
    final latestRun = bundle.runs.isEmpty ? null : bundle.runs.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          icon: Icons.dataset_outlined,
          title: '市场数据健康',
          description: latestRun == null
              ? '当前数据可用于生成创作方向，建议先确认平台覆盖和榜单样本质量。'
              : '最近扫描 ${_formatRadarTime(latestRun.startedAt)}，当前数据可用于生成创作方向。',
          trailing: PersonaStatusPill(
            label: scanState.isScanning ? '更新中' : '可用',
            icon: scanState.isScanning
                ? Icons.sync
                : Icons.check_circle_outline,
          ),
        ),
        const SizedBox(height: 14),
        _MarketMetricGrid(bundle: bundle),
        const SizedBox(height: 14),
        _WorkbenchTile(
          icon: Icons.public_outlined,
          title: '平台覆盖',
          description: '书籍样本和榜单条目分开统计，避免把重复榜单记录当成样本书。',
          child: _PlatformDataCoverageStrip(bundle: bundle),
        ),
        if (scanState.platforms.isNotEmpty) ...[
          const SizedBox(height: 14),
          _WorkbenchTile(
            icon: Icons.radar_outlined,
            title: '扫描进度',
            description: '当前任务状态会同步到命令带；完成后榜单和推荐会使用最新数据。',
            child: _PlatformProgressList(entries: scanState.platforms),
          ),
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
    );
  }
}

class _PlatformProgressList extends StatelessWidget {
  const _PlatformProgressList({required this.entries});

  final List<PlatformScanEntry> entries;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 700;
        if (!twoColumns) {
          return Column(
            children: [
              for (var i = 0; i < entries.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i == entries.length - 1 ? 0 : 10,
                  ),
                  child: _PlatformProgressRow(entry: entries[i]),
                ),
            ],
          );
        }
        return Wrap(
          spacing: 18,
          runSpacing: 10,
          children: [
            for (final entry in entries)
              SizedBox(
                width: (constraints.maxWidth - 18) / 2,
                child: _PlatformProgressRow(entry: entry),
              ),
          ],
        );
      },
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
                  onOpenMarketData: () =>
                      onViewChanged(_WorkspaceView.marketData),
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
      _WorkspaceView.marketData => hasData.when(
        data: (hasMarketData) => hasMarketData
            ? bundle.when(
                data: (data) => _MarketDataTab(
                  bundle: data,
                  scanState: scanState,
                  recommendationState: recommendationState,
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

class _WorkspaceOverview extends StatelessWidget {
  const _WorkspaceOverview({
    required this.bundle,
    required this.scanState,
    required this.recommendationState,
    required this.onOpenMarketData,
    required this.onOpenRankings,
    required this.onOpenRecommendations,
  });

  final ScanDataBundle bundle;
  final MarketScanState scanState;
  final MarketRecommendationState recommendationState;
  final VoidCallback onOpenMarketData;
  final VoidCallback onOpenRankings;
  final VoidCallback onOpenRecommendations;

  @override
  Widget build(BuildContext context) {
    final platformCount = bundle.availablePlatforms.length;
    final latestRun = bundle.runs.isNotEmpty ? bundle.runs.first : null;
    final readinessLabel = scanState.isScanning ? '更新中' : '可生成';
    final readinessDescription = latestRun == null
        ? '当前已有 ${bundle.totalBookCount} 本书籍样本和 ${bundle.totalRankingEntryCount} 条榜单记录，可先审阅榜单质量。'
        : '覆盖 $platformCount 个平台、${bundle.totalBookCount} 本书籍样本、${bundle.totalRankingEntryCount} 条榜单记录；最近扫描 ${_formatRadarTime(latestRun.startedAt)}。';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          icon: scanState.isScanning
              ? Icons.sync_outlined
              : Icons.dashboard_outlined,
          title: '工作台概览',
          description: '用市场数据判断方向，用推荐结果进入项目创建。',
          trailing: PersonaStatusPill(
            label: readinessLabel,
            icon: scanState.isScanning
                ? Icons.sync
                : Icons.check_circle_outline,
          ),
        ),
        const SizedBox(height: 14),
        _MarketMetricGrid(bundle: bundle),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1080
                ? 3
                : constraints.maxWidth >= 720
                ? 2
                : 1;
            final spacing = columns == 1 ? 0.0 : 14.0;
            final itemWidth =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: 14,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _OverviewActionTile(
                    icon: Icons.dataset_outlined,
                    title: '市场数据健康',
                    description: readinessDescription,
                    statusLabel: readinessLabel,
                    statusIcon: scanState.isScanning
                        ? Icons.sync
                        : Icons.check_circle_outline,
                    onPressed: onOpenMarketData,
                    buttonLabel: '查看市场数据',
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _OverviewActionTile(
                    icon: Icons.auto_awesome_outlined,
                    title: '创作推荐状态',
                    description: _recommendationOverviewText(
                      recommendationState,
                    ),
                    statusLabel: recommendationState.isGenerating
                        ? '生成中'
                        : recommendationState.hasDirections
                        ? '${recommendationState.directions.length} 个方向'
                        : recommendationState.errorMessage != null
                        ? '失败'
                        : '待生成',
                    statusIcon: recommendationState.isGenerating
                        ? Icons.sync
                        : Icons.auto_awesome_outlined,
                    onPressed: onOpenRecommendations,
                    buttonLabel: recommendationState.hasDirections
                        ? '查看创作推荐'
                        : '打开推荐页',
                    child: recommendationState.hasDirections
                        ? _RecommendationPreviewList(
                            directions: recommendationState.directions,
                          )
                        : null,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _OverviewActionTile(
                    icon: Icons.leaderboard_outlined,
                    title: '榜单热点入口',
                    description:
                        '当前可浏览 ${bundle.chartCount} 个榜单、${bundle.totalRankingEntryCount} 条榜单记录；样本书共 ${bundle.totalBookCount} 本。',
                    statusLabel: '${bundle.chartCount} 个榜单',
                    statusIcon: Icons.leaderboard_outlined,
                    onPressed: onOpenRankings,
                    buttonLabel: '查看排行榜',
                    child: _PlatformDataCoverageStrip(bundle: bundle),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

String _recommendationOverviewText(MarketRecommendationState state) {
  if (state.isGenerating) {
    return '推荐正在生成，完成后会进入三方向对照。';
  }
  if (state.errorMessage != null) {
    return '推荐任务失败，可打开创作推荐查看错误详情。';
  }
  if (state.hasDirections) {
    return '已生成 ${state.directions.length} 个方向，可比较市场、竞争、可行性和风险。';
  }
  return '尚未生成创作方向。选择目标平台和题材后可从命令带生成。';
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.description,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
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
            width: 38,
            height: 38,
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                description,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

class _MarketMetricGrid extends StatelessWidget {
  const _MarketMetricGrid({required this.bundle});

  final ScanDataBundle bundle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = [
          _WorkbenchMetric(
            icon: Icons.public_outlined,
            label: '覆盖平台',
            value: '${bundle.availablePlatforms.length}',
            detail: '可用数据源',
          ),
          _WorkbenchMetric(
            icon: Icons.menu_book_outlined,
            label: '书籍样本',
            value: '${bundle.totalBookCount} 本',
            detail: '去重样本书',
          ),
          _WorkbenchMetric(
            icon: Icons.list_alt_outlined,
            label: '榜单条目',
            value: '${bundle.totalRankingEntryCount} 条',
            detail: '抓取榜单记录',
          ),
          _WorkbenchMetric(
            icon: Icons.leaderboard_outlined,
            label: '榜单数量',
            value: '${bundle.chartCount}',
            detail: '可浏览榜单',
          ),
        ];
        final columns = constraints.maxWidth >= 920
            ? 4
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        final spacing = columns == 1 ? 0.0 : 12.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: 12,
          children: [
            for (final metric in metrics)
              SizedBox(width: itemWidth, child: metric),
          ],
        );
      },
    );
  }
}

class _WorkbenchMetric extends StatelessWidget {
  const _WorkbenchMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
  });

  final IconData icon;
  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: colorScheme.primary),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              detail,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewActionTile extends StatelessWidget {
  const _OverviewActionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.statusLabel,
    required this.statusIcon,
    required this.onPressed,
    required this.buttonLabel,
    this.child,
  });

  final IconData icon;
  final String title;
  final String description;
  final String statusLabel;
  final IconData statusIcon;
  final VoidCallback onPressed;
  final String buttonLabel;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 20, color: colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    PersonaStatusPill(label: statusLabel, icon: statusIcon),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                if (child != null) ...[const SizedBox(height: 12), child!],
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onPressed,
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: Text(buttonLabel),
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

class _WorkbenchTile extends StatelessWidget {
  const _WorkbenchTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
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

class _RecommendationPreviewList extends StatelessWidget {
  const _RecommendationPreviewList({required this.directions});

  final List<RecommendationDirection> directions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final direction in directions.take(2)) ...[
          _RecommendationPreviewRow(direction: direction),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ScanHistoryWorkspace extends StatelessWidget {
  const _ScanHistoryWorkspace({required this.runs});

  final List<MarketScanRun> runs;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final visibleRuns = runs.take(12).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          icon: Icons.history_outlined,
          title: '扫描历史',
          description: '保留最近的市场扫描结果；任务审计仍在 Workflow Runs 中查看。',
          trailing: PersonaStatusPill(
            label: '${runs.length} 条',
            icon: Icons.list,
          ),
        ),
        const SizedBox(height: 14),
        _WorkbenchTile(
          icon: Icons.list_alt_outlined,
          title: '最近扫描记录',
          description: visibleRuns.isEmpty ? '暂无扫描记录。' : '按最近时间展示最多 12 条扫描记录。',
          child: visibleRuns.isEmpty
              ? Text(
                  '暂无扫描记录',
                  style: textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              : Column(
                  children: [
                    for (var i = 0; i < visibleRuns.length; i++) ...[
                      _ScanHistoryWorkspaceRow(run: visibleRuns[i]),
                      if (i < visibleRuns.length - 1)
                        Divider(
                          height: 16,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                    ],
                  ],
                ),
        ),
      ],
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
              ? '${run.itemCount} 条'
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 860;
          final platformField = DropdownButtonFormField<MarketPlatform>(
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
          );
          final genreField = TextField(
            controller: genreQueryController,
            enabled: !commandsDisabled,
            decoration: const InputDecoration(
              labelText: '题材方向（可选）',
              hintText: '例如：悬疑、无限流、古言',
              border: OutlineInputBorder(),
            ),
          );
          final genreChips = genreOptions.isEmpty
              ? null
              : Wrap(
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
                );
          final actions = _CommandActionButtons(
            compact: compact,
            hasMarketData: hasMarketData,
            canGenerate: canGenerate,
            commandsDisabled: commandsDisabled,
            scanState: scanState,
            recommendationState: recommendationState,
            runningTaskId: runningTaskId,
            onScanNow: onScanNow,
            onGenerate: onGenerate,
            onClearScanData: onClearScanData,
            onAbandonTask: onAbandonTask,
          );
          final statusChips = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CommandStateChip(
                icon: Icons.dataset_outlined,
                label: '市场数据',
                value: hasMarketData ? '可用' : '待扫描',
                color: hasMarketData
                    ? const Color(0xFF16825D)
                    : colorScheme.onSurfaceVariant,
              ),
              _CommandStateChip(
                icon: Icons.radar_outlined,
                label: '扫描',
                value: scanState.isScanning
                    ? '${scanState.completedCount}/${scanState.platforms.length} 已完成'
                    : '未运行',
                color: scanState.isScanning
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              _CommandStateChip(
                icon: Icons.auto_awesome_outlined,
                label: '推荐',
                value: recommendationLabel,
                color: recommendationState.isGenerating
                    ? colorScheme.primary
                    : recommendationState.hasDirections
                    ? const Color(0xFF16825D)
                    : colorScheme.onSurfaceVariant,
              ),
              PersonaStatusPill(
                label: taskLabel,
                icon: isRunning ? Icons.sync : Icons.task_alt_outlined,
              ),
            ],
          );
          final heading = Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(
                  width: 34,
                  height: 34,
                  child: Icon(
                    Icons.tune_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '工作台命令',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          );

          if (!hasMarketData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                compact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          heading,
                          const SizedBox(height: 10),
                          statusChips,
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: heading),
                          const SizedBox(width: 16),
                          Flexible(child: statusChips),
                        ],
                      ),
                const SizedBox(height: 12),
                _MissingDataCommand(
                  onScanNow: onScanNow,
                  disabled: commandsDisabled,
                ),
              ],
            );
          }

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                heading,
                const SizedBox(height: 10),
                statusChips,
                const SizedBox(height: 12),
                platformField,
                const SizedBox(height: 10),
                genreField,
                if (genreChips != null) ...[
                  const SizedBox(height: 8),
                  genreChips,
                ],
                const SizedBox(height: 12),
                actions,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 190, child: heading),
                  const SizedBox(width: 14),
                  Expanded(child: statusChips),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 220, child: platformField),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        genreField,
                        if (genreChips != null) ...[
                          const SizedBox(height: 8),
                          genreChips,
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(width: 260, child: actions),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CommandStateChip extends StatelessWidget {
  const _CommandStateChip({
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 7),
            Text(
              '$label · ',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              value,
              style: textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissingDataCommand extends StatelessWidget {
  const _MissingDataCommand({required this.onScanNow, required this.disabled});

  final Future<void> Function() onScanNow;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 520;
          final message = Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.radar_outlined, color: colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '先采集市场榜单数据，再进入推荐生成流程。',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          );
          final action = FilledButton.icon(
            onPressed: disabled ? null : onScanNow,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('扫描市场数据'),
          );

          if (compact) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [message, const SizedBox(height: 10), action],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: message),
                const SizedBox(width: 12),
                action,
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CommandActionButtons extends StatelessWidget {
  const _CommandActionButtons({
    required this.compact,
    required this.hasMarketData,
    required this.canGenerate,
    required this.commandsDisabled,
    required this.scanState,
    required this.recommendationState,
    required this.runningTaskId,
    required this.onScanNow,
    required this.onGenerate,
    required this.onClearScanData,
    required this.onAbandonTask,
  });

  final bool compact;
  final bool hasMarketData;
  final bool canGenerate;
  final bool commandsDisabled;
  final MarketScanState scanState;
  final MarketRecommendationState recommendationState;
  final String? runningTaskId;
  final Future<void> Function() onScanNow;
  final Future<void> Function() onGenerate;
  final Future<void> Function() onClearScanData;
  final Future<void> Function(String taskId) onAbandonTask;

  @override
  Widget build(BuildContext context) {
    if (!hasMarketData) {
      return const SizedBox.shrink();
    }

    final generateButton = FilledButton.icon(
      onPressed: canGenerate ? onGenerate : null,
      icon: recommendationState.isGenerating
          ? const _ButtonSpinner()
          : const Icon(Icons.auto_awesome),
      label: Text(recommendationState.isGenerating ? '生成中...' : '生成推荐'),
    );
    final moreMenu = _CommandMoreMenu(
      commandsDisabled: commandsDisabled,
      scanState: scanState,
      runningTaskId: runningTaskId,
      onScanNow: onScanNow,
      onClearScanData: onClearScanData,
      onAbandonTask: onAbandonTask,
    );

    if (compact) {
      return Row(
        children: [
          Expanded(child: generateButton),
          const SizedBox(width: 8),
          moreMenu,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: generateButton),
        const SizedBox(width: 8),
        moreMenu,
      ],
    );
  }
}

enum _CommandMenuAction { scan, clear, abandon }

class _CommandMoreMenu extends StatelessWidget {
  const _CommandMoreMenu({
    required this.commandsDisabled,
    required this.scanState,
    required this.runningTaskId,
    required this.onScanNow,
    required this.onClearScanData,
    required this.onAbandonTask,
  });

  final bool commandsDisabled;
  final MarketScanState scanState;
  final String? runningTaskId;
  final Future<void> Function() onScanNow;
  final Future<void> Function() onClearScanData;
  final Future<void> Function(String taskId) onAbandonTask;

  @override
  Widget build(BuildContext context) {
    final hasEnabledAction = !commandsDisabled || runningTaskId != null;

    return Tooltip(
      message: '更多命令',
      child: PopupMenuButton<_CommandMenuAction>(
        enabled: hasEnabledAction,
        icon: const Icon(Icons.more_horiz),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _CommandMenuAction.scan,
            enabled: !commandsDisabled,
            child: Row(
              children: [
                Icon(
                  scanState.isScanning
                      ? Icons.sync_outlined
                      : Icons.radar_outlined,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(scanState.isScanning ? '扫描中...' : '重新扫描'),
              ],
            ),
          ),
          PopupMenuItem(
            value: _CommandMenuAction.clear,
            enabled: !commandsDisabled,
            child: const Row(
              children: [
                Icon(Icons.delete_outline, size: 18),
                SizedBox(width: 10),
                Text('清空数据'),
              ],
            ),
          ),
          if (runningTaskId != null)
            const PopupMenuItem(
              value: _CommandMenuAction.abandon,
              child: Row(
                children: [
                  Icon(Icons.stop_circle_outlined, size: 18),
                  SizedBox(width: 10),
                  Text('放弃任务'),
                ],
              ),
            ),
        ],
        onSelected: (action) {
          switch (action) {
            case _CommandMenuAction.scan:
              onScanNow();
              return;
            case _CommandMenuAction.clear:
              onClearScanData();
              return;
            case _CommandMenuAction.abandon:
              final taskId = runningTaskId;
              if (taskId != null) {
                onAbandonTask(taskId);
              }
              return;
          }
        },
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

class _PlatformDataCoverageStrip extends StatelessWidget {
  const _PlatformDataCoverageStrip({required this.bundle});

  final ScanDataBundle bundle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final platform in bundle.availablePlatforms)
          _PlatformDataCoverageChip(stats: bundle.statsForPlatform(platform)),
      ],
    );
  }
}

class _PlatformDataCoverageChip extends StatelessWidget {
  const _PlatformDataCoverageChip({required this.stats});

  final PlatformScanDataStats stats;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = _platformColor(stats.platform, colorScheme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
              '${_platformDisplayName(stats.platform.name)} ${stats.bookCount}本 / ${stats.rankingEntryCount}条',
              style: textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
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
          entry.itemCount > 0 ? '${entry.itemCount} 条' : '无新数据',
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

class _RecommendationSection extends StatefulWidget {
  const _RecommendationSection({required this.recommendationState});

  final MarketRecommendationState recommendationState;

  @override
  State<_RecommendationSection> createState() => _RecommendationSectionState();
}

class _RecommendationSectionState extends State<_RecommendationSection> {
  int _selectedIndex = 0;

  MarketRecommendationState get recommendationState =>
      widget.recommendationState;

  @override
  void didUpdateWidget(_RecommendationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final directions = recommendationState.directions;
    if (directions.isEmpty) {
      _selectedIndex = 0;
      return;
    }
    if (_selectedIndex >= directions.length) {
      _selectedIndex = directions.length - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusLabel = recommendationState.isGenerating
        ? '生成中'
        : recommendationState.hasDirections
        ? '${recommendationState.directions.length} 个方向'
        : '待生成';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          icon: Icons.compare_arrows_outlined,
          title: '创作方向推荐 · 三方向对照',
          description: '先比较热度、竞争、可行性和风险，再查看选中方向的开书方案与市场验证。',
          trailing: PersonaStatusPill(
            label: statusLabel,
            icon: recommendationState.isGenerating
                ? Icons.sync
                : Icons.auto_awesome_outlined,
          ),
        ),
        const SizedBox(height: 14),
        if (recommendationState.isGenerating)
          const _RecommendationLoading()
        else if (recommendationState.errorMessage != null)
          _RecommendationError(error: recommendationState.errorMessage!)
        else if (recommendationState.directions.isEmpty)
          const _RecommendationEmpty()
        else
          _DirectionComparisonWorkspace(
            directions: recommendationState.directions,
            selectedIndex: _selectedIndex,
            onSelected: (index) => setState(() => _selectedIndex = index),
          ),
      ],
    );
  }
}

class _DirectionComparisonWorkspace extends StatelessWidget {
  const _DirectionComparisonWorkspace({
    required this.directions,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<RecommendationDirection> directions;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected =
        directions[selectedIndex.clamp(0, directions.length - 1).toInt()];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1080
                ? 3
                : constraints.maxWidth >= 720
                ? 2
                : 1;
            final spacing = columns == 1 ? 0.0 : 12.0;
            final itemWidth =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: 12,
              children: [
                for (var i = 0; i < directions.length; i++)
                  SizedBox(
                    width: itemWidth,
                    child: _DirectionComparisonCard(
                      direction: directions[i],
                      index: i,
                      selected: i == selectedIndex,
                      onTap: () => onSelected(i),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        _DirectionDetailPanel(direction: selected),
      ],
    );
  }
}

class _DirectionComparisonCard extends StatelessWidget {
  const _DirectionComparisonCard({
    required this.direction,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final RecommendationDirection direction;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final heatClr = _heatColor(direction.marketHeatSummary);
    final compClr = _competitionColor(
      direction.competitionSummary,
      colorScheme,
    );
    final feasibilityColor = _feasibilityColor(
      direction.feasibility,
      colorScheme,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('market-direction-compare-${direction.suggestedTitle}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.05)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? colorScheme.primary.withValues(alpha: 0.42)
                  : colorScheme.outlineVariant,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: selected
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: textTheme.labelLarge?.copyWith(
                              color: selected
                                  ? colorScheme.onPrimary
                                  : colorScheme.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            direction.suggestedTitle,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _DirectionRolePill(role: direction.directionRole),
                              _GenreTagRow(tags: direction.genreTags),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DecisionMeterList(
                  heatLabel: _heatLabel(direction.marketHeatSummary),
                  heatColor: heatClr,
                  heatScore: _heatScore(direction.marketHeatSummary),
                  competitionLabel: _competitionLabel(
                    direction.competitionSummary,
                  ),
                  competitionColor: compClr,
                  competitionScore: _competitionScore(
                    direction.competitionSummary,
                  ),
                  feasibilityLabel: direction.feasibility,
                  feasibilityColor: feasibilityColor,
                  feasibilityScore: _feasibilityScore(direction.feasibility),
                ),
                const SizedBox(height: 12),
                _RiskPreview(
                  failureRisk: direction.failureRisk,
                  serialRisk: direction.serialRisk,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DirectionDetailPanel extends StatefulWidget {
  const _DirectionDetailPanel({required this.direction});

  final RecommendationDirection direction;

  @override
  State<_DirectionDetailPanel> createState() => _DirectionDetailPanelState();
}

class _DirectionDetailPanelState extends State<_DirectionDetailPanel> {
  late String _selectedTitle;

  RecommendationDirection get direction => widget.direction;

  @override
  void initState() {
    super.initState();
    _selectedTitle = direction.suggestedTitle;
  }

  @override
  void didUpdateWidget(_DirectionDetailPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.direction != widget.direction) {
      _selectedTitle = direction.suggestedTitle;
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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final useStack = constraints.maxWidth < 620;
                final titleBlock = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedTitle,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      direction.coreSellingPoint,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
                final useButton = FilledButton.icon(
                  key: ValueKey(
                    'market-direction-use-${direction.suggestedTitle}',
                  ),
                  onPressed: () {
                    final uri = Uri(
                      path: '/projects/create',
                      queryParameters: {
                        'title': _selectedTitle,
                        'synopsis': _projectSynopsisForDirection(direction),
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
                );
                if (useStack) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      titleBlock,
                      const SizedBox(height: 12),
                      useButton,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: titleBlock),
                    const SizedBox(width: 12),
                    useButton,
                  ],
                );
              },
            ),
            if (direction.titleCandidates.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                '标题候选',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final candidate in direction.titleCandidates)
                    ChoiceChip(
                      label: Text(candidate.title),
                      selected: candidate.title == _selectedTitle,
                      onSelected: (_) =>
                          setState(() => _selectedTitle = candidate.title),
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
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final twoColumns = constraints.maxWidth >= 840;
                final openBook = _OpenBookPlanBlock(direction: direction);
                final insight = _DirectionInsightGrid(direction: direction);
                if (!twoColumns) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [openBook, const SizedBox(height: 12), insight],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: openBook),
                    const SizedBox(width: 12),
                    Expanded(child: insight),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DirectionInsightGrid extends StatelessWidget {
  const _DirectionInsightGrid({required this.direction});

  final RecommendationDirection direction;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InsightTextBlock(label: '简介', value: direction.synopsis),
            const SizedBox(height: 8),
            _InsightTextBlock(label: '目标读者', value: direction.targetAudience),
            const SizedBox(height: 8),
            _InsightTextBlock(label: '市场验证', value: direction.marketValidation),
            const SizedBox(height: 8),
            _InsightTextBlock(label: '差异化定位', value: direction.differentiation),
            const SizedBox(height: 8),
            _InsightTextBlock(label: '失败风险', value: direction.failureRisk),
            const SizedBox(height: 8),
            _InsightTextBlock(label: '连载风险', value: direction.serialRisk),
            const SizedBox(height: 8),
            _InsightTextBlock(label: '验证动作', value: direction.validationAction),
          ],
        ),
      ),
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
          description: '在顶部命令带选择平台和题材后生成推荐，AI 将基于当前市场数据分析创作方向。',
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
        final columns = constraints.maxWidth >= 1020
            ? 3
            : constraints.maxWidth >= 680
            ? 2
            : 1;
        final spacing = columns == 1 ? 0.0 : 14.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: 14,
          children: [
            for (var i = 0; i < 3; i++)
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

class _DecisionMeterList extends StatelessWidget {
  const _DecisionMeterList({
    required this.heatLabel,
    required this.heatColor,
    required this.heatScore,
    required this.competitionLabel,
    required this.competitionColor,
    required this.competitionScore,
    required this.feasibilityLabel,
    required this.feasibilityColor,
    required this.feasibilityScore,
  });

  final String heatLabel;
  final Color heatColor;
  final double heatScore;
  final String competitionLabel;
  final Color competitionColor;
  final double competitionScore;
  final String feasibilityLabel;
  final Color feasibilityColor;
  final double feasibilityScore;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            _DecisionMeter(
              label: '市场',
              value: heatLabel,
              color: heatColor,
              score: heatScore,
            ),
            const SizedBox(height: 8),
            _DecisionMeter(
              label: '竞争',
              value: competitionLabel,
              color: competitionColor,
              score: competitionScore,
            ),
            const SizedBox(height: 8),
            _DecisionMeter(
              label: '可行',
              value: feasibilityLabel,
              color: feasibilityColor,
              score: feasibilityScore,
            ),
          ],
        ),
      ),
    );
  }
}

class _DecisionMeter extends StatelessWidget {
  const _DecisionMeter({
    required this.label,
    required this.value,
    required this.color,
    required this.score,
  });

  final String label;
  final String value;
  final Color color;
  final double score;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final clampedScore = score.clamp(0.08, 1.0).toDouble();

    return Row(
      children: [
        SizedBox(
          width: 42,
          child: Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 6,
              child: ColoredBox(
                color: colorScheme.surfaceContainerHighest,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: clampedScore,
                  child: ColoredBox(color: color),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 58,
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _RiskPreview extends StatelessWidget {
  const _RiskPreview({required this.failureRisk, required this.serialRisk});

  final String failureRisk;
  final String serialRisk;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final riskColor = const Color(0xFFE65100);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: riskColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: riskColor.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_outlined, size: 18, color: riskColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '风险提示',
                    style: textTheme.labelSmall?.copyWith(
                      color: riskColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    failureRisk.isEmpty ? serialRisk : failureRisk,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
    _WorkspaceView.marketData => '市场数据',
    _WorkspaceView.rankings => '排行榜',
    _WorkspaceView.recommendations => '创作推荐',
    _WorkspaceView.history => '历史',
  };
}

IconData _viewIcon(_WorkspaceView view) {
  return switch (view) {
    _WorkspaceView.overview => Icons.dashboard_outlined,
    _WorkspaceView.marketData => Icons.dataset_outlined,
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

Color _platformColor(MarketPlatform platform, ColorScheme colorScheme) {
  return switch (platform) {
    MarketPlatform.qidian => const Color(0xFF2758D9),
    MarketPlatform.fanqie => const Color(0xFFE64A19),
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

double _heatScore(String summary) {
  final lower = summary.toLowerCase();
  if (lower.contains('高') || lower.contains('hot') || lower.contains('强')) {
    return 0.88;
  }
  if (lower.contains('低') || lower.contains('cold') || lower.contains('弱')) {
    return 0.34;
  }
  return 0.62;
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

double _competitionScore(String summary) {
  final lower = summary.toLowerCase();
  if (lower.contains('激') || lower.contains('high') || lower.contains('高')) {
    return 0.82;
  }
  if (lower.contains('低') || lower.contains('low') || lower.contains('少')) {
    return 0.36;
  }
  return 0.58;
}

Color _feasibilityColor(String value, ColorScheme colorScheme) {
  final lower = value.toLowerCase();
  if (lower.contains('高') || lower.contains('high') || lower.contains('强')) {
    return const Color(0xFF16825D);
  }
  if (lower.contains('低') || lower.contains('low') || lower.contains('弱')) {
    return colorScheme.error;
  }
  return const Color(0xFFF9A825);
}

double _feasibilityScore(String value) {
  final lower = value.toLowerCase();
  if (lower.contains('高') || lower.contains('high') || lower.contains('强')) {
    return 0.82;
  }
  if (lower.contains('低') || lower.contains('low') || lower.contains('弱')) {
    return 0.36;
  }
  return 0.58;
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
