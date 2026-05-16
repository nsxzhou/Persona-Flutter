import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/glass_container.dart';
import '../../../core/ui/persona_page.dart';
import '../../../core/ui/skeleton_loader.dart';
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
      description: '用于长篇项目、蓝图、章节工作和后续 Zen Editor 写作会话的本地写作工作台。',
      actions: [
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
                  ? '进入项目详情，维护项目简介，并为后续章节工作台保留入口。'
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
                      : '创建第一个本地写作档案后，可以进入项目详情维护简介和后续工作台入口。',
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

class _ProjectRow extends ConsumerWidget {
  const _ProjectRow({required this.project});

  final WritingProject project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => context.go('/projects/${project.id}'),
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
  late ProjectStatus _status;

  @override
  void initState() {
    super.initState();
    final project = widget.project;
    _titleController = TextEditingController(text: project?.title ?? '');
    _descriptionController = TextEditingController(
      text: project?.description ?? '',
    );
    _status = project?.status ?? ProjectStatus.active;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(projectControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败：${next.error}')));
      }
    });

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
          '项目档案只保存最小身份信息，章节、正文和分析挂载将在后续工作台接入。',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '项目标题',
                  hintText: '例如：雾港纪事',
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '简介 / 一句话概念',
                  hintText: '写下项目的核心设定、主线或创作目标。',
                ),
                minLines: 3,
                maxLines: 5,
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
                  groupValue: _status,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _status = value);
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
            ],
          ),
        ),
        const SizedBox(height: 18),
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
              child: Text(state.isLoading ? '保存中' : '保存'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
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
          ),
        );

    if (mounted && !ref.read(projectControllerProvider).hasError) {
      Navigator.of(context).pop();
    }
  }
}

void _showProjectDialog(BuildContext context, {WritingProject? project}) {
  showGlassDialog<void>(
    context: context,
    maxWidth: 620,
    builder: (context) => _ProjectDialog(project: project),
  );
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

enum _ProjectMenuAction { edit, archive, restore, delete }

String? _requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return '必填';
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
