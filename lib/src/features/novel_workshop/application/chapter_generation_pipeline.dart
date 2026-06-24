import 'dart:math' as math;

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
import 'chapter_quality_review.dart';
import 'memory_patch_document.dart';
import 'memory_patch_yaml.dart';
import 'project_prompt_asset_resolver.dart';
import 'writing_context_assembler.dart';
import 'writing_context_retriever.dart';

const int _defaultChapterTargetChars = 3000;
const double _chapterMinCompletionRatio = 0.72;
const int _chapterMinCompletionFloor = 300;
const int _repeatCheckMinChars = 600;
const int _repeatWindowChars = 120;
const int _repeatHitLimit = 3;

class ChapterLengthSpec {
  const ChapterLengthSpec({
    required this.targetChars,
    required this.minCompletionChars,
  });

  final int targetChars;
  final int minCompletionChars;

  bool needsExpansion(String content) {
    return countDraftChars(content) < minCompletionChars;
  }
}

ChapterLengthSpec resolveChapterLengthSpec(int targetLength) {
  final target = targetLength > 0 ? targetLength : _defaultChapterTargetChars;
  return ChapterLengthSpec(
    targetChars: target,
    minCompletionChars: math.max(
      _chapterMinCompletionFloor,
      (target * _chapterMinCompletionRatio).round(),
    ),
  );
}

int countDraftChars(String content) {
  return content.replaceAll(RegExp(r'\s+'), '').length;
}

class DraftRepeatTrimResult {
  const DraftRepeatTrimResult({
    required this.content,
    required this.trimmed,
    required this.removedChars,
  });

  final String content;
  final bool trimmed;
  final int removedChars;
}

DraftRepeatTrimResult trimRepeatedTail(String content) {
  final normalized = content.replaceAll('\r\n', '\n').trim();
  final compact = normalized.replaceAll(RegExp(r'\s+'), '');
  if (compact.length < _repeatCheckMinChars) {
    return DraftRepeatTrimResult(
      content: normalized,
      trimmed: false,
      removedChars: 0,
    );
  }

  final tail = compact.substring(compact.length - _repeatWindowChars);
  final first = compact.indexOf(tail);
  if (first == -1 || first >= compact.length - _repeatWindowChars) {
    return DraftRepeatTrimResult(
      content: normalized,
      trimmed: false,
      removedChars: 0,
    );
  }

  var hits = 0;
  var searchIndex = 0;
  while (true) {
    final found = compact.indexOf(tail, searchIndex);
    if (found == -1) {
      break;
    }
    hits += 1;
    if (hits >= _repeatHitLimit) {
      final cutIndex = _sourceIndexFromCompactIndex(
        normalized,
        first + _repeatWindowChars,
      );
      final trimmed = normalized.substring(0, cutIndex).trimRight();
      return DraftRepeatTrimResult(
        content: trimmed,
        trimmed: trimmed.length < normalized.length,
        removedChars: math.max(0, normalized.length - trimmed.length),
      );
    }
    searchIndex = found + math.max(1, tail.length);
  }

  return DraftRepeatTrimResult(
    content: normalized,
    trimmed: false,
    removedChars: 0,
  );
}

int _sourceIndexFromCompactIndex(String content, int compactIndex) {
  var seen = 0;
  for (var index = 0; index < content.length; index += 1) {
    if (RegExp(r'\s').hasMatch(content[index])) {
      continue;
    }
    seen += 1;
    if (seen >= compactIndex) {
      return index + 1;
    }
  }
  return content.length;
}

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
    bool? useHighQualityGeneration,
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
      ChapterQualityVerdict? qualityReviewVerdict,
      String? qualityReviewReportMarkdown,
      String? qualityRevisionNotesMarkdown,
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
        qualityReviewVerdict: qualityReviewVerdict,
        qualityReviewReportMarkdown: qualityReviewReportMarkdown,
        qualityRevisionNotesMarkdown: qualityRevisionNotesMarkdown,
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

      final highQuality =
          useHighQualityGeneration ?? project.useHighQualityGeneration;
      final lengthSpec = resolveChapterLengthSpec(project.targetLength);
      ChapterQualityReviewResult? qualityReview;
      var qualityRevisionNotes = '';
      final qualityProcessNotes = <String>[];
      var revisedForQuality = false;
      var postRevisionCharacterReview = '';
      late String content;

      if (highQuality) {
        await transition(
          ChapterGenerationStatus.running,
          ChapterGenerationStage.planningBrief,
          message: '阶段: 生成任务书。梳理本章读感目标、场景推进和章末钩子。',
          contextWarningsMarkdown: _warningsMarkdown(contextWarnings),
        );
        cancellationToken.throwIfCancelled();
        final taskBrief = await _buildChapterTaskBrief(
          provider: provider,
          modelName: modelName,
          traceRecorder: traceRecorder,
          project: project,
          plan: plan,
          sections: baseSections,
          cancellationToken: cancellationToken,
        );

        await transition(
          ChapterGenerationStatus.running,
          ChapterGenerationStage.generatingDraft,
          message: '阶段: 生成正文。根据任务书和上下文生成初稿。',
        );
        cancellationToken.throwIfCancelled();
        var draft = await _generateChapterDraft(
          provider: provider,
          modelName: modelName,
          traceRecorder: traceRecorder,
          prompt: _draftPromptWithTaskBrief(
            basePrompt: bundle.promptMarkdown,
            taskBrief: taskBrief,
          ),
          cancellationToken: cancellationToken,
        );
        draft = _prepareGeneratedBody(
          draft,
          label: '初稿',
          notes: qualityProcessNotes,
        );

        if (lengthSpec.needsExpansion(draft)) {
          final beforeChars = countDraftChars(draft);
          await transition(
            ChapterGenerationStatus.running,
            ChapterGenerationStage.expandingDraft,
            message:
                '阶段: 扩写补足。初稿约 $beforeChars 字，低于最低完成线 ${lengthSpec.minCompletionChars} 字。',
          );
          cancellationToken.throwIfCancelled();
          draft = await _expandChapterDraft(
            provider: provider,
            modelName: modelName,
            traceRecorder: traceRecorder,
            project: project,
            plan: plan,
            sections: baseSections,
            taskBrief: taskBrief,
            draft: draft,
            lengthSpec: lengthSpec,
            cancellationToken: cancellationToken,
          );
          draft = _prepareGeneratedBody(
            draft,
            label: '扩写稿',
            notes: qualityProcessNotes,
          );
          qualityProcessNotes.add(
            '初稿约 $beforeChars 字，低于最低完成线 '
            '${lengthSpec.minCompletionChars} 字，已自动扩写一次；'
            '扩写后约 ${countDraftChars(draft)} 字。',
          );
          qualityRevisionNotes = _qualityRevisionNotes(
            null,
            revised: revisedForQuality,
            processNotes: qualityProcessNotes,
          );
          await transition(
            ChapterGenerationStatus.running,
            ChapterGenerationStage.expandingDraft,
            qualityRevisionNotesMarkdown: qualityRevisionNotes,
          );
        }

        await transition(
          ChapterGenerationStatus.running,
          ChapterGenerationStage.qualityReviewing,
          message: '阶段: 质量评审。检查爽感、节奏、追读、角色命中和语言自然度。',
        );
        cancellationToken.throwIfCancelled();
        qualityReview = await _reviewDraftQuality(
          provider: provider,
          modelName: modelName,
          traceRecorder: traceRecorder,
          project: project,
          plan: plan,
          sections: baseSections,
          taskBrief: taskBrief,
          draft: draft,
          cancellationToken: cancellationToken,
        );
        qualityRevisionNotes = _qualityRevisionNotes(
          qualityReview,
          revised: revisedForQuality,
          processNotes: qualityProcessNotes,
        );
        await transition(
          ChapterGenerationStatus.running,
          ChapterGenerationStage.qualityReviewing,
          message: _qualityReviewLogMessage(qualityReview),
          qualityReviewVerdict: qualityReview.verdict,
          qualityReviewReportMarkdown: qualityReview.reportMarkdown,
          qualityRevisionNotesMarkdown: qualityRevisionNotes,
        );

        if (qualityReview.needsRevision) {
          await transition(
            ChapterGenerationStatus.running,
            ChapterGenerationStage.revisingDraft,
            message: '阶段: 自动修订。根据质量评审修订初稿一轮。',
          );
          cancellationToken.throwIfCancelled();
          draft = await _reviseDraftForQuality(
            provider: provider,
            modelName: modelName,
            traceRecorder: traceRecorder,
            project: project,
            plan: plan,
            sections: baseSections,
            taskBrief: taskBrief,
            draft: draft,
            review: qualityReview,
            cancellationToken: cancellationToken,
          );
          draft = _prepareGeneratedBody(
            draft,
            label: '质量修订稿',
            notes: qualityProcessNotes,
          );
          revisedForQuality = true;
          qualityRevisionNotes = _qualityRevisionNotes(
            qualityReview,
            revised: revisedForQuality,
            processNotes: qualityProcessNotes,
          );
          await transition(
            ChapterGenerationStatus.running,
            ChapterGenerationStage.revisingDraft,
            qualityRevisionNotesMarkdown: qualityRevisionNotes,
          );

          await transition(
            ChapterGenerationStatus.running,
            ChapterGenerationStage.postRevisionCharacterReview,
            message: '阶段: 角色复审。检查自动修订是否引入人物状态或声线偏差。',
          );
          cancellationToken.throwIfCancelled();
          postRevisionCharacterReview = await _reviewPostRevisionCharacterHit(
            provider: provider,
            modelName: modelName,
            traceRecorder: traceRecorder,
            project: project,
            plan: plan,
            sections: baseSections,
            taskBrief: taskBrief,
            draft: draft,
            cancellationToken: cancellationToken,
          );
          qualityRevisionNotes = _qualityRevisionNotes(
            qualityReview,
            revised: revisedForQuality,
            processNotes: qualityProcessNotes,
            characterReviewMarkdown: postRevisionCharacterReview,
          );
          await transition(
            ChapterGenerationStatus.running,
            ChapterGenerationStage.postRevisionCharacterReview,
            message: '角色专项复审完成，结果将作为非阻断润色参考。',
            qualityRevisionNotesMarkdown: qualityRevisionNotes,
          );
        }

        await transition(
          ChapterGenerationStatus.running,
          ChapterGenerationStage.polishingDraft,
          message: '阶段: 去 AI 润色。压实语言、去模板句式并保留事实。',
        );
        cancellationToken.throwIfCancelled();
        content = await _polishDraft(
          provider: provider,
          modelName: modelName,
          traceRecorder: traceRecorder,
          project: project,
          plan: plan,
          sections: baseSections,
          draft: draft,
          characterReviewMarkdown: postRevisionCharacterReview,
          cancellationToken: cancellationToken,
        );
        content = _prepareGeneratedBody(
          content,
          label: '终稿润色稿',
          notes: qualityProcessNotes,
        );
        qualityRevisionNotes = _qualityRevisionNotes(
          qualityReview,
          revised: revisedForQuality,
          processNotes: qualityProcessNotes,
          characterReviewMarkdown: postRevisionCharacterReview,
        );
      } else {
        await transition(
          ChapterGenerationStatus.running,
          ChapterGenerationStage.generatingDraft,
          message: '阶段: 生成正文。调用模型生成纯 Markdown 章节正文。',
          contextWarningsMarkdown: _warningsMarkdown(contextWarnings),
        );
        cancellationToken.throwIfCancelled();
        content = await _generateChapterDraft(
          provider: provider,
          modelName: modelName,
          traceRecorder: traceRecorder,
          prompt: bundle.promptMarkdown,
          cancellationToken: cancellationToken,
        );
      }
      if (content.trim().isEmpty) {
        throw StateError('模型返回了空章节正文。');
      }

      await transition(
        ChapterGenerationStatus.running,
        ChapterGenerationStage.auditContinuity,
        message: '阶段: 连续性审计。检查人物状态、世界规则、伏笔和章节目标。',
        draftMarkdown: content,
        qualityReviewVerdict: qualityReview?.verdict,
        qualityReviewReportMarkdown: qualityReview?.reportMarkdown,
        qualityRevisionNotesMarkdown: qualityRevisionNotes,
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
        qualityReviewVerdict: qualityReview?.verdict,
        qualityReviewReportMarkdown: qualityReview?.reportMarkdown,
        qualityRevisionNotesMarkdown: qualityRevisionNotes,
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
          qualityReviewVerdict:
              qualityReview?.verdict ?? ChapterQualityVerdict.pass,
          qualityReviewReportMarkdown: qualityReview?.reportMarkdown ?? '',
          qualityRevisionNotesMarkdown: qualityRevisionNotes,
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

  Future<String> _buildChapterTaskBrief({
    required ProviderConfig provider,
    required String modelName,
    required PromptTraceRecorder traceRecorder,
    required WritingProject project,
    required ChapterPlan plan,
    required WritingContextSections sections,
    required LlmCancellationToken cancellationToken,
  }) async {
    final generated = await _completionService.completeMarkdown(
      provider: provider,
      prompt: _chapterTaskBriefPrompt(
        project: project,
        plan: plan,
        sections: sections,
      ),
      temperature: 0.25,
      modelName: modelName,
      promptTrace: traceRecorder.config(label: 'plan_chapter_brief'),
      cancellationToken: cancellationToken,
    );
    final brief = _cleanMarkdownDraft(generated);
    if (brief.trim().isEmpty) {
      return '本章按章节目标、细纲、人物状态和写作规则推进，不额外改写已确认设定。';
    }
    return brief;
  }

  Future<String> _generateChapterDraft({
    required ProviderConfig provider,
    required String modelName,
    required PromptTraceRecorder traceRecorder,
    required String prompt,
    required LlmCancellationToken cancellationToken,
  }) async {
    final generated = await _completionService.completeMarkdown(
      provider: provider,
      prompt: prompt,
      temperature: 0.75,
      modelName: modelName,
      promptTrace: traceRecorder.config(label: 'generate_chapter_draft'),
      cancellationToken: cancellationToken,
    );
    return _cleanMarkdownDraft(generated);
  }

  Future<String> _expandChapterDraft({
    required ProviderConfig provider,
    required String modelName,
    required PromptTraceRecorder traceRecorder,
    required WritingProject project,
    required ChapterPlan plan,
    required WritingContextSections sections,
    required String taskBrief,
    required String draft,
    required ChapterLengthSpec lengthSpec,
    required LlmCancellationToken cancellationToken,
  }) async {
    final generated = await _completionService.completeMarkdown(
      provider: provider,
      prompt: _draftExpansionPrompt(
        project: project,
        plan: plan,
        sections: sections,
        taskBrief: taskBrief,
        draft: draft,
        lengthSpec: lengthSpec,
      ),
      temperature: 0.65,
      modelName: modelName,
      promptTrace: traceRecorder.config(label: 'expand_chapter_draft'),
      cancellationToken: cancellationToken,
    );
    final expanded = _cleanMarkdownDraft(generated);
    return expanded.trim().isEmpty ? draft : expanded;
  }

  Future<ChapterQualityReviewResult> _reviewDraftQuality({
    required ProviderConfig provider,
    required String modelName,
    required PromptTraceRecorder traceRecorder,
    required WritingProject project,
    required ChapterPlan plan,
    required WritingContextSections sections,
    required String taskBrief,
    required String draft,
    required LlmCancellationToken cancellationToken,
  }) async {
    final generated = await _completionService.completeMarkdown(
      provider: provider,
      prompt: _qualityReviewPrompt(
        project: project,
        plan: plan,
        sections: sections,
        taskBrief: taskBrief,
        draft: draft,
      ),
      temperature: 0.2,
      modelName: modelName,
      promptTrace: traceRecorder.config(label: 'review_chapter_quality'),
      cancellationToken: cancellationToken,
    );
    return const ChapterQualityReviewParser().parse(generated);
  }

  Future<String> _reviseDraftForQuality({
    required ProviderConfig provider,
    required String modelName,
    required PromptTraceRecorder traceRecorder,
    required WritingProject project,
    required ChapterPlan plan,
    required WritingContextSections sections,
    required String taskBrief,
    required String draft,
    required ChapterQualityReviewResult review,
    required LlmCancellationToken cancellationToken,
  }) async {
    final generated = await _completionService.completeMarkdown(
      provider: provider,
      prompt: _qualityRevisionPrompt(
        project: project,
        plan: plan,
        sections: sections,
        taskBrief: taskBrief,
        draft: draft,
        review: review,
      ),
      temperature: 0.55,
      modelName: modelName,
      promptTrace: traceRecorder.config(label: 'revise_chapter_quality'),
      cancellationToken: cancellationToken,
    );
    final revised = _cleanMarkdownDraft(generated);
    return revised.trim().isEmpty ? draft : revised;
  }

  Future<String> _reviewPostRevisionCharacterHit({
    required ProviderConfig provider,
    required String modelName,
    required PromptTraceRecorder traceRecorder,
    required WritingProject project,
    required ChapterPlan plan,
    required WritingContextSections sections,
    required String taskBrief,
    required String draft,
    required LlmCancellationToken cancellationToken,
  }) async {
    final generated = await _completionService.completeMarkdown(
      provider: provider,
      prompt: _postRevisionCharacterReviewPrompt(
        project: project,
        plan: plan,
        sections: sections,
        taskBrief: taskBrief,
        draft: draft,
      ),
      temperature: 0.2,
      modelName: modelName,
      promptTrace: traceRecorder.config(label: 'review_revision_character_hit'),
      cancellationToken: cancellationToken,
    );
    return _parsePostRevisionCharacterReview(_cleanMarkdownDraft(generated));
  }

  Future<String> _polishDraft({
    required ProviderConfig provider,
    required String modelName,
    required PromptTraceRecorder traceRecorder,
    required WritingProject project,
    required ChapterPlan plan,
    required WritingContextSections sections,
    required String draft,
    required String characterReviewMarkdown,
    required LlmCancellationToken cancellationToken,
  }) async {
    final generated = await _completionService.completeMarkdown(
      provider: provider,
      prompt: _polishPrompt(
        project: project,
        plan: plan,
        sections: sections,
        draft: draft,
        characterReviewMarkdown: characterReviewMarkdown,
      ),
      temperature: 0.45,
      modelName: modelName,
      promptTrace: traceRecorder.config(label: 'polish_chapter_draft'),
      cancellationToken: cancellationToken,
    );
    final polished = _cleanMarkdownDraft(generated);
    return polished.trim().isEmpty ? draft : polished;
  }

  String _chapterTaskBriefPrompt({
    required WritingProject project,
    required ChapterPlan plan,
    required WritingContextSections sections,
  }) {
    return '''
你是长篇小说章节策划编辑。请把当前章节上下文压缩成一份可执行的写作任务书，供下一步正文生成使用。

## 输出契约
只输出 Markdown 任务书，不要写正文，不要输出代码围栏、解释或前言。

任务书必须包含：
- 本章核心推进：目标、压力、兑现、关系变化、章末钩子中本章必须完成的内容。
- 场景节奏：建议的开场承接、中段转折、末尾留钩。
- 角色命中：必须承接的当前状态、关系、秘密或利益动机。
- 读感重点：爽感/推进、节奏张力、追读钩子、语言自然度的执行提醒。

## 项目
${_projectContextMarkdown(project)}

## 章节
- 当前章节：第 ${plan.chapterIndex} 章 · ${_chapterTitle(plan)}

## 章节目标卡
${_objectiveCardMarkdown(plan.objectiveCard)}

## 章节细纲
${_chapterPlanMarkdown(sections.chapterPlan)}

## 关键上下文
${_auditReferenceMarkdown(sections)}
''';
  }

  String _draftPromptWithTaskBrief({
    required String basePrompt,
    required String taskBrief,
  }) {
    return '''
$basePrompt

## Chapter Task Brief

$taskBrief

请严格按上面的任务书生成当前章节正文。任务书服务正文，不得作为正文输出。
''';
  }

  String _draftExpansionPrompt({
    required WritingProject project,
    required ChapterPlan plan,
    required WritingContextSections sections,
    required String taskBrief,
    required String draft,
    required ChapterLengthSpec lengthSpec,
  }) {
    return '''
你是长篇小说正文扩写补足编辑。当前章节正文明显过短，请在不推翻已有内容的前提下扩写成完整章节。

## 输出契约
只输出扩写补足后的当前章节正文，不要输出标题、解释、报告、代码围栏或改稿说明。

## 扩写目标
- 目标篇幅约 ${lengthSpec.targetChars} 字；低于 ${lengthSpec.minCompletionChars} 字视为初稿未完成。
- 保留原稿已经发生的核心事件、人物关系、设定事实和章末方向。
- 补足场景铺陈、动作细节、对话交锋、心理变化、压力升级和章末钩子。
- 不新增会推翻大纲、人物状态、世界规则或后续章节安排的大剧情。
- 禁止复读、循环输出、同义堆字；每一段都必须推进剧情、冲突、人物关系或期待。

## 项目
${_projectContextMarkdown(project)}

## 章节
- 当前章节：第 ${plan.chapterIndex} 章 · ${_chapterTitle(plan)}

## 任务书
$taskBrief

## 上下文边界
${_auditReferenceMarkdown(sections)}

## 当前过短正文
$draft
''';
  }

  String _qualityReviewPrompt({
    required WritingProject project,
    required ChapterPlan plan,
    required WritingContextSections sections,
    required String taskBrief,
    required String draft,
  }) {
    return '''
你是长篇网文成稿质量编辑。请评审初稿的读感，不做连续性硬审计；硬冲突会由后续连续性审计处理。

## 输出契约
只输出 YAML front matter + Markdown 报告，不要输出代码围栏、解释或前言。
文档必须从 `---` 开始，以第二个 `---` 结束 YAML，然后接 Markdown 报告。

YAML 模板：
---
verdict: pass
needsRevision: false
overallScore: 85
dimensions:
  thrill: 85
  pacing: 85
  pull: 85
  characterHit: 85
  naturalLanguage: 85
majorIssues: []
revisionInstructions: |-
  无需修订。
---
# 质量评审报告

## 评审维度
- `thrill` 爽感/推进：本章是否有明确获得、反击、压迫解除、信息差兑现、目标推进或代价落地。
- `pacing` 节奏张力：开场是否承接压力，中段是否有变化，段落/对话是否拖沓。
- `pull` 追读钩子：章末是否留下可承接的新问题、新压力或关系变化。
- `characterHit` 角色命中：人物当前状态、利益动机、关系强度和说话方式是否被正文命中。
- `naturalLanguage` 语言自然度：是否有模板句、AI 腔、说教、空泛比喻和总结感。

## 判级规则
- `pass`：无需自动修订，最多是轻微建议。
- `warning`：有读感问题但不值得自动改稿。
- `needsRevision`：存在一个或多个重大问题，应该自动修订一轮。
- 只在读感问题会明显伤害成稿时设 `needsRevision: true`。
- 不要因道德灰色选择、主角不正义、关系功利而扣分；只判断是否好看、顺畅、可追。

## QMAI 式逐维审查流程
对每个维度都必须给出 `pass` 或 `issue`，不要只写总体感受：
- 已核对依据：引用任务书、角色/记忆参照或正文片段。
- 正文证据：给出具体原文，不要凭空评价。
- 读感影响：说明这个问题如何损害爽感、节奏、追读、角色命中或语言自然度。
- rewrite target：指出自动修订应定位的原文片段或段落功能。
- 阻断判定：只有重大读感问题才进入 `majorIssues` 并触发 `needsRevision: true`。

Markdown 报告必须包含 `## 逐维审查` 和 `## 自动修订目标` 两节；`revisionInstructions` 必须可直接交给改稿模型执行。

## 项目
${_projectContextMarkdown(project)}

## 章节
- 当前章节：第 ${plan.chapterIndex} 章 · ${_chapterTitle(plan)}

## 任务书
$taskBrief

## 角色/记忆参照
${_auditReferenceMarkdown(sections)}

## 待评审初稿
$draft
''';
  }

  String _qualityRevisionPrompt({
    required WritingProject project,
    required ChapterPlan plan,
    required WritingContextSections sections,
    required String taskBrief,
    required String draft,
    required ChapterQualityReviewResult review,
  }) {
    return '''
你是长篇小说改稿编辑。请根据质量评审对初稿进行一轮自动修订。

## 输出契约
只输出修订后的当前章节正文，不要输出标题、解释、报告、代码围栏或改稿说明。

## 改稿边界
- 必须保留原稿已经发生的核心事件、人物关系和设定事实。
- 可以重排段落、压缩废话、加强动作/对话/压力、补足承接和章末钩子。
- 不新增后续大剧情，不替作者规划未来章节。
- 不把道德灰色选择洗白，不加入道德总结。

## 项目
${_projectContextMarkdown(project)}

## 章节
- 当前章节：第 ${plan.chapterIndex} 章 · ${_chapterTitle(plan)}

## 任务书
$taskBrief

## 上下文边界
${_auditReferenceMarkdown(sections)}

## 质量评审报告
${review.reportMarkdown}

## 修订指令
${review.revisionInstructions.trim().isEmpty ? '按质量评审中的重大问题修订。' : review.revisionInstructions.trim()}

## 初稿
$draft
''';
  }

  String _postRevisionCharacterReviewPrompt({
    required WritingProject project,
    required ChapterPlan plan,
    required WritingContextSections sections,
    required String taskBrief,
    required String draft,
  }) {
    return '''
你是长篇小说返修后角色一致性专项审稿员。请只检查自动修订后的正文是否引入新的角色偏差；不要做完整质量评审，也不要建议二次自动返修。

## 输出契约
只输出 YAML front matter + Markdown 报告，不要输出代码围栏、解释或前言。
文档必须从 `---` 开始，以第二个 `---` 结束 YAML，然后接 Markdown 报告。

YAML 模板：
---
verdict: pass
issues: []
polishInstructions: |-
  无需额外处理。
---
# 返修后角色专项复审

## 检查范围
- 人物当前状态、资源、伤势、秘密和关系强度是否被修订稿改偏。
- 角色动机是否仍由利益、欲望、压力或生存本能驱动。
- 角色知道/不知道的信息是否越界。
- 台词、称呼、说话方式是否符合既有角色卡和关系。
- 只标出有正文证据和上下文依据的问题；没有证据就写 pass。

## 非阻断规则
本复审只服务最终润色，不阻断保存，不触发第二轮自动修订。若有问题，`polishInstructions` 只写轻量修补建议。

## 项目
${_projectContextMarkdown(project)}

## 章节
- 当前章节：第 ${plan.chapterIndex} 章 · ${_chapterTitle(plan)}

## 任务书
$taskBrief

## 角色/记忆参照
${_auditReferenceMarkdown(sections)}

## 返修后正文
$draft
''';
  }

  String _polishPrompt({
    required WritingProject project,
    required ChapterPlan plan,
    required WritingContextSections sections,
    required String draft,
    required String characterReviewMarkdown,
  }) {
    return '''
你是长篇小说终稿润色编辑。请做最终去 AI 腔和自然化润色。

## 输出契约
只输出润色后的当前章节正文，不要输出标题、解释、报告、代码围栏或润色说明。

## 润色边界
- 不改变事实、人物关系、场景顺序、章节结尾状态和已确认设定。
- 不新增重大事件或伏笔；只改善表达、节奏、对白和段落呼吸。
- 优先把抽象情绪换成动作、感官、选择和代价。
- 删除模板句、空泛比喻、哲理总结、道德评判和 AI 腔连接词。
- 保持 ${project.language.trim()} 和 ${project.narrativePerspective.trim()}。
- 如果下方提供了返修后角色专项复审，请用轻量润色修补其中有证据的问题；不要新增大剧情，不要改变事实。

## 反 AI 腔规则
${sections.writingRulesMarkdown.trim().isEmpty ? _writingRulesMarkdown(project) : sections.writingRulesMarkdown.trim()}

## 章节
- 当前章节：第 ${plan.chapterIndex} 章 · ${_chapterTitle(plan)}

${characterReviewMarkdown.trim().isEmpty ? '' : '## 返修后角色专项复审\n${characterReviewMarkdown.trim()}\n'}

## 待润色正文
$draft
''';
  }

  String _qualityReviewLogMessage(ChapterQualityReviewResult review) {
    if (review.needsRevision) {
      return '质量评审：needsRevision，将自动修订一轮。';
    }
    return '质量评审：${review.verdict.name}，不触发自动修订。';
  }

  String _qualityRevisionNotes(
    ChapterQualityReviewResult? review, {
    required bool revised,
    List<String> processNotes = const [],
    String characterReviewMarkdown = '',
  }) {
    final lines = <String>[
      '# 质量修订说明',
      '',
      '- 质量结论：${review?.verdict.name ?? '待评审'}',
      if (review?.overallScore != null) '- 总分：${review!.overallScore}',
      '- 自动修订：${revised ? '已执行一轮' : '未执行'}',
    ];
    if (processNotes.isNotEmpty) {
      lines
        ..add('')
        ..add('## 生成链处理记录');
      for (final note in processNotes) {
        lines.add('- $note');
      }
    }
    if (review != null && review.majorIssues.isNotEmpty) {
      lines
        ..add('')
        ..add('## 重大问题');
      for (final issue in review.majorIssues) {
        lines.add('- $issue');
      }
    }
    if (review != null && review.revisionInstructions.trim().isNotEmpty) {
      lines
        ..add('')
        ..add('## 修订指令')
        ..add(review.revisionInstructions.trim());
    }
    if (characterReviewMarkdown.trim().isNotEmpty) {
      lines
        ..add('')
        ..add('## 返修后角色专项复审')
        ..add(characterReviewMarkdown.trim());
    }
    return lines.join('\n').trim();
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
- 角色的道德灰色选择（撒谎、利用、牺牲他人、利益驱动决策）不是连续性错误，不能作为 `fail` 或 `warning` 原因。只检查行为是否与已知性格和能力一致，不检查行为是否正确。
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

  String _parsePostRevisionCharacterReview(String generated) {
    final trimmed = generated.trim();
    if (trimmed.isEmpty) {
      return '# 返修后角色专项复审\n\n未返回复审内容，按非阻断通过处理。';
    }
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
      final verdict = parsed['verdict']?.toString().trim();
      final polishInstructions = _yamlString(parsed['polishInstructions']);
      if (body.isNotEmpty) {
        return body;
      }
      return [
        '# 返修后角色专项复审',
        '',
        '- 结论：${verdict == null || verdict.isEmpty ? 'pass' : verdict}',
        if (polishInstructions.isNotEmpty) '- 润色指令：$polishInstructions',
      ].join('\n');
    } on Object catch (error) {
      return '''
# 返修后角色专项复审

复审输出解析失败，已按非阻断处理；最终连续性审计仍会检查硬冲突。

- 解析错误：$error
'''
          .trim();
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
- 角色的道德灰色行为导致的结构化状态变化（关系恶化、阵营转换、秘密暴露等）不是 Patch 错误，只要正文确实发生了这些变化。

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
      '',
      '## 反AI腔写作规则',
      '- 禁用词：仿佛、犹如、宛若、缓缓、不禁、微微、淡淡、映入眼帘、心中暗道、嘴角微扬、瞳孔微缩、不由自主、心头一震、心下了然。遇到这些词时，用具体的身体动作或感官细节替代。',
      '- 禁用句式："不是A，而是B"（最强AI腔信号）；"声音不大，却带着...的力量"；"眼中闪过一丝..."；"嘴角勾起一抹..."。',
      '- 心理描写外化：不写"他感到愤怒/悲伤/恐惧"，写身体细节（手背青筋鼓起来、把外套叠了三次放进柜子最深处、摸了三下门把手才握住）。',
      '- 段落节奏：优先一句一段；超过60字的段落考虑分行；约30-50%的句子独立成段；不要把3个以上句号放在同一段里。',
      '- 章末禁止总结感慨、哲理收尾、"他不知道的是..."式预告。用动作、对话或悬念收尾。',
      '- 每个子事件必须把"发生了什么""主角注意到什么感官细节""身体如何反应"编织在一个连续段落里，禁止分成三段（发生/感知/反应分开是AI腔标志性模式）。',
      '- 对话去僵硬：60%以上的对话不加"他说""她道"等标签，直接写对白；不同角色的说话方式要有差异（口头禅、句式长短、用词习惯）。',
      '',
      '## 反道德说教（核心写作约束）',
      '- 主角的决策逻辑是利益计算，不是道德判断。写"他算了一下这笔账划不划算"，不写"他内心在正义和私利之间挣扎"。',
      '- 主角可以撒谎、利用他人、借刀杀人、在必要时牺牲他人利益。关键是"手段服务于目标"，不需要道德包装。',
      '- 冲突解决靠实力、信息差、资源碾压或手段更狠，不靠"正义觉醒""天理昭昭"或"善恶终有报"。',
      '- 不要让主角做"道德正确的选择然后获得奖励"。让主角做"利益最大化的选择然后承受代价"。',
      '- 配角的帮助和支持必须有利可图的理由（利益一致、人情债、把柄、未来回报），不要写成"因为主角是好人所以大家都帮他"。',
      '- 反派被击败是因为主角更强/更聪明/更狠，不是因为"邪不压正"。反派可以理直气壮追求自己的利益，不需要"其实他也有苦衷"的洗白。',
      '- 叙事层禁止道德评判。不要用"正义""邪恶""善良""歹毒"等道德标签描述角色或行为。用利益语言：写"他控制了三条商路"不写"他是邪恶的商人"。',
      '- 不要写"他内心深处知道这是错的"。如果他做了，说明他认为值得。',
      '- 关系变化用利益和信任描述：写"他们因为目标一致而合作"不写"他们因为都心存正义而结盟"。',
      '- 禁止在章末加道德总结、人生感悟或"他终于明白了什么是真正的XX"式的升华。',
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

  String _prepareGeneratedBody(
    String content, {
    required String label,
    required List<String> notes,
  }) {
    final result = trimRepeatedTail(content);
    if (result.trimmed) {
      notes.add('$label 检测到尾部重复输出，已裁掉约 ${result.removedChars} 字。');
    }
    return result.content;
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
角色行为由利益和欲望驱动，不由道德感驱动；主角可以做出道德灰色甚至道德黑色的选择，不需要叙事层为其辩护或包装。
冲突解决靠实力、信息差和手段，不靠"正义必胜"或"天理昭昭"的叙事机制。
''';
