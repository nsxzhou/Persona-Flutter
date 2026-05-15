import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/provider_config.dart';

class ProviderConnectivityTester {
  ProviderConnectivityTester({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<ProviderConnectivityResult> test(ProviderConfig provider) async {
    final endpoint = _modelsEndpoint(provider.baseUrl);

    try {
      final response = await _client
          .get(
            endpoint,
            headers: {
              'Authorization': 'Bearer ${provider.apiKey}',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return ProviderConnectivityResult.failure(
          '请求失败：HTTP ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, Object?> || decoded['data'] is! List) {
        return const ProviderConnectivityResult.failure('响应不是有效的 models 列表。');
      }

      return const ProviderConnectivityResult.success('连接成功，已读取模型列表。');
    } on TimeoutException {
      return const ProviderConnectivityResult.failure('连接超时，请检查网络或 Base URL。');
    } on FormatException {
      return const ProviderConnectivityResult.failure('响应不是有效 JSON。');
    } on Object catch (error) {
      return ProviderConnectivityResult.failure(_sanitizeError(error));
    }
  }

  Uri _modelsEndpoint(String baseUrl) {
    final trimmed = baseUrl.trim();
    final normalized = trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    final withoutChat = normalized.endsWith('/chat/completions')
        ? normalized.substring(
            0,
            normalized.length - '/chat/completions'.length,
          )
        : normalized;
    final withoutCompletions = withoutChat.endsWith('/completions')
        ? withoutChat.substring(0, withoutChat.length - '/completions'.length)
        : withoutChat;

    return Uri.parse('$withoutCompletions/models');
  }

  String _sanitizeError(Object error) {
    final message = error.toString();
    if (message.length <= 180) {
      return message;
    }

    return '${message.substring(0, 177)}...';
  }
}

class ProviderConnectivityResult {
  const ProviderConnectivityResult._({
    required this.isSuccess,
    required this.message,
  });

  const ProviderConnectivityResult.success(String message)
    : this._(isSuccess: true, message: message);

  const ProviderConnectivityResult.failure(String message)
    : this._(isSuccess: false, message: message);

  final bool isSuccess;
  final String message;
}
