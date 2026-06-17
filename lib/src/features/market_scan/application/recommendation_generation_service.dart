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
    Future<void> Function(String stage)? onStageChanged,
  }) async {
    cancellationToken?.throwIfCancelled();
    await onStageChanged?.call('building_context');
    final context = await _buildPromptContext(request);
    cancellationToken?.throwIfCancelled();
    if (context.platformBookCount == 0 || context.platformRankingCount == 0) {
      return const [];
    }

    await onStageChanged?.call('computing_metrics');
    final metrics = await ruleEngine.compute(platform: request.targetPlatform);
    cancellationToken?.throwIfCancelled();
    if (metrics.genreHeat.isEmpty && metrics.opportunities.isEmpty) {
      return const [];
    }

    await onStageChanged?.call('calling_llm');
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
    await onStageChanged?.call('parsing_output');
    final parsed = await _parseOrRepair(
      rawOutput: rawOutput,
      prompts: prompts,
      provider: resolvedProvider,
      request: request,
      promptTrace: promptTrace,
      cancellationToken: cancellationToken,
    );
    await onStageChanged?.call('validating_quality');
    return _validateQualityOrRewrite(
      parsed: parsed,
      prompts: prompts,
      provider: resolvedProvider,
      request: request,
      context: context,
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

  Future<_ParsedRecommendationDocument> _parseOrRepair({
    required String rawOutput,
    required RecommendationPrompts prompts,
    required ProviderConfig provider,
    required RecommendationGenerationRequest request,
    required LlmPromptTraceConfig? promptTrace,
    required LlmCancellationToken? cancellationToken,
  }) async {
    try {
      return _ParsedRecommendationDocument(
        markdown: rawOutput,
        directions: documentParser.parse(
          markdown: rawOutput,
          expectedPlatform: request.targetPlatform,
        ),
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
        return _ParsedRecommendationDocument(
          markdown: repaired,
          directions: documentParser.parse(
            markdown: repaired,
            expectedPlatform: request.targetPlatform,
          ),
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

  Future<List<RecommendationDirection>> _validateQualityOrRewrite({
    required _ParsedRecommendationDocument parsed,
    required RecommendationPrompts prompts,
    required ProviderConfig provider,
    required RecommendationGenerationRequest request,
    required RecommendationPromptContext context,
    required LlmPromptTraceConfig? promptTrace,
    required LlmCancellationToken? cancellationToken,
  }) async {
    final qualityErrors = _qualityErrors(parsed.directions, context);
    if (qualityErrors.isEmpty) {
      return parsed.directions;
    }

    cancellationToken?.throwIfCancelled();
    final rewritten = await completionService.completeMarkdown(
      provider: provider,
      prompt: prompts.buildQualityRepairPrompt(
        invalidOutput: parsed.markdown,
        qualityErrors: qualityErrors,
        context: context,
      ),
      businessSystemPrompt: prompts.systemPrompt,
      temperature: 0.2,
      maxAttempts: 1,
      promptTrace: _qualityRepairTrace(promptTrace),
      cancellationToken: cancellationToken,
    );
    cancellationToken?.throwIfCancelled();

    final repaired = await _parseOrRepair(
      rawOutput: rewritten,
      prompts: prompts,
      provider: provider,
      request: request,
      promptTrace: _qualityRepairTrace(promptTrace),
      cancellationToken: cancellationToken,
    );
    final remainingErrors = _qualityErrors(repaired.directions, context);
    if (remainingErrors.isNotEmpty) {
      throw StateError('推荐结果未通过质量校验：${remainingErrors.join('；')}');
    }
    return repaired.directions;
  }

  List<String> _qualityErrors(
    List<RecommendationDirection> directions,
    RecommendationPromptContext context,
  ) {
    final errors = <String>[];
    for (var index = 0; index < directions.length; index += 1) {
      final direction = directions[index];
      final scope = '方向 ${index + 1}（${direction.directionRole}）';
      final openBookFields = {
        '主角': direction.protagonist,
        '核心机制': direction.coreMechanism,
        '前三章钩子': direction.firstThreeChaptersHook,
        '主冲突': direction.mainConflict,
        '第一个爽点': direction.firstPayoff,
        '连载风险': direction.serialRisk,
      };
      for (final entry in openBookFields.entries) {
        if (_isLowInformation(entry.value)) {
          errors.add('$scope 的${entry.key}过于空泛。');
        }
      }

      if (context.samples.isNotEmpty) {
        final evidenceCount = _targetEvidenceCount(
          direction.marketValidation,
          context,
        );
        if (evidenceCount < 2) {
          errors.add('$scope 的 market_validation 少于 2 个目标平台证据信号。');
        }
      }
    }
    return errors;
  }

  bool _isLowInformation(String value) {
    final normalized = value.replaceAll(RegExp(r'\s+'), '');
    if (normalized.runes.length < 6) {
      return true;
    }
    const placeholders = ['待定', '暂无', '不确定', '根据市场决定', '后续补充'];
    return placeholders.any(normalized.contains);
  }

  int _targetEvidenceCount(
    String marketValidation,
    RecommendationPromptContext context,
  ) {
    final matched = <String>{};
    final text = marketValidation.replaceAll(RegExp(r'\s+'), '');
    for (final token in context.targetEvidenceTokens) {
      final normalized = token.replaceAll(RegExp(r'\s+'), '');
      if (normalized.length >= 2 && text.contains(normalized)) {
        matched.add(normalized);
      }
    }
    return matched.length;
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

  LlmPromptTraceConfig? _qualityRepairTrace(LlmPromptTraceConfig? promptTrace) {
    if (promptTrace == null) {
      return null;
    }
    return LlmPromptTraceConfig(
      label: '${promptTrace.label}_quality_repair',
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
    final allBooks = await marketRepository.findBooks();
    final allRankings = await marketRepository.findLatestRankings();
    final allBookById = {for (final book in allBooks) book.id: book};
    final auxiliaryBooks = allBooks
        .where((book) => book.platform != request.targetPlatform)
        .toList(growable: false);
    final auxiliaryBookIds = auxiliaryBooks.map((book) => book.id).toSet();
    final auxiliaryRankings = allRankings
        .where((ranking) => auxiliaryBookIds.contains(ranking.bookId))
        .toList(growable: false);
    final samples = _representativeSamples(
      rankings: rankings,
      bookById: bookById,
      genreQuery: request.normalizedGenreQuery,
    );
    final auxiliarySamples = _representativeSamples(
      rankings: auxiliaryRankings,
      bookById: allBookById,
      genreQuery: request.normalizedGenreQuery,
      maxSamples: 8,
    );
    return RecommendationPromptContext(
      targetPlatform: request.targetPlatform,
      genreQuery: request.normalizedGenreQuery,
      platformBookCount: books.length,
      platformRankingCount: rankings.length,
      auxiliaryPlatformBookCount: auxiliaryBooks.length,
      auxiliaryPlatformRankingCount: auxiliaryRankings.length,
      samples: samples,
      auxiliarySamples: auxiliarySamples,
    );
  }

  List<RecommendationPromptSample> _representativeSamples({
    required List<MarketRanking> rankings,
    required Map<String, MarketBook> bookById,
    required String? genreQuery,
    int maxSamples = 24,
  }) {
    final filtered = _selectRepresentativeSamples(
      rankings: rankings,
      bookById: bookById,
      genreQuery: genreQuery,
      maxSamples: maxSamples,
    );
    if (filtered.isNotEmpty || genreQuery == null) {
      return filtered;
    }
    return _selectRepresentativeSamples(
      rankings: rankings,
      bookById: bookById,
      genreQuery: null,
      maxSamples: maxSamples,
    );
  }

  List<RecommendationPromptSample> _selectRepresentativeSamples({
    required List<MarketRanking> rankings,
    required Map<String, MarketBook> bookById,
    required String? genreQuery,
    required int maxSamples,
  }) {
    final sortedRankings = [...rankings]
      ..sort((a, b) {
        final priority = _chartPriority(
          a.chartName,
        ).compareTo(_chartPriority(b.chartName));
        if (priority != 0) return priority;
        final chart = a.chartName.compareTo(b.chartName);
        return chart == 0 ? a.rank.compareTo(b.rank) : chart;
      });

    final groups = <String, List<RecommendationPromptSample>>{};
    for (final ranking in sortedRankings) {
      final book = bookById[ranking.bookId];
      if (book == null) {
        continue;
      }
      if (genreQuery != null && !_matchesGenreQuery(book, genreQuery)) {
        continue;
      }
      final sample = RecommendationPromptSample(
        platform: book.platform,
        title: book.title,
        author: book.author,
        categories: book.categories,
        tags: book.tags,
        totalWordCount: book.totalWordCount,
        description: book.description,
        chartName: ranking.chartName,
        rank: ranking.rank,
      );
      groups.putIfAbsent(ranking.chartName, () => []).add(sample);
    }

    final output = <RecommendationPromptSample>[];
    final seenBooks = <String>{};
    void addSample(RecommendationPromptSample sample) {
      if (output.length >= maxSamples || !seenBooks.add(sample.title)) {
        return;
      }
      output.add(sample);
    }

    final familyQuotas = <_ChartFamily, int>{
      _ChartFamily.peak: 4,
      _ChartFamily.main: 8,
      _ChartFamily.newBook: 6,
      _ChartFamily.recommendSlot: 3,
      _ChartFamily.other: 3,
    };
    for (final entry in familyQuotas.entries) {
      _roundRobinAdd(
        groups: groups,
        family: entry.key,
        quota: entry.value,
        addSample: addSample,
      );
    }

    while (output.length < maxSamples) {
      final before = output.length;
      for (final family in _ChartFamily.values) {
        _roundRobinAdd(
          groups: groups,
          family: family,
          quota: 1,
          addSample: addSample,
        );
        if (output.length >= maxSamples) {
          break;
        }
      }
      if (output.length == before) {
        break;
      }
    }

    return output;
  }

  void _roundRobinAdd({
    required Map<String, List<RecommendationPromptSample>> groups,
    required _ChartFamily family,
    required int quota,
    required void Function(RecommendationPromptSample sample) addSample,
  }) {
    final chartNames =
        groups.keys
            .where((chartName) => _chartFamily(chartName) == family)
            .toList()
          ..sort((a, b) {
            final priority = _chartPriority(a).compareTo(_chartPriority(b));
            return priority == 0 ? a.compareTo(b) : priority;
          });
    if (chartNames.isEmpty) {
      return;
    }

    var added = 0;
    var row = 0;
    while (added < quota) {
      var addedThisRow = false;
      for (final chartName in chartNames) {
        final items = groups[chartName]!;
        if (row >= items.length) {
          continue;
        }
        addSample(items[row]);
        added += 1;
        addedThisRow = true;
        if (added >= quota) {
          break;
        }
      }
      if (!addedThisRow) {
        break;
      }
      row += 1;
    }
  }

  _ChartFamily _chartFamily(String chartName) {
    if (chartName.contains('巅峰')) return _ChartFamily.peak;
    if (chartName.contains('推荐位')) return _ChartFamily.recommendSlot;
    if (chartName.contains('新书') || chartName.contains('新人')) {
      return _ChartFamily.newBook;
    }
    if (chartName.contains('阅读') ||
        chartName.contains('畅销') ||
        chartName.contains('月票') ||
        chartName.contains('热读')) {
      return _ChartFamily.main;
    }
    return _ChartFamily.other;
  }

  int _chartPriority(String chartName) {
    return switch (_chartFamily(chartName)) {
      _ChartFamily.peak => 0,
      _ChartFamily.main => 1,
      _ChartFamily.newBook => 2,
      _ChartFamily.other => 3,
      _ChartFamily.recommendSlot => 4,
    };
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

enum _ChartFamily { peak, main, newBook, recommendSlot, other }

class _ParsedRecommendationDocument {
  const _ParsedRecommendationDocument({
    required this.markdown,
    required this.directions,
  });

  final String markdown;
  final List<RecommendationDirection> directions;
}
