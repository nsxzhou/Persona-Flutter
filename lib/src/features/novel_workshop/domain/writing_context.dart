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
    this.charactersStatus = '',
    this.runtimeState = '',
    this.runtimeThreads = '',
    this.storySummary = '',
  });

  final String charactersStatus;
  final String runtimeState;
  final String runtimeThreads;
  final String storySummary;

  bool get isEmpty {
    return [
      charactersStatus,
      runtimeState,
      runtimeThreads,
      storySummary,
    ].every((value) => value.trim().isEmpty);
  }
}

class WritingContextSections {
  const WritingContextSections({
    required this.outputContract,
    required this.chapterObjectiveCard,
    required this.voiceProfileMarkdown,
    required this.storyEngineMarkdown,
    required this.projectContextMarkdown,
    required this.runtimeMemory,
    required this.writingRulesMarkdown,
  });

  final String outputContract;
  final ChapterObjectiveCard chapterObjectiveCard;
  final String voiceProfileMarkdown;
  final String storyEngineMarkdown;
  final String projectContextMarkdown;
  final RuntimeMemoryState runtimeMemory;
  final String writingRulesMarkdown;
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
