import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/glass_container.dart';
import '../../application/image_provider_config_providers.dart';
import '../../application/provider_config_providers.dart';
import '../../domain/image_provider_config.dart';
import '../../domain/provider_config.dart';
import 'persona_form_utils.dart';

enum ProviderType { llm, image }

void showProviderDialog(
  BuildContext context, {
  required ProviderType type,
  ProviderConfig? llmProvider,
  ImageProviderConfig? imageProvider,
}) {
  showGlassDialog<void>(
    context: context,
    maxWidth: 720,
    builder: (context) => ProviderDialog(
      type: type,
      llmProvider: llmProvider,
      imageProvider: imageProvider,
    ),
  );
}

class ProviderDialog extends ConsumerStatefulWidget {
  const ProviderDialog({
    required this.type,
    this.llmProvider,
    this.imageProvider,
    super.key,
  });

  final ProviderType type;
  final ProviderConfig? llmProvider;
  final ImageProviderConfig? imageProvider;

  @override
  ConsumerState<ProviderDialog> createState() => _ProviderDialogState();
}

class _ProviderDialogState extends ConsumerState<ProviderDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _baseUrlController;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _modelController;
  late final TextEditingController _modelsController;
  late bool _isEnabled;
  var _isApiKeyVisible = false;

  // Image-specific state
  late ImageAspectRatioPreset _defaultAspectRatio;
  late ImageSizePreset _defaultSize;
  late ImageQualityPreset _defaultQuality;
  late ImageResponseFormat _defaultResponseFormat;

  bool get _isImage => widget.type == ProviderType.image;

  @override
  void initState() {
    super.initState();
    if (_isImage) {
      final p = widget.imageProvider;
      _nameController = TextEditingController(text: p?.name ?? '');
      _baseUrlController = TextEditingController(text: p?.baseUrl ?? '');
      _apiKeyController = TextEditingController(text: p?.apiKey ?? '');
      _modelController = TextEditingController(
        text: p?.defaultModel ?? 'gpt-5-3',
      );
      _modelsController = TextEditingController(
        text: (p?.modelNames ?? const <String>[]).join('\n'),
      );
      _isEnabled = p?.isEnabled ?? true;
      _defaultAspectRatio =
          p?.defaultAspectRatio ?? ImageAspectRatioPreset.square;
      _defaultSize = p?.defaultSize ?? ImageSizePreset.oneK;
      _defaultQuality = p?.defaultQuality ?? ImageQualityPreset.auto;
      _defaultResponseFormat =
          p?.defaultResponseFormat ?? ImageResponseFormat.url;
    } else {
      final p = widget.llmProvider;
      _nameController = TextEditingController(text: p?.name ?? '');
      _baseUrlController = TextEditingController(text: p?.baseUrl ?? '');
      _apiKeyController = TextEditingController(text: p?.apiKey ?? '');
      _modelController = TextEditingController(
        text: p?.defaultModel ?? '',
      );
      _modelsController = TextEditingController(
        text: (p?.modelNames ?? const <String>[]).join('\n'),
      );
      _isEnabled = p?.isEnabled ?? true;
      _defaultAspectRatio = ImageAspectRatioPreset.square;
      _defaultSize = ImageSizePreset.oneK;
      _defaultQuality = ImageQualityPreset.auto;
      _defaultResponseFormat = ImageResponseFormat.url;
    }
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
    final state = _isImage
        ? ref.watch(imageProviderConfigControllerProvider)
        : ref.watch(providerConfigControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isNew = _isImage
        ? widget.imageProvider == null
        : widget.llmProvider == null;

    ref.listen(
      _isImage
          ? imageProviderConfigControllerProvider
          : providerConfigControllerProvider,
      (previous, next) {
        if (next.hasError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('保存失败：${next.error}')));
        }
      },
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isNew
              ? (_isImage ? '新增图像 Provider' : '新增 Provider')
              : (_isImage ? '编辑图像 Provider' : '编辑 Provider'),
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          _isImage
              ? '配置 Bearer 生图连接。API Key 只保存在本地 SQLite 中。'
              : '配置 OpenAI-compatible 连接。API Key 只保存在本地 SQLite 中。',
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
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFields(isWide),
                  const SizedBox(height: 14),
                  _buildEnabledSwitch(colorScheme),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        _buildInfoCard(colorScheme, textTheme),
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

  Widget _buildFields(bool isWide) {
    final nameField = TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(labelText: '名称'),
      validator: requiredValidator,
    );
    final modelField = TextFormField(
      controller: _modelController,
      decoration: InputDecoration(
        labelText: '默认模型',
        hintText: _isImage ? 'gpt-5-3' : 'gpt-4.1-mini',
      ),
      validator: requiredValidator,
    );
    final baseUrlField = TextFormField(
      controller: _baseUrlController,
      decoration: InputDecoration(
        labelText: 'Base URL',
        hintText: _isImage ? 'https://example.com' : 'https://api.openai.com/v1',
      ),
      keyboardType: TextInputType.url,
      validator: urlValidator,
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
      validator: requiredValidator,
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

    if (!_isImage) {
      return _buildLlmFields(
        isWide: isWide,
        nameField: nameField,
        modelField: modelField,
        baseUrlField: baseUrlField,
        apiKeyField: apiKeyField,
        modelsField: modelsField,
      );
    }
    return _buildImageFields(
      isWide: isWide,
      nameField: nameField,
      modelField: modelField,
      baseUrlField: baseUrlField,
      apiKeyField: apiKeyField,
      modelsField: modelsField,
    );
  }

  Widget _buildLlmFields({
    required bool isWide,
    required Widget nameField,
    required Widget modelField,
    required Widget baseUrlField,
    required Widget apiKeyField,
    required Widget modelsField,
  }) {
    if (isWide) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          modelsField,
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        nameField,
        const SizedBox(height: 12),
        modelField,
        const SizedBox(height: 12),
        baseUrlField,
        const SizedBox(height: 12),
        apiKeyField,
        const SizedBox(height: 12),
        modelsField,
      ],
    );
  }

  Widget _buildImageFields({
    required bool isWide,
    required Widget nameField,
    required Widget modelField,
    required Widget baseUrlField,
    required Widget apiKeyField,
    required Widget modelsField,
  }) {
    final aspectRatioField = DropdownButtonFormField<ImageAspectRatioPreset>(
      initialValue: _defaultAspectRatio,
      decoration: const InputDecoration(labelText: '默认画幅'),
      items: [
        for (final ar in ImageAspectRatioPreset.values)
          DropdownMenuItem(value: ar, child: Text(ar.label)),
      ],
      onChanged: (value) {
        if (value != null) setState(() => _defaultAspectRatio = value);
      },
    );
    final sizeField = DropdownButtonFormField<ImageSizePreset>(
      initialValue: _defaultSize,
      decoration: const InputDecoration(labelText: '默认尺寸档位'),
      items: [
        for (final sz in ImageSizePreset.values)
          DropdownMenuItem(value: sz, child: Text(sz.label)),
      ],
      onChanged: (value) {
        if (value != null) setState(() => _defaultSize = value);
      },
    );
    final qualityField = DropdownButtonFormField<ImageQualityPreset>(
      initialValue: _defaultQuality,
      decoration: const InputDecoration(labelText: '默认质量'),
      items: [
        for (final q in ImageQualityPreset.values)
          DropdownMenuItem(value: q, child: Text(q.label)),
      ],
      onChanged: (value) {
        if (value != null) setState(() => _defaultQuality = value);
      },
    );
    final formatField = DropdownButtonFormField<ImageResponseFormat>(
      initialValue: _defaultResponseFormat,
      decoration: const InputDecoration(labelText: '响应格式'),
      items: const [
        DropdownMenuItem(value: ImageResponseFormat.url, child: Text('url')),
        DropdownMenuItem(
          value: ImageResponseFormat.b64Json,
          child: Text('b64_json'),
        ),
      ],
      onChanged: (value) {
        if (value != null) setState(() => _defaultResponseFormat = value);
      },
    );

    if (isWide) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          Row(
            children: [
              Expanded(child: aspectRatioField),
              const SizedBox(width: 12),
              Expanded(child: sizeField),
              const SizedBox(width: 12),
              Expanded(child: qualityField),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: [Expanded(child: formatField)]),
          const SizedBox(height: 12),
          modelsField,
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        nameField,
        const SizedBox(height: 12),
        modelField,
        const SizedBox(height: 12),
        baseUrlField,
        const SizedBox(height: 12),
        apiKeyField,
        const SizedBox(height: 12),
        aspectRatioField,
        const SizedBox(height: 12),
        sizeField,
        const SizedBox(height: 12),
        qualityField,
        const SizedBox(height: 12),
        formatField,
        const SizedBox(height: 12),
        modelsField,
      ],
    );
  }

  Widget _buildEnabledSwitch(ColorScheme colorScheme) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 2,
        ),
        title: Text(_isImage ? '启用图像 Provider' : '启用 Provider'),
        subtitle: Text(
          _isImage
              ? '停用后不参与未来正式生成选择，但详情页仍可测试。'
              : '停用后不参与正式生成选择，但详情页仍可测试。',
        ),
        value: _isEnabled,
        onChanged: (value) => setState(() => _isEnabled = value),
      ),
    );
  }

  Widget _buildInfoCard(ColorScheme colorScheme, TextTheme textTheme) {
    return DecoratedBox(
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
            Icon(Icons.shield_outlined, color: colorScheme.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _isImage
                    ? '连接测试会消耗一次样例生图额度；样例固定使用 1:1 + 1K；完整 API Key 不会在界面中展示。'
                    : '保存后连接测试状态会按现有规则重置，完整密钥不会在界面中展示。',
                style: textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isImage) {
      await ref
          .read(imageProviderConfigControllerProvider.notifier)
          .save(
            id: widget.imageProvider?.id,
            input: ImageProviderConfigInput(
              name: _nameController.text,
              baseUrl: _baseUrlController.text,
              apiKey: _apiKeyController.text,
              defaultModel: _modelController.text,
              modelNames: parseModelNames(_modelsController.text),
              defaultAspectRatio: _defaultAspectRatio,
              defaultSize: _defaultSize,
              defaultQuality: _defaultQuality,
              defaultResponseFormat: _defaultResponseFormat,
              isEnabled: _isEnabled,
            ),
          );
      if (mounted &&
          !ref.read(imageProviderConfigControllerProvider).hasError) {
        Navigator.of(context).pop();
      }
    } else {
      await ref
          .read(providerConfigControllerProvider.notifier)
          .save(
            id: widget.llmProvider?.id,
            input: ProviderConfigInput(
              name: _nameController.text,
              baseUrl: _baseUrlController.text,
              apiKey: _apiKeyController.text,
              defaultModel: _modelController.text,
              modelNames: parseModelNames(_modelsController.text),
              systemPrompt: widget.llmProvider?.systemPrompt ?? '',
              isSystemPromptEnabled:
                  widget.llmProvider?.isSystemPromptEnabled ?? true,
              isEnabled: _isEnabled,
            ),
          );
      if (mounted && !ref.read(providerConfigControllerProvider).hasError) {
        Navigator.of(context).pop();
      }
    }
  }
}
