import '../domain/writing_context.dart';

class WritingContextAssembler {
  const WritingContextAssembler();

  WritingContextBundle assemble(WritingContextSections sections) {
    final warnings = <String>[];
    final blocks = <String>[];

    _appendTextBlock(blocks, 'Output Contract', sections.outputContract);
    if (sections.outputContract.trim().isEmpty) {
      warnings.add('Output Contract 为空。');
    }

    _appendObjectiveCard(blocks, sections.chapterObjectiveCard);
    _appendChapterPlan(blocks, sections.chapterPlan);
    _appendProjectBible(blocks, sections.projectBible, warnings);
    _appendPromptAsset(
      blocks: blocks,
      title: 'Voice Profile',
      markdown: sections.voiceProfileMarkdown,
      warnings: warnings,
    );
    _appendPromptAsset(
      blocks: blocks,
      title: 'Story Engine',
      markdown: sections.storyEngineMarkdown,
      warnings: warnings,
    );
    _appendTextBlock(
      blocks,
      'Project Context',
      sections.projectContextMarkdown,
    );
    _appendRuntimeMemory(blocks, sections.runtimeMemory);
    _appendTextBlock(blocks, 'Writing Rules', sections.writingRulesMarkdown);

    return WritingContextBundle(
      promptMarkdown: blocks.join('\n\n'),
      sections: sections,
      warnings: List.unmodifiable(warnings),
    );
  }

  void _appendTextBlock(List<String> blocks, String title, String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return;
    }
    blocks.add('## $title\n\n$trimmed');
  }

  void _appendObjectiveCard(List<String> blocks, ChapterObjectiveCard card) {
    if (card.isEmpty) {
      return;
    }
    final lines = <String?>[
      _fieldLine('Chapter Title', card.chapterTitle),
      _fieldLine('Objective', card.objective),
      _fieldLine('Pressure Source', card.pressureSource),
      _fieldLine('Payoff Target', card.payoffTarget),
      _fieldLine('Relationship Shift', card.relationshipShift),
      _fieldLine('Hook Type', card.hookType),
    ].whereType<String>().toList(growable: false);
    blocks.add('## Chapter Objective Card\n\n${lines.join('\n')}');
  }

  void _appendChapterPlan(List<String> blocks, ChapterPlanPromptContext plan) {
    final lines = <String>[
      '- Volume: ${plan.volumeIndex} · ${plan.volumeTitle.trim()}',
      '- Local Chapter Index: ${plan.chapterLocalIndex}',
      '- Whole-book Chapter Index: ${plan.chapterIndex}',
      if (plan.coreEvent.trim().isNotEmpty)
        '- Core Event: ${plan.coreEvent.trim()}',
      if (plan.emotionArc.trim().isNotEmpty)
        '- Emotion Arc: ${plan.emotionArc.trim()}',
      if (plan.chapterHook.trim().isNotEmpty)
        '- Chapter Hook: ${plan.chapterHook.trim()}',
    ];
    final outline = plan.outlineMarkdown.trim();
    if (outline.isNotEmpty) {
      blocks.add('## Chapter Outline Node\n\n${lines.join('\n')}\n\n$outline');
      return;
    }
    blocks.add('## Chapter Outline Node\n\n${lines.join('\n')}');
  }

  void _appendProjectBible(
    List<String> blocks,
    ProjectBiblePromptContext bible,
    List<String> warnings,
  ) {
    if (bible.isEmpty) {
      warnings.add('Project Bible 为空。');
      return;
    }
    final parts = <String?>[
      _subsection('Description', bible.descriptionMarkdown),
      _subsection('World Building', bible.worldBuildingMarkdown),
      _subsection('Characters Blueprint', bible.charactersBlueprintMarkdown),
      _subsection('Master Outline', bible.outlineMasterMarkdown),
      _subsection('Outline Detail YAML', bible.outlineDetailYaml),
    ].whereType<String>().toList(growable: false);
    blocks.add('## Project Bible\n\n${parts.join('\n\n')}');
  }

  void _appendRuntimeMemory(List<String> blocks, RuntimeMemoryState memory) {
    if (memory.isEmpty) {
      return;
    }
    final parts = <String?>[
      _subsection('Characters Status', memory.charactersStatus),
      _subsection('Runtime State', memory.runtimeState),
      _subsection('Runtime Threads', memory.runtimeThreads),
      _subsection('Story Summary', memory.storySummary),
    ].whereType<String>().toList(growable: false);
    blocks.add('## Runtime Memory\n\n${parts.join('\n\n')}');
  }

  void _appendPromptAsset({
    required List<String> blocks,
    required String title,
    required String markdown,
    required List<String> warnings,
  }) {
    final trimmed = markdown.trim();
    if (trimmed.isEmpty) {
      warnings.add('$title 为空。');
      return;
    }
    if (!_hasMarkdownHeading(trimmed)) {
      warnings.add('$title 缺少 Markdown 标题。');
    }
    blocks.add('## $title\n\n$trimmed');
  }

  String? _fieldLine(String label, String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return '- $label: $trimmed';
  }

  String? _subsection(String title, String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return '### $title\n\n$trimmed';
  }

  bool _hasMarkdownHeading(String markdown) {
    return markdown.split('\n').any((line) => line.trimLeft().startsWith('# '));
  }
}
