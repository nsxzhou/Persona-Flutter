import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/persona_page.dart';
import '../../novel_workshop/application/novel_workshop_providers.dart';
import '../../plot_lab/application/plot_lab_providers.dart';
import '../../plot_lab/domain/plot_profile.dart';
import '../../settings/application/provider_config_providers.dart';
import '../../settings/domain/provider_config.dart';
import '../../style_lab/application/style_lab_providers.dart';
import '../../style_lab/domain/style_profile.dart';
import '../application/project_providers.dart';
import '../domain/writing_project.dart';

class ProjectDetailPage extends ConsumerWidget {
  const ProjectDetailPage({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(writingProjectProvider(projectId));

    return project.when(
      data: (item) {
        if (item == null) {
          return PersonaPage(
            eyebrow: '项目档案',
            title: '项目不存在',
            description: '该项目可能已被永久删除，返回 Projects 查看当前本地档案。',
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

        return _ProjectDetailContent(project: item);
      },
      loading: () => PersonaPage(
        eyebrow: '项目档案',
        title: '加载中',
        description: '正在读取本地项目档案。',
        children: const [PersonaPanel(child: LinearProgressIndicator())],
      ),
      error: (error, stackTrace) => PersonaPage(
        eyebrow: '项目档案',
        title: '加载失败',
        description: '无法读取项目档案。',
        actions: [
          OutlinedButton.icon(
            onPressed: () => context.go('/projects'),
            icon: const Icon(Icons.arrow_back),
            label: const Text('返回项目'),
          ),
        ],
        children: [
          PersonaPanel(
            child: Text(
              '$error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectDetailContent extends ConsumerWidget {
  const _ProjectDetailContent({required this.project});

  final WritingProject project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = ref.watch(providerConfigsProvider);
    final styleProfiles = ref.watch(styleProfilesProvider);
    final plotProfiles = ref.watch(plotProfilesProvider);
    final chapterPlans = ref.watch(chapterPlansProvider(project.id));
    final acceptedChapters = ref.watch(acceptedChaptersProvider(project.id));
    final storyBible = ref.watch(storyBibleProvider(project.id));
    final memoryProjection = ref.watch(memoryProjectionProvider(project.id));

    return PersonaPage(
      eyebrow: '项目控制台',
      title: project.title,
      description: project.description.trim().isEmpty
          ? '这个项目还没有简介。'
          : project.description,
      actions: [
        FilledButton.icon(
          onPressed: () => context.go('/projects/${project.id}/workshop'),
          icon: const Icon(Icons.dashboard_customize_outlined),
          label: const Text('进入章节工作台'),
        ),
        OutlinedButton.icon(
          onPressed: () => context.go('/projects'),
          icon: const Icon(Icons.arrow_back),
          label: const Text('返回项目'),
        ),
      ],
      children: [
        _ProjectConsoleSummary(
          project: project,
          chapterPlanCount: _asyncCount(chapterPlans),
          acceptedChapterCount: _asyncCount(acceptedChapters),
          storyBibleState: _documentState(
            storyBible,
            empty: '未建立',
            ready: '已建立',
          ),
          memoryProjectionState: _documentState(
            memoryProjection,
            empty: '未生成',
            ready: '已生成',
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final dossier = _ProjectDossier(
              project: project,
              providerLabel: _providerLabel(providers, project),
              styleProfileLabel: _styleProfileLabel(styleProfiles, project),
              plotProfileLabel: _plotProfileLabel(plotProfiles, project),
            );
            final commandPanel = _ProjectCommandPanel(
              project: project,
              providerLabel: _providerLabel(providers, project),
              styleProfileLabel: _styleProfileLabel(styleProfiles, project),
              plotProfileLabel: _plotProfileLabel(plotProfiles, project),
              chapterPlanCount: _asyncCount(chapterPlans),
              acceptedChapterCount: _asyncCount(acceptedChapters),
              storyBibleState: _documentState(
                storyBible,
                empty: '未建立',
                ready: '已建立',
              ),
              memoryProjectionState: _documentState(
                memoryProjection,
                empty: '未生成',
                ready: '已生成',
              ),
            );

            if (constraints.maxWidth < 900) {
              return Column(
                children: [dossier, const SizedBox(height: 18), commandPanel],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: dossier),
                const SizedBox(width: 18),
                Expanded(flex: 5, child: commandPanel),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ProjectConsoleSummary extends StatelessWidget {
  const _ProjectConsoleSummary({
    required this.project,
    required this.chapterPlanCount,
    required this.acceptedChapterCount,
    required this.storyBibleState,
    required this.memoryProjectionState,
  });

  final WritingProject project;
  final String chapterPlanCount;
  final String acceptedChapterCount;
  final String storyBibleState;
  final String memoryProjectionState;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = [
          _ConsoleMetricData(
            label: '章节计划',
            value: chapterPlanCount,
            detail: 'Chapter Board',
            icon: Icons.view_list_outlined,
          ),
          _ConsoleMetricData(
            label: '正式章节',
            value: acceptedChapterCount,
            detail: 'Accepted Chapters',
            icon: Icons.task_alt_outlined,
          ),
          _ConsoleMetricData(
            label: '故事圣经',
            value: storyBibleState,
            detail: 'Story Bible',
            icon: Icons.menu_book_outlined,
          ),
          _ConsoleMetricData(
            label: '记忆投影',
            value: memoryProjectionState,
            detail: 'Memory Projection',
            icon: Icons.account_tree_outlined,
          ),
        ];

        final columns = constraints.maxWidth < 760 ? 2 : 4;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 118,
          ),
          itemBuilder: (context, index) =>
              _ConsoleMetric(metric: metrics[index]),
        );
      },
    );
  }
}

class _ConsoleMetricData {
  const _ConsoleMetricData({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
}

class _ConsoleMetric extends StatelessWidget {
  const _ConsoleMetric({required this.metric});

  final _ConsoleMetricData metric;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return PersonaPanel(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: Icon(metric.icon, color: colorScheme.primary, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(metric.label.toUpperCase(), style: textTheme.labelMedium),
                const SizedBox(height: 8),
                Text(metric.value, style: textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(metric.detail, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectDossier extends StatelessWidget {
  const _ProjectDossier({
    required this.project,
    required this.providerLabel,
    required this.styleProfileLabel,
    required this.plotProfileLabel,
  });

  final WritingProject project;
  final String providerLabel;
  final String styleProfileLabel;
  final String plotProfileLabel;

  @override
  Widget build(BuildContext context) {
    return PersonaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PersonaSectionHeader(
            title: '项目概要',
            description: '项目身份、默认模型、分析档案挂载和基础写作参数。',
            trailing: PersonaStatusPill(
              label: project.status == ProjectStatus.active ? '活动' : '归档',
              icon: project.status == ProjectStatus.active
                  ? Icons.edit_note_outlined
                  : Icons.inventory_2_outlined,
            ),
          ),
          const SizedBox(height: 18),
          _DossierField(
            label: '简介',
            value: project.description.trim().isEmpty
                ? '未填写项目简介。'
                : project.description,
          ),
          const SizedBox(height: 14),
          _DossierField(label: '默认 Provider / Model', value: providerLabel),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DossierField(
                  label: 'Style Profile',
                  value: styleProfileLabel,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _DossierField(
                  label: 'Plot Profile',
                  value: plotProfileLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DossierField(label: '语言', value: project.language),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _DossierField(
                  label: '目标长度',
                  value: '${project.targetLength} 字',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _DossierField(label: '叙事视角', value: project.narrativePerspective),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DossierField(
                  label: '创建时间',
                  value: _formatProjectTime(project.createdAt),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _DossierField(
                  label: '更新时间',
                  value: _formatProjectTime(project.updatedAt),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DossierField extends StatelessWidget {
  const _DossierField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
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
            Text(value, style: textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class _ProjectCommandPanel extends StatelessWidget {
  const _ProjectCommandPanel({
    required this.project,
    required this.providerLabel,
    required this.styleProfileLabel,
    required this.plotProfileLabel,
    required this.chapterPlanCount,
    required this.acceptedChapterCount,
    required this.storyBibleState,
    required this.memoryProjectionState,
  });

  final WritingProject project;
  final String providerLabel;
  final String styleProfileLabel;
  final String plotProfileLabel;
  final String chapterPlanCount;
  final String acceptedChapterCount;
  final String storyBibleState;
  final String memoryProjectionState;

  @override
  Widget build(BuildContext context) {
    return PersonaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PersonaSectionHeader(
            title: '创作工作台',
            description: '从项目资产进入章节流水线。当前阶段支持章节计划管理。',
          ),
          const SizedBox(height: 16),
          _CommandAction(
            icon: Icons.dashboard_customize_outlined,
            title: '进入章节工作台',
            description: '管理 Chapter Plan，后续接入 Contract、Draft、Audit 和 Accept。',
            onTap: () => context.go('/projects/${project.id}/workshop'),
          ),
          const SizedBox(height: 16),
          _ReadinessLine(label: 'Provider / Model', value: providerLabel),
          _ReadinessLine(label: 'Style Profile', value: styleProfileLabel),
          _ReadinessLine(label: 'Plot Profile', value: plotProfileLabel),
          _ReadinessLine(label: '章节计划', value: '$chapterPlanCount 个计划'),
          _ReadinessLine(label: '正式章节', value: '$acceptedChapterCount 个已确认'),
          _ReadinessLine(label: 'Story Bible', value: storyBibleState),
          _ReadinessLine(
            label: 'Memory Projection',
            value: memoryProjectionState,
          ),
        ],
      ),
    );
  }
}

class _CommandAction extends StatelessWidget {
  const _CommandAction({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(description, style: textTheme.bodyMedium),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward, color: colorScheme.primary, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReadinessLine extends StatelessWidget {
  const _ReadinessLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(label.toUpperCase(), style: textTheme.labelMedium),
          ),
          Expanded(child: Text(value, style: textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

String _providerLabel(
  AsyncValue<List<ProviderConfig>> providers,
  WritingProject project,
) {
  final providerId = project.defaultProviderId;
  final modelName = project.defaultModelName;
  if (providerId == null || providerId.trim().isEmpty) {
    return '待补齐默认 Provider。';
  }
  if (modelName == null || modelName.trim().isEmpty) {
    return '待补齐默认模型。';
  }

  return providers.when(
    data: (items) {
      final provider = _findById(items, providerId, (item) => item.id);
      if (provider == null) {
        return 'Provider 已失效 · $modelName';
      }
      final modelSuffix = provider.modelNames.contains(modelName)
          ? modelName
          : '$modelName（已失效）';
      return '${provider.name} · $modelSuffix';
    },
    loading: () => '正在读取 Provider...',
    error: (error, stackTrace) => 'Provider 状态读取失败：$error',
  );
}

String _styleProfileLabel(
  AsyncValue<List<StyleProfile>> profiles,
  WritingProject project,
) {
  final profileId = project.styleProfileId;
  if (profileId == null || profileId.trim().isEmpty) {
    return '未挂载 Style Profile。';
  }

  return profiles.when(
    data: (items) {
      final profile = _findById(items, profileId, (item) => item.id);
      return profile == null ? 'Style Profile 已失效。' : profile.styleName;
    },
    loading: () => '正在读取 Style Profile...',
    error: (error, stackTrace) => 'Style Profile 状态读取失败：$error',
  );
}

String _plotProfileLabel(
  AsyncValue<List<PlotProfile>> profiles,
  WritingProject project,
) {
  final profileId = project.plotProfileId;
  if (profileId == null || profileId.trim().isEmpty) {
    return '未挂载 Plot Profile。';
  }

  return profiles.when(
    data: (items) {
      final profile = _findById(items, profileId, (item) => item.id);
      return profile == null ? 'Plot Profile 已失效。' : profile.plotName;
    },
    loading: () => '正在读取 Plot Profile...',
    error: (error, stackTrace) => 'Plot Profile 状态读取失败：$error',
  );
}

T? _findById<T>(List<T> items, String id, String Function(T item) getId) {
  for (final item in items) {
    if (getId(item) == id) {
      return item;
    }
  }
  return null;
}

String _formatProjectTime(DateTime value) {
  final local = value.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');

  return '$year-$month-$day $hour:$minute';
}

String _asyncCount(AsyncValue<List<Object?>> value) {
  return value.maybeWhen(
    data: (items) => items.length.toString(),
    orElse: () => '...',
  );
}

String _documentState(
  AsyncValue<Object?> value, {
  required String empty,
  required String ready,
}) {
  return value.maybeWhen(
    data: (item) => item == null ? empty : ready,
    loading: () => '读取中...',
    error: (error, stackTrace) => '读取失败',
    orElse: () => '读取中...',
  );
}
