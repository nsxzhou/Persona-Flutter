class ProviderPromptComposer {
  const ProviderPromptComposer();

  String compose({
    required String businessSystemPrompt,
    required String providerSystemPrompt,
  }) {
    final business = businessSystemPrompt.trim();
    final provider = providerSystemPrompt.trim();

    if (business.isEmpty) {
      return provider;
    }
    if (provider.isEmpty) {
      return business;
    }

    return '$business\n\n$provider';
  }
}
