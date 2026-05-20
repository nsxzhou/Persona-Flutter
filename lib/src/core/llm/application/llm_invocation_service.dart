import '../../../features/settings/domain/provider_config.dart';
import '../domain/llm_client.dart';
import '../domain/llm_message.dart';
import '../domain/llm_request.dart';
import '../domain/llm_stream_event.dart';
import 'provider_prompt_composer.dart';

class LlmInvocationService {
  const LlmInvocationService({
    required LlmClient client,
    ProviderPromptComposer promptComposer = const ProviderPromptComposer(),
  }) : _client = client,
       _promptComposer = promptComposer;

  final LlmClient _client;
  final ProviderPromptComposer _promptComposer;

  Stream<LlmStreamEvent> streamChat({
    required ProviderConfig provider,
    required String businessSystemPrompt,
    required List<LlmMessage> messages,
    double temperature = 0.7,
    String? modelName,
    LlmPromptTraceConfig? promptTrace,
  }) async* {
    final resolvedModelName = modelName?.trim().isNotEmpty == true
        ? modelName!.trim()
        : provider.defaultModel;
    final systemPrompt = _promptComposer.compose(
      businessSystemPrompt: businessSystemPrompt,
      providerSystemPrompt: provider.systemPrompt,
      isProviderPromptEnabled: provider.isSystemPromptEnabled,
    );
    final requestMessages = [
      if (systemPrompt.trim().isNotEmpty) LlmMessage.system(systemPrompt),
      ...messages,
    ];
    final startedAt = DateTime.now();
    final output = StringBuffer();

    try {
      await for (final event in _client.streamChat(
        provider: provider,
        request: LlmRequest(
          messages: requestMessages,
          model: resolvedModelName,
          temperature: temperature,
        ),
      )) {
        if (event is LlmStreamDelta) {
          output.write(event.text);
        }
        yield event;
      }
      await _recordTrace(
        promptTrace,
        LlmPromptTraceEvent(
          label: promptTrace?.label ?? 'chat',
          modelName: resolvedModelName,
          temperature: temperature,
          messages: requestMessages,
          startedAt: startedAt,
          completedAt: DateTime.now(),
          output: output.toString(),
        ),
      );
    } on Object catch (error) {
      await _recordTrace(
        promptTrace,
        LlmPromptTraceEvent(
          label: promptTrace?.label ?? 'chat',
          modelName: resolvedModelName,
          temperature: temperature,
          messages: requestMessages,
          startedAt: startedAt,
          completedAt: DateTime.now(),
          errorSummary: _truncateError(error.toString()),
        ),
      );
      rethrow;
    }
  }

  Future<void> _recordTrace(
    LlmPromptTraceConfig? config,
    LlmPromptTraceEvent event,
  ) async {
    if (config == null) {
      return;
    }
    try {
      await config.onComplete(event);
    } on Object {
      // Prompt trace persistence is best-effort diagnostics.
    }
  }

  String _truncateError(String message) {
    if (message.length <= 220) {
      return message;
    }
    return '${message.substring(0, 217)}...';
  }
}

class LlmPromptTraceConfig {
  const LlmPromptTraceConfig({required this.label, required this.onComplete});

  final String label;
  final Future<void> Function(LlmPromptTraceEvent event) onComplete;
}

class LlmPromptTraceEvent {
  const LlmPromptTraceEvent({
    required this.label,
    required this.modelName,
    required this.temperature,
    required this.messages,
    required this.startedAt,
    required this.completedAt,
    this.output,
    this.errorSummary,
  });

  final String label;
  final String modelName;
  final double temperature;
  final List<LlmMessage> messages;
  final DateTime startedAt;
  final DateTime completedAt;
  final String? output;
  final String? errorSummary;
}
