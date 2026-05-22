/// Sanitizes an error by redacting [apiKey] (if non-empty) and truncating
/// to [maxLength] characters (default 220).
String sanitizeLlmError(Object error, String apiKey, {int maxLength = 220}) {
  var message = error.toString();
  final trimmedKey = apiKey.trim();
  if (trimmedKey.isNotEmpty) {
    message = message.replaceAll(trimmedKey, '[REDACTED]');
  }
  if (message.length <= maxLength) {
    return message;
  }
  return '${message.substring(0, maxLength - 3)}...';
}
