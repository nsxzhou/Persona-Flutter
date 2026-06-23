/// Utility functions shared across Drift repository implementations.
library;

/// Converts a blank or whitespace-only string to `null`.
///
/// Useful when writing to Drift `Value(...)` wrappers where an empty
/// string should be stored as SQL `NULL` rather than `''`.
String? blankToNull(String? value) {
  final trimmed = value?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}
