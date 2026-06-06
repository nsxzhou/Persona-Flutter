import 'dart:convert';

import '../../../core/llm/application/llm_invocation_service.dart';
import '../../settings/domain/provider_config.dart';
import '../../settings/domain/provider_config_repository.dart';
import '../domain/recommendation_direction.dart';
import '../../../core/llm/application/markdown_completion_service.dart';
import '../../../core/llm/domain/llm_cancellation.dart';
import 'recommendation_prompts.dart';
import 'rule_engine.dart';

/// Orchestrates: Rule Engine → prompt formatting → LLM call → JSON parsing.
class RecommendationGenerationService {
  const RecommendationGenerationService({
    required this.ruleEngine,
    required this.completionService,
    required this.providerRepository,
  });

  final RuleEngine ruleEngine;
  final MarkdownCompletionService completionService;
  final ProviderConfigRepository providerRepository;

  /// Generate 3-5 recommendation directions from current market data.
  ///
  /// Uses the first enabled LLM provider. Throws if no provider is available.
  Future<List<RecommendationDirection>> generate({
    ProviderConfig? provider,
    LlmCancellationToken? cancellationToken,
    LlmPromptTraceConfig? promptTrace,
  }) async {
    cancellationToken?.throwIfCancelled();
    final metrics = await ruleEngine.compute();
    cancellationToken?.throwIfCancelled();
    if (metrics.genreHeat.isEmpty && metrics.opportunities.isEmpty) {
      return const [];
    }

    final resolvedProvider = provider ?? await requireEnabledProvider();
    final prompts = const RecommendationPrompts();
    final userPrompt = prompts.buildUserPrompt(metrics);

    final rawOutput = await completionService.completeMarkdown(
      provider: resolvedProvider,
      prompt: userPrompt,
      businessSystemPrompt: prompts.systemPrompt,
      temperature: 0.65,
      maxAttempts: 2,
      promptTrace: promptTrace,
      cancellationToken: cancellationToken,
    );

    cancellationToken?.throwIfCancelled();
    return _parseDirections(rawOutput);
  }

  Future<ProviderConfig> requireEnabledProvider() async {
    final providers = await providerRepository.watchProviders().first;
    final enabled = providers.where((p) => p.isEnabled).toList();
    if (enabled.isEmpty) {
      throw StateError('没有可用的 AI Provider。请先在 Settings 中配置。');
    }
    return enabled.first;
  }

  List<RecommendationDirection> _parseDirections(String rawOutput) {
    // The LLM may wrap JSON in markdown code fences — strip them.
    var cleaned = rawOutput.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned
          .replaceFirst(RegExp(r'^```\w*\n?'), '')
          .replaceFirst(RegExp(r'\n?```$'), '');
    }

    try {
      final decoded = jsonDecode(cleaned);
      if (decoded is! List) {
        throw const FormatException('LLM output is not a JSON array.');
      }
      return decoded
          .cast<Map<String, Object?>>()
          .map(RecommendationDirection.fromJson)
          .toList(growable: false);
    } on FormatException catch (e) {
      throw StateError('无法解析 LLM 推荐输出: $e\n原始输出:\n$cleaned');
    }
  }
}
