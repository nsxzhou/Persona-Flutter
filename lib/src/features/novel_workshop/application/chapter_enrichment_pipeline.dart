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
import 'project_prompt_asset_resolver.dart';

class ChapterEnrichmentPipeline {
  const ChapterEnrichmentPipeline({
    required NovelWorkshopRepository repository,
    required ProjectRepository projectRepository,
    required ProviderConfigRepository providerRepository,
    required ProjectPromptAssetResolver promptAssetResolver,
    required MarkdownCompletionService completionService,
    required WorkflowTaskRepository workflowTaskRepository,
    required WorkflowTaskCancellationRegistry cancellationRegistry,
  }) : _repository = repository,
       _projectRepository = projectRepository,
       _providerRepository = providerRepository,
       _promptAssetResolver = promptAssetResolver,
       _completionService = completionService,
       _workflowTaskRepository = workflowTaskRepository,
       _cancellationRegistry = cancellationRegistry;

  final NovelWorkshopRepository _repository;
  final ProjectRepository _projectRepository;
  final ProviderConfigRepository _providerRepository;
  final ProjectPromptAssetResolver _promptAssetResolver;
  final MarkdownCompletionService _completionService;
  final WorkflowTaskRepository _workflowTaskRepository;
  final WorkflowTaskCancellationRegistry _cancellationRegistry;

  Future<ChapterEnrichmentResult> enrichChapters({
    required String projectId,
    required List<String> chapterIds,
    required String instruction,
    int expansionRatioPercent = 20,
  }) async {
    final project = await _requireProject(projectId);
    if (project.origin != ProjectOrigin.importedEnrichment) {
      throw StateError('只有导入加料项目可以使用章节加料。');
    }
    final provider = await _requireProvider(project);
    final modelName = _requireModelName(project, provider);
    final batch = await _repository.createChapterEnrichmentBatch(
      ChapterEnrichmentBatchInput(
        projectId: projectId,
        chapterIds: chapterIds,
        instruction: instruction,
        expansionRatioPercent: expansionRatioPercent,
        providerId: provider.id,
        modelName: modelName,
      ),
    );
    return processBatch(batch.id);
  }

  Future<ChapterEnrichmentResult> retryItem(String itemId) async {
    final item = await _repository.findChapterEnrichmentItem(itemId);
    if (item == null) {
      throw StateError('Chapter enrichment item does not exist: $itemId');
    }
    final batch = await _repository.findChapterEnrichmentBatch(item.batchId);
    if (batch == null) {
      throw StateError(
        'Chapter enrichment batch does not exist: ${item.batchId}',
      );
    }
    await _repository.updateChapterEnrichmentItemState(
      id: item.id,
      status: ChapterEnrichmentItemStatus.waiting,
      errorMessage: null,
      originalContentMarkdown: '',
      generatedContentMarkdown: '',
      clearStartedAt: true,
      clearCompletedAt: true,
      clearAppliedAt: true,
    );
    return processBatch(batch.id, onlyItemIds: {item.id});
  }

  Future<ChapterEnrichmentResult> processBatch(
    String batchId, {
    Set<String>? onlyItemIds,
  }) async {
    var batch = await _requireBatch(batchId);
    if (batch.status == ChapterEnrichmentBatchStatus.abandoned) {
      return ChapterEnrichmentResult(
        batch: batch,
        items: await _repository.watchChapterEnrichmentItems(batch.id).first,
        workflowTaskId: batch.workflowTaskId,
      );
    }
    final project = await _requireProject(batch.projectId);
    if (project.origin != ProjectOrigin.importedEnrichment) {
      throw StateError('只有导入加料项目可以使用章节加料。');
    }
    final provider = await _requireProvider(project);
    final modelName = _requireModelName(project, provider);
    final items = await _repository.watchChapterEnrichmentItems(batch.id).first;
    final pendingItems = items
        .where(
          (item) =>
              item.status == ChapterEnrichmentItemStatus.waiting &&
              (onlyItemIds == null || onlyItemIds.contains(item.id)),
        )
        .toList(growable: false);
    if (pendingItems.isEmpty) {
      return ChapterEnrichmentResult(
        batch: batch,
        items: items,
        workflowTaskId: batch.workflowTaskId,
      );
    }

    final log = StringBuffer(batch.logs);
    final cancellationToken = _cancellationRegistry.register(
      batch.workflowTaskId,
    );
    final traceRecorder = PromptTraceRecorder(
      repository: _workflowTaskRepository,
      workflowTaskId: batch.workflowTaskId,
      workflowKind: chapterEnrichmentWorkflowTaskKind,
      runId: batch.id,
      providerId: provider.id,
      providerApiKey: provider.apiKey,
      modelName: modelName,
      stageLabel: () => 'chapter_enrichment',
    );

    Future<void> updateBatch(
      ChapterEnrichmentBatchStatus status, {
      String? message,
      String? errorMessage,
      DateTime? startedAt,
      DateTime? completedAt,
    }) async {
      if (message != null && message.trim().isNotEmpty) {
        _appendLog(log, message);
      }
      batch = await _repository.updateChapterEnrichmentBatchState(
        id: batch.id,
        status: status,
        providerId: provider.id,
        modelName: modelName,
        errorMessage: errorMessage,
        logs: log.toString(),
        startedAt: startedAt,
        completedAt: completedAt,
      );
    }

    try {
      cancellationToken.throwIfCancelled();
      await updateBatch(
        ChapterEnrichmentBatchStatus.running,
        message: '阶段: 开始章节加料。共 ${pendingItems.length} 个待处理章节。',
        startedAt: DateTime.now(),
      );

      for (final item in pendingItems) {
        cancellationToken.throwIfCancelled();
        await _processItem(
          batch: batch,
          item: item,
          project: project,
          provider: provider,
          modelName: modelName,
          traceRecorder: traceRecorder,
          cancellationToken: cancellationToken,
        );
      }

      final latestItems = await _repository
          .watchChapterEnrichmentItems(batch.id)
          .first;
      final failed = latestItems
          .where((item) => item.status == ChapterEnrichmentItemStatus.failed)
          .length;
      final generatedOrApplied = latestItems
          .where(
            (item) =>
                item.status == ChapterEnrichmentItemStatus.generated ||
                item.status == ChapterEnrichmentItemStatus.applied,
          )
          .length;
      final status = failed == 0
          ? ChapterEnrichmentBatchStatus.succeeded
          : generatedOrApplied == 0
          ? ChapterEnrichmentBatchStatus.failed
          : ChapterEnrichmentBatchStatus.partialFailed;
      await updateBatch(
        status,
        message: failed == 0 ? '章节加料完成。' : '章节加料部分失败。',
        errorMessage: failed == 0 ? null : '$failed 个章节加料失败，可单独重试。',
        completedAt: DateTime.now(),
      );

      return ChapterEnrichmentResult(
        batch: batch,
        items: await _repository.watchChapterEnrichmentItems(batch.id).first,
        workflowTaskId: batch.workflowTaskId,
      );
    } on LlmCancellationException {
      await _repository.abandonWorkflowTask(batch.workflowTaskId);
      rethrow;
    } finally {
      _cancellationRegistry.unregister(batch.workflowTaskId, cancellationToken);
      await cancellationToken.dispose();
    }
  }

  Future<void> _processItem({
    required ChapterEnrichmentBatch batch,
    required ChapterEnrichmentItem item,
    required WritingProject project,
    required ProviderConfig provider,
    required String modelName,
    required PromptTraceRecorder traceRecorder,
    required LlmCancellationToken cancellationToken,
  }) async {
    final startedAt = DateTime.now();
    ProviderConfig? resolvedProvider = provider;
    try {
      final chapter = await _repository.findChapter(item.chapterId);
      if (chapter == null || chapter.projectId != batch.projectId) {
        throw StateError('加料章节不存在：${item.chapterId}');
      }
      final original = chapter.contentMarkdown.trim();
      if (original.isEmpty) {
        throw StateError('章节正文为空，无法加料：${chapter.title}');
      }
      await _repository.updateChapterEnrichmentItemState(
        id: item.id,
        status: ChapterEnrichmentItemStatus.running,
        errorMessage: null,
        originalContentMarkdown: original,
        providerId: provider.id,
        modelName: modelName,
        logs: _itemLog('开始处理章节：${chapter.title}'),
        startedAt: startedAt,
      );
      cancellationToken.throwIfCancelled();

      final assets = await _promptAssetResolver.resolve(project.id);
      final prompt = _buildPrompt(
        project: project,
        batch: batch,
        chapter: chapter,
        voiceProfileMarkdown: assets.voiceProfileMarkdown,
        originalContent: original,
      );
      final generated = await _completionService.completeMarkdown(
        provider: provider,
        prompt: prompt,
        temperature: 0.7,
        modelName: modelName,
        promptTrace: traceRecorder.config(
          label: 'enrich_chapter_${chapter.chapterIndex}',
        ),
        cancellationToken: cancellationToken,
      );
      cancellationToken.throwIfCancelled();
      final content = _cleanMarkdownDraft(generated);
      if (content.trim().isEmpty) {
        throw StateError('模型返回了空加料结果。');
      }
      await _repository.updateChapterEnrichmentItemState(
        id: item.id,
        status: ChapterEnrichmentItemStatus.generated,
        errorMessage: null,
        originalContentMarkdown: original,
        generatedContentMarkdown: content,
        providerId: provider.id,
        modelName: modelName,
        logs: _itemLog('加料预览已生成。'),
        completedAt: DateTime.now(),
      );
    } on LlmCancellationException {
      rethrow;
    } on Object catch (error) {
      await _repository.updateChapterEnrichmentItemState(
        id: item.id,
        status: ChapterEnrichmentItemStatus.failed,
        errorMessage: _sanitizeError(error, resolvedProvider),
        providerId: provider.id,
        modelName: modelName,
        logs: _itemLog('加料失败。'),
        startedAt: startedAt,
        completedAt: DateTime.now(),
      );
    }
  }

  String _buildPrompt({
    required WritingProject project,
    required ChapterEnrichmentBatch batch,
    required ProjectChapter chapter,
    required String voiceProfileMarkdown,
    required String originalContent,
  }) {
    return '''
你是长篇小说章节加料编辑。你的任务是只改写用户选中的单个章节，输出完整的新章节正文。

## 输出契约
- 只输出完整新章节正文。
- 不要输出 JSON、代码围栏、解释、修改说明、diff 或章节标题。
- 不要续写下一章，不要改写其他章节，不要引入选中章节之外的后续剧情。
- 保留本章核心事实、人物关系和因果顺序；可以扩写细节、动作、心理、环境、对话和节奏。
- 目标扩写比例：约 ${batch.expansionRatioPercent}%。
- 用户加料要求：${batch.instruction.trim()}。

## 项目参数
- 项目：${project.title.trim()}
- 语言：${project.language.trim()}
- 叙事视角：${project.narrativePerspective.trim()}
- 当前章节：第 ${chapter.chapterIndex} 章 · ${chapter.title.trim()}

## Voice Profile
${voiceProfileMarkdown.trim().isEmpty ? '未绑定 Voice Profile。保持原文语言风格，并优先服从用户加料要求。' : voiceProfileMarkdown.trim()}

## 原章节正文
$originalContent
''';
  }

  Future<ChapterEnrichmentBatch> _requireBatch(String batchId) async {
    final batch = await _repository.findChapterEnrichmentBatch(batchId);
    if (batch == null) {
      throw StateError('Chapter enrichment batch does not exist: $batchId');
    }
    return batch;
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
      throw StateError('项目需要默认 Provider 才能加料。');
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
      throw StateError('项目需要默认模型才能加料。');
    }
    if (!provider.modelNames.contains(modelName) &&
        provider.defaultModel != modelName) {
      throw StateError('项目默认模型不属于所选 Provider。');
    }
    return modelName;
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

  String _itemLog(String message) {
    return '[${DateTime.now().toIso8601String()}] $message';
  }

  void _appendLog(StringBuffer buffer, String message) {
    final timestamp = DateTime.now().toIso8601String();
    if (buffer.isNotEmpty && !buffer.toString().endsWith('\n')) {
      buffer.writeln();
    }
    buffer.writeln('[$timestamp] $message');
  }
}
