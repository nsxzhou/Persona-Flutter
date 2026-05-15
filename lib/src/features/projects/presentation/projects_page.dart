import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/persona_page.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: '工作区',
      title: '项目',
      description: '用于长篇项目、蓝图、章节工作和后续 Zen Editor 写作会话的本地写作工作台。',
      actions: [
        FilledButton.icon(
          onPressed: null,
          icon: Icon(Icons.add),
          label: Text('新建项目'),
        ),
        OutlinedButton.icon(
          onPressed: null,
          icon: Icon(Icons.upload_file_outlined),
          label: Text('导入'),
        ),
      ],
      children: const [
        _WorkspaceSummary(),
        SizedBox(height: 18),
        _ProjectsLayout(),
      ],
    );
  }
}

class _WorkspaceSummary extends StatelessWidget {
  const _WorkspaceSummary();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: PersonaMetric(
            label: '当前项目',
            value: '0',
            detail: '新建或导入项目后开始写作。',
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: PersonaMetric(
            label: '草稿队列',
            value: '就绪',
            detail: '章节工作台和 Zen Editor 入口。',
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: PersonaMetric(
            label: '本地状态',
            value: '离线',
            detail: 'SQLite 本地工作区，无需账号。',
          ),
        ),
      ],
    );
  }
}

class _ProjectsLayout extends StatelessWidget {
  const _ProjectsLayout();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 940;

        final recent = PersonaPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              PersonaSectionHeader(
                title: '最近项目',
                description: '进入项目工作台和章节导航的集中入口。',
              ),
              SizedBox(height: 18),
              _EmptyProjectsState(),
            ],
          ),
        );

        final actions = Column(
          children: const [
            PersonaActionTile(
              icon: Icons.note_add_outlined,
              title: '从空白长篇开始',
              description: '创建本地项目外壳和章节树。',
              accent: true,
            ),
            SizedBox(height: 12),
            PersonaActionTile(
              icon: Icons.description_outlined,
              title: '导入手稿',
              description: '导入 TXT 素材，供后续分析使用。',
            ),
            SizedBox(height: 12),
            PersonaActionTile(
              icon: Icons.view_timeline_outlined,
              title: '打开工作台',
              description: '查看蓝图、角色、总纲和草稿。',
            ),
          ],
        );

        if (!isWide) {
          return Column(
            children: [recent, const SizedBox(height: 18), actions],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: recent),
            const SizedBox(width: 18),
            Expanded(flex: 4, child: actions),
          ],
        );
      },
    );
  }
}

class _EmptyProjectsState extends StatelessWidget {
  const _EmptyProjectsState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(kPanelRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Icon(
              Icons.library_books_outlined,
              color: colorScheme.primary,
              size: 36,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('尚未打开项目', style: textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    '项目存储实现后，这里会显示最近长篇、章节状态和 Zen Editor 入口。',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
