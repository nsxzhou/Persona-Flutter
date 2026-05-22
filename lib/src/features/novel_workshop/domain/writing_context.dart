class ChapterObjectiveCard {
  const ChapterObjectiveCard({
    this.chapterTitle = '',
    this.objective = '',
    this.pressureSource = '',
    this.payoffTarget = '',
    this.relationshipShift = '',
    this.hookType = '',
  });

  final String chapterTitle;
  final String objective;
  final String pressureSource;
  final String payoffTarget;
  final String relationshipShift;
  final String hookType;

  bool get isEmpty {
    return [
      chapterTitle,
      objective,
      pressureSource,
      payoffTarget,
      relationshipShift,
      hookType,
    ].every((value) => value.trim().isEmpty);
  }
}

class RuntimeMemoryState {
  const RuntimeMemoryState({
    this.runtimeState = '',
    this.runtimeThreads = '',
    this.storySummary = '',
    this.continuityIndex = '',
    this.chapterArchiveMarkdown = '',
  });

  final String runtimeState;
  final String runtimeThreads;
  final String storySummary;
  final String continuityIndex;
  final String chapterArchiveMarkdown;

  bool get isEmpty {
    return [
      runtimeState,
      runtimeThreads,
      storySummary,
      continuityIndex,
      chapterArchiveMarkdown,
    ].every((value) => value.trim().isEmpty);
  }
}

class WritingContextSections {
  const WritingContextSections({
    required this.outputContract,
    required this.projectBible,
    required this.chapterPlan,
    required this.chapterObjectiveCard,
    required this.voiceProfileMarkdown,
    required this.storyEngineMarkdown,
    required this.projectContextMarkdown,
    this.characterGraphMarkdown = '',
    required this.runtimeMemory,
    this.retrievedReferencesMarkdown = '',
    required this.writingRulesMarkdown,
  });

  final String outputContract;
  final ProjectBiblePromptContext projectBible;
  final ChapterPlanPromptContext chapterPlan;
  final ChapterObjectiveCard chapterObjectiveCard;
  final String voiceProfileMarkdown;
  final String storyEngineMarkdown;
  final String projectContextMarkdown;
  final String characterGraphMarkdown;
  final RuntimeMemoryState runtimeMemory;
  final String retrievedReferencesMarkdown;
  final String writingRulesMarkdown;
}

class ProjectBiblePromptContext {
  const ProjectBiblePromptContext({
    this.descriptionMarkdown = '',
    this.worldBuildingMarkdown = '',
    this.charactersBlueprintMarkdown = '',
    this.outlineMasterMarkdown = '',
    this.outlineDetailYaml = '',
  });

  final String descriptionMarkdown;
  final String worldBuildingMarkdown;
  final String charactersBlueprintMarkdown;
  final String outlineMasterMarkdown;
  final String outlineDetailYaml;

  bool get isEmpty {
    return [
      descriptionMarkdown,
      worldBuildingMarkdown,
      charactersBlueprintMarkdown,
      outlineMasterMarkdown,
      outlineDetailYaml,
    ].every((value) => value.trim().isEmpty);
  }
}

class ChapterPlanPromptContext {
  const ChapterPlanPromptContext({
    required this.volumeIndex,
    required this.volumeTitle,
    required this.chapterLocalIndex,
    required this.chapterIndex,
    this.coreEvent = '',
    this.emotionArc = '',
    this.chapterHook = '',
    this.outlineMarkdown = '',
  });

  final int volumeIndex;
  final String volumeTitle;
  final int chapterLocalIndex;
  final int chapterIndex;
  final String coreEvent;
  final String emotionArc;
  final String chapterHook;
  final String outlineMarkdown;
}

class WritingContextBundle {
  const WritingContextBundle({
    required this.promptMarkdown,
    required this.sections,
    required this.warnings,
  });

  final String promptMarkdown;
  final WritingContextSections sections;
  final List<String> warnings;
}

class ChapterGenerationContextPreview {
  const ChapterGenerationContextPreview({
    required this.promptMarkdown,
    required this.warnings,
    required this.projectBibleIncluded,
    required this.chapterObjectiveCardIncluded,
    required this.runtimeMemoryIncluded,
    required this.characterCount,
    required this.relationshipCount,
    required this.voiceProfileIncluded,
    required this.storyEngineIncluded,
    this.selectedChapterExcerptCount = 0,
    this.selectedAssetBlockCount = 0,
    this.selectionReportMarkdown = '',
  });

  final String promptMarkdown;
  final List<String> warnings;
  final bool projectBibleIncluded;
  final bool chapterObjectiveCardIncluded;
  final bool runtimeMemoryIncluded;
  final int characterCount;
  final int relationshipCount;
  final bool voiceProfileIncluded;
  final bool storyEngineIncluded;
  final int selectedChapterExcerptCount;
  final int selectedAssetBlockCount;
  final String selectionReportMarkdown;
}

class ProjectPromptAssets {
  const ProjectPromptAssets({
    this.voiceProfileMarkdown = '',
    this.storyEngineMarkdown = '',
    this.plotSkeletonMarkdown = '',
    this.warnings = const [],
  });

  final String voiceProfileMarkdown;
  final String storyEngineMarkdown;
  final String plotSkeletonMarkdown;
  final List<String> warnings;
}

class RetrievedChapterExcerpt {
  const RetrievedChapterExcerpt({
    required this.chapterId,
    required this.chapterIndex,
    required this.chapterTitle,
    required this.reason,
    required this.excerptMarkdown,
    required this.nearby,
  });

  final String chapterId;
  final int chapterIndex;
  final String chapterTitle;
  final String reason;
  final String excerptMarkdown;
  final bool nearby;
}

class RetrievedAssetBlock {
  const RetrievedAssetBlock({
    required this.id,
    required this.title,
    required this.reason,
    required this.markdown,
  });

  final String id;
  final String title;
  final String reason;
  final String markdown;
}

class RetrievedWritingContext {
  const RetrievedWritingContext({
    required this.sections,
    required this.selectedChapterExcerpts,
    required this.selectedAssetBlocks,
    required this.selectionWarnings,
    required this.selectionReportMarkdown,
  });

  final WritingContextSections sections;
  final List<RetrievedChapterExcerpt> selectedChapterExcerpts;
  final List<RetrievedAssetBlock> selectedAssetBlocks;
  final List<String> selectionWarnings;
  final String selectionReportMarkdown;
}
