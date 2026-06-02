part of 'novel_workshop_page.dart';

enum _IllustrationLibraryStatusFilter {
  allPending,
  draft,
  running,
  failed,
  inserted,
  unused,
}

String _illustrationLibraryStatusFilterLabel(
  _IllustrationLibraryStatusFilter filter,
) {
  return switch (filter) {
    _IllustrationLibraryStatusFilter.allPending => '全部待处理',
    _IllustrationLibraryStatusFilter.draft => '待确认',
    _IllustrationLibraryStatusFilter.running => '运行中',
    _IllustrationLibraryStatusFilter.failed => '失败',
    _IllustrationLibraryStatusFilter.inserted => '已插入',
    _IllustrationLibraryStatusFilter.unused => '未插入',
  };
}

class _NovelIllustrationLibraryPageState
    extends ConsumerState<NovelIllustrationLibraryPage> {
  final _searchController = TextEditingController();
  _IllustrationLibraryStatusFilter _statusFilter =
      _IllustrationLibraryStatusFilter.allPending;
  String? _selectedPlanId;
  String? _selectedIllustrationId;

  @override
  void initState() {
    super.initState();
    _selectedPlanId = widget.initialPlanId;
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(writingProjectProvider(widget.projectId));
    final volumes = ref.watch(chapterVolumesProvider(widget.projectId));
    final plans = ref.watch(chapterPlansProvider(widget.projectId));
    final chapters = ref.watch(projectChaptersProvider(widget.projectId));
    final illustrations = ref.watch(
      chapterIllustrationsProvider(widget.projectId),
    );
    final runs = ref.watch(
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
                data: (illustrationItems) => runs.when(
                  data: (runItems) => imageProviders.when(
                    data: (providerItems) => _IllustrationLibraryWorkbench(
                      project: item,
                      plans: _orderedChapterPlans(
                        volumes: volumeItems,
                        plans: planItems,
                      ),
                      chapters: chapterItems,
                      illustrations: illustrationItems,
                      runs: runItems,
                      enabledProviders: providerItems
                          .where((provider) => provider.isEnabled)
                          .toList(growable: false),
                      selectedPlanId: _selectedPlanId,
                      selectedIllustrationId: _selectedIllustrationId,
                      statusFilter: _statusFilter,
                      searchText: _searchController.text,
                      searchController: _searchController,
                      onSelectPlan: (planId) {
                        setState(() => _selectedPlanId = planId);
                      },
                      onSelectStatus: (filter) {
                        setState(() => _statusFilter = filter);
                      },
                      onSelectIllustration: (id) {
                        setState(() => _selectedIllustrationId = id);
                      },
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
}

class _IllustrationLibraryWorkbench extends StatelessWidget {
  const _IllustrationLibraryWorkbench({
    required this.project,
    required this.plans,
    required this.chapters,
    required this.illustrations,
    required this.runs,
    required this.enabledProviders,
    required this.selectedPlanId,
    required this.selectedIllustrationId,
    required this.statusFilter,
    required this.searchText,
    required this.searchController,
    required this.onSelectPlan,
    required this.onSelectStatus,
    required this.onSelectIllustration,
  });

  final WritingProject project;
  final List<ChapterPlan> plans;
  final List<ProjectChapter> chapters;
  final List<ChapterIllustration> illustrations;
  final List<ChapterIllustrationGenerationRun> runs;
  final List<ImageProviderConfig> enabledProviders;
  final String? selectedPlanId;
  final String? selectedIllustrationId;
  final _IllustrationLibraryStatusFilter statusFilter;
  final String searchText;
  final TextEditingController searchController;
  final ValueChanged<String?> onSelectPlan;
  final ValueChanged<_IllustrationLibraryStatusFilter> onSelectStatus;
  final ValueChanged<String> onSelectIllustration;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedPlan = plans
        .where((plan) => plan.id == selectedPlanId)
        .firstOrNull;
    final filteredRuns = _filteredIllustrationRuns(
      runs: runs,
      plans: plans,
      chapters: chapters,
      selectedPlanId: selectedPlanId,
      filter: statusFilter,
      searchText: searchText,
    );
    final filteredIllustrations = _filteredIllustrations(
      illustrations: illustrations,
      plans: plans,
      chapters: chapters,
      selectedPlanId: selectedPlanId,
      filter: statusFilter,
      searchText: searchText,
    );
    final selectedIllustration =
        filteredIllustrations
            .where((item) => item.id == selectedIllustrationId)
            .firstOrNull ??
        filteredIllustrations.firstOrNull;
    final metrics = _IllustrationLibraryMetrics.from(
      illustrations: illustrations,
      runs: runs,
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _IllustrationLibraryTopBar(
              project: project,
              selectedPlan: selectedPlan,
              statusFilter: statusFilter,
              metrics: metrics,
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 1120;
                  final filters = _IllustrationLibraryFilters(
                    plans: plans,
                    illustrations: illustrations,
                    runs: runs,
                    selectedPlanId: selectedPlanId,
                    statusFilter: statusFilter,
                    searchController: searchController,
                    onSelectPlan: onSelectPlan,
                    onSelectStatus: onSelectStatus,
                  );
                  final queue = _IllustrationLibraryQueue(
                    project: project,
                    selectedPlan: selectedPlan,
                    statusFilter: statusFilter,
                    illustrations: filteredIllustrations,
                    runs: filteredRuns,
                    chapters: chapters,
                    plans: plans,
                    enabledProviders: enabledProviders,
                    selectedIllustrationId: selectedIllustration?.id,
                    onSelectIllustration: onSelectIllustration,
                  );
                  final detail = _IllustrationLibraryDetail(
                    illustration: selectedIllustration,
                    chapters: chapters,
                    plans: plans,
                    enabledProviders: enabledProviders,
                  );

                  if (compact) {
                    return ListView(
                      children: [
                        SizedBox(height: 420, child: filters),
                        Divider(height: 1, color: colorScheme.outlineVariant),
                        SizedBox(height: 560, child: queue),
                        Divider(height: 1, color: colorScheme.outlineVariant),
                        SizedBox(height: 620, child: detail),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(width: 260, child: filters),
                      VerticalDivider(
                        width: 0.5,
                        color: colorScheme.outlineVariant,
                      ),
                      Expanded(child: queue),
                      VerticalDivider(
                        width: 0.5,
                        color: colorScheme.outlineVariant,
                      ),
                      SizedBox(
                        width: constraints.maxWidth >= 1360 ? 400 : 360,
                        child: detail,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IllustrationLibraryTopBar extends StatelessWidget {
  const _IllustrationLibraryTopBar({
    required this.project,
    required this.selectedPlan,
    required this.statusFilter,
    required this.metrics,
  });

  final WritingProject project;
  final ChapterPlan? selectedPlan;
  final _IllustrationLibraryStatusFilter statusFilter;
  final _IllustrationLibraryMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filterLabel = _illustrationLibraryStatusFilterLabel(statusFilter);
    final chapterLabel = selectedPlan == null
        ? '全部章节'
        : _chapterTitle(selectedPlan!);
    final metricSummary =
        '待确认 ${metrics.draft} · 生成中 ${metrics.running} · 失败 ${metrics.failed} · 已插入 ${metrics.inserted}';
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 980;
          final veryCompact = constraints.maxWidth < 700;
          return Row(
            children: [
              Icon(Icons.photo_library_outlined, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '项目插图库',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      compact
                          ? '$chapterLabel · $filterLabel · $metricSummary'
                          : '$chapterLabel · $filterLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (!compact) ...[
                _IllustrationHeaderMetric(label: '待确认', value: metrics.draft),
                _IllustrationHeaderMetric(label: '生成中', value: metrics.running),
                _IllustrationHeaderMetric(label: '失败', value: metrics.failed),
                _IllustrationHeaderMetric(
                  label: '已插入',
                  value: metrics.inserted,
                ),
                const SizedBox(width: 12),
              ],
              if (veryCompact) ...[
                IconButton(
                  onPressed: () =>
                      context.go('/projects/${project.id}/workshop'),
                  icon: const Icon(Icons.arrow_back_outlined),
                  tooltip: '工作台',
                ),
                IconButton.filledTonal(
                  onPressed: () =>
                      context.go('/projects/${project.id}/workshop/reader'),
                  icon: const Icon(Icons.menu_book_outlined),
                  tooltip: '阅读器',
                ),
              ] else ...[
                TextButton.icon(
                  onPressed: () =>
                      context.go('/projects/${project.id}/workshop'),
                  icon: const Icon(Icons.arrow_back_outlined, size: 18),
                  label: const Text('工作台'),
                ),
                const SizedBox(width: 6),
                FilledButton.tonalIcon(
                  onPressed: () =>
                      context.go('/projects/${project.id}/workshop/reader'),
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  label: const Text('阅读器'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _IllustrationHeaderMetric extends StatelessWidget {
  const _IllustrationHeaderMetric({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$value',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _IllustrationLibraryFilters extends StatelessWidget {
  const _IllustrationLibraryFilters({
    required this.plans,
    required this.illustrations,
    required this.runs,
    required this.selectedPlanId,
    required this.statusFilter,
    required this.searchController,
    required this.onSelectPlan,
    required this.onSelectStatus,
  });

  final List<ChapterPlan> plans;
  final List<ChapterIllustration> illustrations;
  final List<ChapterIllustrationGenerationRun> runs;
  final String? selectedPlanId;
  final _IllustrationLibraryStatusFilter statusFilter;
  final TextEditingController searchController;
  final ValueChanged<String?> onSelectPlan;
  final ValueChanged<_IllustrationLibraryStatusFilter> onSelectStatus;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.surface,
      child: ListView(
        shrinkWrap: true,
        primary: false,
        padding: const EdgeInsets.fromLTRB(16, 12, 14, 20),
        children: [
          Text(
            '章节与状态',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '从阅读器进入时默认筛当前章。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_outlined),
              hintText: '搜索 prompt / 原文 / 章节标题',
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '状态',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          _FilterTile(
            label: '全部待处理',
            count: _countPendingLibraryItems(illustrations, runs),
            selected:
                statusFilter == _IllustrationLibraryStatusFilter.allPending,
            onTap: () =>
                onSelectStatus(_IllustrationLibraryStatusFilter.allPending),
          ),
          _FilterTile(
            label: '待确认',
            count: illustrations
                .where((item) => item.status == ChapterIllustrationStatus.draft)
                .length,
            selected: statusFilter == _IllustrationLibraryStatusFilter.draft,
            onTap: () => onSelectStatus(_IllustrationLibraryStatusFilter.draft),
          ),
          _FilterTile(
            label: '运行中',
            count: runs
                .where(
                  (run) =>
                      run.status ==
                          ChapterIllustrationGenerationStatus.pending ||
                      run.status == ChapterIllustrationGenerationStatus.running,
                )
                .length,
            selected: statusFilter == _IllustrationLibraryStatusFilter.running,
            onTap: () =>
                onSelectStatus(_IllustrationLibraryStatusFilter.running),
          ),
          _FilterTile(
            label: '失败',
            count: runs
                .where(
                  (run) =>
                      run.status == ChapterIllustrationGenerationStatus.failed,
                )
                .length,
            selected: statusFilter == _IllustrationLibraryStatusFilter.failed,
            onTap: () =>
                onSelectStatus(_IllustrationLibraryStatusFilter.failed),
          ),
          _FilterTile(
            label: '已插入',
            count: illustrations
                .where(
                  (item) => item.status == ChapterIllustrationStatus.inserted,
                )
                .length,
            selected: statusFilter == _IllustrationLibraryStatusFilter.inserted,
            onTap: () =>
                onSelectStatus(_IllustrationLibraryStatusFilter.inserted),
          ),
          _FilterTile(
            label: '未插入',
            count: illustrations
                .where(
                  (item) => item.status == ChapterIllustrationStatus.unused,
                )
                .length,
            selected: statusFilter == _IllustrationLibraryStatusFilter.unused,
            onTap: () =>
                onSelectStatus(_IllustrationLibraryStatusFilter.unused),
          ),
          const SizedBox(height: 18),
          Text(
            '章节',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          _FilterTile(
            label: '全部章节',
            count: illustrations.length + runs.length,
            selected: selectedPlanId == null,
            onTap: () => onSelectPlan(null),
          ),
          for (final plan in plans)
            _FilterTile(
              label: _chapterTitle(plan),
              count: _countPlanIllustrationItems(
                planId: plan.id,
                illustrations: illustrations,
                runs: runs,
              ),
              selected: selectedPlanId == plan.id,
              onTap: () => onSelectPlan(plan.id),
            ),
        ],
      ),
    );
  }
}

class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(bottom: 3),
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 36),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IllustrationLibraryQueue extends StatelessWidget {
  const _IllustrationLibraryQueue({
    required this.project,
    required this.selectedPlan,
    required this.statusFilter,
    required this.illustrations,
    required this.runs,
    required this.chapters,
    required this.plans,
    required this.enabledProviders,
    required this.selectedIllustrationId,
    required this.onSelectIllustration,
  });

  final WritingProject project;
  final ChapterPlan? selectedPlan;
  final _IllustrationLibraryStatusFilter statusFilter;
  final List<ChapterIllustration> illustrations;
  final List<ChapterIllustrationGenerationRun> runs;
  final List<ProjectChapter> chapters;
  final List<ChapterPlan> plans;
  final List<ImageProviderConfig> enabledProviders;
  final String? selectedIllustrationId;
  final ValueChanged<String> onSelectIllustration;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 18, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedPlan == null
                            ? '全章节审核队列'
                            : '${_chapterTitle(selectedPlan!)} 审核队列',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_illustrationLibraryStatusFilterLabel(statusFilter)} · ${runs.length + illustrations.length} 项',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.tonalIcon(
                  onPressed: () =>
                      context.go('/projects/${project.id}/workshop/reader'),
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  label: const Text('返回阅读器'),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              children: [
                if (runs.isEmpty && illustrations.isEmpty)
                  const _IllustrationLibraryEmptyState(
                    icon: Icons.photo_library_outlined,
                    title: '没有匹配的插图',
                    description: '调整章节、状态或搜索条件后再试。',
                  ),
                for (final run in runs)
                  _IllustrationLibraryRunRow(
                    run: run,
                    title: _illustrationChapterLabel(
                      chapterId: run.chapterId,
                      planId: run.chapterPlanId,
                      chapters: chapters,
                      plans: plans,
                    ),
                  ),
                for (final illustration in illustrations)
                  _IllustrationLibraryListRow(
                    illustration: illustration,
                    title: _illustrationChapterLabel(
                      chapterId: illustration.chapterId,
                      planId: illustration.chapterPlanId,
                      chapters: chapters,
                      plans: plans,
                    ),
                    chapter: chapters
                        .where((item) => item.id == illustration.chapterId)
                        .firstOrNull,
                    enabledProviders: enabledProviders,
                    selected: selectedIllustrationId == illustration.id,
                    onSelected: () => onSelectIllustration(illustration.id),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IllustrationLibraryListRow extends StatelessWidget {
  const _IllustrationLibraryListRow({
    required this.illustration,
    required this.title,
    required this.chapter,
    required this.enabledProviders,
    required this.selected,
    required this.onSelected,
  });

  final ChapterIllustration illustration;
  final String title;
  final ProjectChapter? chapter;
  final List<ImageProviderConfig> enabledProviders;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _illustrationStatusColor(
      illustration.status,
      colorScheme,
    );
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: selected
            ? colorScheme.primary.withValues(alpha: 0.06)
            : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: selected ? colorScheme.primary : Colors.transparent,
            width: 2.5,
          ),
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: InkWell(
        onTap: onSelected,
        hoverColor: colorScheme.primary.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 9, 10, 9),
          child: Row(
            children: [
              _IllustrationImagePreview(
                localPath: illustration.localPath,
                width: 92,
                height: 62,
                borderRadius: 4,
                compactError: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        PersonaStatusPill(
                          label: _illustrationStatusLabel(illustration.status),
                          icon: _illustrationStatusIcon(illustration.status),
                          color: statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      illustration.prompt,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '第 ${illustration.paragraphIndex + 1} 段 · ${illustration.selectedText}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.72,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _IllustrationLibraryActions(
                illustration: illustration,
                chapter: chapter,
                enabledProviders: enabledProviders,
                compact: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IllustrationLibraryRunRow extends ConsumerWidget {
  const _IllustrationLibraryRunRow({required this.run, required this.title});

  final ChapterIllustrationGenerationRun run;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFailed = run.status == ChapterIllustrationGenerationStatus.failed;
    final isRunning =
        run.status == ChapterIllustrationGenerationStatus.pending ||
        run.status == ChapterIllustrationGenerationStatus.running;
    final statusColor = isFailed
        ? colorScheme.error
        : isRunning
        ? colorScheme.primary
        : const Color(0xFF16825D);
    final statusLabel = _illustrationGenerationStatusLabel(run.status);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.045),
        border: Border(
          left: BorderSide(color: statusColor, width: 2.5),
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        child: Row(
          children: [
            Container(
              width: 92,
              height: 62,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isRunning
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: statusColor,
                      ),
                    )
                  : Icon(
                      isFailed
                          ? Icons.error_outline
                          : Icons.receipt_long_outlined,
                      color: statusColor,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      PersonaStatusPill(
                        label: statusLabel,
                        icon: isFailed
                            ? Icons.error_outline
                            : Icons.sync_outlined,
                        color: statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    run.prompt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (run.errorMessage?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      run.errorMessage!.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                OutlinedButton.icon(
                  onPressed: () =>
                      context.go('/workflow-runs/${run.workflowTaskId}'),
                  icon: const Icon(Icons.receipt_long_outlined, size: 18),
                  label: const Text('详情'),
                ),
                if (isFailed)
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      await ref
                          .read(novelWorkshopControllerProvider.notifier)
                          .retryChapterIllustrationGeneration(run.id);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('插图任务已重新创建。')),
                      );
                    },
                    icon: const Icon(Icons.refresh_outlined, size: 18),
                    label: const Text('重试'),
                  ),
                if (isFailed)
                  IconButton(
                    onPressed: () async {
                      await ref
                          .read(novelWorkshopControllerProvider.notifier)
                          .deleteChapterIllustrationGenerationRun(run.id);
                    },
                    icon: const Icon(Icons.delete_outline),
                    tooltip: '删除失败任务',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IllustrationLibraryDetail extends StatelessWidget {
  const _IllustrationLibraryDetail({
    required this.illustration,
    required this.chapters,
    required this.plans,
    required this.enabledProviders,
  });

  final ChapterIllustration? illustration;
  final List<ProjectChapter> chapters;
  final List<ChapterPlan> plans;
  final List<ImageProviderConfig> enabledProviders;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final item = illustration;
    if (item == null) {
      return ColoredBox(
        color: colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _IllustrationInspectorTitle(title: '详情检查器'),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.image_search_outlined,
                        size: 42,
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.32,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '选择一张插图',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.68,
                              ),
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '在队列中选择插图后，这里会显示原文、prompt、Provider 和操作。',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.56,
                          ),
                        ),
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
    final chapter = chapters
        .where((row) => row.id == item.chapterId)
        .firstOrNull;
    final title = _illustrationChapterLabel(
      chapterId: item.chapterId,
      planId: item.chapterPlanId,
      chapters: chapters,
      plans: plans,
    );
    return ColoredBox(
      color: colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _IllustrationInspectorTitle(title: '详情检查器'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              children: [
                _IllustrationImagePreview(
                  localPath: item.localPath,
                  maxHeight: math.min(
                    520,
                    MediaQuery.sizeOf(context).height * 0.55,
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          PersonaStatusPill(
                            label: _illustrationStatusLabel(item.status),
                            icon: _illustrationStatusIcon(item.status),
                            color: _illustrationStatusColor(
                              item.status,
                              colorScheme,
                            ),
                          ),
                          PersonaStatusPill(
                            label: '第 ${item.paragraphIndex + 1} 段',
                            icon: Icons.short_text_outlined,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 16),
                      _IllustrationDetailField(
                        label: 'Selected Text',
                        value: item.selectedText,
                      ),
                      _IllustrationDetailField(
                        label: 'Prompt',
                        value: item.prompt,
                      ),
                      _IllustrationDetailField(
                        label: 'Provider',
                        value: '${item.providerId} · ${item.modelName}',
                      ),
                      const SizedBox(height: 4),
                      _IllustrationLibraryActions(
                        illustration: item,
                        chapter: chapter,
                        enabledProviders: enabledProviders,
                        compact: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IllustrationDetailField extends StatelessWidget {
  const _IllustrationDetailField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 5),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _IllustrationInspectorTitle extends StatelessWidget {
  const _IllustrationInspectorTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _IllustrationLibraryEmptyState extends StatelessWidget {
  const _IllustrationLibraryEmptyState({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 38,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.32),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.68),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.56),
            ),
          ),
        ],
      ),
    );
  }
}

class _IllustrationLibraryActions extends ConsumerWidget {
  const _IllustrationLibraryActions({
    required this.illustration,
    required this.chapter,
    required this.enabledProviders,
    required this.compact,
  });

  final ChapterIllustration illustration;
  final ProjectChapter? chapter;
  final List<ImageProviderConfig> enabledProviders;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = <Widget>[
      if (illustration.status != ChapterIllustrationStatus.inserted)
        FilledButton.tonalIcon(
          onPressed: () async {
            await ref
                .read(novelWorkshopControllerProvider.notifier)
                .insertChapterIllustration(illustration.id);
            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('插图已插入正文。')));
          },
          icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
          label: Text(compact ? '插入' : '插入正文'),
        ),
      if (illustration.status == ChapterIllustrationStatus.inserted)
        OutlinedButton.icon(
          onPressed: () async {
            await ref
                .read(novelWorkshopControllerProvider.notifier)
                .removeChapterIllustrationFromText(illustration.id);
            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('插图已移出正文。')));
          },
          icon: const Icon(Icons.remove_circle_outline, size: 18),
          label: Text(compact ? '移出' : '移出正文'),
        ),
      OutlinedButton.icon(
        onPressed: chapter == null
            ? null
            : () async {
                await _showIllustrationDialog(
                  context,
                  chapter: chapter!,
                  paragraphIndex: illustration.paragraphIndex,
                  selectedText: illustration.selectedText,
                  providers: enabledProviders,
                  initialPrompt: illustration.prompt,
                );
              },
        icon: const Icon(Icons.refresh_outlined, size: 18),
        label: const Text('重试'),
      ),
      IconButton(
        onPressed: () async {
          await ref
              .read(novelWorkshopControllerProvider.notifier)
              .deleteChapterIllustration(
                id: illustration.id,
                projectId: illustration.projectId,
              );
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('插图已永久删除。')));
        },
        icon: const Icon(Icons.delete_outline),
        tooltip: '永久删除',
      ),
    ];
    if (compact) {
      return Wrap(spacing: 6, runSpacing: 6, children: children);
    }
    return Wrap(spacing: 8, runSpacing: 8, children: children);
  }
}

class _IllustrationLibraryMetrics {
  const _IllustrationLibraryMetrics({
    required this.draft,
    required this.running,
    required this.failed,
    required this.inserted,
  });

  factory _IllustrationLibraryMetrics.from({
    required List<ChapterIllustration> illustrations,
    required List<ChapterIllustrationGenerationRun> runs,
  }) {
    return _IllustrationLibraryMetrics(
      draft: illustrations
          .where((item) => item.status == ChapterIllustrationStatus.draft)
          .length,
      running: runs
          .where(
            (run) =>
                run.status == ChapterIllustrationGenerationStatus.pending ||
                run.status == ChapterIllustrationGenerationStatus.running,
          )
          .length,
      failed: runs
          .where(
            (run) => run.status == ChapterIllustrationGenerationStatus.failed,
          )
          .length,
      inserted: illustrations
          .where((item) => item.status == ChapterIllustrationStatus.inserted)
          .length,
    );
  }

  final int draft;
  final int running;
  final int failed;
  final int inserted;
}

List<ChapterIllustration> _filteredIllustrations({
  required List<ChapterIllustration> illustrations,
  required List<ChapterPlan> plans,
  required List<ProjectChapter> chapters,
  required String? selectedPlanId,
  required _IllustrationLibraryStatusFilter filter,
  required String searchText,
}) {
  final normalizedSearch = searchText.trim().toLowerCase();
  return illustrations
      .where(
        (item) =>
            selectedPlanId == null || item.chapterPlanId == selectedPlanId,
      )
      .where((item) => _illustrationMatchesFilter(item.status, filter))
      .where(
        (item) =>
            normalizedSearch.isEmpty ||
            _illustrationSearchText(
              illustration: item,
              chapters: chapters,
              plans: plans,
            ).contains(normalizedSearch),
      )
      .toList(growable: false)
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
}

List<ChapterIllustrationGenerationRun> _filteredIllustrationRuns({
  required List<ChapterIllustrationGenerationRun> runs,
  required List<ChapterPlan> plans,
  required List<ProjectChapter> chapters,
  required String? selectedPlanId,
  required _IllustrationLibraryStatusFilter filter,
  required String searchText,
}) {
  final normalizedSearch = searchText.trim().toLowerCase();
  return runs
      .where(
        (run) => selectedPlanId == null || run.chapterPlanId == selectedPlanId,
      )
      .where((run) => _runMatchesFilter(run.status, filter))
      .where(
        (run) =>
            normalizedSearch.isEmpty ||
            _runSearchText(
              run: run,
              chapters: chapters,
              plans: plans,
            ).contains(normalizedSearch),
      )
      .toList(growable: false)
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
}

bool _illustrationMatchesFilter(
  ChapterIllustrationStatus status,
  _IllustrationLibraryStatusFilter filter,
) {
  return switch (filter) {
    _IllustrationLibraryStatusFilter.allPending =>
      status == ChapterIllustrationStatus.draft ||
          status == ChapterIllustrationStatus.unused,
    _IllustrationLibraryStatusFilter.draft =>
      status == ChapterIllustrationStatus.draft,
    _IllustrationLibraryStatusFilter.inserted =>
      status == ChapterIllustrationStatus.inserted,
    _IllustrationLibraryStatusFilter.unused =>
      status == ChapterIllustrationStatus.unused,
    _IllustrationLibraryStatusFilter.running => false,
    _IllustrationLibraryStatusFilter.failed => false,
  };
}

bool _runMatchesFilter(
  ChapterIllustrationGenerationStatus status,
  _IllustrationLibraryStatusFilter filter,
) {
  final running =
      status == ChapterIllustrationGenerationStatus.pending ||
      status == ChapterIllustrationGenerationStatus.running;
  return switch (filter) {
    _IllustrationLibraryStatusFilter.allPending =>
      running || status == ChapterIllustrationGenerationStatus.failed,
    _IllustrationLibraryStatusFilter.running => running,
    _IllustrationLibraryStatusFilter.failed =>
      status == ChapterIllustrationGenerationStatus.failed,
    _IllustrationLibraryStatusFilter.draft => false,
    _IllustrationLibraryStatusFilter.inserted => false,
    _IllustrationLibraryStatusFilter.unused => false,
  };
}

String _illustrationSearchText({
  required ChapterIllustration illustration,
  required List<ProjectChapter> chapters,
  required List<ChapterPlan> plans,
}) {
  return [
    illustration.prompt,
    illustration.selectedText,
    _illustrationChapterLabel(
      chapterId: illustration.chapterId,
      planId: illustration.chapterPlanId,
      chapters: chapters,
      plans: plans,
    ),
  ].join('\n').toLowerCase();
}

String _runSearchText({
  required ChapterIllustrationGenerationRun run,
  required List<ProjectChapter> chapters,
  required List<ChapterPlan> plans,
}) {
  return [
    run.prompt,
    run.selectedText,
    run.errorMessage ?? '',
    _illustrationChapterLabel(
      chapterId: run.chapterId,
      planId: run.chapterPlanId,
      chapters: chapters,
      plans: plans,
    ),
  ].join('\n').toLowerCase();
}

int _countPendingLibraryItems(
  List<ChapterIllustration> illustrations,
  List<ChapterIllustrationGenerationRun> runs,
) {
  return illustrations
          .where(
            (item) =>
                item.status == ChapterIllustrationStatus.draft ||
                item.status == ChapterIllustrationStatus.unused,
          )
          .length +
      runs
          .where(
            (run) =>
                run.status == ChapterIllustrationGenerationStatus.pending ||
                run.status == ChapterIllustrationGenerationStatus.running ||
                run.status == ChapterIllustrationGenerationStatus.failed,
          )
          .length;
}

int _countPlanIllustrationItems({
  required String planId,
  required List<ChapterIllustration> illustrations,
  required List<ChapterIllustrationGenerationRun> runs,
}) {
  return illustrations.where((item) => item.chapterPlanId == planId).length +
      runs.where((run) => run.chapterPlanId == planId).length;
}

String _illustrationStatusLabel(ChapterIllustrationStatus status) {
  return switch (status) {
    ChapterIllustrationStatus.draft => '待确认',
    ChapterIllustrationStatus.inserted => '已插入',
    ChapterIllustrationStatus.unused => '未插入',
  };
}

String _illustrationGenerationStatusLabel(
  ChapterIllustrationGenerationStatus status,
) {
  return switch (status) {
    ChapterIllustrationGenerationStatus.pending => '排队中',
    ChapterIllustrationGenerationStatus.running => '生成中',
    ChapterIllustrationGenerationStatus.succeeded => '已完成',
    ChapterIllustrationGenerationStatus.failed => '失败',
    ChapterIllustrationGenerationStatus.abandoned => '已放弃',
  };
}

IconData _illustrationStatusIcon(ChapterIllustrationStatus status) {
  return switch (status) {
    ChapterIllustrationStatus.draft => Icons.pending_actions_outlined,
    ChapterIllustrationStatus.inserted => Icons.article_outlined,
    ChapterIllustrationStatus.unused => Icons.inventory_2_outlined,
  };
}

Color _illustrationStatusColor(
  ChapterIllustrationStatus status,
  ColorScheme colorScheme,
) {
  return switch (status) {
    ChapterIllustrationStatus.draft => colorScheme.primary,
    ChapterIllustrationStatus.inserted => const Color(0xFF16825D),
    ChapterIllustrationStatus.unused => colorScheme.onSurfaceVariant,
  };
}

class _IllustrationRunCard extends ConsumerWidget {
  const _IllustrationRunCard({required this.run, required this.title});

  final ChapterIllustrationGenerationRun run;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFailed = run.status == ChapterIllustrationGenerationStatus.failed;
    final isRunning =
        run.status == ChapterIllustrationGenerationStatus.pending ||
        run.status == ChapterIllustrationGenerationStatus.running;
    final statusColor = isFailed
        ? colorScheme.error
        : isRunning
        ? colorScheme.primary
        : const Color(0xFF16825D);
    final statusLabel = switch (run.status) {
      ChapterIllustrationGenerationStatus.pending => '排队中',
      ChapterIllustrationGenerationStatus.running => '生成中',
      ChapterIllustrationGenerationStatus.succeeded => '已完成',
      ChapterIllustrationGenerationStatus.failed => '失败',
      ChapterIllustrationGenerationStatus.abandoned => '已放弃',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: statusColor.withValues(alpha: 0.28)),
          borderRadius: BorderRadius.circular(8),
          color: statusColor.withValues(alpha: 0.05),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  PersonaStatusPill(
                    label: statusLabel,
                    icon: isFailed ? Icons.error_outline : Icons.sync_outlined,
                    color: statusColor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(run.prompt, maxLines: 3, overflow: TextOverflow.ellipsis),
              if (run.errorMessage?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  run.errorMessage!.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colorScheme.error),
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.go('/workflow-runs/${run.workflowTaskId}'),
                    icon: const Icon(Icons.receipt_long_outlined, size: 18),
                    label: const Text('详情'),
                  ),
                  if (isFailed)
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        await ref
                            .read(novelWorkshopControllerProvider.notifier)
                            .retryChapterIllustrationGeneration(run.id);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('插图任务已重新创建。')),
                        );
                      },
                      icon: const Icon(Icons.refresh_outlined, size: 18),
                      label: const Text('重试'),
                    ),
                  if (isFailed)
                    IconButton(
                      onPressed: () async {
                        await ref
                            .read(novelWorkshopControllerProvider.notifier)
                            .deleteChapterIllustrationGenerationRun(run.id);
                      },
                      icon: const Icon(Icons.delete_outline),
                      tooltip: '删除失败任务',
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

class _IllustrationLibraryCard extends ConsumerWidget {
  const _IllustrationLibraryCard({
    required this.illustration,
    required this.title,
    required this.chapter,
    required this.enabledProviders,
  });

  final ChapterIllustration illustration;
  final String title;
  final ProjectChapter? chapter;
  final List<ImageProviderConfig> enabledProviders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusLabel = switch (illustration.status) {
      ChapterIllustrationStatus.draft => '待确认',
      ChapterIllustrationStatus.inserted => '已插入',
      ChapterIllustrationStatus.unused => '未插入',
    };
    final statusColor = switch (illustration.status) {
      ChapterIllustrationStatus.draft => colorScheme.primary,
      ChapterIllustrationStatus.inserted => const Color(0xFF16825D),
      ChapterIllustrationStatus.unused => colorScheme.onSurfaceVariant,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  PersonaStatusPill(
                    label: statusLabel,
                    icon: switch (illustration.status) {
                      ChapterIllustrationStatus.draft =>
                        Icons.pending_actions_outlined,
                      ChapterIllustrationStatus.inserted =>
                        Icons.article_outlined,
                      ChapterIllustrationStatus.unused =>
                        Icons.inventory_2_outlined,
                    },
                    color: statusColor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _IllustrationImagePreview(
                localPath: illustration.localPath,
                maxHeight: 260,
              ),
              const SizedBox(height: 8),
              Text(
                illustration.prompt,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (illustration.selectedText.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  illustration.selectedText.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (illustration.status != ChapterIllustrationStatus.inserted)
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        await ref
                            .read(novelWorkshopControllerProvider.notifier)
                            .insertChapterIllustration(illustration.id);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('插图已插入正文。')),
                        );
                      },
                      icon: const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 18,
                      ),
                      label: const Text('插入正文'),
                    ),
                  if (illustration.status == ChapterIllustrationStatus.inserted)
                    OutlinedButton.icon(
                      onPressed: () async {
                        await ref
                            .read(novelWorkshopControllerProvider.notifier)
                            .removeChapterIllustrationFromText(illustration.id);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('插图已移出正文。')),
                        );
                      },
                      icon: const Icon(Icons.remove_circle_outline, size: 18),
                      label: const Text('移出正文'),
                    ),
                  OutlinedButton.icon(
                    onPressed: chapter == null
                        ? null
                        : () async {
                            await _showIllustrationDialog(
                              context,
                              chapter: chapter!,
                              paragraphIndex: illustration.paragraphIndex,
                              selectedText: illustration.selectedText,
                              providers: enabledProviders,
                              initialPrompt: illustration.prompt,
                            );
                          },
                    icon: const Icon(Icons.refresh_outlined, size: 18),
                    label: const Text('重试'),
                  ),
                  IconButton(
                    onPressed: () async {
                      await ref
                          .read(novelWorkshopControllerProvider.notifier)
                          .deleteChapterIllustration(
                            id: illustration.id,
                            projectId: illustration.projectId,
                          );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('插图已永久删除。')));
                    },
                    icon: const Icon(Icons.delete_outline),
                    tooltip: '永久删除',
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

String _illustrationChapterLabel({
  required String chapterId,
  required String planId,
  required List<ProjectChapter> chapters,
  required List<ChapterPlan> plans,
}) {
  final chapter = chapters.where((item) => item.id == chapterId).firstOrNull;
  if (chapter != null && chapter.title.trim().isNotEmpty) {
    return chapter.title.trim();
  }
  final plan = plans.where((item) => item.id == planId).firstOrNull;
  if (plan != null) {
    return _chapterTitle(plan);
  }
  return '未知章节';
}

