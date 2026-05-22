import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:diff_match_patch/diff_match_patch.dart' as dmp;
import 'package:yaml/yaml.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/analysis_lab_widgets.dart';
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
import '../application/character_graph_parser.dart';
import '../application/novel_workshop_providers.dart';
import '../application/outline_detail_parser.dart';
import '../domain/novel_workshop.dart';
import '../domain/writing_context.dart';
import 'character/character_graph_tab.dart';

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
    final characters = ref.watch(novelCharactersProvider(widget.projectId));
    final relationships = ref.watch(
      novelRelationshipsProvider(widget.projectId),
    );
    final runs = ref.watch(chapterGenerationRunsProvider(widget.projectId));
    final assetRuns = ref.watch(assetGenerationRunsProvider(widget.projectId));
    final enrichmentBatches = ref.watch(
      chapterEnrichmentBatchesProvider(widget.projectId),
    );
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
                  data: (runItems) => assetRuns.when(
                    data: (assetRunItems) => enrichmentBatches.when(
                      data: (batchItems) => _AssetWorkbenchPage(
                        project: item,
                        bible: bibleItem,
                        volumes: volumeItems,
                        plans: planItems,
                        chapters: chapterItems,
                        characters: characters,
                        relationships: relationships,
                        runs: runItems,
                        assetRuns: assetRunItems,
                        enrichmentBatches: batchItems,
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
                          _WorkshopError(message: '无法加载加料任务：$error'),
                      loading: () => const _WorkshopLoading(),
                    ),
                    error: (error, stackTrace) =>
                        _WorkshopError(message: '无法加载资产生成任务：$error'),
                    loading: () => const _WorkshopLoading(),
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
                  final selectedChapterIds = selectedChapter == null
                      ? const <String>{}
                      : <String>{selectedChapter.id};
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
                    isImportedEnrichment:
                        item.origin == ProjectOrigin.importedEnrichment,
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
                        : item.origin == ProjectOrigin.importedEnrichment
                        ? () => _showEnrichmentDialog(
                            project: item,
                            chapters: chapterItems,
                            initialChapterIds: selectedChapterIds,
                          )
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

  Future<void> _showEnrichmentDialog({
    required WritingProject project,
    required List<ProjectChapter> chapters,
    required Set<String> initialChapterIds,
  }) async {
    final candidates = chapters
        .where((chapter) => chapter.contentMarkdown.trim().isNotEmpty)
        .toList(growable: false);
    if (candidates.isEmpty) {
      _showSnack('没有可加料的章节正文。');
      return;
    }
    if (_isDirty) {
      _showSnack('请先保存正文再加料。');
      return;
    }
    final request = await showGlassDialog<_EnrichmentRequest>(
      context: context,
      maxWidth: 900,
      maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      builder: (context) => _EnrichmentRequestDialog(
        chapters: candidates,
        initialChapterIds: initialChapterIds,
      ),
    );
    if (request == null) {
      return;
    }
    try {
      await ref
          .read(novelWorkshopControllerProvider.notifier)
          .enrichChapters(
            projectId: project.id,
            chapterIds: request.chapterIds,
            instruction: request.instruction,
            expansionRatioPercent: request.expansionRatioPercent,
          );
      _showSnack('加料已生成，返回概览预览后应用。');
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
    required this.characters,
    required this.relationships,
    required this.runs,
    required this.assetRuns,
    required this.enrichmentBatches,
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
  final AsyncValue<List<NovelCharacter>> characters;
  final AsyncValue<List<NovelRelationship>> relationships;
  final List<ChapterGenerationRun> runs;
  final List<AssetGenerationRun> assetRuns;
  final List<ChapterEnrichmentBatch> enrichmentBatches;
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
          characters: characters,
          relationships: relationships,
          runs: runs,
          assetRuns: assetRuns,
          enrichmentBatches: enrichmentBatches,
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
    required this.characters,
    required this.relationships,
    required this.runs,
    required this.assetRuns,
    required this.enrichmentBatches,
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
  final AsyncValue<List<NovelCharacter>> characters;
  final AsyncValue<List<NovelRelationship>> relationships;
  final List<ChapterGenerationRun> runs;
  final List<AssetGenerationRun> assetRuns;
  final List<ChapterEnrichmentBatch> enrichmentBatches;
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
  late TabController _tabController;

  int get _tabLength =>
      widget.project.origin == ProjectOrigin.importedEnrichment ? 3 : 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLength, vsync: this);
  }

  @override
  void didUpdateWidget(_WorkbenchTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_tabLength == _tabController.length) {
      return;
    }
    final previousIndex = _tabController.index;
    _tabController.dispose();
    _tabController = TabController(length: _tabLength, vsync: this);
    _tabController.index = previousIndex.clamp(0, _tabLength - 1);
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
    final imported = widget.project.origin == ProjectOrigin.importedEnrichment;
    final tabs = imported
        ? const [Tab(text: '概览'), Tab(text: 'Voice Profile'), Tab(text: '设置')]
        : const [
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
          ];
    final children = imported
        ? [
            _ImportedProjectOverviewTab(
              project: widget.project,
              volumes: widget.volumes,
              plans: widget.plans,
              chapters: widget.chapters,
              enrichmentBatches: widget.enrichmentBatches,
              assets: widget.assets,
            ),
            _YamlMarkdownAssetTab(
              title: 'Voice Profile',
              description:
                  '加料时只注入 Voice Profile，不使用 Story Engine 或 Runtime Memory。',
              markdownAsync: widget.assets.whenData(
                (a) => a.voiceProfileMarkdown,
              ),
              kind: _PromptDocumentKind.voiceProfile,
              emptyIcon: Icons.record_voice_over_outlined,
              emptyTitle: '暂无 Voice Profile',
              emptyDescription: '可在设置中绑定 Style Profile。',
              emptyAction: TextButton.icon(
                onPressed: () => _onSwitchTab(2),
                icon: const Icon(Icons.settings_outlined, size: 18),
                label: const Text('前往设置'),
              ),
            ),
            _WorkshopSettingsTab(project: widget.project, bible: widget.bible),
          ]
        : [
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
              latestRun: _latestAssetRun(
                widget.assetRuns,
                AssetGenerationKind.worldBuilding,
              ),
              emptyIcon: Icons.public_outlined,
              emptyTitle: '暂无世界观设定',
              emptyDescription: '补齐世界规则、地域组织和不可破坏设定后，章节生成会使用它作为硬上下文。',
            ),
            CharacterGraphTab(
              projectId: widget.project.id,
              legacyMarkdown: widget.bible.charactersBlueprintMarkdown,
              characters: widget.characters,
              relationships: widget.relationships,
              latestRun: _latestAssetRun(
                widget.assetRuns,
                AssetGenerationKind.charactersBlueprint,
              ),
              onShowDraftReview: (context, run) async {
                return showGlassDialog<bool>(
                  context: context,
                  maxWidth: 860,
                  builder: (context) => _AssetDraftReviewDialog(
                    title: '角色卡片与关系图草稿',
                    run: run,
                    hasExistingContent: true,
                  ),
                );
              },
            ),
            _BibleMarkdownEditorTab(
              title: '总纲',
              description: '故事主线、主题推进、卷间结构和结局约束。',
              bible: widget.bible,
              field: _BibleField.outlineMaster,
              latestRun: _latestAssetRun(
                widget.assetRuns,
                AssetGenerationKind.outlineMaster,
              ),
              emptyIcon: Icons.route_outlined,
              emptyTitle: '暂无总纲',
              emptyDescription: '总纲用于约束分卷和章节细纲，不再展示剧情分析骨架大纲。',
            ),
            _ChapterPlanningTab(
              volumes: widget.volumes,
              plans: widget.plans,
              chapters: widget.chapters,
              runs: widget.runs,
              projectId: widget.project.id,
              assetRun: _latestAssetRun(
                widget.assetRuns,
                AssetGenerationKind.outlineDetailYaml,
              ),
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
              emptyAction: TextButton.icon(
                onPressed: () => _onSwitchTab(9),
                icon: const Icon(Icons.settings_outlined, size: 18),
                label: const Text('前往设置'),
              ),
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
              emptyAction: TextButton.icon(
                onPressed: () => _onSwitchTab(9),
                icon: const Icon(Icons.settings_outlined, size: 18),
                label: const Text('前往设置'),
              ),
            ),
            _RuntimeMemoryTab(
              projectId: widget.project.id,
              memory: widget.memory,
              chapters: widget.chapters,
              characters: widget.characters,
              relationships: widget.relationships,
            ),
            _PromptStackTab(
              assets: widget.assets,
              bible: widget.bible,
              memory: widget.memory,
            ),
            _WorkshopSettingsTab(project: widget.project, bible: widget.bible),
          ];

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
                tabs: tabs,
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
                  children: children,
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
                  description: '局势、线索、故事摘要',
                ),
                const SizedBox(height: 12),
                memory.when(
                  data: (item) => item.state.isEmpty
                      ? const PersonaEmptyStateCard(
                          icon: Icons.memory_outlined,
                          title: '暂无运行时记忆',
                          description: '完成正文生成后将自动创建',
                        )
                      : _RuntimeMemoryOverviewSummary(
                          memory: item.state,
                          onOpen: () => onSwitchTab(7),
                        ),
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

class _ImportedProjectOverviewTab extends StatelessWidget {
  const _ImportedProjectOverviewTab({
    required this.project,
    required this.volumes,
    required this.plans,
    required this.chapters,
    required this.enrichmentBatches,
    required this.assets,
  });

  final WritingProject project;
  final List<ChapterVolume> volumes;
  final List<ChapterPlan> plans;
  final List<ProjectChapter> chapters;
  final List<ChapterEnrichmentBatch> enrichmentBatches;
  final AsyncValue<ProjectPromptAssets> assets;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final totalChars = chapters.fold<int>(
      0,
      (sum, chapter) => sum + chapter.contentMarkdown.trim().length,
    );
    final latestBatch = enrichmentBatches.isEmpty
        ? null
        : enrichmentBatches.first;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Project identity --
          Row(
            children: [
              Icon(
                Icons.auto_fix_high_outlined,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '导入加料项目',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            project.description.trim().isEmpty
                ? '暂无导入说明。'
                : project.description,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          // -- Metric cards --
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 150,
                  child: PersonaMetric(
                    label: '导入分卷',
                    value: '${volumes.length}',
                    detail: '固定导入正文卷',
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 150,
                  child: PersonaMetric(
                    label: '章节',
                    value: '${plans.length}',
                    detail: '${chapters.length} 章有正文',
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 170,
                  child: PersonaMetric(
                    label: '总字数',
                    value: '$totalChars',
                    detail: '按当前正文统计',
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 170,
                  child: PersonaMetric(
                    label: '加料批次',
                    value: '${enrichmentBatches.length}',
                    detail: latestBatch == null
                        ? '暂无批次'
                        : _enrichmentBatchStatusLabel(latestBatch.status),
                  ),
                ),
              ],
            ),
          ),

          // -- Enrichment batch panel --
          const SizedBox(height: 20),
          PersonaPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PersonaSectionHeader(
                  title: '最近加料批次',
                  description: '成功生成的结果需要预览后手动应用到章节正文。',
                  trailing: latestBatch != null
                      ? FilledButton.icon(
                          onPressed: () => context.go(
                            '/projects/${project.id}/workshop/editor',
                          ),
                          icon: const Icon(Icons.edit_note_outlined, size: 18),
                          label: const Text('进入编辑器'),
                          style: FilledButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                if (latestBatch == null)
                  const PersonaEmptyStateCard(
                    icon: Icons.auto_fix_high_outlined,
                    title: '暂无加料结果',
                    description: '进入编辑器选择章节后执行加料。',
                  )
                else
                  _EnrichmentBatchPreview(batch: latestBatch),
              ],
            ),
          ),

          // -- Voice Profile panel --
          const SizedBox(height: 16),
          PersonaPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PersonaSectionHeader(
                  title: 'Voice Profile',
                  description: '导入项目加料只使用 Voice Profile 作为风格上下文。',
                ),
                const SizedBox(height: 12),
                assets.when(
                  data: (item) => _AssetStatus(
                    label: 'Voice Profile',
                    ready: item.voiceProfileMarkdown.trim().isNotEmpty,
                  ),
                  error: (error, stackTrace) =>
                      InlineError(message: '无法加载 Voice Profile：$error'),
                  loading: () => const SkeletonBox(width: 220, height: 16),
                ),
              ],
            ),
          ),

          // -- Entry button (if no batch yet) --
          if (latestBatch == null) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () =>
                    context.go('/projects/${project.id}/workshop/editor'),
                icon: const Icon(Icons.edit_note_outlined, size: 18),
                label: const Text('进入加料编辑器'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Color _enrichmentItemStatusColor(
  ColorScheme colorScheme,
  ChapterEnrichmentItemStatus status,
) {
  return switch (status) {
    ChapterEnrichmentItemStatus.waiting => colorScheme.onSurfaceVariant,
    ChapterEnrichmentItemStatus.running => colorScheme.primary,
    ChapterEnrichmentItemStatus.generated => const Color(0xFF16825D),
    ChapterEnrichmentItemStatus.failed => colorScheme.error,
    ChapterEnrichmentItemStatus.applied => colorScheme.primary,
  };
}

class _EnrichmentBatchPreview extends ConsumerStatefulWidget {
  const _EnrichmentBatchPreview({required this.batch});

  final ChapterEnrichmentBatch batch;

  @override
  ConsumerState<_EnrichmentBatchPreview> createState() =>
      _EnrichmentBatchPreviewState();
}

class _EnrichmentBatchPreviewState
    extends ConsumerState<_EnrichmentBatchPreview> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = ref.watch(chapterEnrichmentItemsProvider(widget.batch.id));
    final controller = ref.watch(novelWorkshopControllerProvider);
    return items.when(
      data: (itemList) {
        final visibleItems = _expanded ? itemList : itemList.take(8).toList();
        final hasMore = itemList.length > 8;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status pills + batch action
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      PersonaStatusPill(
                        label: _enrichmentBatchStatusLabel(widget.batch.status),
                        icon: Icons.auto_fix_high_outlined,
                        color: colorScheme.primary,
                      ),
                      PersonaStatusPill(
                        label: '成功 ${widget.batch.generatedCount}',
                        icon: Icons.check_circle_outline,
                        color: const Color(0xFF16825D),
                      ),
                      if (widget.batch.failedCount > 0)
                        PersonaStatusPill(
                          label: '失败 ${widget.batch.failedCount}',
                          icon: Icons.error_outline,
                          color: colorScheme.error,
                        ),
                      PersonaStatusPill(
                        label: '已应用 ${widget.batch.appliedCount}',
                        icon: Icons.done_all_outlined,
                        color: colorScheme.tertiary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: controller.isLoading
                      ? null
                      : () => _applyAllGenerated(context, ref, itemList),
                  icon: const Icon(Icons.done_all_outlined, size: 18),
                  label: const Text('批量应用'),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Item list
            for (final item in visibleItems)
              _EnrichmentItemPreviewTile(item: item),
            // Expand/collapse button
            if (hasMore)
              Center(
                child: TextButton.icon(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: Icon(
                    _expanded
                        ? Icons.expand_less_outlined
                        : Icons.expand_more_outlined,
                    size: 18,
                  ),
                  label: Text(_expanded ? '收起' : '查看全部 ${itemList.length} 项'),
                ),
              ),
          ],
        );
      },
      error: (error, stackTrace) => InlineError(message: '无法加载加料结果：$error'),
      loading: () => const SkeletonBox(width: 260, height: 16),
    );
  }

  Future<void> _applyAllGenerated(
    BuildContext context,
    WidgetRef ref,
    List<ChapterEnrichmentItem> items,
  ) async {
    final ids = items
        .where(
          (item) =>
              item.status == ChapterEnrichmentItemStatus.generated &&
              item.generatedContentMarkdown.trim().isNotEmpty,
        )
        .map((item) => item.id)
        .toList(growable: false);
    if (ids.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('没有可应用的加料结果。')));
      return;
    }
    await ref
        .read(novelWorkshopControllerProvider.notifier)
        .applyChapterEnrichmentItems(ids);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已应用 ${ids.length} 个加料结果。')));
  }
}

class _EnrichmentItemPreviewTile extends ConsumerStatefulWidget {
  const _EnrichmentItemPreviewTile({required this.item});

  final ChapterEnrichmentItem item;

  @override
  ConsumerState<_EnrichmentItemPreviewTile> createState() =>
      _EnrichmentItemPreviewTileState();
}

class _EnrichmentItemPreviewTileState
    extends ConsumerState<_EnrichmentItemPreviewTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final item = widget.item;
    final canApply =
        item.status == ChapterEnrichmentItemStatus.generated &&
        item.generatedContentMarkdown.trim().isNotEmpty;
    final canRetry = item.status == ChapterEnrichmentItemStatus.failed;
    final statusColor = _enrichmentItemStatusColor(colorScheme, item.status);
    final originalLen = item.originalContentMarkdown.trim().length;
    final generatedLen = item.generatedContentMarkdown.trim().length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            border: Border.all(
              color: _hovered
                  ? statusColor.withValues(alpha: 0.4)
                  : colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Status color bar
                Container(width: 4, color: statusColor),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Chapter number + status
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    '章节 ${item.position + 1}',
                                    style: textTheme.titleSmall,
                                  ),
                                  const SizedBox(width: 8),
                                  PersonaStatusPill(
                                    label: _enrichmentItemStatusLabel(
                                      item.status,
                                    ),
                                    color: statusColor,
                                  ),
                                ],
                              ),
                            ),
                            // Word count comparison
                            if (generatedLen > 0 && originalLen > 0) ...[
                              Text(
                                '$originalLen → $generatedLen 字',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '+${((generatedLen - originalLen) / originalLen * 100).round()}%',
                                style: textTheme.labelMedium?.copyWith(
                                  color: const Color(0xFF16825D),
                                ),
                              ),
                            ],
                            // Action buttons
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 150),
                              opacity: _hovered ? 1.0 : 0.6,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (canApply)
                                    TextButton.icon(
                                      onPressed: () =>
                                          _reviewAndApply(context, ref),
                                      icon: const Icon(
                                        Icons.check_outlined,
                                        size: 18,
                                      ),
                                      label: const Text('预览应用'),
                                    ),
                                  if (canRetry)
                                    TextButton.icon(
                                      onPressed: () async {
                                        await ref
                                            .read(
                                              novelWorkshopControllerProvider
                                                  .notifier,
                                            )
                                            .retryChapterEnrichmentItem(
                                              item.id,
                                            );
                                      },
                                      icon: const Icon(
                                        Icons.refresh_outlined,
                                        size: 18,
                                      ),
                                      label: const Text('重试'),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (item.errorMessage != null) ...[
                          const SizedBox(height: 6),
                          InlineError(message: item.errorMessage!),
                        ],
                        if (item.generatedContentMarkdown
                            .trim()
                            .isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            item.generatedContentMarkdown.trim(),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _reviewAndApply(BuildContext context, WidgetRef ref) async {
    final action = await showGlassDialog<_EnrichmentReviewAction>(
      context: context,
      maxWidth: 920,
      maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      builder: (context) => _EnrichmentDiffDialog(item: widget.item),
    );
    switch (action) {
      case _EnrichmentReviewAction.apply:
        await ref
            .read(novelWorkshopControllerProvider.notifier)
            .applyChapterEnrichmentItem(widget.item.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('加料结果已应用。')));
        return;
      case _EnrichmentReviewAction.delete:
        await ref
            .read(novelWorkshopControllerProvider.notifier)
            .deleteChapterEnrichmentItem(widget.item.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('加料结果已删除。')));
        return;
      case _EnrichmentReviewAction.cancel:
      case null:
        return;
    }
  }
}

enum _EnrichmentReviewAction { apply, delete, cancel }

class _EnrichmentDiffDialog extends StatelessWidget {
  const _EnrichmentDiffDialog({required this.item});

  final ChapterEnrichmentItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final originalLen = item.originalContentMarkdown.trim().length;
    final generatedLen = item.generatedContentMarkdown.trim().length;
    final diffPercent = originalLen > 0
        ? ((generatedLen - originalLen) / originalLen * 100).round()
        : 0;
    final diffs = dmp.diff(
      item.originalContentMarkdown.trim(),
      item.generatedContentMarkdown.trim(),
      timeout: 0.25,
      checklines: true,
    );
    dmp.cleanupSemantic(diffs);
    final removedLen = diffs
        .where((diff) => diff.operation == dmp.DIFF_DELETE)
        .fold<int>(0, (sum, diff) => sum + diff.text.length);
    final insertedLen = diffs
        .where((diff) => diff.operation == dmp.DIFF_INSERT)
        .fold<int>(0, (sum, diff) => sum + diff.text.length);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 760),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Title --
          Row(
            children: [
              Icon(Icons.compare_arrows_outlined, color: colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(child: Text('加料预览', style: textTheme.titleLarge)),
            ],
          ),
          const SizedBox(height: 12),

          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.text_fields_outlined,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  Text('原文 $originalLen 字', style: textTheme.bodyMedium),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  Text('生成 $generatedLen 字', style: textTheme.bodyMedium),
                  _DiffStatChip(
                    label: diffPercent >= 0
                        ? '+$diffPercent%'
                        : '$diffPercent%',
                    color: diffPercent >= 0
                        ? const Color(0xFF16825D)
                        : colorScheme.error,
                  ),
                  if (removedLen > 0)
                    _DiffStatChip(
                      label: '删除 $removedLen 字',
                      color: colorScheme.error,
                    ),
                  if (insertedLen > 0)
                    _DiffStatChip(
                      label: '新增 $insertedLen 字',
                      color: const Color(0xFF16825D),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // -- Diff columns --
          Flexible(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final original = _DiffColumn(
                  title: '原文快照',
                  diffs: diffs,
                  side: _DiffSide.original,
                  icon: Icons.description_outlined,
                  headerBgColor: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.4,
                  ),
                  borderColor: colorScheme.outlineVariant,
                );
                final generated = _DiffColumn(
                  title: '加料生成稿',
                  diffs: diffs,
                  side: _DiffSide.generated,
                  icon: Icons.auto_fix_high_outlined,
                  headerBgColor: colorScheme.primary.withValues(alpha: 0.08),
                  borderColor: colorScheme.primary.withValues(alpha: 0.25),
                );
                if (constraints.maxWidth < 760) {
                  return ListView(
                    children: [
                      SizedBox(height: 260, child: original),
                      const SizedBox(height: 12),
                      SizedBox(height: 260, child: generated),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: original),
                    const SizedBox(width: 12),
                    Expanded(child: generated),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // -- Action row --
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(_EnrichmentReviewAction.cancel),
                child: const Text('取消'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('删除结果'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: item.generatedContentMarkdown.trim().isEmpty
                    ? null
                    : () => Navigator.of(
                        context,
                      ).pop(_EnrichmentReviewAction.apply),
                icon: const Icon(Icons.check_outlined, size: 18),
                label: const Text('应用到章节'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除加料结果？'),
        content: const Text('这只会删除本次生成的预览结果，不会修改章节正文。删除后无法从该批次中应用它。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('确认删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    Navigator.of(context).pop(_EnrichmentReviewAction.delete);
  }
}

class _DiffStatChip extends StatelessWidget {
  const _DiffStatChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: textTheme.labelMedium?.copyWith(color: color),
        ),
      ),
    );
  }
}

enum _DiffSide { original, generated }

class _DiffColumn extends StatelessWidget {
  const _DiffColumn({
    required this.title,
    required this.diffs,
    required this.side,
    required this.icon,
    required this.headerBgColor,
    required this.borderColor,
  });

  final String title;
  final List<dmp.Diff> diffs;
  final _DiffSide side;
  final IconData icon;
  final Color headerBgColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(kPanelRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kPanelRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ColoredBox(
              color: headerBgColor,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(title, style: textTheme.titleSmall),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: SelectableText.rich(
                  TextSpan(
                    style: textTheme.bodyMedium?.copyWith(height: 1.55),
                    children: _buildDiffSpans(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _buildDiffSpans(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      height: 1.55,
      color: colorScheme.onSurface,
    );
    final deleteStyle = baseStyle?.copyWith(
      backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.55),
      color: colorScheme.onErrorContainer,
      decoration: TextDecoration.lineThrough,
      decorationColor: colorScheme.error,
    );
    final insertStyle = baseStyle?.copyWith(
      backgroundColor: const Color(0xFF16825D).withValues(alpha: 0.12),
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w600,
    );
    final spans = <TextSpan>[];
    for (final diff in diffs) {
      if (diff.text.isEmpty) {
        continue;
      }
      switch (diff.operation) {
        case dmp.DIFF_EQUAL:
          spans.add(TextSpan(text: diff.text, style: baseStyle));
        case dmp.DIFF_DELETE:
          if (side == _DiffSide.original) {
            spans.add(TextSpan(text: diff.text, style: deleteStyle));
          }
        case dmp.DIFF_INSERT:
          if (side == _DiffSide.generated) {
            spans.add(TextSpan(text: diff.text, style: insertStyle));
          }
      }
    }
    if (spans.isEmpty) {
      return [TextSpan(text: '暂无内容。', style: baseStyle)];
    }
    return spans;
  }
}

String _enrichmentBatchStatusLabel(ChapterEnrichmentBatchStatus status) {
  return switch (status) {
    ChapterEnrichmentBatchStatus.pending => '排队中',
    ChapterEnrichmentBatchStatus.running => '加料中',
    ChapterEnrichmentBatchStatus.succeeded => '已完成',
    ChapterEnrichmentBatchStatus.partialFailed => '部分失败',
    ChapterEnrichmentBatchStatus.failed => '失败',
  };
}

String _enrichmentItemStatusLabel(ChapterEnrichmentItemStatus status) {
  return switch (status) {
    ChapterEnrichmentItemStatus.waiting => '等待中',
    ChapterEnrichmentItemStatus.running => '加料中',
    ChapterEnrichmentItemStatus.generated => '待应用',
    ChapterEnrichmentItemStatus.failed => '失败',
    ChapterEnrichmentItemStatus.applied => '已应用',
  };
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
    required this.latestRun,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyDescription,
  });

  final String title;
  final String description;
  final ProjectBible bible;
  final _BibleField field;
  final AssetGenerationRun? latestRun;
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
    final generating =
        widget.latestRun?.status == AssetGenerationStatus.pending ||
        widget.latestRun?.status == AssetGenerationStatus.running;
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
              ] else ...[
                OutlinedButton.icon(
                  key: ValueKey('generate-asset-${widget.field.name}'),
                  onPressed: state.isLoading || generating
                      ? null
                      : () => _generateAsset(trimmed),
                  icon: generating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_fix_high_outlined, size: 18),
                  label: Text(generating ? '生成中' : '生成草稿'),
                ),
                if (_canReview(widget.latestRun)) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: state.isLoading
                        ? null
                        : () => _reviewDraft(widget.latestRun!, trimmed),
                    icon: const Icon(Icons.rate_review_outlined, size: 18),
                    label: const Text('查看草稿'),
                  ),
                ],
                if (trimmed.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _editing = true),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('编辑'),
                  ),
                ],
              ],
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

  Future<void> _generateAsset(String currentMarkdown) async {
    try {
      final result = await ref
          .read(novelWorkshopControllerProvider.notifier)
          .generateAsset(
            projectId: widget.bible.projectId,
            kind: _assetKindForField(widget.field),
          );
      if (!mounted) return;
      await _reviewDraft(result.run, currentMarkdown);
    } on Object {
      // The controller listener renders the error where available.
    }
  }

  Future<void> _reviewDraft(
    AssetGenerationRun run,
    String currentMarkdown,
  ) async {
    final shouldApply = await showGlassDialog<bool>(
      context: context,
      maxWidth: 860,
      builder: (context) => _AssetDraftReviewDialog(
        title: '${widget.title}草稿',
        run: run,
        hasExistingContent: currentMarkdown.trim().isNotEmpty,
      ),
    );
    if (shouldApply != true) return;
    try {
      final saved = await ref
          .read(novelWorkshopControllerProvider.notifier)
          .applyAssetDraft(run.id);
      if (!mounted) return;
      setState(() {
        _loadedMarkdown = _markdownFor(saved, widget.field);
        _controller.text = _loadedMarkdown;
        _editing = false;
      });
      if (Scaffold.maybeOf(context) != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${widget.title}草稿已应用。')));
      }
    } on Object catch (error) {
      if (!mounted) return;
      if (Scaffold.maybeOf(context) != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('应用失败：$error')));
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
    this.emptyAction,
  });

  final String title;
  final String description;
  final AsyncValue<String> markdownAsync;
  final _PromptDocumentKind kind;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyDescription;
  final Widget? emptyAction;

  @override
  Widget build(BuildContext context) {
    return markdownAsync.when(
      data: (markdown) {
        final trimmed = markdown.trim();
        if (trimmed.isEmpty) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final minHeight = (constraints.maxHeight - 40).clamp(
                0.0,
                double.infinity,
              );
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight),
                  child: Center(
                    child: PersonaEmptyStateCard(
                      icon: emptyIcon,
                      title: emptyTitle,
                      description: emptyDescription,
                      action: emptyAction,
                      centered: true,
                      maxWidth: 560,
                    ),
                  ),
                ),
              );
            },
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
    required this.chapters,
    required this.characters,
    required this.relationships,
  });

  final String projectId;
  final AsyncValue<ProjectRuntimeMemory> memory;
  final List<ProjectChapter> chapters;
  final AsyncValue<List<NovelCharacter>> characters;
  final AsyncValue<List<NovelRelationship>> relationships;

  @override
  ConsumerState<_RuntimeMemoryTab> createState() => _RuntimeMemoryTabState();
}

class _RuntimeMemoryTabState extends ConsumerState<_RuntimeMemoryTab> {
  bool _editing = false;
  late TextEditingController _runtimeStateCtrl;
  late TextEditingController _threadsCtrl;
  late TextEditingController _summaryCtrl;
  late TextEditingController _continuityIndexCtrl;
  late TextEditingController _chapterArchiveCtrl;

  @override
  void initState() {
    super.initState();
    _runtimeStateCtrl = TextEditingController();
    _threadsCtrl = TextEditingController();
    _summaryCtrl = TextEditingController();
    _continuityIndexCtrl = TextEditingController();
    _chapterArchiveCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _runtimeStateCtrl.dispose();
    _threadsCtrl.dispose();
    _summaryCtrl.dispose();
    _continuityIndexCtrl.dispose();
    _chapterArchiveCtrl.dispose();
    super.dispose();
  }

  void _startEditing(RuntimeMemoryState state) {
    _runtimeStateCtrl.text = state.runtimeState;
    _threadsCtrl.text = state.runtimeThreads;
    _summaryCtrl.text = state.storySummary;
    _continuityIndexCtrl.text = state.continuityIndex;
    _chapterArchiveCtrl.text = state.chapterArchiveMarkdown;
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
              runtimeState: _runtimeStateCtrl.text,
              runtimeThreads: _threadsCtrl.text,
              storySummary: _summaryCtrl.text,
              continuityIndex: _continuityIndexCtrl.text,
              chapterArchiveMarkdown: _chapterArchiveCtrl.text,
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
                      '创作过程中持续追踪运行状态、剧情线索和故事摘要。角色状态由角色索引与关系网维护。',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (_editing) ...[
                    TextButton(
                      onPressed: controllerState.isLoading
                          ? null
                          : _cancelEditing,
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
              _MemoryPatchReviewList(
                memory: item.state,
                chapters: widget.chapters,
                characters: widget.characters,
                relationships: widget.relationships,
              ),
              const SizedBox(height: 16),
              if (isEmpty)
                _buildEmptyState(context, item.state)
              else if (_editing)
                _buildEditForm(context, colorScheme, textTheme)
              else
                _RuntimeMemoryReadView(memory: item.state),
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

  Widget _buildEmptyState(BuildContext context, RuntimeMemoryState state) {
    return Center(
      child: PersonaEmptyStateCard(
        icon: Icons.auto_stories_outlined,
        title: '运行时记忆尚未建立',
        description: '随着章节生成和故事推进，系统会自动追踪运行状态、剧情线索和故事摘要。你也可以手动编辑来维护它们。',
        centered: true,
        maxWidth: 620,
        action: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _RuntimeMemoryEmptyPreview(),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () => _startEditing(state),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('开始编辑'),
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
        _MemoryEditField(
          controller: _continuityIndexCtrl,
          icon: Icons.account_tree_outlined,
          label: '连续性索引',
          description: '高密度触发点和承接提醒',
          accentColor: Colors.teal,
        ),
        _MemoryEditField(
          controller: _chapterArchiveCtrl,
          icon: Icons.archive_outlined,
          label: '章节归档',
          description: '已审阅章节的连续性记录',
          accentColor: Colors.indigo,
          minLines: 6,
          maxLines: 14,
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
                      ? '未绑定 Style Profile，生成时会自动跳过'
                      : '已接入风格约束',
                  neutralWhenReady: asset.voiceProfileMarkdown.trim().isEmpty,
                ),
                _AssetDetailTile(
                  title: 'Story Engine',
                  bound: true,
                  ready: asset.storyEngineMarkdown.trim().isNotEmpty,
                  detail: asset.storyEngineMarkdown.trim().isEmpty
                      ? '未绑定 Plot Profile，生成时会自动跳过'
                      : '已接入叙事引擎',
                  neutralWhenReady: asset.storyEngineMarkdown.trim().isEmpty,
                ),
                if (_actionablePromptWarnings(asset).isNotEmpty)
                  _WarningList(warnings: _actionablePromptWarnings(asset)),
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

List<String> _actionablePromptWarnings(ProjectPromptAssets asset) {
  const optionalMissingWarnings = {
    '项目未绑定 Voice Profile。',
    '项目未绑定 Story Engine。',
  };
  return asset.warnings
      .where((warning) => !optionalMissingWarnings.contains(warning))
      .toList(growable: false);
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
  late final TextEditingController _totalTargetLengthController;
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
    _totalTargetLengthController = TextEditingController(
      text: p.totalTargetLength.toString(),
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
    _totalTargetLengthController.dispose();
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
      totalTargetLength:
          int.tryParse(_totalTargetLengthController.text.trim()) ?? 0,
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
                              labelText: '单章目标字数',
                              suffixText: '字',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _totalTargetLengthController,
                            decoration: const InputDecoration(
                              labelText: '全书目标字数',
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

class _ChapterPlanningTab extends ConsumerStatefulWidget {
  const _ChapterPlanningTab({
    required this.volumes,
    required this.plans,
    required this.chapters,
    required this.runs,
    required this.projectId,
    required this.assetRun,
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
  final String projectId;
  final AssetGenerationRun? assetRun;
  final String outlineDetailYaml;
  final VoidCallback onCreatePlan;
  final VoidCallback onCreateVolume;
  final ValueChanged<ChapterVolume> onEditVolume;
  final ValueChanged<ChapterPlan> onEditPlan;

  @override
  ConsumerState<_ChapterPlanningTab> createState() =>
      _ChapterPlanningTabState();
}

class _ChapterPlanningTabState extends ConsumerState<_ChapterPlanningTab> {
  late final TextEditingController _yamlController;
  late String _loadedYaml;
  bool _editingYaml = false;

  bool get _isDirty => _yamlController.text != _loadedYaml;

  @override
  void initState() {
    super.initState();
    _loadedYaml = widget.outlineDetailYaml;
    _yamlController = TextEditingController(text: _loadedYaml);
    _yamlController.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(_ChapterPlanningTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.outlineDetailYaml == widget.outlineDetailYaml) {
      return;
    }
    if (_isDirty) {
      return;
    }
    _loadedYaml = widget.outlineDetailYaml;
    _yamlController.text = _loadedYaml;
  }

  @override
  void dispose() {
    _yamlController.removeListener(_onTextChanged);
    _yamlController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _startEditing() {
    setState(() {
      _editingYaml = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _yamlController.text = _loadedYaml;
      _editingYaml = false;
    });
  }

  Future<void> _saveYaml() async {
    final yaml = _yamlController.text;
    try {
      const OutlineDetailParser().parse(yaml);
    } on OutlineDetailValidationException catch (error) {
      if (!mounted) return;
      if (Scaffold.maybeOf(context) != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('YAML 格式错误：${error.message}')));
      }
      return;
    }

    try {
      await ref
          .read(novelWorkshopControllerProvider.notifier)
          .saveOutlineDetailYaml(
            projectId: widget.projectId,
            outlineDetailYaml: yaml,
          );
      if (!mounted) return;
      setState(() {
        _loadedYaml = yaml;
        _editingYaml = false;
      });
      if (Scaffold.maybeOf(context) != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('分卷与章节细纲已保存。')));
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
    final completedChapterCount = widget.plans
        .where(
          (plan) => widget.chapters.any(
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
          volumeCount: widget.volumes.length,
          planCount: widget.plans.length,
          completedChapterCount: completedChapterCount,
          hasVolumes: widget.volumes.isNotEmpty,
          projectId: widget.projectId,
          assetRun: widget.assetRun,
          outlineDetailYaml: widget.outlineDetailYaml,
          onCreateVolume: widget.onCreateVolume,
          onCreatePlan: widget.onCreatePlan,
          onEditYaml: _startEditing,
        ),
        const Divider(height: 1),
        if (_editingYaml)
          _buildYamlEditor(context)
        else if (widget.volumes.isEmpty)
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
                        onCreateVolume: widget.onCreateVolume,
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
                if (widget.outlineDetailYaml.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _OutlineYamlStatus(yaml: widget.outlineDetailYaml),
                  ),
                for (final volume in widget.volumes)
                  _VolumePlanSection(
                    volume: volume,
                    plans: widget.plans
                        .where((plan) => plan.volumeId == volume.id)
                        .toList(growable: false),
                    chapters: widget.chapters,
                    runs: widget.runs,
                    onEditVolume: () => widget.onEditVolume(volume),
                    onGenerateVolumeDetail: () =>
                        _generateVolumeDetail(context, volume),
                    onCreatePlan: widget.onCreatePlan,
                    onEditPlan: widget.onEditPlan,
                  ),
                for (final plan in widget.plans.where(
                  (plan) => !widget.volumes.any(
                    (volume) => volume.id == plan.volumeId,
                  ),
                ))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _WorkbenchChapterTile(
                      plan: plan,
                      chapter: _chapterForPlan(widget.chapters, plan.id),
                      run: _latestRunForPlan(widget.runs, plan.id),
                      onEdit: () => widget.onEditPlan(plan),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildYamlEditor(BuildContext context) {
    final state = ref.watch(novelWorkshopControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '直接编辑分卷与章节细纲 YAML，保存后将同步更新结构化数据。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: state.isLoading ? null : _cancelEditing,
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: state.isLoading || !_isDirty ? null : _saveYaml,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('保存'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildValidationStatus(context),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _yamlController,
                    maxLines: null,
                    minLines: 20,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontFamilyFallback: ['Menlo', 'Consolas'],
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '分卷与章节细纲 (YAML)',
                      alignLabelWithHint: true,
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

  Future<void> _generateVolumeDetail(
    BuildContext context,
    ChapterVolume volume,
  ) async {
    try {
      final result = await ref
          .read(novelWorkshopControllerProvider.notifier)
          .generateAsset(
            projectId: widget.projectId,
            kind: AssetGenerationKind.outlineDetailYaml,
            targetVolumeId: volume.id,
          );
      if (!context.mounted) return;
      final shouldApply = await showGlassDialog<bool>(
        context: context,
        maxWidth: 860,
        builder: (context) => _AssetDraftReviewDialog(
          title: '${volume.title}章节细纲草稿',
          run: result.run,
          hasExistingContent: widget.outlineDetailYaml.trim().isNotEmpty,
        ),
      );
      if (shouldApply == true) {
        await ref
            .read(novelWorkshopControllerProvider.notifier)
            .applyAssetDraft(result.run.id);
      }
    } on Object {
      // The controller listener renders the error where available.
    }
  }

  Widget _buildValidationStatus(BuildContext context) {
    final yaml = _yamlController.text.trim();
    if (yaml.isEmpty) {
      return const SizedBox.shrink();
    }

    try {
      final document = const OutlineDetailParser().parse(yaml);
      return PersonaStatusPill(
        label:
            'YAML 有效 · ${document.volumes.length} 卷 / ${document.chapters.length} 章',
        icon: Icons.verified_outlined,
        color: const Color(0xFF16825D),
      );
    } on OutlineDetailValidationException catch (e) {
      return PersonaStatusPill(
        label: 'YAML 错误：${e.message}',
        icon: Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
      );
    }
  }
}

class _ChapterPlanningToolbar extends StatelessWidget {
  const _ChapterPlanningToolbar({
    required this.volumeCount,
    required this.planCount,
    required this.completedChapterCount,
    required this.hasVolumes,
    required this.projectId,
    required this.assetRun,
    required this.outlineDetailYaml,
    required this.onCreateVolume,
    required this.onCreatePlan,
    required this.onEditYaml,
  });

  final int volumeCount;
  final int planCount;
  final int completedChapterCount;
  final bool hasVolumes;
  final String projectId;
  final AssetGenerationRun? assetRun;
  final String outlineDetailYaml;
  final VoidCallback onCreateVolume;
  final VoidCallback onCreatePlan;
  final VoidCallback onEditYaml;

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
          final generating =
              assetRun?.status == AssetGenerationStatus.pending ||
              assetRun?.status == AssetGenerationStatus.running;
          final actions = Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: hasVolumes
                ? [
                    _OutlineAssetGenerationButton(
                      projectId: projectId,
                      assetRun: assetRun,
                      outlineDetailYaml: outlineDetailYaml,
                      generating: generating,
                    ),
                    OutlinedButton.icon(
                      onPressed: onEditYaml,
                      icon: const Icon(Icons.code_outlined, size: 18),
                      label: const Text('编辑 YAML'),
                    ),
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
                    _OutlineAssetGenerationButton(
                      projectId: projectId,
                      assetRun: assetRun,
                      outlineDetailYaml: outlineDetailYaml,
                      generating: generating,
                    ),
                    OutlinedButton.icon(
                      onPressed: onEditYaml,
                      icon: const Icon(Icons.code_outlined, size: 18),
                      label: const Text('编辑 YAML'),
                    ),
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

class _OutlineAssetGenerationButton extends ConsumerWidget {
  const _OutlineAssetGenerationButton({
    required this.projectId,
    required this.assetRun,
    required this.outlineDetailYaml,
    required this.generating,
  });

  final String projectId;
  final AssetGenerationRun? assetRun;
  final String outlineDetailYaml;
  final bool generating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(novelWorkshopControllerProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          key: const ValueKey('generate-asset-outlineDetailYaml'),
          onPressed: state.isLoading || generating
              ? null
              : () => _generateDraft(context, ref),
          icon: generating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_fix_high_outlined, size: 18),
          label: Text(generating ? '生成中' : '生成全部分卷'),
        ),
        if (_canReview(assetRun)) ...[
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: state.isLoading
                ? null
                : () => _reviewDraft(context, ref, assetRun!),
            icon: const Icon(Icons.rate_review_outlined, size: 18),
            label: const Text('查看草稿'),
          ),
        ],
      ],
    );
  }

  Future<void> _generateDraft(BuildContext context, WidgetRef ref) async {
    try {
      final result = await ref
          .read(novelWorkshopControllerProvider.notifier)
          .generateAsset(
            projectId: projectId,
            kind: AssetGenerationKind.volumeBlueprintYaml,
          );
      if (!context.mounted) return;
      await _reviewDraft(context, ref, result.run);
    } on Object {
      // The controller listener renders the error where available.
    }
  }

  Future<void> _reviewDraft(
    BuildContext context,
    WidgetRef ref,
    AssetGenerationRun run,
  ) async {
    final shouldApply = await showGlassDialog<bool>(
      context: context,
      maxWidth: 860,
      builder: (context) => _AssetDraftReviewDialog(
        title: '分卷规划草稿',
        run: run,
        hasExistingContent: outlineDetailYaml.trim().isNotEmpty,
      ),
    );
    if (shouldApply != true) return;
    try {
      await ref
          .read(novelWorkshopControllerProvider.notifier)
          .applyAssetDraft(run.id);
      if (!context.mounted) return;
      if (Scaffold.maybeOf(context) != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('细纲草稿已应用。')));
      }
    } on Object catch (error) {
      if (!context.mounted) return;
      if (Scaffold.maybeOf(context) != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('应用失败：$error')));
      }
    }
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
    required this.onGenerateVolumeDetail,
    required this.onCreatePlan,
    required this.onEditPlan,
  });

  final ChapterVolume volume;
  final List<ChapterPlan> plans;
  final List<ProjectChapter> chapters;
  final List<ChapterGenerationRun> runs;
  final VoidCallback onEditVolume;
  final VoidCallback onGenerateVolumeDetail;
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
                    tooltip: '生成本卷细纲',
                    onPressed: onGenerateVolumeDetail,
                    icon: const Icon(Icons.auto_fix_high_outlined),
                  ),
                  IconButton(
                    tooltip: '编辑分卷',
                    onPressed: onEditVolume,
                    icon: const Icon(Icons.tune_outlined),
                  ),
                ],
              ),
              if ([
                    volume.summary,
                    volume.centralConflict,
                    volume.characterProgression,
                    volume.endingHook,
                  ].any((value) => value.trim().isNotEmpty) ||
                  volume.targetLength > 0) ...[
                const SizedBox(height: 10),
                _VolumeBlueprintSummary(volume: volume),
              ],
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

class _VolumeBlueprintSummary extends StatelessWidget {
  const _VolumeBlueprintSummary({required this.volume});

  final ChapterVolume volume;

  @override
  Widget build(BuildContext context) {
    final fields = <String>[
      if (volume.targetLength > 0) '目标 ${volume.targetLength} 字',
      if (volume.summary.trim().isNotEmpty) volume.summary.trim(),
      if (volume.centralConflict.trim().isNotEmpty)
        '矛盾：${volume.centralConflict.trim()}',
      if (volume.characterProgression.trim().isNotEmpty)
        '角色：${volume.characterProgression.trim()}',
      if (volume.endingHook.trim().isNotEmpty) '钩子：${volume.endingHook.trim()}',
    ];
    return Text(
      fields.join('\n'),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        height: 1.45,
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
        : neutralWhenReady
        ? colorScheme.onSurfaceVariant
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
                    : neutralWhenReady
                    ? Icons.radio_button_unchecked
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
                    : neutralWhenReady
                    ? '可选'
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
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        PersonaStatusPill(
          label: assets.voiceProfileMarkdown.trim().isEmpty
              ? 'Voice Profile 可选'
              : 'Voice Profile 已接入',
          icon: assets.voiceProfileMarkdown.trim().isEmpty
              ? Icons.radio_button_unchecked
              : Icons.check_circle_outline,
          color: assets.voiceProfileMarkdown.trim().isEmpty
              ? colorScheme.onSurfaceVariant
              : null,
        ),
        PersonaStatusPill(
          label: assets.storyEngineMarkdown.trim().isEmpty
              ? 'Story Engine 可选'
              : 'Story Engine 已接入',
          icon: assets.storyEngineMarkdown.trim().isEmpty
              ? Icons.radio_button_unchecked
              : Icons.check_circle_outline,
          color: assets.storyEngineMarkdown.trim().isEmpty
              ? colorScheme.onSurfaceVariant
              : null,
        ),
      ],
    );
  }
}

class _RuntimeMemoryOverviewSummary extends StatelessWidget {
  const _RuntimeMemoryOverviewSummary({
    required this.memory,
    required this.onOpen,
  });

  final RuntimeMemoryState memory;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final fields = _memoryViewModels(memory);
    final filled = fields
        .where((field) => field.value.trim().isNotEmpty)
        .toList(growable: false);
    final primary = _firstFilledPreview(memory);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.22),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 620;
            final content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.memory_outlined,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '已记录 ${filled.length}/${fields.length} 项',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  primary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final field in fields)
                      _MemoryCompactPill(
                        icon: field.icon,
                        label: field.title,
                        filled: field.value.trim().isNotEmpty,
                        color: field.color,
                      ),
                  ],
                ),
              ],
            );
            final action = TextButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.open_in_new_outlined, size: 16),
              label: const Text('查看详情'),
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [content, const SizedBox(height: 8), action],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: content),
                const SizedBox(width: 14),
                action,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RuntimeMemoryReadView extends StatefulWidget {
  const _RuntimeMemoryReadView({required this.memory});

  final RuntimeMemoryState memory;

  @override
  State<_RuntimeMemoryReadView> createState() => _RuntimeMemoryReadViewState();
}

class _RuntimeMemoryReadViewState extends State<_RuntimeMemoryReadView> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final fields = _memoryViewModels(widget.memory);
    final activeFields = fields
        .where((field) => field.value.trim().isNotEmpty)
        .length;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '记忆检查表',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _MemoryListCount(label: '$activeFields/${fields.length} 项已记录'),
              ],
            ),
          ),
          const Divider(height: 1),
          for (final entry in fields.indexed)
            _MemoryChecklistRow(
              model: entry.$2,
              expanded: _expandedIndex == entry.$1,
              onTap: () {
                setState(() {
                  _expandedIndex = _expandedIndex == entry.$1 ? null : entry.$1;
                });
              },
            ),
        ],
      ),
    );
  }
}

class _MemoryChecklistRow extends StatelessWidget {
  const _MemoryChecklistRow({
    required this.model,
    required this.expanded,
    required this.onTap,
  });

  final _MemoryViewModel model;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final text = model.value.trim();
    final empty = text.isEmpty;
    final displayText = empty
        ? '未记录'
        : expanded
        ? text
        : _memoryPreviewText(text);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        final title = Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: empty ? colorScheme.outline : colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                model.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
        final body = Text(
          displayText,
          maxLines: expanded ? null : 2,
          overflow: expanded ? null : TextOverflow.ellipsis,
          style: textTheme.bodyMedium?.copyWith(
            height: 1.48,
            color: empty
                ? colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
                : colorScheme.onSurface,
            fontStyle: empty ? FontStyle.italic : null,
          ),
        );
        final arrow = Icon(
          expanded
              ? Icons.keyboard_arrow_up_outlined
              : Icons.keyboard_arrow_down_outlined,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        );

        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (compact)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: title),
                              const SizedBox(width: 12),
                              arrow,
                            ],
                          ),
                          const SizedBox(height: 8),
                          body,
                        ],
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 150, child: title),
                          const SizedBox(width: 14),
                          Expanded(child: body),
                          const SizedBox(width: 12),
                          arrow,
                        ],
                      ),
                    if (expanded && !empty) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.only(
                          left: compact ? 0 : 164,
                          right: compact ? 0 : 32,
                        ),
                        child: Text(
                          model.description,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MemoryListCount extends StatelessWidget {
  const _MemoryListCount({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MemoryCompactPill extends StatelessWidget {
  const _MemoryCompactPill({
    required this.icon,
    required this.label,
    required this.filled,
    required this.color,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = filled ? color : colorScheme.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: filled ? 0.08 : 0.04),
        border: Border.all(color: activeColor.withValues(alpha: 0.24)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: activeColor),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: filled ? null : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryViewModel {
  const _MemoryViewModel({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final String value;
  final Color color;
}

List<_MemoryViewModel> _memoryViewModels(RuntimeMemoryState memory) {
  return [
    _MemoryViewModel(
      icon: Icons.play_circle_outline,
      title: '运行状态',
      description: '故事推进中的即时状态',
      value: memory.runtimeState,
      color: const Color(0xFF16825D),
    ),
    _MemoryViewModel(
      icon: Icons.timeline_outlined,
      title: '剧情线索',
      description: '未解决的伏笔和进行中的线索',
      value: memory.runtimeThreads,
      color: const Color(0xFFB7791F),
    ),
    _MemoryViewModel(
      icon: Icons.menu_book_outlined,
      title: '故事摘要',
      description: '截至目前的整体故事脉络',
      value: memory.storySummary,
      color: const Color(0xFF5967C9),
    ),
    _MemoryViewModel(
      icon: Icons.account_tree_outlined,
      title: '连续性索引',
      description: '高密度触发点和承接提醒',
      value: memory.continuityIndex,
      color: const Color(0xFF00897B),
    ),
    _MemoryViewModel(
      icon: Icons.archive_outlined,
      title: '章节归档',
      description: '已审阅章节的连续性记录',
      value: memory.chapterArchiveMarkdown,
      color: const Color(0xFF3949AB),
    ),
  ];
}

String _firstFilledPreview(RuntimeMemoryState memory) {
  for (final value in [
    memory.runtimeState,
    memory.runtimeThreads,
    memory.storySummary,
    memory.continuityIndex,
    memory.chapterArchiveMarkdown,
  ]) {
    final text = _singleLine(value);
    if (text.isNotEmpty) {
      return text;
    }
  }
  return '已有运行时记忆，进入详情查看完整上下文。';
}

String _memoryPreviewText(String value) {
  final text = _singleLine(value);
  if (text.length <= 32) return text;
  return '${text.substring(0, 32)}...';
}

String _singleLine(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ');
}

class _MemoryPatchReviewList extends ConsumerWidget {
  const _MemoryPatchReviewList({
    required this.memory,
    required this.chapters,
    required this.characters,
    required this.relationships,
  });

  final RuntimeMemoryState memory;
  final List<ProjectChapter> chapters;
  final AsyncValue<List<NovelCharacter>> characters;
  final AsyncValue<List<NovelRelationship>> relationships;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = chapters
        .where(
          (chapter) =>
              chapter.memorySyncStatus == MemorySyncStatus.pendingReview,
        )
        .toList(growable: false);
    if (pending.isEmpty) {
      return const SizedBox.shrink();
    }
    final controllerState = ref.watch(novelWorkshopControllerProvider);
    final currentCharacters = characters.hasValue
        ? characters.value!
        : const <NovelCharacter>[];
    final currentRelationships = relationships.hasValue
        ? relationships.value!
        : const <NovelRelationship>[];
    return PersonaPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PersonaSectionHeader(
            title: '待审阅记忆 Patch',
            description: 'AI 生成的 Runtime Memory、角色卡片和关系图变更需要确认后才会应用。',
          ),
          const SizedBox(height: 10),
          for (final chapter in pending)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '第 ${chapter.chapterIndex} 章 · ${chapter.title}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      _MemoryPatchDiffPreview(
                        preview: _buildMemoryPatchPreview(
                          chapter: chapter,
                          memory: memory,
                          characters: currentCharacters,
                          relationships: currentRelationships,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: controllerState.isLoading
                                ? null
                                : () => _discardPatch(context, ref, chapter),
                            icon: const Icon(Icons.block_outlined, size: 18),
                            label: const Text('丢弃 Patch'),
                          ),
                          FilledButton.icon(
                            onPressed: controllerState.isLoading
                                ? null
                                : () => _applyPatch(context, ref, chapter),
                            icon: const Icon(Icons.check_outlined, size: 18),
                            label: const Text('应用 Patch'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _applyPatch(
    BuildContext context,
    WidgetRef ref,
    ProjectChapter chapter,
  ) async {
    try {
      await ref
          .read(novelWorkshopControllerProvider.notifier)
          .applyMemorySyncPatch(chapter.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('记忆 Patch 已应用。')));
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('应用失败：$error')));
    }
  }

  Future<void> _discardPatch(
    BuildContext context,
    WidgetRef ref,
    ProjectChapter chapter,
  ) async {
    try {
      await ref
          .read(novelWorkshopControllerProvider.notifier)
          .discardMemorySyncPatch(chapter.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('记忆 Patch 已丢弃。')));
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('丢弃失败：$error')));
    }
  }
}

class _MemoryPatchDiffPreview extends StatelessWidget {
  const _MemoryPatchDiffPreview({required this.preview});

  final _MemoryPatchPreview preview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (preview.parseError != null) ...[
          InlineError(message: preview.parseError!),
          const SizedBox(height: 8),
        ],
        _PatchDiffSectionView(section: preview.runtimeMemorySection),
        const SizedBox(height: 8),
        _PatchDiffSectionView(section: preview.charactersSection),
        const SizedBox(height: 8),
        _PatchDiffSectionView(section: preview.relationshipsSection),
        if (preview.rawYaml.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                splashColor: Colors.transparent,
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                leading: const Icon(Icons.code_outlined, size: 18),
                title: const Text('Raw YAML'),
                children: [CodeBlock(text: preview.rawYaml, expand: true)],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PatchDiffSectionView extends StatelessWidget {
  const _PatchDiffSectionView({required this.section});

  final _PatchDiffSection section;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasChanges = section.entries.isNotEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.28,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 9),
                child: Row(
                  children: [
                    Icon(
                      section.icon,
                      size: 17,
                      color: hasChanges
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(section.title, style: textTheme.titleSmall),
                    ),
                    _DiffStatChip(
                      label: hasChanges
                          ? '${section.entries.length} 项变更'
                          : '无变更',
                      color: hasChanges
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            if (hasChanges)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in section.entries) ...[
                      _PatchDiffEntryView(entry: entry),
                      if (entry != section.entries.last)
                        const SizedBox(height: 10),
                    ],
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '本分区没有待应用变更。',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PatchDiffEntryView extends StatelessWidget {
  const _PatchDiffEntryView({required this.entry});

  final _PatchDiffEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          'diff -- ${entry.title}',
          style: textTheme.labelMedium?.copyWith(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        _GitDiffBlock(oldText: entry.oldText, newText: entry.newText),
      ],
    );
  }
}

class _GitDiffBlock extends StatelessWidget {
  const _GitDiffBlock({required this.oldText, required this.newText});

  final String oldText;
  final String newText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final diffs = dmp.diff(
      oldText.trim(),
      newText.trim(),
      timeout: 0.25,
      checklines: true,
    );
    dmp.cleanupSemantic(diffs);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.22),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(6),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(10),
        child: SelectableText.rich(
          TextSpan(
            style: TextStyle(
              color: colorScheme.onSurface,
              fontFamily: 'monospace',
              fontSize: 12.5,
              height: 1.45,
            ),
            children: _buildGitDiffSpans(context, diffs),
          ),
        ),
      ),
    );
  }

  List<TextSpan> _buildGitDiffSpans(
    BuildContext context,
    List<dmp.Diff> diffs,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseStyle = TextStyle(
      color: colorScheme.onSurface,
      fontFamily: 'monospace',
      fontSize: 12.5,
      height: 1.45,
    );
    final deleteStyle = baseStyle.copyWith(
      backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.55),
      color: colorScheme.onErrorContainer,
    );
    final insertStyle = baseStyle.copyWith(
      backgroundColor: const Color(0xFF16825D).withValues(alpha: 0.14),
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w600,
    );
    final spans = <TextSpan>[];
    for (final diff in diffs) {
      final text = diff.text;
      if (text.isEmpty) {
        continue;
      }
      switch (diff.operation) {
        case dmp.DIFF_EQUAL:
          spans.add(
            TextSpan(text: _prefixDiffText(text, ' '), style: baseStyle),
          );
        case dmp.DIFF_DELETE:
          spans.add(
            TextSpan(text: _prefixDiffText(text, '-'), style: deleteStyle),
          );
        case dmp.DIFF_INSERT:
          spans.add(
            TextSpan(text: _prefixDiffText(text, '+'), style: insertStyle),
          );
      }
    }
    if (spans.isEmpty) {
      return [TextSpan(text: ' 无内容', style: baseStyle)];
    }
    return spans;
  }
}

String _prefixDiffText(String value, String prefix) {
  final normalized = value.replaceAll('\r\n', '\n');
  final trailingNewline = normalized.endsWith('\n');
  final lines = normalized.split('\n');
  if (trailingNewline) {
    lines.removeLast();
  }
  final joined = lines.map((line) => '$prefix$line').join('\n');
  return trailingNewline ? '$joined\n' : joined;
}

class _MemoryPatchPreview {
  const _MemoryPatchPreview({
    required this.runtimeMemorySection,
    required this.charactersSection,
    required this.relationshipsSection,
    required this.rawYaml,
    this.parseError,
  });

  final _PatchDiffSection runtimeMemorySection;
  final _PatchDiffSection charactersSection;
  final _PatchDiffSection relationshipsSection;
  final String rawYaml;
  final String? parseError;
}

class _PatchDiffSection {
  const _PatchDiffSection({
    required this.title,
    required this.icon,
    required this.entries,
  });

  final String title;
  final IconData icon;
  final List<_PatchDiffEntry> entries;
}

class _PatchDiffEntry {
  const _PatchDiffEntry({
    required this.title,
    required this.oldText,
    required this.newText,
  });

  final String title;
  final String oldText;
  final String newText;
}

class _PreviewCharacter {
  const _PreviewCharacter({
    required this.name,
    required this.aliases,
    required this.tags,
    required this.faction,
    required this.role,
    required this.longTermGoal,
    required this.currentStatus,
    required this.secrets,
    required this.firstChapterIndex,
    required this.lastChapterIndex,
  });

  factory _PreviewCharacter.fromCharacter(NovelCharacter character) {
    return _PreviewCharacter(
      name: character.name,
      aliases: character.aliases,
      tags: character.tags,
      faction: character.faction,
      role: character.role,
      longTermGoal: character.longTermGoal,
      currentStatus: character.currentStatus,
      secrets: character.secrets,
      firstChapterIndex: character.firstChapterIndex,
      lastChapterIndex: character.lastChapterIndex,
    );
  }

  final String name;
  final String aliases;
  final String tags;
  final String faction;
  final String role;
  final String longTermGoal;
  final String currentStatus;
  final String secrets;
  final int? firstChapterIndex;
  final int? lastChapterIndex;

  _PreviewCharacter merge(CharacterDraft draft) {
    return _PreviewCharacter(
      name: name,
      aliases: _mergePatchString(
        draft.fields,
        'aliases',
        draft.aliases,
        aliases,
      ),
      tags: _mergePatchString(draft.fields, 'tags', draft.tags, tags),
      faction: _mergePatchString(
        draft.fields,
        'faction',
        draft.faction,
        faction,
      ),
      role: _mergePatchString(draft.fields, 'role', draft.role, role),
      longTermGoal: _mergePatchString(
        draft.fields,
        'longTermGoal',
        draft.longTermGoal,
        longTermGoal,
      ),
      currentStatus: _mergePatchString(
        draft.fields,
        'currentStatus',
        draft.currentStatus,
        currentStatus,
      ),
      secrets: _mergePatchString(
        draft.fields,
        'secrets',
        draft.secrets,
        secrets,
      ),
      firstChapterIndex: _mergePatchInt(
        draft.fields,
        'firstChapterIndex',
        draft.firstChapterIndex,
        firstChapterIndex,
      ),
      lastChapterIndex: _mergePatchInt(
        draft.fields,
        'lastChapterIndex',
        draft.lastChapterIndex,
        lastChapterIndex,
      ),
    );
  }

  String toDiffText() {
    return _formatPatchFields({
      'name': name,
      'aliases': aliases,
      'tags': tags,
      'faction': faction,
      'role': role,
      'longTermGoal': longTermGoal,
      'currentStatus': currentStatus,
      'secrets': secrets,
      'firstChapterIndex': firstChapterIndex?.toString() ?? '',
      'lastChapterIndex': lastChapterIndex?.toString() ?? '',
    });
  }
}

class _PreviewRelationship {
  const _PreviewRelationship({
    required this.fromName,
    required this.toName,
    required this.relationshipType,
    required this.strength,
    required this.status,
    required this.description,
    required this.lastChangedChapterIndex,
  });

  factory _PreviewRelationship.fromRelationship(
    NovelRelationship relationship,
    Map<String, NovelCharacter> charactersById,
  ) {
    return _PreviewRelationship(
      fromName:
          charactersById[relationship.fromCharacterId]?.name ??
          relationship.fromCharacterId,
      toName:
          charactersById[relationship.toCharacterId]?.name ??
          relationship.toCharacterId,
      relationshipType: relationship.relationshipType,
      strength: relationship.strength,
      status: relationship.status,
      description: relationship.description,
      lastChangedChapterIndex: relationship.lastChangedChapterIndex,
    );
  }

  final String fromName;
  final String toName;
  final String relationshipType;
  final int strength;
  final String status;
  final String description;
  final int? lastChangedChapterIndex;

  String get key => _relationshipKey(fromName, toName);

  _PreviewRelationship merge(RelationshipDraft draft) {
    return _PreviewRelationship(
      fromName: fromName,
      toName: toName,
      relationshipType: _mergePatchString(
        draft.fields,
        'type',
        draft.relationshipType,
        relationshipType,
      ),
      strength:
          _mergePatchInt(
            draft.fields,
            'strength',
            draft.strength.clamp(-5, 5),
            strength,
          ) ??
          0,
      status: _mergePatchString(draft.fields, 'status', draft.status, status),
      description: _mergePatchString(
        draft.fields,
        'description',
        draft.description,
        description,
      ),
      lastChangedChapterIndex: _mergePatchInt(
        draft.fields,
        'lastChangedChapterIndex',
        draft.lastChangedChapterIndex,
        lastChangedChapterIndex,
      ),
    );
  }

  String toDiffText() {
    return _formatPatchFields({
      'from': fromName,
      'to': toName,
      'type': relationshipType,
      'strength': strength.toString(),
      'status': status,
      'description': description,
      'lastChangedChapterIndex': lastChangedChapterIndex?.toString() ?? '',
    });
  }
}

_MemoryPatchPreview _buildMemoryPatchPreview({
  required ProjectChapter chapter,
  required RuntimeMemoryState memory,
  required List<NovelCharacter> characters,
  required List<NovelRelationship> relationships,
}) {
  final rawYaml = chapter.memorySyncPatchYaml.trim();
  CharacterGraphDocument? graphPatch;
  String? parseError;
  if (rawYaml.isNotEmpty) {
    try {
      if (_hasCharacterGraphPatchForPreview(rawYaml)) {
        graphPatch = const CharacterGraphParser().parse(rawYaml);
      }
    } on CharacterGraphValidationException catch (error) {
      parseError = error.message;
    } on Object catch (error) {
      parseError = '无法解析 Patch YAML：$error';
    }
  }
  return _MemoryPatchPreview(
    runtimeMemorySection: _buildRuntimeMemoryPatchSection(chapter, memory),
    charactersSection: _buildCharacterPatchSection(
      characters,
      graphPatch?.characters ?? const [],
    ),
    relationshipsSection: _buildRelationshipPatchSection(
      characters,
      relationships,
      graphPatch?.relationships ?? const [],
    ),
    rawYaml: rawYaml,
    parseError: parseError,
  );
}

bool _hasCharacterGraphPatchForPreview(String rawYaml) {
  final parsed = loadYaml(rawYaml);
  if (parsed is! YamlMap) {
    throw const CharacterGraphValidationException('Patch YAML 根节点必须是对象。');
  }
  return _hasYamlListItems(parsed['characters']) ||
      _hasYamlListItems(parsed['relationships']);
}

bool _hasYamlListItems(Object? value) {
  if (value is YamlList) {
    return value.isNotEmpty;
  }
  if (value is List<Object?>) {
    return value.isNotEmpty;
  }
  return false;
}

_PatchDiffSection _buildRuntimeMemoryPatchSection(
  ProjectChapter chapter,
  RuntimeMemoryState current,
) {
  final entries = <_PatchDiffEntry>[
    if (chapter.memorySyncProposedRuntimeState.trim().isNotEmpty)
      _PatchDiffEntry(
        title: 'runtimeMemory/runtimeState',
        oldText: current.runtimeState,
        newText: chapter.memorySyncProposedRuntimeState,
      ),
    if (chapter.memorySyncProposedRuntimeThreads.trim().isNotEmpty)
      _PatchDiffEntry(
        title: 'runtimeMemory/runtimeThreads',
        oldText: current.runtimeThreads,
        newText: chapter.memorySyncProposedRuntimeThreads,
      ),
    if (chapter.memorySyncProposedStorySummary.trim().isNotEmpty)
      _PatchDiffEntry(
        title: 'runtimeMemory/storySummary',
        oldText: current.storySummary,
        newText: chapter.memorySyncProposedStorySummary,
      ),
    if (chapter.memorySyncProposedContinuityIndex.trim().isNotEmpty)
      _PatchDiffEntry(
        title: 'runtimeMemory/continuityIndex',
        oldText: current.continuityIndex,
        newText: chapter.memorySyncProposedContinuityIndex,
      ),
    if (chapter.memorySyncProposedChapterArchiveMarkdown.trim().isNotEmpty)
      _PatchDiffEntry(
        title: 'runtimeMemory/chapterArchiveMarkdown',
        oldText: current.chapterArchiveMarkdown,
        newText: _mergeChapterArchivePreview(
          current.chapterArchiveMarkdown,
          chapter.memorySyncProposedChapterArchiveMarkdown,
        ),
      ),
  ];
  return _PatchDiffSection(
    title: 'Runtime Memory',
    icon: Icons.memory_outlined,
    entries: entries.where((entry) => entry.oldText != entry.newText).toList(),
  );
}

_PatchDiffSection _buildCharacterPatchSection(
  List<NovelCharacter> currentCharacters,
  List<CharacterDraft> drafts,
) {
  final currentByName = {
    for (final character in currentCharacters)
      character.name.trim(): _PreviewCharacter.fromCharacter(character),
  };
  final entries = <_PatchDiffEntry>[];
  for (final draft in drafts) {
    final key = draft.name.trim();
    final current = currentByName[key];
    final next =
        current?.merge(draft) ??
        _PreviewCharacter(
          name: draft.name,
          aliases: draft.aliases,
          tags: draft.tags,
          faction: draft.faction,
          role: draft.role,
          longTermGoal: draft.longTermGoal,
          currentStatus: draft.currentStatus,
          secrets: draft.secrets,
          firstChapterIndex: draft.firstChapterIndex,
          lastChapterIndex: draft.lastChapterIndex,
        );
    final oldText = current?.toDiffText() ?? '';
    final newText = next.toDiffText();
    if (oldText != newText) {
      entries.add(
        _PatchDiffEntry(
          title: 'characters/$key',
          oldText: oldText,
          newText: newText,
        ),
      );
    }
  }
  return _PatchDiffSection(
    title: 'Characters',
    icon: Icons.groups_outlined,
    entries: entries,
  );
}

_PatchDiffSection _buildRelationshipPatchSection(
  List<NovelCharacter> characters,
  List<NovelRelationship> relationships,
  List<RelationshipDraft> drafts,
) {
  final charactersById = {
    for (final character in characters) character.id: character,
  };
  final currentByKey = {
    for (final relationship in relationships)
      _PreviewRelationship.fromRelationship(relationship, charactersById).key:
          _PreviewRelationship.fromRelationship(relationship, charactersById),
  };
  final entries = <_PatchDiffEntry>[];
  for (final draft in drafts) {
    final key = _relationshipKey(draft.fromName, draft.toName);
    final current = currentByKey[key];
    final next =
        current?.merge(draft) ??
        _PreviewRelationship(
          fromName: draft.fromName,
          toName: draft.toName,
          relationshipType: draft.relationshipType,
          strength: draft.strength.clamp(-5, 5),
          status: draft.status,
          description: draft.description,
          lastChangedChapterIndex: draft.lastChangedChapterIndex,
        );
    final oldText = current?.toDiffText() ?? '';
    final newText = next.toDiffText();
    if (oldText != newText) {
      entries.add(
        _PatchDiffEntry(
          title: 'relationships/$key',
          oldText: oldText,
          newText: newText,
        ),
      );
    }
  }
  return _PatchDiffSection(
    title: 'Relationships',
    icon: Icons.hub_outlined,
    entries: entries,
  );
}

String _mergePatchString(
  Set<String> fields,
  String key,
  String patchValue,
  String existingValue,
) {
  return fields.contains(key) ? patchValue.trim() : existingValue.trim();
}

int? _mergePatchInt(
  Set<String> fields,
  String key,
  int? patchValue,
  int? existingValue,
) {
  return fields.contains(key) ? patchValue : existingValue;
}

String _mergeChapterArchivePreview(String current, String patchValue) {
  final patch = patchValue.trim();
  if (patch.isEmpty) {
    return current.trim();
  }
  final existing = current.trim();
  if (existing.isEmpty) {
    return patch;
  }
  return '$existing\n\n$patch';
}

String _relationshipKey(String fromName, String toName) {
  return '${fromName.trim()} -> ${toName.trim()}';
}

String _formatPatchFields(Map<String, String> fields) {
  return fields.entries
      .where((entry) => entry.value.trim().isNotEmpty)
      .map((entry) => '${entry.key}: ${entry.value.trim()}')
      .join('\n');
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

class _RuntimeMemoryEmptyPreview extends StatelessWidget {
  const _RuntimeMemoryEmptyPreview();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = [
      (
        icon: Icons.play_circle_outline,
        label: '运行状态',
        description: '故事推进中的状态',
        color: const Color(0xFF16825D),
      ),
      (
        icon: Icons.timeline_outlined,
        label: '剧情线索',
        description: '未解决的伏笔与暗线',
        color: const Color(0xFFA66A00),
      ),
      (
        icon: Icons.menu_book_outlined,
        label: '故事摘要',
        description: '整体故事脉络',
        color: colorScheme.primary,
      ),
      (
        icon: Icons.account_tree_outlined,
        label: '连续性索引',
        description: '承接触发点',
        color: const Color(0xFF00897B),
      ),
      (
        icon: Icons.archive_outlined,
        label: '章节归档',
        description: '审阅后的历史记录',
        color: const Color(0xFF3949AB),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 430;
        final children = [
          for (final item in items)
            _CategoryPreview(
              icon: item.icon,
              label: item.label,
              description: item.description,
              color: item.color,
            ),
        ];

        if (compact) {
          return Column(
            children: [
              for (final child in children) ...[
                child,
                if (child != children.last) const SizedBox(height: 10),
              ],
            ],
          );
        }

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            for (final child in children)
              SizedBox(width: (constraints.maxWidth - 10) / 2, child: child),
          ],
        );
      },
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
    this.minLines = 3,
    this.maxLines = 8,
  });

  final TextEditingController controller;
  final IconData icon;
  final String label;
  final String description;
  final Color accentColor;
  final int minLines;
  final int maxLines;

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
            minLines: minLines,
            maxLines: maxLines,
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
    final memoryStatus = chapter == null
        ? null
        : _memorySyncStatusPill(context, chapter!.memorySyncStatus);

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
                if (memoryStatus != null) ...[
                  const SizedBox(height: 8),
                  memoryStatus,
                ],
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

Widget? _memorySyncStatusPill(BuildContext context, MemorySyncStatus status) {
  final colorScheme = Theme.of(context).colorScheme;
  return switch (status) {
    MemorySyncStatus.idle => null,
    MemorySyncStatus.checking => PersonaStatusPill(
      label: '记忆检查中',
      icon: Icons.sync,
      color: colorScheme.primary,
    ),
    MemorySyncStatus.pendingReview => PersonaStatusPill(
      label: 'Patch 待审阅',
      icon: Icons.rate_review_outlined,
      color: colorScheme.primary,
    ),
    MemorySyncStatus.synced => const PersonaStatusPill(
      label: 'Patch 已应用',
      icon: Icons.check_circle_outline,
      color: Color(0xFF16825D),
    ),
    MemorySyncStatus.noChange => PersonaStatusPill(
      label: '记忆无变化',
      icon: Icons.remove_circle_outline,
      color: colorScheme.onSurfaceVariant,
    ),
    MemorySyncStatus.discarded => PersonaStatusPill(
      label: 'Patch 已丢弃',
      icon: Icons.block_outlined,
      color: colorScheme.onSurfaceVariant,
    ),
    MemorySyncStatus.failed => PersonaStatusPill(
      label: 'Patch 失败',
      icon: Icons.error_outline,
      color: colorScheme.error,
    ),
    MemorySyncStatus.stale => PersonaStatusPill(
      label: 'Patch 已过期',
      icon: Icons.history_toggle_off_outlined,
      color: colorScheme.tertiary,
    ),
  };
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
    required this.isImportedEnrichment,
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
  final bool isImportedEnrichment;
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
            canCreatePlan: !widget.isImportedEnrichment,
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
                  canCreatePlan: !widget.isImportedEnrichment,
                  onSaveChapter: widget.onSaveChapter,
                  onGenerate: widget.onGenerate,
                  generateLabel: widget.isImportedEnrichment ? '加料' : '生成',
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
                canCreatePlan: !widget.isImportedEnrichment,
                onSaveChapter: widget.onSaveChapter,
                onGenerate: widget.onGenerate,
                generateLabel: widget.isImportedEnrichment ? '加料' : '生成',
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
    required this.canCreatePlan,
    required this.onSaveChapter,
    required this.onGenerate,
    required this.generateLabel,
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
  final bool canCreatePlan;
  final VoidCallback? onSaveChapter;
  final VoidCallback? onGenerate;
  final String generateLabel;

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
                  if (canCreatePlan)
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
                    label: Text(generateLabel),
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
    required this.canCreatePlan,
  });

  final List<ChapterVolume> volumes;
  final List<ChapterPlan> plans;
  final List<ProjectChapter> chapters;
  final List<ChapterGenerationRun> runs;
  final String? selectedPlanId;
  final ValueChanged<ChapterPlan> onSelectPlan;
  final VoidCallback onCreatePlan;
  final bool canCreatePlan;

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
                if (canCreatePlan)
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
                  child: _NavigatorEmptyState(
                    onCreatePlan: onCreatePlan,
                    canCreatePlan: canCreatePlan,
                  ),
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
  const _NavigatorEmptyState({
    required this.onCreatePlan,
    required this.canCreatePlan,
  });

  final VoidCallback onCreatePlan;
  final bool canCreatePlan;

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
        if (canCreatePlan) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onCreatePlan,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('新建章节'),
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
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
    final memoryStatus = chapter == null
        ? null
        : _memorySyncStatusPill(context, chapter!.memorySyncStatus);

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
                    if (memoryStatus != null) ...[
                      const SizedBox(height: 6),
                      memoryStatus,
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
          final warnings = _actionablePromptWarnings(asset);
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

class _EnrichmentRequest {
  const _EnrichmentRequest({
    required this.chapterIds,
    required this.instruction,
    required this.expansionRatioPercent,
  });

  final List<String> chapterIds;
  final String instruction;
  final int expansionRatioPercent;
}

class _EnrichmentRequestDialog extends StatefulWidget {
  const _EnrichmentRequestDialog({
    required this.chapters,
    required this.initialChapterIds,
  });

  final List<ProjectChapter> chapters;
  final Set<String> initialChapterIds;

  @override
  State<_EnrichmentRequestDialog> createState() =>
      _EnrichmentRequestDialogState();
}

class _EnrichmentRequestDialogState extends State<_EnrichmentRequestDialog> {
  final _instructionController = TextEditingController();
  late final Set<String> _selectedChapterIds;
  String? _focusedChapterId;
  double _ratio = 20;

  static const _quickInstructions = [
    '增强心理描写',
    '补足环境描写',
    '强化冲突张力',
    '丰富对话层次',
    '加深感官细节',
  ];

  static const _ratioPresets = [10, 20, 50, 100];

  @override
  void initState() {
    super.initState();
    _selectedChapterIds = widget.initialChapterIds.isEmpty
        ? {widget.chapters.first.id}
        : widget.initialChapterIds
              .where((id) => widget.chapters.any((chapter) => chapter.id == id))
              .toSet();
    if (_selectedChapterIds.isEmpty && widget.chapters.isNotEmpty) {
      _selectedChapterIds.add(widget.chapters.first.id);
    }
    _focusedChapterId = _selectedChapterIds.isNotEmpty
        ? _selectedChapterIds.first
        : widget.chapters.first.id;
  }

  @override
  void dispose() {
    _instructionController.dispose();
    super.dispose();
  }

  void _submit() {
    final instruction = _instructionController.text.trim();
    if (instruction.isEmpty || _selectedChapterIds.isEmpty) return;
    Navigator.of(context).pop(
      _EnrichmentRequest(
        chapterIds: _selectedChapterIds.toList(growable: false),
        instruction: instruction,
        expansionRatioPercent: _ratio.round().clamp(1, 100),
      ),
    );
  }

  void _appendInstruction(String text) {
    final current = _instructionController.text.trim();
    if (current.isEmpty) {
      _instructionController.text = text;
    } else if (!current.contains(text)) {
      _instructionController.text = '$current，$text';
    }
    setState(() {});
  }

  ProjectChapter? get _previewChapter {
    if (_focusedChapterId == null) return null;
    for (final ch in widget.chapters) {
      if (ch.id == _focusedChapterId) return ch;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final canSubmit = _instructionController.text.trim().isNotEmpty;
    final previewChapter = _previewChapter;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogHeader(colorScheme, textTheme),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWorkflowSection(
                      colorScheme,
                      textTheme,
                      previewChapter,
                      compact: compact,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: colorScheme.outlineVariant),
            const SizedBox(height: 14),
            _buildActionRow(colorScheme, textTheme, canSubmit),
          ],
        );
      },
    );
  }

  Widget _buildDialogHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.auto_fix_high_outlined,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('章节加料', style: textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(
                '选择章节、填写加料方向，并生成可预览的改写结果。',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkflowSection(
    ColorScheme colorScheme,
    TextTheme textTheme,
    ProjectChapter? previewChapter, {
    required bool compact,
  }) {
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildChapterList(colorScheme, textTheme, compact: true),
          const SizedBox(height: 12),
          _buildRightWorkflowColumn(
            colorScheme,
            textTheme,
            previewChapter,
            compact: true,
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: _buildChapterList(colorScheme, textTheme)),
        const SizedBox(width: 14),
        Expanded(
          flex: 7,
          child: _buildRightWorkflowColumn(
            colorScheme,
            textTheme,
            previewChapter,
          ),
        ),
      ],
    );
  }

  Widget _buildRightWorkflowColumn(
    ColorScheme colorScheme,
    TextTheme textTheme,
    ProjectChapter? previewChapter, {
    bool compact = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPreviewPane(
          colorScheme,
          textTheme,
          previewChapter,
          compact: compact,
        ),
        const SizedBox(height: 12),
        compact
            ? _buildInstructionCardCompact(colorScheme, textTheme)
            : _buildInstructionCard(colorScheme, textTheme),
        const SizedBox(height: 12),
        _buildRatioCard(colorScheme, textTheme, compact: compact),
      ],
    );
  }

  Widget _buildSurface({
    required ColorScheme colorScheme,
    required Widget child,
    Color? backgroundColor,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }

  Widget _buildInstructionCard(ColorScheme colorScheme, TextTheme textTheme) {
    return _buildSurface(
      colorScheme: colorScheme,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('加料指令', style: textTheme.titleSmall),
                const SizedBox(width: 8),
                Text(
                  '可点选快捷方向后继续补充',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final label in _quickInstructions)
                  ActionChip(
                    label: Text(label),
                    labelStyle: textTheme.bodySmall,
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(color: colorScheme.outlineVariant),
                    backgroundColor: colorScheme.surface,
                    onPressed: () => _appendInstruction(label),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _instructionController,
              minLines: 4,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '输入具体加料要求...',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
                filled: true,
                fillColor: colorScheme.surfaceContainerLowest,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionCardCompact(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return _buildSurface(
      colorScheme: colorScheme,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('加料指令', style: textTheme.titleSmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final label in _quickInstructions)
                  ActionChip(
                    label: Text(label),
                    labelStyle: textTheme.bodySmall,
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(color: colorScheme.outlineVariant),
                    backgroundColor: colorScheme.surface,
                    onPressed: () => _appendInstruction(label),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _instructionController,
              minLines: 4,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '输入具体加料要求...',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
                filled: true,
                fillColor: colorScheme.surfaceContainerLowest,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatioCard(
    ColorScheme colorScheme,
    TextTheme textTheme, {
    bool compact = false,
  }) {
    if (compact) {
      return _buildSurface(
        colorScheme: colorScheme,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('扩写比例', style: textTheme.titleSmall)),
                  Text(
                    '${_ratio.round()}%',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '在原文基础上扩充约 ${_ratio.round()}% 字数',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Slider(
                value: _ratio,
                min: 1,
                max: 100,
                divisions: 99,
                label: '${_ratio.round()}%',
                onChanged: (value) => setState(() => _ratio = value),
              ),
              const SizedBox(height: 2),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final preset in _ratioPresets)
                    ChoiceChip(
                      label: Text('$preset%'),
                      labelStyle: textTheme.bodySmall,
                      selected: _ratio.round() == preset,
                      onSelected: (_) =>
                          setState(() => _ratio = preset.toDouble()),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return _buildSurface(
      colorScheme: colorScheme,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 108,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('扩写比例', style: textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    '${_ratio.round()}%',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '在原文基础上扩充约 ${_ratio.round()}% 字数',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Slider(
                    value: _ratio,
                    min: 1,
                    max: 100,
                    divisions: 99,
                    label: '${_ratio.round()}%',
                    onChanged: (value) => setState(() => _ratio = value),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final preset in _ratioPresets)
                        ChoiceChip(
                          label: Text('$preset%'),
                          labelStyle: textTheme.bodySmall,
                          selected: _ratio.round() == preset,
                          onSelected: (_) =>
                              setState(() => _ratio = preset.toDouble()),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow(
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool canSubmit,
  ) {
    final summary = Text(
      _selectedChapterIds.isEmpty
          ? '至少选择 1 个章节后才能生成预览。'
          : '将为已选 ${_selectedChapterIds.length} 章生成预览，应用前不会覆盖正文。',
      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
    );
    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: canSubmit && _selectedChapterIds.isNotEmpty
              ? _submit
              : null,
          icon: const Icon(Icons.auto_fix_high_outlined, size: 18),
          label: Text('生成 ${_selectedChapterIds.length} 章预览'),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Align(alignment: Alignment.centerLeft, child: summary),
              const SizedBox(height: 10),
              actions,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: summary),
            const SizedBox(width: 16),
            actions,
          ],
        );
      },
    );
  }

  Widget _buildChapterList(
    ColorScheme colorScheme,
    TextTheme textTheme, {
    bool compact = false,
  }) {
    return _buildSurface(
      colorScheme: colorScheme,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
            child: Row(
              children: [
                Text('选择章节', style: textTheme.titleMedium),
                const SizedBox(width: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    child: Text(
                      '${_selectedChapterIds.length}/${widget.chapters.length}',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() {
                    if (_selectedChapterIds.length == widget.chapters.length) {
                      _selectedChapterIds.clear();
                    } else {
                      _selectedChapterIds.addAll(
                        widget.chapters.map((ch) => ch.id),
                      );
                    }
                  }),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    _selectedChapterIds.length == widget.chapters.length
                        ? '清空'
                        : '全选',
                    style: textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: compact ? 220 : 520,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: widget.chapters.length,
              itemBuilder: (context, index) => _buildChapterRow(
                colorScheme,
                textTheme,
                widget.chapters[index],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterRow(
    ColorScheme colorScheme,
    TextTheme textTheme,
    ProjectChapter chapter,
  ) {
    final isSelected = _selectedChapterIds.contains(chapter.id);
    final isFocused = _focusedChapterId == chapter.id;

    return InkWell(
      onTap: () => setState(() {
        _focusedChapterId = chapter.id;
        if (isSelected) {
          _selectedChapterIds.remove(chapter.id);
        } else {
          _selectedChapterIds.add(chapter.id);
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isFocused
              ? colorScheme.primary.withValues(alpha: 0.06)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (selected) => setState(() {
                if (selected ?? false) {
                  _selectedChapterIds.add(chapter.id);
                } else {
                  _selectedChapterIds.remove(chapter.id);
                }
                _focusedChapterId = chapter.id;
              }),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '第 ${chapter.chapterIndex} 章 · ${chapter.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium,
                  ),
                  Text(
                    '${chapter.contentMarkdown.trim().length} 字',
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

  Widget _buildPreviewPane(
    ColorScheme colorScheme,
    TextTheme textTheme,
    ProjectChapter? chapter, {
    bool compact = false,
  }) {
    return _buildSurface(
      colorScheme: colorScheme,
      backgroundColor: colorScheme.surfaceContainerLowest,
      child: SizedBox(
        height: compact ? 220 : 196,
        child: chapter == null
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    '点击左侧章节查看预览',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '第 ${chapter.chapterIndex} 章 · ${chapter.title}',
                            style: textTheme.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${chapter.contentMarkdown.trim().length} 字',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(14),
                      child: SelectableText(
                        chapter.contentMarkdown.trim().length > 420
                            ? '${chapter.contentMarkdown.trim().substring(0, 420)}...'
                            : chapter.contentMarkdown.trim(),
                        style: textTheme.bodySmall?.copyWith(
                          height: 1.55,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
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

class _AssetDraftReviewDialog extends StatelessWidget {
  const _AssetDraftReviewDialog({
    required this.title,
    required this.run,
    required this.hasExistingContent,
  });

  final String title;
  final AssetGenerationRun run;
  final bool hasExistingContent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 720),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rate_review_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          if (hasExistingContent) ...[
            const SizedBox(height: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.secondary.withValues(alpha: 0.28),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Icon(
                      Icons.merge_type_outlined,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('应用草稿会合并到当前已保存内容，未出现在草稿中的部分会保留。'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Flexible(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: SelectableText(
                  run.draftMarkdown.trim().isEmpty
                      ? '草稿为空。'
                      : run.draftMarkdown,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.55),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: run.draftMarkdown.trim().isEmpty
                    ? null
                    : () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.check_outlined, size: 18),
                label: Text(hasExistingContent ? '合并并应用' : '应用草稿'),
              ),
            ],
          ),
        ],
      ),
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
  late final TextEditingController _targetLengthController;
  late final TextEditingController _summaryController;
  late final TextEditingController _centralConflictController;
  late final TextEditingController _characterProgressionController;
  late final TextEditingController _endingHookController;

  @override
  void initState() {
    super.initState();
    _indexController = TextEditingController(
      text: '${widget.volume?.volumeIndex ?? widget.nextIndex}',
    );
    _titleController = TextEditingController(text: widget.volume?.title ?? '');
    _targetLengthController = TextEditingController(
      text: '${widget.volume?.targetLength ?? 0}',
    );
    _summaryController = TextEditingController(
      text: widget.volume?.summary ?? '',
    );
    _centralConflictController = TextEditingController(
      text: widget.volume?.centralConflict ?? '',
    );
    _characterProgressionController = TextEditingController(
      text: widget.volume?.characterProgression ?? '',
    );
    _endingHookController = TextEditingController(
      text: widget.volume?.endingHook ?? '',
    );
  }

  @override
  void dispose() {
    _indexController.dispose();
    _titleController.dispose();
    _targetLengthController.dispose();
    _summaryController.dispose();
    _centralConflictController.dispose();
    _characterProgressionController.dispose();
    _endingHookController.dispose();
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
            const SizedBox(height: 12),
            TextFormField(
              controller: _targetLengthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '目标字数',
                suffixText: '字',
              ),
              validator: (value) {
                final parsed = int.tryParse(value?.trim() ?? '');
                return parsed == null || parsed < 0 ? '目标字数不能小于 0。' : null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _summaryController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: '分卷摘要'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _centralConflictController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: '核心矛盾'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _characterProgressionController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: '角色推进'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _endingHookController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: '结尾钩子'),
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
    try {
      await ref
          .read(novelWorkshopControllerProvider.notifier)
          .saveChapterVolume(
            id: widget.volume?.id,
            input: ChapterVolumeInput(
              projectId: widget.projectId,
              volumeIndex: int.parse(_indexController.text.trim()),
              title: _titleController.text,
              targetLength: int.parse(_targetLengthController.text.trim()),
              summary: _summaryController.text,
              centralConflict: _centralConflictController.text,
              characterProgression: _characterProgressionController.text,
              endingHook: _endingHookController.text,
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
    maxHeight: MediaQuery.sizeOf(context).height * 0.9,
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

AssetGenerationRun? _latestAssetRun(
  List<AssetGenerationRun> runs,
  AssetGenerationKind kind,
) {
  final matches = runs.where((run) => run.kind == kind).toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return matches.firstOrNull;
}

bool _canReview(AssetGenerationRun? run) {
  if (run == null) return false;
  return (run.status == AssetGenerationStatus.succeeded ||
          run.status == AssetGenerationStatus.applied) &&
      run.draftMarkdown.trim().isNotEmpty;
}

AssetGenerationKind _assetKindForField(_BibleField field) {
  return switch (field) {
    _BibleField.worldBuilding => AssetGenerationKind.worldBuilding,
    _BibleField.charactersBlueprint => AssetGenerationKind.charactersBlueprint,
    _BibleField.outlineMaster => AssetGenerationKind.outlineMaster,
  };
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
