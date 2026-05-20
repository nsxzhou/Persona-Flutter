import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/glass_container.dart';
import '../../../core/ui/persona_page.dart';
import '../../../core/ui/skeleton_loader.dart';
import '../../plot_lab/application/plot_lab_providers.dart';
import '../../plot_lab/application/story_engine_normalizer.dart';
import '../../plot_lab/domain/plot_profile.dart';
import '../../projects/application/project_providers.dart';
import '../../projects/domain/writing_project.dart';
import '../../settings/application/provider_config_providers.dart';
import '../../settings/domain/provider_config.dart';
import '../../style_lab/application/style_lab_providers.dart';
import '../../style_lab/application/voice_profile_front_matter.dart';
import '../../style_lab/domain/style_profile.dart';
import '../application/novel_workshop_providers.dart';
import '../application/outline_detail_parser.dart';
import '../domain/novel_workshop.dart';
import '../domain/writing_context.dart';

class NovelWorkshopPage extends ConsumerStatefulWidget {
  const NovelWorkshopPage({required this.projectId, super.key});

  final String projectId;

  @override
  ConsumerState<NovelWorkshopPage> createState() => _NovelWorkshopPageState();
}

class NovelEditorPage extends ConsumerStatefulWidget {
  const NovelEditorPage({required this.projectId, super.key});

  final String projectId;

  @override
  ConsumerState<NovelEditorPage> createState() => _NovelEditorPageState();
}

class _NovelWorkshopPageState extends ConsumerState<NovelWorkshopPage> {
  @override
  Widget build(BuildContext context) {
    final project = ref.watch(writingProjectProvider(widget.projectId));
    final bible = ref.watch(projectBibleProvider(widget.projectId));
    final volumes = ref.watch(chapterVolumesProvider(widget.projectId));
    final plans = ref.watch(chapterPlansProvider(widget.projectId));
    final chapters = ref.watch(projectChaptersProvider(widget.projectId));
    final runs = ref.watch(chapterGenerationRunsProvider(widget.projectId));
    final memory = ref.watch(projectRuntimeMemoryProvider(widget.projectId));
    final assets = ref.watch(projectPromptAssetsProvider(widget.projectId));

    return project.when(
      data: (item) {
        if (item == null) {
          return _MissingProjectPage(projectId: widget.projectId);
        }
        if (item.status != ProjectStatus.active) {
          return _ArchivedProjectPage(project: item);
        }
        return bible.when(
          data: (bibleItem) => volumes.when(
            data: (volumeItems) => plans.when(
              data: (planItems) => chapters.when(
                data: (chapterItems) => runs.when(
                  data: (runItems) => _AssetWorkbenchPage(
                    project: item,
                    bible: bibleItem,
                    volumes: volumeItems,
                    plans: planItems,
                    chapters: chapterItems,
                    runs: runItems,
                    assets: assets,
                    memory: memory,
                    onCreatePlan: () => _showPlanDialog(
                      context: context,
                      projectId: item.id,
                      volumes: volumeItems,
                      nextIndex: _nextChapterIndex(planItems),
                    ),
                    onCreateVolume: () => _showVolumeDialog(
                      context: context,
                      projectId: item.id,
                      nextIndex: _nextVolumeIndex(volumeItems),
                    ),
                    onEditVolume: (volume) => _showVolumeDialog(
                      context: context,
                      projectId: item.id,
                      volume: volume,
                    ),
                    onEditPlan: (plan) => _showPlanDialog(
                      context: context,
                      projectId: item.id,
                      volumes: volumeItems,
                      plan: plan,
                    ),
                  ),
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
            ),
            error: (error, stackTrace) =>
                _WorkshopError(message: '无法加载分卷：$error'),
            loading: () => const _WorkshopLoading(),
          ),
          error: (error, stackTrace) =>
              _WorkshopError(message: '无法加载项目设定集：$error'),
          loading: () => const _WorkshopLoading(),
        );
      },
      error: (error, stackTrace) => _WorkshopError(message: '无法加载项目：$error'),
      loading: () => const _WorkshopLoading(),
    );
  }
}

class _NovelEditorPageState extends ConsumerState<NovelEditorPage> {
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
    final volumes = ref.watch(chapterVolumesProvider(widget.projectId));
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
        return volumes.when(
          data: (volumeItems) => plans.when(
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
                    volumes: volumeItems,
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
                      volumes: volumeItems,
                      nextIndex: _nextChapterIndex(planItems),
                    ),
                    onEditPlan: selectedPlan == null
                        ? null
                        : () => _showPlanDialog(
                            context: context,
                            projectId: item.id,
                            volumes: volumeItems,
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
          ),
          error: (error, stackTrace) =>
              _WorkshopError(message: '无法加载分卷：$error'),
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

class _AssetWorkbenchPage extends StatelessWidget {
  const _AssetWorkbenchPage({
    required this.project,
    required this.bible,
    required this.volumes,
    required this.plans,
    required this.chapters,
    required this.runs,
    required this.assets,
    required this.memory,
    required this.onCreatePlan,
    required this.onCreateVolume,
    required this.onEditVolume,
    required this.onEditPlan,
  });

  final WritingProject project;
  final ProjectBible bible;
  final List<ChapterVolume> volumes;
  final List<ChapterPlan> plans;
  final List<ProjectChapter> chapters;
  final List<ChapterGenerationRun> runs;
  final AsyncValue<ProjectPromptAssets> assets;
  final AsyncValue<ProjectRuntimeMemory> memory;
  final VoidCallback onCreatePlan;
  final VoidCallback onCreateVolume;
  final ValueChanged<ChapterVolume> onEditVolume;
  final ValueChanged<ChapterPlan> onEditPlan;

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: '项目工作台',
      title: project.title,
      description: '管理项目资产、写作参数和章节目标，然后进入编辑器完成正文创作。',
      maxWidth: 1420,
      actions: [
        OutlinedButton.icon(
          onPressed: () => context.go('/projects'),
          icon: const Icon(Icons.arrow_back_outlined),
          label: const Text('返回项目'),
        ),
        FilledButton.icon(
          onPressed: () =>
              context.go('/projects/${project.id}/workshop/editor'),
          icon: const Icon(Icons.edit_note_outlined),
          label: const Text('进入编辑器'),
        ),
      ],
      children: [
        _WorkbenchTabs(
          project: project,
          bible: bible,
          volumes: volumes,
          plans: plans,
          chapters: chapters,
          runs: runs,
          assets: assets,
          memory: memory,
          onCreatePlan: onCreatePlan,
          onCreateVolume: onCreateVolume,
          onEditVolume: onEditVolume,
          onEditPlan: onEditPlan,
        ),
      ],
    );
  }
}

class _WorkbenchTabs extends StatefulWidget {
  const _WorkbenchTabs({
    required this.project,
    required this.bible,
    required this.volumes,
    required this.plans,
    required this.chapters,
    required this.runs,
    required this.assets,
    required this.memory,
    required this.onCreatePlan,
    required this.onCreateVolume,
    required this.onEditVolume,
    required this.onEditPlan,
  });

  final WritingProject project;
  final ProjectBible bible;
  final List<ChapterVolume> volumes;
  final List<ChapterPlan> plans;
  final List<ProjectChapter> chapters;
  final List<ChapterGenerationRun> runs;
  final AsyncValue<ProjectPromptAssets> assets;
  final AsyncValue<ProjectRuntimeMemory> memory;
  final VoidCallback onCreatePlan;
  final VoidCallback onCreateVolume;
  final ValueChanged<ChapterVolume> onEditVolume;
  final ValueChanged<ChapterPlan> onEditPlan;

  @override
  State<_WorkbenchTabs> createState() => _WorkbenchTabsState();
}

class _WorkbenchTabsState extends State<_WorkbenchTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 10, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onSwitchTab(int index) {
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return PersonaPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: '概览'),
                  Tab(text: '世界观设定'),
                  Tab(text: '角色索引与关系网'),
                  Tab(text: '总纲'),
                  Tab(text: '分卷与章节细纲'),
                  Tab(text: 'Voice Profile'),
                  Tab(text: 'Story Engine'),
                  Tab(text: 'Runtime Memory'),
                  Tab(text: 'Prompt 栈'),
                  Tab(text: '设置'),
                ],
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : MediaQuery.of(context).size.height - 200;
              return SizedBox(
                height: availableHeight,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ProjectOverviewTab(
                      project: widget.project,
                      bible: widget.bible,
                      volumes: widget.volumes,
                      plans: widget.plans,
                      chapters: widget.chapters,
                      runs: widget.runs,
                      assets: widget.assets,
                      memory: widget.memory,
                      onSwitchTab: _onSwitchTab,
                    ),
                    _BibleMarkdownEditorTab(
                      title: '世界观设定',
                      description: '承载世界规则、地域组织、技术/魔法边界和不可破坏设定。',
                      bible: widget.bible,
                      field: _BibleField.worldBuilding,
                      emptyIcon: Icons.public_outlined,
                      emptyTitle: '暂无世界观设定',
                      emptyDescription: '补齐世界规则、地域组织和不可破坏设定后，章节生成会使用它作为硬上下文。',
                    ),
                    _BibleMarkdownEditorTab(
                      title: '角色索引与关系网',
                      description: '集中记录核心角色、人际关系、阵营和长期动机。',
                      bible: widget.bible,
                      field: _BibleField.charactersBlueprint,
                      emptyIcon: Icons.groups_2_outlined,
                      emptyTitle: '暂无角色索引',
                      emptyDescription: '补齐角色、关系和长期动机后，可减少章节生成时临时编造关系。',
                    ),
                    _BibleMarkdownEditorTab(
                      title: '总纲',
                      description: '故事主线、主题推进、卷间结构和结局约束。',
                      bible: widget.bible,
                      field: _BibleField.outlineMaster,
                      emptyIcon: Icons.route_outlined,
                      emptyTitle: '暂无总纲',
                      emptyDescription: '总纲用于约束分卷和章节细纲，不再展示剧情分析骨架大纲。',
                    ),
                    _ChapterPlanningTab(
                      volumes: widget.volumes,
                      plans: widget.plans,
                      chapters: widget.chapters,
                      runs: widget.runs,
                      outlineDetailYaml: widget.bible.outlineDetailYaml,
                      onCreatePlan: widget.onCreatePlan,
                      onCreateVolume: widget.onCreateVolume,
                      onEditVolume: widget.onEditVolume,
                      onEditPlan: widget.onEditPlan,
                    ),
                    _YamlMarkdownAssetTab(
                      title: 'Voice Profile',
                      description: 'YAML 元数据独立展示，正文只渲染 Markdown body。',
                      markdownAsync: widget.assets.whenData(
                        (a) => a.voiceProfileMarkdown,
                      ),
                      kind: _PromptDocumentKind.voiceProfile,
                      emptyIcon: Icons.record_voice_over_outlined,
                      emptyTitle: '暂无 Voice Profile',
                      emptyDescription: '请先在项目设置中绑定 Style Profile。',
                    ),
                    _YamlMarkdownAssetTab(
                      title: 'Story Engine',
                      description: 'YAML 元数据独立展示，剧情写作指南只渲染 Markdown body。',
                      markdownAsync: widget.assets.whenData(
                        (a) => a.storyEngineMarkdown,
                      ),
                      kind: _PromptDocumentKind.storyEngine,
                      emptyIcon: Icons.engineering_outlined,
                      emptyTitle: '暂无 Story Engine',
                      emptyDescription: '请先在项目设置中绑定 Plot Profile。',
                    ),
                    _RuntimeMemoryTab(
                      projectId: widget.project.id,
                      memory: widget.memory,
                    ),
                    _PromptStackTab(
                      assets: widget.assets,
                      bible: widget.bible,
                      memory: widget.memory,
                    ),
                    _WorkshopSettingsTab(
                      project: widget.project,
                      bible: widget.bible,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProjectOverviewTab extends StatelessWidget {
  const _ProjectOverviewTab({
    required this.project,
    required this.bible,
    required this.volumes,
    required this.plans,
    required this.chapters,
    required this.runs,
    required this.assets,
    required this.memory,
    required this.onSwitchTab,
  });

  final WritingProject project;
  final ProjectBible bible;
  final List<ChapterVolume> volumes;
  final List<ChapterPlan> plans;
  final List<ProjectChapter> chapters;
  final List<ChapterGenerationRun> runs;
  final AsyncValue<ProjectPromptAssets> assets;
  final AsyncValue<ProjectRuntimeMemory> memory;
  final ValueChanged<int> onSwitchTab;

  @override
  Widget build(BuildContext context) {
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
    final succeededRuns = runs
        .where((r) => r.status == ChapterGenerationStatus.succeeded)
        .length;
    final bibleEmpty = _projectBibleIsEmpty(bible);
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Top: project description ---
          Text(
            '项目简介',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            bible.descriptionMarkdown.trim().isEmpty
                ? '暂无简介'
                : bible.descriptionMarkdown,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),

          // --- Section 1: metric cards ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 180,
                  child: _TappableMetric(
                    label: '设定集完成度',
                    value: bibleEmpty ? '未配置' : _bibleCompletenessLabel(bible),
                    detail: '世界观 · 角色 · 总纲',
                    onTap: () => onSwitchTab(1),
                  ),
                ),
                const SizedBox(width: 14),
                SizedBox(
                  width: 160,
                  child: _TappableMetric(
                    label: '分卷',
                    value: '${volumes.length}',
                    detail: '${volumes.length} 卷已创建',
                    onTap: () => onSwitchTab(4),
                  ),
                ),
                const SizedBox(width: 14),
                SizedBox(
                  width: 160,
                  child: _TappableMetric(
                    label: '章节细纲',
                    value: '${plans.length}',
                    detail: '${plans.length} 个章节计划',
                    onTap: () => onSwitchTab(4),
                  ),
                ),
                const SizedBox(width: 14),
                SizedBox(
                  width: 160,
                  child: _TappableMetric(
                    label: '正文',
                    value: '$completed/${plans.length}',
                    detail: completed > 0 ? '$completed 个已完成' : '开始写作以生成正文',
                    onTap: () => onSwitchTab(4),
                  ),
                ),
                const SizedBox(width: 14),
                SizedBox(
                  width: 160,
                  child: _TappableMetric(
                    label: '生成任务',
                    value: '${runs.length}',
                    detail: '$succeededRuns 个成功',
                    onTap: () => onSwitchTab(7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- Section 2: Prompt assets panel ---
          PersonaPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PersonaSectionHeader(
                  title: 'Prompt 资产',
                  description: 'Voice Profile & Story Engine 接入状态',
                ),
                const SizedBox(height: 12),
                assets.when(
                  data: (item) => _PromptAssetStatusStrip(assets: item),
                  error: (error, stackTrace) => Text('无法加载 Prompt 资产：$error'),
                  loading: () => const SkeletonBox(width: 260, height: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // --- Section 3: Runtime memory panel ---
          PersonaPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PersonaSectionHeader(
                  title: '运行时记忆',
                  description: '角色状态、剧情线、故事摘要',
                ),
                const SizedBox(height: 12),
                memory.when(
                  data: (item) => item.state.isEmpty
                      ? const PersonaEmptyStateCard(
                          icon: Icons.memory_outlined,
                          title: '暂无运行时记忆',
                          description: '完成正文生成后将自动创建',
                        )
                      : _RuntimeMemoryGrid(memory: item.state),
                  error: (error, stackTrace) => Text('无法加载运行时记忆：$error'),
                  loading: () => const SkeletonBox(width: 220, height: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TappableMetric extends StatelessWidget {
  const _TappableMetric({
    required this.label,
    required this.value,
    required this.detail,
    required this.onTap,
  });

  final String label;
  final String value;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: PersonaMetric(label: label, value: value, detail: detail),
      ),
    );
  }
}

enum _BibleField { worldBuilding, charactersBlueprint, outlineMaster }

class _BibleMarkdownEditorTab extends ConsumerStatefulWidget {
  const _BibleMarkdownEditorTab({
    required this.title,
    required this.description,
    required this.bible,
    required this.field,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyDescription,
  });

  final String title;
  final String description;
  final ProjectBible bible;
  final _BibleField field;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyDescription;

  @override
  ConsumerState<_BibleMarkdownEditorTab> createState() =>
      _BibleMarkdownEditorTabState();
}

class _BibleMarkdownEditorTabState
    extends ConsumerState<_BibleMarkdownEditorTab> {
  late final TextEditingController _controller;
  late String _loadedMarkdown;
  bool _editing = false;

  String get _currentMarkdown => _markdownFor(widget.bible, widget.field);

  bool get _isDirty => _controller.text != _loadedMarkdown;

  @override
  void initState() {
    super.initState();
    _loadedMarkdown = _currentMarkdown;
    _controller = TextEditingController(text: _loadedMarkdown);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(_BibleMarkdownEditorTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextMarkdown = _currentMarkdown;
    if (oldWidget.bible.updatedAt == widget.bible.updatedAt &&
        oldWidget.field == widget.field) {
      return;
    }
    if (_isDirty) {
      return;
    }
    _loadedMarkdown = nextMarkdown;
    _controller.text = nextMarkdown;
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = _loadedMarkdown.trim();
    final state = ref.watch(novelWorkshopControllerProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (_editing) ...[
                TextButton(
                  onPressed: state.isLoading ? null : _cancelEditing,
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  key: ValueKey('save-bible-${widget.field.name}'),
                  onPressed: state.isLoading || !_isDirty ? null : _save,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('保存'),
                ),
              ] else if (trimmed.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () => setState(() => _editing = true),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('编辑'),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (_editing)
            TextField(
              key: ValueKey('edit-bible-${widget.field.name}'),
              controller: _controller,
              minLines: 16,
              maxLines: 28,
              decoration: InputDecoration(
                labelText: widget.title,
                alignLabelWithHint: true,
                hintText: '使用 Markdown 记录${widget.title}。',
              ),
            )
          else if (trimmed.isEmpty)
            PersonaEmptyStateCard(
              icon: widget.emptyIcon,
              title: widget.emptyTitle,
              description: widget.emptyDescription,
              action: OutlinedButton.icon(
                onPressed: () => setState(() => _editing = true),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('开始编辑'),
              ),
            )
          else
            _MarkdownSurface(markdown: trimmed),
        ],
      ),
    );
  }

  Future<void> _save() async {
    try {
      final saved = await ref
          .read(novelWorkshopControllerProvider.notifier)
          .saveProjectBible(
            _inputFor(widget.bible, widget.field, _controller.text),
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _loadedMarkdown = _markdownFor(saved, widget.field);
        _controller.text = _loadedMarkdown;
        _editing = false;
      });
      if (Scaffold.maybeOf(context) != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${widget.title}已保存。')));
      }
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      if (Scaffold.maybeOf(context) != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败：$error')));
      }
    }
  }

  void _cancelEditing() {
    setState(() {
      _controller.text = _loadedMarkdown;
      _editing = false;
    });
  }
}

enum _PromptDocumentKind { voiceProfile, storyEngine }

class _YamlMarkdownAssetTab extends StatelessWidget {
  const _YamlMarkdownAssetTab({
    required this.title,
    required this.description,
    required this.markdownAsync,
    required this.kind,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyDescription,
  });

  final String title;
  final String description;
  final AsyncValue<String> markdownAsync;
  final _PromptDocumentKind kind;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyDescription;

  @override
  Widget build(BuildContext context) {
    return markdownAsync.when(
      data: (markdown) {
        final trimmed = markdown.trim();
        if (trimmed.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: PersonaEmptyStateCard(
              icon: emptyIcon,
              title: emptyTitle,
              description: emptyDescription,
            ),
          );
        }
        final parsed = _parsePromptDocument(kind, trimmed);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              if (parsed.error == null) ...[
                _MetadataSummary(fields: parsed.fields),
                const SizedBox(height: 14),
                _MarkdownSurface(markdown: parsed.bodyMarkdown),
              ] else ...[
                _FormatErrorPanel(message: parsed.error!, source: trimmed),
              ],
            ],
          ),
        );
      },
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.all(20),
        child: Text('加载失败：$error'),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _RuntimeMemoryTab extends ConsumerStatefulWidget {
  const _RuntimeMemoryTab({
    required this.projectId,
    required this.memory,
  });

  final String projectId;
  final AsyncValue<ProjectRuntimeMemory> memory;

  @override
  ConsumerState<_RuntimeMemoryTab> createState() => _RuntimeMemoryTabState();
}

class _RuntimeMemoryTabState extends ConsumerState<_RuntimeMemoryTab> {
  bool _editing = false;
  late TextEditingController _charactersCtrl;
  late TextEditingController _runtimeStateCtrl;
  late TextEditingController _threadsCtrl;
  late TextEditingController _summaryCtrl;

  @override
  void initState() {
    super.initState();
    _charactersCtrl = TextEditingController();
    _runtimeStateCtrl = TextEditingController();
    _threadsCtrl = TextEditingController();
    _summaryCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _charactersCtrl.dispose();
    _runtimeStateCtrl.dispose();
    _threadsCtrl.dispose();
    _summaryCtrl.dispose();
    super.dispose();
  }

  void _startEditing(RuntimeMemoryState state) {
    _charactersCtrl.text = state.charactersStatus;
    _runtimeStateCtrl.text = state.runtimeState;
    _threadsCtrl.text = state.runtimeThreads;
    _summaryCtrl.text = state.storySummary;
    setState(() => _editing = true);
  }

  void _cancelEditing() {
    setState(() => _editing = false);
  }

  Future<void> _save() async {
    try {
      await ref
          .read(novelWorkshopControllerProvider.notifier)
          .saveRuntimeMemory(
            projectId: widget.projectId,
            memoryState: RuntimeMemoryState(
              charactersStatus: _charactersCtrl.text,
              runtimeState: _runtimeStateCtrl.text,
              runtimeThreads: _threadsCtrl.text,
              storySummary: _summaryCtrl.text,
            ),
          );
      if (!mounted) return;
      setState(() => _editing = false);
      if (Scaffold.maybeOf(context) != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('运行时记忆已保存。')));
      }
    } on Object catch (error) {
      if (!mounted) return;
      if (Scaffold.maybeOf(context) != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败：$error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final controllerState = ref.watch(novelWorkshopControllerProvider);

    return widget.memory.when(
      data: (item) {
        final isEmpty = item.state.isEmpty && !_editing;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '创作过程中持续追踪的角色状态、运行状态、剧情线索和故事摘要。',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (_editing) ...[
                    TextButton(
                      onPressed:
                          controllerState.isLoading ? null : _cancelEditing,
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: controllerState.isLoading ? null : _save,
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: const Text('保存'),
                    ),
                  ] else
                    OutlinedButton.icon(
                      onPressed: () => _startEditing(item.state),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(isEmpty ? '开始编辑' : '编辑'),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (isEmpty)
                _buildEmptyState(context, colorScheme, textTheme)
              else if (_editing)
                _buildEditForm(context, colorScheme, textTheme)
              else
                _RuntimeMemoryGrid(memory: item.state),
            ],
          ),
        );
      },
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.all(20),
        child: Text('无法加载运行时记忆：$error'),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration: layered memory icon
            SizedBox(
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background glow
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colorScheme.primary.withValues(alpha: 0.12),
                          colorScheme.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                  // Outer ring
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                  ),
                  // Inner icon
                  Icon(
                    Icons.auto_stories_outlined,
                    size: 40,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '运行时记忆尚未建立',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '随着章节生成和故事推进，系统会自动追踪并累积以下维度的记忆。你也可以手动编辑来维护它们。',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            // Category preview cards
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 440;
                final cards = [
                  _CategoryPreview(
                    icon: Icons.people_outline,
                    label: '角色状态',
                    description: '活跃角色的即时变化',
                    color: Colors.blue,
                  ),
                  _CategoryPreview(
                    icon: Icons.play_circle_outline,
                    label: '运行状态',
                    description: '故事推进中的状态',
                    color: Colors.green,
                  ),
                  _CategoryPreview(
                    icon: Icons.timeline_outlined,
                    label: '剧情线索',
                    description: '未解决的伏笔与暗线',
                    color: Colors.amber,
                  ),
                  _CategoryPreview(
                    icon: Icons.menu_book_outlined,
                    label: '故事摘要',
                    description: '整体故事脉络',
                    color: Colors.purple,
                  ),
                ];
                if (wide) {
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final card in cards)
                        SizedBox(
                          width: (constraints.maxWidth - 10) / 2,
                          child: card,
                        ),
                    ],
                  );
                }
                return Column(children: cards);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      children: [
        _MemoryEditField(
          controller: _charactersCtrl,
          icon: Icons.people_outline,
          label: '角色状态',
          description: '当前活跃角色的状态变化',
          accentColor: Colors.blue,
        ),
        _MemoryEditField(
          controller: _runtimeStateCtrl,
          icon: Icons.play_circle_outline,
          label: '运行状态',
          description: '故事推进中的即时状态',
          accentColor: Colors.green,
        ),
        _MemoryEditField(
          controller: _threadsCtrl,
          icon: Icons.timeline_outlined,
          label: '剧情线索',
          description: '未解决的伏笔和进行中的线索',
          accentColor: Colors.amber,
        ),
        _MemoryEditField(
          controller: _summaryCtrl,
          icon: Icons.menu_book_outlined,
          label: '故事摘要',
          description: '截至目前的整体故事脉络',
          accentColor: Colors.purple,
        ),
      ],
    );
  }
}

class _PromptStackTab extends StatelessWidget {
  const _PromptStackTab({
    required this.assets,
    required this.bible,
    required this.memory,
  });

  final AsyncValue<ProjectPromptAssets> assets;
  final ProjectBible bible;
  final AsyncValue<ProjectRuntimeMemory> memory;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '章节生成会组合项目设定集、章节细纲、Voice Profile、Story Engine 和 Runtime Memory。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _AssetDetailTile(
            title: '项目设定集',
            bound: true,
            ready: !_projectBibleIsEmpty(bible),
            detail: _projectBibleIsEmpty(bible) ? '尚未填写项目设定' : '已接入生成上下文',
          ),
          assets.when(
            data: (asset) => Column(
              children: [
                _AssetDetailTile(
                  title: 'Voice Profile',
                  bound: true,
                  ready: asset.voiceProfileMarkdown.trim().isNotEmpty,
                  detail: asset.voiceProfileMarkdown.trim().isEmpty
                      ? '未绑定 Style Profile'
                      : '已接入风格约束',
                ),
                _AssetDetailTile(
                  title: 'Story Engine',
                  bound: true,
                  ready: asset.storyEngineMarkdown.trim().isNotEmpty,
                  detail: asset.storyEngineMarkdown.trim().isEmpty
                      ? '未绑定 Plot Profile'
                      : '已接入叙事引擎',
                ),
                if (asset.warnings.isNotEmpty)
                  _WarningList(warnings: asset.warnings),
              ],
            ),
            error: (error, stackTrace) => Text('无法加载 Prompt 资产：$error'),
            loading: () => const SkeletonBox(width: 260, height: 16),
          ),
          memory.when(
            data: (item) => _AssetDetailTile(
              title: 'Runtime Memory',
              bound: true,
              ready: true,
              detail: item.state.isEmpty ? '暂无运行时记忆，生成时会自动跳过' : '已接入运行状态',
              neutralWhenReady: item.state.isEmpty,
            ),
            error: (error, stackTrace) => Text('无法加载 Runtime Memory：$error'),
            loading: () => const SkeletonBox(width: 220, height: 16),
          ),
        ],
      ),
    );
  }
}

class _WorkshopSettingsTab extends ConsumerStatefulWidget {
  const _WorkshopSettingsTab({required this.project, required this.bible});

  final WritingProject project;
  final ProjectBible bible;

  @override
  ConsumerState<_WorkshopSettingsTab> createState() =>
      _WorkshopSettingsTabState();
}

class _WorkshopSettingsTabState extends ConsumerState<_WorkshopSettingsTab> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _languageController;
  late final TextEditingController _targetLengthController;
  late final TextEditingController _perspectiveController;
  late ProjectStatus _status;
  String? _selectedProviderId;
  String? _selectedModelName;
  String? _selectedStyleProfileId;
  String? _selectedPlotProfileId;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _titleController = TextEditingController(text: p.title);
    _descriptionController = TextEditingController(text: p.description);
    _languageController = TextEditingController(text: p.language);
    _targetLengthController = TextEditingController(
      text: p.targetLength.toString(),
    );
    _perspectiveController = TextEditingController(
      text: p.narrativePerspective,
    );
    _status = p.status;
    _selectedProviderId = p.defaultProviderId;
    _selectedModelName = p.defaultModelName;
    _selectedStyleProfileId = p.styleProfileId;
    _selectedPlotProfileId = p.plotProfileId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _languageController.dispose();
    _targetLengthController.dispose();
    _perspectiveController.dispose();
    super.dispose();
  }

  void _syncSelections(
    List<ProviderConfig> providers,
    List<StyleProfile> styleProfiles,
    List<PlotProfile> plotProfiles,
  ) {
    if (_initialized) return;
    _initialized = true;
    if (_selectedProviderId != null &&
        providers.every((p) => p.id != _selectedProviderId)) {
      _selectedProviderId = null;
      _selectedModelName = null;
    }
    if (_selectedStyleProfileId != null &&
        styleProfiles.every((p) => p.id != _selectedStyleProfileId)) {
      _selectedStyleProfileId = null;
    }
    if (_selectedPlotProfileId != null &&
        plotProfiles.every((p) => p.id != _selectedPlotProfileId)) {
      _selectedPlotProfileId = null;
    }
  }

  ProviderConfig? _findProvider(List<ProviderConfig> providers) {
    for (final p in providers) {
      if (p.id == _selectedProviderId) return p;
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final input = WritingProjectInput(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _status,
      defaultProviderId: _selectedProviderId ?? '',
      defaultModelName: _selectedModelName ?? '',
      styleProfileId: _selectedStyleProfileId,
      plotProfileId: _selectedPlotProfileId,
      language: _languageController.text.trim(),
      targetLength: int.tryParse(_targetLengthController.text.trim()) ?? 0,
      narrativePerspective: _perspectiveController.text.trim(),
    );
    await ref
        .read(projectControllerProvider.notifier)
        .save(id: widget.project.id, input: input);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('设置已保存')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectControllerProvider);
    final providers = ref.watch(providerConfigsProvider);
    final styleProfiles = ref.watch(styleProfilesProvider);
    final plotProfiles = ref.watch(plotProfilesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(projectControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败：${next.error}')));
      }
    });

    return providers.when(
      data: (providerItems) => styleProfiles.when(
        data: (styleItems) => plotProfiles.when(
          data: (plotItems) {
            _syncSelections(providerItems, styleItems, plotItems);
            final selectedProvider = _findProvider(providerItems);
            final selectedModelName = selectedProvider == null
                ? null
                : _selectedModelName;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '修改项目配置和写作参数，保存后立即生效。',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: '项目标题',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? '必填' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: '简介 / 一句话概念',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 3,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 20),
                    Text('创作配置', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedProviderId,
                      items: [
                        for (final p in providerItems)
                          DropdownMenuItem(
                            value: p.id,
                            child: Text(
                              '${p.name} · ${p.defaultModel}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: providerItems.isEmpty
                          ? null
                          : (v) {
                              if (v != null) {
                                setState(() {
                                  _selectedProviderId = v;
                                  _selectedModelName = null;
                                });
                              }
                            },
                      decoration: const InputDecoration(
                        labelText: '默认 Provider',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedModelName,
                      items: [
                        for (final name
                            in selectedProvider?.modelNames ?? const <String>[])
                          DropdownMenuItem(
                            value: name,
                            child: Text(name, overflow: TextOverflow.ellipsis),
                          ),
                      ],
                      onChanged: selectedProvider == null
                          ? null
                          : (v) {
                              if (v != null) {
                                setState(() => _selectedModelName = v);
                              }
                            },
                      decoration: const InputDecoration(
                        labelText: '默认模型',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      initialValue: _selectedStyleProfileId,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('不挂载 Style Profile'),
                        ),
                        for (final p in styleItems)
                          DropdownMenuItem<String?>(
                            value: p.id,
                            child: Text(
                              p.styleName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (v) =>
                          setState(() => _selectedStyleProfileId = v),
                      decoration: const InputDecoration(
                        labelText: 'Style Profile（可选）',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      initialValue: _selectedPlotProfileId,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('不挂载 Plot Profile'),
                        ),
                        for (final p in plotItems)
                          DropdownMenuItem<String?>(
                            value: p.id,
                            child: Text(
                              p.plotName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (v) =>
                          setState(() => _selectedPlotProfileId = v),
                      decoration: const InputDecoration(
                        labelText: 'Plot Profile（可选）',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('写作参数', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _languageController,
                            decoration: const InputDecoration(
                              labelText: '语言',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _targetLengthController,
                            decoration: const InputDecoration(
                              labelText: '目标长度',
                              suffixText: '字',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _perspectiveController,
                      decoration: const InputDecoration(
                        labelText: '叙事视角',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('项目状态', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    RadioGroup<ProjectStatus>(
                      groupValue: _status,
                      onChanged: (v) {
                        if (v != null) setState(() => _status = v);
                      },
                      child: Column(
                        children: [
                          RadioListTile<ProjectStatus>(
                            title: const Text('活动项目'),
                            subtitle: const Text('显示在默认 Projects 工作区。'),
                            value: ProjectStatus.active,
                          ),
                          RadioListTile<ProjectStatus>(
                            title: const Text('归档项目'),
                            subtitle: const Text('从默认工作区隐藏，但保留项目档案。'),
                            value: ProjectStatus.archived,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoLine(
                      label: '项目设定集更新时间',
                      value: _dateLabel(widget.bible.updatedAt),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: state.isLoading ? null : _save,
                        icon: const Icon(Icons.save_outlined, size: 18),
                        label: Text(state.isLoading ? '保存中' : '保存'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('无法加载 Plot Profiles：$e'),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('无法加载 Style Profiles：$e'),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('无法加载 Providers：$e'),
    );
  }
}

class _MarkdownSurface extends StatelessWidget {
  const _MarkdownSurface({required this.markdown});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: MarkdownBody(data: markdown),
      ),
    );
  }
}

class _MetadataSummary extends StatelessWidget {
  const _MetadataSummary({required this.fields});

  final Map<String, Object?> fields;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    for (final key in ['name', 'tags', 'intensity', 'tone', 'plot_summary']) {
      if (!fields.containsKey(key)) {
        continue;
      }
      chips.add(
        Chip(
          label: Text('$key: ${_metadataValue(fields[key])}'),
          visualDensity: VisualDensity.compact,
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(spacing: 8, runSpacing: 8, children: chips),
      ),
    );
  }
}

class _FormatErrorPanel extends StatelessWidget {
  const _FormatErrorPanel({required this.message, required this.source});

  final String message;
  final String source;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '格式错误：$message',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: colorScheme.error),
            ),
            const SizedBox(height: 12),
            SelectableText(
              source,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterPlanningTab extends StatelessWidget {
  const _ChapterPlanningTab({
    required this.volumes,
    required this.plans,
    required this.chapters,
    required this.runs,
    required this.outlineDetailYaml,
    required this.onCreatePlan,
    required this.onCreateVolume,
    required this.onEditVolume,
    required this.onEditPlan,
  });

  final List<ChapterVolume> volumes;
  final List<ChapterPlan> plans;
  final List<ProjectChapter> chapters;
  final List<ChapterGenerationRun> runs;
  final String outlineDetailYaml;
  final VoidCallback onCreatePlan;
  final VoidCallback onCreateVolume;
  final ValueChanged<ChapterVolume> onEditVolume;
  final ValueChanged<ChapterPlan> onEditPlan;

  @override
  Widget build(BuildContext context) {
    final completedChapterCount = plans
        .where(
          (plan) => chapters.any(
            (chapter) =>
                chapter.chapterPlanId == plan.id &&
                chapter.contentMarkdown.trim().isNotEmpty,
          ),
        )
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChapterPlanningToolbar(
          volumeCount: volumes.length,
          planCount: plans.length,
          completedChapterCount: completedChapterCount,
          hasVolumes: volumes.isNotEmpty,
          onCreateVolume: onCreateVolume,
          onCreatePlan: onCreatePlan,
        ),
        const Divider(height: 1),
        if (volumes.isEmpty)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final minHeight = (constraints.maxHeight - 48).clamp(
                  0.0,
                  double.infinity,
                );
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: minHeight),
                    child: Center(
                      child: _ChapterPlanningEmptyState(
                        onCreateVolume: onCreateVolume,
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        else
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
              children: [
                if (outlineDetailYaml.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _OutlineYamlStatus(yaml: outlineDetailYaml),
                  ),
                for (final volume in volumes)
                  _VolumePlanSection(
                    volume: volume,
                    plans: plans
                        .where((plan) => plan.volumeId == volume.id)
                        .toList(growable: false),
                    chapters: chapters,
                    runs: runs,
                    onEditVolume: () => onEditVolume(volume),
                    onCreatePlan: onCreatePlan,
                    onEditPlan: onEditPlan,
                  ),
                for (final plan in plans.where(
                  (plan) =>
                      !volumes.any((volume) => volume.id == plan.volumeId),
                ))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _WorkbenchChapterTile(
                      plan: plan,
                      chapter: _chapterForPlan(chapters, plan.id),
                      run: _latestRunForPlan(runs, plan.id),
                      onEdit: () => onEditPlan(plan),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ChapterPlanningToolbar extends StatelessWidget {
  const _ChapterPlanningToolbar({
    required this.volumeCount,
    required this.planCount,
    required this.completedChapterCount,
    required this.hasVolumes,
    required this.onCreateVolume,
    required this.onCreatePlan,
  });

  final int volumeCount;
  final int planCount;
  final int completedChapterCount;
  final bool hasVolumes;
  final VoidCallback onCreateVolume;
  final VoidCallback onCreatePlan;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 820;
          final summary = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PlanningMetricPill(label: '分卷', value: '$volumeCount'),
              _PlanningMetricPill(label: '章节目标', value: '$planCount'),
              _PlanningMetricPill(
                label: '已成文',
                value: '$completedChapterCount',
              ),
            ],
          );
          final actions = Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: hasVolumes
                ? [
                    OutlinedButton.icon(
                      onPressed: onCreateVolume,
                      icon: const Icon(Icons.view_agenda_outlined, size: 18),
                      label: const Text('新建分卷'),
                    ),
                    FilledButton.icon(
                      onPressed: onCreatePlan,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('新建章节'),
                    ),
                  ]
                : [
                    FilledButton.icon(
                      onPressed: onCreateVolume,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('新建分卷'),
                    ),
                  ],
          );

          final header = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('分卷与章节细纲', style: textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                '按分卷组织章节目标，正文创作前先把推进顺序和关键转折定清楚。',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              summary,
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [header, const SizedBox(height: 12), actions],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: header),
              const SizedBox(width: 20),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _PlanningMetricPill extends StatelessWidget {
  const _PlanningMetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(kButtonRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _ChapterPlanningEmptyState extends StatelessWidget {
  const _ChapterPlanningEmptyState({required this.onCreateVolume});

  final VoidCallback onCreateVolume;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 620),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(kPanelRadius),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 26, 28, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.22),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.view_agenda_outlined,
                    color: colorScheme.primary,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('暂无分卷', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                '章节细纲必须归属分卷。先创建第一卷，再为它添加章节目标。',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: const [
                  _PlanningStepPill(index: '1', label: '创建分卷'),
                  _PlanningStepPill(index: '2', label: '添加章节目标'),
                  _PlanningStepPill(index: '3', label: '进入编辑器写正文'),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onCreateVolume,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('新建分卷'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanningStepPill extends StatelessWidget {
  const _PlanningStepPill({required this.index, required this.label});

  final String index;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(kButtonRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Text(
                  index,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(width: 7),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _OutlineYamlStatus extends StatelessWidget {
  const _OutlineYamlStatus({required this.yaml});

  final String yaml;

  @override
  Widget build(BuildContext context) {
    try {
      final document = const OutlineDetailParser().parse(yaml);
      return PersonaStatusPill(
        label:
            'YAML 有效 · ${document.volumes.length} 卷 / ${document.chapters.length} 章',
        icon: Icons.verified_outlined,
        color: const Color(0xFF16825D),
      );
    } on Object catch (error) {
      return PersonaStatusPill(
        label: 'YAML 异常：$error',
        icon: Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
      );
    }
  }
}

class _VolumePlanSection extends StatelessWidget {
  const _VolumePlanSection({
    required this.volume,
    required this.plans,
    required this.chapters,
    required this.runs,
    required this.onEditVolume,
    required this.onCreatePlan,
    required this.onEditPlan,
  });

  final ChapterVolume volume;
  final List<ChapterPlan> plans;
  final List<ProjectChapter> chapters;
  final List<ChapterGenerationRun> runs;
  final VoidCallback onEditVolume;
  final VoidCallback onCreatePlan;
  final ValueChanged<ChapterPlan> onEditPlan;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final completedCount = plans
        .where(
          (plan) => chapters.any(
            (chapter) =>
                chapter.chapterPlanId == plan.id &&
                chapter.contentMarkdown.trim().isNotEmpty,
          ),
        )
        .length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(kPanelRadius),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '第 ${volume.volumeIndex} 卷 · ${volume.title}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${plans.length} 个章节目标 · $completedCount 个已成文',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: '编辑分卷',
                    onPressed: onEditVolume,
                    icon: const Icon(Icons.tune_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (plans.isEmpty)
                _EmptyVolumeNotice(onCreatePlan: onCreatePlan)
              else
                Column(
                  children: [
                    for (final plan in plans) ...[
                      _WorkbenchChapterTile(
                        plan: plan,
                        chapter: _chapterForPlan(chapters, plan.id),
                        run: _latestRunForPlan(runs, plan.id),
                        onEdit: () => onEditPlan(plan),
                      ),
                      if (plan != plans.last) const SizedBox(height: 8),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyVolumeNotice extends StatelessWidget {
  const _EmptyVolumeNotice({required this.onCreatePlan});

  final VoidCallback onCreatePlan;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(kButtonRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 420;
            final message = Row(
              children: [
                Icon(
                  Icons.note_add_outlined,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '该分卷暂无章节细纲。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            );
            final action = OutlinedButton.icon(
              onPressed: onCreatePlan,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('新建章节'),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [message, const SizedBox(height: 10), action],
              );
            }

            return Row(
              children: [
                Expanded(child: message),
                const SizedBox(width: 10),
                action,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AssetDetailTile extends StatelessWidget {
  const _AssetDetailTile({
    required this.title,
    required this.bound,
    required this.ready,
    required this.detail,
    this.neutralWhenReady = false,
  });

  final String title;
  final bool bound;
  final bool ready;
  final String detail;
  final bool neutralWhenReady;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = ready
        ? neutralWhenReady
              ? colorScheme.onSurfaceVariant
              : colorScheme.primary
        : bound
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                ready
                    ? neutralWhenReady
                          ? Icons.radio_button_unchecked
                          : Icons.check_circle_outline
                    : Icons.warning_amber_outlined,
                color: statusColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 3),
                    Text(detail, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Text(
                ready
                    ? neutralWhenReady
                          ? '可选'
                          : '已接入'
                    : '待完善',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromptAssetStatusStrip extends StatelessWidget {
  const _PromptAssetStatusStrip({required this.assets});

  final ProjectPromptAssets assets;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        PersonaStatusPill(
          label: assets.voiceProfileMarkdown.trim().isEmpty
              ? 'Voice Profile 缺失'
              : 'Voice Profile 已接入',
          icon: assets.voiceProfileMarkdown.trim().isEmpty
              ? Icons.warning_amber_outlined
              : Icons.check_circle_outline,
        ),
        PersonaStatusPill(
          label: assets.storyEngineMarkdown.trim().isEmpty
              ? 'Story Engine 缺失'
              : 'Story Engine 已接入',
          icon: assets.storyEngineMarkdown.trim().isEmpty
              ? Icons.warning_amber_outlined
              : Icons.check_circle_outline,
        ),
      ],
    );
  }
}

class _RuntimeMemoryGrid extends StatelessWidget {
  const _RuntimeMemoryGrid({required this.memory});

  final RuntimeMemoryState memory;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final children = [
          _MemoryBlock(
            icon: Icons.people_outline,
            title: '角色状态',
            description: '当前活跃角色的状态变化',
            value: memory.charactersStatus,
            accentColor: Colors.blue,
          ),
          _MemoryBlock(
            icon: Icons.play_circle_outline,
            title: '运行状态',
            description: '故事推进中的即时状态',
            value: memory.runtimeState,
            accentColor: Colors.green,
          ),
          _MemoryBlock(
            icon: Icons.timeline_outlined,
            title: '剧情线索',
            description: '未解决的伏笔和进行中的线索',
            value: memory.runtimeThreads,
            accentColor: Colors.amber,
          ),
          _MemoryBlock(
            icon: Icons.menu_book_outlined,
            title: '故事摘要',
            description: '截至目前的整体故事脉络',
            value: memory.storySummary,
            accentColor: Colors.purple,
          ),
        ];
        if (!wide) {
          return Column(children: children);
        }
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final child in children)
              SizedBox(width: (constraints.maxWidth - 12) / 2, child: child),
          ],
        );
      },
    );
  }
}

class _MemoryBlock extends StatelessWidget {
  const _MemoryBlock({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.accentColor,
  });

  final IconData icon;
  final String title;
  final String description;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final text = value.trim();
    final isEmpty = text.isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(10),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Colored left accent bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(icon, size: 20, color: accentColor),
                          const SizedBox(width: 8),
                          Text(
                            title,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isEmpty ? '未记录' : text,
                        style: textTheme.bodyMedium?.copyWith(
                          color: isEmpty
                              ? colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.6,
                                )
                              : null,
                          fontStyle: isEmpty ? FontStyle.italic : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryPreview extends StatelessWidget {
  const _CategoryPreview({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryEditField extends StatelessWidget {
  const _MemoryEditField({
    required this.controller,
    required this.icon,
    required this.label,
    required this.description,
    required this.accentColor,
  });

  final TextEditingController controller;
  final IconData icon;
  final String label;
  final String description;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                description,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            minLines: 3,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: '记录$label...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningList extends StatelessWidget {
  const _WarningList({required this.warnings});

  final List<String> warnings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Warnings', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          for (final warning in warnings)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('- $warning'),
            ),
        ],
      ),
    );
  }
}

class _WorkbenchChapterTile extends StatelessWidget {
  const _WorkbenchChapterTile({
    required this.plan,
    required this.chapter,
    required this.run,
    required this.onEdit,
  });

  final ChapterPlan plan;
  final ProjectChapter? chapter;
  final ChapterGenerationRun? run;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final hasContent = chapter?.contentMarkdown.trim().isNotEmpty ?? false;
    final running =
        run?.status == ChapterGenerationStatus.pending ||
        run?.status == ChapterGenerationStatus.running;
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = running
        ? colorScheme.primary
        : hasContent
        ? const Color(0xFF16825D)
        : colorScheme.onSurfaceVariant;
    final statusIcon = running
        ? Icons.sync
        : hasContent
        ? Icons.check_circle_outline
        : Icons.radio_button_unchecked;
    final statusLabel = running
        ? '生成中'
        : hasContent
        ? '已成文'
        : '待撰写';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(kButtonRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 560;
            final statusMark = DecoratedBox(
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(statusIcon, size: 18, color: statusColor),
              ),
            );
            final content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '第 ${plan.chapterIndex} 章 · ${_chapterTitle(plan)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      statusLabel,
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(color: statusColor),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _objectiveSummary(plan.objectiveCard),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
            final action = OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.tune_outlined, size: 16),
              label: const Text('编辑目标'),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      statusMark,
                      const SizedBox(width: 12),
                      Expanded(child: content),
                    ],
                  ),
                  const SizedBox(height: 10),
                  action,
                ],
              );
            }

            return Row(
              children: [
                statusMark,
                const SizedBox(width: 12),
                Expanded(child: content),
                const SizedBox(width: 10),
                action,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WorkshopScaffold extends StatefulWidget {
  const _WorkshopScaffold({
    required this.project,
    required this.volumes,
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
  final List<ChapterVolume> volumes;
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
  State<_WorkshopScaffold> createState() => _WorkshopScaffoldState();
}

class _WorkshopScaffoldState extends State<_WorkshopScaffold> {
  bool _showNavigator = true;
  bool _showInspector = false;

  void _toggleNavigator() => setState(() => _showNavigator = !_showNavigator);
  void _toggleInspector() => setState(() => _showInspector = !_showInspector);

  @override
  Widget build(BuildContext context) {
    final selectedRunning =
        widget.selectedRun?.status == ChapterGenerationStatus.pending ||
        widget.selectedRun?.status == ChapterGenerationStatus.running;
    return Material(
      color: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1120;
          final isMedium = constraints.maxWidth >= 800;

          final navigator = _ChapterNavigator(
            volumes: widget.volumes,
            plans: widget.plans,
            chapters: widget.chapters,
            runs: widget.runs,
            selectedPlanId: widget.selectedPlan?.id,
            onSelectPlan: widget.onSelectPlan,
            onCreatePlan: widget.onCreatePlan,
          );
          final inspector = _WorkshopInspector(
            plan: widget.selectedPlan,
            run: widget.selectedRun,
            assets: widget.assets,
            memory: widget.memory,
          );
          final editor = _ManuscriptEditor(
            plan: widget.selectedPlan,
            run: widget.selectedRun,
            controller: widget.editorController,
            isBusy: widget.isBusy,
            onEditPlan: widget.onEditPlan,
          );

          if (!isMedium) {
            return Column(
              children: [
                _WorkshopTopBar(
                  project: widget.project,
                  plan: widget.selectedPlan,
                  isDirty: widget.isDirty,
                  isRunning: selectedRunning,
                  showNavigator: _showNavigator,
                  showInspector: _showInspector,
                  onToggleNavigator: _toggleNavigator,
                  onToggleInspector: _toggleInspector,
                  onCreatePlan: widget.onCreatePlan,
                  onSaveChapter: widget.onSaveChapter,
                  onGenerate: widget.onGenerate,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (_showNavigator)
                          SizedBox(height: 360, child: navigator),
                        SizedBox(height: 760, child: editor),
                        if (_showInspector)
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
                project: widget.project,
                plan: widget.selectedPlan,
                isDirty: widget.isDirty,
                isRunning: selectedRunning,
                showNavigator: _showNavigator,
                showInspector: _showInspector,
                onToggleNavigator: _toggleNavigator,
                onToggleInspector: _toggleInspector,
                onCreatePlan: widget.onCreatePlan,
                onSaveChapter: widget.onSaveChapter,
                onGenerate: widget.onGenerate,
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_showNavigator)
                      SizedBox(width: isWide ? 260 : 220, child: navigator),
                    if (_showNavigator)
                      VerticalDivider(
                        width: 0.5,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    Expanded(child: editor),
                    if (_showInspector)
                      VerticalDivider(
                        width: 0.5,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    if (_showInspector) SizedBox(width: 280, child: inspector),
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
    required this.showNavigator,
    required this.showInspector,
    required this.onToggleNavigator,
    required this.onToggleInspector,
    required this.onCreatePlan,
    required this.onSaveChapter,
    required this.onGenerate,
  });

  final WritingProject project;
  final ChapterPlan? plan;
  final bool isDirty;
  final bool isRunning;
  final bool showNavigator;
  final bool showInspector;
  final VoidCallback onToggleNavigator;
  final VoidCallback onToggleInspector;
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

    return GlassContainer(
      borderRadius: 0,
      border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          child: Row(
            children: [
              IconButton(
                tooltip: '返回工作台',
                onPressed: () => context.go('/projects/${project.id}/workshop'),
                icon: const Icon(Icons.arrow_back, size: 20),
                iconSize: 20,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: showNavigator ? '隐藏章节导航' : '显示章节导航',
                onPressed: onToggleNavigator,
                icon: Icon(
                  showNavigator ? Icons.menu_open : Icons.menu,
                  size: 20,
                ),
                iconSize: 20,
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  backgroundColor: showNavigator
                      ? colorScheme.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      project.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    _CompactStatusPill(
                      label: statusLabel,
                      icon: statusIcon,
                      color: isRunning
                          ? colorScheme.primary
                          : isDirty
                          ? colorScheme.error
                          : const Color(0xFF16825D),
                    ),
                    if (plan != null)
                      Text(
                        '第 ${plan!.chapterIndex} 章 · ${_chapterTitle(plan!)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: onCreatePlan,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('新建'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onSaveChapter,
                    icon: const Icon(Icons.save_outlined, size: 16),
                    label: const Text('保存'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: onGenerate,
                    icon: const Icon(Icons.auto_fix_high_outlined, size: 16),
                    label: const Text('生成'),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: showInspector ? '隐藏诊断面板' : '显示诊断面板',
                    onPressed: onToggleInspector,
                    icon: Icon(
                      showInspector ? Icons.chevron_right : Icons.chevron_left,
                      size: 20,
                    ),
                    iconSize: 20,
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      backgroundColor: showInspector
                          ? colorScheme.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
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

class _ChapterNavigator extends StatelessWidget {
  const _ChapterNavigator({
    required this.volumes,
    required this.plans,
    required this.chapters,
    required this.runs,
    required this.selectedPlanId,
    required this.onSelectPlan,
    required this.onCreatePlan,
  });

  final List<ChapterVolume> volumes;
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
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '章节',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: '新建章节',
                  onPressed: onCreatePlan,
                  icon: const Icon(Icons.add, size: 18),
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          if (plans.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: _ChapterProgressStrip(plans: plans, chapters: chapters),
            ),
          if (plans.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _NavigatorEmptyState(onCreatePlan: onCreatePlan),
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  for (final volume in volumes)
                    _NavigatorVolumeSection(
                      volume: volume,
                      plans: plans
                          .where((plan) => plan.volumeId == volume.id)
                          .toList(growable: false),
                      chapters: chapters,
                      runs: runs,
                      selectedPlanId: selectedPlanId,
                      onSelectPlan: onSelectPlan,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NavigatorVolumeSection extends StatefulWidget {
  const _NavigatorVolumeSection({
    required this.volume,
    required this.plans,
    required this.chapters,
    required this.runs,
    required this.selectedPlanId,
    required this.onSelectPlan,
  });

  final ChapterVolume volume;
  final List<ChapterPlan> plans;
  final List<ProjectChapter> chapters;
  final List<ChapterGenerationRun> runs;
  final String? selectedPlanId;
  final ValueChanged<ChapterPlan> onSelectPlan;

  @override
  State<_NavigatorVolumeSection> createState() =>
      _NavigatorVolumeSectionState();
}

class _NavigatorVolumeSectionState extends State<_NavigatorVolumeSection> {
  bool _expanded = true;

  @override
  void initState() {
    super.initState();
    _expanded =
        widget.selectedPlanId == null ||
        widget.plans.any((p) => p.id == widget.selectedPlanId);
  }

  @override
  void didUpdateWidget(_NavigatorVolumeSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPlanId != oldWidget.selectedPlanId &&
        widget.plans.any((p) => p.id == widget.selectedPlanId)) {
      _expanded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasSelected = widget.plans.any((p) => p.id == widget.selectedPlanId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 12, 8),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.expand_more : Icons.chevron_right,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '第 ${widget.volume.volumeIndex} 卷 · ${widget.volume.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: hasSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: hasSelected
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  '${widget.plans.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          for (final plan in widget.plans)
            _ChapterPlanTile(
              plan: plan,
              chapter: _chapterForPlan(widget.chapters, plan.id),
              run: _latestRunForPlan(widget.runs, plan.id),
              selected: widget.selectedPlanId == plan.id,
              onTap: () => widget.onSelectPlan(plan),
            ),
      ],
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
            Text(
              '$completed/${plans.length}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${(progress * 100).round()}%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 3,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.note_add_outlined,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          size: 32,
        ),
        const SizedBox(height: 12),
        Text(
          '暂无章节',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onCreatePlan,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('新建章节'),
          style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
        ),
      ],
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: selected
            ? colorScheme.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: selected ? colorScheme.primary : Colors.transparent,
            width: 2.5,
          ),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        hoverColor: colorScheme.primary.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 12, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  running
                      ? Icons.sync
                      : completed
                      ? Icons.check_circle_outline
                      : Icons.radio_button_unchecked,
                  size: 16,
                  color: selected
                      ? colorScheme.primary
                      : running
                      ? colorScheme.primary
                      : completed
                      ? const Color(0xFF16825D)
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _chapterTitle(plan),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: selected
                            ? colorScheme.onSurface
                            : colorScheme.onSurface,
                      ),
                    ),
                    if (selected &&
                        plan.objectiveCard.objective.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        plan.objectiveCard.objective,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
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
        color: colorScheme.surface,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                '选择章节后开始写作',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '左侧章节列表为空时，请先创建章节目标卡',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ColoredBox(
      color: colorScheme.surface,
      child: Column(
        children: [
          if (run?.errorMessage != null)
            _EditorNotice(message: '最近生成失败：${run!.errorMessage}'),
          _InlineChapterHeader(plan: plan!, run: run, onEditPlan: onEditPlan),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
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
                      fontSize: 17,
                      height: 1.8,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: '开始写第 ${plan!.chapterIndex} 章...',
                      hintStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.35,
                        ),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: const EdgeInsets.fromLTRB(4, 12, 4, 12),
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

class _InlineChapterHeader extends StatelessWidget {
  const _InlineChapterHeader({
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
    final running =
        run?.status == ChapterGenerationStatus.pending ||
        run?.status == ChapterGenerationStatus.running;

    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 12, 24, 0),
      child: Row(
        children: [
          Text(
            '第 ${plan.chapterIndex} 章',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _chapterTitle(plan),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          if (running) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
          ],
          const SizedBox(width: 8),
          InkWell(
            onTap: onEditPlan,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_outlined,
                    size: 14,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '目标',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
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

class _EditorNotice extends StatelessWidget {
  const _EditorNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.errorContainer.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(36, 8, 24, 8),
        child: Row(
          children: [
            Icon(Icons.error_outline, size: 15, color: colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colorScheme.error),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 10),
            child: Text(
              '诊断',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InspectorSection(
                    title: '章节目标',
                    child: plan == null
                        ? Text(
                            '未选择章节',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5),
                                ),
                          )
                        : _ObjectiveCardView(card: plan!.objectiveCard),
                  ),
                  _InspectorSection(
                    title: '上下文',
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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
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
    final colorScheme = Theme.of(context).colorScheme;
    final fields = [
      ('目标', card.objective),
      ('压力源', card.pressureSource),
      ('兑现', card.payoffTarget),
      ('关系', card.relationshipShift),
      ('钩子', card.hookType),
    ];
    final filled = fields.where((f) => f.$2.trim().isNotEmpty).toList();
    if (filled.isEmpty) {
      return Text(
        '未填写目标',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final field in filled)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 36,
                  child: Text(
                    field.$1,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    field.$2,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
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
          final warnings = <String>[...asset.warnings];
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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            ready ? Icons.check_circle_outline : Icons.radio_button_unchecked,
            size: 16,
            color: ready
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Text(
            ready ? '已接入' : '未接入',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: ready
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final item = run;
    if (item == null) {
      return Text(
        '暂无生成任务',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      );
    }
    final running =
        item.status == ChapterGenerationStatus.pending ||
        item.status == ChapterGenerationStatus.running;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _runIcon(item.status),
              size: 14,
              color: _runColor(context, item.status),
            ),
            const SizedBox(width: 6),
            Text(
              _runStatusLabel(item.status),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _runColor(context, item.status),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (running) ...[
              const SizedBox(width: 6),
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        _InfoLine(label: '模型', value: item.modelName),
        if (item.contextWarningsMarkdown.trim().isNotEmpty)
          _InfoLine(label: '提示', value: item.contextWarningsMarkdown),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => context.go('/workflow-runs/${item.workflowTaskId}'),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.open_in_new_outlined,
                  size: 13,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Prompt Trace',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final text = value?.trim();
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
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
    required this.volumes,
    required this.nextIndex,
    this.plan,
  });

  final String projectId;
  final List<ChapterVolume> volumes;
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
  String? _volumeId;

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
    _volumeId = widget.plan?.volumeId ?? widget.volumes.firstOrNull?.id;
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
            DropdownButtonFormField<String>(
              initialValue: _volumeId,
              items: [
                for (final volume in widget.volumes)
                  DropdownMenuItem(
                    value: volume.id,
                    child: Text('第 ${volume.volumeIndex} 卷 · ${volume.title}'),
                  ),
              ],
              onChanged: widget.volumes.isEmpty
                  ? null
                  : (value) => setState(() => _volumeId = value),
              decoration: const InputDecoration(labelText: '所属分卷'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? '请选择分卷。' : null,
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
    final volume = widget.volumes
        .where((item) => item.id == _volumeId)
        .firstOrNull;
    if (volume == null) {
      _showDialogSnack('新建章节必须先有分卷。');
      return;
    }
    final chapterLocalIndex = widget.plan?.chapterLocalIndex ?? _chapterIndex;
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
              volumeId: volume.id,
              volumeIndex: volume.volumeIndex,
              volumeTitle: volume.title,
              chapterLocalIndex: chapterLocalIndex,
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

class _ChapterVolumeDialog extends ConsumerStatefulWidget {
  const _ChapterVolumeDialog({
    required this.projectId,
    required this.nextIndex,
    this.volume,
  });

  final String projectId;
  final int nextIndex;
  final ChapterVolume? volume;

  @override
  ConsumerState<_ChapterVolumeDialog> createState() =>
      _ChapterVolumeDialogState();
}

class _ChapterVolumeDialogState extends ConsumerState<_ChapterVolumeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _indexController;
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _indexController = TextEditingController(
      text: '${widget.volume?.volumeIndex ?? widget.nextIndex}',
    );
    _titleController = TextEditingController(text: widget.volume?.title ?? '');
  }

  @override
  void dispose() {
    _indexController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(novelWorkshopControllerProvider);
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.volume == null ? '新建分卷' : '编辑分卷',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _indexController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '分卷序号'),
            validator: (value) {
              final index = int.tryParse(value?.trim() ?? '');
              return index == null || index <= 0 ? '分卷序号必须大于 0。' : null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: '分卷标题'),
            validator: (value) =>
                value == null || value.trim().isEmpty ? '分卷标题不能为空。' : null,
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
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      await ref
          .read(novelWorkshopControllerProvider.notifier)
          .saveChapterVolume(
            id: widget.volume?.id,
            input: ChapterVolumeInput(
              projectId: widget.projectId,
              volumeIndex: int.parse(_indexController.text.trim()),
              title: _titleController.text,
            ),
          );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存失败：$error')));
    }
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
  required List<ChapterVolume> volumes,
  int nextIndex = 1,
  ChapterPlan? plan,
}) {
  showGlassDialog<void>(
    context: context,
    maxWidth: 680,
    maxHeight: MediaQuery.sizeOf(context).height * 0.9,
    builder: (context) => _ChapterPlanDialog(
      projectId: projectId,
      volumes: volumes,
      nextIndex: nextIndex,
      plan: plan,
    ),
  );
}

void _showVolumeDialog({
  required BuildContext context,
  required String projectId,
  int nextIndex = 1,
  ChapterVolume? volume,
}) {
  showGlassDialog<void>(
    context: context,
    maxWidth: 520,
    builder: (context) => _ChapterVolumeDialog(
      projectId: projectId,
      nextIndex: nextIndex,
      volume: volume,
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

int _nextVolumeIndex(List<ChapterVolume> volumes) {
  if (volumes.isEmpty) {
    return 1;
  }
  return volumes
          .map((volume) => volume.volumeIndex)
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

String _bibleCompletenessLabel(ProjectBible bible) {
  final sections = [
    bible.descriptionMarkdown,
    bible.worldBuildingMarkdown,
    bible.charactersBlueprintMarkdown,
    bible.outlineMasterMarkdown,
    bible.outlineDetailYaml,
  ];
  final filled = sections.where((value) => value.trim().isNotEmpty).length;
  return '$filled/${sections.length}';
}

bool _projectBibleIsEmpty(ProjectBible bible) {
  return [
    bible.descriptionMarkdown,
    bible.worldBuildingMarkdown,
    bible.charactersBlueprintMarkdown,
    bible.outlineMasterMarkdown,
    bible.outlineDetailYaml,
  ].every((value) => value.trim().isEmpty);
}

String _markdownFor(ProjectBible bible, _BibleField field) {
  return switch (field) {
    _BibleField.worldBuilding => bible.worldBuildingMarkdown,
    _BibleField.charactersBlueprint => bible.charactersBlueprintMarkdown,
    _BibleField.outlineMaster => bible.outlineMasterMarkdown,
  };
}

ProjectBibleInput _inputFor(
  ProjectBible bible,
  _BibleField field,
  String markdown,
) {
  return ProjectBibleInput(
    projectId: bible.projectId,
    descriptionMarkdown: bible.descriptionMarkdown,
    worldBuildingMarkdown: field == _BibleField.worldBuilding
        ? markdown
        : bible.worldBuildingMarkdown,
    charactersBlueprintMarkdown: field == _BibleField.charactersBlueprint
        ? markdown
        : bible.charactersBlueprintMarkdown,
    outlineMasterMarkdown: field == _BibleField.outlineMaster
        ? markdown
        : bible.outlineMasterMarkdown,
    outlineDetailYaml: bible.outlineDetailYaml,
  );
}

String _dateLabel(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')} '
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}

String _metadataValue(Object? value) {
  if (value == null) {
    return '';
  }
  if (value is Iterable) {
    return value.map((item) => item.toString()).join(', ');
  }
  return value.toString();
}

_ParsedPromptDocument _parsePromptDocument(
  _PromptDocumentKind kind,
  String markdown,
) {
  try {
    return switch (kind) {
      _PromptDocumentKind.voiceProfile => (() {
        final document = const VoiceProfileFrontMatterParser().parse(markdown);
        return _ParsedPromptDocument(
          fields: document.fields,
          bodyMarkdown: document.bodyMarkdown,
        );
      })(),
      _PromptDocumentKind.storyEngine => (() {
        final document = const StoryEngineNormalizer().parse(markdown);
        return _ParsedPromptDocument(
          fields: document.fields,
          bodyMarkdown: document.bodyMarkdown,
        );
      })(),
    };
  } on Object catch (error) {
    return _ParsedPromptDocument(error: '$error');
  }
}

class _ParsedPromptDocument {
  const _ParsedPromptDocument({
    this.fields = const {},
    this.bodyMarkdown = '',
    this.error,
  });

  final Map<String, Object?> fields;
  final String bodyMarkdown;
  final String? error;
}
