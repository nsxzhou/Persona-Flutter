import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/analysis_lab_widgets.dart';
import '../../../core/ui/glass_container.dart';
import '../../../core/ui/persona_page.dart';
import '../../../core/ui/skeleton_loader.dart';
import '../../novel_workshop/application/novel_workshop_providers.dart';
import '../../novel_workshop/domain/novel_import.dart';
import '../../plot_lab/application/plot_lab_providers.dart';
import '../../plot_lab/domain/plot_profile.dart';
import '../../settings/application/provider_config_providers.dart';
import '../../settings/domain/provider_config.dart';
import '../../style_lab/application/style_lab_providers.dart';
import '../../style_lab/domain/style_profile.dart';
import '../application/project_providers.dart';
import '../domain/writing_project.dart';

class ProjectsPage extends ConsumerStatefulWidget {
  const ProjectsPage({super.key});

  @override
  ConsumerState<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends ConsumerState<ProjectsPage> {
  ProjectStatus _selectedStatus = ProjectStatus.active;

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(writingProjectsProvider(_selectedStatus));

    return PersonaPage(
      eyebrow: '工作区',
      title: '项目',
      description: '用于长篇项目、蓝图和本地写作会话的项目管理工作区。',
      actions: [
        OutlinedButton.icon(
          onPressed: () => _showNovelImportDialog(context),
          icon: const Icon(Icons.upload_file_outlined),
          label: const Text('导入小说'),
        ),
        FilledButton.icon(
          onPressed: () => _showProjectDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('新建项目'),
        ),
      ],
      children: [
        projects.when(
          data: (items) => _ProjectWorkspace(
            items: items,
            selectedStatus: _selectedStatus,
            onStatusChanged: (status) {
              setState(() => _selectedStatus = status);
            },
          ),
          error: (error, stackTrace) => PersonaPanel(
            child: Text(
              '无法加载项目：$error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          loading: () => const _ProjectsLoading(),
        ),
      ],
    );
  }
}

class _ProjectWorkspace extends StatelessWidget {
  const _ProjectWorkspace({
    required this.items,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  final List<WritingProject> items;
  final ProjectStatus selectedStatus;
  final ValueChanged<ProjectStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _WorkspaceOverview(
          visibleCount: items.length,
          selectedStatus: selectedStatus,
          onStatusChanged: onStatusChanged,
        ),
        const SizedBox(height: 18),
        _ProjectListPanel(items: items, selectedStatus: selectedStatus),
      ],
    );
  }
}

class _WorkspaceOverview extends StatelessWidget {
  const _WorkspaceOverview({
    required this.visibleCount,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  final int visibleCount;
  final ProjectStatus selectedStatus;
  final ValueChanged<ProjectStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isActive = selectedStatus == ProjectStatus.active;

    return PersonaPanel(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final summary = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(
                    isActive
                        ? Icons.folder_open_outlined
                        : Icons.inventory_2_outlined,
                    color: colorScheme.primary,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          isActive ? '活动项目' : '归档项目',
                          style: textTheme.titleLarge,
                        ),
                        PersonaStatusPill(
                          label: '$visibleCount 个档案',
                          icon: isActive
                              ? Icons.edit_note_outlined
                              : Icons.inventory_2_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isActive
                          ? '默认工作区只显示正在推进的本地写作档案。'
                          : '归档项目会保留记录，但不会出现在默认工作区。',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          );

          final switcher = _ProjectStatusSwitcher(
            selectedStatus: selectedStatus,
            onChanged: onStatusChanged,
          );

          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                summary,
                const SizedBox(height: 14),
                Align(alignment: Alignment.centerLeft, child: switcher),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: summary),
              const SizedBox(width: 18),
              switcher,
            ],
          );
        },
      ),
    );
  }
}

class _ProjectStatusSwitcher extends StatelessWidget {
  const _ProjectStatusSwitcher({
    required this.selectedStatus,
    required this.onChanged,
  });

  final ProjectStatus selectedStatus;
  final ValueChanged<ProjectStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ProjectStatus>(
      showSelectedIcon: true,
      segments: const [
        ButtonSegment(
          value: ProjectStatus.active,
          icon: Icon(Icons.edit_note_outlined),
          label: Text('活动'),
        ),
        ButtonSegment(
          value: ProjectStatus.archived,
          icon: Icon(Icons.inventory_2_outlined),
          label: Text('归档'),
        ),
      ],
      selected: {selectedStatus},
      onSelectionChanged: (selection) => onChanged(selection.single),
    );
  }
}

class _ProjectListPanel extends StatelessWidget {
  const _ProjectListPanel({required this.items, required this.selectedStatus});

  final List<WritingProject> items;
  final ProjectStatus selectedStatus;

  @override
  Widget build(BuildContext context) {
    return PersonaPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: PersonaSectionHeader(
              title: selectedStatus == ProjectStatus.active ? '写作档案' : '归档档案',
              description: selectedStatus == ProjectStatus.active
                  ? '维护本地写作项目的简介、创作配置和归档状态。'
                  : '归档项目不会出现在默认工作区，可以恢复或永久删除。',
            ),
          ),
          const Divider(height: 1),
          if (items.isEmpty)
            _EmptyProjectsState(status: selectedStatus)
          else
            for (final item in items) _ProjectRow(project: item),
        ],
      ),
    );
  }
}

class _EmptyProjectsState extends StatelessWidget {
  const _EmptyProjectsState({required this.status});

  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isArchived = status == ProjectStatus.archived;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 26),
      child: Row(
        children: [
          Icon(
            isArchived
                ? Icons.inventory_2_outlined
                : Icons.library_books_outlined,
            color: colorScheme.primary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArchived ? '没有归档项目' : '尚未创建项目',
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  isArchived
                      ? '归档后的项目会保留在这里，方便恢复或永久删除。'
                      : '创建第一个本地写作档案后，可以在这里维护简介和创作配置。',
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (!isArchived) ...[
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: () => _showProjectDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('新建项目'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProjectRow extends StatelessWidget {
  const _ProjectRow({required this.project});

  final WritingProject project;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isActive = project.status == ProjectStatus.active;

    return InkWell(
      onTap: isActive
          ? () => context.go('/projects/${project.id}/workshop')
          : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final details = _ProjectRowDetails(project: project);
              final actions = _ProjectRowActions(project: project);
              final updated = Text(
                _formatProjectTime(project.updatedAt),
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              );

              if (constraints.maxWidth < 720) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    details,
                    const SizedBox(height: 12),
                    Row(children: [updated, const Spacer(), actions]),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: details),
                  const SizedBox(width: 18),
                  SizedBox(width: 92, child: updated),
                  const SizedBox(width: 10),
                  actions,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProjectRowDetails extends StatelessWidget {
  const _ProjectRowDetails({required this.project});

  final WritingProject project;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(
              project.status == ProjectStatus.active
                  ? Icons.folder_open_outlined
                  : Icons.inventory_2_outlined,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    project.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  PersonaStatusPill(
                    label: _statusLabel(project.status),
                    icon: project.status == ProjectStatus.active
                        ? Icons.edit_note_outlined
                        : Icons.inventory_2_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                project.description.trim().isEmpty
                    ? '未填写项目简介。'
                    : project.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProjectRowActions extends ConsumerWidget {
  const _ProjectRowActions({required this.project});

  final WritingProject project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<_ProjectMenuAction>(
      tooltip: '项目操作',
      icon: const Icon(Icons.more_horiz),
      onSelected: (action) {
        switch (action) {
          case _ProjectMenuAction.edit:
            _showProjectDialog(context, project: project);
          case _ProjectMenuAction.openWorkshop:
            context.go('/projects/${project.id}/workshop');
          case _ProjectMenuAction.archive:
            ref.read(projectControllerProvider.notifier).archive(project.id);
          case _ProjectMenuAction.restore:
            ref.read(projectControllerProvider.notifier).restore(project.id);
          case _ProjectMenuAction.delete:
            _confirmDeleteProject(context, ref, project);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _ProjectMenuAction.edit,
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18),
              SizedBox(width: 10),
              Text('编辑项目'),
            ],
          ),
        ),
        if (project.status == ProjectStatus.active)
          const PopupMenuItem(
            value: _ProjectMenuAction.openWorkshop,
            child: Row(
              children: [
                Icon(Icons.edit_note_outlined, size: 18),
                SizedBox(width: 10),
                Text('打开工作台'),
              ],
            ),
          ),
        PopupMenuItem(
          value: project.status == ProjectStatus.active
              ? _ProjectMenuAction.archive
              : _ProjectMenuAction.restore,
          child: Row(
            children: [
              Icon(
                project.status == ProjectStatus.active
                    ? Icons.inventory_2_outlined
                    : Icons.unarchive_outlined,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(project.status == ProjectStatus.active ? '归档项目' : '恢复项目'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: _ProjectMenuAction.delete,
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18),
              SizedBox(width: 10),
              Text('永久删除'),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProjectsLoading extends StatelessWidget {
  const _ProjectsLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (var index = 0; index < 3; index++) ...[
              Expanded(
                child: PersonaPanel(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonBox(width: 80, height: 10),
                      SizedBox(height: 14),
                      SkeletonBox(width: 46, height: 28),
                      SizedBox(height: 6),
                      SkeletonBox(width: 150, height: 12),
                    ],
                  ),
                ),
              ),
              if (index != 2) const SizedBox(width: 14),
            ],
          ],
        ),
        const SizedBox(height: 18),
        PersonaPanel(
          child: Column(
            children: List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    const SkeletonBox(width: 38, height: 38),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SkeletonBox(width: 160, height: 14),
                          SizedBox(height: 8),
                          SkeletonBox(width: 280, height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectDialog extends ConsumerStatefulWidget {
  const _ProjectDialog({this.project});

  final WritingProject? project;

  @override
  ConsumerState<_ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends ConsumerState<_ProjectDialog> {
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

  @override
  void initState() {
    super.initState();
    final project = widget.project;
    _titleController = TextEditingController(text: project?.title ?? '');
    _descriptionController = TextEditingController(
      text: project?.description ?? '',
    );
    _languageController = TextEditingController(
      text: project?.language ?? defaultProjectLanguage,
    );
    _targetLengthController = TextEditingController(
      text: (project?.targetLength ?? defaultProjectTargetLength).toString(),
    );
    _totalTargetLengthController = TextEditingController(
      text: (project?.totalTargetLength ?? defaultProjectTotalTargetLength)
          .toString(),
    );
    _perspectiveController = TextEditingController(
      text: project?.narrativePerspective ?? defaultProjectNarrativePerspective,
    );
    _status = project?.status ?? ProjectStatus.active;
    _selectedProviderId = project?.defaultProviderId;
    _selectedModelName = project?.defaultModelName;
    _selectedStyleProfileId = project?.styleProfileId;
    _selectedPlotProfileId = project?.plotProfileId;
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectControllerProvider);
    final providers = ref.watch(providerConfigsProvider);
    final styleProfiles = ref.watch(styleProfilesProvider);
    final plotProfiles = ref.watch(plotProfilesProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(projectControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败：${next.error}')));
      }
    });

    Widget asyncBody() {
      return providers.when(
        data: (providerItems) => styleProfiles.when(
          data: (styleItems) => plotProfiles.when(
            data: (plotItems) {
              _syncSelections(providerItems, styleItems, plotItems);
              final selectedProvider = _findById(
                providerItems,
                _selectedProviderId,
                (item) => item.id,
              );
              final selectedModelName = selectedProvider == null
                  ? null
                  : _selectedModelName;
              final canSave = providerItems.isNotEmpty && !state.isLoading;

              return _ProjectDialogForm(
                formKey: _formKey,
                titleController: _titleController,
                descriptionController: _descriptionController,
                languageController: _languageController,
                targetLengthController: _targetLengthController,
                totalTargetLengthController: _totalTargetLengthController,
                perspectiveController: _perspectiveController,
                status: _status,
                providers: providerItems,
                styleProfiles: styleItems,
                plotProfiles: plotItems,
                selectedProvider: selectedProvider,
                selectedModelName: selectedModelName,
                selectedStyleProfileId: _selectedStyleProfileId,
                selectedPlotProfileId: _selectedPlotProfileId,
                controllerBusy: state.isLoading,
                canSave: canSave,
                onStatusChanged: (status) => setState(() => _status = status),
                onProviderChanged: (id) {
                  setState(() {
                    _selectedProviderId = id;
                    _selectedModelName = _findById(
                      providerItems,
                      id,
                      (item) => item.id,
                    )?.defaultModel;
                  });
                },
                onModelChanged: (modelName) =>
                    setState(() => _selectedModelName = modelName),
                onStyleProfileChanged: (id) =>
                    setState(() => _selectedStyleProfileId = id),
                onPlotProfileChanged: (id) =>
                    setState(() => _selectedPlotProfileId = id),
                onCancel: () => Navigator.of(context).pop(),
                onSave: _save,
              );
            },
            error: (error, stackTrace) => _ProjectDialogLoadError('$error'),
            loading: () => const _ProjectDialogLoading(),
          ),
          error: (error, stackTrace) => _ProjectDialogLoadError('$error'),
          loading: () => const _ProjectDialogLoading(),
        ),
        error: (error, stackTrace) => _ProjectDialogLoadError('$error'),
        loading: () => const _ProjectDialogLoading(),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.project == null ? '新建项目' : '编辑项目',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          '维护项目身份、默认模型、Profile 挂载和基础写作参数。',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        Flexible(child: asyncBody()),
      ],
    );
  }

  void _syncSelections(
    List<ProviderConfig> providers,
    List<StyleProfile> styleProfiles,
    List<PlotProfile> plotProfiles,
  ) {
    if (_selectedProviderId == null && providers.isNotEmpty) {
      final enabled = providers.where((provider) => provider.isEnabled);
      final provider = enabled.isEmpty ? providers.first : enabled.first;
      _selectedProviderId = provider.id;
      _selectedModelName = provider.defaultModel;
    }
    if (_selectedProviderId != null &&
        !providers.any((provider) => provider.id == _selectedProviderId)) {
      _selectedProviderId = providers.isEmpty ? null : providers.first.id;
      _selectedModelName = providers.isEmpty
          ? null
          : providers.first.defaultModel;
    }
    final selectedProvider = _findById(
      providers,
      _selectedProviderId,
      (item) => item.id,
    );
    if (selectedProvider != null &&
        !selectedProvider.modelNames.contains(_selectedModelName)) {
      _selectedModelName = selectedProvider.defaultModel;
    }
    if (_selectedStyleProfileId != null &&
        !styleProfiles.any(
          (profile) => profile.id == _selectedStyleProfileId,
        )) {
      _selectedStyleProfileId = null;
    }
    if (_selectedPlotProfileId != null &&
        !plotProfiles.any((profile) => profile.id == _selectedPlotProfileId)) {
      _selectedPlotProfileId = null;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final providerId = _selectedProviderId?.trim();
    final modelName = _selectedModelName?.trim();
    if (providerId == null ||
        providerId.isEmpty ||
        modelName == null ||
        modelName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先选择 Provider 和模型。')));
      return;
    }

    await ref
        .read(projectControllerProvider.notifier)
        .save(
          id: widget.project?.id,
          input: WritingProjectInput(
            title: _titleController.text,
            description: _descriptionController.text,
            status: _status,
            defaultProviderId: providerId,
            defaultModelName: modelName,
            styleProfileId: _selectedStyleProfileId,
            plotProfileId: _selectedPlotProfileId,
            language: _languageController.text,
            targetLength:
                int.tryParse(_targetLengthController.text.trim()) ?? 0,
            totalTargetLength:
                int.tryParse(_totalTargetLengthController.text.trim()) ?? 0,
            narrativePerspective: _perspectiveController.text,
          ),
        );

    if (mounted && !ref.read(projectControllerProvider).hasError) {
      Navigator.of(context).pop();
    }
  }
}

class _ProjectDialogForm extends StatelessWidget {
  const _ProjectDialogForm({
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.languageController,
    required this.targetLengthController,
    required this.totalTargetLengthController,
    required this.perspectiveController,
    required this.status,
    required this.providers,
    required this.styleProfiles,
    required this.plotProfiles,
    required this.controllerBusy,
    required this.canSave,
    required this.onStatusChanged,
    required this.onProviderChanged,
    required this.onModelChanged,
    required this.onStyleProfileChanged,
    required this.onPlotProfileChanged,
    required this.onCancel,
    required this.onSave,
    this.selectedProvider,
    this.selectedModelName,
    this.selectedStyleProfileId,
    this.selectedPlotProfileId,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController languageController;
  final TextEditingController targetLengthController;
  final TextEditingController totalTargetLengthController;
  final TextEditingController perspectiveController;
  final ProjectStatus status;
  final List<ProviderConfig> providers;
  final List<StyleProfile> styleProfiles;
  final List<PlotProfile> plotProfiles;
  final ProviderConfig? selectedProvider;
  final String? selectedModelName;
  final String? selectedStyleProfileId;
  final String? selectedPlotProfileId;
  final bool controllerBusy;
  final bool canSave;
  final ValueChanged<ProjectStatus> onStatusChanged;
  final ValueChanged<String> onProviderChanged;
  final ValueChanged<String> onModelChanged;
  final ValueChanged<String?> onStyleProfileChanged;
  final ValueChanged<String?> onPlotProfileChanged;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '项目标题',
                hintText: '例如：雾港纪事',
              ),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: '简介 / 一句话概念',
                hintText: '写下项目的核心设定、主线或创作目标。',
              ),
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            _DialogSection(
              title: '创作配置',
              description: '选择项目默认调用的 Provider、模型和可复用分析档案。',
              children: [
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
                          if (value != null) onProviderChanged(value);
                        },
                  decoration: const InputDecoration(
                    labelText: '默认 Provider',
                    border: OutlineInputBorder(),
                  ),
                  validator: (_) =>
                      providers.isEmpty ? '请先在 Settings 配置 Provider' : null,
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
                          if (value != null) onModelChanged(value);
                        },
                  decoration: const InputDecoration(
                    labelText: '默认模型',
                    border: OutlineInputBorder(),
                  ),
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: selectedStyleProfileId,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('不挂载 Style Profile'),
                    ),
                    for (final profile in styleProfiles)
                      DropdownMenuItem<String?>(
                        value: profile.id,
                        child: Text(
                          profile.styleName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: onStyleProfileChanged,
                  decoration: const InputDecoration(
                    labelText: 'Style Profile（可选）',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: selectedPlotProfileId,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('不挂载 Plot Profile'),
                    ),
                    for (final profile in plotProfiles)
                      DropdownMenuItem<String?>(
                        value: profile.id,
                        child: Text(
                          profile.plotName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: onPlotProfileChanged,
                  decoration: const InputDecoration(
                    labelText: 'Plot Profile（可选）',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (providers.isEmpty) ...[
                  const SizedBox(height: 12),
                  _ProviderMissingNotice(colorScheme: colorScheme),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _DialogSection(
              title: '写作参数',
              description: '作为后续章节生成和编辑器的项目级默认值。',
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final language = TextFormField(
                      controller: languageController,
                      decoration: const InputDecoration(
                        labelText: '语言',
                        border: OutlineInputBorder(),
                      ),
                      validator: _requiredValidator,
                    );
                    final targetLength = TextFormField(
                      controller: targetLengthController,
                      decoration: const InputDecoration(
                        labelText: '单章目标字数',
                        suffixText: '字',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: _positiveIntValidator,
                    );
                    final totalTargetLength = TextFormField(
                      controller: totalTargetLengthController,
                      decoration: const InputDecoration(
                        labelText: '全书目标字数',
                        suffixText: '字',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: _positiveIntValidator,
                    );

                    if (constraints.maxWidth < 620) {
                      return Column(
                        children: [
                          language,
                          const SizedBox(height: 12),
                          targetLength,
                          const SizedBox(height: 12),
                          totalTargetLength,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: language),
                        const SizedBox(width: 12),
                        Expanded(child: targetLength),
                        const SizedBox(width: 12),
                        Expanded(child: totalTargetLength),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: perspectiveController,
                  decoration: const InputDecoration(
                    labelText: '叙事视角',
                    hintText: defaultProjectNarrativePerspective,
                    border: OutlineInputBorder(),
                  ),
                  validator: _requiredValidator,
                ),
              ],
            ),
            const SizedBox(height: 14),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.28,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: RadioGroup<ProjectStatus>(
                groupValue: status,
                onChanged: (value) {
                  if (value != null) {
                    onStatusChanged(value);
                  }
                },
                child: Column(
                  children: const [
                    RadioListTile<ProjectStatus>(
                      title: Text('活动项目'),
                      subtitle: Text('显示在默认 Projects 工作区。'),
                      value: ProjectStatus.active,
                    ),
                    RadioListTile<ProjectStatus>(
                      title: Text('归档项目'),
                      subtitle: Text('从默认工作区隐藏，但保留项目档案。'),
                      value: ProjectStatus.archived,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: controllerBusy ? null : onCancel,
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: canSave ? onSave : null,
                  child: Text(controllerBusy ? '保存中' : '保存'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogSection extends StatelessWidget {
  const _DialogSection({
    required this.title,
    required this.description,
    required this.children,
  });

  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PersonaSectionHeader(title: title, description: description),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ProviderMissingNotice extends StatelessWidget {
  const _ProviderMissingNotice({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '请先在 Settings 配置 Provider，项目需要默认 Provider 和模型才能保存。',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectDialogLoading extends StatelessWidget {
  const _ProjectDialogLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 180,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ProjectDialogLoadError extends StatelessWidget {
  const _ProjectDialogLoadError(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      '无法加载创作配置：$message',
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    );
  }
}

void showProjectDialog(BuildContext context, {WritingProject? project}) {
  showGlassDialog<void>(
    context: context,
    maxWidth: 680,
    maxHeight: MediaQuery.sizeOf(context).height * 0.9,
    builder: (context) => _ProjectDialog(project: project),
  );
}

void _showProjectDialog(BuildContext context, {WritingProject? project}) {
  showProjectDialog(context, project: project);
}

Future<void> _showNovelImportDialog(BuildContext context) async {
  final project = await showGlassDialog<WritingProject>(
    context: context,
    maxWidth: 920,
    builder: (context) => const _NovelImportDialog(),
  );
  if (project != null && context.mounted) {
    context.go('/projects/${project.id}/workshop');
  }
}

Future<void> _confirmDeleteProject(
  BuildContext context,
  WidgetRef ref,
  WritingProject project,
) async {
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
            Text('永久删除项目', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        const SizedBox(height: 12),
        Text('确定删除「${project.title}」吗？该记录会从本地 SQLite 中移除。'),
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

  if (confirmed ?? false) {
    await ref.read(projectControllerProvider.notifier).delete(project.id);
  }
}

enum _ProjectMenuAction { edit, openWorkshop, archive, restore, delete }

class _NovelImportDialog extends ConsumerStatefulWidget {
  const _NovelImportDialog();

  @override
  ConsumerState<_NovelImportDialog> createState() => _NovelImportDialogState();
}

class _NovelImportDialogState extends ConsumerState<_NovelImportDialog> {
  final _titleController = TextEditingController();
  NovelImportDraft? _draft;
  String? _selectedProviderId;
  String? _selectedModelName;
  String? _selectedStyleProfileId;
  bool _parsing = false;
  bool _creating = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() {
      _parsing = true;
      _errorMessage = null;
    });
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['txt', 'epub'],
        allowMultiple: false,
      );
      final path = result?.files.single.path;
      if (path == null) {
        return;
      }
      final draft = await ref.read(novelImportParserProvider).importFile(path);
      setState(() {
        _draft = draft;
        _titleController.text = draft.title;
      });
    } on Object catch (error) {
      setState(() => _errorMessage = '$error');
    } finally {
      if (mounted) {
        setState(() => _parsing = false);
      }
    }
  }

  Future<void> _createProject() async {
    final draft = _draft;
    final providerId = _selectedProviderId;
    final modelName = _selectedModelName;
    if (draft == null || providerId == null || modelName == null) {
      return;
    }
    setState(() {
      _creating = true;
      _errorMessage = null;
    });
    try {
      final project = await ref
          .read(novelImportServiceProvider)
          .createImportedProject(
            draft: NovelImportDraft(
              sourceType: draft.sourceType,
              title: _titleController.text.trim().isEmpty
                  ? draft.title
                  : _titleController.text.trim(),
              sourceFilename: draft.sourceFilename,
              chapters: draft.chapters,
              warnings: draft.warnings,
            ),
            defaultProviderId: providerId,
            defaultModelName: modelName,
            styleProfileId: _selectedStyleProfileId,
          );
      if (mounted) {
        Navigator.of(context).pop(project);
      }
    } on Object catch (error) {
      setState(() => _errorMessage = '$error');
    } finally {
      if (mounted) {
        setState(() => _creating = false);
      }
    }
  }

  void _updateChapterTitle(int index, String title) {
    final draft = _draft;
    if (draft == null) return;
    final chapters = [...draft.chapters];
    chapters[index] = chapters[index].copyWith(title: title);
    _replaceDraft(draft, chapters);
  }

  void _deleteChapter(int index) {
    final draft = _draft;
    if (draft == null) return;
    final chapters = [...draft.chapters]..removeAt(index);
    _replaceDraft(draft, chapters);
  }

  void _mergeWithNext(int index) {
    final draft = _draft;
    if (draft == null || index + 1 >= draft.chapters.length) return;
    final chapters = [...draft.chapters];
    final current = chapters[index];
    final next = chapters[index + 1];
    chapters[index] = current.copyWith(
      contentMarkdown:
          '${current.contentMarkdown.trim()}\n\n${next.contentMarkdown.trim()}',
    );
    chapters.removeAt(index + 1);
    _replaceDraft(draft, chapters);
  }

  void _replaceDraft(
    NovelImportDraft draft,
    List<NovelImportChapterDraft> chapters,
  ) {
    setState(() {
      _draft = NovelImportDraft(
        sourceType: draft.sourceType,
        title: draft.title,
        sourceFilename: draft.sourceFilename,
        chapters: chapters,
        warnings: draft.warnings,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final providers = ref.watch(providerConfigsProvider);
    final styleProfiles = ref.watch(styleProfilesProvider);
    final draft = _draft;
    final busy = _parsing || _creating;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return providers.when(
      data: (providerItems) => styleProfiles.when(
        data: (styleItems) {
          if (_selectedProviderId == null && providerItems.isNotEmpty) {
            final enabled = providerItems.where((item) => item.isEnabled);
            final provider = enabled.isEmpty
                ? providerItems.first
                : enabled.first;
            _selectedProviderId = provider.id;
            _selectedModelName = provider.defaultModel;
          }
          final selectedProvider = _findById(
            providerItems,
            _selectedProviderId,
            (item) => item.id,
          );
          final modelNames = selectedProvider?.modelNames ?? const <String>[];
          if (selectedProvider != null &&
              (_selectedModelName == null ||
                  !modelNames.contains(_selectedModelName))) {
            _selectedModelName = selectedProvider.defaultModel;
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- Title with icon --
              Row(
                children: [
                  Icon(Icons.import_export_outlined, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '导入小说加料项目',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '选择 TXT / EPUB 后确认章节切分，再创建只用于整章加料的导入型项目。',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              // -- File selection area --
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(kPanelRadius),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: busy ? null : _pickFile,
                        icon: const Icon(Icons.upload_file_outlined),
                        label: Text(_parsing ? '解析中...' : '选择文件'),
                      ),
                      const SizedBox(width: 12),
                      if (draft != null)
                        Expanded(
                          child: Text(
                            '${draft.sourceFilename} · ${draft.chapters.length} 章 · ${draft.totalCharacterCount} 字',
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium,
                          ),
                        )
                      else
                        Expanded(
                          child: Text(
                            '支持 .txt 和 .epub 格式',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // -- Error message --
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                InlineError(message: _errorMessage!),
              ],

              // -- Settings section --
              if (draft != null) ...[
                const SizedBox(height: 20),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(kPanelRadius),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '基本设置',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: '项目标题',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedProviderId,
                                decoration: const InputDecoration(
                                  labelText: '默认 Provider',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  for (final provider in providerItems)
                                    DropdownMenuItem(
                                      value: provider.id,
                                      child: Text(provider.name),
                                    ),
                                ],
                                onChanged: busy
                                    ? null
                                    : (id) {
                                        if (id == null) return;
                                        final provider = _findById(
                                          providerItems,
                                          id,
                                          (item) => item.id,
                                        );
                                        setState(() {
                                          _selectedProviderId = id;
                                          _selectedModelName =
                                              provider?.defaultModel;
                                        });
                                      },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedModelName,
                                decoration: const InputDecoration(
                                  labelText: '默认模型',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  for (final modelName in modelNames)
                                    DropdownMenuItem(
                                      value: modelName,
                                      child: Text(modelName),
                                    ),
                                ],
                                onChanged: busy
                                    ? null
                                    : (modelName) => setState(
                                        () => _selectedModelName = modelName,
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String?>(
                          initialValue: _selectedStyleProfileId,
                          decoration: const InputDecoration(
                            labelText: 'Voice Profile（可选）',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('不绑定'),
                            ),
                            for (final profile in styleItems)
                              DropdownMenuItem<String?>(
                                value: profile.id,
                                child: Text(profile.styleName),
                              ),
                          ],
                          onChanged: busy
                              ? null
                              : (id) =>
                                    setState(() => _selectedStyleProfileId = id),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // -- Chapter preview section --
              if (draft != null) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      '章节列表',
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(width: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        child: Text(
                          '${draft.chapters.length}',
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: _ImportChapterPreviewList(
                    chapters: draft.chapters,
                    onTitleChanged: _updateChapterTitle,
                    onDelete: _deleteChapter,
                    onMergeWithNext: _mergeWithNext,
                  ),
                ),
              ],

              // -- Action row --
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: busy ? null : () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed:
                        draft == null ||
                            draft.chapters.isEmpty ||
                            _selectedProviderId == null ||
                            _selectedModelName == null ||
                            busy
                        ? null
                        : _createProject,
                    icon: const Icon(Icons.check_outlined, size: 18),
                    label: Text(_creating ? '创建中...' : '创建项目'),
                  ),
                ],
              ),
            ],
          );
        },
        error: (error, stackTrace) => InlineError(
          message: '无法加载 Style Profiles：$error',
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => InlineError(
        message: '无法加载 Providers：$error',
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ImportChapterPreviewList extends StatefulWidget {
  const _ImportChapterPreviewList({
    required this.chapters,
    required this.onTitleChanged,
    required this.onDelete,
    required this.onMergeWithNext,
  });

  final List<NovelImportChapterDraft> chapters;
  final void Function(int index, String title) onTitleChanged;
  final ValueChanged<int> onDelete;
  final ValueChanged<int> onMergeWithNext;

  @override
  State<_ImportChapterPreviewList> createState() =>
      _ImportChapterPreviewListState();
}

class _ImportChapterPreviewListState extends State<_ImportChapterPreviewList> {
  int _hoveredIndex = -1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(kPanelRadius),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: widget.chapters.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        itemBuilder: (context, index) {
          final chapter = widget.chapters[index];
          final isHovered = _hoveredIndex == index;
          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = -1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              color: isHovered
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                  : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Chapter number badge
                  Container(
                    width: 36,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Chapter title input
                  Expanded(
                    child: TextFormField(
                      key: ValueKey(chapter.id),
                      initialValue: chapter.title,
                      style: textTheme.bodyLarge,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        hintText: '章节标题',
                        suffixText: '${chapter.characterCount} 字',
                        suffixStyle: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (value) =>
                          widget.onTitleChanged(index, value),
                    ),
                  ),
                  // Action buttons — fade in on hover
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: isHovered ? 1.0 : 0.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 4),
                        IconButton(
                          tooltip: '合并下一章',
                          iconSize: 18,
                          visualDensity: VisualDensity.compact,
                          onPressed: index + 1 >= widget.chapters.length
                              ? null
                              : () => widget.onMergeWithNext(index),
                          icon: const Icon(Icons.call_merge_outlined),
                        ),
                        IconButton(
                          tooltip: '删除章节',
                          iconSize: 18,
                          visualDensity: VisualDensity.compact,
                          onPressed: widget.chapters.length <= 1
                              ? null
                              : () => widget.onDelete(index),
                          icon: Icon(
                            Icons.delete_outline,
                            color: colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

String? _requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return '必填';
  }
  return null;
}

String? _positiveIntValidator(String? value) {
  final parsed = int.tryParse(value?.trim() ?? '');
  if (parsed == null || parsed <= 0) {
    return '请输入大于 0 的整数';
  }
  return null;
}

T? _findById<T>(List<T> items, String? id, String Function(T item) getId) {
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

String _statusLabel(ProjectStatus status) {
  return switch (status) {
    ProjectStatus.active => '活动',
    ProjectStatus.archived => '归档',
  };
}

String _formatProjectTime(DateTime value) {
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');

  return '$month-$day $hour:$minute';
}
