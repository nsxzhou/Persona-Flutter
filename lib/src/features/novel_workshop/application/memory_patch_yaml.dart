String normalizeMemoryPatchYaml(String raw) {
  final trimmed = raw.trim();
  final match = RegExp(
    r'^```(?:markdown|md|yaml|yml)?\s*([\s\S]*?)\s*```$',
    caseSensitive: false,
  ).firstMatch(trimmed);
  return match?.group(1)?.trim() ?? trimmed;
}
