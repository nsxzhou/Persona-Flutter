import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/persona_page.dart';
import '../../projects/application/project_providers.dart';
import '../../projects/domain/writing_project.dart';
import '../../settings/application/provider_config_providers.dart';
import '../../settings/domain/provider_config.dart';
import '../application/plot_lab_providers.dart';
import '../application/story_engine_normalizer.dart';
import '../domain/plot_analysis_run.dart';
import '../domain/plot_profile.dart';
import '../domain/plot_sample.dart';

class PlotLabPage extends ConsumerStatefulWidget {
  const PlotLabPage({super.key});

  @override
  ConsumerState<PlotLabPage> createState() => _PlotLabPageState();
}

class _PlotLabPageState extends ConsumerState<PlotLabPage> {
  var _filter = _PlotLibraryFilter.all;

  @override
  Widget build(BuildContext context) {
    final samples = ref.watch(plotSamplesProvider);
    final providers = ref.watch(providerConfigsProvider);
    final runs = ref.watch(recentPlotAnalysisRunsProvider);
    final profiles = ref.watch(plotProfilesProvider);
    final controller = ref.watch(plotLabControllerProvider);

    return PersonaPage(
      eyebrow: '故事映射',
      title: '剧情实验室',
      description:
          '管理已保存的 Plot Profile 和待保存的 Story Engine 草稿，追溯来源样本、全书骨架、分析报告与任务日志。',
      maxWidth: 1420,
      actions: [
        FilledButton.icon(
          onPressed: controller.isLoading
              ? null
              : () => showDialog<void>(
                  context: context,
                  builder: (context) => const _CreatePlotProfileDialog(),
                ),
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('新建 Profile'),
        ),
      ],
      children: [
        controller.when(
          data: (_) => const SizedBox.shrink(),
          loading: () => const LinearProgressIndicator(minHeight: 2),
          error: (error, stackTrace) => _InlineError(message: '$error'),
        ),
        samples.when(
          data: (sampleItems) => providers.when(
            data: (providerItems) => runs.when(
              data: (runItems) => profiles.when(
                data: (profileItems) {
                  final assets = _buildLibraryAssets(
                    profiles: profileItems,
                    runs: runItems,
                    samples: sampleItems,
                    providers: providerItems,
                  );
                  final activeRuns = runItems
                      .where(_isActivityRun)
                      .toList(growable: false);
                  return _PlotLibraryCanvas(
                    assets: assets,
                    activeRuns: activeRuns,
                    filter: _filter,
                    onFilterChanged: (value) => setState(() => _filter = value),
                    onAssetSelected: _openAsset,
                    onRerun: _rerun,
                    onDeleteAsset: _deleteAsset,
                    onDeleteRun: _deleteRun,
                  );
                },
                loading: _loadingPanel,
                error: (error, stackTrace) => _InlineError(message: '$error'),
              ),
              loading: _loadingPanel,
              error: (error, stackTrace) => _InlineError(message: '$error'),
            ),
            loading: _loadingPanel,
            error: (error, stackTrace) => _InlineError(message: '$error'),
          ),
          loading: _loadingPanel,
          error: (error, stackTrace) => _InlineError(message: '$error'),
        ),
      ],
    );
  }

  Future<void> _rerun(PlotAnalysisRun run) async {
    try {
      await ref.read(plotLabControllerProvider.notifier).rerun(run.id);
      _showSnack('任务已重跑。');
    } on Object catch (error) {
      _showSnack('$error');
    }
  }

  Future<void> _deleteAsset(_PlotLibraryAsset asset) async {
    final confirmed = await _confirmDeletePlotItem(
      context: context,
      title: asset.kind == _PlotLibraryAssetKind.saved
          ? '删除 Plot Profile'
          : '删除 Story Engine 草稿',
      message: '确定删除「${asset.title}」吗？该记录会从本地数据库中移除。',
    );
    if (!mounted || !confirmed) return;
    try {
      final controller = ref.read(plotLabControllerProvider.notifier);
      switch (asset.kind) {
        case _PlotLibraryAssetKind.saved:
          await controller.deleteProfile(asset.id);
        case _PlotLibraryAssetKind.draft:
          await controller.deleteRun(asset.id);
      }
      _showSnack('已删除。');
    } on Object catch (error) {
      _showSnack('$error');
    }
  }

  Future<void> _deleteRun(PlotAnalysisRun run) async {
    final confirmed = await _confirmDeletePlotItem(
      context: context,
      title: '删除分析任务',
      message: '确定删除「${run.plotName}」吗？任务状态、日志和草稿会从本地数据库中移除。',
    );
    if (!mounted || !confirmed) return;
    try {
      await ref.read(plotLabControllerProvider.notifier).deleteRun(run.id);
      _showSnack('分析任务已删除。');
    } on Object catch (error) {
      _showSnack('$error');
    }
  }

  void _openAsset(_PlotLibraryAsset asset) {
    switch (asset.kind) {
      case _PlotLibraryAssetKind.saved:
        context.go('/plot-lab/profiles/${asset.id}');
      case _PlotLibraryAssetKind.draft:
        context.go('/plot-lab/tasks/${asset.id}');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _loadingPanel() {
    return const PersonaPanel(
      child: SizedBox(
        height: 260,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class PlotLabProfileDetailPage extends ConsumerWidget {
  const PlotLabProfileDetailPage({required this.profileId, super.key});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(plotProfileProvider(profileId));
    return profile.when(
      data: (item) {
        if (item == null) {
          return const _PlotLabMissingDetail(
            title: 'Profile 不存在',
            description: '这个 Plot Profile 可能已被删除。',
          );
        }
        final run = ref.watch(plotAnalysisRunProvider(item.sourceRunId));
        final sampleId = item.sourceSampleId;
        final sample = sampleId == null
            ? const AsyncValue<PlotSample?>.data(null)
            : ref.watch(plotSampleProvider(sampleId));
        return _PlotLabDetailScaffold(
          title: item.plotName,
          subtitle: item.sourceTitle ?? '已保存 Plot Profile',
          child: _SavedPlotProfileDetail(
            profile: item,
            run: run,
            sample: sample,
          ),
        );
      },
      loading: () => const _PlotLabDetailLoading(),
      error: (error, stackTrace) =>
          _PlotLabMissingDetail(title: '无法读取 Profile', description: '$error'),
    );
  }
}

class PlotLabTaskDetailPage extends ConsumerWidget {
  const PlotLabTaskDetailPage({required this.runId, super.key});

  final String runId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final run = ref.watch(plotAnalysisRunProvider(runId));
    return run.when(
      data: (item) {
        if (item == null) {
          return const _PlotLabMissingDetail(
            title: '任务不存在',
            description: '这个 Story Engine 草稿或分析任务可能已被删除。',
          );
        }
        final sample = ref.watch(plotSampleProvider(item.sampleId));
        return _PlotLabDetailScaffold(
          title: item.plotName,
          subtitle: _taskDetailSubtitle(item),
          child: _PlotTaskDetail(run: item, sample: sample),
        );
      },
      loading: () => const _PlotLabDetailLoading(),
      error: (error, stackTrace) =>
          _PlotLabMissingDetail(title: '无法读取任务', description: '$error'),
    );
  }
}

class _PlotLibraryCanvas extends StatelessWidget {
  const _PlotLibraryCanvas({
    required this.assets,
    required this.activeRuns,
    required this.filter,
    required this.onFilterChanged,
    required this.onAssetSelected,
    required this.onRerun,
    required this.onDeleteAsset,
    required this.onDeleteRun,
  });

  final List<_PlotLibraryAsset> assets;
  final List<PlotAnalysisRun> activeRuns;
  final _PlotLibraryFilter filter;
  final ValueChanged<_PlotLibraryFilter> onFilterChanged;
  final ValueChanged<_PlotLibraryAsset> onAssetSelected;
  final ValueChanged<PlotAnalysisRun> onRerun;
  final ValueChanged<_PlotLibraryAsset> onDeleteAsset;
  final ValueChanged<PlotAnalysisRun> onDeleteRun;

  @override
  Widget build(BuildContext context) {
    final filteredAssets = _filterAssets(assets, filter);
    return Column(
      children: [
        _LibrarySummary(
          assets: assets,
          activeRuns: activeRuns,
          filter: filter,
          onFilterChanged: onFilterChanged,
        ),
        const SizedBox(height: 14),
        _PlotLibraryList(
          assets: filteredAssets,
          filter: filter,
          onAssetSelected: onAssetSelected,
          onDeleteAsset: onDeleteAsset,
        ),
        if (activeRuns.isNotEmpty) ...[
          const SizedBox(height: 14),
          _ActivityRunsPanel(
            runs: activeRuns,
            onRerun: onRerun,
            onDeleteRun: onDeleteRun,
          ),
        ],
      ],
    );
  }
}

class _LibrarySummary extends StatelessWidget {
  const _LibrarySummary({
    required this.assets,
    required this.activeRuns,
    required this.filter,
    required this.onFilterChanged,
  });

  final List<_PlotLibraryAsset> assets;
  final List<PlotAnalysisRun> activeRuns;
  final _PlotLibraryFilter filter;
  final ValueChanged<_PlotLibraryFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final savedCount = assets
        .where((asset) => asset.kind == _PlotLibraryAssetKind.saved)
        .length;
    final draftCount = assets
        .where((asset) => asset.kind == _PlotLibraryAssetKind.draft)
        .length;
    return PersonaPanel(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PersonaSectionHeader(
            title: 'Plot Profile 档案库',
            description: '已保存档案和可入库草稿在这里统一管理；样本、骨架与任务日志作为来源证据保留。',
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<_PlotLibraryFilter>(
              segments: [
                ButtonSegment(
                  value: _PlotLibraryFilter.all,
                  label: Text('全部 (${savedCount + draftCount})'),
                ),
                ButtonSegment(
                  value: _PlotLibraryFilter.saved,
                  label: Text('已保存 ($savedCount)'),
                ),
                ButtonSegment(
                  value: _PlotLibraryFilter.drafts,
                  label: Text('待保存 ($draftCount)'),
                ),
                ButtonSegment(
                  value: _PlotLibraryFilter.activity,
                  label: Text('任务 (${activeRuns.length})'),
                ),
              ],
              selected: {filter},
              showSelectedIcon: false,
              onSelectionChanged: (value) => onFilterChanged(value.single),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatePlotProfileDialog extends ConsumerStatefulWidget {
  const _CreatePlotProfileDialog();

  @override
  ConsumerState<_CreatePlotProfileDialog> createState() =>
      _CreatePlotProfileDialogState();
}

class _CreatePlotProfileDialogState
    extends ConsumerState<_CreatePlotProfileDialog> {
  String? _selectedSampleId;
  String? _selectedProviderId;
  String? _selectedModelName;
  String? _selectedProjectId;
  final _plotNameController = TextEditingController();

  @override
  void dispose() {
    _plotNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final samples = ref.watch(plotSamplesProvider);
    final providers = ref.watch(providerConfigsProvider);
    final projects = ref.watch(writingProjectsProvider(ProjectStatus.active));
    final controller = ref.watch(plotLabControllerProvider);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: samples.when(
            data: (sampleItems) => providers.when(
              data: (providerItems) => projects.when(
                data: (projectItems) {
                  _syncDefaults(sampleItems, providerItems, projectItems);
                  final selectedSample = _findOrNull(
                    sampleItems,
                    _selectedSampleId,
                    (item) => item.id,
                  );
                  final selectedProvider = _findOrNull(
                    providerItems,
                    _selectedProviderId,
                    (item) => item.id,
                  );
                  final selectedModelName =
                      _selectedModelName ?? selectedProvider?.defaultModel;
                  final selectedProject = _findOrNull(
                    projectItems,
                    _selectedProjectId,
                    (item) => item.id,
                  );
                  return _CreatePlotProfileForm(
                    samples: sampleItems,
                    providers: providerItems,
                    projects: projectItems,
                    selectedSample: selectedSample,
                    selectedProvider: selectedProvider,
                    selectedModelName: selectedModelName,
                    selectedProject: selectedProject,
                    plotNameController: _plotNameController,
                    controllerBusy: controller.isLoading,
                    onImportSample: _importSample,
                    onSampleSelected: (id) => setState(() {
                      _selectedSampleId = id;
                      _plotNameController.text =
                          _findOrNull(
                            sampleItems,
                            id,
                            (item) => item.id,
                          )?.title ??
                          '';
                    }),
                    onProviderSelected: (id) => setState(() {
                      _selectedProviderId = id;
                      final provider = _findOrNull(
                        providerItems,
                        id,
                        (item) => item.id,
                      );
                      _selectedModelName = provider?.defaultModel;
                    }),
                    onModelSelected: (modelName) =>
                        setState(() => _selectedModelName = modelName),
                    onProjectSelected: (id) =>
                        setState(() => _selectedProjectId = id),
                    onRun: selectedSample == null || selectedProvider == null
                        ? null
                        : () => _createRun(
                            selectedSample,
                            selectedProvider,
                            selectedModelName ?? selectedProvider.defaultModel,
                          ),
                  );
                },
                loading: () => const SizedBox(
                  height: 260,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stackTrace) => _InlineError(message: '$error'),
              ),
              loading: () => const SizedBox(
                height: 260,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => _InlineError(message: '$error'),
            ),
            loading: () => const SizedBox(
              height: 260,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => _InlineError(message: '$error'),
          ),
        ),
      ),
    );
  }

  void _syncDefaults(
    List<PlotSample> samples,
    List<ProviderConfig> providers,
    List<WritingProject> projects,
  ) {
    if (_selectedSampleId == null && samples.isNotEmpty) {
      _selectedSampleId = samples.first.id;
      _plotNameController.text = samples.first.title;
    }
    if (_selectedProviderId == null && providers.isNotEmpty) {
      final enabled = providers.where((provider) => provider.isEnabled);
      _selectedProviderId =
          (enabled.isEmpty ? providers.first : enabled.first).id;
      _selectedModelName =
          (enabled.isEmpty ? providers.first : enabled.first).defaultModel;
    }
    if (_selectedSampleId != null &&
        !samples.any((sample) => sample.id == _selectedSampleId)) {
      _selectedSampleId = samples.isEmpty ? null : samples.first.id;
    }
    if (_selectedProviderId != null &&
        !providers.any((provider) => provider.id == _selectedProviderId)) {
      _selectedProviderId = providers.isEmpty ? null : providers.first.id;
      _selectedModelName = providers.isEmpty
          ? null
          : providers.first.defaultModel;
    }
    final selectedProvider = _findOrNull(
      providers,
      _selectedProviderId,
      (item) => item.id,
    );
    if (selectedProvider != null &&
        !selectedProvider.modelNames.contains(_selectedModelName)) {
      _selectedModelName = selectedProvider.defaultModel;
    }
    if (_selectedProjectId != null &&
        !projects.any((project) => project.id == _selectedProjectId)) {
      _selectedProjectId = null;
    }
  }

  Future<void> _importSample() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['txt', 'epub'],
        allowMultiple: false,
        withData: false,
      );
      final path = result?.files.single.path;
      if (path == null) {
        return;
      }
      final saved = await ref
          .read(plotLabControllerProvider.notifier)
          .importFile(path, projectId: _selectedProjectId);
      if (!mounted) return;
      setState(() {
        _selectedSampleId = saved.id;
        _plotNameController.text = saved.title;
      });
      _showSnack('已导入剧情样本。');
    } on Object catch (error) {
      _showSnack('导入失败：$error');
    }
  }

  Future<void> _createRun(
    PlotSample sample,
    ProviderConfig provider,
    String modelName,
  ) async {
    try {
      final run = await ref
          .read(plotLabControllerProvider.notifier)
          .createAndRun(
            sampleId: sample.id,
            providerId: provider.id,
            modelName: modelName,
            plotName: _plotNameController.text,
            projectId: _selectedProjectId,
          );
      if (!mounted) return;
      _showSnack('分析任务已创建：${run.plotName}。');
      Navigator.of(context).pop();
    } on Object catch (error) {
      _showSnack('$error');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CreatePlotProfileForm extends StatelessWidget {
  const _CreatePlotProfileForm({
    required this.samples,
    required this.providers,
    required this.projects,
    required this.plotNameController,
    required this.controllerBusy,
    required this.onImportSample,
    required this.onSampleSelected,
    required this.onProviderSelected,
    required this.onModelSelected,
    required this.onProjectSelected,
    this.selectedSample,
    this.selectedProvider,
    this.selectedModelName,
    this.selectedProject,
    this.onRun,
  });

  final List<PlotSample> samples;
  final List<ProviderConfig> providers;
  final List<WritingProject> projects;
  final PlotSample? selectedSample;
  final ProviderConfig? selectedProvider;
  final String? selectedModelName;
  final WritingProject? selectedProject;
  final TextEditingController plotNameController;
  final bool controllerBusy;
  final VoidCallback onImportSample;
  final ValueChanged<String> onSampleSelected;
  final ValueChanged<String> onProviderSelected;
  final ValueChanged<String> onModelSelected;
  final ValueChanged<String?> onProjectSelected;
  final VoidCallback? onRun;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: PersonaSectionHeader(
                  title: '新建 Plot Profile',
                  description: '导入或选择样本，运行分析后生成可保存的 Story Engine 草稿。',
                ),
              ),
              IconButton(
                tooltip: '关闭',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: controllerBusy ? null : onImportSample,
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('导入 TXT / EPUB'),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: selectedSample?.id,
            items: [
              for (final sample in samples)
                DropdownMenuItem(
                  value: sample.id,
                  child: Text(
                    '${sample.title} · ${_sourceLabel(sample)}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: samples.isEmpty
                ? null
                : (value) {
                    if (value != null) onSampleSelected(value);
                  },
            decoration: const InputDecoration(
              labelText: '样本',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: plotNameController,
            decoration: const InputDecoration(
              labelText: '剧情档案名称',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: selectedProvider?.id,
            items: [
              for (final provider in providers)
                DropdownMenuItem(
                  value: provider.id,
                  child: Text(
                    '${provider.name} · ${provider.defaultModel}${provider.isEnabled ? '' : '（停用）'}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: providers.isEmpty
                ? null
                : (value) {
                    if (value != null) onProviderSelected(value);
                  },
            decoration: const InputDecoration(
              labelText: 'Provider',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: selectedModelName,
            items: [
              for (final modelName
                  in selectedProvider?.modelNames ?? const <String>[])
                DropdownMenuItem(
                  value: modelName,
                  child: Text(modelName, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: selectedProvider == null
                ? null
                : (value) {
                    if (value != null) onModelSelected(value);
                  },
            decoration: const InputDecoration(
              labelText: 'Model',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            initialValue: selectedProject?.id,
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('不绑定项目'),
              ),
              for (final project in projects)
                DropdownMenuItem<String?>(
                  value: project.id,
                  child: Text(project.title, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: onProjectSelected,
            decoration: const InputDecoration(
              labelText: '项目（可选）',
              border: OutlineInputBorder(),
            ),
          ),
          if (providers.isEmpty) ...[
            const SizedBox(height: 12),
            const _InlineError(message: '请先在 Settings 配置 Provider。'),
          ],
          if (selectedSample != null) ...[
            const SizedBox(height: 14),
            _SampleBrief(sample: selectedSample!),
          ],
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: controllerBusy
                    ? null
                    : () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: controllerBusy ? null : onRun,
                icon: const Icon(Icons.auto_awesome_outlined),
                label: const Text('开始分析'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlotLibraryList extends StatelessWidget {
  const _PlotLibraryList({
    required this.assets,
    required this.filter,
    required this.onAssetSelected,
    required this.onDeleteAsset,
  });

  final List<_PlotLibraryAsset> assets;
  final _PlotLibraryFilter filter;
  final ValueChanged<_PlotLibraryAsset> onAssetSelected;
  final ValueChanged<_PlotLibraryAsset> onDeleteAsset;

  @override
  Widget build(BuildContext context) {
    return PersonaPanel(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (assets.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(18),
              child: PersonaEmptyStateCard(
                icon: Icons.account_tree_outlined,
                title: _emptyTitle(filter),
                description: _emptyDescription(filter),
              ),
            );
          }
          final compact = constraints.maxWidth < 760;
          return Column(
            children: [
              if (!compact) const _LibraryTableHeader(),
              for (final asset in assets)
                _LibraryAssetRow(
                  asset: asset,
                  compact: compact,
                  onTap: () => onAssetSelected(asset),
                  onDelete: () => onDeleteAsset(asset),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _LibraryTableHeader extends StatelessWidget {
  const _LibraryTableHeader();

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      letterSpacing: 0.2,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
        child: Row(
          children: [
            Expanded(flex: 4, child: Text('档案', style: textStyle)),
            Expanded(flex: 3, child: Text('来源', style: textStyle)),
            Expanded(flex: 3, child: Text('模型', style: textStyle)),
            Expanded(flex: 2, child: Text('状态', style: textStyle)),
            SizedBox(width: 104, child: Text('更新时间', style: textStyle)),
          ],
        ),
      ),
    );
  }
}

class _LibraryAssetRow extends StatelessWidget {
  const _LibraryAssetRow({
    required this.asset,
    required this.compact,
    required this.onTap,
    required this.onDelete,
  });

  final _PlotLibraryAsset asset;
  final bool compact;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.8),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AssetTitle(asset: asset),
                    const SizedBox(height: 8),
                    Text(
                      asset.sourceTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _AssetKindPill(kind: asset.kind),
                        PersonaStatusPill(
                          label: _statusLabel(asset.status),
                          icon: _statusIcon(asset.status),
                          color: _statusColor(colorScheme, asset.status),
                        ),
                        _StoryEngineStatus(markdown: asset.storyEngineMarkdown),
                        _AssetMoreButton(onDelete: onDelete),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(flex: 4, child: _AssetTitle(asset: asset)),
                    Expanded(
                      flex: 3,
                      child: Text(
                        asset.sourceTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        asset.providerLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _AssetKindPill(kind: asset.kind),
                          _StoryEngineStatus(
                            markdown: asset.storyEngineMarkdown,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 104,
                      child: Text(
                        _formatDate(asset.updatedAt),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      child: _AssetMoreButton(onDelete: onDelete),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _AssetTitle extends StatelessWidget {
  const _AssetTitle({required this.asset});

  final _PlotLibraryAsset asset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = asset.kind == _PlotLibraryAssetKind.saved
        ? Icons.bookmark_added_outlined
        : Icons.edit_document;
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(asset.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(
                asset.kind == _PlotLibraryAssetKind.saved
                    ? 'Plot Profile'
                    : 'Story Engine 草稿',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AssetMoreButton extends StatelessWidget {
  const _AssetMoreButton({required this.onDelete});

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_PlotAssetMenuAction>(
      tooltip: '档案操作',
      icon: const Icon(Icons.more_horiz),
      onSelected: (action) {
        switch (action) {
          case _PlotAssetMenuAction.delete:
            onDelete();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _PlotAssetMenuAction.delete,
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18),
              SizedBox(width: 10),
              Text('删除'),
            ],
          ),
        ),
      ],
    );
  }
}

class _AssetKindPill extends StatelessWidget {
  const _AssetKindPill({required this.kind});

  final _PlotLibraryAssetKind kind;

  @override
  Widget build(BuildContext context) {
    final saved = kind == _PlotLibraryAssetKind.saved;
    return PersonaStatusPill(
      label: saved ? '已保存' : '待保存',
      icon: saved ? Icons.check_circle_outline : Icons.pending_actions_outlined,
      color: saved
          ? const Color(0xFF16825D)
          : Theme.of(context).colorScheme.primary,
    );
  }
}

class _ActivityRunsPanel extends StatelessWidget {
  const _ActivityRunsPanel({
    required this.runs,
    required this.onRerun,
    required this.onDeleteRun,
  });

  final List<PlotAnalysisRun> runs;
  final ValueChanged<PlotAnalysisRun> onRerun;
  final ValueChanged<PlotAnalysisRun> onDeleteRun;

  @override
  Widget build(BuildContext context) {
    return PersonaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PersonaSectionHeader(
            title: '任务活动',
            description: '运行中、失败或尚未入库的任务保留在这里，可重跑失败任务。',
          ),
          const SizedBox(height: 12),
          for (final run in runs) ...[
            _ActivityRunRow(
              run: run,
              onRerun: () => onRerun(run),
              onDelete: () => onDeleteRun(run),
            ),
            if (run != runs.last) const Divider(height: 18),
          ],
        ],
      ),
    );
  }
}

class _ActivityRunRow extends StatelessWidget {
  const _ActivityRunRow({
    required this.run,
    required this.onRerun,
    required this.onDelete,
  });

  final PlotAnalysisRun run;
  final VoidCallback onRerun;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = _progressForRun(run);
    final summary = _runActivitySummary(run);
    final progressValue = _visibleProgressValue(run, progress);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => context.go('/plot-lab/tasks/${run.id}'),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 700;
                    final title = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          run.plotName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            PersonaStatusPill(
                              label: _statusLabel(run.status),
                              icon: _statusIcon(run.status),
                              color: _statusColor(colorScheme, run.status),
                            ),
                            PersonaStatusPill(
                              label: _stageLabel(run.stage),
                              icon: Icons.timeline,
                            ),
                            PersonaStatusPill(
                              label: _chunkProgressLabel(run),
                              icon: Icons.grain,
                            ),
                          ],
                        ),
                      ],
                    );
                    final detailAction = OutlinedButton.icon(
                      onPressed: () => context.go('/plot-lab/tasks/${run.id}'),
                      icon: const Icon(Icons.open_in_new_outlined),
                      label: const Text('打开详情'),
                    );
                    final rerunAction = OutlinedButton.icon(
                      onPressed: run.status == PlotAnalysisStatus.failed
                          ? onRerun
                          : null,
                      icon: const Icon(Icons.replay_outlined),
                      label: const Text('重跑'),
                    );
                    final deleteAction = IconButton.outlined(
                      tooltip: '删除分析任务',
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                    );
                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          title,
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [detailAction, rerunAction, deleteAction],
                          ),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: title),
                        const SizedBox(width: 12),
                        detailAction,
                        const SizedBox(width: 8),
                        rerunAction,
                        const SizedBox(width: 8),
                        deleteAction,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          minHeight: 6,
                          color: _statusColor(colorScheme, run.status),
                          backgroundColor: colorScheme.outlineVariant
                              .withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      progress.label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      summary.icon,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        summary.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SampleBrief extends StatelessWidget {
  const _SampleBrief({required this.sample});

  final PlotSample sample;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sample.title, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(
              '${sample.characterCount} 字符 · ${_sourceLabel(sample)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlotLabDetailScaffold extends StatelessWidget {
  const _PlotLabDetailScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: 'Plot Profile Detail',
      title: title,
      description: subtitle,
      maxWidth: 1180,
      actions: [
        OutlinedButton.icon(
          onPressed: () => context.go('/plot-lab'),
          icon: const Icon(Icons.arrow_back_outlined),
          label: const Text('返回档案库'),
        ),
      ],
      children: [child],
    );
  }
}

class _SavedPlotProfileDetail extends ConsumerStatefulWidget {
  const _SavedPlotProfileDetail({
    required this.profile,
    required this.run,
    required this.sample,
  });

  final PlotProfile profile;
  final AsyncValue<PlotAnalysisRun?> run;
  final AsyncValue<PlotSample?> sample;

  @override
  ConsumerState<_SavedPlotProfileDetail> createState() =>
      _SavedPlotProfileDetailState();
}

class _SavedPlotProfileDetailState
    extends ConsumerState<_SavedPlotProfileDetail> {
  final _plotNameController = TextEditingController();
  final _storyEngineController = TextEditingController();
  String? _documentKey;
  bool _previewStoryEngine = false;

  @override
  void initState() {
    super.initState();
    _syncProfile();
  }

  @override
  void didUpdateWidget(covariant _SavedPlotProfileDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncProfile();
  }

  @override
  void dispose() {
    _plotNameController.dispose();
    _storyEngineController.dispose();
    super.dispose();
  }

  void _syncProfile() {
    final key = widget.profile.id;
    if (_documentKey == key) return;
    _plotNameController.text = widget.profile.plotName;
    _storyEngineController.text = widget.profile.storyEngineMarkdown;
    _documentKey = key;
  }

  @override
  Widget build(BuildContext context) {
    return _PlotDetailBody(
      titleController: _plotNameController,
      storyEngineController: _storyEngineController,
      previewStoryEngine: _previewStoryEngine,
      run: widget.run,
      sample: widget.sample,
      reportMarkdown: widget.profile.analysisReportMarkdown,
      skeletonMarkdown: widget.profile.plotSkeletonMarkdown,
      sourceTitle: widget.profile.sourceTitle,
      primaryActionLabel: '更新 Profile',
      primaryActionIcon: Icons.edit_outlined,
      onPreviewChanged: (value) => setState(() => _previewStoryEngine = value),
      onPrimaryAction: _updateProfile,
      onCopyStoryEngine: _copyStoryEngine,
      onDelete: _deleteProfile,
    );
  }

  Future<void> _updateProfile() async {
    try {
      await ref
          .read(plotLabControllerProvider.notifier)
          .updateProfile(
            id: widget.profile.id,
            plotName: _plotNameController.text,
            storyEngineMarkdown: _storyEngineController.text,
            projectId: widget.profile.projectId,
          );
      _showSnack('剧情档案已更新。');
    } on Object catch (error) {
      _showSnack('$error');
    }
  }

  Future<void> _copyStoryEngine() async {
    await Clipboard.setData(ClipboardData(text: _storyEngineController.text));
    _showSnack('已复制 Story Engine。');
  }

  Future<void> _deleteProfile() async {
    final confirmed = await _confirmDeletePlotItem(
      context: context,
      title: '删除 Plot Profile',
      message: '确定删除「${widget.profile.plotName}」吗？该 Profile 会从本地数据库中移除。',
    );
    if (!mounted || !confirmed) return;
    try {
      await ref
          .read(plotLabControllerProvider.notifier)
          .deleteProfile(widget.profile.id);
      if (!mounted) return;
      _showSnack('剧情档案已删除。');
      context.go('/plot-lab');
    } on Object catch (error) {
      _showSnack('$error');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PlotTaskDetail extends ConsumerStatefulWidget {
  const _PlotTaskDetail({required this.run, required this.sample});

  final PlotAnalysisRun run;
  final AsyncValue<PlotSample?> sample;

  @override
  ConsumerState<_PlotTaskDetail> createState() => _PlotTaskDetailState();
}

class _PlotTaskDetailState extends ConsumerState<_PlotTaskDetail> {
  final _plotNameController = TextEditingController();
  final _storyEngineController = TextEditingController();
  String? _documentKey;
  bool _previewStoryEngine = false;

  @override
  void initState() {
    super.initState();
    _syncTask();
  }

  @override
  void didUpdateWidget(covariant _PlotTaskDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTask();
  }

  @override
  void dispose() {
    _plotNameController.dispose();
    _storyEngineController.dispose();
    super.dispose();
  }

  void _syncTask() {
    final key =
        '${widget.run.id}:${widget.run.storyEngineMarkdown.hashCode}:${widget.run.profileId ?? ''}';
    if (_documentKey == key) return;
    _plotNameController.text = widget.run.plotName;
    _storyEngineController.text = widget.run.storyEngineMarkdown ?? '';
    _documentKey = key;
  }

  @override
  Widget build(BuildContext context) {
    final profileId = widget.run.profileId;
    final hasProfile = profileId != null;
    final canSave =
        widget.run.status == PlotAnalysisStatus.succeeded && !hasProfile;

    return _PlotDetailBody(
      titleController: _plotNameController,
      storyEngineController: _storyEngineController,
      previewStoryEngine: _previewStoryEngine,
      run: AsyncValue.data(widget.run),
      sample: widget.sample,
      reportMarkdown: widget.run.analysisReportMarkdown,
      skeletonMarkdown: widget.run.plotSkeletonMarkdown,
      sourceTitle: null,
      primaryActionLabel: hasProfile ? '打开 Profile' : '保存为 Profile',
      primaryActionIcon: hasProfile
          ? Icons.open_in_new_outlined
          : Icons.save_outlined,
      primaryActionEnabled: hasProfile || canSave,
      deleteTooltip: '删除任务',
      onPreviewChanged: (value) => setState(() => _previewStoryEngine = value),
      onPrimaryAction: hasProfile ? _openProfile : _saveProfile,
      onCopyStoryEngine: _copyStoryEngine,
      onDelete: _deleteTask,
    );
  }

  Future<void> _saveProfile() async {
    try {
      final profile = await ref
          .read(plotLabControllerProvider.notifier)
          .saveProfile(
            runId: widget.run.id,
            plotName: _plotNameController.text,
            storyEngineMarkdown: _storyEngineController.text,
            projectId: widget.run.projectId,
          );
      if (!mounted) return;
      _showSnack('剧情档案已保存。');
      context.go('/plot-lab/profiles/${profile.id}');
    } on Object catch (error) {
      _showSnack('$error');
    }
  }

  Future<void> _copyStoryEngine() async {
    await Clipboard.setData(ClipboardData(text: _storyEngineController.text));
    _showSnack('已复制 Story Engine。');
  }

  Future<void> _deleteTask() async {
    final confirmed = await _confirmDeletePlotItem(
      context: context,
      title: '删除分析任务',
      message: '确定删除「${widget.run.plotName}」吗？任务状态、日志和草稿会从本地数据库中移除。',
    );
    if (!mounted || !confirmed) return;
    try {
      await ref
          .read(plotLabControllerProvider.notifier)
          .deleteRun(widget.run.id);
      if (!mounted) return;
      _showSnack('分析任务已删除。');
      context.go('/plot-lab');
    } on Object catch (error) {
      _showSnack('$error');
    }
  }

  void _openProfile() {
    final profileId = widget.run.profileId;
    if (profileId == null) return;
    context.go('/plot-lab/profiles/$profileId');
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PlotDetailBody extends StatefulWidget {
  const _PlotDetailBody({
    required this.titleController,
    required this.storyEngineController,
    required this.previewStoryEngine,
    required this.run,
    required this.sample,
    required this.reportMarkdown,
    required this.skeletonMarkdown,
    required this.primaryActionLabel,
    required this.primaryActionIcon,
    required this.onPreviewChanged,
    required this.onPrimaryAction,
    required this.onCopyStoryEngine,
    required this.onDelete,
    this.sourceTitle,
    this.primaryActionEnabled = true,
    this.deleteTooltip = '删除',
  });

  final TextEditingController titleController;
  final TextEditingController storyEngineController;
  final bool previewStoryEngine;
  final AsyncValue<PlotAnalysisRun?> run;
  final AsyncValue<PlotSample?> sample;
  final String? reportMarkdown;
  final String? skeletonMarkdown;
  final String? sourceTitle;
  final String primaryActionLabel;
  final IconData primaryActionIcon;
  final bool primaryActionEnabled;
  final String deleteTooltip;
  final ValueChanged<bool> onPreviewChanged;
  final VoidCallback onPrimaryAction;
  final VoidCallback onCopyStoryEngine;
  final VoidCallback onDelete;

  @override
  State<_PlotDetailBody> createState() => _PlotDetailBodyState();
}

class _PlotDetailBodyState extends State<_PlotDetailBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    widget.storyEngineController.addListener(_handleDocumentChanged);
  }

  @override
  void didUpdateWidget(covariant _PlotDetailBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storyEngineController != widget.storyEngineController) {
      oldWidget.storyEngineController.removeListener(_handleDocumentChanged);
      widget.storyEngineController.addListener(_handleDocumentChanged);
    }
  }

  @override
  void dispose() {
    widget.storyEngineController.removeListener(_handleDocumentChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _handleDocumentChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PersonaPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: _DetailHeader(
              titleController: widget.titleController,
              storyEngineMarkdown: widget.storyEngineController.text,
              run: widget.run,
              primaryActionLabel: widget.primaryActionLabel,
              primaryActionIcon: widget.primaryActionIcon,
              primaryActionEnabled: widget.primaryActionEnabled,
              deleteTooltip: widget.deleteTooltip,
              onPrimaryAction: widget.onPrimaryAction,
              onCopyStoryEngine: widget.onCopyStoryEngine,
              onDelete: widget.onDelete,
            ),
          ),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Story Engine'),
              Tab(text: '全书骨架'),
              Tab(text: '分析报告'),
              Tab(text: '来源样本'),
              Tab(text: '任务日志'),
            ],
          ),
          SizedBox(
            height: 680,
            child: TabBarView(
              controller: _tabController,
              children: [
                _StoryEngineTab(
                  controller: widget.storyEngineController,
                  preview: widget.previewStoryEngine,
                  onPreviewChanged: widget.onPreviewChanged,
                ),
                _MarkdownTab(
                  markdown: widget.skeletonMarkdown,
                  emptyIcon: Icons.account_tree_outlined,
                  emptyTitle: '暂无全书骨架',
                  emptyDescription: '分析完成后会在这里展示只读骨架。',
                ),
                _MarkdownTab(
                  markdown: widget.reportMarkdown,
                  emptyIcon: Icons.article_outlined,
                  emptyTitle: '暂无分析报告',
                  emptyDescription: '分析完成后会在这里展示只读报告。',
                ),
                _SampleTab(
                  sample: widget.sample,
                  sourceTitle: widget.sourceTitle,
                ),
                _RunLogTab(run: widget.run),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.titleController,
    required this.storyEngineMarkdown,
    required this.run,
    required this.primaryActionLabel,
    required this.primaryActionIcon,
    required this.primaryActionEnabled,
    required this.deleteTooltip,
    required this.onPrimaryAction,
    required this.onCopyStoryEngine,
    required this.onDelete,
  });

  final TextEditingController titleController;
  final String storyEngineMarkdown;
  final AsyncValue<PlotAnalysisRun?> run;
  final String primaryActionLabel;
  final IconData primaryActionIcon;
  final bool primaryActionEnabled;
  final String deleteTooltip;
  final VoidCallback onPrimaryAction;
  final VoidCallback onCopyStoryEngine;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentRun = run.value;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 780;
        final controls = Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _StoryEngineStatus(markdown: storyEngineMarkdown),
            if (currentRun != null)
              PersonaStatusPill(
                label: _statusLabel(currentRun.status),
                icon: _statusIcon(currentRun.status),
                color: _statusColor(colorScheme, currentRun.status),
              ),
            FilledButton.icon(
              onPressed: primaryActionEnabled ? onPrimaryAction : null,
              icon: Icon(primaryActionIcon),
              label: Text(primaryActionLabel),
            ),
            IconButton.outlined(
              tooltip: '复制 Story Engine',
              onPressed: storyEngineMarkdown.trim().isEmpty
                  ? null
                  : onCopyStoryEngine,
              icon: const Icon(Icons.copy_outlined),
            ),
            IconButton.outlined(
              tooltip: deleteTooltip,
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        );
        final titleField = TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: '剧情档案名称',
            border: OutlineInputBorder(),
          ),
        );
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [titleField, const SizedBox(height: 12), controls],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleField),
            const SizedBox(width: 16),
            controls,
          ],
        );
      },
    );
  }
}

class _StoryEngineTab extends StatelessWidget {
  const _StoryEngineTab({
    required this.controller,
    required this.preview,
    required this.onPreviewChanged,
  });

  final TextEditingController controller;
  final bool preview;
  final ValueChanged<bool> onPreviewChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('源码')),
                ButtonSegment(value: true, label: Text('预览')),
              ],
              selected: {preview},
              onSelectionChanged: (value) => onPreviewChanged(value.single),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: preview
                ? _MarkdownPreview(markdown: controller.text)
                : TextField(
                    controller: controller,
                    expands: true,
                    maxLines: null,
                    minLines: null,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                      labelText: 'Story Engine Markdown',
                    ),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MarkdownPreview extends StatelessWidget {
  const _MarkdownPreview({required this.markdown});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final previewMarkdown = _storyEnginePreviewMarkdown(markdown);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(kPanelRadius),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: MarkdownBody(data: previewMarkdown),
      ),
    );
  }
}

class _MarkdownTab extends StatelessWidget {
  const _MarkdownTab({
    required this.markdown,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyDescription,
  });

  final String? markdown;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyDescription;

  @override
  Widget build(BuildContext context) {
    final text = markdown?.trim();
    if (text == null || text.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(18),
        child: PersonaEmptyStateCard(
          icon: emptyIcon,
          title: emptyTitle,
          description: emptyDescription,
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: MarkdownBody(data: text),
    );
  }
}

class _SampleTab extends StatelessWidget {
  const _SampleTab({required this.sample, required this.sourceTitle});

  final AsyncValue<PlotSample?> sample;
  final String? sourceTitle;

  @override
  Widget build(BuildContext context) {
    return sample.when(
      data: (item) {
        if (item == null) {
          return Padding(
            padding: const EdgeInsets.all(18),
            child: PersonaEmptyStateCard(
              icon: Icons.text_snippet_outlined,
              title: sourceTitle ?? '来源样本不可用',
              description: '保存的档案仍可使用，但来源样本文本无法读取。',
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  PersonaStatusPill(
                    label: _sourceLabel(item),
                    icon: item.sourceType == PlotSampleSourceType.epub
                        ? Icons.menu_book_outlined
                        : Icons.text_snippet_outlined,
                  ),
                  PersonaStatusPill(
                    label: '${item.characterCount} 字符',
                    icon: Icons.notes_outlined,
                  ),
                  if (item.epubBookTitle != null)
                    PersonaStatusPill(
                      label: item.epubBookTitle!,
                      icon: Icons.book_outlined,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(item.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _CodeBlock(text: item.content),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.all(18),
        child: _InlineError(message: '$error'),
      ),
    );
  }
}

class _RunLogTab extends StatelessWidget {
  const _RunLogTab({required this.run});

  final AsyncValue<PlotAnalysisRun?> run;

  @override
  Widget build(BuildContext context) {
    return run.when(
      data: (item) {
        if (item == null) {
          return const Padding(
            padding: EdgeInsets.all(18),
            child: PersonaEmptyStateCard(
              icon: Icons.history_outlined,
              title: '任务记录不可用',
              description: '没有找到对应分析任务。',
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    PersonaStatusPill(
                      label: _statusLabel(item.status),
                      icon: _statusIcon(item.status),
                      color: _statusColor(
                        Theme.of(context).colorScheme,
                        item.status,
                      ),
                    ),
                    if (item.stage != null)
                      PersonaStatusPill(
                        label: _stageLabel(item.stage),
                        icon: Icons.timeline,
                      ),
                    PersonaStatusPill(
                      label: _chunkProgressLabel(item),
                      icon: Icons.grain,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _RunProgressOverview(run: item),
              if (item.errorMessage != null) ...[
                const SizedBox(height: 12),
                _InlineError(message: item.errorMessage!),
              ],
              const SizedBox(height: 14),
              Text('完整日志', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              Expanded(
                child: _CodeBlock(
                  key: const ValueKey('plot-lab-run-log-code-block'),
                  text: item.logs.trim().isEmpty ? '暂无日志。' : item.logs,
                  expand: true,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.all(18),
        child: _InlineError(message: '$error'),
      ),
    );
  }
}

class _RunProgressOverview extends StatelessWidget {
  const _RunProgressOverview({required this.run});

  final PlotAnalysisRun run;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = _progressForRun(run);
    final progressValue = _visibleProgressValue(run, progress);
    final statusColor = _statusColor(colorScheme, run.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 7,
                  color: statusColor,
                  backgroundColor: colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              progress.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 8,
          children: [
            for (final step in _plotAnalysisSteps)
              _StageStepPill(
                label: step.label,
                state: _stageStepState(run, step),
              ),
          ],
        ),
      ],
    );
  }
}

class _StageStepPill extends StatelessWidget {
  const _StageStepPill({required this.label, required this.state});

  final String label;
  final _StageStepState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (icon, color) = switch (state) {
      _StageStepState.done => (Icons.check, const Color(0xFF16825D)),
      _StageStepState.active => (Icons.sync, colorScheme.primary),
      _StageStepState.failed => (Icons.error_outline, colorScheme.error),
      _StageStepState.waiting => (
        Icons.radio_button_unchecked,
        colorScheme.onSurfaceVariant,
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryEngineStatus extends StatelessWidget {
  const _StoryEngineStatus({required this.markdown});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (markdown.trim().isEmpty) {
      return PersonaStatusPill(
        label: '等待生成',
        icon: Icons.hourglass_empty,
        color: colorScheme.onSurfaceVariant,
      );
    }
    try {
      const StoryEngineNormalizer().parse(markdown);
      return const PersonaStatusPill(
        label: 'YAML+MD 有效',
        icon: Icons.verified_outlined,
        color: Color(0xFF16825D),
      );
    } on Object {
      return PersonaStatusPill(
        label: '结构待检查',
        icon: Icons.error_outline,
        color: colorScheme.error,
      );
    }
  }
}

class _PlotLabDetailLoading extends StatelessWidget {
  const _PlotLabDetailLoading();

  @override
  Widget build(BuildContext context) {
    return const PersonaPage(
      eyebrow: 'Plot Profile Detail',
      title: '读取中',
      description: '正在读取剧情档案。',
      children: [
        PersonaPanel(
          child: SizedBox(
            height: 260,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}

class _PlotLabMissingDetail extends StatelessWidget {
  const _PlotLabMissingDetail({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: 'Plot Profile Detail',
      title: title,
      description: description,
      actions: [
        OutlinedButton.icon(
          onPressed: () => context.go('/plot-lab'),
          icon: const Icon(Icons.arrow_back_outlined),
          label: const Text('返回档案库'),
        ),
      ],
      children: const [
        PersonaPanel(
          child: PersonaEmptyStateCard(
            icon: Icons.search_off_outlined,
            title: '没有找到内容',
            description: '返回档案库选择其他 Profile。',
          ),
        ),
      ],
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.text, this.expand = false, super.key});

  final String text;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(kPanelRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: expand
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                text,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5),
              ),
            )
          : ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 220, maxHeight: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  text,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
    );
    return SizedBox(width: double.infinity, child: content);
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: TextStyle(color: colorScheme.error)),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> _confirmDeletePlotItem({
  required BuildContext context,
  required String title,
  required String message,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('删除'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

enum _PlotLibraryFilter { all, saved, drafts, activity }

enum _PlotLibraryAssetKind { saved, draft }

enum _PlotAssetMenuAction { delete }

enum _StageStepState { waiting, active, done, failed }

class _RunActivitySummary {
  const _RunActivitySummary({required this.text, required this.icon});

  final String text;
  final IconData icon;
}

class _PlotAnalysisStep {
  const _PlotAnalysisStep({required this.stage, required this.label});

  final PlotAnalysisStage? stage;
  final String label;
}

class _RunProgress {
  const _RunProgress({required this.value, required this.label});

  final double? value;
  final String label;
}

const _plotAnalysisSteps = [
  _PlotAnalysisStep(stage: PlotAnalysisStage.preparingInput, label: '准备输入'),
  _PlotAnalysisStep(stage: PlotAnalysisStage.sketchingChunks, label: '分块速写'),
  _PlotAnalysisStep(stage: PlotAnalysisStage.buildingSkeleton, label: '骨架'),
  _PlotAnalysisStep(stage: PlotAnalysisStage.reporting, label: '报告'),
  _PlotAnalysisStep(
    stage: PlotAnalysisStage.postprocessing,
    label: 'Story Engine',
  ),
  _PlotAnalysisStep(stage: null, label: '完成'),
];

class _PlotLibraryAsset {
  const _PlotLibraryAsset({
    required this.id,
    required this.kind,
    required this.title,
    required this.sourceTitle,
    required this.providerLabel,
    required this.status,
    required this.storyEngineMarkdown,
    required this.updatedAt,
  });

  final String id;
  final _PlotLibraryAssetKind kind;
  final String title;
  final String sourceTitle;
  final String providerLabel;
  final PlotAnalysisStatus status;
  final String storyEngineMarkdown;
  final DateTime updatedAt;
}

List<_PlotLibraryAsset> _buildLibraryAssets({
  required List<PlotProfile> profiles,
  required List<PlotAnalysisRun> runs,
  required List<PlotSample> samples,
  required List<ProviderConfig> providers,
}) {
  final sampleById = {for (final sample in samples) sample.id: sample};
  final providerById = {
    for (final provider in providers) provider.id: provider,
  };
  final assets = <_PlotLibraryAsset>[
    for (final profile in profiles)
      _PlotLibraryAsset(
        id: profile.id,
        kind: _PlotLibraryAssetKind.saved,
        title: profile.plotName,
        sourceTitle:
            profile.sourceTitle ??
            sampleById[profile.sourceSampleId]?.title ??
            '来源样本不可用',
        providerLabel: _providerLabel(
          providerById[profile.providerId],
          profile.modelName,
        ),
        status: PlotAnalysisStatus.succeeded,
        storyEngineMarkdown: profile.storyEngineMarkdown,
        updatedAt: profile.updatedAt,
      ),
    for (final run in runs.where(_isDraftRun))
      _PlotLibraryAsset(
        id: run.id,
        kind: _PlotLibraryAssetKind.draft,
        title: run.plotName,
        sourceTitle: sampleById[run.sampleId]?.title ?? '来源样本不可用',
        providerLabel: _providerLabel(
          providerById[run.providerId],
          run.modelName,
        ),
        status: run.status,
        storyEngineMarkdown: run.storyEngineMarkdown ?? '',
        updatedAt: run.updatedAt,
      ),
  ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return assets;
}

List<_PlotLibraryAsset> _filterAssets(
  List<_PlotLibraryAsset> assets,
  _PlotLibraryFilter filter,
) {
  return switch (filter) {
    _PlotLibraryFilter.all => assets,
    _PlotLibraryFilter.saved =>
      assets
          .where((asset) => asset.kind == _PlotLibraryAssetKind.saved)
          .toList(growable: false),
    _PlotLibraryFilter.drafts =>
      assets
          .where((asset) => asset.kind == _PlotLibraryAssetKind.draft)
          .toList(growable: false),
    _PlotLibraryFilter.activity => const [],
  };
}

bool _isDraftRun(PlotAnalysisRun run) {
  return run.status == PlotAnalysisStatus.succeeded &&
      run.profileId == null &&
      (run.storyEngineMarkdown?.trim().isNotEmpty ?? false);
}

bool _isActivityRun(PlotAnalysisRun run) {
  if (_isDraftRun(run)) {
    return false;
  }
  return run.status == PlotAnalysisStatus.pending ||
      run.status == PlotAnalysisStatus.running ||
      run.status == PlotAnalysisStatus.failed ||
      (run.status == PlotAnalysisStatus.succeeded && run.profileId == null);
}

String _storyEnginePreviewMarkdown(String markdown) {
  if (markdown.trim().isEmpty) {
    return '暂无内容。';
  }
  try {
    return const StoryEngineNormalizer().parse(markdown).bodyMarkdown;
  } on Object {
    final stripped = _stripFrontMatter(markdown).trim();
    return stripped.isEmpty ? '暂无内容。' : stripped;
  }
}

String _stripFrontMatter(String markdown) {
  final normalized = markdown.trimLeft();
  if (!normalized.startsWith('---\n')) {
    return markdown;
  }
  final end = normalized.indexOf('\n---', 4);
  if (end < 0) {
    return markdown;
  }
  final bodyStart = normalized.indexOf('\n', end + 4);
  return bodyStart < 0 ? '' : normalized.substring(bodyStart);
}

String _taskDetailSubtitle(PlotAnalysisRun run) {
  final status = _statusLabel(run.status);
  final stage = _stageLabel(run.stage);
  final chunks = _chunkProgressLabel(run);
  return '$status · $stage · $chunks · ${run.modelName}';
}

T? _findOrNull<T>(List<T> items, String? id, String Function(T item) getId) {
  if (id == null) {
    return null;
  }
  for (final item in items) {
    if (getId(item) == id) {
      return item;
    }
  }
  return null;
}

String _providerLabel(ProviderConfig? provider, String modelName) {
  if (provider == null) {
    return modelName;
  }
  return '${provider.name} · $modelName';
}

String _sourceLabel(PlotSample sample) {
  return switch (sample.sourceType) {
    PlotSampleSourceType.txt => 'TXT',
    PlotSampleSourceType.epub => 'EPUB 合并样本',
  };
}

String _stageLabel(PlotAnalysisStage? stage) {
  return switch (stage) {
    PlotAnalysisStage.preparingInput => '准备输入',
    PlotAnalysisStage.sketchingChunks => '分块速写',
    PlotAnalysisStage.buildingSkeleton => '构建骨架',
    PlotAnalysisStage.reporting => '生成报告',
    PlotAnalysisStage.postprocessing => '生成 Story Engine',
    null => '等待阶段',
  };
}

String _statusLabel(PlotAnalysisStatus status) {
  return switch (status) {
    PlotAnalysisStatus.pending => 'pending',
    PlotAnalysisStatus.running => 'running',
    PlotAnalysisStatus.succeeded => 'succeeded',
    PlotAnalysisStatus.failed => 'failed',
  };
}

IconData _statusIcon(PlotAnalysisStatus status) {
  return switch (status) {
    PlotAnalysisStatus.pending => Icons.schedule,
    PlotAnalysisStatus.running => Icons.sync,
    PlotAnalysisStatus.succeeded => Icons.check_circle_outline,
    PlotAnalysisStatus.failed => Icons.error_outline,
  };
}

Color _statusColor(ColorScheme colorScheme, PlotAnalysisStatus status) {
  return switch (status) {
    PlotAnalysisStatus.pending => colorScheme.tertiary,
    PlotAnalysisStatus.running => colorScheme.primary,
    PlotAnalysisStatus.succeeded => const Color(0xFF16825D),
    PlotAnalysisStatus.failed => colorScheme.error,
  };
}

String _chunkProgressLabel(PlotAnalysisRun run) {
  final completed = RegExp(r'完成 sketch \d+/').allMatches(run.logs).length;
  if (run.chunkCount <= 0) {
    return '0 chunks';
  }
  return '${completed.clamp(0, run.chunkCount)}/${run.chunkCount} chunks';
}

_RunProgress _progressForRun(PlotAnalysisRun run) {
  if (run.status == PlotAnalysisStatus.failed) {
    return const _RunProgress(value: 1, label: '失败');
  }
  if (run.status == PlotAnalysisStatus.succeeded) {
    return const _RunProgress(value: 1, label: '100%');
  }
  if (run.status == PlotAnalysisStatus.pending) {
    return const _RunProgress(value: 0.06, label: 'queued');
  }
  final stageBase = switch (run.stage) {
    PlotAnalysisStage.preparingInput => 0.1,
    PlotAnalysisStage.sketchingChunks => 0.2,
    PlotAnalysisStage.buildingSkeleton => 0.55,
    PlotAnalysisStage.reporting => 0.72,
    PlotAnalysisStage.postprocessing => 0.88,
    null => 0.08,
  };
  if (run.stage == PlotAnalysisStage.sketchingChunks && run.chunkCount > 0) {
    final completed = RegExp(r'完成 sketch \d+/').allMatches(run.logs).length;
    final value = 0.2 + (completed / run.chunkCount).clamp(0, 1) * 0.32;
    return _RunProgress(value: value, label: '${(value * 100).round()}%');
  }
  return _RunProgress(value: stageBase, label: '${(stageBase * 100).round()}%');
}

double? _visibleProgressValue(PlotAnalysisRun run, _RunProgress progress) {
  if (run.status == PlotAnalysisStatus.running && progress.value == null) {
    return null;
  }
  return progress.value;
}

_StageStepState _stageStepState(PlotAnalysisRun run, _PlotAnalysisStep step) {
  if (run.status == PlotAnalysisStatus.failed) {
    if (step.stage == run.stage || step.stage == null) {
      return _StageStepState.failed;
    }
    return _stageIndex(step.stage) < _stageIndex(run.stage)
        ? _StageStepState.done
        : _StageStepState.waiting;
  }
  if (run.status == PlotAnalysisStatus.succeeded) {
    return _StageStepState.done;
  }
  if (run.status == PlotAnalysisStatus.pending) {
    return _StageStepState.waiting;
  }
  if (step.stage == run.stage) {
    return _StageStepState.active;
  }
  return _stageIndex(step.stage) < _stageIndex(run.stage)
      ? _StageStepState.done
      : _StageStepState.waiting;
}

int _stageIndex(PlotAnalysisStage? stage) {
  return switch (stage) {
    PlotAnalysisStage.preparingInput => 0,
    PlotAnalysisStage.sketchingChunks => 1,
    PlotAnalysisStage.buildingSkeleton => 2,
    PlotAnalysisStage.reporting => 3,
    PlotAnalysisStage.postprocessing => 4,
    null => 5,
  };
}

_RunActivitySummary _runActivitySummary(PlotAnalysisRun run) {
  if (run.errorMessage != null && run.errorMessage!.trim().isNotEmpty) {
    return _RunActivitySummary(
      text: run.errorMessage!,
      icon: Icons.error_outline,
    );
  }
  final lastLog = run.logs
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList(growable: false)
      .lastOrNull;
  if (lastLog != null) {
    return _RunActivitySummary(text: lastLog, icon: Icons.notes_outlined);
  }
  return const _RunActivitySummary(text: '等待任务启动。', icon: Icons.schedule);
}

String _emptyTitle(_PlotLibraryFilter filter) {
  return switch (filter) {
    _PlotLibraryFilter.all => '尚无 Plot Profile 资产',
    _PlotLibraryFilter.saved => '尚无已保存 Plot Profile',
    _PlotLibraryFilter.drafts => '尚无待保存 Story Engine 草稿',
    _PlotLibraryFilter.activity => '当前没有任务活动',
  };
}

String _emptyDescription(_PlotLibraryFilter filter) {
  return switch (filter) {
    _PlotLibraryFilter.all => '导入 TXT 或 EPUB 样本并运行分析后，会生成可保存的剧情档案。',
    _PlotLibraryFilter.saved => '保存后的 Plot Profile 会显示在这里。',
    _PlotLibraryFilter.drafts => '成功生成但尚未保存的 Story Engine 会显示在这里。',
    _PlotLibraryFilter.activity => '运行中、失败和未入库任务会显示在活动区。',
  };
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$month-$day $hour:$minute';
}
