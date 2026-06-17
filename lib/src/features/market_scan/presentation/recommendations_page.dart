import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/market_recommendation_controller.dart';
import '../application/market_scan_controller.dart';
import '../application/market_scan_providers.dart';
import '../application/recommendation_generation_config_provider.dart';
import '../domain/chart_key.dart';
import '../domain/market_book.dart';
import '../domain/recommendation_generation_request.dart';
import 'widgets/direction_comparison.dart';
import 'widgets/editorial_section_header.dart';
import 'widgets/generate_command_panel.dart';
import 'widgets/reference_config_panel.dart';
import 'widgets/recommendation_sub_nav.dart';
import 'widgets/shared_chips.dart';

class RecommendationsPage extends ConsumerStatefulWidget {
  const RecommendationsPage({super.key});

  @override
  ConsumerState<RecommendationsPage> createState() =>
      _RecommendationsPageState();
}

class _RecommendationsPageState extends ConsumerState<RecommendationsPage> {
  final TextEditingController _genreQueryController = TextEditingController();

  @override
  void dispose() {
    _genreQueryController.dispose();
    super.dispose();
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

  Future<void> _generate() async {
    final config = ref.read(recommendationGenerationConfigControllerProvider);
    if (!config.canProceedToStep2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择目标平台和参考榜单。')),
      );
      return;
    }
    await _runCommand(
      () => ref.read(marketRecommendationControllerProvider.notifier).generate(
        RecommendationGenerationRequest(
          targetPlatforms: config.targetPlatforms.toList(),
          selectedChartKeys: config.selectedChartKeys.toList(),
          genreQuery: _genreQueryController.text,
        ),
      ),
    );
  }

  List<String> _genreOptionsForConfig(
    List<MarketBook> books,
    Set<MarketPlatform> targetPlatforms,
  ) {
    if (targetPlatforms.isEmpty) {
      return const [];
    }
    final counts = <String, int>{};
    for (final book in books.where(
      (book) => targetPlatforms.contains(book.platform),
    )) {
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

  @override
  Widget build(BuildContext context) {
    final hasDataAsync = ref.watch(marketScanHasDataProvider);
    final bundleAsync = ref.watch(scanDataBundleProvider);
    final scanState = ref.watch(marketScanControllerProvider);
    final recommendationState = ref.watch(
      marketRecommendationControllerProvider,
    );
    final config = ref.watch(recommendationGenerationConfigControllerProvider);
    final commandsDisabled =
        scanState.isScanning ||
        scanState.isClearing ||
        recommendationState.isGenerating;

    return hasDataAsync.when(
      data: (hasMarketData) {
        if (!hasMarketData) {
          return MarketDataMissingPanel(
            onScanNow: () async {
              context.go(RecommendationSection.marketData.basePath);
            },
            subtitle: '需要先在「市场数据」页完成扫描，才能生成创作方向推荐。',
          );
        }
        return bundleAsync.when(
          data: (bundle) {
            final availablePlatforms = bundle.availablePlatforms;
            final availableChartKeys = availableChartKeysFromRankings(
              rankings: bundle.rankings,
              books: bundle.books,
            );
            final genreOptions = _genreOptionsForConfig(
              bundle.books,
              config.targetPlatforms,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (config.wizardStep == 1)
                  ReferenceConfigPanel(
                    availablePlatforms: availablePlatforms,
                    availableChartKeys: availableChartKeys,
                    selectedPlatforms: config.targetPlatforms,
                    selectedChartKeys: config.selectedChartKeys,
                    commandsDisabled: commandsDisabled,
                    onPlatformToggled: (platform) => ref
                        .read(
                          recommendationGenerationConfigControllerProvider
                              .notifier,
                        )
                        .toggleTargetPlatform(platform),
                    onChartKeyToggled: (chartKey) => ref
                        .read(
                          recommendationGenerationConfigControllerProvider
                              .notifier,
                        )
                        .toggleChartKey(chartKey),
                    onProceed: () => ref
                        .read(
                          recommendationGenerationConfigControllerProvider
                              .notifier,
                        )
                        .proceedToStep2(),
                  )
                else ...[
                  GenerateCommandPanel(
                    hasMarketData: true,
                    recommendationState: recommendationState,
                    targetPlatformCount: config.targetPlatforms.length,
                    referenceChartCount: config.selectedChartKeys.length,
                    genreOptions: genreOptions,
                    genreQueryController: _genreQueryController,
                    commandsDisabled: commandsDisabled,
                    onBackToConfig: () => ref
                        .read(
                          recommendationGenerationConfigControllerProvider
                              .notifier,
                        )
                        .backToStep1(),
                    onGenerate: _generate,
                  ),
                  const SizedBox(height: 48),
                  EditorialSectionHeader(
                    title: '三方向对照',
                    description: '比较热度、竞争、可行性和风险，选择最适合的开书方向。',
                  ),
                  const SizedBox(height: 28),
                  DirectionComparisonSection(
                    recommendationState: recommendationState,
                  ),
                ],
                const SizedBox(height: 24),
              ],
            );
          },
          loading: () => const MarketDataLoadingPanel(),
          error: (error, _) => MarketDataErrorPanel(error: error),
        );
      },
      loading: () => const MarketDataLoadingPanel(),
      error: (error, _) => MarketDataErrorPanel(error: error),
    );
  }
}
