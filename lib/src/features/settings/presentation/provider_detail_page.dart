import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/llm/domain/llm_message.dart';
import '../../../core/llm/domain/llm_stream_event.dart';
import '../../../core/theme/app_theme.dart';
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
      loading: () => PersonaPage(
        eyebrow: 'Provider',
        title: '加载中',
        description: '正在读取 Provider 配置。',
        children: const [PersonaPanel(child: LinearProgressIndicator())],
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
      unawaited(_subscription?.cancel());
      _subscription = null;
      _streamingAssistantId = null;
    } else if (!_promptHasLocalChanges(oldWidget.provider.systemPrompt)) {
      _promptController.text = widget.provider.systemPrompt;
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

    return PersonaPage(
      eyebrow: 'Provider',
      title: provider.name,
      description:
          '${provider.baseUrl} · ${provider.defaultModel} · ${provider.modelNames.length} models',
      actions: [
        OutlinedButton.icon(
          onPressed: () => context.go('/settings'),
          icon: const Icon(Icons.arrow_back),
          label: const Text('返回设置'),
        ),
      ],
      children: [
        _ProviderCommandBar(provider: provider),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final chat = _ChatWorkbench(
              provider: provider,
              selectedModelName: selectedModelName,
              messages: _messages,
              draftController: _draftController,
              isStreaming: _isStreaming,
              errorMessage: _errorMessage,
              onSend: _sendMessage,
              onStop: _stopStreaming,
              onClear: _clearConversation,
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
            );

            if (constraints.maxWidth < 980) {
              return Column(
                children: [chat, const SizedBox(height: 16), inspector],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: chat),
                const SizedBox(width: 16),
                SizedBox(width: 410, child: inspector),
              ],
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

class _ProviderCommandBar extends StatelessWidget {
  const _ProviderCommandBar({required this.provider});

  final ProviderConfig provider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(colorScheme, provider.testStatus);
    final textTheme = Theme.of(context).textTheme;

    return PersonaPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final statusItems = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PersonaStatusPill(
                label: provider.isEnabled ? '正式生成可选' : '已停用 · 仍可测试',
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
                label: provider.systemPrompt.trim().isEmpty
                    ? 'Prompt 未配置'
                    : 'Prompt 已配置',
                icon: Icons.notes_outlined,
              ),
            ],
          );

          final metadata = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.memory_outlined,
                color: colorScheme.onSurfaceVariant,
                size: 16,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${provider.defaultModel} · ${provider.modelNames.length} models',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );

          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [metadata, const SizedBox(height: 10), statusItems],
            );
          }

          return Row(
            children: [
              Expanded(child: metadata),
              const SizedBox(width: 16),
              statusItems,
            ],
          );
        },
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PersonaPanel(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 700,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
              child: PersonaSectionHeader(
                title: '流式对话测试',
                description:
                    '${provider.name} · $selectedModelName · ${_normalizedModelNames(provider).length} models',
                trailing: isStreaming
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
              child: messages.isEmpty
                  ? _ChatEmptyState(provider: provider)
                  : ListView.separated(
                      padding: const EdgeInsets.all(18),
                      itemBuilder: (context, index) =>
                          _ChatBubble(message: messages[index]),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemCount: messages.length,
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
                    controller: draftController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: '用户消息',
                      hintText: '输入一段测试消息，按按钮开始流式生成。',
                    ),
                    onSubmitted: (_) => onSend(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed:
                            messages.isEmpty && draftController.text.isEmpty
                            ? null
                            : onClear,
                        icon: const Icon(Icons.delete_sweep_outlined),
                        label: const Text('清空'),
                      ),
                      const Spacer(),
                      if (isStreaming)
                        FilledButton.icon(
                          onPressed: onStop,
                          icon: const Icon(Icons.stop_circle_outlined),
                          label: const Text('停止'),
                        )
                      else
                        FilledButton.icon(
                          onPressed: onSend,
                          icon: const Icon(Icons.send_outlined),
                          label: const Text('发送测试'),
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
            Icon(
              Icons.forum_outlined,
              color: colorScheme.onSurfaceVariant,
              size: 34,
            ),
            const SizedBox(height: 12),
            Text(
              '${_initialModelName(provider)} · ${_normalizedModelNames(provider).length} models',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              '发送测试消息后，这里会逐步渲染模型回复。',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final _ChatTranscriptMessage message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isUser = message.role == LlmMessageRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isUser ? colorScheme.primary : colorScheme.surface,
            borderRadius: BorderRadius.circular(kPanelRadius),
            border: Border.all(
              color: isUser ? colorScheme.primary : colorScheme.outlineVariant,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUser ? 'User' : 'Assistant',
                  style: textTheme.labelMedium?.copyWith(
                    color: isUser
                        ? colorScheme.onPrimary.withValues(alpha: 0.78)
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message.content.isEmpty ? '正在生成...' : message.content,
                  style: textTheme.bodyMedium?.copyWith(
                    color: isUser
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
    required this.onSelectedIndexChanged,
    required this.onTemperatureChanged,
    required this.onModelSelected,
    required this.onSavePrompt,
  });

  final ProviderConfig provider;
  final TextEditingController promptController;
  final double temperature;
  final String selectedModelName;
  final String? actualModelName;
  final List<LlmMessage> actualRequest;
  final bool isStreaming;
  final int selectedIndex;
  final ValueChanged<int> onSelectedIndexChanged;
  final ValueChanged<double> onTemperatureChanged;
  final ValueChanged<String> onModelSelected;
  final Future<void> Function() onSavePrompt;

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
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: PersonaSectionHeader(
              title: 'Inspector',
              description: '编辑 Prompt、调整测试参数并检查实际请求。',
              trailing: isStreaming
                  ? PersonaStatusPill(
                      label: '测试中',
                      icon: Icons.sync,
                      color: colorScheme.primary,
                    )
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: 0,
                  icon: Icon(Icons.notes_outlined),
                  label: Text('Prompt'),
                ),
                ButtonSegment(
                  value: 1,
                  icon: Icon(Icons.tune_outlined),
                  label: Text('参数'),
                ),
                ButtonSegment(
                  value: 2,
                  icon: Icon(Icons.code_outlined),
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
                  Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
          ),
          const Divider(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 360),
              child: switch (selectedIndex) {
                0 => _PromptInspectorTab(
                  provider: provider,
                  promptController: promptController,
                  controllerIsLoading: controllerState.isLoading,
                  onSavePrompt: onSavePrompt,
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

class _PromptInspectorTab extends StatelessWidget {
  const _PromptInspectorTab({
    required this.provider,
    required this.promptController,
    required this.controllerIsLoading,
    required this.onSavePrompt,
  });

  final ProviderConfig provider;
  final TextEditingController promptController;
  final bool controllerIsLoading;
  final Future<void> Function() onSavePrompt;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Provider Prompt',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          '作为该 Provider 的全局系统约束，正式生成时追加到业务 Prompt 后面。',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        TextField(
          controller: promptController,
          minLines: 11,
          maxLines: 16,
          style: textTheme.bodyMedium,
          decoration: const InputDecoration(
            alignLabelWithHint: true,
            labelText: 'System Prompt',
            hintText: _defaultProviderChatSystemPrompt,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                provider.systemPrompt.trim().isEmpty
                    ? '未保存 Prompt；测试会使用内置默认模板。'
                    : '已保存 Prompt；测试和未来正式调用会复用它。',
                style: textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: controllerIsLoading ? null : onSavePrompt,
              icon: const Icon(Icons.save_outlined),
              label: Text(controllerIsLoading ? '保存中' : '保存'),
            ),
          ],
        ),
      ],
    );
  }
}

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
    final modelNames = _normalizedModelNames(provider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PersonaSectionHeader(
          title: '测试参数',
          description: 'Temperature ${temperature.toStringAsFixed(1)}',
          trailing: PersonaStatusPill(
            label: isStreaming ? '锁定中' : '可调整',
            icon: Icons.thermostat_outlined,
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
          onChanged: isStreaming
              ? null
              : (value) {
                  if (value != null) {
                    onModelSelected(value);
                  }
                },
          decoration: const InputDecoration(
            labelText: 'Model',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Slider(
          value: temperature,
          min: 0,
          max: 2,
          divisions: 20,
          label: temperature.toStringAsFixed(1),
          onChanged: isStreaming ? null : onTemperatureChanged,
        ),
        const SizedBox(height: 8),
        Text('该参数只影响当前页面的对话测试，不会保存到 Provider 配置。', style: textTheme.bodyMedium),
      ],
    );
  }
}

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PersonaSectionHeader(
          title: 'Actual Request',
          description: '展示最终消息和参数；不会展示 API Key。',
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 440),
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
      return Text('发送测试后显示最终请求消息。', style: textTheme.bodyMedium);
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
          Text(message.role.name, style: textTheme.labelMedium),
          const SizedBox(height: 4),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  message.content,
                  style: textTheme.bodyMedium?.copyWith(
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 92, child: Text(label, style: textTheme.labelMedium)),
          Expanded(child: Text(value, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

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
