import '../../../core/llm/application/markdown_completion_service.dart';
import '../../../core/llm/domain/llm_cancellation.dart';
import '../../../core/llm/domain/llm_error_utils.dart';
import '../../../core/tasks/application/prompt_trace_recorder.dart';
import '../../../core/tasks/application/workflow_task_cancellation_registry.dart';
import '../../../core/tasks/application/workflow_task_repository.dart';
import '../../projects/domain/project_repository.dart';
import '../../projects/domain/writing_project.dart';
import '../../settings/domain/provider_config.dart';
import '../../settings/domain/provider_config_repository.dart';
import '../domain/novel_workshop.dart';
import '../domain/novel_workshop_repository.dart';
import 'asset_generation_prompts.dart';
import 'character_graph_parser.dart';
import 'outline_detail_parser.dart';
import 'project_prompt_asset_resolver.dart';
import 'volume_blueprint_parser.dart';

class AssetGenerationPipeline {
  const AssetGenerationPipeline({
    required NovelWorkshopRepository repository,
    required ProjectRepository projectRepository,
    required ProviderConfigRepository providerRepository,
    required ProjectPromptAssetResolver promptAssetResolver,
    required MarkdownCompletionService completionService,
    required WorkflowTaskRepository workflowTaskRepository,
    required WorkflowTaskCancellationRegistry cancellationRegistry,
    AssetGenerationPromptBuilder promptBuilder =
        const AssetGenerationPromptBuilder(),
    OutlineDetailParser outlineDetailParser = const OutlineDetailParser(),
    CharacterGraphParser characterGraphParser = const CharacterGraphParser(),
    VolumeBlueprintParser volumeBlueprintParser = const VolumeBlueprintParser(),
  }) : _repository = repository,
       _projectRepository = projectRepository,
       _providerRepository = providerRepository,
       _promptAssetResolver = promptAssetResolver,
       _completionService = completionService,
       _workflowTaskRepository = workflowTaskRepository,
       _cancellationRegistry = cancellationRegistry,
       _promptBuilder = promptBuilder,
       _outlineDetailParser = outlineDetailParser,
       _characterGraphParser = characterGraphParser,
       _volumeBlueprintParser = volumeBlueprintParser;

  final NovelWorkshopRepository _repository;
  final ProjectRepository _projectRepository;
  final ProviderConfigRepository _providerRepository;
  final ProjectPromptAssetResolver _promptAssetResolver;
  final MarkdownCompletionService _completionService;
  final WorkflowTaskRepository _workflowTaskRepository;
  final WorkflowTaskCancellationRegistry _cancellationRegistry;
  final AssetGenerationPromptBuilder _promptBuilder;
  final OutlineDetailParser _outlineDetailParser;
  final CharacterGraphParser _characterGraphParser;
  final VolumeBlueprintParser _volumeBlueprintParser;

  Future<AssetGenerationResult> generateAsset({
    required String projectId,
    required AssetGenerationKind kind,
    String userFeedback = '',
    String? targetVolumeId,
  }) async {
    final normalizedVolumeId = targetVolumeId?.trim();
    final scopedKind = normalizedVolumeId == null || normalizedVolumeId.isEmpty
        ? kind
        : AssetGenerationKind.outlineDetailYaml;
    if (await _repository.hasRunningAssetGeneration(
      projectId: projectId,
      kind: scopedKind,
      targetVolumeId: normalizedVolumeId,
    )) {
      throw StateError(_runningAssetMessage(scopedKind, normalizedVolumeId));
    }
    final run = normalizedVolumeId == null || normalizedVolumeId.isEmpty
        ? await _repository.createAssetGenerationRun(
            AssetGenerationRunInput(
              projectId: projectId,
              kind: kind,
              providerId: '',
              modelName: '',
            ),
          )
        : await _repository.createVolumeDetailGenerationRun(
            projectId: projectId,
            volumeId: normalizedVolumeId,
          );
    var currentRun = run;
    final cancellationToken = _cancellationRegistry.register(
      run.workflowTaskId,
    );
    var currentStage = currentRun.stage;
    final log = StringBuffer(currentRun.logs);
    ProviderConfig? resolvedProvider;

    Future<void> transition(
      AssetGenerationStatus status,
      AssetGenerationStage? stage, {
      String? message,
      String? providerId,
      String? modelName,
      String? errorMessage,
      String? draftMarkdown,
      DateTime? startedAt,
      DateTime? completedAt,
    }) async {
      currentStage = stage;
      if (message != null && message.trim().isNotEmpty) {
        _appendLog(log, message);
      }
      currentRun = await _repository.updateAssetGenerationRunState(
        id: currentRun.id,
        status: status,
        stage: stage,
        providerId: providerId,
        modelName: modelName,
        errorMessage: errorMessage,
        logs: log.toString(),
        draftMarkdown: draftMarkdown,
        startedAt: startedAt,
        completedAt: completedAt,
      );
    }

    try {
      cancellationToken.throwIfCancelled();
      final project = await _requireProject(projectId);
      final targetVolume = currentRun.targetVolumeId == null
          ? null
          : await _requireVolume(projectId, currentRun.targetVolumeId!);
      final provider = await _requireProvider(project);
      final modelName = _requireModelName(project, provider);
      resolvedProvider = provider;
      final traceRecorder = PromptTraceRecorder(
        repository: _workflowTaskRepository,
        workflowTaskId: currentRun.workflowTaskId,
        workflowKind: assetGenerationWorkflowTaskKind,
        runId: currentRun.id,
        providerId: provider.id,
        providerApiKey: provider.apiKey,
        modelName: modelName,
        stageLabel: () => currentStage?.name,
      );

      await transition(
        AssetGenerationStatus.running,
        AssetGenerationStage.preparingContext,
        message: '阶段: 准备上下文。读取项目设定与 Prompt 资产。',
        providerId: provider.id,
        modelName: modelName,
        startedAt: DateTime.now(),
      );
      cancellationToken.throwIfCancelled();

      final bible = await _repository.ensureProjectBible(projectId);
      final assets = await _promptAssetResolver.resolve(projectId);
      var prompt = _promptBuilder.buildPrompt(
        kind: kind,
        project: project,
        bible: bible,
        assets: assets,
        targetVolume: targetVolume,
      );
      if (userFeedback.trim().isNotEmpty) {
        prompt = '$prompt\n\n## 用户额外要求\n${userFeedback.trim()}\n';
      }

      await transition(
        AssetGenerationStatus.running,
        AssetGenerationStage.generatingDraft,
        message: '阶段: 生成草稿。调用模型生成${_kindLabel(kind)}。',
      );
      cancellationToken.throwIfCancelled();

      final generated = await _completionService.completeMarkdown(
        provider: provider,
        prompt: prompt,
        temperature:
            kind == AssetGenerationKind.outlineDetailYaml ||
                kind == AssetGenerationKind.volumeBlueprintYaml
            ? 0.35
            : 0.55,
        modelName: modelName,
        promptTrace: traceRecorder.config(label: 'generate_${kind.name}'),
        cancellationToken: cancellationToken,
      );
      cancellationToken.throwIfCancelled();
      var draft = _cleanDraft(generated);
      if (draft.trim().isEmpty) {
        throw StateError('模型返回了空资产草稿。');
      }

      // Validate; if it fails, attempt one automatic repair.
      var validationError = _tryValidateDraft(kind, draft);
      String? validationWarning;
      if (validationError != null) {
        await transition(
          AssetGenerationStatus.running,
          AssetGenerationStage.repairingDraft,
          message: '阶段: 自动修复。校验发现问题，正在调用模型修复。',
        );
        cancellationToken.throwIfCancelled();
        final repairPrompt = _promptBuilder.buildRepairPrompt(
          kind: kind,
          project: project,
          bible: bible,
          assets: assets,
          previousDraft: draft,
          validationErrors: validationError,
          targetVolume: targetVolume,
        );
        final repairGenerated = await _completionService.completeMarkdown(
          provider: provider,
          prompt: repairPrompt,
          temperature:
              kind == AssetGenerationKind.outlineDetailYaml ||
                  kind == AssetGenerationKind.volumeBlueprintYaml
              ? 0.35
              : 0.55,
          modelName: modelName,
          promptTrace: traceRecorder.config(
            label: 'repair_${kind.name}',
          ),
          cancellationToken: cancellationToken,
        );
        cancellationToken.throwIfCancelled();
        final repairedDraft = _cleanDraft(repairGenerated);
        if (repairedDraft.trim().isNotEmpty) {
          final repairError = _tryValidateDraft(kind, repairedDraft);
          if (repairError == null) {
            // Repair succeeded.
            draft = repairedDraft;
          } else {
            // Repair failed — use repaired draft anyway but attach warnings.
            draft = repairedDraft;
            validationWarning = repairError;
            await transition(
              AssetGenerationStatus.running,
              null,
              message: '自动修复未能完全解决校验问题，请人工审阅。',
              errorMessage: repairError,
            );
          }
        }
        // If repaired draft was empty, keep the original draft.
      }

      await transition(
        AssetGenerationStatus.running,
        AssetGenerationStage.savingDraft,
        message: '阶段: 保存草稿。等待人工审阅确认。',
      );
      cancellationToken.throwIfCancelled();
      await transition(
        AssetGenerationStatus.succeeded,
        null,
        message: '资产草稿生成完成。',
        errorMessage: validationWarning,
        draftMarkdown: draft,
        completedAt: DateTime.now(),
      );

      return AssetGenerationResult(
        run: currentRun,
        workflowTaskId: currentRun.workflowTaskId,
      );
    } on LlmCancellationException {
      await _repository.abandonWorkflowTask(currentRun.workflowTaskId);
      rethrow;
    } on Object catch (error) {
      await transition(
        AssetGenerationStatus.failed,
        null,
        message: '资产草稿生成失败。',
        errorMessage: _sanitizeError(error, resolvedProvider),
        completedAt: DateTime.now(),
      );
      rethrow;
    } finally {
      _cancellationRegistry.unregister(
        currentRun.workflowTaskId,
        cancellationToken,
      );
      await cancellationToken.dispose();
    }
  }

  /// Creates a new [AssetGenerationRun] that regenerates a draft based on the
  /// previous draft, validation errors and optional user feedback.
  Future<AssetGenerationResult> regenerateAssetWithFeedback({
    required String projectId,
    required AssetGenerationKind kind,
    required String previousRunId,
    required String previousDraft,
    required String validationErrors,
    String userFeedback = '',
    String? targetVolumeId,
  }) async {
    final normalizedVolumeId = targetVolumeId?.trim();
    final scopedKind =
        normalizedVolumeId == null || normalizedVolumeId.isEmpty
            ? kind
            : AssetGenerationKind.outlineDetailYaml;
    if (await _repository.hasRunningAssetGeneration(
      projectId: projectId,
      kind: scopedKind,
      targetVolumeId: normalizedVolumeId,
    )) {
      throw StateError(_runningAssetMessage(scopedKind, normalizedVolumeId));
    }
    final run = await _repository.createAssetGenerationRun(
      AssetGenerationRunInput(
        projectId: projectId,
        kind: kind,
        providerId: '',
        modelName: '',
        previousRunId: previousRunId,
        userFeedback: userFeedback.trim().isEmpty ? null : userFeedback.trim(),
      ),
    );
    var currentRun = run;
    final cancellationToken = _cancellationRegistry.register(
      run.workflowTaskId,
    );
    var currentStage = currentRun.stage;
    final log = StringBuffer(currentRun.logs);
    ProviderConfig? resolvedProvider;

    Future<void> transition(
      AssetGenerationStatus status,
      AssetGenerationStage? stage, {
      String? message,
      String? providerId,
      String? modelName,
      String? errorMessage,
      String? draftMarkdown,
      DateTime? startedAt,
      DateTime? completedAt,
    }) async {
      currentStage = stage;
      if (message != null && message.trim().isNotEmpty) {
        _appendLog(log, message);
      }
      currentRun = await _repository.updateAssetGenerationRunState(
        id: currentRun.id,
        status: status,
        stage: stage,
        providerId: providerId,
        modelName: modelName,
        errorMessage: errorMessage,
        logs: log.toString(),
        draftMarkdown: draftMarkdown,
        startedAt: startedAt,
        completedAt: completedAt,
      );
    }

    try {
      cancellationToken.throwIfCancelled();
      final project = await _requireProject(projectId);
      final targetVolume = currentRun.targetVolumeId == null
          ? null
          : await _requireVolume(projectId, currentRun.targetVolumeId!);
      final provider = await _requireProvider(project);
      final modelName = _requireModelName(project, provider);
      resolvedProvider = provider;
      final traceRecorder = PromptTraceRecorder(
        repository: _workflowTaskRepository,
        workflowTaskId: currentRun.workflowTaskId,
        workflowKind: assetGenerationWorkflowTaskKind,
        runId: currentRun.id,
        providerId: provider.id,
        providerApiKey: provider.apiKey,
        modelName: modelName,
        stageLabel: () => currentStage?.name,
      );

      await transition(
        AssetGenerationStatus.running,
        AssetGenerationStage.preparingContext,
        message: '阶段: 准备上下文。构建修复 Prompt。',
        providerId: provider.id,
        modelName: modelName,
        startedAt: DateTime.now(),
      );
      cancellationToken.throwIfCancelled();

      final bible = await _repository.ensureProjectBible(projectId);
      final assets = await _promptAssetResolver.resolve(projectId);
      final prompt = _promptBuilder.buildRepairPrompt(
        kind: kind,
        project: project,
        bible: bible,
        assets: assets,
        previousDraft: previousDraft,
        validationErrors: validationErrors,
        userFeedback: userFeedback,
        targetVolume: targetVolume,
      );

      await transition(
        AssetGenerationStatus.running,
        AssetGenerationStage.generatingDraft,
        message: '阶段: 生成草稿。调用模型修复${_kindLabel(kind)}。',
      );
      cancellationToken.throwIfCancelled();

      final generated = await _completionService.completeMarkdown(
        provider: provider,
        prompt: prompt,
        temperature:
            kind == AssetGenerationKind.outlineDetailYaml ||
                    kind == AssetGenerationKind.volumeBlueprintYaml
                ? 0.35
                : 0.55,
        modelName: modelName,
        promptTrace: traceRecorder.config(
          label: 'regenerate_${kind.name}',
        ),
        cancellationToken: cancellationToken,
      );
      cancellationToken.throwIfCancelled();
      var draft = _cleanDraft(generated);
      if (draft.trim().isEmpty) {
        throw StateError('模型返回了空资产草稿。');
      }

      // Validate; if it fails, attempt one automatic repair.
      var validationError = _tryValidateDraft(kind, draft);
      String? validationWarning;
      if (validationError != null) {
        await transition(
          AssetGenerationStatus.running,
          AssetGenerationStage.repairingDraft,
          message: '阶段: 自动修复。校验发现问题，正在调用模型修复。',
        );
        cancellationToken.throwIfCancelled();
        final repairPrompt = _promptBuilder.buildRepairPrompt(
          kind: kind,
          project: project,
          bible: bible,
          assets: assets,
          previousDraft: draft,
          validationErrors: validationError,
          targetVolume: targetVolume,
        );
        final repairGenerated = await _completionService.completeMarkdown(
          provider: provider,
          prompt: repairPrompt,
          temperature:
              kind == AssetGenerationKind.outlineDetailYaml ||
                      kind == AssetGenerationKind.volumeBlueprintYaml
                  ? 0.35
                  : 0.55,
          modelName: modelName,
          promptTrace: traceRecorder.config(
            label: 'repair_${kind.name}',
          ),
          cancellationToken: cancellationToken,
        );
        cancellationToken.throwIfCancelled();
        final repairedDraft = _cleanDraft(repairGenerated);
        if (repairedDraft.trim().isNotEmpty) {
          final repairError = _tryValidateDraft(kind, repairedDraft);
          if (repairError == null) {
            draft = repairedDraft;
          } else {
            draft = repairedDraft;
            validationWarning = repairError;
          }
        }
      }

      await transition(
        AssetGenerationStatus.running,
        AssetGenerationStage.savingDraft,
        message: '阶段: 保存草稿。等待人工审阅确认。',
      );
      cancellationToken.throwIfCancelled();
      await transition(
        AssetGenerationStatus.succeeded,
        null,
        message: '资产草稿生成完成。',
        errorMessage: validationWarning,
        draftMarkdown: draft,
        completedAt: DateTime.now(),
      );

      return AssetGenerationResult(
        run: currentRun,
        workflowTaskId: currentRun.workflowTaskId,
      );
    } on LlmCancellationException {
      await _repository.abandonWorkflowTask(currentRun.workflowTaskId);
      rethrow;
    } on Object catch (error) {
      await transition(
        AssetGenerationStatus.failed,
        null,
        message: '资产草稿生成失败。',
        errorMessage: _sanitizeError(error, resolvedProvider),
        completedAt: DateTime.now(),
      );
      rethrow;
    } finally {
      _cancellationRegistry.unregister(
        currentRun.workflowTaskId,
        cancellationToken,
      );
      await cancellationToken.dispose();
    }
  }

  String _runningAssetMessage(
    AssetGenerationKind kind,
    String? targetVolumeId,
  ) {
    if (targetVolumeId != null && targetVolumeId.isNotEmpty) {
      return '该分卷已有运行中的章节细纲生成任务。';
    }
    return '项目已有运行中的${_kindLabel(kind)}生成任务。';
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
      throw StateError('项目需要默认 Provider 才能生成资产。');
    }
    final provider = await _providerRepository.findProvider(providerId);
    if (provider == null) {
      throw StateError('项目默认 Provider 不存在。');
    }
    return provider;
  }

  Future<ChapterVolume> _requireVolume(
    String projectId,
    String volumeId,
  ) async {
    final volumes = await _repository.watchChapterVolumesOnce(projectId);
    for (final volume in volumes) {
      if (volume.id == volumeId) {
        return volume;
      }
    }
    throw StateError('目标分卷不存在。');
  }

  /// Validates a draft and returns the error message if invalid, or null if
  /// the draft passes all checks.
  String? _tryValidateDraft(AssetGenerationKind kind, String draft) {
    try {
      switch (kind) {
        case AssetGenerationKind.worldBuilding:
        case AssetGenerationKind.outlineMaster:
          return null;
        case AssetGenerationKind.charactersBlueprint:
          _characterGraphParser.parse(draft);
        case AssetGenerationKind.volumeBlueprintYaml:
          _volumeBlueprintParser.parse(draft);
        case AssetGenerationKind.outlineDetailYaml:
          _outlineDetailParser.parse(draft);
      }
      return null;
    } on Object catch (e) {
      return e.toString();
    }
  }

  String _requireModelName(WritingProject project, ProviderConfig provider) {
    final modelName = project.defaultModelName?.trim();
    if (modelName == null || modelName.isEmpty) {
      throw StateError('项目需要默认模型才能生成资产。');
    }
    if (!provider.modelNames.contains(modelName) &&
        provider.defaultModel != modelName) {
      throw StateError('项目默认模型不属于所选 Provider。');
    }
    return modelName;
  }

  String _cleanDraft(String markdown) {
    var text = markdown.trim();
    final fencePattern = RegExp(
      r'^```(?:markdown|md|yaml|yml)?\s*\n([\s\S]*?)\n```\s*$',
      caseSensitive: false,
    );
    final match = fencePattern.firstMatch(text);
    if (match != null) {
      text = match.group(1)!.trim();
    }
    return text;
  }

  String _sanitizeError(Object error, ProviderConfig? provider) {
    return sanitizeLlmError(error, provider?.apiKey ?? '');
  }

  String _kindLabel(AssetGenerationKind kind) {
    return switch (kind) {
      AssetGenerationKind.worldBuilding => '世界观设定',
      AssetGenerationKind.charactersBlueprint => '角色索引与关系网',
      AssetGenerationKind.outlineMaster => '总纲',
      AssetGenerationKind.volumeBlueprintYaml => '分卷规划',
      AssetGenerationKind.outlineDetailYaml => '分卷与章节细纲',
    };
  }

  void _appendLog(StringBuffer buffer, String message) {
    final timestamp = DateTime.now().toIso8601String();
    if (buffer.isNotEmpty && !buffer.toString().endsWith('\n')) {
      buffer.write('\n');
    }
    buffer.writeln('[$timestamp] $message');
  }
}
