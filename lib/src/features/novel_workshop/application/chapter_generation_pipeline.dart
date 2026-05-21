import '../../../core/llm/application/markdown_completion_service.dart';
import '../../../core/llm/domain/llm_error_utils.dart';
import '../../../core/tasks/application/prompt_trace_recorder.dart';
import '../../../core/tasks/application/workflow_task_repository.dart';
import 'package:yaml/yaml.dart';
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

  static const int _promptArchiveDigestThreshold = 45000;

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
      final baseSections = WritingContextSections(
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
      );
      var bundle = _contextAssembler.assemble(baseSections);
      if (_shouldDigestChapterArchive(bundle.promptMarkdown, baseSections)) {
        final digestedMemory = await _temporaryArchiveDigestMemory(
          provider: provider,
          modelName: modelName,
          traceRecorder: traceRecorder,
          project: project,
          plan: plan,
          memory: baseSections.runtimeMemory,
        );
        bundle = _contextAssembler.assemble(
          WritingContextSections(
            outputContract: baseSections.outputContract,
            projectBible: baseSections.projectBible,
            chapterPlan: baseSections.chapterPlan,
            chapterObjectiveCard: baseSections.chapterObjectiveCard,
            voiceProfileMarkdown: baseSections.voiceProfileMarkdown,
            storyEngineMarkdown: baseSections.storyEngineMarkdown,
            projectContextMarkdown: baseSections.projectContextMarkdown,
            characterGraphMarkdown: baseSections.characterGraphMarkdown,
            runtimeMemory: digestedMemory,
            writingRulesMarkdown: baseSections.writingRulesMarkdown,
          ),
        );
        contextWarnings.add('章节归档过长，本次生成已使用临时 Chapter Archive Digest。');
      }
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
        message: '阶段: 同步记忆。生成待审阅 Runtime Memory、角色卡片和关系图 Patch。',
      );
      await _proposeMemoryPatch(
        provider: provider,
        modelName: modelName,
        traceRecorder: traceRecorder,
        chapter: chapter,
        project: project,
        plan: plan,
        currentMemory: runtimeMemory?.state ?? const RuntimeMemoryState(),
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

  bool _shouldDigestChapterArchive(
    String promptMarkdown,
    WritingContextSections sections,
  ) {
    return promptMarkdown.length > _promptArchiveDigestThreshold &&
        sections.runtimeMemory.chapterArchiveMarkdown.trim().isNotEmpty;
  }

  Future<RuntimeMemoryState> _temporaryArchiveDigestMemory({
    required ProviderConfig provider,
    required String modelName,
    required PromptTraceRecorder traceRecorder,
    required WritingProject project,
    required ChapterPlan plan,
    required RuntimeMemoryState memory,
  }) async {
    final archive = memory.chapterArchiveMarkdown.trim();
    if (archive.isEmpty) {
      return memory;
    }
    final prompt =
        '''
你是长篇小说项目的连续性归档压缩器。请把下方 Chapter Archive 压缩成仅供本次章节生成使用的 Chapter Archive Digest。

## 输出契约
- 只输出 Markdown。
- 不要输出解释、前言、代码围栏。
- 保留与当前章节承接有关的已发生事实、未解决线索、世界规则变化、因果链。
- 不要新增事实，不要改写为未来规划，不要加入人物卡全量状态。
- 控制在 1200 字以内。

## 项目
- 标题：${project.title}
- 当前目标章节：第 ${plan.chapterIndex} 章 · ${_chapterTitle(plan)}

## Continuity Index
${memory.continuityIndex.trim().isEmpty ? '（空）' : memory.continuityIndex.trim()}

## Chapter Archive
$archive
''';
    final digest = _cleanMarkdownDraft(
      await _completionService.completeMarkdown(
        provider: provider,
        prompt: prompt,
        temperature: 0.2,
        modelName: modelName,
        promptTrace: traceRecorder.config(label: 'digest_chapter_archive'),
      ),
    );
    if (digest.trim().isEmpty) {
      return memory;
    }
    return RuntimeMemoryState(
      runtimeState: memory.runtimeState,
      runtimeThreads: memory.runtimeThreads,
      storySummary: memory.storySummary,
      continuityIndex: memory.continuityIndex,
      chapterArchiveMarkdown: '# Chapter Archive Digest\n\n${digest.trim()}',
    );
  }

  Future<void> _proposeMemoryPatch({
    required ProviderConfig provider,
    required String modelName,
    required PromptTraceRecorder traceRecorder,
    required ProjectChapter chapter,
    required WritingProject project,
    required ChapterPlan plan,
    required RuntimeMemoryState currentMemory,
    required List<NovelCharacter> characters,
    required List<NovelRelationship> relationships,
  }) async {
    final prompt =
        '''
你是长篇小说项目的连续性档案编辑。你的任务是把刚写完的章节转化为待审阅的结构化记忆 Patch，让下一章能准确继承人物、关系、线索和世界状态。

## 输出契约
- 只输出 YAML。
- 不要输出 Markdown、代码围栏、解释。
- 根节点允许 `characters`、`relationships`、`runtimeMemory`。
- `characters` 中每项必须有 `name`，只写本章需要新增或修改的字段，可更新 `aliases`、`tags`、`faction`、`role`、`longTermGoal`、`currentStatus`、`secrets`、`firstChapterIndex`、`lastChapterIndex`。
- `relationships` 中每项必须有 `from`、`to`，只写本章需要新增或修改的字段，可更新 `type`、`strength`、`status`、`description`、`lastChangedChapterIndex`。
- `runtimeMemory` 只输出本章需要修改或追加的字段，可包含 `runtimeState`、`runtimeThreads`、`storySummary`、`continuityIndex`、`chapterArchiveMarkdown`。

## 更新原则
只记录本章正文明确发生或明确确认的变化，不补全、不推测、不替作者规划未来。不要输出全量快照；没有变化的角色、关系和 Runtime Memory 字段不要重复写入。
字段缺失表示保留旧值；只有需要清空字段时才显式输出空字符串。

`runtimeMemory` 用来服务下一章承接：
- `runtimeState` 记录章节结束后的地点、资源、伤势、任务状态和世界规则变化。
- `runtimeThreads` 记录未解决悬念、伏笔债务、承诺、威胁、追踪线索和待回收信息。
- `storySummary` 用 3-6 句更新全局故事摘要，保留因果链和本章对下一章的直接影响。
- `continuityIndex` 是高密度触发索引，只保留悬念、状态、世界规则变化等下一章必须注意的短条目；不要写人物卡全量状态。
- `chapterArchiveMarkdown` 只输出本章新增的章级归档片段，系统会追加到原有归档后面。

如果本章没有结构化变化，可以输出空列表或空对象；不要为了填字段编造变化。

## 项目
- 标题：${project.title}
- 当前章节：第 ${plan.chapterIndex} 章 · ${chapter.title}

## 已有结构化角色和关系
${_characterGraphMarkdown(characters, relationships)}

## 当前 Runtime Memory
${_runtimeMemoryMarkdown(currentMemory)}

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
          proposedMemory: currentMemory,
          patchYaml: '',
        ),
      );
      return;
    }
    final proposedMemory = _parseProposedRuntimeMemory(
      patchYaml,
      fallback: currentMemory,
    );
    await _repository.saveMemorySyncProposal(
      MemorySyncProposalInput(
        chapterId: chapter.id,
        contentHash: chapter.contentHash,
        proposedMemory: proposedMemory,
        patchYaml: patchYaml,
      ),
    );
  }

  String _runtimeMemoryMarkdown(RuntimeMemoryState memory) {
    if (memory.isEmpty) {
      return '（空）';
    }
    return [
      if (memory.runtimeState.trim().isNotEmpty)
        '### Runtime State\n\n${memory.runtimeState.trim()}',
      if (memory.runtimeThreads.trim().isNotEmpty)
        '### Runtime Threads\n\n${memory.runtimeThreads.trim()}',
      if (memory.storySummary.trim().isNotEmpty)
        '### Story Summary\n\n${memory.storySummary.trim()}',
      if (memory.continuityIndex.trim().isNotEmpty)
        '### Continuity Index\n\n${memory.continuityIndex.trim()}',
      if (memory.chapterArchiveMarkdown.trim().isNotEmpty)
        '### Chapter Archive\n\n${memory.chapterArchiveMarkdown.trim()}',
    ].join('\n\n');
  }

  RuntimeMemoryState _parseProposedRuntimeMemory(
    String patchYaml, {
    required RuntimeMemoryState fallback,
  }) {
    try {
      final parsed = loadYaml(patchYaml);
      if (parsed is! YamlMap) {
        return fallback;
      }
      final memory = parsed['runtimeMemory'];
      if (memory is! YamlMap) {
        return fallback;
      }
      return RuntimeMemoryState(
        runtimeState: _yamlMapString(memory, 'runtimeState'),
        runtimeThreads: _yamlMapString(memory, 'runtimeThreads'),
        storySummary: _yamlMapString(memory, 'storySummary'),
        continuityIndex: _yamlMapString(memory, 'continuityIndex'),
        chapterArchiveMarkdown: _yamlMapString(
          memory,
          'chapterArchiveMarkdown',
        ),
      );
    } on Object {
      return fallback;
    }
  }

  String _yamlMapString(YamlMap map, String key) {
    for (final entry in map.entries) {
      if (entry.key.toString() == key) {
        return _yamlString(entry.value);
      }
    }
    return '';
  }

  String _yamlString(Object? value) {
    if (value == null) {
      return '';
    }
    if (value is YamlScalar) {
      return value.value?.toString().trim() ?? '';
    }
    if (value is String) {
      return value.trim();
    }
    return value.toString().trim();
  }

  String _writingRulesMarkdown(WritingProject project) {
    return [
      '- 写作语言：${project.language.trim()}。',
      '- 叙事视角：${project.narrativePerspective.trim()}。',
      '- 篇幅目标：尽量接近 ${project.targetLength} 字；节奏优先，不为凑字数拖长场景。',
      '- 只写当前章节正文，不写分析、解释、前言、后记、标题或元信息；不要输出 Markdown 代码围栏。',
      '- 上下文优先级：Chapter Objective Card 和 Chapter Outline Node 决定本章任务；Project Bible 决定设定边界；Voice Profile 决定文风；Story Engine 决定剧情推进方式；Runtime Memory 决定开篇状态。',
      '- 开篇承接 Runtime Memory 中的当前位置、压力、未解决悬念或上一章余波，不无故重置人物、地点、关系、资源和伤势。',
      '- 本章至少推进目标、压力、兑现点、关系变化、章末钩子中的三项；每个推进都要落到行动、对话、选择或代价。',
      '- 角色可以变化，但变化必须由本章事件触发；保持性格、能力、秘密、伤势和关系强度的连续性。',
      '- 同类冲突再次出现时必须带来新信息、新代价或新关系变化，避免复读旧章节模式。',
      '- 伏笔要处在可追踪状态：埋设、强化、半兑现、回收或反噬；不要制造无法承接的随机悬念。',
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
正文从当前上下文出发，完成本章目标，并为下一章留下可承接状态。
不得改写已确认设定、角色状态或关系；确需变化时，必须在正文中写出清晰因果和代价。
''';
