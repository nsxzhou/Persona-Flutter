import '../../../core/llm/application/markdown_completion_service.dart';
import '../../../core/tasks/application/prompt_trace_recorder.dart';
import '../../../core/tasks/application/workflow_task_repository.dart';
import '../../projects/domain/project_repository.dart';
import '../../projects/domain/writing_project.dart';
import '../../settings/domain/provider_config.dart';
import '../../settings/domain/provider_config_repository.dart';
import '../domain/novel_workshop.dart';
import '../domain/novel_workshop_repository.dart';
import 'asset_generation_prompts.dart';
import 'outline_detail_parser.dart';
import 'project_prompt_asset_resolver.dart';

class AssetGenerationPipeline {
  const AssetGenerationPipeline({
    required NovelWorkshopRepository repository,
    required ProjectRepository projectRepository,
    required ProviderConfigRepository providerRepository,
    required ProjectPromptAssetResolver promptAssetResolver,
    required MarkdownCompletionService completionService,
    required WorkflowTaskRepository workflowTaskRepository,
    AssetGenerationPromptBuilder promptBuilder =
        const AssetGenerationPromptBuilder(),
    OutlineDetailParser outlineDetailParser = const OutlineDetailParser(),
  }) : _repository = repository,
       _projectRepository = projectRepository,
       _providerRepository = providerRepository,
       _promptAssetResolver = promptAssetResolver,
       _completionService = completionService,
       _workflowTaskRepository = workflowTaskRepository,
       _promptBuilder = promptBuilder,
       _outlineDetailParser = outlineDetailParser;

  final NovelWorkshopRepository _repository;
  final ProjectRepository _projectRepository;
  final ProviderConfigRepository _providerRepository;
  final ProjectPromptAssetResolver _promptAssetResolver;
  final MarkdownCompletionService _completionService;
  final WorkflowTaskRepository _workflowTaskRepository;
  final AssetGenerationPromptBuilder _promptBuilder;
  final OutlineDetailParser _outlineDetailParser;

  Future<AssetGenerationResult> generateAsset({
    required String projectId,
    required AssetGenerationKind kind,
  }) async {
    final run = await _repository.createAssetGenerationRun(
      AssetGenerationRunInput(
        projectId: projectId,
        kind: kind,
        providerId: '',
        modelName: '',
      ),
    );
    var currentRun = run;
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
      final project = await _requireProject(projectId);
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

      final bible = await _repository.ensureProjectBible(projectId);
      final assets = await _promptAssetResolver.resolve(projectId);
      final prompt = _promptBuilder.buildPrompt(
        kind: kind,
        project: project,
        bible: bible,
        assets: assets,
      );

      await transition(
        AssetGenerationStatus.running,
        AssetGenerationStage.generatingDraft,
        message: '阶段: 生成草稿。调用模型生成${_kindLabel(kind)}。',
      );

      final generated = await _completionService.completeMarkdown(
        provider: provider,
        prompt: prompt,
        temperature: kind == AssetGenerationKind.outlineDetailYaml
            ? 0.35
            : 0.55,
        modelName: modelName,
        promptTrace: traceRecorder.config(label: 'generate_${kind.name}'),
      );
      final draft = _cleanDraft(generated);
      if (draft.trim().isEmpty) {
        throw StateError('模型返回了空资产草稿。');
      }
      if (kind == AssetGenerationKind.outlineDetailYaml) {
        _outlineDetailParser.parse(draft);
      }

      await transition(
        AssetGenerationStatus.running,
        AssetGenerationStage.savingDraft,
        message: '阶段: 保存草稿。等待人工审阅确认。',
      );
      await transition(
        AssetGenerationStatus.succeeded,
        null,
        message: '资产草稿生成完成。',
        draftMarkdown: draft,
        completedAt: DateTime.now(),
      );

      return AssetGenerationResult(
        run: currentRun,
        workflowTaskId: currentRun.workflowTaskId,
      );
    } on Object catch (error) {
      await transition(
        AssetGenerationStatus.failed,
        null,
        message: '资产草稿生成失败。',
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
      throw StateError('项目需要默认 Provider 才能生成资产。');
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
    var message = error.toString();
    final apiKey = provider?.apiKey.trim() ?? '';
    if (apiKey.isNotEmpty) {
      message = message.replaceAll(apiKey, '[REDACTED]');
    }
    if (message.length <= 220) {
      return message;
    }
    return '${message.substring(0, 217)}...';
  }

  String _kindLabel(AssetGenerationKind kind) {
    return switch (kind) {
      AssetGenerationKind.worldBuilding => '世界观设定',
      AssetGenerationKind.charactersBlueprint => '角色索引与关系网',
      AssetGenerationKind.outlineMaster => '总纲',
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
