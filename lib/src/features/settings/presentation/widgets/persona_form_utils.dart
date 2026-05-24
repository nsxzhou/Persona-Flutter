String? requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return '必填';
  }
  return null;
}

String? urlValidator(String? value) {
  final requiredError = requiredValidator(value);
  if (requiredError != null) {
    return requiredError;
  }
  final uri = Uri.tryParse(value!.trim());
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    return '请输入有效 URL';
  }
  return null;
}

List<String> parseModelNames(String value) {
  return value
      .split(RegExp(r'[\n,]'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

String extractHost(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri != null && uri.host.isNotEmpty) {
    return uri.host + (uri.port != 80 && uri.port != 443 ? ':${uri.port}' : '');
  }
  return url;
}
