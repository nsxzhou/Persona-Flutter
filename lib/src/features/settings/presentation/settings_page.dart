import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/glass_container.dart';
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
      actions: [
        FilledButton.icon(
          onPressed: () => _showProviderDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('新增 Provider'),
        ),
      ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PersonaSectionHeader(
            title: 'Provider 控制台',
            description: '管理 OpenAI-compatible 连接。页头新增配置，卡片内优先测试当前 Provider。',
            trailing: PersonaStatusPill(
              label: '${items.length} 个配置',
              icon: Icons.key_outlined,
            ),
          ),
          const SizedBox(height: 18),
          if (items.isEmpty)
            const _EmptyProviderState()
          else
            _ProviderList(items: items),
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
    return Column(
      children: [
        for (final item in items) ...[
          _ProviderCard(provider: item),
          if (item != items.last) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ProviderCard extends ConsumerWidget {
  const _ProviderCard({required this.provider});

  final ProviderConfig provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(colorScheme, provider.testStatus);
    final controllerState = ref.watch(providerConfigControllerProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(kPanelRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final details = _ProviderDetails(
              provider: provider,
              statusColor: statusColor,
            );
            final actions = _ProviderActions(
              provider: provider,
              isBusy: controllerState.isLoading,
            );

            if (constraints.maxWidth < 720) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [details, const SizedBox(height: 14), actions],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: details),
                const SizedBox(width: 18),
                SizedBox(width: 190, child: actions),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProviderDetails extends StatelessWidget {
  const _ProviderDetails({required this.provider, required this.statusColor});

  final ProviderConfig provider;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor.withValues(alpha: 0.24)),
          ),
          child: Icon(
            _statusIcon(provider.testStatus),
            color: statusColor,
            size: 21,
          ),
        ),
        const SizedBox(width: 14),
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
                    provider.name,
                    style: textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  PersonaStatusPill(
                    label: _statusLabel(provider.testStatus),
                    icon: _statusIcon(provider.testStatus),
                    color: statusColor,
                  ),
                  if (!provider.isEnabled)
                    PersonaStatusPill(
                      label: '已停用',
                      icon: Icons.pause_circle_outline,
                      color: colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              _ProviderMetaGrid(provider: provider),
              if (provider.lastTestMessage != null) ...[
                const SizedBox(height: 10),
                _ProviderTestMessage(
                  message: provider.lastTestMessage!,
                  color: statusColor,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProviderMetaGrid extends StatelessWidget {
  const _ProviderMetaGrid({required this.provider});

  final ProviderConfig provider;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cells = [
          _ProviderMetaCell(
            label: 'Base URL',
            value: provider.baseUrl,
            icon: Icons.link_outlined,
          ),
          _ProviderMetaCell(
            label: '默认模型',
            value: provider.defaultModel,
            icon: Icons.memory_outlined,
          ),
          _ProviderMetaCell(
            label: 'API Key',
            value: _maskApiKey(provider.apiKey),
            icon: Icons.vpn_key_outlined,
          ),
        ];

        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              for (final cell in cells) ...[
                cell,
                if (cell != cells.last) const SizedBox(height: 8),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (final cell in cells) ...[
              Expanded(child: cell),
              if (cell != cells.last) const SizedBox(width: 8),
            ],
          ],
        );
      },
    );
  }
}

class _ProviderMetaCell extends StatelessWidget {
  const _ProviderMetaCell({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(kPanelRadius),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.72),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.onSurfaceVariant, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: textTheme.labelMedium),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _ProviderTestMessage extends StatelessWidget {
  const _ProviderTestMessage({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(kPanelRadius),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.bolt_outlined, color: color, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderActions extends ConsumerWidget {
  const _ProviderActions({required this.provider, required this.isBusy});

  final ProviderConfig provider;
  final bool isBusy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        FilledButton.icon(
          onPressed: isBusy
              ? null
              : () => ref
                    .read(providerConfigControllerProvider.notifier)
                    .test(provider.id),
          icon: const Icon(Icons.network_check),
          label: const Text('测试连接'),
        ),
        IconButton(
          tooltip: '编辑',
          onPressed: () => _showProviderDialog(context, provider: provider),
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          tooltip: '删除',
          onPressed: () => _confirmDelete(context, ref, provider),
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
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
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 520,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '名称'),
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _baseUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Base URL',
                    hintText: 'https://api.openai.com/v1',
                  ),
                  keyboardType: TextInputType.url,
                  validator: _urlValidator,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _apiKeyController,
                  decoration: const InputDecoration(labelText: 'API Key'),
                  obscureText: true,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _modelController,
                  decoration: const InputDecoration(
                    labelText: '默认模型',
                    hintText: 'gpt-4.1-mini',
                  ),
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('启用 Provider'),
                  value: _isEnabled,
                  onChanged: (value) => setState(() => _isEnabled = value),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
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
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('删除 Provider', style: Theme.of(context).textTheme.titleLarge),
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

String _maskApiKey(String value) {
  final trimmed = value.trim();
  if (trimmed.length <= 8) {
    return '••••';
  }
  return '${trimmed.substring(0, 4)}••••${trimmed.substring(trimmed.length - 4)}';
}

String _statusLabel(ProviderTestStatus status) {
  return switch (status) {
    ProviderTestStatus.untested => '未测试',
    ProviderTestStatus.testing => '测试中',
    ProviderTestStatus.succeeded => '可用',
    ProviderTestStatus.failed => '失败',
  };
}

IconData _statusIcon(ProviderTestStatus status) {
  return switch (status) {
    ProviderTestStatus.untested => Icons.help_outline,
    ProviderTestStatus.testing => Icons.sync,
    ProviderTestStatus.succeeded => Icons.check_circle_outline,
    ProviderTestStatus.failed => Icons.error_outline,
  };
}

Widget _buildSkeletonLoading() {
  return Column(
    children: [
      const PersonaPanel(child: _ProviderListSkeleton()),
    ],
  );
}

class _ProviderListSkeleton extends StatelessWidget {
  const _ProviderListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Expanded(child: SkeletonBox(width: 120, height: 16)),
            SizedBox(width: 16),
            SkeletonBox(width: 80, height: 24),
          ],
        ),
        const SizedBox(height: 18),
        const _ProviderCardSkeleton(),
        const SizedBox(height: 12),
        const _ProviderCardSkeleton(),
      ],
    );
  }
}

class _ProviderCardSkeleton extends StatelessWidget {
  const _ProviderCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kPanelRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SkeletonBox(width: 42, height: 42),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 140, height: 14),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: SkeletonBox(width: 100, height: 36)),
                      SizedBox(width: 8),
                      Expanded(child: SkeletonBox(width: 100, height: 36)),
                      SizedBox(width: 8),
                      Expanded(child: SkeletonBox(width: 100, height: 36)),
                    ],
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

Color _statusColor(ColorScheme colorScheme, ProviderTestStatus status) {
  return switch (status) {
    ProviderTestStatus.untested => colorScheme.onSurfaceVariant,
    ProviderTestStatus.testing => colorScheme.primary,
    ProviderTestStatus.succeeded => const Color(0xFF16825D),
    ProviderTestStatus.failed => colorScheme.error,
  };
}
