import '../../../features/settings/domain/provider_config.dart';
import 'llm_request.dart';
import 'llm_stream_event.dart';

abstract interface class LlmClient {
  Stream<LlmStreamEvent> streamChat({
    required ProviderConfig provider,
    required LlmRequest request,
  });
}
