import 'dart:convert';

import 'package:yaml/yaml.dart';

import '../../../core/llm/application/markdown_completion_service.dart';
import '../../../core/llm/domain/llm_cancellation.dart';
import '../../../core/tasks/application/prompt_trace_recorder.dart';
import '../../projects/domain/writing_project.dart';
import '../../settings/domain/provider_config.dart';
import '../domain/novel_workshop.dart';
import '../domain/writing_context.dart';

class WritingContextRetriever {
  const WritingContextRetriever({
    required MarkdownCompletionService completionService,
  }) : _completionService = completionService;

  final MarkdownCompletionService _completionService;

  static const int _nearbyChapterCount = 2;
  static const int _maxRemoteCandidates = 8;
  static const int _selectorAttempts = 2;
  static const int _nearExcerptLength = 3200;
  static const int _farExcerptLength = 900;
  static const int _summaryLength = 260;
  static const int _assetBlockLength = 1800;

  Future<RetrievedWritingContext> retrieve({
    required WritingProject project,
    required ChapterPlan plan,
    required WritingContextSections baseSections,
    required List<ProjectChapter> previousChapters,
    required List<NovelCharacter> characters,
    required List<NovelRelationship> relationships,
    ProviderConfig? provider,
    String? modelName,
    PromptTraceRecorder? traceRecorder,
    LlmCancellationToken? cancellationToken,
  }) async {
    final queryTerms = _queryTerms(
      project: project,
      plan: plan,
      sections: baseSections,
      characters: characters,
      relationships: relationships,
    );
    final chapterCandidates = _chapterCandidates(
      chapters: previousChapters,
      queryTerms: queryTerms,
    );
    final assetCandidates = _assetCandidates(baseSections);

    _SelectorResult? selector;
    final warnings = <String>[];
    if (provider != null &&
        modelName != null &&
        (chapterCandidates.isNotEmpty || assetCandidates.length > 1)) {
      for (var attempt = 1; attempt <= _selectorAttempts; attempt += 1) {
        try {
          selector = _parseSelectorResult(
            await _completionService.completeMarkdown(
              provider: provider,
              modelName: modelName,
              temperature: 0.15,
              prompt: _selectorPrompt(
                project: project,
                plan: plan,
                candidates: chapterCandidates,
                assets: assetCandidates,
              ),
              promptTrace: traceRecorder?.config(
                label: 'select_generation_context_$attempt',
              ),
              cancellationToken: cancellationToken,
            ),
          );
          if (selector.hasSelection) {
            break;
          }
          throw const FormatException('selector returned no selected context');
        } on Object catch (error) {
          selector = null;
          if (attempt == _selectorAttempts) {
            warnings.add('上下文筛选器失败，已使用本地检索兜底：$error');
          }
        }
      }
    }

    final selectedChapters = _selectedChapterExcerpts(
      candidates: chapterCandidates,
      selector: selector,
    );
    final selectedAssets = _selectedAssetBlocks(
      candidates: assetCandidates,
      selector: selector,
    );
    final report = _selectionReport(
      selectedChapters: selectedChapters,
      selectedAssets: selectedAssets,
      selector: selector,
      usedFallback: selector == null,
    );
    return RetrievedWritingContext(
      sections: WritingContextSections(
        outputContract: baseSections.outputContract,
        projectBible: const ProjectBiblePromptContext(),
        chapterPlan: baseSections.chapterPlan,
        chapterObjectiveCard: baseSections.chapterObjectiveCard,
        voiceProfileMarkdown: '',
        storyEngineMarkdown: '',
        projectContextMarkdown: baseSections.projectContextMarkdown,
        characterGraphMarkdown: baseSections.characterGraphMarkdown,
        runtimeMemory: const RuntimeMemoryState(),
        retrievedReferencesMarkdown: _referencesMarkdown(
          selectedChapters: selectedChapters,
          selectedAssets: selectedAssets,
          report: report,
        ),
        writingRulesMarkdown: baseSections.writingRulesMarkdown,
      ),
      selectedChapterExcerpts: List.unmodifiable(selectedChapters),
      selectedAssetBlocks: List.unmodifiable(selectedAssets),
      selectionWarnings: List.unmodifiable(warnings),
      selectionReportMarkdown: report,
    );
  }

  List<_ChapterCandidate> _chapterCandidates({
    required List<ProjectChapter> chapters,
    required Set<String> queryTerms,
  }) {
    final sorted = [...chapters]
      ..sort((a, b) => a.chapterIndex.compareTo(b.chapterIndex));
    final nearbyIds = sorted.reversed
        .take(_nearbyChapterCount)
        .map((chapter) => chapter.id)
        .toSet();
    final candidates = <_ChapterCandidate>[];
    for (final chapter in sorted) {
      final content = chapter.contentMarkdown.trim();
      if (content.isEmpty) {
        continue;
      }
      final hits = _matchingTerms('${chapter.title}\n$content', queryTerms);
      final nearby = nearbyIds.contains(chapter.id);
      final score = (nearby ? 100 : 0) + hits.length * 12;
      if (nearby || hits.isNotEmpty) {
        candidates.add(
          _ChapterCandidate(
            chapter: chapter,
            nearby: nearby,
            score: score,
            matchedTerms: hits,
            summary: _firstText(content, _summaryLength),
            keywordSnippet: _snippetForTerms(content, hits, _farExcerptLength),
          ),
        );
      }
    }
    candidates.sort((a, b) {
      final score = b.score.compareTo(a.score);
      if (score != 0) {
        return score;
      }
      return b.chapter.chapterIndex.compareTo(a.chapter.chapterIndex);
    });
    final nearby = candidates.where((candidate) => candidate.nearby);
    final remote = candidates
        .where((candidate) => !candidate.nearby)
        .take(_maxRemoteCandidates);
    return [...nearby, ...remote].toList(growable: false);
  }

  List<_AssetCandidate> _assetCandidates(WritingContextSections sections) {
    final candidates = <_AssetCandidate>[];
    void addMarkdown(String source, String title, String markdown) {
      final trimmed = markdown.trim();
      if (trimmed.isEmpty) {
        return;
      }
      candidates.add(
        _AssetCandidate(
          id: source,
          title: title,
          markdown: _firstText(trimmed, _assetBlockLength),
        ),
      );
    }

    addMarkdown(
      'project_bible.description',
      'Project Bible / Description',
      sections.projectBible.descriptionMarkdown,
    );
    addMarkdown(
      'project_bible.world_building',
      'Project Bible / World Building',
      sections.projectBible.worldBuildingMarkdown,
    );
    addMarkdown(
      'project_bible.characters',
      'Project Bible / Characters Blueprint',
      sections.projectBible.charactersBlueprintMarkdown,
    );
    addMarkdown(
      'project_bible.master_outline',
      'Project Bible / Master Outline',
      sections.projectBible.outlineMasterMarkdown,
    );
    addMarkdown(
      'project_bible.outline_detail',
      'Project Bible / Outline Detail YAML',
      sections.projectBible.outlineDetailYaml,
    );
    addMarkdown(
      'voice_profile',
      'Voice Profile',
      sections.voiceProfileMarkdown,
    );
    addMarkdown('story_engine', 'Story Engine', sections.storyEngineMarkdown);
    addMarkdown(
      'runtime_memory.state',
      'Runtime Memory / Runtime State',
      sections.runtimeMemory.runtimeState,
    );
    addMarkdown(
      'runtime_memory.threads',
      'Runtime Memory / Runtime Threads',
      sections.runtimeMemory.runtimeThreads,
    );
    addMarkdown(
      'runtime_memory.summary',
      'Runtime Memory / Story Summary',
      sections.runtimeMemory.storySummary,
    );
    addMarkdown(
      'runtime_memory.continuity_index',
      'Runtime Memory / Continuity Index',
      sections.runtimeMemory.continuityIndex,
    );
    addMarkdown(
      'runtime_memory.archive',
      'Runtime Memory / Chapter Archive',
      sections.runtimeMemory.chapterArchiveMarkdown,
    );
    return candidates;
  }

  Set<String> _queryTerms({
    required WritingProject project,
    required ChapterPlan plan,
    required WritingContextSections sections,
    required List<NovelCharacter> characters,
    required List<NovelRelationship> relationships,
  }) {
    final source = [
      project.title,
      project.description,
      plan.objectiveCard.chapterTitle,
      plan.objectiveCard.objective,
      plan.objectiveCard.pressureSource,
      plan.objectiveCard.payoffTarget,
      plan.objectiveCard.relationshipShift,
      plan.objectiveCard.hookType,
      plan.coreEvent,
      plan.emotionArc,
      plan.chapterHook,
      plan.outlineMarkdown,
      sections.runtimeMemory.runtimeState,
      sections.runtimeMemory.runtimeThreads,
      sections.runtimeMemory.continuityIndex,
      ...characters.expand(
        (character) => [
          character.name,
          character.aliases,
          character.tags,
          character.faction,
          character.role,
          character.currentStatus,
        ],
      ),
      ...relationships.map((relationship) => relationship.relationshipType),
    ].join('\n');
    return _extractTerms(source);
  }

  String _selectorPrompt({
    required WritingProject project,
    required ChapterPlan plan,
    required List<_ChapterCandidate> candidates,
    required List<_AssetCandidate> assets,
  }) {
    return '''
你是长篇小说章节生成的上下文筛选器。请只基于候选目录和短摘选择本章真正需要注入的前文与资产块。

## 输出契约
- 只输出 YAML，不要 Markdown，不要代码围栏，不要解释。
- `selected_chapters` 最多 5 个，必须使用候选中的 chapter_index。
- `selected_assets` 最多 8 个，必须使用候选中的 id。
- 如果候选不足，可以返回空数组。

YAML 形状：
selected_chapters:
  - chapter_index: 1
    reason: 为什么本章需要它
selected_assets:
  - id: voice_profile
    reason: 为什么需要它
summary: 一句话概括筛选依据

## 当前项目
- 标题：${project.title}
- 当前章节：第 ${plan.chapterIndex} 章 · ${plan.objectiveCard.chapterTitle.trim().isEmpty ? '第${plan.chapterIndex}章' : plan.objectiveCard.chapterTitle.trim()}

## 当前章节目标
${[if (plan.objectiveCard.objective.trim().isNotEmpty) '- Objective: ${plan.objectiveCard.objective.trim()}', if (plan.objectiveCard.pressureSource.trim().isNotEmpty) '- Pressure Source: ${plan.objectiveCard.pressureSource.trim()}', if (plan.objectiveCard.payoffTarget.trim().isNotEmpty) '- Payoff Target: ${plan.objectiveCard.payoffTarget.trim()}', if (plan.objectiveCard.relationshipShift.trim().isNotEmpty) '- Relationship Shift: ${plan.objectiveCard.relationshipShift.trim()}', if (plan.coreEvent.trim().isNotEmpty) '- Core Event: ${plan.coreEvent.trim()}', if (plan.emotionArc.trim().isNotEmpty) '- Emotion Arc: ${plan.emotionArc.trim()}', if (plan.chapterHook.trim().isNotEmpty) '- Chapter Hook: ${plan.chapterHook.trim()}', if (plan.outlineMarkdown.trim().isNotEmpty) '- Outline: ${_firstText(plan.outlineMarkdown, 600)}'].join('\n')}

## 前文章节候选
${candidates.isEmpty ? '[]' : jsonEncode(candidates.map((candidate) => candidate.toSelectorJson()).toList(growable: false))}

## 资产块候选
${assets.isEmpty ? '[]' : jsonEncode(assets.map((asset) => asset.toSelectorJson()).toList(growable: false))}
''';
  }

  _SelectorResult _parseSelectorResult(String raw) {
    final cleaned = _stripFence(raw).trim();
    if (_looksLikeJsonRoot(cleaned)) {
      throw const FormatException('selector output must be YAML, not JSON');
    }
    final parsed = loadYaml(cleaned);
    final root = _selectorMap(parsed);
    if (root == null) {
      throw const FormatException('selector YAML root is not a mapping');
    }
    final chapters = <_SelectedChapter>[];
    for (final item in _selectorList(root['selected_chapters'])) {
      final itemMap = _selectorMap(item);
      if (itemMap != null) {
        final index = itemMap['chapter_index'];
        if (index is num) {
          chapters.add(
            _SelectedChapter(
              chapterIndex: index.toInt(),
              reason: itemMap['reason']?.toString().trim() ?? '',
            ),
          );
        }
      }
    }
    final assets = <_SelectedAsset>[];
    for (final item in _selectorList(root['selected_assets'])) {
      final itemMap = _selectorMap(item);
      if (itemMap != null) {
        final id = itemMap['id']?.toString().trim();
        if (id != null && id.isNotEmpty) {
          assets.add(
            _SelectedAsset(
              id: id,
              reason: itemMap['reason']?.toString().trim() ?? '',
            ),
          );
        }
      }
    }
    return _SelectorResult(
      chapters: chapters,
      assets: assets,
      summary: root['summary']?.toString().trim() ?? '',
    );
  }

  Map<Object?, Object?>? _selectorMap(Object? value) {
    if (value is YamlMap) {
      return value;
    }
    if (value is Map<Object?, Object?>) {
      return value;
    }
    return null;
  }

  List<Object?> _selectorList(Object? value) {
    if (value is YamlList) {
      return value.nodes.map((node) => node.value).toList(growable: false);
    }
    if (value is List<Object?>) {
      return value;
    }
    return const [];
  }

  bool _looksLikeJsonRoot(String value) {
    final trimmed = value.trimLeft();
    return trimmed.startsWith('{') || trimmed.startsWith('[');
  }

  List<RetrievedChapterExcerpt> _selectedChapterExcerpts({
    required List<_ChapterCandidate> candidates,
    required _SelectorResult? selector,
  }) {
    final byIndex = {
      for (final candidate in candidates)
        candidate.chapter.chapterIndex: candidate,
    };
    final selected = <_ChapterCandidate, String>{};
    if (selector != null) {
      for (final chapter in selector.chapters) {
        final candidate = byIndex[chapter.chapterIndex];
        if (candidate != null) {
          selected[candidate] = chapter.reason;
        }
      }
    }
    if (selected.isEmpty) {
      for (final candidate in candidates.take(5)) {
        selected[candidate] = candidate.nearby
            ? '本地兜底：最近前文章节。'
            : '本地兜底：命中 ${candidate.matchedTerms.join('、')}。';
      }
    }
    return selected.entries
        .map((entry) {
          final candidate = entry.key;
          return RetrievedChapterExcerpt(
            chapterId: candidate.chapter.id,
            chapterIndex: candidate.chapter.chapterIndex,
            chapterTitle: candidate.chapter.title,
            reason: entry.value.trim().isEmpty ? '筛选器选择。' : entry.value.trim(),
            excerptMarkdown: candidate.nearby
                ? _tailText(
                    candidate.chapter.contentMarkdown,
                    _nearExcerptLength,
                  )
                : candidate.keywordSnippet,
            nearby: candidate.nearby,
          );
        })
        .toList(growable: false)
      ..sort((a, b) => a.chapterIndex.compareTo(b.chapterIndex));
  }

  List<RetrievedAssetBlock> _selectedAssetBlocks({
    required List<_AssetCandidate> candidates,
    required _SelectorResult? selector,
  }) {
    final byId = {for (final candidate in candidates) candidate.id: candidate};
    final selected = <_AssetCandidate, String>{};
    if (selector != null) {
      for (final asset in selector.assets) {
        final candidate = byId[asset.id];
        if (candidate != null) {
          selected[candidate] = asset.reason;
        }
      }
    }
    if (selected.isEmpty) {
      for (final candidate in _fallbackAssets(candidates)) {
        selected[candidate] = '本地兜底：高优先级资产块。';
      }
    }
    return selected.entries
        .map(
          (entry) => RetrievedAssetBlock(
            id: entry.key.id,
            title: entry.key.title,
            reason: entry.value.trim().isEmpty ? '筛选器选择。' : entry.value,
            markdown: entry.key.markdown,
          ),
        )
        .toList(growable: false);
  }

  Iterable<_AssetCandidate> _fallbackAssets(List<_AssetCandidate> candidates) {
    const preferred = [
      'voice_profile',
      'story_engine',
      'runtime_memory.state',
      'runtime_memory.threads',
      'runtime_memory.continuity_index',
      'runtime_memory.archive',
      'project_bible.description',
      'project_bible.world_building',
    ];
    final byId = {for (final candidate in candidates) candidate.id: candidate};
    final selected = <_AssetCandidate>[];
    for (final id in preferred) {
      final candidate = byId[id];
      if (candidate != null) {
        selected.add(candidate);
      }
    }
    if (selected.isEmpty) {
      return candidates.take(8);
    }
    return selected.take(8);
  }

  String _referencesMarkdown({
    required List<RetrievedChapterExcerpt> selectedChapters,
    required List<RetrievedAssetBlock> selectedAssets,
    required String report,
  }) {
    final blocks = <String>[];
    if (report.trim().isNotEmpty) {
      blocks.add('### Selection Report\n\n${report.trim()}');
    }
    if (selectedChapters.isNotEmpty) {
      blocks.add(
        [
          '### Prior Chapter Excerpts',
          for (final excerpt in selectedChapters)
            '''
#### Chapter ${excerpt.chapterIndex}: ${excerpt.chapterTitle}
Reason: ${excerpt.reason}
Scope: ${excerpt.nearby ? 'nearby-long' : 'remote-short'}

${excerpt.excerptMarkdown.trim()}''',
        ].join('\n\n'),
      );
    }
    if (selectedAssets.isNotEmpty) {
      blocks.add(
        [
          '### Retrieved Asset Blocks',
          for (final asset in selectedAssets)
            '''
#### ${asset.title}
Reason: ${asset.reason}
Source ID: ${asset.id}

${asset.markdown.trim()}''',
        ].join('\n\n'),
      );
    }
    return blocks.join('\n\n');
  }

  String _selectionReport({
    required List<RetrievedChapterExcerpt> selectedChapters,
    required List<RetrievedAssetBlock> selectedAssets,
    required _SelectorResult? selector,
    required bool usedFallback,
  }) {
    final lines = <String>[
      usedFallback ? 'Mode: local fallback' : 'Mode: LLM selector',
      if (selector != null && selector.summary.trim().isNotEmpty)
        'Summary: ${selector.summary.trim()}',
      'Selected chapters: ${selectedChapters.map((chapter) => chapter.chapterIndex).join(', ').trim().isEmpty ? 'none' : selectedChapters.map((chapter) => chapter.chapterIndex).join(', ')}',
      'Selected asset blocks: ${selectedAssets.map((asset) => asset.id).join(', ').trim().isEmpty ? 'none' : selectedAssets.map((asset) => asset.id).join(', ')}',
    ];
    return lines.join('\n');
  }

  Set<String> _extractTerms(String text) {
    final terms = <String>{};
    for (final match in RegExp(r'[A-Za-z][A-Za-z0-9_-]{2,}').allMatches(text)) {
      terms.add(match.group(0)!.toLowerCase());
    }
    for (final match in RegExp(r'[\u4e00-\u9fff]{2,8}').allMatches(text)) {
      final value = match.group(0)!;
      if (!_commonChineseTerms.contains(value)) {
        terms.add(value);
      }
      if (value.length > 4) {
        for (var index = 0; index <= value.length - 2; index += 2) {
          final part = value.substring(
            index,
            (index + 4).clamp(0, value.length),
          );
          if (part.length >= 2 && !_commonChineseTerms.contains(part)) {
            terms.add(part);
          }
        }
      }
    }
    return terms.where((term) => term.length >= 2).take(80).toSet();
  }

  List<String> _matchingTerms(String text, Set<String> terms) {
    final lower = text.toLowerCase();
    return terms.where((term) => lower.contains(term.toLowerCase())).toList()
      ..sort((a, b) => b.length.compareTo(a.length));
  }

  String _snippetForTerms(String text, List<String> terms, int maxLength) {
    final trimmed = text.trim();
    if (trimmed.length <= maxLength) {
      return trimmed;
    }
    var hitIndex = -1;
    for (final term in terms) {
      hitIndex = trimmed.indexOf(term);
      if (hitIndex >= 0) {
        break;
      }
    }
    if (hitIndex < 0) {
      return _firstText(trimmed, maxLength);
    }
    final start = (hitIndex - maxLength ~/ 3).clamp(0, trimmed.length);
    final end = (start + maxLength).clamp(0, trimmed.length);
    return trimmed.substring(start, end).trim();
  }

  String _firstText(String text, int maxLength) {
    final trimmed = text.trim();
    if (trimmed.length <= maxLength) {
      return trimmed;
    }
    return '${trimmed.substring(0, maxLength).trim()}...';
  }

  String _tailText(String text, int maxLength) {
    final trimmed = text.trim();
    if (trimmed.length <= maxLength) {
      return trimmed;
    }
    return '...${trimmed.substring(trimmed.length - maxLength).trim()}';
  }

  String _stripFence(String raw) {
    final trimmed = raw.trim();
    final match = RegExp(
      r'^```(?:json|yaml|yml)?\s*([\s\S]*?)\s*```$',
      caseSensitive: false,
    ).firstMatch(trimmed);
    return match?.group(1)?.trim() ?? trimmed;
  }
}

class _ChapterCandidate {
  const _ChapterCandidate({
    required this.chapter,
    required this.nearby,
    required this.score,
    required this.matchedTerms,
    required this.summary,
    required this.keywordSnippet,
  });

  final ProjectChapter chapter;
  final bool nearby;
  final int score;
  final List<String> matchedTerms;
  final String summary;
  final String keywordSnippet;

  Map<String, Object?> toSelectorJson() {
    return {
      'chapter_index': chapter.chapterIndex,
      'title': chapter.title,
      'nearby': nearby,
      'score': score,
      'matched_terms': matchedTerms.take(8).toList(growable: false),
      'summary': summary,
      'candidate_snippet': keywordSnippet,
    };
  }
}

class _AssetCandidate {
  const _AssetCandidate({
    required this.id,
    required this.title,
    required this.markdown,
  });

  final String id;
  final String title;
  final String markdown;

  Map<String, Object?> toSelectorJson() {
    return {'id': id, 'title': title, 'excerpt': markdown};
  }
}

class _SelectorResult {
  const _SelectorResult({
    required this.chapters,
    required this.assets,
    required this.summary,
  });

  final List<_SelectedChapter> chapters;
  final List<_SelectedAsset> assets;
  final String summary;

  bool get hasSelection => chapters.isNotEmpty || assets.isNotEmpty;
}

class _SelectedChapter {
  const _SelectedChapter({required this.chapterIndex, required this.reason});

  final int chapterIndex;
  final String reason;
}

class _SelectedAsset {
  const _SelectedAsset({required this.id, required this.reason});

  final String id;
  final String reason;
}

const _commonChineseTerms = {
  '当前',
  '章节',
  '目标',
  '压力',
  '关系',
  '项目',
  '正文',
  '生成',
  '故事',
  '角色',
  '需要',
  '线索',
  '本章',
  '前文',
  '状态',
};
