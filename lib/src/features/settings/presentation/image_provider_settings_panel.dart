import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/glass_container.dart';
import '../../../core/ui/hoverable_widget.dart';
import '../../../core/ui/persona_page.dart';
import '../application/image_provider_config_providers.dart';
import '../domain/image_provider_config.dart';
import '../domain/provider_config.dart';

class ImageProviderSettingsPanel extends StatelessWidget {
  const ImageProviderSettingsPanel({required this.items, super.key});

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
                    onPressed: () => _showImageProviderDialog(context),
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
                description: '添加 Base URL、API Key 和默认模型后，可以运行样例文生图测试。',
                action: OutlinedButton.icon(
                  onPressed: () => _showImageProviderDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('新增图像 Provider'),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: _ImageProviderList(items: items),
            ),
        ],
      ),
    );
  }
}

class _ImageProviderList extends StatelessWidget {
  const _ImageProviderList({required this.items});

  final List<ImageProviderConfig> items;

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(
      context,
    ).colorScheme.outlineVariant.withValues(alpha: 0.5);
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _ImageProviderRow(provider: items[i]),
          if (i < items.length - 1)
            Divider(height: 1, thickness: 1, color: dividerColor),
        ],
      ],
    );
  }
}

class _ImageProviderRow extends ConsumerWidget {
  const _ImageProviderRow({required this.provider});

  final ImageProviderConfig provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColor = _statusColor(colorScheme, provider.testStatus);
    final isBusy = ref.watch(imageProviderConfigControllerProvider).isLoading;
    final host = _extractHost(provider.baseUrl);

    return HoverableWidget(
      scaleOnHover: 1.0,
      builder: (context, isHovered, child) {
        return Material(
          color: isHovered
              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.18)
              : Colors.transparent,
          child: InkWell(
            onTap: () => context.go('/settings/image-providers/${provider.id}'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 740;
                  final info = _buildInfo(context, host);
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
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
        _MonoPill(label: provider.defaultModel),
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
    Color statusColor,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.auto_awesome_outlined, size: 18, color: statusColor),
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
          onPressed: () =>
              _showImageProviderDialog(context, provider: provider),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 18),
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

class _ImageProviderDialog extends ConsumerStatefulWidget {
  const _ImageProviderDialog({this.provider});

  final ImageProviderConfig? provider;

  @override
  ConsumerState<_ImageProviderDialog> createState() =>
      _ImageProviderDialogState();
}

class _ImageProviderDialogState extends ConsumerState<_ImageProviderDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _baseUrlController;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _modelController;
  late final TextEditingController _modelsController;
  late ImageProviderKind _providerKind;
  late ImageAspectRatioPreset _defaultAspectRatio;
  late ImageSizePreset _defaultSize;
  late ImageQualityPreset _defaultQuality;
  late ImageResponseFormat _defaultResponseFormat;
  late bool _isEnabled;
  var _isApiKeyVisible = false;

  @override
  void initState() {
    super.initState();
    final provider = widget.provider;
    _nameController = TextEditingController(text: provider?.name ?? '');
    _baseUrlController = TextEditingController(text: provider?.baseUrl ?? '');
    _apiKeyController = TextEditingController(text: provider?.apiKey ?? '');
    _modelController = TextEditingController(
      text: provider?.defaultModel ?? 'gpt-5-3',
    );
    _modelsController = TextEditingController(
      text: (provider?.modelNames ?? const <String>[]).join('\n'),
    );
    _providerKind = provider?.providerKind ?? ImageProviderKind.gpt;
    _defaultAspectRatio =
        provider?.defaultAspectRatio ?? ImageAspectRatioPreset.square;
    _defaultSize = provider?.defaultSize ?? ImageSizePreset.oneK;
    _defaultQuality = provider?.defaultQuality ?? ImageQualityPreset.auto;
    _defaultResponseFormat =
        provider?.defaultResponseFormat ?? ImageResponseFormat.url;
    _isEnabled = provider?.isEnabled ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    _modelsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(imageProviderConfigControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(imageProviderConfigControllerProvider, (previous, next) {
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
          widget.provider == null ? '新增图像 Provider' : '编辑图像 Provider',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          '配置 Bearer 生图连接。API Key 只保存在本地 SQLite 中。',
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
                  hintText: 'gpt-5-3',
                ),
                validator: _requiredValidator,
              );
              final baseUrlField = TextFormField(
                controller: _baseUrlController,
                decoration: const InputDecoration(
                  labelText: 'Base URL',
                  hintText: 'https://example.com',
                ),
                keyboardType: TextInputType.url,
                validator: _urlValidator,
              );
              final apiKeyField = TextFormField(
                controller: _apiKeyController,
                decoration: InputDecoration(
                  labelText: 'API Key',
                  suffixIcon: IconButton(
                    tooltip: _isApiKeyVisible ? '隐藏 API Key' : '显示 API Key',
                    icon: Icon(
                      _isApiKeyVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() => _isApiKeyVisible = !_isApiKeyVisible);
                    },
                  ),
                ),
                obscureText: !_isApiKeyVisible,
                validator: _requiredValidator,
              );
              final modelsField = TextFormField(
                controller: _modelsController,
                decoration: const InputDecoration(
                  labelText: '可用模型',
                  hintText: '每行一个模型；默认模型会自动加入列表',
                ),
                minLines: 3,
                maxLines: 5,
              );
              final kindField = DropdownButtonFormField<ImageProviderKind>(
                initialValue: _providerKind,
                decoration: const InputDecoration(labelText: 'Provider 类型'),
                items: [
                  for (final kind in ImageProviderKind.values)
                    DropdownMenuItem(value: kind, child: Text(kind.label)),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _providerKind = value;
                    if (value == ImageProviderKind.grok) {
                      _defaultResponseFormat = ImageResponseFormat.url;
                    }
                  });
                },
              );
              final aspectRatioField =
                  DropdownButtonFormField<ImageAspectRatioPreset>(
                    initialValue: _defaultAspectRatio,
                    decoration: const InputDecoration(labelText: '默认画幅'),
                    items: [
                      for (final aspectRatio in ImageAspectRatioPreset.values)
                        DropdownMenuItem(
                          value: aspectRatio,
                          child: Text(aspectRatio.label),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _defaultAspectRatio = value);
                      }
                    },
                  );
              final sizeField = DropdownButtonFormField<ImageSizePreset>(
                initialValue: _defaultSize,
                decoration: const InputDecoration(labelText: '默认尺寸档位'),
                items: [
                  for (final size in ImageSizePreset.values)
                    DropdownMenuItem(value: size, child: Text(size.label)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _defaultSize = value);
                  }
                },
              );
              final qualityField = DropdownButtonFormField<ImageQualityPreset>(
                initialValue: _defaultQuality,
                decoration: const InputDecoration(labelText: '默认质量'),
                items: [
                  for (final quality in ImageQualityPreset.values)
                    DropdownMenuItem(
                      value: quality,
                      child: Text(quality.label),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _defaultQuality = value);
                  }
                },
              );
              final formatField = DropdownButtonFormField<ImageResponseFormat>(
                initialValue: _defaultResponseFormat,
                decoration: const InputDecoration(labelText: '响应格式'),
                items: const [
                  DropdownMenuItem(
                    value: ImageResponseFormat.url,
                    child: Text('url'),
                  ),
                  DropdownMenuItem(
                    value: ImageResponseFormat.b64Json,
                    child: Text('b64_json'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _defaultResponseFormat = value);
                  }
                },
              );

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
                    const SizedBox(height: 12),
                    Row(children: [Expanded(child: kindField)]),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: aspectRatioField),
                        const SizedBox(width: 12),
                        Expanded(child: sizeField),
                        if (_providerKind != ImageProviderKind.grok) ...[
                          const SizedBox(width: 12),
                          Expanded(child: qualityField),
                        ],
                      ],
                    ),
                    if (_providerKind != ImageProviderKind.grok) ...[
                      const SizedBox(height: 12),
                      Row(children: [Expanded(child: formatField)]),
                    ],
                    const SizedBox(height: 12),
                    modelsField,
                  ] else ...[
                    nameField,
                    const SizedBox(height: 12),
                    modelField,
                    const SizedBox(height: 12),
                    baseUrlField,
                    const SizedBox(height: 12),
                    apiKeyField,
                    const SizedBox(height: 12),
                    kindField,
                    const SizedBox(height: 12),
                    aspectRatioField,
                    const SizedBox(height: 12),
                    sizeField,
                    if (_providerKind != ImageProviderKind.grok) ...[
                      const SizedBox(height: 12),
                      qualityField,
                      const SizedBox(height: 12),
                      formatField,
                    ],
                    const SizedBox(height: 12),
                    modelsField,
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
                      title: const Text('启用图像 Provider'),
                      subtitle: const Text('停用后不参与未来正式生成选择，但详情页仍可测试。'),
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
                    '连接测试会消耗一次样例生图额度；样例固定使用 1:1 + 1K；完整 API Key 不会在界面中展示。',
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
        .read(imageProviderConfigControllerProvider.notifier)
        .save(
          id: widget.provider?.id,
          input: ImageProviderConfigInput(
            name: _nameController.text,
            baseUrl: _baseUrlController.text,
            apiKey: _apiKeyController.text,
            defaultModel: _modelController.text,
            providerKind: _providerKind,
            modelNames: _parseModelNames(_modelsController.text),
            defaultAspectRatio: _defaultAspectRatio,
            defaultSize: _defaultSize,
            defaultQuality: _providerKind == ImageProviderKind.grok
                ? ImageQualityPreset.auto
                : _defaultQuality,
            defaultResponseFormat: _providerKind == ImageProviderKind.grok
                ? ImageResponseFormat.url
                : _defaultResponseFormat,
            isEnabled: _isEnabled,
          ),
        );

    if (mounted && !ref.read(imageProviderConfigControllerProvider).hasError) {
      Navigator.of(context).pop();
    }
  }
}

void _showImageProviderDialog(
  BuildContext context, {
  ImageProviderConfig? provider,
}) {
  showGlassDialog<void>(
    context: context,
    maxWidth: 720,
    builder: (context) => _ImageProviderDialog(provider: provider),
  );
}

Future<void> _confirmDelete(
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

class _MonoPill extends StatelessWidget {
  const _MonoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelSmall?.copyWith(
            fontFamily: 'monospace',
            fontFamilyFallback: const ['Menlo', 'Courier'],
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
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

List<String> _parseModelNames(String value) {
  return value
      .split(RegExp(r'[\n,]'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

String _extractHost(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri != null && uri.host.isNotEmpty) {
    return uri.host + (uri.port != 80 && uri.port != 443 ? ':${uri.port}' : '');
  }
  return url;
}

Color _statusColor(ColorScheme colorScheme, ProviderTestStatus status) {
  return switch (status) {
    ProviderTestStatus.untested => colorScheme.onSurfaceVariant,
    ProviderTestStatus.testing => colorScheme.primary,
    ProviderTestStatus.succeeded => const Color(0xFF16825D),
    ProviderTestStatus.failed => colorScheme.error,
  };
}
