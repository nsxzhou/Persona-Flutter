/// Returns `true` if [markdown] contains at least one top-level heading (`# `).
bool hasMarkdownHeading(String markdown) {
  return markdown.split('\n').any((line) => line.trimLeft().startsWith('# '));
}

/// Strips YAML front matter (delimited by `---`) from [markdown].
///
/// Returns the body text after the closing `---`, or the original text if no
/// valid front matter is found.
String stripFrontMatter(String markdown) {
  final normalized = markdown.trimLeft();
  if (!normalized.startsWith('---\n')) {
    return markdown;
  }
  final end = normalized.indexOf('\n---', 4);
  if (end < 0) {
    return markdown;
  }
  final bodyStart = normalized.indexOf('\n', end + 4);
  return bodyStart < 0 ? '' : normalized.substring(bodyStart).trim();
}

/// Strips a markdown code fence wrapper (e.g. ` ```markdown ... ``` `).
///
/// If [raw] is wrapped in a fenced code block, returns the inner content.
/// Otherwise returns [raw] unchanged.
String stripMarkdownFence(String raw) {
  final trimmed = raw.trim();
  final match = RegExp(
    r'^```(?:markdown|md|yaml|yml)?\s*([\s\S]*?)\s*```$',
    caseSensitive: false,
  ).firstMatch(trimmed);
  return match?.group(1)?.trim() ?? trimmed;
}

/// Normalizes YAML front matter documents for parsing.
///
/// - Strips code fences
/// - Ensures opening `---` is followed by a newline
String normalizeYamlMarkdownDocument(String raw) {
  var normalized = stripMarkdownFence(raw).trimLeft();
  if (normalized.startsWith('---') && !normalized.startsWith('---\n')) {
    normalized = '---\n${normalized.substring(3).trimLeft()}';
  }
  return normalized;
}
