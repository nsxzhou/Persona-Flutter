import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/analysis_lab_widgets.dart';
import '../../../core/ui/glass_container.dart';
import '../../../core/ui/keep_alive_tab_wrapper.dart';
import '../../../core/ui/persona_page.dart';
import '../../../core/ui/skeleton_loader.dart';
import '../../../core/utils/markdown_utils.dart';
import '../../projects/application/project_providers.dart';
import '../../projects/domain/writing_project.dart';
import '../../settings/application/provider_config_providers.dart';
import '../../settings/domain/provider_config.dart';
import '../application/style_lab_providers.dart';
import '../application/voice_profile_front_matter.dart';
import '../domain/style_analysis_run.dart';
import '../domain/style_profile.dart';
import '../domain/style_sample.dart';

class StyleLabPage extends ConsumerStatefulWidget {
  const StyleLabPage({super.key});

  @override
  ConsumerState<StyleLabPage> createState() => _StyleLabPageState();
}

class _StyleLabPageState extends ConsumerState<StyleLabPage> {
  var _filter = _StyleLibraryFilter.all;

  @override
  Widget build(BuildContext context) {
    final samples = ref.watch(styleSamplesProvider);
    final providers = ref.watch(providerConfigsProvider);
    final runs = ref.watch(recentStyleAnalysisRunsProvider);
    final profiles = ref.watch(styleProfilesProvider);
    final controller = ref.watch(styleLabControllerProvider);

    return PersonaPage(
      eyebrow: '创作画布',
      title: '风格实验室',
      description:
          '管理已保存的 Style Profile 和待保存的 Voice Profile 草稿，追溯来源样本、分析报告与任务日志。',
      maxWidth: 1420,
      actions: [
        FilledButton.icon(
          onPressed: controller.isLoading
              ? null
              : () => _showCreateProfileDialog(context),
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('新建 Profile'),
        ),
      ],
      children: [
        controller.when(
          data: (_) => const SizedBox.shrink(),
          loading: () => const LinearProgressIndicator(minHeight: 2),
          error: (error, stackTrace) => InlineError(message: '$error'),
        ),
        _asyncLibrary(
          samples: samples,
          providers: providers,
          runs: runs,
          profiles: profiles,
          controllerBusy: controller.isLoading,
        ),
      ],
    );
  }

  Widget _asyncLibrary({
    required AsyncValue<List<StyleSample>> samples,
    required AsyncValue<List<ProviderConfig>> providers,
    required AsyncValue<List<StyleAnalysisRun>> runs,
    required AsyncValue<List<StyleProfile>> profiles,
    required bool controllerBusy,
  }) {
    return samples.when(
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

              return _StyleLibraryCanvas(
                assets: assets,
                activeRuns: activeRuns,
                filter: _filter,
                onFilterChanged: (filter) => setState(() => _filter = filter),
                onAssetSelected: _openAsset,
                onRerun: _rerun,
                onDeleteAsset: _deleteAsset,
                onDeleteRun: _deleteRun,
              );
            },
            loading: _loadingPanel,
            error: (error, stackTrace) => InlineError(message: '$error'),
          ),
          loading: _loadingPanel,
          error: (error, stackTrace) => InlineError(message: '$error'),
        ),
        loading: _loadingPanel,
        error: (error, stackTrace) => InlineError(message: '$error'),
      ),
      loading: _loadingPanel,
      error: (error, stackTrace) => InlineError(message: '$error'),
    );
  }

  Future<void> _rerun(StyleAnalysisRun run) async {
    try {
      await ref.read(styleLabControllerProvider.notifier).rerun(run.id);
      _showSnack('任务已重跑。');
    } on Object catch (error) {
      _showSnack('$error');
    }
  }

  Future<void> _deleteAsset(_StyleLibraryAsset asset) async {
    final confirmed = await _confirmDeleteStyleItem(
      context: context,
      title: asset.kind == _StyleLibraryAssetKind.saved
          ? '删除 Style Profile'
          : '删除 Voice Profile 草稿',
      message: '确定删除「${asset.title}」吗？该记录会从本地数据库中移除。',
    );
    if (!mounted || !confirmed) return;
    try {
      final controller = ref.read(styleLabControllerProvider.notifier);
      switch (asset.kind) {
        case _StyleLibraryAssetKind.saved:
          await controller.deleteProfile(asset.id);
        case _StyleLibraryAssetKind.draft:
          await controller.deleteRun(asset.id);
      }
      _showSnack('已删除。');
    } on Object catch (error) {
      _showSnack('$error');
    }
  }

  Future<void> _deleteRun(StyleAnalysisRun run) async {
    final confirmed = await _confirmDeleteStyleItem(
      context: context,
      title: '删除分析任务',
      message: '确定删除「${run.styleName}」吗？任务状态、日志和草稿会从本地数据库中移除。',
    );
    if (!mounted || !confirmed) return;
    try {
      await ref.read(styleLabControllerProvider.notifier).deleteRun(run.id);
      _showSnack('分析任务已删除。');
    } on Object catch (error) {
      _showSnack('$error');
    }
  }

  Future<void> _showCreateProfileDialog(BuildContext context) async {
    await showGlassDialog<void>(
      context: context,
      maxWidth: 560,
      builder: (context) => const _CreateProfileDialog(),
    );
  }

  void _openAsset(_StyleLibraryAsset asset) {
    switch (asset.kind) {
      case _StyleLibraryAssetKind.saved:
        context.go('/style-lab/profiles/${asset.id}');
      case _StyleLibraryAssetKind.draft:
        context.go('/style-lab/tasks/${asset.id}');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _loadingPanel() {
    return PersonaPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < 5; i++)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  SkeletonBox(width: 100, height: 28, borderRadius: 999),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 180, height: 14),
                        SizedBox(height: 6),
                        SkeletonBox(width: 120, height: 12),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  SkeletonBox(width: 80, height: 12),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class StyleLabProfileDetailPage extends ConsumerWidget {
  const StyleLabProfileDetailPage({required this.profileId, super.key});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(styleProfileProvider(profileId));
    return profile.when(
      data: (item) {
        if (item == null) {
          return const AnalysisMissingDetail(eyebrow: 'Profile Detail', backRoute: '/style-lab', 
            title: 'Profile 不存在',
            description: '这个 Style Profile 可能已被删除。',
          );
        }
        final run = ref.watch(styleAnalysisRunProvider(item.sourceRunId));
        final sampleId = item.sourceSampleId;
        final sample = sampleId == null
            ? const AsyncValue<StyleSample?>.data(null)
            : ref.watch(styleSampleProvider(sampleId));
        return _StyleLabDetailScaffold(
          title: item.styleName,
          subtitle: item.sourceTitle ?? '已保存 Style Profile',
          child: _StyleLabSavedProfileDetail(
            profile: item,
            run: run,
            sample: sample,
          ),
        );
      },
      loading: () => const AnalysisDetailLoading(eyebrow: 'Profile Detail', description: '正在读取风格档案。'),
      error: (error, stackTrace) =>
          AnalysisMissingDetail(eyebrow: 'Profile Detail', backRoute: '/style-lab', title: '无法读取 Profile', description: '$error'),
    );
  }
}

class StyleLabDraftDetailPage extends ConsumerWidget {
  const StyleLabDraftDetailPage({required this.runId, super.key});

  final String runId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final run = ref.watch(styleAnalysisRunProvider(runId));
    return run.when(
      data: (item) {
        if (item == null) {
          return const AnalysisMissingDetail(eyebrow: 'Profile Detail', backRoute: '/style-lab', 
            title: '草稿不存在',
            description: '这个 Voice Profile 草稿可能已被删除。',
          );
        }
        final sample = ref.watch(styleSampleProvider(item.sampleId));
        return _StyleLabDetailScaffold(
          title: item.styleName,
          subtitle: '待保存 Voice Profile 草稿',
          child: _StyleLabDraftProfileDetail(run: item, sample: sample),
        );
      },
      loading: () => const AnalysisDetailLoading(eyebrow: 'Profile Detail', description: '正在读取风格档案。'),
      error: (error, stackTrace) =>
          AnalysisMissingDetail(eyebrow: 'Profile Detail', backRoute: '/style-lab', title: '无法读取草稿', description: '$error'),
    );
  }
}

class StyleLabTaskDetailPage extends ConsumerWidget {
  const StyleLabTaskDetailPage({required this.runId, super.key});

  final String runId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final run = ref.watch(styleAnalysisRunProvider(runId));
    return run.when(
      data: (item) {
        if (item == null) {
          return const AnalysisMissingDetail(eyebrow: 'Profile Detail', backRoute: '/style-lab', 
            title: '任务不存在',
            description: '这个风格分析任务可能已被删除。',
          );
        }
        final sample = ref.watch(styleSampleProvider(item.sampleId));
        return _StyleLabDetailScaffold(
          eyebrow: 'Task Detail',
          title: item.styleName,
          subtitle: _taskDetailSubtitle(item),
          child: _StyleLabTaskDetail(run: item, sample: sample),
        );
      },
      loading: () => const AnalysisDetailLoading(eyebrow: 'Profile Detail', description: '正在读取风格档案。'),
      error: (error, stackTrace) =>
          AnalysisMissingDetail(eyebrow: 'Profile Detail', backRoute: '/style-lab', title: '无法读取任务', description: '$error'),
    );
  }
}

class _StyleLibraryCanvas extends StatelessWidget {
  const _StyleLibraryCanvas({
    required this.assets,
    required this.activeRuns,
    required this.filter,
    required this.onFilterChanged,
    required this.onAssetSelected,
    required this.onRerun,
    required this.onDeleteAsset,
    required this.onDeleteRun,
  });

  final List<_StyleLibraryAsset> assets;
  final List<StyleAnalysisRun> activeRuns;
  final _StyleLibraryFilter filter;
  final ValueChanged<_StyleLibraryFilter> onFilterChanged;
  final ValueChanged<_StyleLibraryAsset> onAssetSelected;
  final ValueChanged<StyleAnalysisRun> onRerun;
  final ValueChanged<_StyleLibraryAsset> onDeleteAsset;
  final ValueChanged<StyleAnalysisRun> onDeleteRun;

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
        _StyleLibraryList(
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

  final List<_StyleLibraryAsset> assets;
  final List<StyleAnalysisRun> activeRuns;
  final _StyleLibraryFilter filter;
  final ValueChanged<_StyleLibraryFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final savedCount = assets
        .where((asset) => asset.kind == _StyleLibraryAssetKind.saved)
        .length;
    final draftCount = assets
        .where((asset) => asset.kind == _StyleLibraryAssetKind.draft)
        .length;
    return PersonaPanel(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PersonaSectionHeader(
            title: 'Profile 档案库',
            description: '已保存档案和可入库草稿在这里统一管理；样本与任务作为来源上下文保留。',
          ),
          const SizedBox(height: 14),
          _LibraryControlStrip(
            savedCount: savedCount,
            draftCount: draftCount,
            activeCount: activeRuns.length,
            filter: filter,
            onFilterChanged: onFilterChanged,
          ),
        ],
      ),
    );
  }
}

class _LibraryControlStrip extends StatelessWidget {
  const _LibraryControlStrip({
    required this.savedCount,
    required this.draftCount,
    required this.activeCount,
    required this.filter,
    required this.onFilterChanged,
  });

  final int savedCount;
  final int draftCount;
  final int activeCount;
  final _StyleLibraryFilter filter;
  final ValueChanged<_StyleLibraryFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final filters = SegmentedButton<_StyleLibraryFilter>(
      segments: [
        ButtonSegment(
          value: _StyleLibraryFilter.all,
          label: Text('全部 (${savedCount + draftCount})'),
        ),
        ButtonSegment(
          value: _StyleLibraryFilter.saved,
          label: Text('已保存 ($savedCount)'),
        ),
        ButtonSegment(
          value: _StyleLibraryFilter.drafts,
          label: Text('待保存 ($draftCount)'),
        ),
        ButtonSegment(
          value: _StyleLibraryFilter.activity,
          label: Text('任务 ($activeCount)'),
        ),
      ],
      selected: {filter},
      onSelectionChanged: (value) => onFilterChanged(value.single),
      showSelectedIcon: false,
    );
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: filters,
      ),
    );
  }
}

class _CreateProfileDialog extends ConsumerStatefulWidget {
  const _CreateProfileDialog();

  @override
  ConsumerState<_CreateProfileDialog> createState() =>
      _CreateProfileDialogState();
}

class _CreateProfileDialogState extends ConsumerState<_CreateProfileDialog> {
  String? _selectedSampleId;
  String? _selectedProviderId;
  String? _selectedModelName;
  String? _selectedProjectId;
  final _styleNameController = TextEditingController();

  @override
  void dispose() {
    _styleNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final samples = ref.watch(styleSamplesProvider);
    final providers = ref.watch(providerConfigsProvider);
    final projects = ref.watch(writingProjectsProvider(ProjectStatus.active));
    final controller = ref.watch(styleLabControllerProvider);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: samples.when(
            data: (sampleItems) => providers.when(
              data: (providerItems) => projects.when(
                data: (projectItems) {
                  _syncDefaults(providerItems, projectItems);
                  final selectedSample = findOrNull(
                    sampleItems,
                    _selectedSampleId,
                    (item) => item.id,
                  );
                  final selectedProvider = findOrNull(
                    providerItems,
                    _selectedProviderId,
                    (item) => item.id,
                  );
                  final selectedModelName =
                      _selectedModelName ?? selectedProvider?.defaultModel;
                  final selectedProject = findOrNull(
                    projectItems,
                    _selectedProjectId,
                    (item) => item.id,
                  );
                  return _CreateProfileForm(
                    providers: providerItems,
                    projects: projectItems,
                    selectedSample: selectedSample,
                    selectedProvider: selectedProvider,
                    selectedModelName: selectedModelName,
                    selectedProject: selectedProject,
                    styleNameController: _styleNameController,
                    controllerBusy: controller.isLoading,
                    onImportSample: _importSample,
                    onProviderSelected: (id) => setState(() {
                      _selectedProviderId = id;
                      final provider = findOrNull(
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
                error: (error, stackTrace) => InlineError(message: '$error'),
              ),
              loading: () => const SizedBox(
                height: 260,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => InlineError(message: '$error'),
            ),
            loading: () => const SizedBox(
              height: 260,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => InlineError(message: '$error'),
          ),
    );
  }

  void _syncDefaults(
    List<ProviderConfig> providers,
    List<WritingProject> projects,
  ) {
    if (_selectedProviderId == null && providers.isNotEmpty) {
      final enabled = providers.where((provider) => provider.isEnabled);
      _selectedProviderId =
          (enabled.isEmpty ? providers.first : enabled.first).id;
      _selectedModelName =
          (enabled.isEmpty ? providers.first : enabled.first).defaultModel;
    }
    if (_selectedProviderId != null &&
        !providers.any((provider) => provider.id == _selectedProviderId)) {
      _selectedProviderId = providers.isEmpty ? null : providers.first.id;
      _selectedModelName = providers.isEmpty
          ? null
          : providers.first.defaultModel;
    }
    final selectedProvider = findOrNull(
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
          .read(styleLabControllerProvider.notifier)
          .importFile(path, projectId: _selectedProjectId);
      if (!mounted || saved.isEmpty) {
        return;
      }
      setState(() {
        _selectedSampleId = saved.first.id;
        _styleNameController.text = saved.first.title;
      });
      _showSnack('已导入 ${saved.length} 个样本。');
    } on Object catch (error) {
      _showSnack('导入失败：$error');
    }
  }

  Future<void> _createRun(
    StyleSample sample,
    ProviderConfig provider,
    String modelName,
  ) async {
    try {
      final run = await ref
          .read(styleLabControllerProvider.notifier)
          .createAndRun(
            sampleId: sample.id,
            providerId: provider.id,
            modelName: modelName,
            styleName: _styleNameController.text,
            projectId: _selectedProjectId,
          );
      if (!mounted) return;
      _showSnack('分析任务已创建：${run.styleName}。');
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

class _CreateProfileForm extends StatelessWidget {
  const _CreateProfileForm({
    required this.providers,
    required this.projects,
    required this.styleNameController,
    required this.controllerBusy,
    required this.onImportSample,
    required this.onProviderSelected,
    required this.onModelSelected,
    required this.onProjectSelected,
    this.selectedSample,
    this.selectedProvider,
    this.selectedModelName,
    this.selectedProject,
    this.onRun,
  });

  final List<ProviderConfig> providers;
  final List<WritingProject> projects;
  final StyleSample? selectedSample;
  final ProviderConfig? selectedProvider;
  final String? selectedModelName;
  final WritingProject? selectedProject;
  final TextEditingController styleNameController;
  final bool controllerBusy;
  final VoidCallback onImportSample;
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
                  title: '新建 Profile',
                  description: '导入样本，运行分析后生成可保存的 Voice Profile 草稿。',
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
          TextField(
            controller: styleNameController,
            decoration: const InputDecoration(
              labelText: '风格档案名称',
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
            const InlineError(message: '请先在 Settings 配置 Provider。'),
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

class _StyleLibraryList extends StatelessWidget {
  const _StyleLibraryList({
    required this.assets,
    required this.filter,
    required this.onAssetSelected,
    required this.onDeleteAsset,
  });

  final List<_StyleLibraryAsset> assets;
  final _StyleLibraryFilter filter;
  final ValueChanged<_StyleLibraryAsset> onAssetSelected;
  final ValueChanged<_StyleLibraryAsset> onDeleteAsset;

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
                icon: Icons.folder_copy_outlined,
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
    final textStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
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
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
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

class _LibraryAssetRow extends StatefulWidget {
  const _LibraryAssetRow({
    required this.asset,
    required this.compact,
    required this.onTap,
    required this.onDelete,
  });

  final _StyleLibraryAsset asset;
  final bool compact;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  State<_LibraryAssetRow> createState() => _LibraryAssetRowState();
}

class _LibraryAssetRowState extends State<_LibraryAssetRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final asset = widget.asset;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _isHovered
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.15)
                  : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.8),
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              child: widget.compact ? Column(
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
                        _YamlPill(markdown: asset.profileMarkdown),
                        PersonaStatusPill(
                          label: asset.status.name,
                          icon: statusIcon(asset.status.name),
                          color: statusColor(colorScheme, asset.status.name),
                        ),
                        _AssetMoreButton(onDelete: widget.onDelete),
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
                          _YamlPill(markdown: asset.profileMarkdown),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 104,
                      child: Text(
                        formatDate(asset.updatedAt),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      child: _AssetMoreButton(onDelete: widget.onDelete),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ),
    );
  }
}

class _AssetMoreButton extends StatelessWidget {
  const _AssetMoreButton({required this.onDelete});

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_StyleAssetMenuAction>(
      tooltip: '档案操作',
      icon: const Icon(Icons.more_horiz),
      onSelected: (action) {
        switch (action) {
          case _StyleAssetMenuAction.delete:
            onDelete();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _StyleAssetMenuAction.delete,
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

class _AssetTitle extends StatelessWidget {
  const _AssetTitle({required this.asset});

  final _StyleLibraryAsset asset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final icon = asset.kind == _StyleLibraryAssetKind.saved
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
              Text(
                asset.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                asset.kind == _StyleLibraryAssetKind.saved
                    ? 'Style Profile'
                    : 'Voice Profile 草稿',
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

class _AssetKindPill extends StatelessWidget {
  const _AssetKindPill({required this.kind});

  final _StyleLibraryAssetKind kind;

  @override
  Widget build(BuildContext context) {
    final saved = kind == _StyleLibraryAssetKind.saved;
    return PersonaStatusPill(
      label: saved ? '已保存' : '待保存',
      icon: saved ? Icons.check_circle_outline : Icons.pending_actions_outlined,
      color: saved
          ? const Color(0xFF16825D)
          : Theme.of(context).colorScheme.primary,
    );
  }
}

class _YamlPill extends StatelessWidget {
  const _YamlPill({required this.markdown});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    try {
      const VoiceProfileFrontMatterParser().parse(markdown);
      return const PersonaStatusPill(
        label: 'YAML 有效',
        icon: Icons.verified_outlined,
        color: Color(0xFF16825D),
      );
    } on Object {
      return PersonaStatusPill(
        label: 'YAML 异常',
        icon: Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
      );
    }
  }
}

class _ActivityRunsPanel extends StatelessWidget {
  const _ActivityRunsPanel({
    required this.runs,
    required this.onRerun,
    required this.onDeleteRun,
  });

  final List<StyleAnalysisRun> runs;
  final ValueChanged<StyleAnalysisRun> onRerun;
  final ValueChanged<StyleAnalysisRun> onDeleteRun;

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

class _ActivityRunRow extends StatefulWidget {
  const _ActivityRunRow({
    required this.run,
    required this.onRerun,
    required this.onDelete,
  });

  final StyleAnalysisRun run;
  final VoidCallback onRerun;
  final VoidCallback onDelete;

  @override
  State<_ActivityRunRow> createState() => _ActivityRunRowState();
}

class _ActivityRunRowState extends State<_ActivityRunRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final run = widget.run;
    final progress = _progressForRun(run);
    final summary = _runActivitySummary(run);
    final progressValue = _visibleProgressValue(run, progress);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(kPanelRadius),
        onTap: () => context.go('/style-lab/tasks/${run.id}'),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _isHovered
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.18)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(kPanelRadius),
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
                          run.styleName,
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
                              label: run.status.name,
                              icon: statusIcon(run.status.name),
                              color: statusColor(colorScheme, run.status.name),
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
                      onPressed: () => context.go('/style-lab/tasks/${run.id}'),
                      icon: const Icon(Icons.open_in_new_outlined),
                      label: const Text('打开详情'),
                    );
                    final rerunAction = OutlinedButton.icon(
                      onPressed: run.status == StyleAnalysisStatus.failed
                          ? widget.onRerun
                          : null,
                      icon: const Icon(Icons.replay_outlined),
                      label: const Text('重跑'),
                    );
                    final deleteAction = IconButton.outlined(
                      tooltip: '删除分析任务',
                      onPressed: widget.onDelete,
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
                          color: statusColor(colorScheme, run.status.name),
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
                      color: summary.color ?? colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        summary.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: summary.color ?? colorScheme.onSurfaceVariant,
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
    ),
    );
  }
}

class _SampleBrief extends StatelessWidget {
  const _SampleBrief({required this.sample});

  final StyleSample sample;

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

class _StyleLabDetailScaffold extends StatelessWidget {
  const _StyleLabDetailScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    this.eyebrow = 'Profile Detail',
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: eyebrow,
      title: title,
      description: subtitle,
      maxWidth: 1180,
      actions: [
        OutlinedButton.icon(
          onPressed: () => context.go('/style-lab'),
          icon: const Icon(Icons.arrow_back_outlined),
          label: const Text('返回档案库'),
        ),
      ],
      children: [child],
    );
  }
}

class _StyleLabSavedProfileDetail extends ConsumerStatefulWidget {
  const _StyleLabSavedProfileDetail({
    required this.profile,
    required this.run,
    required this.sample,
  });

  final StyleProfile profile;
  final AsyncValue<StyleAnalysisRun?> run;
  final AsyncValue<StyleSample?> sample;

  @override
  ConsumerState<_StyleLabSavedProfileDetail> createState() =>
      _StyleLabSavedProfileDetailState();
}

class _StyleLabSavedProfileDetailState
    extends ConsumerState<_StyleLabSavedProfileDetail> {
  final _styleNameController = TextEditingController();
  final _profileController = TextEditingController();
  String? _documentKey;
  bool _previewProfile = false;

  @override
  void initState() {
    super.initState();
    _syncProfile();
  }

  @override
  void didUpdateWidget(covariant _StyleLabSavedProfileDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncProfile();
  }

  @override
  void dispose() {
    _styleNameController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  void _syncProfile() {
    final key = widget.profile.id;
    if (_documentKey == key) return;
    _styleNameController.text = widget.profile.styleName;
    _profileController.text = widget.profile.profileMarkdown;
    _documentKey = key;
  }

  @override
  Widget build(BuildContext context) {
    return _ProfileDetailBody(
      titleController: _styleNameController,
      profileController: _profileController,
      previewProfile: _previewProfile,
      run: widget.run,
      sample: widget.sample,
      reportMarkdown: widget.profile.analysisReportMarkdown,
      sourceTitle: widget.profile.sourceTitle,
      primaryActionLabel: '更新 Profile',
      primaryActionIcon: Icons.edit_outlined,
      onPreviewChanged: (value) => setState(() => _previewProfile = value),
      onPrimaryAction: _updateProfile,
      onCopyProfile: _copyProfile,
      onDelete: _deleteProfile,
    );
  }

  Future<void> _updateProfile() async {
    try {
      await ref
          .read(styleLabControllerProvider.notifier)
          .updateProfile(
            id: widget.profile.id,
            styleName: _styleNameController.text,
            profileMarkdown: _profileController.text,
            projectId: widget.profile.projectId,
          );
      _showSnack('风格档案已更新。');
    } on Object catch (error) {
      _showSnack('$error');
    }
  }

  Future<void> _copyProfile() async {
    await Clipboard.setData(ClipboardData(text: _profileController.text));
    _showSnack('已复制 Voice Profile。');
  }

  Future<void> _deleteProfile() async {
    final confirmed = await _confirmDeleteStyleItem(
      context: context,
      title: '删除 Style Profile',
      message: '确定删除「${widget.profile.styleName}」吗？该 Profile 会从本地数据库中移除。',
    );
    if (!mounted || !confirmed) return;
    try {
      await ref
          .read(styleLabControllerProvider.notifier)
          .deleteProfile(widget.profile.id);
      if (!mounted) return;
      _showSnack('风格档案已删除。');
      context.go('/style-lab');
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

class _StyleLabDraftProfileDetail extends ConsumerStatefulWidget {
  const _StyleLabDraftProfileDetail({required this.run, required this.sample});

  final StyleAnalysisRun run;
  final AsyncValue<StyleSample?> sample;

  @override
  ConsumerState<_StyleLabDraftProfileDetail> createState() =>
      _StyleLabDraftProfileDetailState();
}

class _StyleLabDraftProfileDetailState
    extends ConsumerState<_StyleLabDraftProfileDetail> {
  final _styleNameController = TextEditingController();
  final _profileController = TextEditingController();
  String? _documentKey;
  bool _previewProfile = false;

  @override
  void initState() {
    super.initState();
    _syncDraft();
  }

  @override
  void didUpdateWidget(covariant _StyleLabDraftProfileDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncDraft();
  }

  @override
  void dispose() {
    _styleNameController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  void _syncDraft() {
    final key = widget.run.id;
    if (_documentKey == key) return;
    _styleNameController.text = widget.run.styleName;
    _profileController.text = widget.run.voiceProfileMarkdown ?? '';
    _documentKey = key;
  }

  @override
  Widget build(BuildContext context) {
    return _ProfileDetailBody(
      titleController: _styleNameController,
      profileController: _profileController,
      previewProfile: _previewProfile,
      run: AsyncValue.data(widget.run),
      sample: widget.sample,
      reportMarkdown: widget.run.analysisReportMarkdown,
      sourceTitle: null,
      primaryActionLabel: '保存为 Profile',
      primaryActionIcon: Icons.save_outlined,
      primaryActionEnabled: widget.run.status == StyleAnalysisStatus.succeeded,
      deleteTooltip: '删除草稿',
      onPreviewChanged: (value) => setState(() => _previewProfile = value),
      onPrimaryAction: _saveProfile,
      onCopyProfile: _copyProfile,
      onDelete: _deleteDraft,
    );
  }

  Future<void> _saveProfile() async {
    try {
      final profile = await ref
          .read(styleLabControllerProvider.notifier)
          .saveProfile(
            runId: widget.run.id,
            styleName: _styleNameController.text,
            profileMarkdown: _profileController.text,
            projectId: widget.run.projectId,
          );
      if (!mounted) return;
      _showSnack('风格档案已保存。');
      context.go('/style-lab/profiles/${profile.id}');
    } on Object catch (error) {
      _showSnack('$error');
    }
  }

  Future<void> _copyProfile() async {
    await Clipboard.setData(ClipboardData(text: _profileController.text));
    _showSnack('已复制 Voice Profile。');
  }

  Future<void> _deleteDraft() async {
    final confirmed = await _confirmDeleteStyleItem(
      context: context,
      title: '删除 Voice Profile 草稿',
      message: '确定删除「${widget.run.styleName}」吗？草稿、任务状态和日志会从本地数据库中移除。',
    );
    if (!mounted || !confirmed) return;
    try {
      await ref
          .read(styleLabControllerProvider.notifier)
          .deleteRun(widget.run.id);
      if (!mounted) return;
      _showSnack('草稿已删除。');
      context.go('/style-lab');
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

class _StyleLabTaskDetail extends ConsumerStatefulWidget {
  const _StyleLabTaskDetail({required this.run, required this.sample});

  final StyleAnalysisRun run;
  final AsyncValue<StyleSample?> sample;

  @override
  ConsumerState<_StyleLabTaskDetail> createState() =>
      _StyleLabTaskDetailState();
}

class _StyleLabTaskDetailState extends ConsumerState<_StyleLabTaskDetail> {
  final _styleNameController = TextEditingController();
  final _profileController = TextEditingController();
  String? _documentKey;
  bool _previewProfile = false;

  @override
  void initState() {
    super.initState();
    _syncTask();
  }

  @override
  void didUpdateWidget(covariant _StyleLabTaskDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTask();
  }

  @override
  void dispose() {
    _styleNameController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  void _syncTask() {
    final key =
        '${widget.run.id}:${widget.run.voiceProfileMarkdown.hashCode}:${widget.run.profileId ?? ''}';
    if (_documentKey == key) return;
    _styleNameController.text = widget.run.styleName;
    _profileController.text = widget.run.voiceProfileMarkdown ?? '';
    _documentKey = key;
  }

  @override
  Widget build(BuildContext context) {
    final profileId = widget.run.profileId;
    final hasProfile = profileId != null;
    final canSave =
        widget.run.status == StyleAnalysisStatus.succeeded && !hasProfile;

    return _ProfileDetailBody(
      titleController: _styleNameController,
      profileController: _profileController,
      previewProfile: _previewProfile,
      run: AsyncValue.data(widget.run),
      sample: widget.sample,
      reportMarkdown: widget.run.analysisReportMarkdown,
      sourceTitle: null,
      primaryActionLabel: hasProfile ? '打开 Profile' : '保存为 Profile',
      primaryActionIcon: hasProfile
          ? Icons.open_in_new_outlined
          : Icons.save_outlined,
      primaryActionEnabled: hasProfile || canSave,
      deleteTooltip: '删除任务',
      onPreviewChanged: (value) => setState(() => _previewProfile = value),
      onPrimaryAction: hasProfile ? _openProfile : _saveProfile,
      onCopyProfile: _copyProfile,
      onDelete: _deleteTask,
    );
  }

  Future<void> _saveProfile() async {
    try {
      final profile = await ref
          .read(styleLabControllerProvider.notifier)
          .saveProfile(
            runId: widget.run.id,
            styleName: _styleNameController.text,
            profileMarkdown: _profileController.text,
            projectId: widget.run.projectId,
          );
      if (!mounted) return;
      _showSnack('风格档案已保存，可从当前任务打开。');
      context.go('/style-lab/tasks/${widget.run.id}');
      await ref.read(styleAnalysisRunProvider(widget.run.id).future);
      if (!mounted) return;
      _documentKey = null;
      _styleNameController.text = profile.styleName;
    } on Object catch (error) {
      _showSnack('$error');
    }
  }

  Future<void> _copyProfile() async {
    await Clipboard.setData(ClipboardData(text: _profileController.text));
    _showSnack('已复制 Voice Profile。');
  }

  Future<void> _deleteTask() async {
    final confirmed = await _confirmDeleteStyleItem(
      context: context,
      title: '删除分析任务',
      message: '确定删除「${widget.run.styleName}」吗？任务状态、日志和草稿会从本地数据库中移除。',
    );
    if (!mounted || !confirmed) return;
    try {
      await ref
          .read(styleLabControllerProvider.notifier)
          .deleteRun(widget.run.id);
      if (!mounted) return;
      _showSnack('分析任务已删除。');
      context.go('/style-lab');
    } on Object catch (error) {
      _showSnack('$error');
    }
  }

  void _openProfile() {
    final profileId = widget.run.profileId;
    if (profileId == null) return;
    context.go('/style-lab/profiles/$profileId');
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ProfileDetailBody extends StatefulWidget {
  const _ProfileDetailBody({
    required this.titleController,
    required this.profileController,
    required this.previewProfile,
    required this.run,
    required this.sample,
    required this.reportMarkdown,
    required this.primaryActionLabel,
    required this.primaryActionIcon,
    required this.onPreviewChanged,
    required this.onPrimaryAction,
    required this.onCopyProfile,
    required this.onDelete,
    this.sourceTitle,
    this.primaryActionEnabled = true,
    this.deleteTooltip = '删除',
  });

  final TextEditingController titleController;
  final TextEditingController profileController;
  final bool previewProfile;
  final AsyncValue<StyleAnalysisRun?> run;
  final AsyncValue<StyleSample?> sample;
  final String? reportMarkdown;
  final String? sourceTitle;
  final String primaryActionLabel;
  final IconData primaryActionIcon;
  final bool primaryActionEnabled;
  final String deleteTooltip;
  final ValueChanged<bool> onPreviewChanged;
  final VoidCallback onPrimaryAction;
  final VoidCallback onCopyProfile;
  final VoidCallback onDelete;

  @override
  State<_ProfileDetailBody> createState() => _ProfileDetailBodyState();
}

class _ProfileDetailBodyState extends State<_ProfileDetailBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    widget.profileController.addListener(_handleDocumentChanged);
  }

  @override
  void didUpdateWidget(covariant _ProfileDetailBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profileController != widget.profileController) {
      oldWidget.profileController.removeListener(_handleDocumentChanged);
      widget.profileController.addListener(_handleDocumentChanged);
    }
  }

  @override
  void dispose() {
    widget.profileController.removeListener(_handleDocumentChanged);
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
              profileMarkdown: widget.profileController.text,
              run: widget.run,
              primaryActionLabel: widget.primaryActionLabel,
              primaryActionIcon: widget.primaryActionIcon,
              primaryActionEnabled: widget.primaryActionEnabled,
              deleteTooltip: widget.deleteTooltip,
              onPrimaryAction: widget.onPrimaryAction,
              onCopyProfile: widget.onCopyProfile,
              onDelete: widget.onDelete,
            ),
          ),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Voice Profile'),
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
                KeepAliveTabWrapper(
                  child: _VoiceProfileTab(
                    controller: widget.profileController,
                    preview: widget.previewProfile,
                    onPreviewChanged: widget.onPreviewChanged,
                  ),
                ),
                KeepAliveTabWrapper(
                  child: _ReportTab(markdown: widget.reportMarkdown),
                ),
                KeepAliveTabWrapper(
                  child: _SampleTab(
                    sample: widget.sample,
                    sourceTitle: widget.sourceTitle,
                  ),
                ),
                KeepAliveTabWrapper(
                  child: _RunLogTab(run: widget.run),
                ),
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
    required this.profileMarkdown,
    required this.run,
    required this.primaryActionLabel,
    required this.primaryActionIcon,
    required this.primaryActionEnabled,
    required this.deleteTooltip,
    required this.onPrimaryAction,
    required this.onCopyProfile,
    required this.onDelete,
  });

  final TextEditingController titleController;
  final String profileMarkdown;
  final AsyncValue<StyleAnalysisRun?> run;
  final String primaryActionLabel;
  final IconData primaryActionIcon;
  final bool primaryActionEnabled;
  final String deleteTooltip;
  final VoidCallback onPrimaryAction;
  final VoidCallback onCopyProfile;
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
            _ValidationStatus(markdown: profileMarkdown),
            if (currentRun != null)
              PersonaStatusPill(
                label: currentRun.status.name,
                icon: statusIcon(currentRun.status.name),
                color: statusColor(colorScheme, currentRun.status.name),
              ),
            FilledButton.icon(
              onPressed: primaryActionEnabled ? onPrimaryAction : null,
              icon: Icon(primaryActionIcon),
              label: Text(primaryActionLabel),
            ),
            IconButton.outlined(
              tooltip: '复制完整 YAML+MD',
              onPressed: profileMarkdown.trim().isEmpty ? null : onCopyProfile,
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
            labelText: '风格档案名称',
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

class _VoiceProfileTab extends StatelessWidget {
  const _VoiceProfileTab({
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
            child: _ProfileEditor(controller: controller, preview: preview),
          ),
        ],
      ),
    );
  }
}

class _ReportTab extends StatelessWidget {
  const _ReportTab({required this.markdown});

  final String? markdown;

  @override
  Widget build(BuildContext context) {
    final text = markdown?.trim();
    if (text == null || text.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(18),
        child: PersonaEmptyStateCard(
          icon: Icons.article_outlined,
          title: '暂无分析报告',
          description: '分析完成后会在这里展示只读报告。',
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

  final AsyncValue<StyleSample?> sample;
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
                    icon: item.sourceType == StyleSampleSourceType.epubChapter
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
              CodeBlock(text: item.content),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.all(18),
        child: InlineError(message: '$error'),
      ),
    );
  }
}

class _RunLogTab extends StatelessWidget {
  const _RunLogTab({required this.run});

  final AsyncValue<StyleAnalysisRun?> run;

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
                      label: item.status.name,
                      icon: statusIcon(item.status.name),
                      color: statusColor(
                        Theme.of(context).colorScheme,
                        item.status.name,
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
                InlineError(message: item.errorMessage!),
              ],
              const SizedBox(height: 14),
              Text('完整日志', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              Expanded(
                child: CodeBlock(
                  key: const ValueKey('style-lab-run-log-code-block'),
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
        child: InlineError(message: '$error'),
      ),
    );
  }
}

class _RunProgressOverview extends StatelessWidget {
  const _RunProgressOverview({required this.run});

  final StyleAnalysisRun run;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = _progressForRun(run);
    final runStatusColor = statusColor(colorScheme, run.status.name);
    final progressValue = _visibleProgressValue(run, progress);

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
                  color: runStatusColor,
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
            for (final step in _styleAnalysisSteps)
              StageStepPill(
                label: step.label,
                state: _stageStepState(run, step),
              ),
          ],
        ),
      ],
    );
  }
}

class _ProfileEditor extends StatelessWidget {
  const _ProfileEditor({required this.controller, required this.preview});

  final TextEditingController controller;
  final bool preview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (preview) {
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(kPanelRadius),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: MarkdownBody(data: stripFrontMatter(controller.text)),
        ),
      );
    }
    return TextField(
      controller: controller,
      expands: true,
      maxLines: null,
      minLines: null,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
        labelText: 'YAML+MD 源码',
      ),
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        height: 1.45,
      ),
    );
  }
}

class _ValidationStatus extends StatelessWidget {
  const _ValidationStatus({required this.markdown});

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
      const VoiceProfileFrontMatterParser().parse(markdown);
      return const PersonaStatusPill(
        label: 'YAML 契约有效',
        icon: Icons.verified_outlined,
        color: Color(0xFF16825D),
      );
    } on Object catch (error) {
      return PersonaStatusPill(
        label: '$error',
        icon: Icons.error_outline,
        color: colorScheme.error,
      );
    }
  }
}



Future<bool> _confirmDeleteStyleItem({
  required BuildContext context,
  required String title,
  required String message,
}) async {
  final confirmed = await showGlassDialog<bool>(
    context: context,
    maxWidth: 500,
    builder: (context) => Column(
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
            Text(title, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        const SizedBox(height: 12),
        Text(message),
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
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('删除'),
            ),
          ],
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

enum _StyleLibraryFilter { all, saved, drafts, activity }

enum _StyleLibraryAssetKind { saved, draft }

enum _StyleAssetMenuAction { delete }

class _RunActivitySummary {
  const _RunActivitySummary({
    required this.text,
    required this.icon,
    this.color,
  });

  final String text;
  final IconData icon;
  final Color? color;
}

class _StyleAnalysisStep {
  const _StyleAnalysisStep({required this.stage, required this.label});

  final StyleAnalysisStage? stage;
  final String label;
}

class _RunProgress {
  const _RunProgress({required this.value, required this.label});

  final double? value;
  final String label;
}

const _styleAnalysisSteps = [
  _StyleAnalysisStep(stage: StyleAnalysisStage.preparingInput, label: '准备输入'),
  _StyleAnalysisStep(stage: StyleAnalysisStage.analyzingChunks, label: '分块分析'),
  _StyleAnalysisStep(stage: StyleAnalysisStage.aggregating, label: '聚合'),
  _StyleAnalysisStep(stage: StyleAnalysisStage.reporting, label: '报告'),
  _StyleAnalysisStep(
    stage: StyleAnalysisStage.buildingVoiceProfile,
    label: 'Voice Profile',
  ),
  _StyleAnalysisStep(stage: null, label: '完成'),
];

class _StyleLibraryAsset {
  const _StyleLibraryAsset({
    required this.id,
    required this.kind,
    required this.title,
    required this.sourceTitle,
    required this.providerLabel,
    required this.profileMarkdown,
    required this.status,
    required this.updatedAt,
  });

  final String id;
  final _StyleLibraryAssetKind kind;
  final String title;
  final String sourceTitle;
  final String providerLabel;
  final String profileMarkdown;
  final StyleAnalysisStatus status;
  final DateTime updatedAt;
}

List<_StyleLibraryAsset> _buildLibraryAssets({
  required List<StyleProfile> profiles,
  required List<StyleAnalysisRun> runs,
  required List<StyleSample> samples,
  required List<ProviderConfig> providers,
}) {
  final sampleById = {for (final sample in samples) sample.id: sample};
  final providerById = {
    for (final provider in providers) provider.id: provider,
  };
  final assets = <_StyleLibraryAsset>[
    for (final profile in profiles)
      _StyleLibraryAsset(
        id: profile.id,
        kind: _StyleLibraryAssetKind.saved,
        title: profile.styleName,
        sourceTitle:
            profile.sourceTitle ??
            sampleById[profile.sourceSampleId]?.title ??
            '来源样本不可用',
        providerLabel: providerLabel(
          providerById[profile.providerId]?.name,
          profile.modelName,
        ),
        profileMarkdown: profile.profileMarkdown,
        status: StyleAnalysisStatus.succeeded,
        updatedAt: profile.updatedAt,
      ),
    for (final run in runs.where(_isDraftRun))
      _StyleLibraryAsset(
        id: run.id,
        kind: _StyleLibraryAssetKind.draft,
        title: run.styleName,
        sourceTitle: sampleById[run.sampleId]?.title ?? '来源样本不可用',
        providerLabel: providerLabel(
          providerById[run.providerId]?.name,
          run.modelName,
        ),
        profileMarkdown: run.voiceProfileMarkdown!,
        status: run.status,
        updatedAt: run.updatedAt,
      ),
  ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return assets;
}

List<_StyleLibraryAsset> _filterAssets(
  List<_StyleLibraryAsset> assets,
  _StyleLibraryFilter filter,
) {
  return switch (filter) {
    _StyleLibraryFilter.all => assets,
    _StyleLibraryFilter.saved =>
      assets
          .where((asset) => asset.kind == _StyleLibraryAssetKind.saved)
          .toList(growable: false),
    _StyleLibraryFilter.drafts =>
      assets
          .where((asset) => asset.kind == _StyleLibraryAssetKind.draft)
          .toList(growable: false),
    _StyleLibraryFilter.activity => const [],
  };
}

bool _isDraftRun(StyleAnalysisRun run) {
  return run.status == StyleAnalysisStatus.succeeded &&
      run.profileId == null &&
      (run.voiceProfileMarkdown?.trim().isNotEmpty ?? false);
}

bool _isActivityRun(StyleAnalysisRun run) {
  if (_isDraftRun(run)) {
    return false;
  }
  return run.status == StyleAnalysisStatus.pending ||
      run.status == StyleAnalysisStatus.running ||
      run.status == StyleAnalysisStatus.failed ||
      (run.status == StyleAnalysisStatus.succeeded && run.profileId == null);
}

String _taskDetailSubtitle(StyleAnalysisRun run) {
  final status = run.status.name;
  final stage = _stageLabel(run.stage);
  final chunks = _chunkProgressLabel(run);
  return '$status · $stage · $chunks · ${run.modelName}';
}

String _sourceLabel(StyleSample sample) {
  return switch (sample.sourceType) {
    StyleSampleSourceType.txt => 'TXT',
    StyleSampleSourceType.epubChapter => 'EPUB 章节',
  };
}

String _stageLabel(StyleAnalysisStage? stage) {
  return switch (stage) {
    StyleAnalysisStage.preparingInput => '准备输入',
    StyleAnalysisStage.analyzingChunks => '分块分析',
    StyleAnalysisStage.aggregating => '聚合分析',
    StyleAnalysisStage.reporting => '生成报告',
    StyleAnalysisStage.buildingVoiceProfile => '生成 Voice Profile',
    StyleAnalysisStage.persistingResult => '保存结果',
    null => '等待阶段',
  };
}

String _chunkProgressLabel(StyleAnalysisRun run) {
  final chunkCount = run.chunkCount;
  if (chunkCount <= 0) {
    return 'chunks 待计算';
  }
  final completed = _completedChunkCount(run);
  if (completed == null) {
    return '$chunkCount chunks';
  }
  return '$completed/$chunkCount chunks';
}

_RunActivitySummary _runActivitySummary(StyleAnalysisRun run) {
  final error = run.errorMessage?.trim();
  if (error != null && error.isNotEmpty) {
    return _RunActivitySummary(
      text: error,
      icon: Icons.error_outline,
      color: const Color(0xFFC93434),
    );
  }

  final log = run.logs.trim();
  if (log.isNotEmpty) {
    final lines = log
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    return _RunActivitySummary(
      text: lines.isEmpty ? log : lines.last,
      icon: Icons.notes_outlined,
    );
  }

  return switch (run.status) {
    StyleAnalysisStatus.pending => const _RunActivitySummary(
      text: '任务已进入队列，等待开始分析。',
      icon: Icons.schedule,
    ),
    StyleAnalysisStatus.running => const _RunActivitySummary(
      text: '任务正在运行，打开详情可查看完整日志和阶段进度。',
      icon: Icons.sync,
    ),
    StyleAnalysisStatus.succeeded => const _RunActivitySummary(
      text: '任务已完成，打开详情可检查报告并保存为 Profile。',
      icon: Icons.check_circle_outline,
      color: Color(0xFF16825D),
    ),
    StyleAnalysisStatus.failed => const _RunActivitySummary(
      text: '任务失败，打开详情可查看诊断信息。',
      icon: Icons.error_outline,
      color: Color(0xFFC93434),
    ),
  };
}

int? _completedChunkCount(StyleAnalysisRun run) {
  final chunkCount = run.chunkCount;
  if (chunkCount <= 0) {
    return null;
  }
  if (run.status == StyleAnalysisStatus.succeeded) {
    return chunkCount;
  }
  final matches = RegExp(
    r'完成 chunk\s+(\d+)/(\d+)',
    caseSensitive: false,
  ).allMatches(run.logs);
  if (matches.isEmpty) {
    return null;
  }
  var completed = 0;
  for (final match in matches) {
    final current = int.tryParse(match.group(1) ?? '');
    final total = int.tryParse(match.group(2) ?? '');
    if (current == null || total == null || total != chunkCount) {
      continue;
    }
    if (current > completed) {
      completed = current;
    }
  }
  return completed.clamp(0, chunkCount);
}

_RunProgress _progressForRun(StyleAnalysisRun run) {
  return switch (run.status) {
    StyleAnalysisStatus.succeeded => const _RunProgress(
      value: 1,
      label: '100%',
    ),
    StyleAnalysisStatus.failed => _RunProgress(
      value: _stageProgressValue(run.stage, run),
      label: '失败',
    ),
    StyleAnalysisStatus.pending => const _RunProgress(
      value: null,
      label: '等待中',
    ),
    StyleAnalysisStatus.running => _runningProgress(run),
  };
}

double? _visibleProgressValue(StyleAnalysisRun run, _RunProgress progress) {
  return run.status == StyleAnalysisStatus.failed ? 1.0 : progress.value;
}

_RunProgress _runningProgress(StyleAnalysisRun run) {
  final value = _stageProgressValue(run.stage, run);
  if (value == null) {
    return const _RunProgress(value: null, label: '运行中');
  }
  return _RunProgress(value: value, label: '${(value * 100).round()}%');
}

double? _stageProgressValue(StyleAnalysisStage? stage, StyleAnalysisRun run) {
  final base = switch (stage) {
    StyleAnalysisStage.preparingInput => 0.08,
    StyleAnalysisStage.analyzingChunks => _chunkStageProgress(run),
    StyleAnalysisStage.aggregating => 0.64,
    StyleAnalysisStage.reporting => 0.78,
    StyleAnalysisStage.buildingVoiceProfile => 0.9,
    StyleAnalysisStage.persistingResult => 0.96,
    null => null,
  };
  return base?.clamp(0.0, 1.0).toDouble();
}

double _chunkStageProgress(StyleAnalysisRun run) {
  final chunkCount = run.chunkCount;
  final completed = _completedChunkCount(run);
  if (chunkCount <= 0 || completed == null) {
    return 0.18;
  }
  return 0.18 + (0.42 * completed / chunkCount);
}

StageStepState _stageStepState(StyleAnalysisRun run, _StyleAnalysisStep step) {
  if (run.status == StyleAnalysisStatus.failed &&
      (step.stage == run.stage || (run.stage == null && step.stage == null))) {
    return StageStepState.failed;
  }
  if (run.status == StyleAnalysisStatus.succeeded) {
    return StageStepState.done;
  }
  if (step.stage == run.stage) {
    return StageStepState.active;
  }
  final currentIndex = _stageIndex(run.stage);
  final stepIndex = _stageIndex(step.stage);
  if (currentIndex != null && stepIndex != null && stepIndex < currentIndex) {
    return StageStepState.done;
  }
  return StageStepState.waiting;
}

int? _stageIndex(StyleAnalysisStage? stage) {
  final index = _styleAnalysisSteps.indexWhere((step) => step.stage == stage);
  return index < 0 ? null : index;
}

String _emptyTitle(_StyleLibraryFilter filter) {
  return switch (filter) {
    _StyleLibraryFilter.all => '尚无 Profile 资产',
    _StyleLibraryFilter.saved => '尚无已保存 Profile',
    _StyleLibraryFilter.drafts => '尚无待保存草稿',
    _StyleLibraryFilter.activity => '任务入口在下方活动区',
  };
}

String _emptyDescription(_StyleLibraryFilter filter) {
  return switch (filter) {
    _StyleLibraryFilter.all => '点击页头的新建按钮，导入样本并运行分析。',
    _StyleLibraryFilter.saved => '从草稿详情页保存后，Style Profile 会出现在这里。',
    _StyleLibraryFilter.drafts => '分析成功且尚未保存的 Voice Profile 会出现在这里。',
    _StyleLibraryFilter.activity => '运行中或失败的任务会在任务活动区展示。',
  };
}
