import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/market_book.dart';
import 'market_recommendation_controller.dart';

part 'recommendation_generation_config_provider.g.dart';

class RecommendationGenerationConfig {
  const RecommendationGenerationConfig({
    this.wizardStep = 1,
    this.targetPlatforms = const {},
    this.selectedChartKeys = const {},
  });

  final int wizardStep;
  final Set<MarketPlatform> targetPlatforms;
  final Set<String> selectedChartKeys;

  bool get canProceedToStep2 =>
      targetPlatforms.isNotEmpty && selectedChartKeys.isNotEmpty;

  RecommendationGenerationConfig copyWith({
    int? wizardStep,
    Set<MarketPlatform>? targetPlatforms,
    Set<String>? selectedChartKeys,
  }) {
    return RecommendationGenerationConfig(
      wizardStep: wizardStep ?? this.wizardStep,
      targetPlatforms: targetPlatforms ?? this.targetPlatforms,
      selectedChartKeys: selectedChartKeys ?? this.selectedChartKeys,
    );
  }
}

@Riverpod(keepAlive: true)
class RecommendationGenerationConfigController
    extends _$RecommendationGenerationConfigController {
  @override
  RecommendationGenerationConfig build() =>
      const RecommendationGenerationConfig();

  void goToStep(int step) {
    state = state.copyWith(wizardStep: step);
  }

  void proceedToStep2() {
    if (!state.canProceedToStep2) {
      return;
    }
    state = state.copyWith(wizardStep: 2);
  }

  void backToStep1() {
    ref.read(marketRecommendationControllerProvider.notifier).clearResults();
    state = state.copyWith(wizardStep: 1);
  }

  void toggleTargetPlatform(MarketPlatform platform) {
    _clearResultsIfNeeded();
    final next = Set<MarketPlatform>.from(state.targetPlatforms);
    if (next.contains(platform)) {
      next.remove(platform);
    } else {
      next.add(platform);
    }
    state = state.copyWith(targetPlatforms: next);
  }

  void toggleChartKey(String chartKey) {
    _clearResultsIfNeeded();
    final next = Set<String>.from(state.selectedChartKeys);
    if (next.contains(chartKey)) {
      next.remove(chartKey);
    } else {
      next.add(chartKey);
    }
    state = state.copyWith(selectedChartKeys: next);
  }

  void addReferenceFromRanking({
    required MarketPlatform platform,
    required String chartKey,
  }) {
    _clearResultsIfNeeded();
    state = state.copyWith(
      wizardStep: 1,
      targetPlatforms: {...state.targetPlatforms, platform},
      selectedChartKeys: {...state.selectedChartKeys, chartKey},
    );
  }

  void _clearResultsIfNeeded() {
    final recommendationState = ref.read(marketRecommendationControllerProvider);
    if (recommendationState.hasDirections && !recommendationState.isGenerating) {
      ref.read(marketRecommendationControllerProvider.notifier).clearResults();
    }
  }
}
