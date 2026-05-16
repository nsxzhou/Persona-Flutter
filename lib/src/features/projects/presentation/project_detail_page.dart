import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/persona_page.dart';
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

class _ProjectDetailContent extends StatelessWidget {
  const _ProjectDetailContent({required this.project});

  final WritingProject project;

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: '项目档案',
      title: project.title,
      description: project.description.trim().isEmpty
          ? '这个项目还没有简介。'
          : project.description,
      actions: [
        OutlinedButton.icon(
          onPressed: () => context.go('/projects'),
          icon: const Icon(Icons.arrow_back),
          label: const Text('返回项目'),
        ),
      ],
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final dossier = _ProjectDossier(project: project);
            const nextSteps = _ProjectWorkbenchPreview();

            if (constraints.maxWidth < 900) {
              return Column(
                children: [dossier, const SizedBox(height: 18), nextSteps],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: dossier),
                const SizedBox(width: 18),
                const Expanded(flex: 5, child: nextSteps),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ProjectDossier extends StatelessWidget {
  const _ProjectDossier({required this.project});

  final WritingProject project;

  @override
  Widget build(BuildContext context) {
    return PersonaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PersonaSectionHeader(
            title: '项目概要',
            description: '当前版本只保存项目身份信息，后续章节和蓝图会接入这里。',
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

class _ProjectWorkbenchPreview extends StatelessWidget {
  const _ProjectWorkbenchPreview();

  @override
  Widget build(BuildContext context) {
    return PersonaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          PersonaSectionHeader(
            title: '后续工作台入口',
            description: '本轮只建立项目档案，以下能力暂不提供点击入口。',
          ),
          SizedBox(height: 16),
          PersonaActionTile(
            icon: Icons.account_tree_outlined,
            title: '章节结构',
            description: '后续接入分卷、章节细纲和正文状态。',
          ),
          SizedBox(height: 12),
          PersonaActionTile(
            icon: Icons.style_outlined,
            title: 'Style / Plot 挂载',
            description: '后续把分析档案绑定到当前项目。',
          ),
          SizedBox(height: 12),
          PersonaActionTile(
            icon: Icons.edit_note_outlined,
            title: 'Zen Editor',
            description: '后续进入章节写作、改写和记忆同步。',
          ),
        ],
      ),
    );
  }
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
