import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/llm/domain/llm_message.dart';
import '../../../core/llm/domain/llm_stream_event.dart';
import '../../../core/ui/persona_page.dart';
import '../application/provider_config_providers.dart';
import '../domain/provider_config.dart';

const _defaultProviderChatSystemPrompt = '''
你是一位网文正文续写助手。
根据用户给出的前文和续写要求，直接输出下一段正文。
保持场景连续、动作清晰、对白自然，不要解释，不要输出思考过程。''';

class ProviderDetailPage extends ConsumerWidget {
  const ProviderDetailPage({required this.providerId, super.key});

  final String providerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(providerConfigProvider(providerId));

    return provider.when(
      data: (item) {
        if (item == null) {
          return PersonaPage(
            eyebrow: 'Provider',
            title: 'Provider 不存在',
            description: '该 Provider 可能已被删除，返回设置页重新选择配置。',
            actions: [
              OutlinedButton.icon(
                onPressed: () => context.go('/settings'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('返回设置'),
              ),
            ],
            children: const [PersonaPanel(child: Text('没有找到对应的 Provider 配置。'))],
          );
        }

        return _ProviderDetailContent(provider: item);
      },
      loading: () => const PersonaPage(
        eyebrow: 'Provider',
        title: '加载中',
        description: '正在读取 Provider 配置。',
        children: [PersonaPanel(child: LinearProgressIndicator())],
      ),
      error: (error, stackTrace) => PersonaPage(
        eyebrow: 'Provider',
        title: '加载失败',
        description: '无法读取 Provider 配置。',
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

class _ProviderDetailContent extends ConsumerStatefulWidget {
  const _ProviderDetailContent({required this.provider});

  final ProviderConfig provider;

  @override
  ConsumerState<_ProviderDetailContent> createState() =>
      _ProviderDetailContentState();
}

class _ProviderDetailContentState
    extends ConsumerState<_ProviderDetailContent> {
  late final TextEditingController _promptController;
  late final TextEditingController _draftController;
  double _temperature = 0.7;
  int _inspectorIndex = 0;
  String? _selectedModelName;
  String? _lastActualModelName;
  late bool _isSystemPromptEnabled;
  bool _sidebarExpanded = true;
  final List<_ChatTranscriptMessage> _messages = [];
  List<LlmMessage> _lastActualRequest = const [];
  StreamSubscription<LlmStreamEvent>? _subscription;
  String? _streamingAssistantId;
  String? _errorMessage;

  bool get _isStreaming => _subscription != null;

  String get _effectiveSystemPrompt {
    final draft = _promptController.text.trim();
    if (draft.isNotEmpty) {
      return draft;
    }
    return _defaultProviderChatSystemPrompt;
  }

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
    _promptController = TextEditingController(
      text: widget.provider.systemPrompt,
    );
    _draftController = TextEditingController();
    _selectedModelName = _initialModelName(widget.provider);
    _isSystemPromptEnabled = widget.provider.isSystemPromptEnabled;
  }

  @override
  void didUpdateWidget(covariant _ProviderDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider.id != widget.provider.id) {
      _promptController.text = widget.provider.systemPrompt;
      _draftController.clear();
      _messages.clear();
      _lastActualRequest = const [];
      _lastActualModelName = null;
      _errorMessage = null;
      _inspectorIndex = 0;
      _selectedModelName = _initialModelName(widget.provider);
      _isSystemPromptEnabled = widget.provider.isSystemPromptEnabled;
      unawaited(_subscription?.cancel());
      _subscription = null;
      _streamingAssistantId = null;
    } else if (!_promptHasLocalChanges(oldWidget.provider.systemPrompt)) {
      _promptController.text = widget.provider.systemPrompt;
      _isSystemPromptEnabled = widget.provider.isSystemPromptEnabled;
    }
    final selected = _selectedModelName?.trim();
    if (selected != null &&
        selected.isNotEmpty &&
        !_normalizedModelNames(widget.provider).contains(selected)) {
      _selectedModelName = _initialModelName(widget.provider);
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    _promptController.dispose();
    _draftController.dispose();
    super.dispose();
  }

  bool _promptHasLocalChanges(String previousPrompt) {
    return _promptController.text.trim() != previousPrompt.trim();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final selectedModelName = _resolvedModelName;
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(colorScheme, provider.testStatus);

    return PersonaPage(
      eyebrow: 'Provider',
      title: provider.name,
      description:
          '${provider.baseUrl} · ${provider.defaultModel} · ${provider.modelNames.length} models',
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
            // Compute a bounded height for workbench/inspector so that
            // Expanded and ListView work inside SingleChildScrollView.
            final viewHeight = MediaQuery.of(context).size.height;
            final panelHeight = (viewHeight - 220).clamp(480.0, 900.0);

            final chat = _ChatWorkbench(
              provider: provider,
              selectedModelName: selectedModelName,
              messages: _messages,
              draftController: _draftController,
              isStreaming: _isStreaming,
              errorMessage: _errorMessage,
              sidebarExpanded: _sidebarExpanded,
              temperature: _temperature,
              modelNames: _normalizedModelNames(provider),
              onSend: _sendMessage,
              onStop: _stopStreaming,
              onClear: _clearConversation,
              onToggleSidebar: () {
                setState(() => _sidebarExpanded = !_sidebarExpanded);
              },
              onTemperatureChanged: (value) {
                setState(() => _temperature = value);
              },
              onModelSelected: (value) {
                setState(() => _selectedModelName = value);
              },
            );
            final inspector = _ProviderInspectorPanel(
              provider: provider,
              promptController: _promptController,
              temperature: _temperature,
              selectedModelName: selectedModelName,
              actualModelName: _lastActualModelName,
              actualRequest: _lastActualRequest,
              isStreaming: _isStreaming,
              selectedIndex: _inspectorIndex,
              isSystemPromptEnabled: _isSystemPromptEnabled,
              onSelectedIndexChanged: (value) {
                setState(() => _inspectorIndex = value);
              },
              onTemperatureChanged: (value) {
                setState(() => _temperature = value);
              },
              onModelSelected: (value) {
                setState(() => _selectedModelName = value);
              },
              onSavePrompt: _savePrompt,
              onSystemPromptEnabledChanged: (value) {
                setState(() => _isSystemPromptEnabled = value);
                _savePrompt();
              },
            );

            if (constraints.maxWidth < 980) {
              return SizedBox(
                height: panelHeight,
                child: Column(
                  children: [
                    Expanded(child: chat),
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
                  Expanded(child: chat),
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

  Future<void> _savePrompt() async {
    await ref
        .read(providerConfigControllerProvider.notifier)
        .updateSystemPrompt(
          id: widget.provider.id,
          systemPrompt: _promptController.text,
          isSystemPromptEnabled: _isSystemPromptEnabled,
        );

    if (!mounted) {
      return;
    }
    final state = ref.read(providerConfigControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.hasError ? '保存失败：${state.error}' : 'Provider Prompt 已保存',
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final userText = _draftController.text.trim();
    if (userText.isEmpty || _isStreaming) {
      return;
    }

    final userMessage = _ChatTranscriptMessage.user(userText);
    final assistantMessage = _ChatTranscriptMessage.assistant('');
    final modelName = _resolvedModelName;
    final requestMessages = [
      LlmMessage.system(_effectiveSystemPrompt),
      ..._messages
          .where((message) => message.content.trim().isNotEmpty)
          .map((message) => message.toLlmMessage()),
      userMessage.toLlmMessage(),
    ];

    setState(() {
      _draftController.clear();
      _errorMessage = null;
      _messages.add(userMessage);
      _messages.add(assistantMessage);
      _lastActualRequest = requestMessages;
      _lastActualModelName = modelName;
      _streamingAssistantId = assistantMessage.id;
    });

    final chatMessages = [
      for (final message in requestMessages.skip(1)) message,
    ];

    final stream = ref
        .read(llmInvocationServiceProvider)
        .streamChat(
          provider: widget.provider.copyWith(
            systemPrompt: _promptController.text,
            isSystemPromptEnabled: _isSystemPromptEnabled,
          ),
          businessSystemPrompt: _promptController.text.trim().isEmpty
              ? _defaultProviderChatSystemPrompt
              : '',
          messages: chatMessages
              .where((message) => message.role != LlmMessageRole.system)
              .toList(),
          temperature: _temperature,
          modelName: modelName,
        );

    _subscription = stream.listen(
      (event) {
        if (!mounted) {
          return;
        }
        switch (event) {
          case LlmStreamDelta(:final text):
            _appendAssistantDelta(text);
          case LlmStreamDone():
            _finishStreaming();
        }
      },
      onError: (Object error) {
        if (!mounted) {
          return;
        }
        setState(() {
          _errorMessage = error.toString();
          _removeEmptyStreamingAssistant();
          _subscription = null;
          _streamingAssistantId = null;
        });
      },
      onDone: () {
        if (!mounted) {
          return;
        }
        _finishStreaming();
      },
    );
  }

  void _appendAssistantDelta(String text) {
    final id = _streamingAssistantId;
    if (id == null) {
      return;
    }
    setState(() {
      final index = _messages.indexWhere((message) => message.id == id);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(
          content: '${_messages[index].content}$text',
        );
      }
    });
  }

  void _removeEmptyStreamingAssistant() {
    final id = _streamingAssistantId;
    if (id == null) {
      return;
    }
    _messages.removeWhere(
      (message) => message.id == id && message.content.trim().isEmpty,
    );
  }

  void _finishStreaming() {
    setState(() {
      _removeEmptyStreamingAssistant();
      _subscription = null;
      _streamingAssistantId = null;
    });
  }

  Future<void> _stopStreaming() async {
    await _subscription?.cancel();
    if (!mounted) {
      return;
    }
    setState(() {
      _subscription = null;
      _streamingAssistantId = null;
    });
  }

  Future<void> _clearConversation() async {
    await _stopStreaming();
    setState(() {
      _draftController.clear();
      _messages.clear();
      _lastActualRequest = const [];
      _lastActualModelName = null;
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
// Model helpers
// ---------------------------------------------------------------------------

String _initialModelName(ProviderConfig provider) {
  final modelNames = _normalizedModelNames(provider);
  if (modelNames.isNotEmpty) {
    return modelNames.first;
  }
  return provider.defaultModel.trim();
}

List<String> _normalizedModelNames(ProviderConfig provider) {
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

// ---------------------------------------------------------------------------
// Chat Workbench
// ---------------------------------------------------------------------------

class _ChatWorkbench extends StatelessWidget {
  const _ChatWorkbench({
    required this.provider,
    required this.selectedModelName,
    required this.messages,
    required this.draftController,
    required this.isStreaming,
    required this.onSend,
    required this.onStop,
    required this.onClear,
    required this.sidebarExpanded,
    required this.temperature,
    required this.modelNames,
    required this.onToggleSidebar,
    required this.onTemperatureChanged,
    required this.onModelSelected,
    this.errorMessage,
  });

  final ProviderConfig provider;
  final String selectedModelName;
  final List<_ChatTranscriptMessage> messages;
  final TextEditingController draftController;
  final bool isStreaming;
  final String? errorMessage;
  final VoidCallback onSend;
  final VoidCallback onStop;
  final VoidCallback onClear;
  final bool sidebarExpanded;
  final double temperature;
  final List<String> modelNames;
  final VoidCallback onToggleSidebar;
  final ValueChanged<double> onTemperatureChanged;
  final ValueChanged<String> onModelSelected;

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
                      Text('流式对话测试', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(
                        '${provider.name} · $selectedModelName',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isStreaming)
                  PersonaStatusPill(
                    label: '生成中',
                    icon: Icons.sync,
                    color: colorScheme.primary,
                  ),
              ],
            ),
          ),
          // Inline control bar
          _InlineControlBar(
            selectedModelName: selectedModelName,
            modelNames: modelNames,
            temperature: temperature,
            sidebarExpanded: sidebarExpanded,
            isStreaming: isStreaming,
            onModelSelected: onModelSelected,
            onTemperatureChanged: onTemperatureChanged,
            onToggleSidebar: onToggleSidebar,
          ),
          const Divider(height: 1),
          // Messages
          Expanded(
            child: messages.isEmpty
                ? _ChatEmptyState(provider: provider)
                : ListView.separated(
                    padding: const EdgeInsets.all(18),
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isLast = index == messages.length - 1;
                      final isStreamingThis =
                          isLast &&
                          msg.role == LlmMessageRole.assistant &&
                          isStreaming;
                      return _ChatBubble(
                        message: msg,
                        isStreaming: isStreamingThis,
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemCount: messages.length,
                  ),
          ),
          // Error
          if (errorMessage != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: colorScheme.error, size: 16),
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
                  controller: draftController,
                  minLines: 2,
                  maxLines: 4,
                  style: textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: '输入测试消息，按按钮开始流式生成。',
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
                      borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                    ),
                  ),
                  onSubmitted: (_) => onSend(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed:
                          messages.isEmpty && draftController.text.isEmpty
                          ? null
                          : onClear,
                      icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                      label: const Text('清空'),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const Spacer(),
                    if (isStreaming)
                      FilledButton.icon(
                        onPressed: onStop,
                        icon: const Icon(Icons.stop_circle_outlined, size: 16),
                        label: const Text('停止'),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                    else
                      FilledButton.icon(
                        onPressed: onSend,
                        icon: const Icon(Icons.send_outlined, size: 16),
                        label: const Text('发送测试'),
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
// Inline control bar
// ---------------------------------------------------------------------------

class _InlineControlBar extends StatelessWidget {
  const _InlineControlBar({
    required this.selectedModelName,
    required this.modelNames,
    required this.temperature,
    required this.sidebarExpanded,
    required this.isStreaming,
    required this.onModelSelected,
    required this.onTemperatureChanged,
    required this.onToggleSidebar,
  });

  final String selectedModelName;
  final List<String> modelNames;
  final double temperature;
  final bool sidebarExpanded;
  final bool isStreaming;
  final ValueChanged<String> onModelSelected;
  final ValueChanged<double> onTemperatureChanged;
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
          // Model selector
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
                  DropdownMenuItem(value: name, child: Text(name, overflow: TextOverflow.ellipsis)),
              ],
              onChanged: isStreaming
                  ? null
                  : (value) {
                      if (value != null) onModelSelected(value);
                    },
            ),
          ),
          const SizedBox(width: 16),
          // Temperature
          Text(
            'TEMP',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: colorScheme.primary,
                inactiveTrackColor: colorScheme.outline,
                thumbColor: colorScheme.primary,
              ),
              child: Slider(
                value: temperature,
                min: 0,
                max: 2,
                divisions: 20,
                onChanged: isStreaming ? null : onTemperatureChanged,
              ),
            ),
          ),
          Text(
            temperature.toStringAsFixed(1),
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
          const Spacer(),
          // Sidebar toggle
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
// Chat empty state
// ---------------------------------------------------------------------------

class _ChatEmptyState extends StatelessWidget {
  const _ChatEmptyState({required this.provider});

  final ProviderConfig provider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
                  Icons.forum_outlined,
                  color: colorScheme.primary.withValues(alpha: 0.6),
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '${_initialModelName(provider)} · ${_normalizedModelNames(provider).length} models',
              style: textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              '发送测试消息后，这里会逐步渲染模型回复。',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chat bubble
// ---------------------------------------------------------------------------

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, required this.isStreaming});

  final _ChatTranscriptMessage message;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUser = message.role == LlmMessageRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              _AvatarIcon(
                icon: Icons.smart_toy_outlined,
                color: colorScheme.onSurfaceVariant,
                bgColor: colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isUser
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(14),
                    topRight: const Radius.circular(14),
                    bottomLeft: Radius.circular(isUser ? 14 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 14),
                  ),
                  border: isUser
                      ? null
                      : Border.all(color: colorScheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: _buildContent(context, isUser),
                ),
              ),
            ),
            if (isUser) ...[
              const SizedBox(width: 8),
              _AvatarIcon(
                icon: Icons.person_outline,
                color: colorScheme.primary,
                bgColor: colorScheme.primaryContainer,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isUser) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (message.content.isEmpty && isStreaming) {
      return _ShimmerPlaceholder(isUser: isUser);
    }

    final contentText = message.content.isEmpty ? '正在生成...' : message.content;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            contentText,
            style: textTheme.bodyMedium?.copyWith(
              color: isUser ? colorScheme.onPrimary : colorScheme.onSurface,
              height: 1.6,
            ),
          ),
        ),
        if (isStreaming && message.content.isNotEmpty) const _TypingCursor(),
      ],
    );
  }
}

class _AvatarIcon extends StatelessWidget {
  const _AvatarIcon({
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  final IconData icon;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}

// ---------------------------------------------------------------------------
// Typing cursor
// ---------------------------------------------------------------------------

class _TypingCursor extends StatefulWidget {
  const _TypingCursor();

  @override
  State<_TypingCursor> createState() => _TypingCursorState();
}

class _TypingCursorState extends State<_TypingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _controller.value,
          child: Container(
            width: 2,
            height: 14,
            margin: const EdgeInsets.only(left: 2, bottom: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer placeholder
// ---------------------------------------------------------------------------

class _ShimmerPlaceholder extends StatefulWidget {
  const _ShimmerPlaceholder({required this.isUser});

  final bool isUser;

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = widget.isUser
        ? colorScheme.onPrimary.withValues(alpha: 0.15)
        : colorScheme.outlineVariant.withValues(alpha: 0.4);
    final highlightColor = widget.isUser
        ? colorScheme.onPrimary.withValues(alpha: 0.25)
        : colorScheme.outline.withValues(alpha: 0.3);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _ShimmerLine(
              width: 180,
              progress: _controller.value,
              baseColor: baseColor,
              highlightColor: highlightColor,
            ),
            const SizedBox(height: 6),
            _ShimmerLine(
              width: 140,
              progress: _controller.value,
              baseColor: baseColor,
              highlightColor: highlightColor,
            ),
            const SizedBox(height: 6),
            _ShimmerLine(
              width: 100,
              progress: _controller.value,
              baseColor: baseColor,
              highlightColor: highlightColor,
            ),
          ],
        );
      },
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  const _ShimmerLine({
    required this.width,
    required this.progress,
    required this.baseColor,
    required this.highlightColor,
  });

  final double width;
  final double progress;
  final Color baseColor;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: LinearGradient(
          colors: [baseColor, highlightColor, baseColor],
          stops: [
            (progress - 0.3).clamp(0.0, 1.0),
            progress.clamp(0.0, 1.0),
            (progress + 0.3).clamp(0.0, 1.0),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Inspector panel
// ---------------------------------------------------------------------------

class _ProviderInspectorPanel extends ConsumerWidget {
  const _ProviderInspectorPanel({
    required this.provider,
    required this.promptController,
    required this.temperature,
    required this.selectedModelName,
    required this.actualModelName,
    required this.actualRequest,
    required this.isStreaming,
    required this.selectedIndex,
    required this.isSystemPromptEnabled,
    required this.onSelectedIndexChanged,
    required this.onTemperatureChanged,
    required this.onModelSelected,
    required this.onSavePrompt,
    required this.onSystemPromptEnabledChanged,
  });

  final ProviderConfig provider;
  final TextEditingController promptController;
  final double temperature;
  final String selectedModelName;
  final String? actualModelName;
  final List<LlmMessage> actualRequest;
  final bool isStreaming;
  final int selectedIndex;
  final bool isSystemPromptEnabled;
  final ValueChanged<int> onSelectedIndexChanged;
  final ValueChanged<double> onTemperatureChanged;
  final ValueChanged<String> onModelSelected;
  final Future<void> Function() onSavePrompt;
  final ValueChanged<bool> onSystemPromptEnabledChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerState = ref.watch(providerConfigControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return PersonaPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '编辑 Prompt、调整参数并检查请求。',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isStreaming)
                  PersonaStatusPill(
                    label: '测试中',
                    icon: Icons.sync,
                    color: colorScheme.primary,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: 0,
                  icon: Icon(Icons.notes_outlined, size: 15),
                  label: Text('Prompt'),
                ),
                ButtonSegment(
                  value: 1,
                  icon: Icon(Icons.tune_outlined, size: 15),
                  label: Text('参数'),
                ),
                ButtonSegment(
                  value: 2,
                  icon: Icon(Icons.code_outlined, size: 15),
                  label: Text('Request'),
                ),
              ],
              selected: {selectedIndex},
              onSelectionChanged: (selection) {
                onSelectedIndexChanged(selection.first);
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
              child: switch (selectedIndex) {
                0 => _PromptInspectorTab(
                  provider: provider,
                  promptController: promptController,
                  controllerIsLoading: controllerState.isLoading,
                  isSystemPromptEnabled: isSystemPromptEnabled,
                  onSavePrompt: onSavePrompt,
                  onSystemPromptEnabledChanged: onSystemPromptEnabledChanged,
                ),
                1 => _ParameterInspectorTab(
                  provider: provider,
                  temperature: temperature,
                  selectedModelName: selectedModelName,
                  isStreaming: isStreaming,
                  onTemperatureChanged: onTemperatureChanged,
                  onModelSelected: onModelSelected,
                ),
                _ => _RequestInspectorTab(
                  temperature: temperature,
                  modelName: actualModelName ?? selectedModelName,
                  actualRequest: actualRequest,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Prompt tab
// ---------------------------------------------------------------------------

class _PromptInspectorTab extends StatelessWidget {
  const _PromptInspectorTab({
    required this.provider,
    required this.promptController,
    required this.controllerIsLoading,
    required this.isSystemPromptEnabled,
    required this.onSavePrompt,
    required this.onSystemPromptEnabledChanged,
  });

  final ProviderConfig provider;
  final TextEditingController promptController;
  final bool controllerIsLoading;
  final bool isSystemPromptEnabled;
  final Future<void> Function() onSavePrompt;
  final ValueChanged<bool> onSystemPromptEnabledChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Provider Prompt',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '作为该 Provider 的全局系统约束，正式生成时追加到业务 Prompt 后面。',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: isSystemPromptEnabled
                  ? colorScheme.primaryContainer.withValues(alpha: 0.25)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSystemPromptEnabled
                    ? colorScheme.primary.withValues(alpha: 0.3)
                    : colorScheme.outlineVariant,
              ),
            ),
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              title: Text(
                '启用 Provider Prompt',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                isSystemPromptEnabled
                    ? '已启用 · 正式生成时追加到业务 Prompt 后面'
                    : '已禁用 · 正式生成时忽略此 Prompt',
                style: textTheme.labelSmall?.copyWith(
                  color: isSystemPromptEnabled
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              value: isSystemPromptEnabled,
              onChanged: onSystemPromptEnabledChanged,
            ),
          ),
          const SizedBox(height: 12),
          Opacity(
            opacity: isSystemPromptEnabled ? 1.0 : 0.5,
            child: TextField(
              controller: promptController,
              minLines: 8,
              maxLines: 12,
              style: textTheme.bodySmall,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                labelText: 'System Prompt',
                labelStyle: textTheme.bodySmall,
                hintText: _defaultProviderChatSystemPrompt,
                hintStyle: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  provider.systemPrompt.trim().isEmpty
                      ? '未保存 Prompt；测试会使用内置默认模板。'
                      : '已保存 Prompt。',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: controllerIsLoading ? null : onSavePrompt,
                icon: const Icon(Icons.save_outlined, size: 15),
                label: Text(controllerIsLoading ? '保存中' : '保存'),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Parameter tab
// ---------------------------------------------------------------------------

class _ParameterInspectorTab extends StatelessWidget {
  const _ParameterInspectorTab({
    required this.provider,
    required this.temperature,
    required this.selectedModelName,
    required this.isStreaming,
    required this.onTemperatureChanged,
    required this.onModelSelected,
  });

  final ProviderConfig provider;
  final double temperature;
  final String selectedModelName;
  final bool isStreaming;
  final ValueChanged<double> onTemperatureChanged;
  final ValueChanged<String> onModelSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final modelNames = _normalizedModelNames(provider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '测试参数',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            PersonaStatusPill(
              label: isStreaming ? '锁定中' : '可调整',
              icon: Icons.thermostat_outlined,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Model', style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: selectedModelName,
          items: [
            for (final modelName in modelNames)
              DropdownMenuItem(
                value: modelName,
                child: Text(modelName, overflow: TextOverflow.ellipsis, style: textTheme.bodySmall),
              ),
          ],
          onChanged: isStreaming
              ? null
              : (value) {
                  if (value != null) {
                    onModelSelected(value);
                  }
                },
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            isDense: true,
          ),
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text('Temperature', style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(
              temperature.toStringAsFixed(1),
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Slider(
          value: temperature,
          min: 0,
          max: 2,
          divisions: 20,
          onChanged: isStreaming ? null : onTemperatureChanged,
        ),
        const SizedBox(height: 8),
        Text(
          '该参数只影响当前页面的对话测试，不会保存到 Provider 配置。',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Request tab
// ---------------------------------------------------------------------------

class _RequestInspectorTab extends StatelessWidget {
  const _RequestInspectorTab({
    required this.temperature,
    required this.modelName,
    required this.actualRequest,
  });

  final double temperature;
  final String modelName;
  final List<LlmMessage> actualRequest;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actual Request',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          '展示最终消息和参数；不会展示 API Key。',
          style: textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: _ActualRequestView(
              temperature: temperature,
              modelName: modelName,
              messages: actualRequest,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActualRequestView extends StatelessWidget {
  const _ActualRequestView({
    required this.temperature,
    required this.modelName,
    required this.messages,
  });

  final double temperature;
  final String modelName;
  final List<LlmMessage> messages;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (messages.isEmpty) {
      return Text(
        '发送测试后显示最终请求消息。',
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RequestMetaLine(label: 'model', value: modelName),
        _RequestMetaLine(
          label: 'temperature',
          value: temperature.toStringAsFixed(1),
        ),
        const SizedBox(height: 12),
        for (final message in messages) ...[
          Text(
            message.role.name,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  message.content,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _RequestMetaLine extends StatelessWidget {
  const _RequestMetaLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Transcript message
// ---------------------------------------------------------------------------

class _ChatTranscriptMessage {
  _ChatTranscriptMessage({
    required this.id,
    required this.role,
    required this.content,
  });

  factory _ChatTranscriptMessage.user(String content) {
    return _ChatTranscriptMessage(
      id: 'user-${DateTime.now().microsecondsSinceEpoch}',
      role: LlmMessageRole.user,
      content: content,
    );
  }

  factory _ChatTranscriptMessage.assistant(String content) {
    return _ChatTranscriptMessage(
      id: 'assistant-${DateTime.now().microsecondsSinceEpoch}',
      role: LlmMessageRole.assistant,
      content: content,
    );
  }

  final String id;
  final LlmMessageRole role;
  final String content;

  _ChatTranscriptMessage copyWith({String? content}) {
    return _ChatTranscriptMessage(
      id: id,
      role: role,
      content: content ?? this.content,
    );
  }

  LlmMessage toLlmMessage() {
    return LlmMessage(role: role, content: content);
  }
}

// ---------------------------------------------------------------------------
// Status helpers
// ---------------------------------------------------------------------------

String _statusLabel(ProviderTestStatus status) {
  return switch (status) {
    ProviderTestStatus.untested => '未测试',
    ProviderTestStatus.testing => '测试中',
    ProviderTestStatus.succeeded => '连接可用',
    ProviderTestStatus.failed => '连接失败',
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
