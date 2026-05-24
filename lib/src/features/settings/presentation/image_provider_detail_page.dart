import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/image_generation/domain/image_generation_request.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/persona_page.dart';
import '../application/image_provider_config_providers.dart';
import '../domain/image_provider_config.dart';
import '../domain/provider_config.dart';

class ImageProviderDetailPage extends ConsumerWidget {
  const ImageProviderDetailPage({required this.providerId, super.key});

  final String providerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(imageProviderConfigProvider(providerId));

    return provider.when(
      data: (item) {
        if (item == null) {
          return PersonaPage(
            eyebrow: 'Image Provider',
            title: '图像 Provider 不存在',
            description: '该图像 Provider 可能已被删除，返回设置页重新选择配置。',
            actions: [
              OutlinedButton.icon(
                onPressed: () => context.go('/settings'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('返回设置'),
              ),
            ],
            children: const [
              PersonaPanel(child: Text('没有找到对应的图像 Provider 配置。')),
            ],
          );
        }

        return _ImageProviderDetailContent(provider: item);
      },
      loading: () => PersonaPage(
        eyebrow: 'Image Provider',
        title: '加载中',
        description: '正在读取图像 Provider 配置。',
        children: const [PersonaPanel(child: LinearProgressIndicator())],
      ),
      error: (error, stackTrace) => PersonaPage(
        eyebrow: 'Image Provider',
        title: '加载失败',
        description: '无法读取图像 Provider 配置。',
        actions: [
          OutlinedButton.icon(
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.arrow_back),
            label: const Text('返回设置'),
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

class _ImageProviderDetailContent extends ConsumerStatefulWidget {
  const _ImageProviderDetailContent({required this.provider});

  final ImageProviderConfig provider;

  @override
  ConsumerState<_ImageProviderDetailContent> createState() =>
      _ImageProviderDetailContentState();
}

class _ImageProviderDetailContentState
    extends ConsumerState<_ImageProviderDetailContent> {
  late final TextEditingController _promptController;
  String? _selectedModelName;
  late ImageAspectRatioPreset _selectedAspectRatio;
  late ImageSizePreset _selectedSize;
  late ImageQualityPreset _selectedQuality;
  late ImageResponseFormat _selectedResponseFormat;
  ImageGenerationResult? _lastResult;
  _ActualImageRequest? _lastRequest;
  String? _errorMessage;
  var _isGenerating = false;

  String get _resolvedModelName {
    final modelNames = _normalizedModelNames(widget.provider);
    final selected = _selectedModelName?.trim();
    if (selected != null &&
        selected.isNotEmpty &&
        modelNames.contains(selected)) {
      return selected;
    }
    if (modelNames.isNotEmpty) {
      return modelNames.first;
    }
    return widget.provider.defaultModel.trim();
  }

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController(text: imageProviderSamplePrompt);
    _selectedModelName = _initialModelName(widget.provider);
    _selectedAspectRatio = widget.provider.defaultAspectRatio;
    _selectedSize = widget.provider.defaultSize;
    _selectedQuality = widget.provider.defaultQuality;
    _selectedResponseFormat = widget.provider.defaultResponseFormat;
  }

  @override
  void didUpdateWidget(covariant _ImageProviderDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider.id != widget.provider.id) {
      _promptController.text = imageProviderSamplePrompt;
      _selectedModelName = _initialModelName(widget.provider);
      _selectedAspectRatio = widget.provider.defaultAspectRatio;
      _selectedSize = widget.provider.defaultSize;
      _selectedQuality = widget.provider.defaultQuality;
      _selectedResponseFormat = widget.provider.defaultResponseFormat;
      _lastResult = null;
      _lastRequest = null;
      _errorMessage = null;
      _isGenerating = false;
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;

    return PersonaPage(
      eyebrow: 'Image Provider',
      title: provider.name,
      description:
          '${provider.baseUrl} · ${provider.defaultModel} · ${provider.defaultAspectRatio.label} · ${provider.defaultSize.label}',
      actions: [
        OutlinedButton.icon(
          onPressed: () => context.go('/settings'),
          icon: const Icon(Icons.arrow_back),
          label: const Text('返回设置'),
        ),
      ],
      children: [
        _ImageProviderCommandBar(provider: provider),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final workbench = _ImageGenerationWorkbench(
              provider: provider,
              promptController: _promptController,
              selectedModelName: _resolvedModelName,
              selectedAspectRatio: _selectedAspectRatio,
              selectedSize: _selectedSize,
              selectedQuality: _selectedQuality,
              selectedResponseFormat: _selectedResponseFormat,
              isGenerating: _isGenerating,
              result: _lastResult,
              errorMessage: _errorMessage,
              onGenerate: _generate,
              onClear: _clear,
            );
            final inspector = _ImageGenerationInspector(
              provider: provider,
              selectedModelName: _resolvedModelName,
              selectedAspectRatio: _selectedAspectRatio,
              selectedSize: _selectedSize,
              selectedQuality: _selectedQuality,
              selectedResponseFormat: _selectedResponseFormat,
              actualRequest: _lastRequest,
              result: _lastResult,
              isGenerating: _isGenerating,
              onModelSelected: (value) {
                setState(() => _selectedModelName = value);
              },
              onAspectRatioChanged: (value) {
                setState(() => _selectedAspectRatio = value);
              },
              onSizeChanged: (value) {
                setState(() => _selectedSize = value);
              },
              onQualityChanged: (value) {
                setState(() => _selectedQuality = value);
              },
              onResponseFormatChanged: (value) {
                setState(() => _selectedResponseFormat = value);
              },
            );

            if (constraints.maxWidth < 980) {
              return Column(
                children: [workbench, const SizedBox(height: 16), inspector],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: workbench),
                const SizedBox(width: 16),
                SizedBox(width: 410, child: inspector),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _generate() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty || _isGenerating) {
      return;
    }
    final modelName = _resolvedModelName;
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _lastRequest = _ActualImageRequest(
        endpoint: _generationEndpoint(widget.provider.baseUrl),
        model: modelName,
        prompt: prompt,
        size: resolveImageRequestSize(
          aspectRatio: _selectedAspectRatio,
          size: _selectedSize,
        ),
        quality: _selectedQuality.quality,
        responseFormat: _responseFormatValue(_selectedResponseFormat),
        n: 1,
      );
    });

    try {
      final result = await ref
          .read(imageGenerationServiceProvider)
          .generateImage(
            provider: widget.provider,
            prompt: prompt,
            modelName: modelName,
            aspectRatio: _selectedAspectRatio,
            size: _selectedSize,
            quality: _selectedQuality,
            responseFormat: _selectedResponseFormat,
          );
      if (!mounted) return;
      setState(() {
        _lastResult = result;
        _isGenerating = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isGenerating = false;
      });
    }
  }

  void _clear() {
    setState(() {
      _lastResult = null;
      _lastRequest = null;
      _errorMessage = null;
    });
  }
}

class _ImageProviderCommandBar extends StatelessWidget {
  const _ImageProviderCommandBar({required this.provider});

  final ImageProviderConfig provider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(colorScheme, provider.testStatus);

    return PersonaPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          PersonaStatusPill(
            label: provider.isEnabled ? '未来正式生成可选' : '已停用 · 仍可测试',
            icon: provider.isEnabled
                ? Icons.check_circle_outline
                : Icons.pause_circle_outline,
            color: provider.isEnabled
                ? const Color(0xFF16825D)
                : colorScheme.onSurfaceVariant,
          ),
          PersonaStatusPill(
            label: _statusLabel(provider.testStatus),
            icon: _statusIcon(provider.testStatus),
            color: statusColor,
          ),
          PersonaStatusPill(
            label: 'Bearer auth',
            icon: Icons.key_outlined,
            color: colorScheme.primary,
          ),
          PersonaStatusPill(
            label:
                '${provider.defaultAspectRatio.label} · ${provider.defaultSize.label} · ${provider.defaultQuality.label}',
            icon: Icons.aspect_ratio_outlined,
          ),
        ],
      ),
    );
  }
}

class _ImageGenerationWorkbench extends StatelessWidget {
  const _ImageGenerationWorkbench({
    required this.provider,
    required this.promptController,
    required this.selectedModelName,
    required this.selectedAspectRatio,
    required this.selectedSize,
    required this.selectedQuality,
    required this.selectedResponseFormat,
    required this.isGenerating,
    required this.onGenerate,
    required this.onClear,
    this.result,
    this.errorMessage,
  });

  final ImageProviderConfig provider;
  final TextEditingController promptController;
  final String selectedModelName;
  final ImageAspectRatioPreset selectedAspectRatio;
  final ImageSizePreset selectedSize;
  final ImageQualityPreset selectedQuality;
  final ImageResponseFormat selectedResponseFormat;
  final bool isGenerating;
  final ImageGenerationResult? result;
  final String? errorMessage;
  final VoidCallback onGenerate;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PersonaPanel(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 760,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
              child: PersonaSectionHeader(
                title: '文生图测试',
                description:
                    '$selectedModelName · ${selectedAspectRatio.label} · ${selectedSize.label} · ${selectedQuality.label}',
                trailing: isGenerating
                    ? PersonaStatusPill(
                        label: '生成中',
                        icon: Icons.sync,
                        color: colorScheme.primary,
                      )
                    : null,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: _ImagePreviewSurface(
                  result: result,
                  isGenerating: isGenerating,
                ),
              ),
            ),
            if (errorMessage != null) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: colorScheme.error,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  TextField(
                    controller: promptController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Prompt',
                      hintText: '输入用于测试的文生图 Prompt。',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: result == null && errorMessage == null
                            ? null
                            : onClear,
                        icon: const Icon(Icons.delete_sweep_outlined),
                        label: const Text('清空'),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: isGenerating ? null : onGenerate,
                        icon: isGenerating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.auto_awesome_outlined),
                        label: Text(isGenerating ? '生成中' : '生成测试'),
                      ),
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

class _ImagePreviewSurface extends StatelessWidget {
  const _ImagePreviewSurface({required this.isGenerating, this.result});

  final ImageGenerationResult? result;
  final bool isGenerating;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final images = result?.images;
    final image = images == null || images.isEmpty ? null : images.first;

    if (isGenerating) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 14),
            Text('正在生成样例图片', style: textTheme.titleSmall),
          ],
        ),
      );
    }

    if (image == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              color: colorScheme.onSurfaceVariant,
              size: 38,
            ),
            const SizedBox(height: 12),
            Text('生成后图片会在这里预览', style: textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              '预览仅保存在当前页面内存中，离开页面后消失。',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    final b64 = image.b64Json;
    final url = image.url;
    Widget imageWidget;
    if (b64 != null && b64.trim().isNotEmpty) {
      imageWidget = Image.memory(
        _decodeImageBytes(b64),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            _BrokenImage(message: '无法解码 b64_json 图片。'),
      );
    } else if (url != null && url.trim().isNotEmpty) {
      imageWidget = Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const _BrokenImage(message: '无法加载远程图片。'),
      );
    } else {
      imageWidget = const _BrokenImage(message: '响应没有可显示图片。');
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(kPanelRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Center(child: imageWidget),
      ),
    );
  }
}

class _BrokenImage extends StatelessWidget {
  const _BrokenImage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Text(
        message,
        style: TextStyle(color: colorScheme.error),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ImageGenerationInspector extends StatefulWidget {
  const _ImageGenerationInspector({
    required this.provider,
    required this.selectedModelName,
    required this.selectedAspectRatio,
    required this.selectedSize,
    required this.selectedQuality,
    required this.selectedResponseFormat,
    required this.isGenerating,
    required this.onModelSelected,
    required this.onAspectRatioChanged,
    required this.onSizeChanged,
    required this.onQualityChanged,
    required this.onResponseFormatChanged,
    this.actualRequest,
    this.result,
  });

  final ImageProviderConfig provider;
  final String selectedModelName;
  final ImageAspectRatioPreset selectedAspectRatio;
  final ImageSizePreset selectedSize;
  final ImageQualityPreset selectedQuality;
  final ImageResponseFormat selectedResponseFormat;
  final bool isGenerating;
  final ValueChanged<String> onModelSelected;
  final ValueChanged<ImageAspectRatioPreset> onAspectRatioChanged;
  final ValueChanged<ImageSizePreset> onSizeChanged;
  final ValueChanged<ImageQualityPreset> onQualityChanged;
  final ValueChanged<ImageResponseFormat> onResponseFormatChanged;
  final _ActualImageRequest? actualRequest;
  final ImageGenerationResult? result;

  @override
  State<_ImageGenerationInspector> createState() =>
      _ImageGenerationInspectorState();
}

class _ImageGenerationInspectorState extends State<_ImageGenerationInspector> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PersonaPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  icon: Icon(Icons.tune_outlined),
                  label: Text('参数'),
                ),
                ButtonSegment(
                  value: 1,
                  icon: Icon(Icons.receipt_long_outlined),
                  label: Text('请求'),
                ),
                ButtonSegment(
                  value: 2,
                  icon: Icon(Icons.data_object_outlined),
                  label: Text('响应'),
                ),
              ],
              selected: {_selectedIndex},
              onSelectionChanged: (value) {
                setState(() => _selectedIndex = value.single);
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: switch (_selectedIndex) {
              0 => _ImageParameterTab(
                provider: widget.provider,
                selectedModelName: widget.selectedModelName,
                selectedAspectRatio: widget.selectedAspectRatio,
                selectedSize: widget.selectedSize,
                selectedQuality: widget.selectedQuality,
                selectedResponseFormat: widget.selectedResponseFormat,
                isGenerating: widget.isGenerating,
                onModelSelected: widget.onModelSelected,
                onAspectRatioChanged: widget.onAspectRatioChanged,
                onSizeChanged: widget.onSizeChanged,
                onQualityChanged: widget.onQualityChanged,
                onResponseFormatChanged: widget.onResponseFormatChanged,
              ),
              1 => _ImageRequestTab(actualRequest: widget.actualRequest),
              _ => _ImageResponseTab(result: widget.result),
            },
          ),
        ],
      ),
    );
  }
}

class _ImageParameterTab extends StatelessWidget {
  const _ImageParameterTab({
    required this.provider,
    required this.selectedModelName,
    required this.selectedAspectRatio,
    required this.selectedSize,
    required this.selectedQuality,
    required this.selectedResponseFormat,
    required this.isGenerating,
    required this.onModelSelected,
    required this.onAspectRatioChanged,
    required this.onSizeChanged,
    required this.onQualityChanged,
    required this.onResponseFormatChanged,
  });

  final ImageProviderConfig provider;
  final String selectedModelName;
  final ImageAspectRatioPreset selectedAspectRatio;
  final ImageSizePreset selectedSize;
  final ImageQualityPreset selectedQuality;
  final ImageResponseFormat selectedResponseFormat;
  final bool isGenerating;
  final ValueChanged<String> onModelSelected;
  final ValueChanged<ImageAspectRatioPreset> onAspectRatioChanged;
  final ValueChanged<ImageSizePreset> onSizeChanged;
  final ValueChanged<ImageQualityPreset> onQualityChanged;
  final ValueChanged<ImageResponseFormat> onResponseFormatChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final modelNames = _normalizedModelNames(provider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PersonaSectionHeader(
          title: '测试参数',
          description: '只影响当前页面的文生图测试。',
          trailing: PersonaStatusPill(
            label: isGenerating ? '锁定中' : '可调整',
            icon: Icons.tune_outlined,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: selectedModelName,
          items: [
            for (final modelName in modelNames)
              DropdownMenuItem(
                value: modelName,
                child: Text(modelName, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: isGenerating
              ? null
              : (value) {
                  if (value != null) onModelSelected(value);
                },
          decoration: const InputDecoration(
            labelText: 'Model',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<ImageAspectRatioPreset>(
          initialValue: selectedAspectRatio,
          items: [
            for (final aspectRatio in ImageAspectRatioPreset.values)
              DropdownMenuItem(
                value: aspectRatio,
                child: Text(aspectRatio.label),
              ),
          ],
          onChanged: isGenerating
              ? null
              : (value) {
                  if (value != null) onAspectRatioChanged(value);
                },
          decoration: const InputDecoration(
            labelText: 'Aspect ratio',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<ImageSizePreset>(
          initialValue: selectedSize,
          items: [
            for (final size in ImageSizePreset.values)
              DropdownMenuItem(value: size, child: Text(size.label)),
          ],
          onChanged: isGenerating
              ? null
              : (value) {
                  if (value != null) onSizeChanged(value);
                },
          decoration: const InputDecoration(
            labelText: 'Size tier',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<ImageQualityPreset>(
          initialValue: selectedQuality,
          items: [
            for (final quality in ImageQualityPreset.values)
              DropdownMenuItem(value: quality, child: Text(quality.label)),
          ],
          onChanged: isGenerating
              ? null
              : (value) {
                  if (value != null) onQualityChanged(value);
                },
          decoration: const InputDecoration(
            labelText: 'Quality',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<ImageResponseFormat>(
          initialValue: selectedResponseFormat,
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
          onChanged: isGenerating
              ? null
              : (value) {
                  if (value != null) onResponseFormatChanged(value);
                },
          decoration: const InputDecoration(
            labelText: 'Response format',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Text('n 固定为 1；style、user 当前不发送。', style: textTheme.bodyMedium),
      ],
    );
  }
}

class _ImageRequestTab extends StatelessWidget {
  const _ImageRequestTab({required this.actualRequest});

  final _ActualImageRequest? actualRequest;

  @override
  Widget build(BuildContext context) {
    final request = actualRequest;
    if (request == null) {
      return Text(
        '发送测试后显示最终请求；不会展示 API Key。',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PersonaSectionHeader(
          title: 'Actual Request',
          description: '展示最终参数；不会展示 API Key。',
        ),
        const SizedBox(height: 12),
        _MetaLine(label: 'endpoint', value: request.endpoint),
        _MetaLine(label: 'model', value: request.model),
        _MetaLine(label: 'size', value: request.size),
        _MetaLine(label: 'quality', value: request.quality),
        _MetaLine(label: 'response_format', value: request.responseFormat),
        _MetaLine(label: 'n', value: request.n.toString()),
        const SizedBox(height: 12),
        Text('prompt', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        _CodeBlock(text: request.prompt),
      ],
    );
  }
}

class _ImageResponseTab extends StatelessWidget {
  const _ImageResponseTab({required this.result});

  final ImageGenerationResult? result;

  @override
  Widget build(BuildContext context) {
    final result = this.result;
    if (result == null) {
      return Text(
        '生成成功后显示响应摘要。',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    final image = result.images.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PersonaSectionHeader(
          title: 'Response',
          description: '图片数据只保存在当前页面内存中。',
        ),
        const SizedBox(height: 12),
        if (result.created != null)
          _MetaLine(label: 'created', value: result.created.toString()),
        _MetaLine(label: 'images', value: result.images.length.toString()),
        if (image.url != null)
          _MetaLine(label: 'url', value: image.url!, selectable: true),
        if (image.b64Json != null)
          _MetaLine(label: 'b64_json', value: '${image.b64Json!.length} chars'),
        if (image.revisedPrompt != null) ...[
          const SizedBox(height: 12),
          Text(
            'revised_prompt',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          _CodeBlock(text: image.revisedPrompt!),
        ],
        if (result.usage != null) ...[
          const SizedBox(height: 12),
          Text('usage', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          _CodeBlock(
            text: const JsonEncoder.withIndent('  ').convert(result.usage),
          ),
        ],
      ],
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.label,
    required this.value,
    this.selectable = false,
  });

  final String label;
  final String value;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: selectable
                ? SelectableText(value, style: textTheme.bodySmall)
                : Text(
                    value,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall,
                  ),
          ),
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SelectableText(
          text,
          style: textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            fontFamilyFallback: const ['Menlo', 'Courier'],
          ),
        ),
      ),
    );
  }
}

class _ActualImageRequest {
  const _ActualImageRequest({
    required this.endpoint,
    required this.model,
    required this.prompt,
    required this.size,
    required this.quality,
    required this.responseFormat,
    required this.n,
  });

  final String endpoint;
  final String model;
  final String prompt;
  final String size;
  final String quality;
  final String responseFormat;
  final int n;
}

List<String> _normalizedModelNames(ImageProviderConfig provider) {
  final seen = <String>{};
  final modelNames = <String>[];

  void add(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || !seen.add(trimmed)) {
      return;
    }
    modelNames.add(trimmed);
  }

  add(provider.defaultModel);
  for (final modelName in provider.modelNames) {
    add(modelName);
  }

  return modelNames;
}

String _initialModelName(ImageProviderConfig provider) {
  final modelNames = _normalizedModelNames(provider);
  if (modelNames.isNotEmpty) {
    return modelNames.first;
  }
  return provider.defaultModel.trim();
}

String _generationEndpoint(String baseUrl) {
  final trimmed = baseUrl.trim();
  final withoutTrailingSlash = trimmed.endsWith('/')
      ? trimmed.substring(0, trimmed.length - 1)
      : trimmed;
  final normalized = withoutTrailingSlash.endsWith('/v1')
      ? withoutTrailingSlash
      : '$withoutTrailingSlash/v1';
  return '$normalized/images/generations';
}

String _responseFormatValue(ImageResponseFormat format) {
  return switch (format) {
    ImageResponseFormat.url => 'url',
    ImageResponseFormat.b64Json => 'b64_json',
  };
}

Uint8List _decodeImageBytes(String b64Json) {
  final normalized = b64Json.contains(',')
      ? b64Json.substring(b64Json.indexOf(',') + 1)
      : b64Json;
  return base64Decode(normalized);
}

Color _statusColor(ColorScheme colorScheme, ProviderTestStatus status) {
  return switch (status) {
    ProviderTestStatus.untested => colorScheme.onSurfaceVariant,
    ProviderTestStatus.testing => colorScheme.primary,
    ProviderTestStatus.succeeded => const Color(0xFF16825D),
    ProviderTestStatus.failed => colorScheme.error,
  };
}

String _statusLabel(ProviderTestStatus status) {
  return switch (status) {
    ProviderTestStatus.untested => '未测试',
    ProviderTestStatus.testing => '测试中',
    ProviderTestStatus.succeeded => '连接可用',
    ProviderTestStatus.failed => '测试失败',
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
