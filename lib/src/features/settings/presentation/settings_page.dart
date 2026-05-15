import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/persona_page.dart';
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
          loading: () => const PersonaPanel(child: LinearProgressIndicator()),
        ),
        const SizedBox(height: 18),
        const _LocalDataGrid(),
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
            title: 'Provider 设置',
            description: '保存 OpenAI-compatible 连接配置。API Key 当前按项目决策存入 SQLite。',
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Icon(Icons.key_outlined, color: colorScheme.primary, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('尚未配置 Provider', style: textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    '添加 Base URL、API Key 和默认模型后，可以运行真实连接测试。',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: () => _showProviderDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('添加'),
            ),
          ],
        ),
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
          _ProviderRow(provider: item),
          if (item != items.last) const Divider(height: 1),
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(colorScheme, provider.testStatus);
    final controllerState = ref.watch(providerConfigControllerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: PersonaStatusPill(
              label: _statusLabel(provider.testStatus),
              icon: _statusIcon(provider.testStatus),
              color: statusColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(provider.name, style: textTheme.titleMedium),
                    ),
                    if (!provider.isEnabled) ...[
                      const SizedBox(width: 8),
                      PersonaStatusPill(
                        label: '已停用',
                        icon: Icons.pause_circle_outline,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(provider.baseUrl, style: textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  '默认模型：${provider.defaultModel} · API Key：${_maskApiKey(provider.apiKey)}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (provider.lastTestMessage != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    provider.lastTestMessage!,
                    style: textTheme.bodySmall?.copyWith(color: statusColor),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: controllerState.isLoading
                    ? null
                    : () => ref
                          .read(providerConfigControllerProvider.notifier)
                          .test(provider.id),
                icon: const Icon(Icons.network_check),
                label: const Text('测试'),
              ),
              IconButton(
                tooltip: '编辑',
                onPressed: () =>
                    _showProviderDialog(context, provider: provider),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: '删除',
                onPressed: () => _confirmDelete(context, ref, provider),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocalDataGrid extends StatelessWidget {
  const _LocalDataGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 3 : 1;

        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          shrinkWrap: true,
          childAspectRatio: columns == 3 ? 2.55 : 4,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            PersonaActionTile(
              icon: Icons.storage_outlined,
              title: '本地数据',
              description: 'SQLite 工作区边界和重置控制。',
            ),
            PersonaActionTile(
              icon: Icons.import_export,
              title: '导入 / 导出',
              description: '迁移手稿、档案和项目文件。',
            ),
            PersonaActionTile(
              icon: Icons.settings_backup_restore,
              title: '备份 / 恢复',
              description: '备份会包含 SQLite 中的 Provider API Key。',
            ),
          ],
        );
      },
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

    return AlertDialog(
      title: Text(widget.provider == null ? '新增 Provider' : '编辑 Provider'),
      content: SizedBox(
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
      actions: [
        TextButton(
          onPressed: state.isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: state.isLoading ? null : _save,
          child: Text(state.isLoading ? '保存中' : '保存'),
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
  showDialog<void>(
    context: context,
    builder: (context) => _ProviderDialog(provider: provider),
  );
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  ProviderConfig provider,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('删除 Provider'),
      content: Text('确定删除「${provider.name}」吗？API Key 会从 SQLite 中删除。'),
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

Color _statusColor(ColorScheme colorScheme, ProviderTestStatus status) {
  return switch (status) {
    ProviderTestStatus.untested => colorScheme.onSurfaceVariant,
    ProviderTestStatus.testing => colorScheme.primary,
    ProviderTestStatus.succeeded => const Color(0xFF16825D),
    ProviderTestStatus.failed => colorScheme.error,
  };
}
