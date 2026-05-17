import '../domain/llm_message.dart';
import '../domain/llm_stream_event.dart';
import 'llm_invocation_service.dart';
import '../../../features/settings/domain/provider_config.dart';

class MarkdownCompletionService {
  const MarkdownCompletionService({required LlmInvocationService invocation})
    : _invocation = invocation;

  final LlmInvocationService _invocation;

  Future<String> completeMarkdown({
    required ProviderConfig provider,
    required String prompt,
    double temperature = 0.4,
    int maxAttempts = 3,
    String? modelName,
    LlmPromptTraceConfig? promptTrace,
  }) async {
    Object? lastError;
    for (var attempt = 1; attempt <= maxAttempts; attempt += 1) {
      try {
        final buffer = StringBuffer();
        await for (final event in _invocation.streamChat(
          provider: provider,
          businessSystemPrompt: '',
          messages: [LlmMessage.user(prompt)],
          temperature: temperature,
          modelName: modelName,
          promptTrace: promptTrace,
        )) {
          if (event is LlmStreamDelta) {
            buffer.write(event.text);
          }
        }
        final text = buffer.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
        lastError = const EmptyMarkdownCompletionException('模型返回了空内容。');
      } on Object catch (error) {
        lastError = error;
      }
    }

    final message = lastError?.toString() ?? '模型没有返回 Markdown 内容。';
    throw EmptyMarkdownCompletionException(_sanitize(message, provider));
  }

  String _sanitize(String message, ProviderConfig provider) {
    final apiKey = provider.apiKey.trim();
    if (apiKey.isEmpty) {
      return _truncate(message);
    }
    return _truncate(message.replaceAll(apiKey, '[REDACTED]'));
  }

  String _truncate(String message) {
    if (message.length <= 220) {
      return message;
    }
    return '${message.substring(0, 217)}...';
  }
}

class EmptyMarkdownCompletionException implements Exception {
  const EmptyMarkdownCompletionException(this.message);

  final String message;

  @override
  String toString() => message;
}
