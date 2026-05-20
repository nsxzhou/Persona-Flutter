class ProviderPromptComposer {
  const ProviderPromptComposer();

  String compose({
    required String businessSystemPrompt,
    required String providerSystemPrompt,
    bool isProviderPromptEnabled = true,
  }) {
    final business = businessSystemPrompt.trim();
    final provider = providerSystemPrompt.trim();

    if (!isProviderPromptEnabled || provider.isEmpty) {
      return business;
    }
    if (business.isEmpty) {
      return provider;
    }

    return '$business\n\n$provider';
  }
}
