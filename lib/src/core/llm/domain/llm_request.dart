import 'llm_cancellation.dart';
import 'llm_message.dart';

class LlmRequest {
  const LlmRequest({
    required this.messages,
    required this.model,
    this.temperature = 0.7,
    this.cancellationToken,
  });

  final List<LlmMessage> messages;
  final String model;
  final double temperature;
  final LlmCancellationToken? cancellationToken;
}
