import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/glass_container.dart';
import '../../../core/ui/hoverable_widget.dart';
import '../../../core/ui/persona_page.dart';
import '../../../core/ui/skeleton_loader.dart';
import '../application/provider_config_providers.dart';
import '../domain/provider_config.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = ref.watch(providerConfigsProvider);

    return PersonaPage(
      eyebrow: '本地控制',
      title: '设置',
      description: '配置 OpenAI-compatible Provider、本地数据边界、导入导出和备份行为。',
      children: [
        providers.when(
          data: (items) => _ProviderSettings(items: items),
          error: (error, stackTrace) => PersonaPanel(
            child: Text(
              '无法加载 Provider：$error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          loading: () => _buildSkeletonLoading(),
        ),
        const SizedBox(height: 18),
        const _PendingActionsPanel(),
      ],
    );
  }
}

class _ProviderSettings extends StatelessWidget {
  const _ProviderSettings({required this.items});

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
              title: 'Provider 控制台',
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
                    onPressed: () => _showProviderDialog(context),
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
              child: const _EmptyProviderState(),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: _ProviderList(items: items),
            ),
        ],
      ),
    );
  }
}

class _EmptyProviderState extends StatelessWidget {
  const _EmptyProviderState();

  @override
  Widget build(BuildContext context) {
    return PersonaEmptyStateCard(
      icon: Icons.key_outlined,
      title: '尚未配置 Provider',
      description: '添加 Base URL、API Key 和默认模型后，可以运行真实连接测试。',
      action: OutlinedButton.icon(
        onPressed: () => _showProviderDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('新增 Provider'),
      ),
    );
  }
}

class _ProviderList extends StatelessWidget {
  const _ProviderList({required this.items});

  final List<ProviderConfig> items;

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(
      context,
    ).colorScheme.outlineVariant.withValues(alpha: 0.5);
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _ProviderRow(provider: items[i]),
          if (i < items.length - 1)
            Divider(height: 1, thickness: 1, color: dividerColor),
        ],
      ],
    );
  }
}

class _ProviderRow extends ConsumerWidget {
  const _ProviderRow({required this.provider});

  final ProviderConfig provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColor = _statusColor(colorScheme, provider.testStatus);
    final isBusy = ref.watch(providerConfigControllerProvider).isLoading;
    final host = _extractHost(provider.baseUrl);

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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 700;
                  final info = _buildInfo(context, host, statusColor);
                  final actions = _buildActions(
                    context,
                    ref,
                    isBusy,
                    statusColor,
                  );

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _StatusDot(color: statusColor),
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
                                color: statusColor.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  }

                  return Row(
                    children: [
                      _StatusDot(color: statusColor),
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
                            message: provider.lastTestMessage!,
                            child: Text(
                              provider.lastTestMessage!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: statusColor.withValues(alpha: 0.8),
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

  Widget _buildInfo(BuildContext context, String host, Color statusColor) {
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
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            child: Text(
              provider.defaultModel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                fontFamily: 'monospace',
                fontFamilyFallback: ['Menlo', 'Courier'],
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
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
    Color statusColor,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.network_check, size: 18, color: statusColor),
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
          onPressed: () => _showProviderDialog(context, provider: provider),
        ),
        IconButton(
          icon: Icon(Icons.delete_outline, size: 18),
          tooltip: '删除',
          iconSize: 18,
          visualDensity: VisualDensity.compact,
          onPressed: () => _confirmDelete(context, ref, provider),
        ),
        const Icon(Icons.chevron_right, size: 18),
      ],
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

String _extractHost(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri != null && uri.host.isNotEmpty) {
    return uri.host + (uri.port != 80 && uri.port != 443 ? ':${uri.port}' : '');
  }
  return url;
}

class _PendingActionsPanel extends StatelessWidget {
  const _PendingActionsPanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PersonaPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PersonaSectionHeader(
            title: '待开发',
            description: '本地数据 / 导入导出 / 备份恢复',
            trailing: PersonaStatusPill(
              label: '3 项',
              icon: Icons.construction_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _PendingItem(label: '本地数据'),
              _PendingItem(label: '导入 / 导出'),
              _PendingItem(label: '备份 / 恢复'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '这些功能还未完成，先保留占位，不提供误导性的点击入口。',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingItem extends StatelessWidget {
  const _PendingItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(kPanelRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(label, style: textTheme.titleSmall),
            const SizedBox(width: 10),
            Text(
              '待开发',
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderDialog extends ConsumerStatefulWidget {
  const _ProviderDialog({this.provider});

  final ProviderConfig? provider;

  @override
  ConsumerState<_ProviderDialog> createState() => _ProviderDialogState();
}

class _ProviderDialogState extends ConsumerState<_ProviderDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _baseUrlController;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _modelController;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    final provider = widget.provider;
    _nameController = TextEditingController(text: provider?.name ?? '');
    _baseUrlController = TextEditingController(text: provider?.baseUrl ?? '');
    _apiKeyController = TextEditingController(text: provider?.apiKey ?? '');
    _modelController = TextEditingController(
      text: provider?.defaultModel ?? '',
    );
    _isEnabled = provider?.isEnabled ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(providerConfigControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(providerConfigControllerProvider, (previous, next) {
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
          widget.provider == null ? '新增 Provider' : '编辑 Provider',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          '配置 OpenAI-compatible 连接。API Key 只保存在本地 SQLite 中。',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 620;
              final nameField = TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '名称'),
                validator: _requiredValidator,
              );
              final modelField = TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: '默认模型',
                  hintText: 'gpt-4.1-mini',
                ),
                validator: _requiredValidator,
              );
              final baseUrlField = TextFormField(
                controller: _baseUrlController,
                decoration: const InputDecoration(
                  labelText: 'Base URL',
                  hintText: 'https://api.openai.com/v1',
                ),
                keyboardType: TextInputType.url,
                validator: _urlValidator,
              );
              final apiKeyField = TextFormField(
                controller: _apiKeyController,
                decoration: const InputDecoration(labelText: 'API Key'),
                obscureText: true,
                validator: _requiredValidator,
              );

              final fields = [nameField, modelField, baseUrlField, apiKeyField];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isWide) ...[
                    Row(
                      children: [
                        Expanded(child: nameField),
                        const SizedBox(width: 12),
                        Expanded(child: modelField),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: baseUrlField),
                        const SizedBox(width: 12),
                        Expanded(child: apiKeyField),
                      ],
                    ),
                  ] else
                    for (final field in fields) ...[
                      field,
                      if (field != fields.last) const SizedBox(height: 12),
                    ],
                  const SizedBox(height: 14),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.28,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      title: const Text('启用 Provider'),
                      subtitle: const Text('停用后不参与正式生成选择，但详情页仍可测试。'),
                      value: _isEnabled,
                      onChanged: (value) => setState(() => _isEnabled = value),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '保存后连接测试状态会按现有规则重置，完整密钥不会在界面中展示。',
                    style: textTheme.bodySmall,
                  ),
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
        .read(providerConfigControllerProvider.notifier)
        .save(
          id: widget.provider?.id,
          input: ProviderConfigInput(
            name: _nameController.text,
            baseUrl: _baseUrlController.text,
            apiKey: _apiKeyController.text,
            defaultModel: _modelController.text,
            systemPrompt: widget.provider?.systemPrompt ?? '',
            isEnabled: _isEnabled,
          ),
        );

    if (mounted && !ref.read(providerConfigControllerProvider).hasError) {
      Navigator.of(context).pop();
    }
  }
}

void _showProviderDialog(BuildContext context, {ProviderConfig? provider}) {
  showGlassDialog<void>(
    context: context,
    maxWidth: 720,
    builder: (context) => _ProviderDialog(provider: provider),
  );
}

Future<void> _confirmDelete(
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

String? _requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return '必填';
  }
  return null;
}

String? _urlValidator(String? value) {
  final requiredError = _requiredValidator(value);
  if (requiredError != null) {
    return requiredError;
  }
  final uri = Uri.tryParse(value!.trim());
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    return '请输入有效 URL';
  }
  return null;
}

Widget _buildSkeletonLoading() {
  return PersonaPanel(
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
          child: Row(
            children: const [
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: const [
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

Color _statusColor(ColorScheme colorScheme, ProviderTestStatus status) {
  return switch (status) {
    ProviderTestStatus.untested => colorScheme.onSurfaceVariant,
    ProviderTestStatus.testing => colorScheme.primary,
    ProviderTestStatus.succeeded => const Color(0xFF16825D),
    ProviderTestStatus.failed => colorScheme.error,
  };
}
