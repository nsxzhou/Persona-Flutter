import '../../../core/llm/application/markdown_completion_service.dart';
import '../../../core/llm/domain/llm_cancellation.dart';
import '../../../core/llm/domain/llm_error_utils.dart';
import '../../../core/tasks/application/prompt_trace_recorder.dart';
import '../../../core/tasks/application/workflow_task_cancellation_registry.dart';
import '../../../core/tasks/application/workflow_task_repository.dart';
import 'package:yaml/yaml.dart';
import '../../projects/domain/project_repository.dart';
import '../../projects/domain/writing_project.dart';
import '../../settings/domain/provider_config.dart';
import '../../settings/domain/provider_config_repository.dart';
import '../domain/novel_workshop.dart';
import '../domain/novel_workshop_repository.dart';
import '../domain/writing_context.dart';
import 'memory_patch_document.dart';
import 'memory_patch_yaml.dart';
import 'project_prompt_asset_resolver.dart';
import 'writing_context_assembler.dart';
import 'writing_context_retriever.dart';

class ChapterGenerationPipeline {
  const ChapterGenerationPipeline({
    required NovelWorkshopRepository repository,
    required ProjectRepository projectRepository,
    required ProviderConfigRepository providerRepository,
    required ProjectPromptAssetResolver promptAssetResolver,
    required WritingContextAssembler contextAssembler,
    required WritingContextRetriever contextRetriever,
    required MarkdownCompletionService completionService,
    required WorkflowTaskRepository workflowTaskRepository,
    required WorkflowTaskCancellationRegistry cancellationRegistry,
  }) : _repository = repository,
       _projectRepository = projectRepository,
       _providerRepository = providerRepository,
       _promptAssetResolver = promptAssetResolver,
       _contextAssembler = contextAssembler,
       _contextRetriever = contextRetriever,
       _completionService = completionService,
       _workflowTaskRepository = workflowTaskRepository,
       _cancellationRegistry = cancellationRegistry;

  final NovelWorkshopRepository _repository;
  final ProjectRepository _projectRepository;
  final ProviderConfigRepository _providerRepository;
  final ProjectPromptAssetResolver _promptAssetResolver;
  final WritingContextAssembler _contextAssembler;
  final WritingContextRetriever _contextRetriever;
  final MarkdownCompletionService _completionService;
  final WorkflowTaskRepository _workflowTaskRepository;
  final WorkflowTaskCancellationRegistry _cancellationRegistry;

  static const int _promptArchiveDigestThreshold = 45000;
  static const int _maxBatchDraftAttempts = 2;
  static const int _maxBatchPatchAttempts = 2;

  Future<ChapterGenerationContextPreview> previewGenerationContext({
    required String projectId,
    required String chapterPlanId,
  }) async {
    final context = await _buildGenerationContext(
      projectId: projectId,
      chapterPlanId: chapterPlanId,
    );
    return ChapterGenerationContextPreview(
      promptMarkdown: context.bundle.promptMarkdown,
      warnings: context.warnings,
      projectBibleIncluded: context.retrieved.selectedAssetBlocks.any(
        (asset) => asset.id.startsWith('project_bible.'),
      ),
      chapterObjectiveCardIncluded:
          !context.baseSections.chapterObjectiveCard.isEmpty,
      runtimeMemoryIncluded: context.retrieved.selectedAssetBlocks.any(
        (asset) => asset.id.startsWith('runtime_memory.'),
      ),
      characterCount: context.characters.length,
      relationshipCount: context.relationships.length,
      voiceProfileIncluded: context.retrieved.selectedAssetBlocks.any(
        (asset) => asset.id == 'voice_profile',
      ),
      storyEngineIncluded: context.retrieved.selectedAssetBlocks.any(
        (asset) => asset.id == 'story_engine',
      ),
      selectedChapterExcerptCount:
          context.retrieved.selectedChapterExcerpts.length,
      selectedAssetBlockCount: context.retrieved.selectedAssetBlocks.length,
      selectionReportMarkdown: context.retrieved.selectionReportMarkdown,
    );
  }

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
    final cancellationToken = _cancellationRegistry.register(
      run.workflowTaskId,
    );
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
      String? draftMarkdown,
      ContinuityVerdict? continuityVerdict,
      String? continuityReportMarkdown,
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
        draftMarkdown: draftMarkdown,
        continuityVerdict: continuityVerdict,
        continuityReportMarkdown: continuityReportMarkdown,
        startedAt: startedAt,
        completedAt: completedAt,
      );
    }

    try {
      cancellationToken.throwIfCancelled();
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
      cancellationToken.throwIfCancelled();

      var context = await _buildGenerationContext(
        projectId: projectId,
        chapterPlanId: chapterPlanId,
        project: project,
        plan: plan,
        provider: provider,
        modelName: modelName,
        traceRecorder: traceRecorder,
        cancellationToken: cancellationToken,
      );
      final contextWarnings = [...context.warnings];
      var bundle = context.bundle;
      var baseSections = context.baseSections;
      final originalRuntimeMemory = context.originalRuntimeMemory;
      if (_shouldDigestChapterArchive(bundle.promptMarkdown, baseSections)) {
        final digestedMemory = await _temporaryArchiveDigestMemory(
          provider: provider,
          modelName: modelName,
          traceRecorder: traceRecorder,
          project: project,
          plan: plan,
          memory: originalRuntimeMemory,
          cancellationToken: cancellationToken,
        );
        baseSections = _sectionsWithRuntimeReferenceDigest(
          baseSections,
          digestedMemory,
        );
        bundle = _contextAssembler.assemble(baseSections);
        contextWarnings.add('章节归档过长，本次生成已使用临时 Chapter Archive Digest。');
      }

      await transition(
        ChapterGenerationStatus.running,
        ChapterGenerationStage.generatingDraft,
        message: '阶段: 生成正文。调用模型生成纯 Markdown 章节正文。',
        contextWarningsMarkdown: _warningsMarkdown(contextWarnings),
      );
      cancellationToken.throwIfCancelled();

      final generated = await _completionService.completeMarkdown(
        provider: provider,
        prompt: bundle.promptMarkdown,
        temperature: 0.75,
        modelName: modelName,
        promptTrace: traceRecorder.config(label: 'generate_chapter_draft'),
        cancellationToken: cancellationToken,
      );
      cancellationToken.throwIfCancelled();
      final content = _cleanMarkdownDraft(generated);
      if (content.trim().isEmpty) {
        throw StateError('模型返回了空章节正文。');
      }

      await transition(
        ChapterGenerationStatus.running,
        ChapterGenerationStage.auditContinuity,
        message: '阶段: 连续性审计。检查人物状态、世界规则、伏笔和章节目标。',
        draftMarkdown: content,
      );
      final audit = await _auditContinuity(
        provider: provider,
        modelName: modelName,
        traceRecorder: traceRecorder,
        project: project,
        plan: plan,
        sections: baseSections,
        content: content,
        cancellationToken: cancellationToken,
      );
      await transition(
        audit.verdict == ContinuityVerdict.fail
            ? ChapterGenerationStatus.failed
            : ChapterGenerationStatus.running,
        audit.verdict == ContinuityVerdict.fail
            ? null
            : ChapterGenerationStage.auditContinuity,
        message: _auditLogMessage(audit.verdict),
        draftMarkdown: content,
        continuityVerdict: audit.verdict,
        continuityReportMarkdown: audit.reportMarkdown,
        errorMessage: audit.verdict == ContinuityVerdict.fail
            ? '连续性审计未通过，请查看审计报告后重新生成。'
            : null,
        completedAt: audit.verdict == ContinuityVerdict.fail
            ? DateTime.now()
            : null,
      );
      cancellationToken.throwIfCancelled();
      if (audit.verdict == ContinuityVerdict.fail) {
        throw StateError('连续性审计未通过，请查看审计报告后重新生成。');
      }

      await transition(
        ChapterGenerationStatus.running,
        ChapterGenerationStage.savingChapter,
        message: audit.verdict == ContinuityVerdict.warning
            ? '阶段: 保存正文。审计为 warning，写入章节并暂停记忆同步。'
            : '阶段: 保存正文。写入当前章节正文。',
      );
      cancellationToken.throwIfCancelled();
      final chapter = await _repository.saveChapter(
        id: existingChapter?.id,
        input: ProjectChapterInput(
          projectId: projectId,
          chapterPlanId: plan.id,
          chapterIndex: plan.chapterIndex,
          title: _chapterTitle(plan),
          contentMarkdown: content,
          continuityVerdict: audit.verdict,
          continuityReportMarkdown: audit.reportMarkdown,
        ),
      );

      if (audit.verdict == ContinuityVerdict.warning) {
        await transition(
          ChapterGenerationStatus.succeeded,
          null,
          chapterId: chapter.id,
          message: '章节生成完成，等待用户审阅后继续同步记忆。',
          contextWarningsMarkdown: _warningsMarkdown(contextWarnings),
          completedAt: DateTime.now(),
        );
        return ChapterGenerationResult(
          run: currentRun,
          chapter: chapter,
          contextWarnings: List.unmodifiable(contextWarnings),
          workflowTaskId: currentRun.workflowTaskId,
        );
      }

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
        currentMemory: originalRuntimeMemory,
        characters: context.characters,
        relationships: context.relationships,
        cancellationToken: cancellationToken,
      );
      cancellationToken.throwIfCancelled();

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
    } on LlmCancellationException {
      await _repository.abandonWorkflowTask(currentRun.workflowTaskId);
      rethrow;
    } on Object catch (error) {
      if (currentRun.status != ChapterGenerationStatus.failed) {
        await transition(
          ChapterGenerationStatus.failed,
          null,
          message: '章节生成失败。',
          errorMessage: _sanitizeError(error, resolvedProvider),
          completedAt: DateTime.now(),
        );
      }
      rethrow;
    } finally {
      _cancellationRegistry.unregister(
        currentRun.workflowTaskId,
        cancellationToken,
      );
      await cancellationToken.dispose();
    }
  }

  Future<ChapterGenerationBatchResult> startChapterGenerationBatch({
    required String projectId,
    required List<String> chapterPlanIds,
  }) async {
    final project = await _requireProject(projectId);
    if (project.origin == ProjectOrigin.importedEnrichment) {
      throw StateError('导入加料项目不支持批量草稿。');
    }
    final provider = await _requireProvider(project);
    final modelName = _requireModelName(project, provider);
    await _validateBatchStart(
      projectId: projectId,
      chapterPlanIds: chapterPlanIds,
    );
    final batch = await _repository.createChapterGenerationBatch(
      ChapterGenerationBatchInput(
        projectId: projectId,
        chapterPlanIds: chapterPlanIds,
        providerId: provider.id,
        modelName: modelName,
      ),
    );
    return processChapterGenerationBatch(batch.id);
  }

  Future<ChapterGenerationBatchResult> processChapterGenerationBatch(
    String batchId,
  ) async {
    var batch = await _requireGenerationBatch(batchId);
    if (batch.status == ChapterGenerationBatchStatus.failed ||
        batch.status == ChapterGenerationBatchStatus.succeeded ||
        batch.status == ChapterGenerationBatchStatus.abandoned) {
      return ChapterGenerationBatchResult(
        batch: batch,
        items: await _repository
            .watchChapterGenerationBatchItems(batch.id)
            .first,
        workflowTaskId: batch.workflowTaskId,
      );
    }
    final project = await _requireProject(batch.projectId);
    if (project.origin == ProjectOrigin.importedEnrichment) {
      throw StateError('导入加料项目不支持批量草稿。');
    }
    final provider = await _requireProvider(project);
    final modelName = _requireModelName(project, provider);
    final cancellationToken = _cancellationRegistry.register(
      batch.workflowTaskId,
    );
    final log = StringBuffer(batch.logs);

    Future<void> updateBatch(
      ChapterGenerationBatchStatus status, {
      String? message,
      String? errorMessage,
      DateTime? startedAt,
      DateTime? completedAt,
    }) async {
      if (message != null && message.trim().isNotEmpty) {
        _appendLog(log, message);
      }
      batch = await _repository.updateChapterGenerationBatchState(
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
        ChapterGenerationBatchStatus.running,
        message: '阶段: 开始批量草稿。按章节顺序执行双门禁。',
        startedAt: batch.startedAt ?? DateTime.now(),
      );

      var items = await _repository
          .watchChapterGenerationBatchItems(batch.id)
          .first;
      for (final initialItem in items) {
        cancellationToken.throwIfCancelled();
        final latestBatch = await _requireGenerationBatch(batch.id);
        if (latestBatch.status == ChapterGenerationBatchStatus.failed ||
            latestBatch.status == ChapterGenerationBatchStatus.abandoned) {
          return ChapterGenerationBatchResult(
            batch: latestBatch,
            items: await _repository
                .watchChapterGenerationBatchItems(batch.id)
                .first,
            workflowTaskId: latestBatch.workflowTaskId,
          );
        }
        batch = latestBatch;
        if (initialItem.status == ChapterGenerationBatchItemStatus.synced) {
          continue;
        }
        final item = await _processBatchItem(
          batch: batch,
          item: initialItem,
          project: project,
          provider: provider,
          modelName: modelName,
          cancellationToken: cancellationToken,
        );
        if (item.status == ChapterGenerationBatchItemStatus.failed) {
          await updateBatch(
            ChapterGenerationBatchStatus.failed,
            message: '批量草稿停止：章节检查点未通过。',
            errorMessage: item.errorMessage ?? '章节检查点未通过。',
            completedAt: DateTime.now(),
          );
          items = await _repository
              .watchChapterGenerationBatchItems(batch.id)
              .first;
          return ChapterGenerationBatchResult(
            batch: batch,
            items: items,
            workflowTaskId: batch.workflowTaskId,
          );
        }
      }

      await updateBatch(
        ChapterGenerationBatchStatus.succeeded,
        message: '批量草稿完成。',
        completedAt: DateTime.now(),
      );
      return ChapterGenerationBatchResult(
        batch: batch,
        items: await _repository
            .watchChapterGenerationBatchItems(batch.id)
            .first,
        workflowTaskId: batch.workflowTaskId,
      );
    } on LlmCancellationException {
      await _repository.abandonWorkflowTask(batch.workflowTaskId);
      rethrow;
    } on Object catch (error) {
      await updateBatch(
        ChapterGenerationBatchStatus.failed,
        message: '批量草稿失败：${_sanitizeError(error, provider)}',
        errorMessage: _sanitizeError(error, provider),
        completedAt: DateTime.now(),
      );
      rethrow;
    } finally {
      _cancellationRegistry.unregister(batch.workflowTaskId, cancellationToken);
      await cancellationToken.dispose();
    }
  }

  Future<ChapterGenerationBatchResult> stopChapterGenerationBatch(
    String batchId,
  ) async {
    var batch = await _requireGenerationBatch(batchId);
    if (batch.status != ChapterGenerationBatchStatus.pending &&
        batch.status != ChapterGenerationBatchStatus.running) {
      return ChapterGenerationBatchResult(
        batch: batch,
        items: await _repository
            .watchChapterGenerationBatchItems(batch.id)
            .first,
        workflowTaskId: batch.workflowTaskId,
      );
    }
    final log = StringBuffer(batch.logs);
    _appendLog(log, '用户停止批量草稿。');
    batch = await _repository.updateChapterGenerationBatchState(
      id: batch.id,
      status: ChapterGenerationBatchStatus.failed,
      errorMessage: '用户已停止批量草稿。',
      logs: log.toString(),
      completedAt: DateTime.now(),
    );
    return ChapterGenerationBatchResult(
      batch: batch,
      items: await _repository.watchChapterGenerationBatchItems(batch.id).first,
      workflowTaskId: batch.workflowTaskId,
    );
  }

  Future<ProjectChapter> proposeMemoryPatchForChapter({
    required String projectId,
    required String chapterId,
  }) async {
    final project = await _requireProject(projectId);
    final provider = await _requireProvider(project);
    final modelName = _requireModelName(project, provider);
    final chapter = await _repository.findChapter(chapterId);
    if (chapter == null) {
      throw StateError('Project chapter does not exist: $chapterId');
    }
    if (chapter.projectId != projectId) {
      throw StateError('章节不属于当前项目。');
    }
    if (chapter.contentMarkdown.trim().isEmpty) {
      throw StateError('章节正文为空，无法同步记忆。');
    }
    if (chapter.memorySyncStatus == MemorySyncStatus.pendingReview &&
        chapter.memorySyncContentHash == chapter.contentHash) {
      return chapter;
    }
    final plan = await _requirePlan(projectId, chapter.chapterPlanId);
    final current = await _repository.findChapter(chapter.id);
    if (current == null || current.contentHash != chapter.contentHash) {
      throw StateError('章节正文已变化，请重新打开后再同步记忆。');
    }
    final memory = await _repository.findRuntimeMemory(projectId);
    final characters = await _repository.watchCharacters(projectId).first;
    final relationships = await _repository.watchRelationships(projectId).first;
    await _proposeMemoryPatch(
      provider: provider,
      modelName: modelName,
      traceRecorder: null,
      chapter: current,
      project: project,
      plan: plan,
      currentMemory: memory?.state ?? const RuntimeMemoryState(),
      characters: characters,
      relationships: relationships,
    );
    final updated = await _repository.findChapter(chapter.id);
    if (updated == null) {
      throw StateError('Project chapter does not exist: ${chapter.id}');
    }
    return updated;
  }

  Future<ChapterGenerationBatchItem> _processBatchItem({
    required ChapterGenerationBatch batch,
    required ChapterGenerationBatchItem item,
    required WritingProject project,
    required ProviderConfig provider,
    required String modelName,
    required LlmCancellationToken cancellationToken,
  }) async {
    var currentItem = item;
    final itemLog = StringBuffer(currentItem.logs);

    Future<void> updateItem(
      ChapterGenerationBatchItemStatus status, {
      String? message,
      String? errorMessage,
      String? chapterId,
      String? latestRunId,
      int? draftAttemptCount,
      int? patchAttemptCount,
      DateTime? startedAt,
      DateTime? completedAt,
      DateTime? syncedAt,
    }) async {
      if (message != null && message.trim().isNotEmpty) {
        _appendLog(itemLog, message);
      }
      currentItem = await _repository.updateChapterGenerationBatchItemState(
        id: currentItem.id,
        status: status,
        errorMessage: errorMessage,
        chapterId: chapterId,
        latestRunId: latestRunId,
        draftAttemptCount: draftAttemptCount,
        patchAttemptCount: patchAttemptCount,
        logs: itemLog.toString(),
        startedAt: startedAt,
        completedAt: completedAt,
        syncedAt: syncedAt,
      );
    }

    await updateItem(
      ChapterGenerationBatchItemStatus.running,
      message: '开始处理批量章节。',
      startedAt: currentItem.startedAt ?? DateTime.now(),
    );
    cancellationToken.throwIfCancelled();

    var chapter = currentItem.chapterId == null
        ? await _repository.findChapterByPlan(currentItem.chapterPlanId)
        : await _repository.findChapter(currentItem.chapterId!);
    var generatedByThisBatch =
        chapter != null &&
        chapter.contentMarkdown.trim().isNotEmpty &&
        currentItem.draftAttemptCount > 0;

    while (chapter == null ||
        chapter.contentMarkdown.trim().isEmpty ||
        chapter.continuityVerdict != ContinuityVerdict.pass) {
      cancellationToken.throwIfCancelled();
      if (currentItem.draftAttemptCount >= _maxBatchDraftAttempts) {
        await updateItem(
          ChapterGenerationBatchItemStatus.failed,
          message: '正文审计重试耗尽。',
          errorMessage: '正文连续性审计未通过，已达到 $_maxBatchDraftAttempts 次重试上限。',
          completedAt: DateTime.now(),
        );
        return currentItem;
      }
      if (chapter != null &&
          chapter.contentMarkdown.trim().isNotEmpty &&
          !generatedByThisBatch) {
        await updateItem(
          ChapterGenerationBatchItemStatus.failed,
          message: '发现批次启动前已有正文，停止当前章节。',
          errorMessage: '章节已有正文，批量草稿不会覆盖既有正文。',
          completedAt: DateTime.now(),
        );
        return currentItem;
      }

      final attempt = currentItem.draftAttemptCount + 1;
      await updateItem(
        ChapterGenerationBatchItemStatus.running,
        message: '正文生成尝试 $attempt/$_maxBatchDraftAttempts。',
        draftAttemptCount: attempt,
      );
      try {
        final result = await generateChapter(
          projectId: batch.projectId,
          chapterPlanId: currentItem.chapterPlanId,
          replaceExisting: generatedByThisBatch,
        );
        cancellationToken.throwIfCancelled();
        generatedByThisBatch = true;
        chapter = result.chapter;
        await updateItem(
          ChapterGenerationBatchItemStatus.running,
          message: '正文生成完成，连续性审计：${result.chapter.continuityVerdict.name}。',
          chapterId: result.chapter.id,
          latestRunId: result.run.id,
        );
      } on Object catch (error) {
        if (error is LlmCancellationException) {
          rethrow;
        }
        final run = await _latestRunForPlan(
          projectId: batch.projectId,
          chapterPlanId: currentItem.chapterPlanId,
        );
        await updateItem(
          ChapterGenerationBatchItemStatus.running,
          message: '正文生成尝试失败：${_sanitizeError(error, provider)}',
          latestRunId: run?.id,
        );
      }

      chapter = await _repository.findChapterByPlan(currentItem.chapterPlanId);
    }

    while (true) {
      cancellationToken.throwIfCancelled();
      final stableChapter = chapter;
      if (stableChapter == null) {
        await updateItem(
          ChapterGenerationBatchItemStatus.failed,
          message: '章节正文未生成，无法同步记忆。',
          errorMessage: '章节正文未生成，无法同步记忆。',
          completedAt: DateTime.now(),
        );
        return currentItem;
      }
      final latest = await _repository.findChapter(stableChapter.id);
      if (latest == null) {
        await updateItem(
          ChapterGenerationBatchItemStatus.failed,
          message: '章节不存在，无法同步记忆。',
          errorMessage: '章节不存在，无法同步记忆。',
          completedAt: DateTime.now(),
        );
        return currentItem;
      }
      chapter = latest;
      if (chapter.memorySyncStatus == MemorySyncStatus.synced) {
        await updateItem(
          ChapterGenerationBatchItemStatus.synced,
          message: 'Memory Patch 已通过 AI 审阅并应用。',
          chapterId: chapter.id,
          completedAt: DateTime.now(),
          syncedAt: DateTime.now(),
        );
        return currentItem;
      }
      if (currentItem.patchAttemptCount >= _maxBatchPatchAttempts) {
        await updateItem(
          ChapterGenerationBatchItemStatus.failed,
          message: 'Memory Patch 审阅重试耗尽。',
          errorMessage: 'Memory Patch 审阅未通过，已达到 $_maxBatchPatchAttempts 次重试上限。',
          completedAt: DateTime.now(),
        );
        return currentItem;
      }
      final attempt = currentItem.patchAttemptCount + 1;
      await updateItem(
        ChapterGenerationBatchItemStatus.running,
        message: 'Memory Patch 生成与审阅尝试 $attempt/$_maxBatchPatchAttempts。',
        patchAttemptCount: attempt,
      );
      try {
        chapter = await _ensureMemoryPatchForBatch(
          project: project,
          provider: provider,
          modelName: modelName,
          chapter: chapter,
          cancellationToken: cancellationToken,
        );
        final review = await _reviewMemoryPatch(
          provider: provider,
          modelName: modelName,
          project: project,
          chapter: chapter,
          cancellationToken: cancellationToken,
        );
        await updateItem(
          ChapterGenerationBatchItemStatus.running,
          message:
              'Memory Patch AI 审阅：${review.verdict.name}。\n${review.reportMarkdown}',
        );
        if (review.verdict == ContinuityVerdict.pass) {
          final saved = await _repository.applyMemorySyncPatch(chapter.id);
          await updateItem(
            ChapterGenerationBatchItemStatus.synced,
            message: 'Memory Patch 已自动应用。',
            chapterId: saved.id,
            completedAt: DateTime.now(),
            syncedAt: DateTime.now(),
          );
          return currentItem;
        }
        if (chapter.memorySyncStatus == MemorySyncStatus.pendingReview) {
          await _repository.discardMemorySyncPatch(chapter.id);
        }
      } on Object catch (error) {
        if (error is LlmCancellationException) {
          rethrow;
        }
        await updateItem(
          ChapterGenerationBatchItemStatus.running,
          message: 'Memory Patch 审阅尝试失败：${_sanitizeError(error, provider)}',
        );
      }
    }
  }

  Future<WritingProject> _requireProject(String projectId) async {
    final project = await _projectRepository.findProject(projectId);
    if (project == null) {
      throw StateError('Project does not exist: $projectId');
    }
    return project;
  }

  Future<ChapterGenerationBatch> _requireGenerationBatch(String batchId) async {
    final batch = await _repository.findChapterGenerationBatch(batchId);
    if (batch == null) {
      throw StateError('Chapter generation batch does not exist: $batchId');
    }
    return batch;
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

  Future<void> _validateBatchStart({
    required String projectId,
    required List<String> chapterPlanIds,
  }) async {
    if (chapterPlanIds.isEmpty) {
      throw StateError('请选择需要批量生成的章节。');
    }
    if (await _repository.hasRunningChapterGenerationBatch(projectId)) {
      throw StateError('项目已有运行中的批量草稿任务。');
    }
    if (await _repository.hasRunningChapterGenerationForProject(projectId)) {
      throw StateError('项目已有运行中的单章生成任务。');
    }
    final chapters = await _repository.watchChapters(projectId).first;
    final pendingPatch = chapters.any(
      (chapter) => chapter.memorySyncStatus == MemorySyncStatus.pendingReview,
    );
    if (pendingPatch) {
      throw StateError('项目存在待审阅的 Memory Patch，请先应用或丢弃。');
    }
    final plans = <ChapterPlan>[];
    final seen = <String>{};
    for (final id in chapterPlanIds) {
      if (!seen.add(id)) {
        throw StateError('批量生成章节不能重复。');
      }
      final plan = await _requirePlan(projectId, id);
      plans.add(plan);
    }
    final sorted = [...plans]
      ..sort((a, b) => a.chapterIndex.compareTo(b.chapterIndex));
    for (var index = 0; index < sorted.length; index += 1) {
      if (sorted[index].id != plans[index].id) {
        throw StateError('批量生成章节必须按章节顺序选择。');
      }
    }
    final volumeId = plans.first.volumeId;
    for (var index = 0; index < plans.length; index += 1) {
      final plan = plans[index];
      if (plan.volumeId != volumeId) {
        throw StateError('批量生成仅支持同一卷内连续章节。');
      }
      if (index > 0 && plan.chapterIndex != plans[index - 1].chapterIndex + 1) {
        throw StateError('批量生成章节必须连续，不能跳章。');
      }
      final chapter = await _repository.findChapterByPlan(plan.id);
      if (chapter != null && chapter.contentMarkdown.trim().isNotEmpty) {
        throw StateError('选区内已有正文：${chapter.title}');
      }
      if (await _repository.hasRunningChapterGeneration(plan.id)) {
        throw StateError('章节已有运行中的生成任务：${_chapterTitle(plan)}');
      }
    }
  }

  Future<_GenerationContext> _buildGenerationContext({
    required String projectId,
    required String chapterPlanId,
    WritingProject? project,
    ChapterPlan? plan,
    ProviderConfig? provider,
    String? modelName,
    PromptTraceRecorder? traceRecorder,
    LlmCancellationToken? cancellationToken,
  }) async {
    final resolvedProject = project ?? await _requireProject(projectId);
    final resolvedPlan = plan ?? await _requirePlan(projectId, chapterPlanId);
    final assets = await _promptAssetResolver.resolve(projectId);
    final bible = await _repository.ensureProjectBible(projectId);
    final runtimeMemory = await _repository.findRuntimeMemory(projectId);
    final characters = await _repository.watchCharacters(projectId).first;
    final relationships = await _repository.watchRelationships(projectId).first;
    final previousChapters = (await _repository.watchChapters(projectId).first)
        .where(
          (chapter) =>
              chapter.chapterIndex < resolvedPlan.chapterIndex &&
              chapter.contentMarkdown.trim().isNotEmpty,
        )
        .toList(growable: false);
    final projectBible = ProjectBiblePromptContext(
      descriptionMarkdown: bible.descriptionMarkdown,
      worldBuildingMarkdown: bible.worldBuildingMarkdown,
      charactersBlueprintMarkdown: bible.charactersBlueprintMarkdown,
      outlineMasterMarkdown: bible.outlineMasterMarkdown,
      outlineDetailYaml: bible.outlineDetailYaml,
    );
    final baseSections = WritingContextSections(
      outputContract: _outputContract,
      projectBible: projectBible,
      chapterPlan: ChapterPlanPromptContext(
        volumeIndex: resolvedPlan.volumeIndex,
        volumeTitle: resolvedPlan.volumeTitle,
        chapterLocalIndex: resolvedPlan.chapterLocalIndex,
        chapterIndex: resolvedPlan.chapterIndex,
        coreEvent: resolvedPlan.coreEvent,
        emotionArc: resolvedPlan.emotionArc,
        chapterHook: resolvedPlan.chapterHook,
        outlineMarkdown: resolvedPlan.outlineMarkdown,
      ),
      chapterObjectiveCard: resolvedPlan.objectiveCard,
      voiceProfileMarkdown: assets.voiceProfileMarkdown,
      storyEngineMarkdown: assets.storyEngineMarkdown,
      projectContextMarkdown: _projectContextMarkdown(resolvedProject),
      characterGraphMarkdown: _characterGraphMarkdown(
        characters,
        relationships,
      ),
      runtimeMemory: runtimeMemory?.state ?? const RuntimeMemoryState(),
      writingRulesMarkdown: _writingRulesMarkdown(resolvedProject),
    );
    final retrieved = await _contextRetriever.retrieve(
      project: resolvedProject,
      plan: resolvedPlan,
      baseSections: baseSections,
      previousChapters: previousChapters,
      characters: characters,
      relationships: relationships,
      provider: provider,
      modelName: modelName,
      traceRecorder: traceRecorder,
      cancellationToken: cancellationToken,
    );
    final bundle = _contextAssembler.assemble(retrieved.sections);
    return _GenerationContext(
      bundle: bundle,
      baseSections: retrieved.sections,
      originalRuntimeMemory: baseSections.runtimeMemory,
      retrieved: retrieved,
      warnings: List.unmodifiable([
        ...assets.warnings,
        if (projectBible.isEmpty) 'Project Bible 为空。',
        if (characters.isEmpty) '结构化角色卡片为空。',
        if (runtimeMemory == null || runtimeMemory.state.isEmpty) '运行时记忆为空。',
        ...retrieved.selectionWarnings,
        ...bundle.warnings,
      ]),
      characters: List.unmodifiable(characters),
      relationships: List.unmodifiable(relationships),
    );
  }

  Future<_ContinuityAuditResult> _auditContinuity({
    required ProviderConfig provider,
    required String modelName,
    required PromptTraceRecorder traceRecorder,
    required WritingProject project,
    required ChapterPlan plan,
    required WritingContextSections sections,
    required String content,
    LlmCancellationToken? cancellationToken,
  }) async {
    final generated = await _completionService.completeMarkdown(
      provider: provider,
      prompt: _continuityAuditPrompt(
        project: project,
        plan: plan,
        sections: sections,
        content: content,
      ),
      temperature: 0.2,
      modelName: modelName,
      promptTrace: traceRecorder.config(label: 'audit_continuity'),
      cancellationToken: cancellationToken,
    );
    return _parseContinuityAudit(_cleanMarkdownDraft(generated));
  }

  String _continuityAuditPrompt({
    required WritingProject project,
    required ChapterPlan plan,
    required WritingContextSections sections,
    required String content,
  }) {
    return '''
你是长篇小说项目的连续性审计员。请检查刚生成的章节是否能安全进入项目正文。

## 输出契约
只输出 YAML front matter + Markdown 报告，不要输出代码围栏、解释或前言。
文档必须从 `---` 开始，以第二个 `---` 结束 YAML，然后接 Markdown 报告。

YAML 模板：
---
verdict: pass
summary: 一句话说明总体结论
characterState: pass
worldRules: pass
foreshadowing: pass
chapterObjective: pass
blockingIssues: []
warningIssues: []
---
# 连续性审计报告

## 判级规则
- `fail` 只用于明确硬冲突：人物状态与已知状态不可兼容、世界规则被明确违反、章节目标完全未推进且正文没有替代完成证据。
- 伏笔遗漏、目标完成偏弱、关系推进不足、轻微状态模糊，通常是 `warning`。
- 审美、文风、节奏、描写质量问题不能作为 `fail` 原因；最多写入 warning 或备注。
- 不要因为信息缺失就编造冲突。没有证据时写“未发现明确冲突”。

## 项目
- 标题：${project.title}
- 当前章节：第 ${plan.chapterIndex} 章 · ${_chapterTitle(plan)}

## 章节目标卡
${_objectiveCardMarkdown(plan.objectiveCard)}

## 章节细纲
${_chapterPlanMarkdown(sections.chapterPlan)}

## 项目设定与规则
${_auditReferenceMarkdown(sections)}

## 待审计章节正文
$content
''';
  }

  _ContinuityAuditResult _parseContinuityAudit(String generated) {
    final trimmed = generated.trim();
    try {
      if (!trimmed.startsWith('---')) {
        throw const FormatException('缺少 YAML front matter。');
      }
      final close = trimmed.indexOf('\n---', 3);
      if (close < 0) {
        throw const FormatException('缺少 YAML 结束分隔符。');
      }
      final yamlText = trimmed.substring(3, close).trim();
      final body = trimmed.substring(close + 4).trim();
      final parsed = loadYaml(yamlText);
      if (parsed is! YamlMap) {
        throw const FormatException('YAML 根节点不是 mapping。');
      }
      final verdict = _parseContinuityVerdict(parsed['verdict']?.toString());
      final report = body.isEmpty
          ? _fallbackAuditReport(verdict, parsed['summary']?.toString() ?? '')
          : body;
      return _ContinuityAuditResult(
        verdict: verdict,
        reportMarkdown: report.trim(),
      );
    } on Object catch (error) {
      return _ContinuityAuditResult(
        verdict: ContinuityVerdict.warning,
        reportMarkdown:
            '''
# 连续性审计报告

## 解析失败

审计输出解析失败，已按 warning 处理。错误：$error

## 原始审计输出

```markdown
$trimmed
```
'''
                .trim(),
      );
    }
  }

  ContinuityVerdict _parseContinuityVerdict(String? value) {
    final normalized = value?.trim().toLowerCase();
    return switch (normalized) {
      'pass' => ContinuityVerdict.pass,
      'warning' => ContinuityVerdict.warning,
      'fail' => ContinuityVerdict.fail,
      _ => throw FormatException('未知审计 verdict: $value'),
    };
  }

  String _fallbackAuditReport(ContinuityVerdict verdict, String summary) {
    final text = summary.trim().isEmpty ? '未提供审计摘要。' : summary.trim();
    return '# 连续性审计报告\n\n- Verdict: ${verdict.name}\n- Summary: $text';
  }

  String _auditLogMessage(ContinuityVerdict verdict) {
    return switch (verdict) {
      ContinuityVerdict.pass => '连续性审计通过。',
      ContinuityVerdict.warning => '连续性审计返回 warning，保存章节但暂停记忆同步。',
      ContinuityVerdict.fail => '连续性审计未通过，阻断章节保存。',
    };
  }

  String _objectiveCardMarkdown(ChapterObjectiveCard card) {
    if (card.isEmpty) {
      return '（空）';
    }
    return [
      if (card.chapterTitle.trim().isNotEmpty)
        '- Chapter Title: ${card.chapterTitle.trim()}',
      if (card.objective.trim().isNotEmpty)
        '- Objective: ${card.objective.trim()}',
      if (card.pressureSource.trim().isNotEmpty)
        '- Pressure Source: ${card.pressureSource.trim()}',
      if (card.payoffTarget.trim().isNotEmpty)
        '- Payoff Target: ${card.payoffTarget.trim()}',
      if (card.relationshipShift.trim().isNotEmpty)
        '- Relationship Shift: ${card.relationshipShift.trim()}',
      if (card.hookType.trim().isNotEmpty)
        '- Hook Type: ${card.hookType.trim()}',
    ].join('\n');
  }

  String _chapterPlanMarkdown(ChapterPlanPromptContext plan) {
    return [
      '- Volume: ${plan.volumeIndex} · ${plan.volumeTitle.trim()}',
      '- Local Chapter Index: ${plan.chapterLocalIndex}',
      '- Whole-book Chapter Index: ${plan.chapterIndex}',
      if (plan.coreEvent.trim().isNotEmpty)
        '- Core Event: ${plan.coreEvent.trim()}',
      if (plan.emotionArc.trim().isNotEmpty)
        '- Emotion Arc: ${plan.emotionArc.trim()}',
      if (plan.chapterHook.trim().isNotEmpty)
        '- Chapter Hook: ${plan.chapterHook.trim()}',
      if (plan.outlineMarkdown.trim().isNotEmpty)
        '\n${plan.outlineMarkdown.trim()}',
    ].join('\n');
  }

  String _auditReferenceMarkdown(WritingContextSections sections) {
    final parts = <String>[
      if (sections.retrievedReferencesMarkdown.trim().isNotEmpty)
        '### Retrieved References\n\n${sections.retrievedReferencesMarkdown.trim()}',
      if (!sections.projectBible.isEmpty)
        '### Project Bible\n\n${[sections.projectBible.descriptionMarkdown, sections.projectBible.worldBuildingMarkdown, sections.projectBible.charactersBlueprintMarkdown, sections.projectBible.outlineMasterMarkdown, sections.projectBible.outlineDetailYaml].where((value) => value.trim().isNotEmpty).join('\n\n')}',
      if (sections.storyEngineMarkdown.trim().isNotEmpty)
        '### Story Engine\n\n${sections.storyEngineMarkdown.trim()}',
      if (sections.characterGraphMarkdown.trim().isNotEmpty)
        '### Structured Characters And Relationships\n\n${sections.characterGraphMarkdown.trim()}',
      if (!sections.runtimeMemory.isEmpty)
        '### Runtime Memory\n\n${_runtimeMemoryMarkdown(sections.runtimeMemory)}',
    ];
    if (parts.isEmpty) {
      return '（空）';
    }
    return parts.join('\n\n');
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
        (sections.runtimeMemory.chapterArchiveMarkdown.trim().isNotEmpty ||
            sections.retrievedReferencesMarkdown.contains(
              'Source ID: runtime_memory.archive',
            ));
  }

  WritingContextSections _sectionsWithRuntimeReferenceDigest(
    WritingContextSections sections,
    RuntimeMemoryState digest,
  ) {
    final archive = digest.chapterArchiveMarkdown.trim();
    if (archive.isEmpty) {
      return sections;
    }
    final reference = sections.retrievedReferencesMarkdown.trim();
    final nextReference = reference.isEmpty
        ? '### Runtime Memory / Chapter Archive Digest\n\n$archive'
        : '$reference\n\n### Runtime Memory / Chapter Archive Digest\n\n$archive';
    return WritingContextSections(
      outputContract: sections.outputContract,
      projectBible: sections.projectBible,
      chapterPlan: sections.chapterPlan,
      chapterObjectiveCard: sections.chapterObjectiveCard,
      voiceProfileMarkdown: sections.voiceProfileMarkdown,
      storyEngineMarkdown: sections.storyEngineMarkdown,
      projectContextMarkdown: sections.projectContextMarkdown,
      characterGraphMarkdown: sections.characterGraphMarkdown,
      runtimeMemory: sections.runtimeMemory,
      retrievedReferencesMarkdown: nextReference,
      writingRulesMarkdown: sections.writingRulesMarkdown,
    );
  }

  Future<RuntimeMemoryState> _temporaryArchiveDigestMemory({
    required ProviderConfig provider,
    required String modelName,
    required PromptTraceRecorder traceRecorder,
    required WritingProject project,
    required ChapterPlan plan,
    required RuntimeMemoryState memory,
    LlmCancellationToken? cancellationToken,
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
        cancellationToken: cancellationToken,
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
    required PromptTraceRecorder? traceRecorder,
    required ProjectChapter chapter,
    required WritingProject project,
    required ChapterPlan plan,
    required RuntimeMemoryState currentMemory,
    required List<NovelCharacter> characters,
    required List<NovelRelationship> relationships,
    LlmCancellationToken? cancellationToken,
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
- 当 `runtimeMemory` 中的任一字段包含换行时，必须使用 YAML block scalar（`|` 或 `|-`）表示，不要用裸多行字符串。
- `chapterArchiveMarkdown` 必须用 YAML block scalar（`|` 或 `|-`）表示。

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
      promptTrace: traceRecorder?.config(label: 'propose_memory_patch'),
      cancellationToken: cancellationToken,
    );
    final patchYaml = normalizeMemoryPatchYaml(_cleanMarkdownDraft(generated));
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
    try {
      final patch = const MemoryPatchParser().parse(patchYaml);
      final proposedMemory = _parseProposedRuntimeMemory(
        patch.runtimeMemory,
        fallback: currentMemory,
      );
      await _repository.saveMemorySyncProposal(
        MemorySyncProposalInput(
          chapterId: chapter.id,
          contentHash: chapter.contentHash,
          proposedMemory: proposedMemory,
          patchYaml: patch.rawYaml,
        ),
      );
    } on MemoryPatchValidationException {
      await _repository.saveMemorySyncProposal(
        MemorySyncProposalInput(
          chapterId: chapter.id,
          contentHash: chapter.contentHash,
          proposedMemory: currentMemory,
          patchYaml: patchYaml,
        ),
      );
    }
  }

  Future<ProjectChapter> _ensureMemoryPatchForBatch({
    required WritingProject project,
    required ProviderConfig provider,
    required String modelName,
    required ProjectChapter chapter,
    required LlmCancellationToken cancellationToken,
  }) async {
    if (chapter.memorySyncStatus == MemorySyncStatus.pendingReview &&
        chapter.memorySyncContentHash == chapter.contentHash) {
      return chapter;
    }
    final plan = await _requirePlan(project.id, chapter.chapterPlanId);
    final current = await _repository.findChapter(chapter.id);
    if (current == null || current.contentHash != chapter.contentHash) {
      throw StateError('章节正文已变化，请重新打开后再同步记忆。');
    }
    final memory = await _repository.findRuntimeMemory(project.id);
    final characters = await _repository.watchCharacters(project.id).first;
    final relationships = await _repository
        .watchRelationships(project.id)
        .first;
    await _proposeMemoryPatch(
      provider: provider,
      modelName: modelName,
      traceRecorder: null,
      chapter: current,
      project: project,
      plan: plan,
      currentMemory: memory?.state ?? const RuntimeMemoryState(),
      characters: characters,
      relationships: relationships,
      cancellationToken: cancellationToken,
    );
    final updated = await _repository.findChapter(chapter.id);
    if (updated == null) {
      throw StateError('Project chapter does not exist: ${chapter.id}');
    }
    return updated;
  }

  Future<_ContinuityAuditResult> _reviewMemoryPatch({
    required ProviderConfig provider,
    required String modelName,
    required WritingProject project,
    required ProjectChapter chapter,
    required LlmCancellationToken cancellationToken,
  }) async {
    final memory = await _repository.findRuntimeMemory(project.id);
    final generated = await _completionService.completeMarkdown(
      provider: provider,
      prompt: _memoryPatchReviewPrompt(
        project: project,
        chapter: chapter,
        currentMemory: memory?.state ?? const RuntimeMemoryState(),
      ),
      temperature: 0.15,
      modelName: modelName,
      cancellationToken: cancellationToken,
    );
    return _parseContinuityAudit(_cleanMarkdownDraft(generated));
  }

  String _memoryPatchReviewPrompt({
    required WritingProject project,
    required ProjectChapter chapter,
    required RuntimeMemoryState currentMemory,
  }) {
    return '''
你是长篇小说项目的 Memory Patch 审阅员。请判断待应用的结构化记忆 Patch 是否可以安全写入 Runtime Memory 并服务下一章生成。

## 输出契约
只输出 YAML front matter + Markdown 报告，不要输出代码围栏、解释或前言。
文档必须从 `---` 开始，以第二个 `---` 结束 YAML，然后接 Markdown 报告。

YAML 模板：
---
verdict: pass
summary: 一句话说明总体结论
characterGraph: pass
runtimeMemory: pass
chapterArchive: pass
blockingIssues: []
warningIssues: []
---
# Memory Patch 审阅报告

## 判级规则
- `pass`：Patch 只记录本章正文明确发生的信息，不破坏既有 Runtime Memory，可以安全应用。
- `warning`：Patch 大体可读但有缺漏、模糊、轻微过度概括，继续自动应用有风险。
- `fail`：Patch 编造正文没有发生的信息、删除关键连续性、严重覆盖既有状态、或格式明显无法安全应用。
- 只评估 Patch 的安全性，不评价正文文风。

## 项目
- 标题：${project.title}
- 章节：第 ${chapter.chapterIndex} 章 · ${chapter.title}

## 当前 Runtime Memory
${_runtimeMemoryMarkdown(currentMemory)}

## 待应用 Patch YAML
${chapter.memorySyncPatchYaml.trim().isEmpty ? '（空）' : chapter.memorySyncPatchYaml.trim()}

## Patch 预览字段
### Runtime State
${chapter.memorySyncProposedRuntimeState.trim().isEmpty ? '（无变化）' : chapter.memorySyncProposedRuntimeState.trim()}

### Runtime Threads
${chapter.memorySyncProposedRuntimeThreads.trim().isEmpty ? '（无变化）' : chapter.memorySyncProposedRuntimeThreads.trim()}

### Story Summary
${chapter.memorySyncProposedStorySummary.trim().isEmpty ? '（无变化）' : chapter.memorySyncProposedStorySummary.trim()}

### Continuity Index
${chapter.memorySyncProposedContinuityIndex.trim().isEmpty ? '（无变化）' : chapter.memorySyncProposedContinuityIndex.trim()}

### Chapter Archive
${chapter.memorySyncProposedChapterArchiveMarkdown.trim().isEmpty ? '（无变化）' : chapter.memorySyncProposedChapterArchiveMarkdown.trim()}

## 章节正文
${chapter.contentMarkdown}
''';
  }

  Future<ChapterGenerationRun?> _latestRunForPlan({
    required String projectId,
    required String chapterPlanId,
  }) async {
    final runs = await _repository.watchChapterGenerationRuns(projectId).first;
    for (final run in runs) {
      if (run.chapterPlanId == chapterPlanId) {
        return run;
      }
    }
    return null;
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
    YamlMap? memory, {
    required RuntimeMemoryState fallback,
  }) {
    try {
      if (memory == null) {
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

class _GenerationContext {
  const _GenerationContext({
    required this.bundle,
    required this.baseSections,
    required this.originalRuntimeMemory,
    required this.retrieved,
    required this.warnings,
    required this.characters,
    required this.relationships,
  });

  final WritingContextBundle bundle;
  final WritingContextSections baseSections;
  final RuntimeMemoryState originalRuntimeMemory;
  final RetrievedWritingContext retrieved;
  final List<String> warnings;
  final List<NovelCharacter> characters;
  final List<NovelRelationship> relationships;
}

class _ContinuityAuditResult {
  const _ContinuityAuditResult({
    required this.verdict,
    required this.reportMarkdown,
  });

  final ContinuityVerdict verdict;
  final String reportMarkdown;
}

const _outputContract = '''
只输出当前章节正文。
输出必须是纯 Markdown 正文，不要 JSON，不要代码围栏，不要解释生成过程。
不要重复章节标题，章节标题由系统保存。
正文从当前上下文出发，完成本章目标，并为下一章留下可承接状态。
不得改写已确认设定、角色状态或关系；确需变化时，必须在正文中写出清晰因果和代价。
''';
