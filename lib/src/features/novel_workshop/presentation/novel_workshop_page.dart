import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/glass_container.dart';
import '../../../core/ui/persona_page.dart';
import '../../../core/ui/skeleton_loader.dart';
import '../../projects/application/project_providers.dart';
import '../../projects/domain/writing_project.dart';
import '../application/novel_workshop_providers.dart';
import '../domain/novel_workshop.dart';
import '../domain/writing_context.dart';

class NovelWorkshopPage extends ConsumerStatefulWidget {
  const NovelWorkshopPage({required this.projectId, super.key});

  final String projectId;

  @override
  ConsumerState<NovelWorkshopPage> createState() => _NovelWorkshopPageState();
}

class _NovelWorkshopPageState extends ConsumerState<NovelWorkshopPage> {
  final _editorController = TextEditingController();
  String? _selectedPlanId;
  String? _loadedChapterId;
  String _loadedContent = '';

  @override
  void dispose() {
    _editorController.dispose();
    super.dispose();
  }

  bool get _isDirty => _editorController.text != _loadedContent;

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(writingProjectProvider(widget.projectId));
    final plans = ref.watch(chapterPlansProvider(widget.projectId));
    final chapters = ref.watch(projectChaptersProvider(widget.projectId));
    final runs = ref.watch(chapterGenerationRunsProvider(widget.projectId));
    final memory = ref.watch(projectRuntimeMemoryProvider(widget.projectId));
    final assets = ref.watch(projectPromptAssetsProvider(widget.projectId));
    final controller = ref.watch(novelWorkshopControllerProvider);

    ref.listen(novelWorkshopControllerProvider, (previous, next) {
      if (next.hasError) {
        _showSnack('操作失败：${next.error}');
      }
    });

    return project.when(
      data: (item) {
        if (item == null) {
          return _MissingProjectPage(projectId: widget.projectId);
        }
        if (item.status != ProjectStatus.active) {
          return _ArchivedProjectPage(project: item);
        }
        return plans.when(
          data: (planItems) => chapters.when(
            data: (chapterItems) => runs.when(
              data: (runItems) {
                final selectedPlan = _syncSelectedPlan(planItems);
                final selectedChapter = selectedPlan == null
                    ? null
                    : _chapterForPlan(chapterItems, selectedPlan.id);
                _syncEditor(selectedChapter);
                final selectedRun = selectedPlan == null
                    ? null
                    : _latestRunForPlan(runItems, selectedPlan.id);
                final selectedRunning =
                    selectedRun?.status == ChapterGenerationStatus.pending ||
                    selectedRun?.status == ChapterGenerationStatus.running;
                final busy = controller.isLoading || selectedRunning;

                return _WorkshopScaffold(
                  project: item,
                  plans: planItems,
                  chapters: chapterItems,
                  runs: runItems,
                  selectedPlan: selectedPlan,
                  selectedChapter: selectedChapter,
                  selectedRun: selectedRun,
                  editorController: _editorController,
                  isDirty: _isDirty,
                  isBusy: busy,
                  assets: assets,
                  memory: memory,
                  onSelectPlan: (plan) => _selectPlan(
                    nextPlan: plan,
                    currentProject: item,
                    currentPlan: selectedPlan,
                    currentChapter: selectedChapter,
                  ),
                  onCreatePlan: () => _showPlanDialog(
                    context: context,
                    projectId: item.id,
                    nextIndex: _nextChapterIndex(planItems),
                  ),
                  onEditPlan: selectedPlan == null
                      ? null
                      : () => _showPlanDialog(
                          context: context,
                          projectId: item.id,
                          plan: selectedPlan,
                        ),
                  onSaveChapter: selectedPlan == null || busy
                      ? null
                      : () => _saveChapter(
                          project: item,
                          plan: selectedPlan,
                          chapter: selectedChapter,
                        ),
                  onGenerate: selectedPlan == null || busy
                      ? null
                      : () => _generateChapter(
                          project: item,
                          plan: selectedPlan,
                          chapter: selectedChapter,
                        ),
                );
              },
              error: (error, stackTrace) =>
                  _WorkshopError(message: '无法加载生成任务：$error'),
              loading: () => const _WorkshopLoading(),
            ),
            error: (error, stackTrace) =>
                _WorkshopError(message: '无法加载章节正文：$error'),
            loading: () => const _WorkshopLoading(),
          ),
          error: (error, stackTrace) =>
              _WorkshopError(message: '无法加载章节计划：$error'),
          loading: () => const _WorkshopLoading(),
        );
      },
      error: (error, stackTrace) => _WorkshopError(message: '无法加载项目：$error'),
      loading: () => const _WorkshopLoading(),
    );
  }

  ChapterPlan? _syncSelectedPlan(List<ChapterPlan> plans) {
    if (plans.isEmpty) {
      _selectedPlanId = null;
      return null;
    }
    final selected = plans
        .where((plan) => plan.id == _selectedPlanId)
        .firstOrNull;
    if (selected != null) {
      return selected;
    }
    _selectedPlanId = plans.first.id;
    return plans.first;
  }

  void _syncEditor(ProjectChapter? chapter) {
    final chapterId = chapter?.id;
    final content = chapter?.contentMarkdown ?? '';
    if (_loadedChapterId == chapterId && _loadedContent == content) {
      return;
    }
    _loadedChapterId = chapterId;
    _loadedContent = content;
    _editorController.text = content;
  }

  Future<void> _selectPlan({
    required ChapterPlan nextPlan,
    required WritingProject currentProject,
    required ChapterPlan? currentPlan,
    required ProjectChapter? currentChapter,
  }) async {
    if (nextPlan.id == currentPlan?.id) {
      return;
    }
    if (!await _resolveDirtyEditor(
      project: currentProject,
      plan: currentPlan,
      chapter: currentChapter,
    )) {
      return;
    }
    setState(() => _selectedPlanId = nextPlan.id);
  }

  Future<void> _saveChapter({
    required WritingProject project,
    required ChapterPlan plan,
    required ProjectChapter? chapter,
  }) async {
    try {
      final saved = await ref
          .read(novelWorkshopControllerProvider.notifier)
          .saveChapter(
            id: chapter?.id,
            input: ProjectChapterInput(
              projectId: project.id,
              chapterPlanId: plan.id,
              chapterIndex: plan.chapterIndex,
              title: _chapterTitle(plan),
              contentMarkdown: _editorController.text,
            ),
          );
      setState(() {
        _loadedChapterId = saved.id;
        _loadedContent = saved.contentMarkdown;
      });
      _showSnack('正文已保存。');
    } on Object {
      // The controller listener renders the error.
    }
  }

  Future<void> _generateChapter({
    required WritingProject project,
    required ChapterPlan plan,
    required ProjectChapter? chapter,
  }) async {
    if (!await _resolveDirtyEditor(
      project: project,
      plan: plan,
      chapter: chapter,
    )) {
      return;
    }
    var replaceExisting = false;
    if ((chapter?.contentMarkdown.trim().isNotEmpty ?? false)) {
      final confirmed = await _confirmOverwriteChapter(plan);
      if (!confirmed) {
        return;
      }
      replaceExisting = true;
    }
    try {
      await ref
          .read(novelWorkshopControllerProvider.notifier)
          .generateChapter(
            projectId: widget.projectId,
            chapterPlanId: plan.id,
            replaceExisting: replaceExisting,
          );
      _showSnack('章节生成完成。');
    } on Object {
      // The controller listener renders the error.
    }
  }

  Future<bool> _resolveDirtyEditor({
    required WritingProject project,
    required ChapterPlan? plan,
    required ProjectChapter? chapter,
  }) async {
    if (!_isDirty) {
      return true;
    }
    final action = await showGlassDialog<_DirtyEditorAction>(
      context: context,
      maxWidth: 520,
      builder: (context) => const _DirtyEditorDialog(),
    );
    switch (action) {
      case _DirtyEditorAction.save:
        if (plan == null) {
          return false;
        }
        await _saveChapter(project: project, plan: plan, chapter: chapter);
        return !_isDirty;
      case _DirtyEditorAction.discard:
        setState(() {
          _editorController.text = _loadedContent;
        });
        return true;
      case _DirtyEditorAction.cancel:
      case null:
        return false;
    }
  }

  Future<bool> _confirmOverwriteChapter(ChapterPlan plan) async {
    final confirmed = await showGlassDialog<bool>(
      context: context,
      maxWidth: 520,
      builder: (context) => _ConfirmOverwriteDialog(plan: plan),
    );
    return confirmed ?? false;
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _WorkshopScaffold extends StatelessWidget {
  const _WorkshopScaffold({
    required this.project,
    required this.plans,
    required this.chapters,
    required this.runs,
    required this.selectedPlan,
    required this.selectedChapter,
    required this.selectedRun,
    required this.editorController,
    required this.isDirty,
    required this.isBusy,
    required this.assets,
    required this.memory,
    required this.onSelectPlan,
    required this.onCreatePlan,
    required this.onEditPlan,
    required this.onSaveChapter,
    required this.onGenerate,
  });

  final WritingProject project;
  final List<ChapterPlan> plans;
  final List<ProjectChapter> chapters;
  final List<ChapterGenerationRun> runs;
  final ChapterPlan? selectedPlan;
  final ProjectChapter? selectedChapter;
  final ChapterGenerationRun? selectedRun;
  final TextEditingController editorController;
  final bool isDirty;
  final bool isBusy;
  final AsyncValue<ProjectPromptAssets> assets;
  final AsyncValue<ProjectRuntimeMemory> memory;
  final ValueChanged<ChapterPlan> onSelectPlan;
  final VoidCallback onCreatePlan;
  final VoidCallback? onEditPlan;
  final VoidCallback? onSaveChapter;
  final VoidCallback? onGenerate;

  @override
  Widget build(BuildContext context) {
    final selectedRunning =
        selectedRun?.status == ChapterGenerationStatus.pending ||
        selectedRun?.status == ChapterGenerationStatus.running;
    return Material(
      color: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final navigator = _ChapterNavigator(
            plans: plans,
            chapters: chapters,
            runs: runs,
            selectedPlanId: selectedPlan?.id,
            onSelectPlan: onSelectPlan,
            onCreatePlan: onCreatePlan,
          );
          final inspector = _WorkshopInspector(
            plan: selectedPlan,
            run: selectedRun,
            assets: assets,
            memory: memory,
          );
          final editor = _ManuscriptEditor(
            plan: selectedPlan,
            run: selectedRun,
            controller: editorController,
            isBusy: isBusy,
            onEditPlan: onEditPlan,
          );
          if (constraints.maxWidth < 1120) {
            return Column(
              children: [
                _WorkshopTopBar(
                  project: project,
                  plan: selectedPlan,
                  isDirty: isDirty,
                  isRunning: selectedRunning,
                  onCreatePlan: onCreatePlan,
                  onSaveChapter: onSaveChapter,
                  onGenerate: onGenerate,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 360, child: navigator),
                        SizedBox(height: 760, child: editor),
                        SizedBox(height: 520, child: inspector),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              _WorkshopTopBar(
                project: project,
                plan: selectedPlan,
                isDirty: isDirty,
                isRunning: selectedRunning,
                onCreatePlan: onCreatePlan,
                onSaveChapter: onSaveChapter,
                onGenerate: onGenerate,
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: 292, child: navigator),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    Expanded(child: editor),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    SizedBox(width: 320, child: inspector),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WorkshopTopBar extends StatelessWidget {
  const _WorkshopTopBar({
    required this.project,
    required this.plan,
    required this.isDirty,
    required this.isRunning,
    required this.onCreatePlan,
    required this.onSaveChapter,
    required this.onGenerate,
  });

  final WritingProject project;
  final ChapterPlan? plan;
  final bool isDirty;
  final bool isRunning;
  final VoidCallback onCreatePlan;
  final VoidCallback? onSaveChapter;
  final VoidCallback? onGenerate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusLabel = isRunning
        ? '生成中'
        : isDirty
        ? '未保存'
        : '已保存';
    final statusIcon = isRunning
        ? Icons.sync
        : isDirty
        ? Icons.edit_outlined
        : Icons.check_circle_outline;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          child: Row(
            children: [
              IconButton(
                tooltip: '返回项目',
                onPressed: () => context.go('/projects'),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      project.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    _CompactStatusPill(
                      label: statusLabel,
                      icon: statusIcon,
                      color: isDirty ? colorScheme.error : colorScheme.primary,
                    ),
                    if (plan != null)
                      Text(
                        '第 ${plan!.chapterIndex} 章 · ${_chapterTitle(plan!)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: onCreatePlan,
                    icon: const Icon(Icons.add),
                    label: const Text('新建章节'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onSaveChapter,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('保存正文'),
                  ),
                  FilledButton.icon(
                    onPressed: onGenerate,
                    icon: const Icon(Icons.auto_fix_high_outlined),
                    label: const Text('生成章节'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChapterNavigator extends StatelessWidget {
  const _ChapterNavigator({
    required this.plans,
    required this.chapters,
    required this.runs,
    required this.selectedPlanId,
    required this.onSelectPlan,
    required this.onCreatePlan,
  });

  final List<ChapterPlan> plans;
  final List<ProjectChapter> chapters;
  final List<ChapterGenerationRun> runs;
  final String? selectedPlanId;
  final ValueChanged<ChapterPlan> onSelectPlan;
  final VoidCallback onCreatePlan;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '创作导航',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: '新建章节',
                  onPressed: onCreatePlan,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
            child: _ChapterProgressStrip(plans: plans, chapters: chapters),
          ),
          if (plans.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: _NavigatorEmptyState(onCreatePlan: onCreatePlan),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 18),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return _ChapterPlanTile(
                    plan: plan,
                    chapter: _chapterForPlan(chapters, plan.id),
                    run: _latestRunForPlan(runs, plan.id),
                    selected: selectedPlanId == plan.id,
                    onTap: () => onSelectPlan(plan),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ChapterProgressStrip extends StatelessWidget {
  const _ChapterProgressStrip({required this.plans, required this.chapters});

  final List<ChapterPlan> plans;
  final List<ProjectChapter> chapters;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final completed = plans
        .where(
          (plan) =>
              _chapterForPlan(
                chapters,
                plan.id,
              )?.contentMarkdown.trim().isNotEmpty ??
              false,
        )
        .length;
    final progress = plans.isEmpty ? 0.0 : completed / plans.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('章节', style: Theme.of(context).textTheme.labelLarge),
            const Spacer(),
            Text(
              '$completed/${plans.length} 已写',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}

class _NavigatorEmptyState extends StatelessWidget {
  const _NavigatorEmptyState({required this.onCreatePlan});

  final VoidCallback onCreatePlan;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.note_add_outlined, color: colorScheme.primary, size: 30),
            const SizedBox(height: 12),
            Text('尚未创建章节', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              '先创建章节目标卡，再生成或手写正文。',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onCreatePlan,
              icon: const Icon(Icons.add),
              label: const Text('新建章节'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterPlanTile extends StatelessWidget {
  const _ChapterPlanTile({
    required this.plan,
    required this.chapter,
    required this.run,
    required this.selected,
    required this.onTap,
  });

  final ChapterPlan plan;
  final ProjectChapter? chapter;
  final ChapterGenerationRun? run;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final running =
        run?.status == ChapterGenerationStatus.pending ||
        run?.status == ChapterGenerationStatus.running;
    final completed = chapter?.contentMarkdown.trim().isNotEmpty ?? false;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected
            ? colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
          left: BorderSide(
            color: selected ? colorScheme.primary : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      running
                          ? Icons.sync
                          : completed
                          ? Icons.check
                          : Icons.circle_outlined,
                      size: 17,
                      color: selected
                          ? colorScheme.primary
                          : running
                          ? colorScheme.primary
                          : completed
                          ? Colors.green
                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '第 ${plan.chapterIndex} 章 · ${_chapterTitle(plan)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: selected
                                ? FontWeight.w900
                                : FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          plan.objectiveCard.objective.trim().isEmpty
                              ? '未填写章节目标。'
                              : plan.objectiveCard.objective,
                          maxLines: selected ? 3 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManuscriptEditor extends StatelessWidget {
  const _ManuscriptEditor({
    required this.plan,
    required this.run,
    required this.controller,
    required this.isBusy,
    required this.onEditPlan,
  });

  final ChapterPlan? plan;
  final ChapterGenerationRun? run;
  final TextEditingController controller;
  final bool isBusy;
  final VoidCallback? onEditPlan;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (plan == null) {
      return ColoredBox(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.18),
        child: const Center(
          child: PersonaEmptyStateCard(
            icon: Icons.menu_book_outlined,
            title: '选择章节后开始写作',
            description: '左侧章节列表为空时，请先创建章节目标卡。',
          ),
        ),
      );
    }
    return ColoredBox(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      child: Column(
        children: [
          _ChapterBanner(plan: plan!, run: run, onEditPlan: onEditPlan),
          if (run?.errorMessage != null)
            _EditorNotice(message: '最近生成失败：${run!.errorMessage}'),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 940),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 30),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border.all(color: colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextField(
                      key: const ValueKey('novel-workshop-editor'),
                      controller: controller,
                      enabled: !isBusy,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      keyboardType: TextInputType.multiline,
                      textAlignVertical: TextAlignVertical.top,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        height: 1.72,
                        color: colorScheme.onSurface,
                      ),
                      decoration: const InputDecoration(
                        hintText: '在这里写入当前章节正文。',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.fromLTRB(34, 32, 34, 32),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterBanner extends StatelessWidget {
  const _ChapterBanner({
    required this.plan,
    required this.run,
    required this.onEditPlan,
  });

  final ChapterPlan plan;
  final ChapterGenerationRun? run;
  final VoidCallback? onEditPlan;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('当前章节', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 5),
                  Text(
                    '第 ${plan.chapterIndex} 章 · ${_chapterTitle(plan)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _objectiveSummary(plan.objectiveCard),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (run != null)
              _CompactStatusPill(
                label: _runStatusLabel(run!.status),
                icon: _runIcon(run!.status),
                color: _runColor(context, run!.status),
              ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onEditPlan,
              icon: const Icon(Icons.tune_outlined),
              label: const Text('编辑目标'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorNotice extends StatelessWidget {
  const _EditorNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.32),
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
        child: Row(
          children: [
            Icon(Icons.error_outline, size: 18, color: colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkshopInspector extends StatelessWidget {
  const _WorkshopInspector({
    required this.plan,
    required this.run,
    required this.assets,
    required this.memory,
  });

  final ChapterPlan? plan;
  final ChapterGenerationRun? run;
  final AsyncValue<ProjectPromptAssets> assets;
  final AsyncValue<ProjectRuntimeMemory> memory;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Text(
              '工作流诊断',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InspectorSection(
                    title: '章节目标',
                    child: plan == null
                        ? const Text('未选择章节。')
                        : _ObjectiveCardView(card: plan!.objectiveCard),
                  ),
                  _InspectorSection(
                    title: '上下文状态',
                    child: _ContextStatusList(assets: assets, memory: memory),
                  ),
                  _InspectorSection(
                    title: '生成任务',
                    child: _RunSummary(run: run),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InspectorSection extends StatelessWidget {
  const _InspectorSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ObjectiveCardView extends StatelessWidget {
  const _ObjectiveCardView({required this.card});

  final ChapterObjectiveCard card;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoLine(label: '标题', value: card.chapterTitle),
        _InfoLine(label: '目标', value: card.objective),
        _InfoLine(label: '压力源', value: card.pressureSource),
        _InfoLine(label: '兑现目标', value: card.payoffTarget),
        _InfoLine(label: '关系变化', value: card.relationshipShift),
        _InfoLine(label: '钩子类型', value: card.hookType),
      ],
    );
  }
}

class _ContextStatusList extends StatelessWidget {
  const _ContextStatusList({required this.assets, required this.memory});

  final AsyncValue<ProjectPromptAssets> assets;
  final AsyncValue<ProjectRuntimeMemory> memory;

  @override
  Widget build(BuildContext context) {
    return assets.when(
      data: (asset) => memory.when(
        data: (item) {
          final warnings = <String>[
            ...asset.warnings,
            if (item.state.isEmpty) '运行时记忆为空。',
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AssetStatus(
                label: 'Voice Profile',
                ready: asset.voiceProfileMarkdown.trim().isNotEmpty,
              ),
              _AssetStatus(
                label: 'Story Engine',
                ready: asset.storyEngineMarkdown.trim().isNotEmpty,
              ),
              _AssetStatus(label: 'Runtime Memory', ready: !item.state.isEmpty),
              if (warnings.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text('Warnings', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                for (final warning in warnings)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• $warning'),
                  ),
              ],
            ],
          );
        },
        error: (error, stackTrace) => Text('无法加载运行时记忆：$error'),
        loading: () => const SkeletonBox(width: 180, height: 14),
      ),
      error: (error, stackTrace) => Text('无法加载 Prompt 资产：$error'),
      loading: () => const SkeletonBox(width: 180, height: 14),
    );
  }
}

class _AssetStatus extends StatelessWidget {
  const _AssetStatus({required this.label, required this.ready});

  final String label;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            ready ? Icons.check_circle_outline : Icons.warning_amber_outlined,
            size: 18,
            color: ready
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(ready ? '已接入' : '缺失'),
        ],
      ),
    );
  }
}

class _RunSummary extends StatelessWidget {
  const _RunSummary({required this.run});

  final ChapterGenerationRun? run;

  @override
  Widget build(BuildContext context) {
    final item = run;
    if (item == null) {
      return const Text('当前章节暂无生成任务。');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoLine(label: '状态', value: _runStatusLabel(item.status)),
        _InfoLine(label: '阶段', value: _runStageLabel(item.stage)),
        _InfoLine(label: '模型', value: item.modelName),
        if (item.contextWarningsMarkdown.trim().isNotEmpty)
          _InfoLine(label: 'Warnings', value: item.contextWarningsMarkdown),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => context.go('/workflow-runs/${item.workflowTaskId}'),
          icon: const Icon(Icons.open_in_new_outlined),
          label: const Text('查看 Prompt Trace'),
        ),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final text = value?.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 3),
          Text(text == null || text.isEmpty ? '未填写' : text),
        ],
      ),
    );
  }
}

class _CompactStatusPill extends StatelessWidget {
  const _CompactStatusPill({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.28)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DirtyEditorDialog extends StatelessWidget {
  const _DirtyEditorDialog();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('正文尚未保存', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        const Text('继续前请选择保存当前正文、放弃本地改动或取消操作。'),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 8,
          runSpacing: 8,
          children: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(_DirtyEditorAction.cancel),
              child: const Text('取消'),
            ),
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pop(_DirtyEditorAction.discard),
              child: const Text('放弃'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(_DirtyEditorAction.save),
              child: const Text('保存'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ConfirmOverwriteDialog extends StatelessWidget {
  const _ConfirmOverwriteDialog({required this.plan});

  final ChapterPlan plan;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '覆盖已有正文',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('「${_chapterTitle(plan)}」已有正文。重新生成会覆盖当前保存内容。'),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('确认覆盖'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChapterPlanDialog extends ConsumerStatefulWidget {
  const _ChapterPlanDialog({
    required this.projectId,
    required this.nextIndex,
    this.plan,
  });

  final String projectId;
  final int nextIndex;
  final ChapterPlan? plan;

  @override
  ConsumerState<_ChapterPlanDialog> createState() => _ChapterPlanDialogState();
}

class _ChapterPlanDialogState extends ConsumerState<_ChapterPlanDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _objectiveController;
  late final TextEditingController _pressureController;
  late final TextEditingController _payoffController;
  late final TextEditingController _relationshipController;
  late final TextEditingController _hookController;

  int get _chapterIndex => widget.plan?.chapterIndex ?? widget.nextIndex;

  @override
  void initState() {
    super.initState();
    final card = widget.plan?.objectiveCard ?? const ChapterObjectiveCard();
    _titleController = TextEditingController(text: card.chapterTitle);
    _objectiveController = TextEditingController(text: card.objective);
    _pressureController = TextEditingController(text: card.pressureSource);
    _payoffController = TextEditingController(text: card.payoffTarget);
    _relationshipController = TextEditingController(
      text: card.relationshipShift,
    );
    _hookController = TextEditingController(text: card.hookType);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _objectiveController.dispose();
    _pressureController.dispose();
    _payoffController.dispose();
    _relationshipController.dispose();
    _hookController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(novelWorkshopControllerProvider);
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.plan == null ? '新建章节目标卡' : '编辑章节目标卡',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            TextFormField(
              initialValue: '第 $_chapterIndex 章',
              readOnly: true,
              decoration: const InputDecoration(labelText: '章节序号'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '章节标题'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _objectiveController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: '章节目标'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pressureController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: '压力源'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _payoffController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: '兑现目标'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _relationshipController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: '关系变化'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _hookController,
              decoration: const InputDecoration(labelText: '钩子类型'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: state.isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: state.isLoading ? null : _save,
                  child: const Text('保存'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_chapterIndex <= 0) {
      _showDialogSnack('章节序号必须大于 0。');
      return;
    }
    final card = ChapterObjectiveCard(
      chapterTitle: _titleController.text,
      objective: _objectiveController.text,
      pressureSource: _pressureController.text,
      payoffTarget: _payoffController.text,
      relationshipShift: _relationshipController.text,
      hookType: _hookController.text,
    );
    if (card.isEmpty) {
      _showDialogSnack('章节目标卡不能为空。');
      return;
    }
    try {
      await ref
          .read(novelWorkshopControllerProvider.notifier)
          .saveChapterPlan(
            id: widget.plan?.id,
            input: ChapterPlanInput(
              projectId: widget.projectId,
              chapterIndex: _chapterIndex,
              objectiveCard: card,
            ),
          );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on Object catch (error) {
      _showDialogSnack('保存失败：$error');
    }
  }

  void _showDialogSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _WorkshopLoading extends StatelessWidget {
  const _WorkshopLoading();

  @override
  Widget build(BuildContext context) {
    return const PersonaPage(
      eyebrow: '写作工作台',
      title: '加载中',
      description: '正在读取项目、章节和生成任务。',
      children: [
        PersonaPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 180, height: 16),
              SizedBox(height: 14),
              SkeletonBox(width: 420, height: 12),
              SizedBox(height: 10),
              SkeletonBox(width: 360, height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

class _WorkshopError extends StatelessWidget {
  const _WorkshopError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: '写作工作台',
      title: '无法打开工作台',
      description: message,
      actions: [
        OutlinedButton.icon(
          onPressed: () => context.go('/projects'),
          icon: const Icon(Icons.arrow_back_outlined),
          label: const Text('返回项目'),
        ),
      ],
      children: [
        PersonaPanel(
          child: Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    );
  }
}

class _MissingProjectPage extends StatelessWidget {
  const _MissingProjectPage({required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: '写作工作台',
      title: '项目不存在',
      description: '没有找到项目：$projectId。',
      actions: [
        OutlinedButton.icon(
          onPressed: () => context.go('/projects'),
          icon: const Icon(Icons.arrow_back_outlined),
          label: const Text('返回项目'),
        ),
      ],
      children: const [
        PersonaEmptyStateCard(
          icon: Icons.link_off_outlined,
          title: '无法打开工作台',
          description: '该项目可能已被删除或归档数据不可用。',
        ),
      ],
    );
  }
}

class _ArchivedProjectPage extends StatelessWidget {
  const _ArchivedProjectPage({required this.project});

  final WritingProject project;

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: '写作工作台',
      title: '项目已归档',
      description: '「${project.title}」已归档，工作台只服务活动项目。',
      actions: [
        OutlinedButton.icon(
          onPressed: () => context.go('/projects'),
          icon: const Icon(Icons.arrow_back_outlined),
          label: const Text('返回项目'),
        ),
      ],
      children: const [
        PersonaEmptyStateCard(
          icon: Icons.inventory_2_outlined,
          title: '归档项目不可编辑',
          description: '请先在项目页恢复项目，再打开写作工作台。',
        ),
      ],
    );
  }
}

enum _DirtyEditorAction { save, discard, cancel }

void _showPlanDialog({
  required BuildContext context,
  required String projectId,
  int nextIndex = 1,
  ChapterPlan? plan,
}) {
  showGlassDialog<void>(
    context: context,
    maxWidth: 680,
    maxHeight: MediaQuery.sizeOf(context).height * 0.9,
    builder: (context) => _ChapterPlanDialog(
      projectId: projectId,
      nextIndex: nextIndex,
      plan: plan,
    ),
  );
}

ProjectChapter? _chapterForPlan(List<ProjectChapter> chapters, String planId) {
  return chapters
      .where((chapter) => chapter.chapterPlanId == planId)
      .firstOrNull;
}

ChapterGenerationRun? _latestRunForPlan(
  List<ChapterGenerationRun> runs,
  String planId,
) {
  final matches = runs.where((run) => run.chapterPlanId == planId).toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return matches.firstOrNull;
}

int _nextChapterIndex(List<ChapterPlan> plans) {
  if (plans.isEmpty) {
    return 1;
  }
  return plans
          .map((plan) => plan.chapterIndex)
          .reduce((a, b) => a > b ? a : b) +
      1;
}

String _chapterTitle(ChapterPlan plan) {
  final title = plan.objectiveCard.chapterTitle.trim();
  return title.isEmpty ? '第 ${plan.chapterIndex} 章' : title;
}

String _objectiveSummary(ChapterObjectiveCard card) {
  final values = [
    card.objective,
    card.pressureSource,
    card.payoffTarget,
    card.relationshipShift,
    card.hookType,
  ].map((value) => value.trim()).where((value) => value.isNotEmpty);
  return values.isEmpty ? '未填写章节目标。' : values.take(2).join(' / ');
}

IconData _runIcon(ChapterGenerationStatus status) {
  return switch (status) {
    ChapterGenerationStatus.pending => Icons.schedule,
    ChapterGenerationStatus.running => Icons.sync,
    ChapterGenerationStatus.succeeded => Icons.check_circle_outline,
    ChapterGenerationStatus.failed => Icons.error_outline,
  };
}

Color _runColor(BuildContext context, ChapterGenerationStatus status) {
  final colorScheme = Theme.of(context).colorScheme;
  return switch (status) {
    ChapterGenerationStatus.pending => colorScheme.onSurfaceVariant,
    ChapterGenerationStatus.running => colorScheme.primary,
    ChapterGenerationStatus.succeeded => Colors.green,
    ChapterGenerationStatus.failed => colorScheme.error,
  };
}

String _runStatusLabel(ChapterGenerationStatus status) {
  return switch (status) {
    ChapterGenerationStatus.pending => '等待中',
    ChapterGenerationStatus.running => '运行中',
    ChapterGenerationStatus.succeeded => '成功',
    ChapterGenerationStatus.failed => '失败',
  };
}

String _runStageLabel(ChapterGenerationStage? stage) {
  return switch (stage) {
    ChapterGenerationStage.preparingContext => '准备上下文',
    ChapterGenerationStage.generatingDraft => '生成正文',
    ChapterGenerationStage.savingChapter => '保存正文',
    null => '未运行',
  };
}
