import 'llm_message.dart';

class LlmRequest {
  const LlmRequest({
    required this.messages,
    required this.model,
    this.temperature = 0.7,
  });

  final List<LlmMessage> messages;
  final String model;
  final double temperature;
}
