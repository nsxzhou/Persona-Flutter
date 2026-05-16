enum LlmMessageRole { system, user, assistant }

class LlmMessage {
  const LlmMessage({required this.role, required this.content});

  const LlmMessage.system(String content)
    : this(role: LlmMessageRole.system, content: content);

  const LlmMessage.user(String content)
    : this(role: LlmMessageRole.user, content: content);

  const LlmMessage.assistant(String content)
    : this(role: LlmMessageRole.assistant, content: content);

  final LlmMessageRole role;
  final String content;
}
