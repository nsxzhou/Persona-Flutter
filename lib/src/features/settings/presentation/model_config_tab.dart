import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/glass_container.dart';
import '../../../core/ui/hoverable_widget.dart';
import '../../../core/ui/persona_page.dart';
import '../../../core/ui/skeleton_loader.dart';
import '../application/image_provider_config_providers.dart';
import '../application/provider_config_providers.dart';
import '../domain/image_provider_config.dart';
import '../domain/provider_config.dart';
import 'widgets/persona_form_utils.dart';
import 'widgets/persona_info_pill.dart';
import 'widgets/persona_status_indicator.dart';
import 'widgets/provider_dialog.dart';

enum _ProviderTab { llm, image }

class ModelConfigTab extends StatefulWidget {
  const ModelConfigTab({super.key});

  @override
  State<ModelConfigTab> createState() => _ModelConfigTabState();
}

class _ModelConfigTabState extends State<ModelConfigTab> {
  _ProviderTab _selectedTab = _ProviderTab.llm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTabSwitcher(),
        const SizedBox(height: 16),
        if (_selectedTab == _ProviderTab.llm)
          const _LlmProviderList()
        else
          const _ImageProviderList(),
      ],
    );
  }

  Widget _buildTabSwitcher() {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        SegmentedButton<_ProviderTab>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: _ProviderTab.llm,
              icon: Icon(Icons.smart_toy_outlined, size: 15),
              label: Text('LLM'),
            ),
            ButtonSegment(
              value: _ProviderTab.image,
              icon: Icon(Icons.image_outlined, size: 15),
              label: Text('图像'),
            ),
          ],
          selected: {_selectedTab},
          onSelectionChanged: (selection) {
            setState(() => _selectedTab = selection.first);
          },
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            textStyle: WidgetStatePropertyAll(textTheme.labelSmall),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// LLM Provider List
// ---------------------------------------------------------------------------

class _LlmProviderList extends ConsumerWidget {
  const _LlmProviderList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = ref.watch(providerConfigsProvider);
    return providers.when(
      data: (items) => _LlmProviderPanel(items: items),
      error: (error, stackTrace) => PersonaPanel(
        child: Text(
          '无法加载 Provider：$error',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
      loading: () => _buildSkeletonLoading(),
    );
  }
}

class _LlmProviderPanel extends StatelessWidget {
  const _LlmProviderPanel({required this.items});

  final List<ProviderConfig> items;

  @override
  Widget build(BuildContext context) {
    return PersonaPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
            child: PersonaSectionHeader(
              title: 'LLM Provider',
              description: '管理 OpenAI-compatible 连接，测试可用性与配置详情。',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PersonaStatusPill(
                    label: '${items.length} 个配置',
                    icon: Icons.key_outlined,
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: () => showProviderDialog(
                      context,
                      type: ProviderType.llm,
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('新增'),
                  ),
                ],
              ),
            ),
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: PersonaEmptyStateCard(
                icon: Icons.key_outlined,
                title: '尚未配置 Provider',
                description:
                    '添加 Base URL、API Key 和默认模型后，可以运行真实连接测试。',
                action: OutlinedButton.icon(
                  onPressed: () => showProviderDialog(
                    context,
                    type: ProviderType.llm,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('新增 Provider'),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: _ProviderConfigList(items: items),
            ),
        ],
      ),
    );
  }
}

class _ProviderConfigList extends StatelessWidget {
  const _ProviderConfigList({required this.items});

  final List<ProviderConfig> items;

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(
      context,
    ).colorScheme.outlineVariant.withValues(alpha: 0.5);
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _ProviderConfigRow(provider: items[i]),
          if (i < items.length - 1)
            Divider(height: 1, thickness: 1, color: dividerColor),
        ],
      ],
    );
  }
}

class _ProviderConfigRow extends ConsumerWidget {
  const _ProviderConfigRow({required this.provider});

  final ProviderConfig provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final sColor = statusColor(colorScheme, provider.testStatus);
    final isBusy = ref.watch(providerConfigControllerProvider).isLoading;
    final host = extractHost(provider.baseUrl);

    return HoverableWidget(
      scaleOnHover: 1.0,
      builder: (context, isHovered, child) {
        return Material(
          color: isHovered
              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.18)
              : Colors.transparent,
          child: InkWell(
            onTap: () => context.go('/settings/providers/${provider.id}'),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 700;
                  final info = _buildInfo(context, host, sColor);
                  final actions = _buildActions(
                    context,
                    ref,
                    isBusy,
                    sColor,
                  );

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            StatusDot(color: sColor),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                provider.name,
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            actions,
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 18),
                          child: info,
                        ),
                        if (provider.lastTestMessage != null) ...[
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 18),
                            child: Text(
                              provider.lastTestMessage!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: sColor.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  }

                  return Row(
                    children: [
                      StatusDot(color: sColor),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 150,
                        child: Text(
                          provider.name,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: info),
                      if (provider.lastTestMessage != null) ...[
                        const SizedBox(width: 12),
                        Flexible(
                          child: Tooltip(
                            message: provider.lastTestMessage,
                            child: Text(
                              provider.lastTestMessage!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: sColor.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 12),
                      actions,
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfo(BuildContext context, String host, Color sColor) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            host,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 10),
        MonoPill(label: provider.defaultModel),
        if (provider.modelNames.length > 1) ...[
          const SizedBox(width: 8),
          Text(
            '+${provider.modelNames.length - 1} models',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (!provider.isEnabled) ...[
          const SizedBox(width: 8),
          PersonaStatusPill(
            label: '停用',
            icon: Icons.pause_circle_outline,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ],
    );
  }

  Widget _buildActions(
    BuildContext context,
    WidgetRef ref,
    bool isBusy,
    Color sColor,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.network_check, size: 18, color: sColor),
          tooltip: '测试连接',
          iconSize: 18,
          visualDensity: VisualDensity.compact,
          onPressed: isBusy
              ? null
              : () => ref
                    .read(providerConfigControllerProvider.notifier)
                    .test(provider.id),
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 18),
          tooltip: '编辑',
          iconSize: 18,
          visualDensity: VisualDensity.compact,
          onPressed: () => showProviderDialog(
            context,
            type: ProviderType.llm,
            llmProvider: provider,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 18),
          tooltip: '删除',
          iconSize: 18,
          visualDensity: VisualDensity.compact,
          onPressed: () => _confirmDeleteLlm(context, ref, provider),
        ),
        const Icon(Icons.chevron_right, size: 18),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Image Provider List
// ---------------------------------------------------------------------------

class _ImageProviderList extends ConsumerWidget {
  const _ImageProviderList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = ref.watch(imageProviderConfigsProvider);
    return providers.when(
      data: (items) => _ImageProviderPanel(items: items),
      error: (error, stackTrace) => PersonaPanel(
        child: Text(
          '无法加载图像 Provider：$error',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
      loading: () => _buildSkeletonLoading(),
    );
  }
}

class _ImageProviderPanel extends StatelessWidget {
  const _ImageProviderPanel({required this.items});

  final List<ImageProviderConfig> items;

  @override
  Widget build(BuildContext context) {
    return PersonaPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
            child: PersonaSectionHeader(
              title: '图像 Provider',
              description: '管理 Bearer 生图连接，用样例生成测试真实可用性。',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PersonaStatusPill(
                    label: '${items.length} 个配置',
                    icon: Icons.image_outlined,
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: () => showProviderDialog(
                      context,
                      type: ProviderType.image,
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('新增'),
                  ),
                ],
              ),
            ),
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: PersonaEmptyStateCard(
                icon: Icons.image_outlined,
                title: '尚未配置图像 Provider',
                description:
                    '添加 Base URL、API Key 和默认模型后，可以运行样例文生图测试。',
                action: OutlinedButton.icon(
                  onPressed: () => showProviderDialog(
                    context,
                    type: ProviderType.image,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('新增图像 Provider'),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: _ImageProviderConfigList(items: items),
            ),
        ],
      ),
    );
  }
}

class _ImageProviderConfigList extends StatelessWidget {
  const _ImageProviderConfigList({required this.items});

  final List<ImageProviderConfig> items;

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(
      context,
    ).colorScheme.outlineVariant.withValues(alpha: 0.5);
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _ImageProviderConfigRow(provider: items[i]),
          if (i < items.length - 1)
            Divider(height: 1, thickness: 1, color: dividerColor),
        ],
      ],
    );
  }
}

class _ImageProviderConfigRow extends ConsumerWidget {
  const _ImageProviderConfigRow({required this.provider});

  final ImageProviderConfig provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final sColor = statusColor(colorScheme, provider.testStatus);
    final isBusy = ref.watch(imageProviderConfigControllerProvider).isLoading;
    final host = extractHost(provider.baseUrl);

    return HoverableWidget(
      scaleOnHover: 1.0,
      builder: (context, isHovered, child) {
        return Material(
          color: isHovered
              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.18)
              : Colors.transparent,
          child: InkWell(
            onTap: () =>
                context.go('/settings/image-providers/${provider.id}'),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 740;
                  final info = _buildInfo(context, host);
                  final actions = _buildActions(
                    context,
                    ref,
                    isBusy,
                    sColor,
                  );

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            StatusDot(color: sColor),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                provider.name,
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            actions,
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 18),
                          child: info,
                        ),
                        if (provider.lastTestMessage != null) ...[
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 18),
                            child: Text(
                              provider.lastTestMessage!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: sColor.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  }

                  return Row(
                    children: [
                      StatusDot(color: sColor),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 150,
                        child: Text(
                          provider.name,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: info),
                      if (provider.lastTestMessage != null) ...[
                        const SizedBox(width: 12),
                        Flexible(
                          child: Tooltip(
                            message: provider.lastTestMessage,
                            child: Text(
                              provider.lastTestMessage!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: sColor.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 12),
                      actions,
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfo(BuildContext context, String host) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            host,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 10),
        MonoPill(label: provider.defaultModel),
        const SizedBox(width: 8),
        Text(
          '${provider.defaultAspectRatio.label} · ${provider.defaultSize.label}',
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        if (provider.modelNames.length > 1) ...[
          const SizedBox(width: 8),
          Text(
            '+${provider.modelNames.length - 1} models',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (!provider.isEnabled) ...[
          const SizedBox(width: 8),
          PersonaStatusPill(
            label: '停用',
            icon: Icons.pause_circle_outline,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ],
    );
  }

  Widget _buildActions(
    BuildContext context,
    WidgetRef ref,
    bool isBusy,
    Color sColor,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.auto_awesome_outlined, size: 18, color: sColor),
          tooltip: '样例生成测试',
          iconSize: 18,
          visualDensity: VisualDensity.compact,
          onPressed: isBusy
              ? null
              : () => ref
                    .read(imageProviderConfigControllerProvider.notifier)
                    .test(provider.id),
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 18),
          tooltip: '编辑',
          iconSize: 18,
          visualDensity: VisualDensity.compact,
          onPressed: () => showProviderDialog(
            context,
            type: ProviderType.image,
            imageProvider: provider,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 18),
          tooltip: '删除',
          iconSize: 18,
          visualDensity: VisualDensity.compact,
          onPressed: () => _confirmDeleteImage(context, ref, provider),
        ),
        const Icon(Icons.chevron_right, size: 18),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Confirm Delete Dialogs
// ---------------------------------------------------------------------------

Future<void> _confirmDeleteLlm(
  BuildContext context,
  WidgetRef ref,
  ProviderConfig provider,
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
            Text('删除 Provider', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        const SizedBox(height: 12),
        Text('确定删除「${provider.name}」吗？API Key 会从 SQLite 中删除。'),
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
    await ref
        .read(providerConfigControllerProvider.notifier)
        .delete(provider.id);
  }
}

Future<void> _confirmDeleteImage(
  BuildContext context,
  WidgetRef ref,
  ImageProviderConfig provider,
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
            Text(
              '删除图像 Provider',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('确定删除「${provider.name}」吗？API Key 会从 SQLite 中删除。'),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('删除'),
            ),
          ],
        ),
      ],
    ),
  );

  if (confirmed ?? false) {
    await ref
        .read(imageProviderConfigControllerProvider.notifier)
        .delete(provider.id);
  }
}

// ---------------------------------------------------------------------------
// Skeleton Loading
// ---------------------------------------------------------------------------

Widget _buildSkeletonLoading() {
  return PersonaPanel(
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 14),
          child: Row(
            children: [
              SkeletonBox(width: 120, height: 16),
              Spacer(),
              SkeletonBox(width: 70, height: 32),
            ],
          ),
        ),
        for (var i = 0; i < 3; i++) ...[
          const _ProviderRowSkeleton(),
          if (i < 2) const Divider(height: 1),
        ],
      ],
    ),
  );
}

class _ProviderRowSkeleton extends StatelessWidget {
  const _ProviderRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          SkeletonBox(width: 8, height: 8),
          SizedBox(width: 10),
          SkeletonBox(width: 120, height: 14),
          SizedBox(width: 16),
          Expanded(child: SkeletonBox(width: 160, height: 12)),
          SizedBox(width: 10),
          SkeletonBox(width: 80, height: 20),
          SizedBox(width: 16),
          SkeletonBox(width: 80, height: 28),
        ],
      ),
    );
  }
}
