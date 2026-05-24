import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/image_generation/domain/image_generation_request.dart';
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
  bool _sidebarExpanded = true;

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
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(colorScheme, provider.testStatus);

    return PersonaPage(
      eyebrow: 'Image Provider',
      title: provider.name,
      description:
          '${provider.baseUrl} · ${provider.defaultModel} · Bearer auth',
      actions: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 400;
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!isCompact) ...[
                  _HeaderStatusBadge(
                    label: _statusLabel(provider.testStatus),
                    icon: _statusIcon(provider.testStatus),
                    color: statusColor,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '启用',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    height: 24,
                    child: Material(
                      color: Colors.transparent,
                      child: Switch(
                        value: provider.isEnabled,
                        onChanged: null,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                OutlinedButton.icon(
                  onPressed: () => context.go('/settings'),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('返回设置'),
                ),
              ],
            );
          },
        ),
      ],
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final viewHeight = MediaQuery.of(context).size.height;
            final panelHeight = (viewHeight - 220).clamp(480.0, 900.0);

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
              sidebarExpanded: _sidebarExpanded,
              modelNames: _normalizedModelNames(provider),
              onGenerate: _generate,
              onClear: _clear,
              onToggleSidebar: () {
                setState(() => _sidebarExpanded = !_sidebarExpanded);
              },
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
              return SizedBox(
                height: panelHeight,
                child: Column(
                  children: [
                    Expanded(child: workbench),
                    const SizedBox(height: 16),
                    Expanded(child: inspector),
                  ],
                ),
              );
            }

            return SizedBox(
              height: panelHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: workbench),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    width: _sidebarExpanded ? 410 : 0,
                    child: _sidebarExpanded
                        ? Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: inspector,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
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

// ---------------------------------------------------------------------------
// Header badge
// ---------------------------------------------------------------------------

class _HeaderStatusBadge extends StatelessWidget {
  const _HeaderStatusBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.26)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Image Generation Workbench
// ---------------------------------------------------------------------------

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
    required this.sidebarExpanded,
    required this.modelNames,
    required this.onToggleSidebar,
    required this.onModelSelected,
    required this.onAspectRatioChanged,
    required this.onSizeChanged,
    required this.onQualityChanged,
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
  final bool sidebarExpanded;
  final List<String> modelNames;
  final VoidCallback onToggleSidebar;
  final ValueChanged<String> onModelSelected;
  final ValueChanged<ImageAspectRatioPreset> onAspectRatioChanged;
  final ValueChanged<ImageSizePreset> onSizeChanged;
  final ValueChanged<ImageQualityPreset> onQualityChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PersonaPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '文生图测试',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$selectedModelName · ${selectedAspectRatio.label} · ${selectedSize.label}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isGenerating)
                  PersonaStatusPill(
                    label: '生成中',
                    icon: Icons.sync,
                    color: colorScheme.primary,
                  ),
              ],
            ),
          ),
          // Inline control bar
          _ImageInlineControlBar(
            selectedModelName: selectedModelName,
            modelNames: modelNames,
            sidebarExpanded: sidebarExpanded,
            isGenerating: isGenerating,
            onModelSelected: onModelSelected,
            onToggleSidebar: onToggleSidebar,
          ),
          // Parameter chips
          _ImageParameterChips(
            selectedAspectRatio: selectedAspectRatio,
            selectedSize: selectedSize,
            selectedQuality: selectedQuality,
            isGenerating: isGenerating,
            onAspectRatioChanged: onAspectRatioChanged,
            onSizeChanged: onSizeChanged,
            onQualityChanged: onQualityChanged,
          ),
          const Divider(height: 1),
          // Preview area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: _ImagePreviewSurface(
                result: result,
                isGenerating: isGenerating,
              ),
            ),
          ),
          // Error
          if (errorMessage != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.error.withValues(alpha: 0.3),
                  ),
                ),
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
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const Divider(height: 1),
          // Input
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                TextField(
                  controller: promptController,
                  minLines: 2,
                  maxLines: 4,
                  style: textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: '输入用于测试的文生图 Prompt。',
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: result == null && errorMessage == null
                          ? null
                          : onClear,
                      icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                      label: const Text('清空'),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: isGenerating ? null : onGenerate,
                      icon: isGenerating
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.auto_awesome_outlined, size: 16),
                      label: Text(isGenerating ? '生成中' : '生成测试'),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Image inline control bar
// ---------------------------------------------------------------------------

class _ImageInlineControlBar extends StatelessWidget {
  const _ImageInlineControlBar({
    required this.selectedModelName,
    required this.modelNames,
    required this.sidebarExpanded,
    required this.isGenerating,
    required this.onModelSelected,
    required this.onToggleSidebar,
  });

  final String selectedModelName;
  final List<String> modelNames;
  final bool sidebarExpanded;
  final bool isGenerating;
  final ValueChanged<String> onModelSelected;
  final VoidCallback onToggleSidebar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Text(
            'MODEL',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: DropdownButton<String>(
              value: selectedModelName,
              isDense: true,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              style: textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: colorScheme.onSurface,
              ),
              items: [
                for (final name in modelNames)
                  DropdownMenuItem(
                    value: name,
                    child: Text(name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: isGenerating
                  ? null
                  : (value) {
                      if (value != null) onModelSelected(value);
                    },
            ),
          ),
          const Spacer(),
          Tooltip(
            message: sidebarExpanded ? '收起 Inspector' : '展开 Inspector',
            child: InkWell(
              onTap: onToggleSidebar,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outlineVariant),
                  color: sidebarExpanded
                      ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                      : Colors.transparent,
                ),
                child: Icon(
                  sidebarExpanded
                      ? Icons.keyboard_double_arrow_right
                      : Icons.keyboard_double_arrow_left,
                  size: 16,
                  color: sidebarExpanded
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Image parameter chips
// ---------------------------------------------------------------------------

class _ImageParameterChips extends StatelessWidget {
  const _ImageParameterChips({
    required this.selectedAspectRatio,
    required this.selectedSize,
    required this.selectedQuality,
    required this.isGenerating,
    required this.onAspectRatioChanged,
    required this.onSizeChanged,
    required this.onQualityChanged,
  });

  final ImageAspectRatioPreset selectedAspectRatio;
  final ImageSizePreset selectedSize;
  final ImageQualityPreset selectedQuality;
  final bool isGenerating;
  final ValueChanged<ImageAspectRatioPreset> onAspectRatioChanged;
  final ValueChanged<ImageSizePreset> onSizeChanged;
  final ValueChanged<ImageQualityPreset> onQualityChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        children: [
          // Aspect ratio
          _ChipGroup(
            label: 'Ratio',
            children: [
              for (final ar in ImageAspectRatioPreset.values)
                _ParamChip(
                  label: ar.label,
                  selected: ar == selectedAspectRatio,
                  onTap: isGenerating ? null : () => onAspectRatioChanged(ar),
                ),
            ],
          ),
          // Size
          _ChipGroup(
            label: 'Size',
            children: [
              for (final sz in ImageSizePreset.values)
                _ParamChip(
                  label: sz.label,
                  selected: sz == selectedSize,
                  onTap: isGenerating ? null : () => onSizeChanged(sz),
                ),
            ],
          ),
          // Quality
          _ChipGroup(
            label: 'Quality',
            children: [
              for (final q in ImageQualityPreset.values)
                _ParamChip(
                  label: q.label,
                  selected: q == selectedQuality,
                  onTap: isGenerating ? null : () => onQualityChanged(q),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipGroup extends StatelessWidget {
  const _ChipGroup({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.6,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        ...children,
      ],
    );
  }
}

class _ParamChip extends StatelessWidget {
  const _ParamChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selected
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : colorScheme.outlineVariant,
            ),
            color: selected
                ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
          child: Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Image preview surface
// ---------------------------------------------------------------------------

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
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '正在生成样例图片',
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (image == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(
                  Icons.image_outlined,
                  color: colorScheme.primary.withValues(alpha: 0.6),
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text('生成后图片会在这里预览', style: textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              '预览仅保存在当前页面内存中，离开页面后消失。',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
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
            const _BrokenImage(message: '无法解码 b64_json 图片。'),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(child: imageWidget),
        ),
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

// ---------------------------------------------------------------------------
// Image Generation Inspector
// ---------------------------------------------------------------------------

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PersonaPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inspector',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '参数、请求与响应详情。',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isGenerating)
                  PersonaStatusPill(
                    label: '生成中',
                    icon: Icons.sync,
                    color: colorScheme.primary,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  icon: Icon(Icons.tune_outlined, size: 15),
                  label: Text('参数'),
                ),
                ButtonSegment(
                  value: 1,
                  icon: Icon(Icons.receipt_long_outlined, size: 15),
                  label: Text('请求'),
                ),
                ButtonSegment(
                  value: 2,
                  icon: Icon(Icons.data_object_outlined, size: 15),
                  label: Text('响应'),
                ),
              ],
              selected: {_selectedIndex},
              onSelectionChanged: (value) {
                setState(() => _selectedIndex = value.single);
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStatePropertyAll(
                  Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
          ),
          const Divider(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
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
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Image parameter tab
// ---------------------------------------------------------------------------

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
    final colorScheme = Theme.of(context).colorScheme;
    final modelNames = _normalizedModelNames(provider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '测试参数',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              PersonaStatusPill(
                label: isGenerating ? '锁定中' : '可调整',
                icon: Icons.tune_outlined,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ParamField(
            label: 'Model',
            child: DropdownButtonFormField<String>(
              initialValue: selectedModelName,
              items: [
                for (final modelName in modelNames)
                  DropdownMenuItem(
                    value: modelName,
                    child: Text(
                      modelName,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall,
                    ),
                  ),
              ],
              onChanged: isGenerating
                  ? null
                  : (value) {
                      if (value != null) onModelSelected(value);
                    },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
              style: textTheme.bodySmall,
            ),
          ),
          _ParamField(
            label: 'Aspect Ratio',
            child: DropdownButtonFormField<ImageAspectRatioPreset>(
              initialValue: selectedAspectRatio,
              items: [
                for (final aspectRatio in ImageAspectRatioPreset.values)
                  DropdownMenuItem(
                    value: aspectRatio,
                    child: Text(aspectRatio.label, style: textTheme.bodySmall),
                  ),
              ],
              onChanged: isGenerating
                  ? null
                  : (value) {
                      if (value != null) onAspectRatioChanged(value);
                    },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
              style: textTheme.bodySmall,
            ),
          ),
          _ParamField(
            label: 'Size Tier',
            child: DropdownButtonFormField<ImageSizePreset>(
              initialValue: selectedSize,
              items: [
                for (final size in ImageSizePreset.values)
                  DropdownMenuItem(
                    value: size,
                    child: Text(size.label, style: textTheme.bodySmall),
                  ),
              ],
              onChanged: isGenerating
                  ? null
                  : (value) {
                      if (value != null) onSizeChanged(value);
                    },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
              style: textTheme.bodySmall,
            ),
          ),
          _ParamField(
            label: 'Quality',
            child: DropdownButtonFormField<ImageQualityPreset>(
              initialValue: selectedQuality,
              items: [
                for (final quality in ImageQualityPreset.values)
                  DropdownMenuItem(
                    value: quality,
                    child: Text(quality.label, style: textTheme.bodySmall),
                  ),
              ],
              onChanged: isGenerating
                  ? null
                  : (value) {
                      if (value != null) onQualityChanged(value);
                    },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
              style: textTheme.bodySmall,
            ),
          ),
          _ParamField(
            label: 'Response Format',
            child: DropdownButtonFormField<ImageResponseFormat>(
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
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
              style: textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'n 固定为 1；style、user 当前不发送。',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParamField extends StatelessWidget {
  const _ParamField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Image request tab
// ---------------------------------------------------------------------------

class _ImageRequestTab extends StatelessWidget {
  const _ImageRequestTab({required this.actualRequest});

  final _ActualImageRequest? actualRequest;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final request = actualRequest;

    if (request == null) {
      return Text(
        '发送测试后显示最终请求；不会展示 API Key。',
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actual Request',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '展示最终参数；不会展示 API Key。',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          _MetaLine(label: 'endpoint', value: request.endpoint),
          _MetaLine(label: 'model', value: request.model),
          _MetaLine(label: 'size', value: request.size),
          _MetaLine(label: 'quality', value: request.quality),
          _MetaLine(label: 'response_format', value: request.responseFormat),
          _MetaLine(label: 'n', value: request.n.toString()),
          const SizedBox(height: 12),
          Text(
            'prompt',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          _CodeBlock(text: request.prompt),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Image response tab
// ---------------------------------------------------------------------------

class _ImageResponseTab extends StatelessWidget {
  const _ImageResponseTab({required this.result});

  final ImageGenerationResult? result;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final result = this.result;

    if (result == null) {
      return Text(
        '生成成功后显示响应摘要。',
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    final image = result.images.first;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Response',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '图片数据只保存在当前页面内存中。',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          if (result.created != null)
            _MetaLine(label: 'created', value: result.created.toString()),
          _MetaLine(
            label: 'images',
            value: result.images.length.toString(),
          ),
          if (image.url != null)
            _MetaLine(label: 'url', value: image.url!, selectable: true),
          if (image.b64Json != null)
            _MetaLine(
              label: 'b64_json',
              value: '${image.b64Json!.length} chars',
            ),
          if (image.revisedPrompt != null) ...[
            const SizedBox(height: 12),
            Text(
              'revised_prompt',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            _CodeBlock(text: image.revisedPrompt!),
          ],
          if (result.usage != null) ...[
            const SizedBox(height: 12),
            Text(
              'usage',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            _CodeBlock(
              text: const JsonEncoder.withIndent('  ').convert(result.usage),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

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
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
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
                    style: textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
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
        borderRadius: BorderRadius.circular(8),
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

// ---------------------------------------------------------------------------
// Actual request model
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

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
