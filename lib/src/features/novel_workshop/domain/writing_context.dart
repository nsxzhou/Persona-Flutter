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
