import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_route.dart';
import '../../../core/ui/keep_alive_tab_wrapper.dart';
import '../application/market_recommendation_controller.dart';
import '../application/market_scan_providers.dart';
import 'market_data_page.dart';
import 'rankings_page.dart';
import 'recommendations_page.dart';
import 'widgets/recommendation_sub_nav.dart';

class RecommendationShell extends ConsumerStatefulWidget {
  const RecommendationShell({required this.section, super.key});

  final String section;

  @override
  ConsumerState<RecommendationShell> createState() =>
      _RecommendationShellState();
}

class _RecommendationShellState extends ConsumerState<RecommendationShell> {
  static const _maxWidth = 1380.0;
  static const _pages = [
    KeepAliveTabWrapper(child: MarketDataPage()),
    KeepAliveTabWrapper(child: RankingsPage()),
    KeepAliveTabWrapper(child: RecommendationsPage()),
  ];

  int get _activeIndex => _indexForSection(widget.section);

  void _onSectionSelected(RecommendationSection section) {
    if (widget.section == section.segment) {
      return;
    }
    context.go(section.basePath);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hasMarketData = ref.watch(marketScanHasDataProvider).value == true;
    final recommendationState = ref.watch(
      marketRecommendationControllerProvider,
    );

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI 推荐',
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '创作方向推荐',
                            style: textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 10),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 700),
                            child: Text(
                              '审阅市场数据，生成并比较创作方向。',
                              style: textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go(AppRoute.projects.path),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('返回项目'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                RecommendationSubNav(
                  hasMarketData: hasMarketData,
                  hasRecommendations: recommendationState.hasDirections,
                  isGenerating: recommendationState.isGenerating,
                  onSectionSelected: _onSectionSelected,
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: IndexedStack(
                    index: _activeIndex,
                    children: [
                      for (var i = 0; i < _pages.length; i++)
                        _SectionScrollViewport(
                          key: PageStorageKey<String>(
                            'recommendation-section-$i',
                          ),
                          child: _pages[i],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static int _indexForSection(String section) {
    return switch (section) {
      'rankings' => 1,
      'recommendations' => 2,
      _ => 0,
    };
  }
}

class _SectionScrollViewport extends StatelessWidget {
  const _SectionScrollViewport({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SingleChildScrollView(
        primary: false,
        child: Align(
          alignment: Alignment.topLeft,
          child: child,
        ),
      ),
    );
  }
}
