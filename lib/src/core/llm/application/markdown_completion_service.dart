import '../domain/llm_cancellation.dart';
import '../domain/llm_error_utils.dart';
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
    String businessSystemPrompt = '',
    double temperature = 0.4,
    int maxAttempts = 3,
    String? modelName,
    LlmPromptTraceConfig? promptTrace,
    LlmCancellationToken? cancellationToken,
  }) async {
    Object? lastError;
    for (var attempt = 1; attempt <= maxAttempts; attempt += 1) {
      try {
        cancellationToken?.throwIfCancelled();
        final buffer = StringBuffer();
        await for (final event in _invocation.streamChat(
          provider: provider,
          businessSystemPrompt: businessSystemPrompt,
          messages: [LlmMessage.user(prompt)],
          temperature: temperature,
          modelName: modelName,
          promptTrace: promptTrace,
          cancellationToken: cancellationToken,
        )) {
          cancellationToken?.throwIfCancelled();
          if (event is LlmStreamDelta) {
            buffer.write(event.text);
          }
        }
        cancellationToken?.throwIfCancelled();
        final text = buffer.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
        lastError = const EmptyMarkdownCompletionException('模型返回了空内容。');
      } on LlmCancellationException {
        rethrow;
      } on Object catch (error) {
        lastError = error;
      }
    }

    final message = lastError?.toString() ?? '模型没有返回 Markdown 内容。';
    throw EmptyMarkdownCompletionException(
      sanitizeLlmError(message, provider.apiKey),
    );
  }
}

class EmptyMarkdownCompletionException implements Exception {
  const EmptyMarkdownCompletionException(this.message);

  final String message;

  @override
  String toString() => message;
}
