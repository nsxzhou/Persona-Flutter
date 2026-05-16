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
  }) {
    final systemPrompt = _promptComposer.compose(
      businessSystemPrompt: businessSystemPrompt,
      providerSystemPrompt: provider.systemPrompt,
    );
    final requestMessages = [
      if (systemPrompt.trim().isNotEmpty) LlmMessage.system(systemPrompt),
      ...messages,
    ];

    return _client.streamChat(
      provider: provider,
      request: LlmRequest(
        messages: requestMessages,
        model: provider.defaultModel,
        temperature: temperature,
      ),
    );
  }
}
