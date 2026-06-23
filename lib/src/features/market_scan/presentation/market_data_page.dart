import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../workflow_runs/application/workflow_task_controller.dart';
import '../application/market_recommendation_controller.dart';
import '../application/market_scan_controller.dart';
import '../application/market_scan_providers.dart';
import '../domain/market_book.dart';
import 'widgets/editorial_section_header.dart';
import 'widgets/market_metric_strip.dart';
import 'widgets/market_scan_formatters.dart';
import 'widgets/scan_command_panel.dart';
import 'widgets/scan_history_timeline.dart';
import 'widgets/shared_chips.dart';

class MarketDataPage extends ConsumerStatefulWidget {
  const MarketDataPage({super.key});

  @override
  ConsumerState<MarketDataPage> createState() => _MarketDataPageState();
}

class _MarketDataPageState extends ConsumerState<MarketDataPage> {
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

  Future<void> _scanNow() async {
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
    if (confirmed != true || !mounted) {
      return;
    }
    await _runCommand(
      () => ref.read(marketScanControllerProvider.notifier).clearAllData(),
    );
  }

  Future<void> _abandonTask(String taskId) async {
    await _runCommand(
      () => ref.read(workflowTaskControllerProvider.notifier).abandon(taskId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDataAsync = ref.watch(marketScanHasDataProvider);
    final bundleAsync = ref.watch(scanDataBundleProvider);
    final scanState = ref.watch(marketScanControllerProvider);
    final recommendationState = ref.watch(
      marketRecommendationControllerProvider,
    );
    final runningTaskId = scanState.isScanning
        ? scanState.workflowTaskId
        : recommendationState.isGenerating
        ? recommendationState.workflowTaskId
        : null;

    return hasDataAsync.when(
      data: (hasMarketData) {
        if (!hasMarketData) {
          return MarketDataMissingPanel(onScanNow: _scanNow);
        }
        return bundleAsync.when(
          data: (bundle) => _MarketDataContent(
            bundle: bundle,
            scanState: scanState,
            recommendationState: recommendationState,
            runningTaskId: runningTaskId,
            onScanNow: _scanNow,
            onClearScanData: _clearScanData,
            onAbandonTask: _abandonTask,
          ),
          loading: () => const MarketDataLoadingPanel(),
          error: (error, _) => MarketDataErrorPanel(error: error),
        );
      },
      loading: () => const MarketDataLoadingPanel(),
      error: (error, _) => MarketDataErrorPanel(error: error),
    );
  }
}

class _MarketDataContent extends StatelessWidget {
  const _MarketDataContent({
    required this.bundle,
    required this.scanState,
    required this.recommendationState,
    required this.runningTaskId,
    required this.onScanNow,
    required this.onClearScanData,
    required this.onAbandonTask,
  });

  final ScanDataBundle bundle;
  final MarketScanState scanState;
  final MarketRecommendationState recommendationState;
  final String? runningTaskId;
  final Future<void> Function() onScanNow;
  final Future<void> Function() onClearScanData;
  final Future<void> Function(String taskId) onAbandonTask;

  @override
  Widget build(BuildContext context) {
    final latestRun = bundle.runs.isEmpty ? null : bundle.runs.first;
    final description = latestRun == null
        ? '当前数据可用于生成创作方向，建议先确认平台覆盖和榜单样本质量。'
        : '最近扫描 ${formatRadarTime(latestRun.startedAt)}，当前数据可用于生成创作方向。';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MarketMetricStrip(bundle: bundle),
        const SizedBox(height: 28),
        MarketDataOperationsPanel(
          bundle: bundle,
          hasMarketData: true,
          scanState: scanState,
          runningTaskId: runningTaskId,
          healthDescription: description,
          onScanNow: onScanNow,
          onClearScanData: onClearScanData,
          onAbandonTask: onAbandonTask,
        ),
        if (scanState.platforms.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            '扫描进度',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 12),
          PlatformProgressList(entries: scanState.platforms),
        ],
        if (scanState.error != null) ...[
          const SizedBox(height: 20),
          WorkflowNotice(
            icon: Icons.error_outline,
            title: '扫描任务异常',
            message: scanState.error!,
            isError: true,
          ),
        ],
        if (recommendationState.errorMessage != null) ...[
          const SizedBox(height: 20),
          WorkflowNotice(
            icon: Icons.error_outline,
            title: '推荐任务失败',
            message: recommendationState.errorMessage!,
            isError: true,
          ),
        ],
        const SizedBox(height: 48),
        const EditorialSectionHeader(
          title: '扫描历史',
          description: '保留最近的市场扫描结果；任务审计仍在 Workflow Runs 中查看。',
        ),
        const SizedBox(height: 24),
        ScanHistoryTimeline(runs: bundle.runs),
        const SizedBox(height: 24),
      ],
    );
  }
}

List<MarketPlatform> availablePlatformsFromBundle(ScanDataBundle? bundle) {
  if (bundle == null) {
    return const [];
  }
  return bundle.availablePlatforms;
}
