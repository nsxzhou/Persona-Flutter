import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/market_scan_providers.dart';
import 'scan_data_browser.dart';
import 'widgets/recommendation_sub_nav.dart';
import 'widgets/shared_chips.dart';

class RankingsPage extends ConsumerWidget {
  const RankingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasDataAsync = ref.watch(marketScanHasDataProvider);
    final bundleAsync = ref.watch(scanDataBundleProvider);

    return hasDataAsync.when(
      data: (hasMarketData) {
        if (!hasMarketData) {
          return _RankingsEmpty(onScan: () {
            context.go(RecommendationSection.marketData.basePath);
          });
        }
        return bundleAsync.when(
          data: (bundle) => const ScanDataBrowser(
            showHeader: false,
            showStats: false,
            showHistory: false,
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

class _RankingsEmpty extends StatelessWidget {
  const _RankingsEmpty({required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '暂无榜单数据',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '需要先在「市场数据」页完成扫描，才能浏览榜单热点。',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.radar_outlined),
            label: const Text('前往市场数据'),
          ),
        ],
      ),
    );
  }
}
