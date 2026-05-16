sealed class LlmStreamEvent {
  const LlmStreamEvent();
}

class LlmStreamDelta extends LlmStreamEvent {
  const LlmStreamDelta(this.text);

  final String text;
}

class LlmStreamDone extends LlmStreamEvent {
  const LlmStreamDone();
}
