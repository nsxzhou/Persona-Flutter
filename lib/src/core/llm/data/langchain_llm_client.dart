import 'package:http/http.dart' as http;
import 'package:langchain_core/chat_models.dart' as lc;
import 'package:langchain_core/prompts.dart' as lc;
import 'package:langchain_openai/langchain_openai.dart' as openai;

import '../../../features/settings/domain/provider_config.dart';
import '../domain/llm_client.dart';
import '../domain/llm_error_utils.dart';
import '../domain/llm_message.dart';
import '../domain/llm_request.dart';
import '../domain/llm_stream_event.dart';

typedef ChatModelFactory =
    lc.BaseChatModel<lc.ChatModelOptions> Function(ProviderConfig provider);

class LangChainLlmClient implements LlmClient {
  LangChainLlmClient({http.Client? client, ChatModelFactory? modelFactory})
    : _client = client,
      _modelFactory = modelFactory;

  final http.Client? _client;
  final ChatModelFactory? _modelFactory;

  @override
  Stream<LlmStreamEvent> streamChat({
    required ProviderConfig provider,
    required LlmRequest request,
  }) async* {
    final model = _modelFactory?.call(provider) ?? _createModel(provider);
    final prompt = lc.PromptValue.chat(_toLangChainMessages(request.messages));
    final options = openai.ChatOpenAIOptions(
      model: request.model,
      temperature: _clampTemperature(request.temperature),
    );

    try {
      await for (final chunk in model.stream(prompt, options: options)) {
        final text = chunk.output.content;
        if (text.isNotEmpty) {
          yield LlmStreamDelta(text);
        }
      }
      yield const LlmStreamDone();
    } on Object catch (error) {
      throw LlmClientException(_sanitizeError(error, provider));
    }
  }

  lc.BaseChatModel<lc.ChatModelOptions> _createModel(ProviderConfig provider) {
    return openai.ChatOpenAI(
      apiKey: provider.apiKey,
      baseUrl: _normalizeBaseUrl(provider.baseUrl),
      client: _client,
      defaultOptions: openai.ChatOpenAIOptions(model: provider.defaultModel),
    );
  }

  List<lc.ChatMessage> _toLangChainMessages(List<LlmMessage> messages) {
    return [
      for (final message in messages)
        switch (message.role) {
          LlmMessageRole.system => lc.ChatMessage.system(message.content),
          LlmMessageRole.user => lc.ChatMessage.humanText(message.content),
          LlmMessageRole.assistant => lc.ChatMessage.ai(message.content),
        },
    ];
  }

  String _normalizeBaseUrl(String baseUrl) {
    final trimmed = baseUrl.trim();
    if (trimmed.endsWith('/chat/completions')) {
      return trimmed.substring(0, trimmed.length - '/chat/completions'.length);
    }
    if (trimmed.endsWith('/completions')) {
      return trimmed.substring(0, trimmed.length - '/completions'.length);
    }
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  double _clampTemperature(double temperature) {
    return temperature.clamp(0, 2).toDouble();
  }

  String _sanitizeError(Object error, ProviderConfig provider) {
    return sanitizeLlmError(error, provider.apiKey, maxLength: 180);
  }
}

class LlmClientException implements Exception {
  const LlmClientException(this.message);

  final String message;

  @override
  String toString() => message;
}
