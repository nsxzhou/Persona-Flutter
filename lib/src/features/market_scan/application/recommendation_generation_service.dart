import '../../../core/llm/application/llm_invocation_service.dart';
import '../../../core/llm/application/markdown_completion_service.dart';
import '../../../core/llm/domain/llm_cancellation.dart';
import '../../settings/domain/provider_config.dart';
import '../../settings/domain/provider_config_repository.dart';
import '../domain/market_book.dart';
import '../domain/market_ranking.dart';
import '../domain/market_scan_repository.dart';
import '../domain/recommendation_direction.dart';
import '../domain/recommendation_generation_request.dart';
import 'recommendation_direction_document_parser.dart';
import 'recommendation_prompts.dart';
import 'rule_engine.dart';

/// Orchestrates: Rule Engine → prompt formatting → LLM call → YAML+MD parsing.
class RecommendationGenerationService {
  const RecommendationGenerationService({
    required this.ruleEngine,
    required this.marketRepository,
    required this.completionService,
    required this.providerRepository,
    this.documentParser = const RecommendationDirectionDocumentParser(),
  });

  final RuleEngine ruleEngine;
  final MarketScanRepository marketRepository;
  final MarkdownCompletionService completionService;
  final ProviderConfigRepository providerRepository;
  final RecommendationDirectionDocumentParser documentParser;

  /// Generate 3 recommendation directions from current market data.
  ///
  /// Uses the first enabled LLM provider. Throws if no provider is available.
  Future<List<RecommendationDirection>> generate({
    required RecommendationGenerationRequest request,
    ProviderConfig? provider,
    LlmCancellationToken? cancellationToken,
    LlmPromptTraceConfig? promptTrace,
  }) async {
    cancellationToken?.throwIfCancelled();
    final context = await _buildPromptContext(request);
    cancellationToken?.throwIfCancelled();
    if (context.platformBookCount == 0 || context.platformRankingCount == 0) {
      return const [];
    }

    final metrics = await ruleEngine.compute(platform: request.targetPlatform);
    cancellationToken?.throwIfCancelled();
    if (metrics.genreHeat.isEmpty && metrics.opportunities.isEmpty) {
      return const [];
    }

    final resolvedProvider = provider ?? await requireEnabledProvider();
    final prompts = const RecommendationPrompts();
    final userPrompt = prompts.buildUserPrompt(metrics, context: context);

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
    return _parseOrRepair(
      rawOutput: rawOutput,
      prompts: prompts,
      provider: resolvedProvider,
      request: request,
      promptTrace: promptTrace,
      cancellationToken: cancellationToken,
    );
  }

  Future<ProviderConfig> requireEnabledProvider() async {
    final providers = await providerRepository.watchProviders().first;
    final enabled = providers.where((p) => p.isEnabled).toList();
    if (enabled.isEmpty) {
      throw StateError('没有可用的 AI Provider。请先在 Settings 中配置。');
    }
    return enabled.first;
  }

  Future<List<RecommendationDirection>> _parseOrRepair({
    required String rawOutput,
    required RecommendationPrompts prompts,
    required ProviderConfig provider,
    required RecommendationGenerationRequest request,
    required LlmPromptTraceConfig? promptTrace,
    required LlmCancellationToken? cancellationToken,
  }) async {
    try {
      return documentParser.parse(
        markdown: rawOutput,
        expectedPlatform: request.targetPlatform,
      );
    } on Object catch (parseError) {
      cancellationToken?.throwIfCancelled();
      try {
        final repaired = await completionService.completeMarkdown(
          provider: provider,
          prompt: prompts.buildRepairPrompt(
            invalidOutput: rawOutput,
            parseError: parseError.toString(),
            targetPlatform: request.targetPlatform,
          ),
          businessSystemPrompt: prompts.systemPrompt,
          temperature: 0,
          maxAttempts: 1,
          promptTrace: _repairTrace(promptTrace),
          cancellationToken: cancellationToken,
        );
        cancellationToken?.throwIfCancelled();
        return documentParser.parse(
          markdown: repaired,
          expectedPlatform: request.targetPlatform,
        );
      } on Object catch (repairError) {
        throw StateError(
          '无法解析 LLM 推荐 YAML+MD 输出: $parseError\n'
          '自动修复失败: $repairError\n'
          '原始输出:\n${rawOutput.trim()}',
        );
      }
    }
  }

  LlmPromptTraceConfig? _repairTrace(LlmPromptTraceConfig? promptTrace) {
    if (promptTrace == null) {
      return null;
    }
    return LlmPromptTraceConfig(
      label: '${promptTrace.label}_repair',
      onComplete: promptTrace.onComplete,
    );
  }

  Future<RecommendationPromptContext> _buildPromptContext(
    RecommendationGenerationRequest request,
  ) async {
    final books = await marketRepository.findBooks(
      platform: request.targetPlatform,
    );
    final rankings = await marketRepository.findLatestRankings(
      platform: request.targetPlatform,
    );
    final bookById = {for (final book in books) book.id: book};
    final samples = _representativeSamples(
      rankings: rankings,
      bookById: bookById,
      genreQuery: request.normalizedGenreQuery,
    );
    return RecommendationPromptContext(
      targetPlatform: request.targetPlatform,
      genreQuery: request.normalizedGenreQuery,
      platformBookCount: books.length,
      platformRankingCount: rankings.length,
      samples: samples,
    );
  }

  List<RecommendationPromptSample> _representativeSamples({
    required List<MarketRanking> rankings,
    required Map<String, MarketBook> bookById,
    required String? genreQuery,
  }) {
    final sortedRankings = [...rankings]
      ..sort((a, b) {
        final chart = a.chartName.compareTo(b.chartName);
        return chart == 0 ? a.rank.compareTo(b.rank) : chart;
      });
    final filtered = _sampleCandidates(
      rankings: sortedRankings,
      bookById: bookById,
      genreQuery: genreQuery,
    );
    final candidates = filtered.isEmpty && genreQuery != null
        ? _sampleCandidates(
            rankings: sortedRankings,
            bookById: bookById,
            genreQuery: null,
          )
        : filtered;
    return candidates.take(12).toList(growable: false);
  }

  Iterable<RecommendationPromptSample> _sampleCandidates({
    required List<MarketRanking> rankings,
    required Map<String, MarketBook> bookById,
    required String? genreQuery,
  }) sync* {
    final seenBooks = <String>{};
    for (final ranking in rankings) {
      final book = bookById[ranking.bookId];
      if (book == null || !seenBooks.add(book.id)) {
        continue;
      }
      if (genreQuery != null && !_matchesGenreQuery(book, genreQuery)) {
        continue;
      }
      yield RecommendationPromptSample(
        title: book.title,
        author: book.author,
        categories: book.categories,
        tags: book.tags,
        totalWordCount: book.totalWordCount,
        description: book.description,
        chartName: ranking.chartName,
        rank: ranking.rank,
      );
    }
  }

  bool _matchesGenreQuery(MarketBook book, String genreQuery) {
    final query = genreQuery.trim();
    if (query.isEmpty) {
      return true;
    }
    final searchable = [
      book.title,
      book.description,
      ...book.categories,
      ...book.tags,
    ].join('\n');
    return searchable.contains(query);
  }
}
