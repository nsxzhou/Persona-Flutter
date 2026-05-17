import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/persona_page.dart';
import '../../plot_lab/application/plot_lab_providers.dart';
import '../../plot_lab/domain/plot_profile.dart';
import '../../projects/application/project_providers.dart';
import '../../projects/domain/writing_project.dart';
import '../../settings/application/provider_config_providers.dart';
import '../../settings/domain/provider_config.dart';
import '../../style_lab/application/style_lab_providers.dart';
import '../../style_lab/domain/style_profile.dart';
import '../application/novel_workshop_providers.dart';
import '../domain/chapter_plan.dart';

class NovelWorkshopPage extends ConsumerStatefulWidget {
  const NovelWorkshopPage({required this.projectId, super.key});

  final String projectId;

  @override
  ConsumerState<NovelWorkshopPage> createState() => _NovelWorkshopPageState();
}

class _NovelWorkshopPageState extends ConsumerState<NovelWorkshopPage> {
  String? _selectedPlanId;

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(writingProjectProvider(widget.projectId));
    final plans = ref.watch(chapterPlansProvider(widget.projectId));
    final acceptedChapters = ref.watch(
      acceptedChaptersProvider(widget.projectId),
    );
    final storyBible = ref.watch(storyBibleProvider(widget.projectId));
    final memoryProjection = ref.watch(
      memoryProjectionProvider(widget.projectId),
    );
    final providers = ref.watch(providerConfigsProvider);
    final styleProfiles = ref.watch(styleProfilesProvider);
    final plotProfiles = ref.watch(plotProfilesProvider);
    final controller = ref.watch(novelWorkshopControllerProvider);

    return project.when(
      data: (item) {
        if (item == null) {
          return PersonaPage(
            eyebrow: '章节工作台',
            title: '项目不存在',
            description: '这个写作项目可能已被删除，无法打开章节工作台。',
            actions: [
              OutlinedButton.icon(
                onPressed: () => context.go('/projects'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('返回项目'),
              ),
            ],
            children: const [PersonaPanel(child: Text('没有找到对应的项目记录。'))],
          );
        }

        return PersonaPage(
          eyebrow: '章节工作台',
          title: item.title,
          description: '逐章规划、审查生成依据，并在后续阶段接入章节契约、正文草稿和记忆投影。',
          maxWidth: 1480,
          actions: [
            OutlinedButton.icon(
              onPressed: () => context.go('/projects/${item.id}'),
              icon: const Icon(Icons.arrow_back),
              label: const Text('项目控制台'),
            ),
            FilledButton.icon(
              onPressed: controller.isLoading
                  ? null
                  : () =>
                        _showChapterPlanDialog(context: context, project: item),
              icon: const Icon(Icons.add),
              label: const Text('新建章节'),
            ),
          ],
          children: [
            controller.when(
              data: (_) => const SizedBox.shrink(),
              loading: () => const LinearProgressIndicator(minHeight: 2),
              error: (error, stackTrace) => _InlineError(message: '$error'),
            ),
            plans.when(
              data: (planItems) {
                final selectedPlan = _resolveSelectedPlan(planItems);
                return _WorkshopLayout(
                  project: item,
                  plans: planItems,
                  selectedPlan: selectedPlan,
                  acceptedCount: _acceptedCount(acceptedChapters),
                  providerLabel: _providerLabel(providers, item),
                  styleProfileLabel: _styleProfileLabel(styleProfiles, item),
                  plotProfileLabel: _plotProfileLabel(plotProfiles, item),
                  storyBibleState: _storyBibleState(storyBible),
                  memoryProjectionState: _memoryProjectionState(
                    memoryProjection,
                  ),
                  onCreatePlan: () =>
                      _showChapterPlanDialog(context: context, project: item),
                  onSelectPlan: (plan) =>
                      setState(() => _selectedPlanId = plan.id),
                  onEditPlan: (plan) => _showChapterPlanDialog(
                    context: context,
                    project: item,
                    existing: plan,
                  ),
                  onDeletePlan: _deleteChapterPlan,
                );
              },
              loading: () => const PersonaPanel(
                child: SizedBox(
                  height: 320,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stackTrace) => _InlineError(message: '$error'),
            ),
          ],
        );
      },
      loading: () => const PersonaPage(
        eyebrow: '章节工作台',
        title: '加载中',
        description: '正在读取项目和章节计划。',
        children: [PersonaPanel(child: LinearProgressIndicator())],
      ),
      error: (error, stackTrace) => PersonaPage(
        eyebrow: '章节工作台',
        title: '加载失败',
        description: '无法读取章节工作台。',
        children: [_InlineError(message: '$error')],
      ),
    );
  }

  ChapterPlan? _resolveSelectedPlan(List<ChapterPlan> plans) {
    if (plans.isEmpty) {
      _selectedPlanId = null;
      return null;
    }
    final selectedId = _selectedPlanId;
    if (selectedId != null) {
      for (final plan in plans) {
        if (plan.id == selectedId) {
          return plan;
        }
      }
    }
    final first = plans.first;
    _selectedPlanId = first.id;
    return first;
  }

  Future<void> _showChapterPlanDialog({
    required BuildContext context,
    required WritingProject project,
    ChapterPlan? existing,
  }) async {
    final saved = await showDialog<ChapterPlan>(
      context: context,
      builder: (context) =>
          _ChapterPlanDialog(project: project, existing: existing),
    );
    if (!mounted || saved == null) {
      return;
    }
    setState(() => _selectedPlanId = saved.id);
    _showSnack(existing == null ? '章节计划已创建。' : '章节计划已更新。');
  }

  Future<void> _deleteChapterPlan(ChapterPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除章节计划'),
        content: Text(
          '确定删除「第 ${plan.chapterIndex} 章 · ${plan.title}」吗？后续该操作会同步删除该章草稿运行、正式稿和 Prompt Trace。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) {
      return;
    }

    try {
      await ref
          .read(novelWorkshopControllerProvider.notifier)
          .deleteChapterPlan(plan.id);
      if (_selectedPlanId == plan.id) {
        setState(() => _selectedPlanId = null);
      }
      _showSnack('章节计划已删除。');
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

class _WorkshopLayout extends StatelessWidget {
  const _WorkshopLayout({
    required this.project,
    required this.plans,
    required this.selectedPlan,
    required this.acceptedCount,
    required this.providerLabel,
    required this.styleProfileLabel,
    required this.plotProfileLabel,
    required this.storyBibleState,
    required this.memoryProjectionState,
    required this.onCreatePlan,
    required this.onSelectPlan,
    required this.onEditPlan,
    required this.onDeletePlan,
  });

  final WritingProject project;
  final List<ChapterPlan> plans;
  final ChapterPlan? selectedPlan;
  final int acceptedCount;
  final String providerLabel;
  final String styleProfileLabel;
  final String plotProfileLabel;
  final String storyBibleState;
  final String memoryProjectionState;
  final VoidCallback onCreatePlan;
  final ValueChanged<ChapterPlan> onSelectPlan;
  final ValueChanged<ChapterPlan> onEditPlan;
  final ValueChanged<ChapterPlan> onDeletePlan;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1040) {
          return Column(
            children: [
              SizedBox(
                height: 520,
                child: _ChapterListPanel(
                  plans: plans,
                  selectedPlan: selectedPlan,
                  onCreatePlan: onCreatePlan,
                  onSelectPlan: onSelectPlan,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 620,
                child: _ChapterPlanDetailPanel(
                  plan: selectedPlan,
                  onCreatePlan: onCreatePlan,
                  onEditPlan: onEditPlan,
                  onDeletePlan: onDeletePlan,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 560,
                child: _WorkshopContextPanel(
                  project: project,
                  planCount: plans.length,
                  acceptedCount: acceptedCount,
                  providerLabel: providerLabel,
                  styleProfileLabel: styleProfileLabel,
                  plotProfileLabel: plotProfileLabel,
                  storyBibleState: storyBibleState,
                  memoryProjectionState: memoryProjectionState,
                ),
              ),
            ],
          );
        }

        return SizedBox(
          height: 720,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 320,
                child: _ChapterListPanel(
                  plans: plans,
                  selectedPlan: selectedPlan,
                  onCreatePlan: onCreatePlan,
                  onSelectPlan: onSelectPlan,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ChapterPlanDetailPanel(
                  plan: selectedPlan,
                  onCreatePlan: onCreatePlan,
                  onEditPlan: onEditPlan,
                  onDeletePlan: onDeletePlan,
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 310,
                child: _WorkshopContextPanel(
                  project: project,
                  planCount: plans.length,
                  acceptedCount: acceptedCount,
                  providerLabel: providerLabel,
                  styleProfileLabel: styleProfileLabel,
                  plotProfileLabel: plotProfileLabel,
                  storyBibleState: storyBibleState,
                  memoryProjectionState: memoryProjectionState,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChapterListPanel extends StatelessWidget {
  const _ChapterListPanel({
    required this.plans,
    required this.selectedPlan,
    required this.onCreatePlan,
    required this.onSelectPlan,
  });

  final List<ChapterPlan> plans;
  final ChapterPlan? selectedPlan;
  final VoidCallback onCreatePlan;
  final ValueChanged<ChapterPlan> onSelectPlan;

  @override
  Widget build(BuildContext context) {
    return PersonaPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PersonaSectionHeader(
            title: '章节板',
            description: '${plans.length} 个章节计划',
            trailing: IconButton.filledTonal(
              tooltip: '新建章节',
              onPressed: onCreatePlan,
              icon: const Icon(Icons.add),
            ),
          ),
          const SizedBox(height: 14),
          if (plans.isEmpty)
            Expanded(
              child: Center(
                child: PersonaEmptyStateCard(
                  icon: Icons.view_list_outlined,
                  title: '还没有章节计划',
                  description: '先创建第 1 章，定义目标、拍点和章末钩子。',
                  action: FilledButton.icon(
                    onPressed: onCreatePlan,
                    icon: const Icon(Icons.add),
                    label: const Text('创建第 1 章'),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: plans.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return _ChapterPlanRow(
                    plan: plan,
                    selected: selectedPlan?.id == plan.id,
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

class _ChapterPlanRow extends StatelessWidget {
  const _ChapterPlanRow({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final ChapterPlan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kButtonRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.09)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
            borderRadius: BorderRadius.circular(kButtonRadius),
            border: Border.all(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'CH ${plan.chapterIndex.toString().padLeft(2, '0')}',
                    style: textTheme.labelMedium?.copyWith(
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  _ChapterStatusPill(status: plan.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(plan.title, style: textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                _compactPlanSummary(plan),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChapterPlanDetailPanel extends StatelessWidget {
  const _ChapterPlanDetailPanel({
    required this.plan,
    required this.onCreatePlan,
    required this.onEditPlan,
    required this.onDeletePlan,
  });

  final ChapterPlan? plan;
  final VoidCallback onCreatePlan;
  final ValueChanged<ChapterPlan> onEditPlan;
  final ValueChanged<ChapterPlan> onDeletePlan;

  @override
  Widget build(BuildContext context) {
    final item = plan;
    return PersonaPanel(
      padding: const EdgeInsets.all(20),
      child: item == null
          ? Center(
              child: PersonaEmptyStateCard(
                icon: Icons.edit_note_outlined,
                title: '选择或创建章节',
                description: '章节计划会显示目标、拍点、限制和后续生成阶段占位。',
                action: FilledButton.icon(
                  onPressed: onCreatePlan,
                  icon: const Icon(Icons.add),
                  label: const Text('新建章节'),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PersonaSectionHeader(
                  title: '第 ${item.chapterIndex} 章 · ${item.title}',
                  description: '章节计划是后续生成章节契约和正文草稿的执行依据。',
                  trailing: _ChapterStatusPill(status: item.status),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => onEditPlan(item),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('编辑计划'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => onDeletePlan(item),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('删除'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView(
                    children: [
                      _PlanSection(label: '本章目标', value: item.goal),
                      _PlanSection(label: '核心剧情拍点', value: item.targetBeat),
                      _PlanSection(label: '必须包含', value: item.mustInclude),
                      _PlanSection(label: '必须避免', value: item.mustAvoid),
                      _PlanSection(label: '章末钩子', value: item.hook),
                      _PlanSection(label: '伏笔回收', value: item.payoff),
                      const SizedBox(height: 6),
                      _PipelinePlaceholder(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _PlanSection extends StatelessWidget {
  const _PlanSection({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final normalized = value.trim().isEmpty ? '未填写。' : value.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.24),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: textTheme.labelMedium),
              const SizedBox(height: 8),
              Text(normalized, style: textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _PipelinePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('后续生成阶段'),
            SizedBox(height: 10),
            _PipelineStep(label: 'Chapter Contract', state: '待接入'),
            _PipelineStep(label: 'Draft', state: '待接入'),
            _PipelineStep(label: 'Audit', state: '待接入'),
            _PipelineStep(label: 'Revise / Accept', state: '待接入'),
          ],
        ),
      ),
    );
  }
}

class _PipelineStep extends StatelessWidget {
  const _PipelineStep({required this.label, required this.state});

  final String label;
  final String state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(
            Icons.radio_button_unchecked,
            size: 16,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          PersonaStatusPill(label: state, icon: Icons.schedule_outlined),
        ],
      ),
    );
  }
}

class _WorkshopContextPanel extends StatelessWidget {
  const _WorkshopContextPanel({
    required this.project,
    required this.planCount,
    required this.acceptedCount,
    required this.providerLabel,
    required this.styleProfileLabel,
    required this.plotProfileLabel,
    required this.storyBibleState,
    required this.memoryProjectionState,
  });

  final WritingProject project;
  final int planCount;
  final int acceptedCount;
  final String providerLabel;
  final String styleProfileLabel;
  final String plotProfileLabel;
  final String storyBibleState;
  final String memoryProjectionState;

  @override
  Widget build(BuildContext context) {
    return PersonaPanel(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const PersonaSectionHeader(
            title: '上下文',
            description: '当前章节生成会依赖的项目资产状态。',
          ),
          const SizedBox(height: 14),
          _ContextLine(label: '章节计划', value: '$planCount 个计划'),
          _ContextLine(label: '正式章节', value: '$acceptedCount 个已确认'),
          _ContextLine(label: 'Provider / Model', value: providerLabel),
          _ContextLine(label: 'Style Profile', value: styleProfileLabel),
          _ContextLine(label: 'Plot Profile', value: plotProfileLabel),
          _ContextLine(label: 'Story Bible', value: storyBibleState),
          _ContextLine(
            label: 'Memory Projection',
            value: memoryProjectionState,
          ),
          const SizedBox(height: 14),
          const PersonaSectionHeader(
            title: '质量检查',
            description: '后续接入草稿审查后，这里显示风格、剧情、设定和伏笔问题。',
          ),
          const SizedBox(height: 14),
          _ContextLine(label: '目标语言', value: project.language),
          _ContextLine(label: '目标长度', value: '${project.targetLength} 字'),
          _ContextLine(label: '叙事视角', value: project.narrativePerspective),
        ],
      ),
    );
  }
}

class _ContextLine extends StatelessWidget {
  const _ContextLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: textTheme.labelMedium),
          const SizedBox(height: 5),
          Text(value, style: textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _ChapterPlanDialog extends ConsumerStatefulWidget {
  const _ChapterPlanDialog({required this.project, this.existing});

  final WritingProject project;
  final ChapterPlan? existing;

  @override
  ConsumerState<_ChapterPlanDialog> createState() => _ChapterPlanDialogState();
}

class _ChapterPlanDialogState extends ConsumerState<_ChapterPlanDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _chapterIndexController;
  late final TextEditingController _titleController;
  late final TextEditingController _goalController;
  late final TextEditingController _targetBeatController;
  late final TextEditingController _mustIncludeController;
  late final TextEditingController _mustAvoidController;
  late final TextEditingController _hookController;
  late final TextEditingController _payoffController;
  late ChapterPlanStatus _status;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _chapterIndexController = TextEditingController(
      text: (existing?.chapterIndex ?? 1).toString(),
    );
    _titleController = TextEditingController(text: existing?.title ?? '第一章');
    _goalController = TextEditingController(text: existing?.goal ?? '');
    _targetBeatController = TextEditingController(
      text: existing?.targetBeat ?? '',
    );
    _mustIncludeController = TextEditingController(
      text: existing?.mustInclude ?? '',
    );
    _mustAvoidController = TextEditingController(
      text: existing?.mustAvoid ?? '',
    );
    _hookController = TextEditingController(text: existing?.hook ?? '');
    _payoffController = TextEditingController(text: existing?.payoff ?? '');
    _status = existing?.status ?? ChapterPlanStatus.planned;
  }

  @override
  void dispose() {
    _chapterIndexController.dispose();
    _titleController.dispose();
    _goalController.dispose();
    _targetBeatController.dispose();
    _mustIncludeController.dispose();
    _mustAvoidController.dispose();
    _hookController.dispose();
    _payoffController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(novelWorkshopControllerProvider);
    return AlertDialog(
      title: Text(widget.existing == null ? '新建章节计划' : '编辑章节计划'),
      content: SizedBox(
        width: 680,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _chapterIndexController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '章节序号'),
                        validator: (value) {
                          final parsed = int.tryParse(value?.trim() ?? '');
                          if (parsed == null || parsed <= 0) {
                            return '请输入大于 0 的章节序号';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: '标题'),
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return '请输入章节标题';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ChapterPlanStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: '状态'),
                  items: ChapterPlanStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(_chapterStatusLabel(status)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _status = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                _DialogTextField(controller: _goalController, label: '本章目标'),
                _DialogTextField(
                  controller: _targetBeatController,
                  label: '核心剧情拍点',
                ),
                _DialogTextField(
                  controller: _mustIncludeController,
                  label: '必须包含',
                ),
                _DialogTextField(
                  controller: _mustAvoidController,
                  label: '必须避免',
                ),
                _DialogTextField(controller: _hookController, label: '章末钩子'),
                _DialogTextField(controller: _payoffController, label: '伏笔回收'),
                controller.when(
                  data: (_) => const SizedBox.shrink(),
                  loading: () => const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
                  error: (error, stackTrace) => Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _InlineError(message: '$error'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: controller.isLoading
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: controller.isLoading ? null : _save,
          child: const Text('保存'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final input = ChapterPlanInput(
      projectId: widget.project.id,
      chapterIndex: int.parse(_chapterIndexController.text.trim()),
      title: _titleController.text.trim(),
      goal: _goalController.text.trim(),
      targetBeat: _targetBeatController.text.trim(),
      mustInclude: _mustIncludeController.text.trim(),
      mustAvoid: _mustAvoidController.text.trim(),
      hook: _hookController.text.trim(),
      payoff: _payoffController.text.trim(),
      status: _status,
    );
    try {
      final saved = await ref
          .read(novelWorkshopControllerProvider.notifier)
          .saveChapterPlan(id: widget.existing?.id, input: input);
      if (!mounted) return;
      Navigator.of(context).pop(saved);
    } on Object {
      // The controller exposes the error in the dialog.
    }
  }
}

class _DialogTextField extends StatelessWidget {
  const _DialogTextField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        minLines: 2,
        maxLines: 4,
      ),
    );
  }
}

class _ChapterStatusPill extends StatelessWidget {
  const _ChapterStatusPill({required this.status});

  final ChapterPlanStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = switch (status) {
      ChapterPlanStatus.planned => colorScheme.primary,
      ChapterPlanStatus.drafting => Colors.orange,
      ChapterPlanStatus.reviewed => Colors.teal,
      ChapterPlanStatus.accepted => Colors.green,
    };
    return PersonaStatusPill(
      label: _chapterStatusLabel(status),
      icon: switch (status) {
        ChapterPlanStatus.planned => Icons.event_note_outlined,
        ChapterPlanStatus.drafting => Icons.auto_awesome_outlined,
        ChapterPlanStatus.reviewed => Icons.fact_check_outlined,
        ChapterPlanStatus.accepted => Icons.check_circle_outline,
      },
      color: color,
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PersonaPanel(
      backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.35),
      child: Text(
        message,
        style: TextStyle(color: colorScheme.onErrorContainer),
      ),
    );
  }
}

int _acceptedCount(AsyncValue<List<dynamic>> value) {
  return value.maybeWhen(data: (items) => items.length, orElse: () => 0);
}

String _providerLabel(
  AsyncValue<List<ProviderConfig>> providers,
  WritingProject project,
) {
  final providerId = project.defaultProviderId;
  final modelName = project.defaultModelName;
  if (providerId == null || providerId.trim().isEmpty) {
    return '待补齐默认 Provider';
  }
  if (modelName == null || modelName.trim().isEmpty) {
    return '待补齐默认模型';
  }
  return providers.when(
    data: (items) {
      for (final provider in items) {
        if (provider.id == providerId) {
          return '${provider.name} · $modelName';
        }
      }
      return 'Provider 已失效 · $modelName';
    },
    loading: () => '正在读取 Provider',
    error: (error, stackTrace) => 'Provider 状态读取失败',
  );
}

String _styleProfileLabel(
  AsyncValue<List<StyleProfile>> profiles,
  WritingProject project,
) {
  final profileId = project.styleProfileId;
  if (profileId == null || profileId.trim().isEmpty) {
    return '未挂载 Style Profile';
  }
  return profiles.when(
    data: (items) {
      for (final profile in items) {
        if (profile.id == profileId) return profile.styleName;
      }
      return 'Style Profile 已失效';
    },
    loading: () => '正在读取 Style Profile',
    error: (error, stackTrace) => 'Style Profile 状态读取失败',
  );
}

String _plotProfileLabel(
  AsyncValue<List<PlotProfile>> profiles,
  WritingProject project,
) {
  final profileId = project.plotProfileId;
  if (profileId == null || profileId.trim().isEmpty) {
    return '未挂载 Plot Profile';
  }
  return profiles.when(
    data: (items) {
      for (final profile in items) {
        if (profile.id == profileId) return profile.plotName;
      }
      return 'Plot Profile 已失效';
    },
    loading: () => '正在读取 Plot Profile',
    error: (error, stackTrace) => 'Plot Profile 状态读取失败',
  );
}

String _storyBibleState(AsyncValue<dynamic> value) {
  return value.maybeWhen(
    data: (item) => item == null ? '未建立' : '已建立',
    orElse: () => '读取中',
  );
}

String _memoryProjectionState(AsyncValue<dynamic> value) {
  return value.maybeWhen(
    data: (item) => item == null ? '未生成' : '已生成',
    orElse: () => '读取中',
  );
}

String _compactPlanSummary(ChapterPlan plan) {
  final parts = [
    plan.goal.trim(),
    plan.targetBeat.trim(),
  ].where((value) => value.isNotEmpty).toList(growable: false);
  return parts.isEmpty ? '未填写本章目标。' : parts.join(' / ');
}

String _chapterStatusLabel(ChapterPlanStatus status) {
  return switch (status) {
    ChapterPlanStatus.planned => '已规划',
    ChapterPlanStatus.drafting => '生成中',
    ChapterPlanStatus.reviewed => '已审查',
    ChapterPlanStatus.accepted => '已确认',
  };
}
