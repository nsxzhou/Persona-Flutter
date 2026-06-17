part of 'novel_workshop_page.dart';

class _NovelReaderPageState extends ConsumerState<NovelReaderPage> {
  String? _selectedPlanId;

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(writingProjectProvider(widget.projectId));
    final volumes = ref.watch(chapterVolumesProvider(widget.projectId));
    final plans = ref.watch(chapterPlansProvider(widget.projectId));
    final chapters = ref.watch(projectChaptersProvider(widget.projectId));
    final illustrations = ref.watch(
      chapterIllustrationsProvider(widget.projectId),
    );
    final illustrationRuns = ref.watch(
      chapterIllustrationGenerationRunsProvider(widget.projectId),
    );
    final imageProviders = ref.watch(imageProviderConfigsProvider);

    return project.when(
      data: (item) {
        if (item == null) {
          return _MissingProjectPage(projectId: widget.projectId);
        }
        return volumes.when(
          data: (volumeItems) => plans.when(
            data: (planItems) => chapters.when(
              data: (chapterItems) => illustrations.when(
                data: (illustrationItems) => illustrationRuns.when(
                  data: (illustrationRunItems) => imageProviders.when(
                    data: (providerItems) => _ReaderWorkbench(
                      project: item,
                      volumes: volumeItems,
                      plans: planItems,
                      chapters: chapterItems,
                      illustrations: illustrationItems,
                      illustrationRuns: illustrationRunItems,
                      imageProviders: providerItems,
                      selectedPlanId: _selectedPlanId,
                      onSelectPlan: (planId) {
                        setState(() {
                          _selectedPlanId = planId;
                        });
                      },
                      onExportEpub: () => _exportEpub(
                        project: item,
                        volumes: volumeItems,
                        plans: planItems,
                        chapters: chapterItems,
                        illustrations: illustrationItems,
                      ),
                    ),
                    error: (error, stackTrace) =>
                        _WorkshopError(message: '无法加载图像 Provider：$error'),
                    loading: () => const _WorkshopLoading(),
                  ),
                  error: (error, stackTrace) =>
                      _WorkshopError(message: '无法加载插图任务：$error'),
                  loading: () => const _WorkshopLoading(),
                ),
                error: (error, stackTrace) =>
                    _WorkshopError(message: '无法加载章节插图：$error'),
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

  Future<void> _exportEpub({
    required WritingProject project,
    required List<ChapterVolume> volumes,
    required List<ChapterPlan> plans,
    required List<ProjectChapter> chapters,
    required List<ChapterIllustration> illustrations,
  }) async {
    try {
      final path = await ref
          .read(novelWorkshopControllerProvider.notifier)
          .exportEpub(
            project: project,
            volumes: volumes,
            plans: plans,
            chapters: chapters,
            illustrations: illustrations,
          );
      if (!mounted || path == null) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已导出 EPUB：$path')));
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('导出失败：$error')));
    }
  }
}

class _ReaderWorkbench extends ConsumerStatefulWidget {
  const _ReaderWorkbench({
    required this.project,
    required this.volumes,
    required this.plans,
    required this.chapters,
    required this.illustrations,
    required this.illustrationRuns,
    required this.imageProviders,
    required this.selectedPlanId,
    required this.onSelectPlan,
    required this.onExportEpub,
  });

  final WritingProject project;
  final List<ChapterVolume> volumes;
  final List<ChapterPlan> plans;
  final List<ProjectChapter> chapters;
  final List<ChapterIllustration> illustrations;
  final List<ChapterIllustrationGenerationRun> illustrationRuns;
  final List<ImageProviderConfig> imageProviders;
  final String? selectedPlanId;
  final ValueChanged<String> onSelectPlan;
  final VoidCallback onExportEpub;

  @override
  ConsumerState<_ReaderWorkbench> createState() => _ReaderWorkbenchState();
}

class _ReaderWorkbenchState extends ConsumerState<_ReaderWorkbench> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isReviewRailVisible = true;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(readerSettingsProvider);
    final orderedPlans = _orderedChapterPlans(
      volumes: widget.volumes,
      plans: widget.plans,
    );
    final selectedPlan = orderedPlans.firstWhere(
      (plan) => plan.id == widget.selectedPlanId,
      orElse: () => orderedPlans.isEmpty
          ? _emptyReaderPlan(widget.project.id)
          : orderedPlans.first,
    );
    final chapter = widget.chapters.firstWhere(
      (item) => item.chapterPlanId == selectedPlan.id,
      orElse: () => _emptyReaderChapter(widget.project.id, selectedPlan),
    );
    final chapterIllustrations =
        widget.illustrations
            .where((item) => item.chapterId == chapter.id)
            .toList(growable: false)
          ..sort((a, b) {
            final paragraph = a.paragraphIndex.compareTo(b.paragraphIndex);
            if (paragraph != 0) return paragraph;
            return a.createdAt.compareTo(b.createdAt);
          });
    final insertedByParagraph = <int, List<ChapterIllustration>>{};
    for (final item in chapterIllustrations) {
      if (item.status == ChapterIllustrationStatus.inserted) {
        insertedByParagraph
            .putIfAbsent(item.paragraphIndex, () => <ChapterIllustration>[])
            .add(item);
      }
    }
    final draftCount = widget.illustrations
        .where((item) => item.status == ChapterIllustrationStatus.draft)
        .length;
    final activeIllustrationRuns =
        widget.illustrationRuns
            .where(
              (run) =>
                  run.status == ChapterIllustrationGenerationStatus.pending ||
                  run.status == ChapterIllustrationGenerationStatus.running ||
                  run.status == ChapterIllustrationGenerationStatus.failed,
            )
            .toList(growable: false)
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final runningIllustrationRunCount = activeIllustrationRuns
        .where(
          (run) =>
              run.status == ChapterIllustrationGenerationStatus.pending ||
              run.status == ChapterIllustrationGenerationStatus.running,
        )
        .length;
    final failedIllustrationRunCount = activeIllustrationRuns
        .where(
          (run) => run.status == ChapterIllustrationGenerationStatus.failed,
        )
        .length;
    final currentChapterRuns = activeIllustrationRuns
        .where((run) => run.chapterId == chapter.id)
        .toList(growable: false);
    final currentChapterReviewItems = chapterIllustrations
        .where((item) => item.status != ChapterIllustrationStatus.unused)
        .toList(growable: false);
    final libraryBadgeCount =
        draftCount + runningIllustrationRunCount + failedIllustrationRunCount;
    final paragraphs = readerParagraphsFromMarkdown(chapter.contentMarkdown);
    final enabledProviders = widget.imageProviders
        .where((provider) => provider.isEnabled)
        .toList(growable: false);
    final backgroundColor = _readerBackgroundColor(settings);
    final foregroundColor = _readerForegroundColor(settings);
    final selectedPlanIndex = orderedPlans.indexWhere(
      (plan) => plan.id == selectedPlan.id,
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      drawer: Drawer(
        width: 360,
        backgroundColor: backgroundColor,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: SafeArea(
          child: _ReaderChapterDrawer(
            plans: orderedPlans,
            selectedPlanId: selectedPlan.id,
            onSelectPlan: (planId) {
              Navigator.of(context).pop();
              widget.onSelectPlan(planId);
            },
          ),
        ),
      ),
      body: Column(
        children: [
          _ReaderTopBar(
            project: widget.project,
            chapterTitle: _chapterTitle(selectedPlan),
            libraryBadgeCount: libraryBadgeCount,
            foregroundColor: foregroundColor,
            onBack: () => context.go('/projects/${widget.project.id}/workshop'),
            onOpenToc: () => _scaffoldKey.currentState?.openDrawer(),
            onOpenLibrary: () => context.go(
              '/projects/${widget.project.id}/workshop/illustrations?plan=${selectedPlan.id}',
            ),
            onExportEpub: widget.onExportEpub,
            onOpenSettings: () async {
              final next = await showDialog<ReaderSettings>(
                context: context,
                builder: (context) =>
                    _ReaderSettingsDialog(initialSettings: settings),
              );
              if (next != null) {
                await ref.read(readerSettingsProvider.notifier).update(next);
              }
            },
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _ReaderPaper(
                    title: _chapterTitle(selectedPlan),
                    projectTitle: widget.project.title,
                    chapterIndex: selectedPlan.chapterIndex,
                    paragraphs: paragraphs,
                    insertedByParagraph: insertedByParagraph,
                    enabledProviders: enabledProviders,
                    chapter: chapter,
                    settings: settings,
                    backgroundColor: backgroundColor,
                    foregroundColor: foregroundColor,
                    onIllustrationCreated: () {},
                  ),
                ),
                if (_isReviewRailVisible)
                  _ReaderChapterIllustrationRail(
                    projectId: widget.project.id,
                    planId: selectedPlan.id,
                    illustrations: currentChapterReviewItems,
                    runs: currentChapterRuns,
                    chapter: chapter,
                    enabledProviders: enabledProviders,
                    onCollapse: () {
                      setState(() => _isReviewRailVisible = false);
                    },
                    onOpenLibrary: () => context.go(
                      '/projects/${widget.project.id}/workshop/illustrations?plan=${selectedPlan.id}',
                    ),
                  )
                else
                  _ReaderReviewRailExpander(
                    onExpand: () {
                      setState(() => _isReviewRailVisible = true);
                    },
                  ),
              ],
            ),
          ),
          _ReaderBottomBar(
            currentIndex: selectedPlanIndex < 0 ? 0 : selectedPlanIndex,
            totalCount: orderedPlans.length,
            onPrevious: selectedPlanIndex > 0
                ? () => widget.onSelectPlan(
                    orderedPlans[selectedPlanIndex - 1].id,
                  )
                : null,
            onNext:
                selectedPlanIndex >= 0 &&
                    selectedPlanIndex < orderedPlans.length - 1
                ? () => widget.onSelectPlan(
                    orderedPlans[selectedPlanIndex + 1].id,
                  )
                : null,
          ),
          if (orderedPlans.isEmpty)
            ColoredBox(
              color: backgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '还没有章节计划，先回工作台创建章节。',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: foregroundColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Color _readerBackgroundColor(ReaderSettings settings) {
  return settings.dark ? const Color(0xFF171A1F) : const Color(0xFFF4F6FA);
}

Color _readerForegroundColor(ReaderSettings settings) {
  return settings.dark ? const Color(0xFFE7E9EF) : const Color(0xFF20242C);
}

class _ReaderTopBar extends StatelessWidget {
  const _ReaderTopBar({
    required this.project,
    required this.chapterTitle,
    required this.libraryBadgeCount,
    required this.foregroundColor,
    required this.onBack,
    required this.onOpenToc,
    required this.onOpenLibrary,
    required this.onOpenSettings,
    required this.onExportEpub,
  });

  final WritingProject project;
  final String chapterTitle;
  final int libraryBadgeCount;
  final Color foregroundColor;
  final VoidCallback onBack;
  final VoidCallback onOpenToc;
  final VoidCallback onOpenLibrary;
  final VoidCallback onOpenSettings;
  final VoidCallback onExportEpub;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.92),
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.65),
              ),
            ),
          ),
          child: Row(
            children: [
              Tooltip(
                message: '目录',
                child: IconButton(
                  onPressed: onOpenToc,
                  icon: const Icon(Icons.menu_book_outlined),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      chapterTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: foregroundColor.withValues(alpha: 0.58),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_outlined, size: 18),
                label: const Text('工作台'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onExportEpub,
                icon: const Icon(Icons.ios_share_outlined, size: 18),
                label: const Text('EPUB'),
              ),
              const SizedBox(width: 8),
              Badge(
                isLabelVisible: libraryBadgeCount > 0,
                label: Text('$libraryBadgeCount'),
                child: IconButton(
                  onPressed: onOpenLibrary,
                  icon: const Icon(Icons.photo_library_outlined),
                  tooltip: '插图库',
                ),
              ),
              IconButton(
                onPressed: onOpenSettings,
                icon: const Icon(Icons.tune_outlined),
                tooltip: '阅读设置',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReaderSettingsDialog extends StatefulWidget {
  const _ReaderSettingsDialog({required this.initialSettings});

  final ReaderSettings initialSettings;

  @override
  State<_ReaderSettingsDialog> createState() => _ReaderSettingsDialogState();
}

class _ReaderSettingsDialogState extends State<_ReaderSettingsDialog> {
  late ReaderSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('阅读设置'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              value: _settings.dark,
              onChanged: (value) {
                setState(() => _settings = _settings.copyWith(dark: value));
              },
              title: const Text('深色阅读'),
              contentPadding: EdgeInsets.zero,
            ),
            _ReaderSettingSlider(
              label: '字号',
              value: _settings.fontSize,
              min: 16,
              max: 24,
              divisions: 8,
              displayValue: _settings.fontSize.toStringAsFixed(0),
              onChanged: (value) {
                setState(() => _settings = _settings.copyWith(fontSize: value));
              },
            ),
            _ReaderSettingSlider(
              label: '行距',
              value: _settings.lineHeight,
              min: 1.55,
              max: 2.25,
              divisions: 7,
              displayValue: _settings.lineHeight.toStringAsFixed(2),
              onChanged: (value) {
                setState(
                  () => _settings = _settings.copyWith(lineHeight: value),
                );
              },
            ),
            _ReaderSettingSlider(
              label: '栏宽',
              value: _settings.columnWidth,
              min: 640,
              max: 820,
              divisions: 6,
              displayValue: _settings.columnWidth.toStringAsFixed(0),
              onChanged: (value) {
                setState(
                  () => _settings = _settings.copyWith(columnWidth: value),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_settings),
          child: const Text('应用'),
        ),
      ],
    );
  }
}

class _ReaderSettingSlider extends StatelessWidget {
  const _ReaderSettingSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text(displayValue),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ReaderBottomBar extends StatelessWidget {
  const _ReaderBottomBar({
    required this.currentIndex,
    required this.totalCount,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentIndex;
  final int totalCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = totalCount <= 0 ? 0.0 : (currentIndex + 1) / totalCount;
    return Material(
      color: colorScheme.surface.withValues(alpha: 0.94),
      child: SafeArea(
        top: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          ),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left_outlined, size: 18),
                label: const Text('上一章'),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Text(
                totalCount <= 0 ? '0 / 0' : '${currentIndex + 1} / $totalCount',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 18),
              OutlinedButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right_outlined, size: 18),
                label: const Text('下一章'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReaderChapterDrawer extends StatelessWidget {
  const _ReaderChapterDrawer({
    required this.plans,
    required this.selectedPlanId,
    required this.onSelectPlan,
  });

  final List<ChapterPlan> plans;
  final String selectedPlanId;
  final ValueChanged<String> onSelectPlan;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      children: [
        Text('目录', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          '选择章节继续阅读。',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 18),
        for (final plan in plans)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Material(
              color: plan.id == selectedPlanId
                  ? colorScheme.primaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: ListTile(
                dense: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                title: Text(
                  _chapterTitle(plan),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('第 ${plan.chapterIndex} 章'),
                onTap: () => onSelectPlan(plan.id),
              ),
            ),
          ),
      ],
    );
  }
}

class _ReaderPaper extends ConsumerStatefulWidget {
  const _ReaderPaper({
    required this.title,
    required this.projectTitle,
    required this.chapterIndex,
    required this.paragraphs,
    required this.insertedByParagraph,
    required this.enabledProviders,
    required this.chapter,
    required this.settings,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onIllustrationCreated,
  });

  final String title;
  final String projectTitle;
  final int chapterIndex;
  final List<String> paragraphs;
  final Map<int, List<ChapterIllustration>> insertedByParagraph;
  final List<ImageProviderConfig> enabledProviders;
  final ProjectChapter chapter;
  final ReaderSettings settings;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onIllustrationCreated;

  @override
  ConsumerState<_ReaderPaper> createState() => _ReaderPaperState();
}

class _ReaderPaperState extends ConsumerState<_ReaderPaper> {
  String _selectedText = '';

  @override
  void didUpdateWidget(covariant _ReaderPaper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chapter.id != widget.chapter.id) {
      _selectedText = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: widget.backgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 40, 28, 72),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: widget.settings.columnWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(64, 60, 64, 76),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'CHAPTER ${widget.chapterIndex.toString().padLeft(2, '0')} · MANUSCRIPT REVIEW',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: widget.foregroundColor,
                      fontFamily: _readerFontFamily,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '书名：${widget.projectTitle}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: widget.foregroundColor.withValues(alpha: 0.58),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 34),
                  if (widget.paragraphs.isEmpty)
                    Text(
                      '本章还没有正文。',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: widget.foregroundColor.withValues(alpha: 0.68),
                      ),
                    )
                  else
                    SelectionArea(
                      onSelectionChanged: (content) {
                        _selectedText = content?.plainText.trim() ?? '';
                      },
                      contextMenuBuilder: _buildSelectionMenu,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (
                            var index = 0;
                            index < widget.paragraphs.length;
                            index += 1
                          )
                            _ReaderParagraph(
                              text: widget.paragraphs[index],
                              inserted:
                                  widget.insertedByParagraph[index] ??
                                  const <ChapterIllustration>[],
                              settings: widget.settings,
                              foregroundColor: widget.foregroundColor,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionMenu(
    BuildContext context,
    SelectableRegionState selectableRegionState,
  ) {
    final selectedText = _selectedText.trim();
    final buttonItems = [...selectableRegionState.contextMenuButtonItems];
    if (selectedText.isNotEmpty) {
      buttonItems.insert(
        0,
        ContextMenuButtonItem(
          label: '生成插图',
          onPressed: () async {
            ContextMenuController.removeAny();
            if (widget.enabledProviders.isEmpty) {
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(content: Text('请先在设置中启用图像 Provider。')),
              );
              return;
            }
            if (widget.chapter.id.isEmpty) {
              ScaffoldMessenger.of(
                this.context,
              ).showSnackBar(const SnackBar(content: Text('当前章节还没有可绑定的正文记录。')));
              return;
            }
            final messenger = ScaffoldMessenger.of(this.context);
            final paragraphIndex = _resolveSelectedParagraphIndex(selectedText);
            var initialPrompt = selectedText;
            String? initialPromptError;
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('正在优化 Prompt...'),
                  duration: Duration(minutes: 1),
                ),
              );
            try {
              initialPrompt = await ref
                  .read(novelWorkshopControllerProvider.notifier)
                  .generateChapterIllustrationPrompt(
                    chapter: widget.chapter,
                    paragraphIndex: paragraphIndex,
                    selectedText: selectedText,
                  );
              if (!mounted) {
                return;
              }
              messenger.hideCurrentSnackBar();
            } on Object catch (error) {
              if (!mounted) {
                return;
              }
              initialPromptError = '$error';
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('Prompt 优化失败，已使用原文打开：$error')),
                );
            }
            final created = await _showIllustrationDialog(
              this.context,
              chapter: widget.chapter,
              paragraphIndex: paragraphIndex,
              selectedText: selectedText,
              providers: widget.enabledProviders,
              initialPrompt: initialPrompt,
              initialPromptError: initialPromptError,
            );
            if (created && mounted) {
              widget.onIllustrationCreated();
            }
          },
        ),
      );
    }
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: selectableRegionState.contextMenuAnchors,
      buttonItems: buttonItems,
    );
  }

  int _resolveSelectedParagraphIndex(String selectedText) {
    if (widget.paragraphs.isEmpty) {
      return 0;
    }

    final trimmedSelection = selectedText.trim();
    if (trimmedSelection.isEmpty) {
      return 0;
    }

    final exactMatch = _paragraphIndexForExactSelection(
      trimmedSelection,
      delimiter: '\n',
    );
    if (exactMatch != null) {
      return exactMatch;
    }
    final markdownMatch = _paragraphIndexForExactSelection(
      trimmedSelection,
      delimiter: '\n\n',
    );
    if (markdownMatch != null) {
      return markdownMatch;
    }

    final selectedFragments = trimmedSelection
        .split(RegExp(r'\n+'))
        .map((fragment) => fragment.trim())
        .where((fragment) => fragment.isNotEmpty)
        .toList(growable: false);
    var bestIndex = -1;
    for (final fragment in selectedFragments) {
      final normalizedFragment = _normalizeSelectionText(fragment);
      for (var index = 0; index < widget.paragraphs.length; index += 1) {
        final paragraph = widget.paragraphs[index].trim();
        final normalizedParagraph = _normalizeSelectionText(paragraph);
        if (paragraph.contains(fragment) ||
            normalizedParagraph.contains(normalizedFragment) ||
            normalizedFragment.contains(normalizedParagraph) ||
            _hasSelectionOverlap(normalizedFragment, normalizedParagraph)) {
          bestIndex = index > bestIndex ? index : bestIndex;
        }
      }
    }
    return bestIndex >= 0 ? bestIndex : widget.paragraphs.length - 1;
  }

  int? _paragraphIndexForExactSelection(
    String selectedText, {
    required String delimiter,
  }) {
    final document = widget.paragraphs.join(delimiter);
    final selectionStart = document.indexOf(selectedText);
    if (selectionStart < 0) {
      return null;
    }
    final selectionEnd = selectionStart + selectedText.length - 1;
    var cursor = 0;
    for (var index = 0; index < widget.paragraphs.length; index += 1) {
      final paragraphEnd = cursor + widget.paragraphs[index].length;
      if (selectionEnd <= paragraphEnd) {
        return index;
      }
      cursor = paragraphEnd + delimiter.length;
    }
    return widget.paragraphs.length - 1;
  }
}

class _ReaderParagraph extends ConsumerWidget {
  const _ReaderParagraph({
    required this.text,
    required this.inserted,
    required this.settings,
    required this.foregroundColor,
  });

  final String text;
  final List<ChapterIllustration> inserted;
  final ReaderSettings settings;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: foregroundColor,
              fontFamily: _readerFontFamily,
              fontFamilyFallback: const [
                'Noto Serif CJK SC',
                'Source Han Serif SC',
                'serif',
              ],
              fontSize: settings.fontSize,
              height: settings.lineHeight,
              letterSpacing: 0,
            ),
          ),
          for (final illustration in inserted)
            SelectionContainer.disabled(
              child: Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _IllustrationImagePreview(
                      localPath: illustration.localPath,
                      maxHeight: math.min(
                        300,
                        MediaQuery.sizeOf(context).height * 0.32,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              illustration.selectedText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: foregroundColor.withValues(
                                      alpha: 0.56,
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () async {
                              await ref
                                  .read(
                                    novelWorkshopControllerProvider.notifier,
                                  )
                                  .removeChapterIllustrationFromText(
                                    illustration.id,
                                  );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('插图已移出正文。')),
                              );
                            },
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              size: 16,
                            ),
                            label: const Text('移出正文'),
                          ),
                        ],
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

class _ReaderChapterIllustrationRail extends StatelessWidget {
  const _ReaderChapterIllustrationRail({
    required this.projectId,
    required this.planId,
    required this.illustrations,
    required this.runs,
    required this.chapter,
    required this.enabledProviders,
    required this.onCollapse,
    required this.onOpenLibrary,
  });

  final String projectId;
  final String planId;
  final List<ChapterIllustration> illustrations;
  final List<ChapterIllustrationGenerationRun> runs;
  final ProjectChapter chapter;
  final List<ImageProviderConfig> enabledProviders;
  final VoidCallback onCollapse;
  final VoidCallback onOpenLibrary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pendingCount = illustrations
        .where((item) => item.status == ChapterIllustrationStatus.draft)
        .length;
    final failedCount = runs
        .where(
          (run) => run.status == ChapterIllustrationGenerationStatus.failed,
        )
        .length;
    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.94),
        border: Border(left: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        left: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '当前章轻审核',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '只处理本章待确认、失败和已插入插图。',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onOpenLibrary,
                  icon: const Icon(Icons.open_in_new_outlined),
                  tooltip: '打开插图库',
                ),
                IconButton(
                  onPressed: onCollapse,
                  icon: const Icon(Icons.keyboard_double_arrow_right_outlined),
                  tooltip: '收起插图审核',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                PersonaStatusPill(
                  label: '待确认 $pendingCount',
                  icon: Icons.pending_actions_outlined,
                  color: colorScheme.primary,
                ),
                PersonaStatusPill(
                  label: '失败 $failedCount',
                  icon: Icons.error_outline,
                  color: colorScheme.error,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (runs.isEmpty && illustrations.isEmpty)
              const WorkbenchEmptyState(
                sectionLabel: '插图审核',
                title: '本章暂无插图',
                description: '选中正文片段后可生成插图，草稿会先进入审核队列。',
              )
            else ...[
              for (final run in runs)
                _IllustrationRunCard(
                  run: run,
                  title: chapter.title.trim().isEmpty
                      ? '当前章节'
                      : chapter.title.trim(),
                ),
              for (final illustration in illustrations)
                _IllustrationLibraryCard(
                  illustration: illustration,
                  title: chapter.title.trim().isEmpty
                      ? '当前章节'
                      : chapter.title.trim(),
                  chapter: chapter,
                  enabledProviders: enabledProviders,
                ),
            ],
            const SizedBox(height: 10),
            FilledButton.tonalIcon(
              onPressed: onOpenLibrary,
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: const Text('打开完整插图库'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReaderReviewRailExpander extends StatelessWidget {
  const _ReaderReviewRailExpander({required this.onExpand});

  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 52,
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.94),
        border: Border(left: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        left: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Tooltip(
              message: '展开插图审核',
              child: IconButton(
                onPressed: onExpand,
                icon: const Icon(Icons.keyboard_double_arrow_left_outlined),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
