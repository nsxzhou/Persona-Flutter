import '../../../core/llm/application/markdown_completion_service.dart';
import '../../../core/llm/domain/llm_error_utils.dart';
import '../../../core/tasks/application/prompt_trace_recorder.dart';
import '../../../core/tasks/application/workflow_task_repository.dart';
import '../../projects/domain/project_repository.dart';
import '../../projects/domain/writing_project.dart';
import '../../settings/domain/provider_config.dart';
import '../../settings/domain/provider_config_repository.dart';
import '../domain/novel_workshop.dart';
import '../domain/novel_workshop_repository.dart';
import '../domain/writing_context.dart';
import 'project_prompt_asset_resolver.dart';
import 'writing_context_assembler.dart';

class ChapterGenerationPipeline {
  const ChapterGenerationPipeline({
    required NovelWorkshopRepository repository,
    required ProjectRepository projectRepository,
    required ProviderConfigRepository providerRepository,
    required ProjectPromptAssetResolver promptAssetResolver,
    required WritingContextAssembler contextAssembler,
    required MarkdownCompletionService completionService,
    required WorkflowTaskRepository workflowTaskRepository,
  }) : _repository = repository,
       _projectRepository = projectRepository,
       _providerRepository = providerRepository,
       _promptAssetResolver = promptAssetResolver,
       _contextAssembler = contextAssembler,
       _completionService = completionService,
       _workflowTaskRepository = workflowTaskRepository;

  final NovelWorkshopRepository _repository;
  final ProjectRepository _projectRepository;
  final ProviderConfigRepository _providerRepository;
  final ProjectPromptAssetResolver _promptAssetResolver;
  final WritingContextAssembler _contextAssembler;
  final MarkdownCompletionService _completionService;
  final WorkflowTaskRepository _workflowTaskRepository;

  Future<ChapterGenerationResult> generateChapter({
    required String projectId,
    required String chapterPlanId,
    bool replaceExisting = false,
  }) async {
    if (await _repository.hasRunningChapterGeneration(chapterPlanId)) {
      throw StateError('该章节已有运行中的生成任务。');
    }

    final run = await _repository.createChapterGenerationRun(
      ChapterGenerationRunInput(
        projectId: projectId,
        chapterPlanId: chapterPlanId,
        providerId: '',
        modelName: '',
      ),
    );

    var currentRun = run;
    var currentStage = currentRun.stage;
    final log = StringBuffer(currentRun.logs);
    ProviderConfig? resolvedProvider;

    Future<void> transition(
      ChapterGenerationStatus status,
      ChapterGenerationStage? stage, {
      String? message,
      String? chapterId,
      String? providerId,
      String? modelName,
      String? errorMessage,
      String? contextWarningsMarkdown,
      DateTime? startedAt,
      DateTime? completedAt,
    }) async {
      currentStage = stage;
      if (message != null && message.trim().isNotEmpty) {
        _appendLog(log, message);
      }
      currentRun = await _repository.updateChapterGenerationRunState(
        id: currentRun.id,
        status: status,
        stage: stage,
        chapterId: chapterId,
        providerId: providerId,
        modelName: modelName,
        errorMessage: errorMessage,
        logs: log.toString(),
        contextWarningsMarkdown: contextWarningsMarkdown,
        startedAt: startedAt,
        completedAt: completedAt,
      );
    }

    try {
      final project = await _requireProject(projectId);
      final provider = await _requireProvider(project);
      final modelName = _requireModelName(project, provider);
      final plan = await _requirePlan(projectId, chapterPlanId);
      resolvedProvider = provider;
      final traceRecorder = PromptTraceRecorder(
        repository: _workflowTaskRepository,
        workflowTaskId: currentRun.workflowTaskId,
        workflowKind: chapterGenerationWorkflowTaskKind,
        runId: currentRun.id,
        providerId: provider.id,
        providerApiKey: provider.apiKey,
        modelName: modelName,
        stageLabel: () => currentStage?.name,
      );
      final existingChapter = await _repository.findChapterByPlan(
        chapterPlanId,
      );
      if (existingChapter != null &&
          existingChapter.contentMarkdown.trim().isNotEmpty &&
          !replaceExisting) {
        throw StateError('章节已有正文，需确认覆盖后才能重新生成。');
      }

      await transition(
        ChapterGenerationStatus.running,
        ChapterGenerationStage.preparingContext,
        message: '阶段: 准备上下文。读取项目、章节目标、Prompt 资产与运行时记忆。',
        providerId: provider.id,
        modelName: modelName,
        startedAt: DateTime.now(),
      );

      final assets = await _promptAssetResolver.resolve(projectId);
      final bible = await _repository.ensureProjectBible(projectId);
      final runtimeMemory = await _repository.findRuntimeMemory(projectId);
      final characters = await _repository.watchCharacters(projectId).first;
      final relationships = await _repository
          .watchRelationships(projectId)
          .first;
      final contextWarnings = <String>[
        ...assets.warnings,
        if (ProjectBiblePromptContext(
          descriptionMarkdown: bible.descriptionMarkdown,
          worldBuildingMarkdown: bible.worldBuildingMarkdown,
          charactersBlueprintMarkdown: bible.charactersBlueprintMarkdown,
          outlineMasterMarkdown: bible.outlineMasterMarkdown,
          outlineDetailYaml: bible.outlineDetailYaml,
        ).isEmpty)
          'Project Bible 为空。',
        if (characters.isEmpty) '结构化角色卡片为空。',
        if (runtimeMemory == null || runtimeMemory.state.isEmpty) '运行时记忆为空。',
      ];
      final bundle = _contextAssembler.assemble(
        WritingContextSections(
          outputContract: _outputContract,
          projectBible: ProjectBiblePromptContext(
            descriptionMarkdown: bible.descriptionMarkdown,
            worldBuildingMarkdown: bible.worldBuildingMarkdown,
            charactersBlueprintMarkdown: bible.charactersBlueprintMarkdown,
            outlineMasterMarkdown: bible.outlineMasterMarkdown,
            outlineDetailYaml: bible.outlineDetailYaml,
          ),
          chapterPlan: ChapterPlanPromptContext(
            volumeIndex: plan.volumeIndex,
            volumeTitle: plan.volumeTitle,
            chapterLocalIndex: plan.chapterLocalIndex,
            chapterIndex: plan.chapterIndex,
            coreEvent: plan.coreEvent,
            emotionArc: plan.emotionArc,
            chapterHook: plan.chapterHook,
            outlineMarkdown: plan.outlineMarkdown,
          ),
          chapterObjectiveCard: plan.objectiveCard,
          voiceProfileMarkdown: assets.voiceProfileMarkdown,
          storyEngineMarkdown: assets.storyEngineMarkdown,
          projectContextMarkdown: _projectContextMarkdown(project),
          characterGraphMarkdown: _characterGraphMarkdown(
            characters,
            relationships,
          ),
          runtimeMemory: runtimeMemory?.state ?? const RuntimeMemoryState(),
          writingRulesMarkdown: _writingRulesMarkdown(project),
        ),
      );
      contextWarnings.addAll(bundle.warnings);

      await transition(
        ChapterGenerationStatus.running,
        ChapterGenerationStage.generatingDraft,
        message: '阶段: 生成正文。调用模型生成纯 Markdown 章节正文。',
        contextWarningsMarkdown: _warningsMarkdown(contextWarnings),
      );

      final generated = await _completionService.completeMarkdown(
        provider: provider,
        prompt: bundle.promptMarkdown,
        temperature: 0.75,
        modelName: modelName,
        promptTrace: traceRecorder.config(label: 'generate_chapter_draft'),
      );
      final content = _cleanMarkdownDraft(generated);
      if (content.trim().isEmpty) {
        throw StateError('模型返回了空章节正文。');
      }

      await transition(
        ChapterGenerationStatus.running,
        ChapterGenerationStage.savingChapter,
        message: '阶段: 保存正文。写入当前章节正文。',
      );
      final chapter = await _repository.saveChapter(
        id: existingChapter?.id,
        input: ProjectChapterInput(
          projectId: projectId,
          chapterPlanId: plan.id,
          chapterIndex: plan.chapterIndex,
          title: _chapterTitle(plan),
          contentMarkdown: content,
        ),
      );

      await transition(
        ChapterGenerationStatus.running,
        ChapterGenerationStage.proposingMemoryPatch,
        message: '阶段: 同步记忆。生成角色卡片和关系图更新提案。',
      );
      await _proposeMemoryPatch(
        provider: provider,
        modelName: modelName,
        traceRecorder: traceRecorder,
        chapter: chapter,
        project: project,
        plan: plan,
        characters: characters,
        relationships: relationships,
      );

      await transition(
        ChapterGenerationStatus.succeeded,
        null,
        chapterId: chapter.id,
        message: '章节生成完成。',
        contextWarningsMarkdown: _warningsMarkdown(contextWarnings),
        completedAt: DateTime.now(),
      );

      return ChapterGenerationResult(
        run: currentRun,
        chapter: chapter,
        contextWarnings: List.unmodifiable(contextWarnings),
        workflowTaskId: currentRun.workflowTaskId,
      );
    } on Object catch (error) {
      await transition(
        ChapterGenerationStatus.failed,
        null,
        message: '章节生成失败。',
        errorMessage: _sanitizeError(error, resolvedProvider),
        completedAt: DateTime.now(),
      );
      rethrow;
    }
  }

  Future<WritingProject> _requireProject(String projectId) async {
    final project = await _projectRepository.findProject(projectId);
    if (project == null) {
      throw StateError('Project does not exist: $projectId');
    }
    return project;
  }

  Future<ProviderConfig> _requireProvider(WritingProject project) async {
    final providerId = project.defaultProviderId?.trim();
    if (providerId == null || providerId.isEmpty) {
      throw StateError('项目需要默认 Provider 才能生成章节。');
    }
    final provider = await _providerRepository.findProvider(providerId);
    if (provider == null) {
      throw StateError('项目默认 Provider 不存在。');
    }
    return provider;
  }

  String _requireModelName(WritingProject project, ProviderConfig provider) {
    final modelName = project.defaultModelName?.trim();
    if (modelName == null || modelName.isEmpty) {
      throw StateError('项目需要默认模型才能生成章节。');
    }
    if (!provider.modelNames.contains(modelName) &&
        provider.defaultModel != modelName) {
      throw StateError('项目默认模型不属于所选 Provider。');
    }
    return modelName;
  }

  Future<ChapterPlan> _requirePlan(
    String projectId,
    String chapterPlanId,
  ) async {
    final plan = await _repository.findChapterPlan(chapterPlanId);
    if (plan == null) {
      throw StateError('Chapter Plan 不存在。');
    }
    if (plan.projectId != projectId) {
      throw StateError('章节计划不属于当前项目。');
    }
    return plan;
  }

  String _projectContextMarkdown(WritingProject project) {
    final lines = <String>[
      '- Project Title: ${project.title.trim()}',
      '- Language: ${project.language.trim()}',
      '- Chapter Target Length: ${project.targetLength} 字左右',
      '- Novel Target Length: ${project.totalTargetLength} 字左右',
      '- Narrative Perspective: ${project.narrativePerspective.trim()}',
    ];
    return lines.join('\n');
  }

  String _characterGraphMarkdown(
    List<NovelCharacter> characters,
    List<NovelRelationship> relationships,
  ) {
    if (characters.isEmpty && relationships.isEmpty) {
      return '';
    }
    final characterById = {
      for (final character in characters) character.id: character,
    };
    final buffer = StringBuffer();
    if (characters.isNotEmpty) {
      buffer.writeln('### Character Cards');
      for (final character in characters) {
        buffer.writeln(
          '- ${character.name}: ${[character.role, character.faction, character.longTermGoal, character.currentStatus].where((value) => value.trim().isNotEmpty).join(' / ')}',
        );
      }
    }
    if (relationships.isNotEmpty) {
      if (buffer.isNotEmpty) {
        buffer.writeln();
      }
      buffer.writeln('### Directed Relationships');
      for (final relationship in relationships) {
        final from =
            characterById[relationship.fromCharacterId]?.name ?? 'Unknown';
        final to = characterById[relationship.toCharacterId]?.name ?? 'Unknown';
        buffer.writeln(
          '- $from -> $to: ${relationship.relationshipType} '
          '(strength ${relationship.strength}) ${relationship.status} '
          '${relationship.description}',
        );
      }
    }
    return buffer.toString().trim();
  }

  Future<void> _proposeMemoryPatch({
    required ProviderConfig provider,
    required String modelName,
    required PromptTraceRecorder traceRecorder,
    required ProjectChapter chapter,
    required WritingProject project,
    required ChapterPlan plan,
    required List<NovelCharacter> characters,
    required List<NovelRelationship> relationships,
  }) async {
    final prompt =
        '''
你是长篇小说项目的连续性编辑。阅读当前章节正文后，只输出 YAML，用作待审阅的结构化记忆 Patch。

## 输出契约
- 只输出 YAML。
- 不要输出 Markdown、代码围栏、解释。
- 根节点允许 `characters`、`relationships`、`runtimeMemory`。
- 只包含本章确实发生变化的角色和关系，不要输出全量快照。
- `characters` 中每项必须有 `name`，可更新 `aliases`、`tags`、`faction`、`role`、`longTermGoal`、`currentStatus`、`secrets`、`firstChapterIndex`、`lastChapterIndex`。
- `relationships` 中每项必须有 `from`、`to`，可更新 `type`、`strength`、`status`、`description`、`lastChangedChapterIndex`。
- `runtimeMemory` 可包含 `runtimeState`、`runtimeThreads`、`storySummary`。

## 项目
- 标题：${project.title}
- 当前章节：第 ${plan.chapterIndex} 章 · ${chapter.title}

## 已有结构化角色和关系
${_characterGraphMarkdown(characters, relationships)}

## 章节正文
${chapter.contentMarkdown}
''';
    final generated = await _completionService.completeMarkdown(
      provider: provider,
      prompt: prompt,
      temperature: 0.25,
      modelName: modelName,
      promptTrace: traceRecorder.config(label: 'propose_memory_patch'),
    );
    final patchYaml = _cleanMarkdownDraft(generated);
    if (patchYaml.trim().isEmpty) {
      await _repository.saveMemorySyncProposal(
        MemorySyncProposalInput(
          chapterId: chapter.id,
          contentHash: chapter.contentHash,
          patchYaml: '',
        ),
      );
      return;
    }
    await _repository.saveMemorySyncProposal(
      MemorySyncProposalInput(
        chapterId: chapter.id,
        contentHash: chapter.contentHash,
        patchYaml: patchYaml,
      ),
    );
  }

  String _writingRulesMarkdown(WritingProject project) {
    return [
      '- 使用项目语言：${project.language.trim()}。',
      '- 使用叙事视角：${project.narrativePerspective.trim()}。',
      '- 正文长度尽量接近 ${project.targetLength} 字；不要为了凑字数牺牲节奏。',
      '- 只写当前章节正文，不输出分析、解释、前言、后记或元信息。',
      '- 不要输出 Markdown 代码围栏。',
    ].join('\n');
  }

  String _chapterTitle(ChapterPlan plan) {
    final title = plan.objectiveCard.chapterTitle.trim();
    return title.isEmpty ? '第${plan.chapterIndex}章' : title;
  }

  String _warningsMarkdown(List<String> warnings) {
    final normalized = warnings
        .map((warning) => warning.trim())
        .where((warning) => warning.isNotEmpty)
        .toList(growable: false);
    if (normalized.isEmpty) {
      return '';
    }
    return normalized.map((warning) => '- $warning').join('\n');
  }

  String _cleanMarkdownDraft(String markdown) {
    var text = markdown.trim();
    final fencePattern = RegExp(
      r'^```(?:markdown|md)?\s*\n([\s\S]*?)\n```\s*$',
      caseSensitive: false,
    );
    final match = fencePattern.firstMatch(text);
    if (match != null) {
      text = match.group(1) ?? '';
    }
    return text.trim();
  }

  String _sanitizeError(Object error, ProviderConfig? provider) {
    return sanitizeLlmError(error, provider?.apiKey ?? '');
  }

  void _appendLog(StringBuffer buffer, String message) {
    final timestamp = DateTime.now().toIso8601String();
    if (buffer.isNotEmpty && !buffer.toString().endsWith('\n')) {
      buffer.writeln();
    }
    buffer.writeln('[$timestamp] $message');
  }
}

const _outputContract = '''
只输出当前章节正文。
输出必须是纯 Markdown 正文，不要 JSON，不要代码围栏，不要解释生成过程。
不要重复章节标题，章节标题由系统保存。
''';
