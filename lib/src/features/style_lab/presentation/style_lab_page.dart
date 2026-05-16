import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/persona_page.dart';
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
          error: (error, stackTrace) => _InlineError(message: '$error'),
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

  Future<void> _showCreateProfileDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => const _CreateProfileDialog(),
    );
  }

  void _openAsset(_StyleLibraryAsset asset) {
    switch (asset.kind) {
      case _StyleLibraryAssetKind.saved:
        context.go('/style-lab/profiles/${asset.id}');
      case _StyleLibraryAssetKind.draft:
        context.go('/style-lab/drafts/${asset.id}');
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

class StyleLabProfileDetailPage extends ConsumerWidget {
  const StyleLabProfileDetailPage({required this.profileId, super.key});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(styleProfileProvider(profileId));
    return profile.when(
      data: (item) {
        if (item == null) {
          return _StyleLabMissingDetail(
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
      loading: () => const _StyleLabDetailLoading(),
      error: (error, stackTrace) =>
          _StyleLabMissingDetail(title: '无法读取 Profile', description: '$error'),
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
          return _StyleLabMissingDetail(
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
      loading: () => const _StyleLabDetailLoading(),
      error: (error, stackTrace) =>
          _StyleLabMissingDetail(title: '无法读取草稿', description: '$error'),
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
  });

  final List<_StyleLibraryAsset> assets;
  final List<StyleAnalysisRun> activeRuns;
  final _StyleLibraryFilter filter;
  final ValueChanged<_StyleLibraryFilter> onFilterChanged;
  final ValueChanged<_StyleLibraryAsset> onAssetSelected;
  final ValueChanged<StyleAnalysisRun> onRerun;

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
        ),
        if (activeRuns.isNotEmpty) ...[
          const SizedBox(height: 14),
          _ActivityRunsPanel(runs: activeRuns, onRerun: onRerun),
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
    final controller = ref.watch(styleLabControllerProvider);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: samples.when(
            data: (sampleItems) => providers.when(
              data: (providerItems) {
                _syncDefaults(sampleItems, providerItems);
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
                return _CreateProfileForm(
                  samples: sampleItems,
                  providers: providerItems,
                  selectedSample: selectedSample,
                  selectedProvider: selectedProvider,
                  styleNameController: _styleNameController,
                  controllerBusy: controller.isLoading,
                  onImportSample: _importSample,
                  onSampleSelected: (id) => setState(() {
                    _selectedSampleId = id;
                    _styleNameController.text =
                        _findOrNull(
                          sampleItems,
                          id,
                          (item) => item.id,
                        )?.title ??
                        '';
                  }),
                  onProviderSelected: (id) =>
                      setState(() => _selectedProviderId = id),
                  onRun: selectedSample == null || selectedProvider == null
                      ? null
                      : () => _createRun(selectedSample, selectedProvider),
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
        ),
      ),
    );
  }

  void _syncDefaults(
    List<StyleSample> samples,
    List<ProviderConfig> providers,
  ) {
    if (_selectedSampleId == null && samples.isNotEmpty) {
      _selectedSampleId = samples.first.id;
      _styleNameController.text = samples.first.title;
    }
    if (_selectedProviderId == null && providers.isNotEmpty) {
      final enabled = providers.where((provider) => provider.isEnabled);
      _selectedProviderId =
          (enabled.isEmpty ? providers.first : enabled.first).id;
    }
    if (_selectedSampleId != null &&
        !samples.any((sample) => sample.id == _selectedSampleId)) {
      _selectedSampleId = samples.isEmpty ? null : samples.first.id;
    }
    if (_selectedProviderId != null &&
        !providers.any((provider) => provider.id == _selectedProviderId)) {
      _selectedProviderId = providers.isEmpty ? null : providers.first.id;
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
          .importFile(path);
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

  Future<void> _createRun(StyleSample sample, ProviderConfig provider) async {
    try {
      final run = await ref
          .read(styleLabControllerProvider.notifier)
          .createAndRun(
            sampleId: sample.id,
            providerId: provider.id,
            styleName: _styleNameController.text,
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
    required this.samples,
    required this.providers,
    required this.styleNameController,
    required this.controllerBusy,
    required this.onImportSample,
    required this.onSampleSelected,
    required this.onProviderSelected,
    this.selectedSample,
    this.selectedProvider,
    this.onRun,
  });

  final List<StyleSample> samples;
  final List<ProviderConfig> providers;
  final StyleSample? selectedSample;
  final ProviderConfig? selectedProvider;
  final TextEditingController styleNameController;
  final bool controllerBusy;
  final VoidCallback onImportSample;
  final ValueChanged<String> onSampleSelected;
  final ValueChanged<String> onProviderSelected;
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
                  description: '导入或选择样本，运行分析后生成可保存的 Voice Profile 草稿。',
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
              labelText: 'Provider / Model',
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

class _StyleLibraryList extends StatelessWidget {
  const _StyleLibraryList({
    required this.assets,
    required this.filter,
    required this.onAssetSelected,
  });

  final List<_StyleLibraryAsset> assets;
  final _StyleLibraryFilter filter;
  final ValueChanged<_StyleLibraryAsset> onAssetSelected;

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
  });

  final _StyleLibraryAsset asset;
  final bool compact;
  final VoidCallback onTap;

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
                        _YamlPill(markdown: asset.profileMarkdown),
                        PersonaStatusPill(
                          label: _statusLabel(asset.status),
                          icon: _statusIcon(asset.status),
                          color: _statusColor(colorScheme, asset.status),
                        ),
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
                        _formatDate(asset.updatedAt),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
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

class _AssetTitle extends StatelessWidget {
  const _AssetTitle({required this.asset});

  final _StyleLibraryAsset asset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
              Text(asset.title, maxLines: 1, overflow: TextOverflow.ellipsis),
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
  const _ActivityRunsPanel({required this.runs, required this.onRerun});

  final List<StyleAnalysisRun> runs;
  final ValueChanged<StyleAnalysisRun> onRerun;

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
            _ActivityRunRow(run: run, onRerun: () => onRerun(run)),
            if (run != runs.last) const Divider(height: 18),
          ],
        ],
      ),
    );
  }
}

class _ActivityRunRow extends StatelessWidget {
  const _ActivityRunRow({required this.run, required this.onRerun});

  final StyleAnalysisRun run;
  final VoidCallback onRerun;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(run.styleName),
              PersonaStatusPill(
                label: _statusLabel(run.status),
                icon: _statusIcon(run.status),
                color: _statusColor(colorScheme, run.status),
              ),
              if (run.stage != null)
                PersonaStatusPill(label: run.stage!.name, icon: Icons.timeline),
              if (run.errorMessage != null)
                Text(
                  run.errorMessage!,
                  style: TextStyle(color: colorScheme.error),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: run.status == StyleAnalysisStatus.failed ? onRerun : null,
          icon: const Icon(Icons.replay_outlined),
          label: const Text('重跑'),
        ),
      ],
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
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: 'Profile Detail',
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
      onPreviewChanged: (value) => setState(() => _previewProfile = value),
      onPrimaryAction: _saveProfile,
      onCopyProfile: _copyProfile,
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
    this.sourceTitle,
    this.primaryActionEnabled = true,
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
  final ValueChanged<bool> onPreviewChanged;
  final VoidCallback onPrimaryAction;
  final VoidCallback onCopyProfile;

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
              onPrimaryAction: widget.onPrimaryAction,
              onCopyProfile: widget.onCopyProfile,
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
                _VoiceProfileTab(
                  controller: widget.profileController,
                  preview: widget.previewProfile,
                  onPreviewChanged: widget.onPreviewChanged,
                ),
                _ReportTab(markdown: widget.reportMarkdown),
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
    required this.profileMarkdown,
    required this.run,
    required this.primaryActionLabel,
    required this.primaryActionIcon,
    required this.primaryActionEnabled,
    required this.onPrimaryAction,
    required this.onCopyProfile,
  });

  final TextEditingController titleController;
  final String profileMarkdown;
  final AsyncValue<StyleAnalysisRun?> run;
  final String primaryActionLabel;
  final IconData primaryActionIcon;
  final bool primaryActionEnabled;
  final VoidCallback onPrimaryAction;
  final VoidCallback onCopyProfile;

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
              tooltip: '复制完整 YAML+MD',
              onPressed: profileMarkdown.trim().isEmpty ? null : onCopyProfile,
              icon: const Icon(Icons.copy_outlined),
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
                    label: _statusLabel(item.status),
                    icon: _statusIcon(item.status),
                    color: _statusColor(
                      Theme.of(context).colorScheme,
                      item.status,
                    ),
                  ),
                  if (item.stage != null)
                    PersonaStatusPill(
                      label: item.stage!.name,
                      icon: Icons.timeline,
                    ),
                  PersonaStatusPill(
                    label: '${item.chunkCount} chunks',
                    icon: Icons.grain,
                  ),
                ],
              ),
              if (item.errorMessage != null) ...[
                const SizedBox(height: 12),
                _InlineError(message: item.errorMessage!),
              ],
              const SizedBox(height: 14),
              _CodeBlock(text: item.logs.trim().isEmpty ? '暂无日志。' : item.logs),
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
          child: MarkdownBody(data: _stripFrontMatter(controller.text)),
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

class _StyleLabDetailLoading extends StatelessWidget {
  const _StyleLabDetailLoading();

  @override
  Widget build(BuildContext context) {
    return const PersonaPage(
      eyebrow: 'Profile Detail',
      title: '读取中',
      description: '正在读取风格档案。',
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

class _StyleLabMissingDetail extends StatelessWidget {
  const _StyleLabMissingDetail({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: 'Profile Detail',
      title: title,
      description: description,
      actions: [
        OutlinedButton.icon(
          onPressed: () => context.go('/style-lab'),
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
  const _CodeBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(kPanelRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 220, maxHeight: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: SelectableText(
            text,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5),
          ),
        ),
      ),
    );
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

enum _StyleLibraryFilter { all, saved, drafts, activity }

enum _StyleLibraryAssetKind { saved, draft }

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
        providerLabel: _providerLabel(
          providerById[profile.providerId],
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
        providerLabel: _providerLabel(
          providerById[run.providerId],
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

String _sourceLabel(StyleSample sample) {
  return switch (sample.sourceType) {
    StyleSampleSourceType.txt => 'TXT',
    StyleSampleSourceType.epubChapter => 'EPUB 章节',
  };
}

String _statusLabel(StyleAnalysisStatus status) {
  return switch (status) {
    StyleAnalysisStatus.pending => 'pending',
    StyleAnalysisStatus.running => 'running',
    StyleAnalysisStatus.paused => 'paused',
    StyleAnalysisStatus.succeeded => 'succeeded',
    StyleAnalysisStatus.failed => 'failed',
    StyleAnalysisStatus.canceled => 'canceled',
  };
}

IconData _statusIcon(StyleAnalysisStatus status) {
  return switch (status) {
    StyleAnalysisStatus.pending => Icons.schedule,
    StyleAnalysisStatus.running => Icons.sync,
    StyleAnalysisStatus.paused => Icons.pause_circle_outline,
    StyleAnalysisStatus.succeeded => Icons.check_circle_outline,
    StyleAnalysisStatus.failed => Icons.error_outline,
    StyleAnalysisStatus.canceled => Icons.cancel_outlined,
  };
}

Color _statusColor(ColorScheme colorScheme, StyleAnalysisStatus status) {
  return switch (status) {
    StyleAnalysisStatus.pending => colorScheme.tertiary,
    StyleAnalysisStatus.running => colorScheme.primary,
    StyleAnalysisStatus.paused => const Color(0xFF8C6A14),
    StyleAnalysisStatus.succeeded => const Color(0xFF16825D),
    StyleAnalysisStatus.failed => colorScheme.error,
    StyleAnalysisStatus.canceled => colorScheme.onSurfaceVariant,
  };
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
  return bodyStart < 0 ? '' : normalized.substring(bodyStart).trim();
}

String _formatDate(DateTime value) {
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(value.month)}-${two(value.day)} ${two(value.hour)}:${two(value.minute)}';
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
