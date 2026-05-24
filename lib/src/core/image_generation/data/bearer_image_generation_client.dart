import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../features/settings/domain/image_provider_config.dart';
import '../../llm/domain/llm_error_utils.dart';
import '../domain/image_generation_client.dart';
import '../domain/image_generation_request.dart';

class BearerImageGenerationClient implements ImageGenerationClient {
  BearerImageGenerationClient({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<ImageGenerationResult> generateImage({
    required ImageProviderConfig provider,
    required ImageGenerationRequest request,
  }) async {
    final isGrok = provider.providerKind == ImageProviderKind.grok;
    final endpoint = _endpoint(
      provider.baseUrl,
      isGrok ? '/chat/completions' : '/images/generations',
    );
    try {
      final response = await _client
          .post(
            endpoint,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer ${provider.apiKey}',
            },
            body: jsonEncode(_generationBody(provider, request)),
          )
          .timeout(const Duration(seconds: 120));
      return isGrok
          ? _parseChatCompletionsResponse(response, provider)
          : _parseImagesResponse(response, provider);
    } on TimeoutException {
      throw const ImageGenerationClientException('图像生成超时，请检查网络或模型状态。');
    } on ImageGenerationClientException {
      rethrow;
    } on Object catch (error) {
      throw ImageGenerationClientException(_sanitizeError(error, provider));
    }
  }

  @override
  Future<ImageGenerationResult> editImage({
    required ImageProviderConfig provider,
    required ImageEditRequest request,
  }) async {
    if (provider.providerKind == ImageProviderKind.grok) {
      throw const ImageGenerationClientException('Grok 图像 Provider 暂不支持图片编辑。');
    }
    final endpoint = _endpoint(provider.baseUrl, '/images/edits');
    final multipart = http.MultipartRequest('POST', endpoint)
      ..headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer ${provider.apiKey}',
      })
      ..fields.addAll({
        'model': request.model,
        'prompt': request.prompt,
        'size': request.size,
        'quality': request.quality,
        'response_format': _responseFormatValue(request.responseFormat),
      })
      ..files.add(
        http.MultipartFile.fromBytes(
          'image',
          request.imageBytes,
          filename: request.imageFilename,
        ),
      );
    final maskBytes = request.maskBytes;
    final maskFilename = request.maskFilename;
    if (maskBytes != null && maskFilename != null && maskFilename.isNotEmpty) {
      multipart.files.add(
        http.MultipartFile.fromBytes('mask', maskBytes, filename: maskFilename),
      );
    }

    try {
      final streamed = await _client
          .send(multipart)
          .timeout(const Duration(seconds: 120));
      final response = await http.Response.fromStream(streamed);
      return _parseImagesResponse(response, provider);
    } on TimeoutException {
      throw const ImageGenerationClientException('图像编辑超时，请检查网络或模型状态。');
    } on ImageGenerationClientException {
      rethrow;
    } on Object catch (error) {
      throw ImageGenerationClientException(_sanitizeError(error, provider));
    }
  }

  ImageGenerationResult _parseImagesResponse(
    http.Response response,
    ImageProviderConfig provider,
  ) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ImageGenerationClientException(
        '请求失败：HTTP ${response.statusCode} ${_sanitizeBody(response.body, provider)}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, Object?>) {
      throw const ImageGenerationClientException('响应不是有效的图像生成对象。');
    }
    final data = decoded['data'];
    if (data is! List) {
      throw const ImageGenerationClientException('响应缺少 data 图像列表。');
    }
    final images = data
        .whereType<Map<String, Object?>>()
        .map(
          (item) => GeneratedImage(
            url: item['url'] as String?,
            b64Json: item['b64_json'] as String?,
            revisedPrompt: item['revised_prompt'] as String?,
          ),
        )
        .where((image) => image.hasImage)
        .take(1)
        .toList(growable: false);
    if (images.isEmpty) {
      throw const ImageGenerationClientException('响应没有可显示的图像。');
    }
    final usage = decoded['usage'];
    return ImageGenerationResult(
      created: decoded['created'] is int ? decoded['created'] as int : null,
      images: images,
      usage: usage is Map<String, Object?> ? usage : null,
      rawBody: response.body,
    );
  }

  ImageGenerationResult _parseChatCompletionsResponse(
    http.Response response,
    ImageProviderConfig provider,
  ) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ImageGenerationClientException(
        '请求失败：HTTP ${response.statusCode} ${_sanitizeBody(response.body, provider)}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, Object?>) {
      throw const ImageGenerationClientException('响应不是有效的聊天生图对象。');
    }
    final choices = decoded['choices'];
    if (choices is! List) {
      throw const ImageGenerationClientException('响应缺少 choices 列表。');
    }
    final images = choices
        .whereType<Map<String, Object?>>()
        .map((choice) => choice['message'])
        .whereType<Map<String, Object?>>()
        .map((message) => message['content'])
        .whereType<String>()
        .map(_markdownImageUrl)
        .whereType<String>()
        .map((url) => GeneratedImage(url: url))
        .where((image) => image.hasImage)
        .take(1)
        .toList(growable: false);
    if (images.isEmpty) {
      throw const ImageGenerationClientException('聊天生图响应没有可显示的图片链接。');
    }
    final usage = decoded['usage'];
    return ImageGenerationResult(
      created: decoded['created'] is int ? decoded['created'] as int : null,
      images: images,
      usage: usage is Map<String, Object?> ? usage : null,
      rawBody: response.body,
    );
  }

  Uri _endpoint(String baseUrl, String path) {
    final trimmed = baseUrl.trim();
    final withoutTrailingSlash = trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    final normalized = withoutTrailingSlash.endsWith('/v1')
        ? withoutTrailingSlash
        : '$withoutTrailingSlash/v1';
    return Uri.parse('$normalized$path');
  }

  Map<String, Object?> _generationBody(
    ImageProviderConfig provider,
    ImageGenerationRequest request,
  ) {
    final body = <String, Object?>{
      'model': request.model,
      'prompt': request.prompt,
      'size': request.size,
      'response_format': _responseFormatValue(request.responseFormat),
    };
    if (provider.providerKind != ImageProviderKind.grok) {
      body['quality'] = request.quality;
      return body;
    }
    return {
      'model': request.model,
      'stream': false,
      'messages': [
        {'role': 'user', 'content': request.prompt},
      ],
      'image_config': {'size': request.size, 'response_format': 'url'},
    };
  }

  String? _markdownImageUrl(String content) {
    final match = RegExp(r'!\[[^\]]*\]\(([^)]+)\)').firstMatch(content);
    return match?.group(1)?.trim();
  }

  String _responseFormatValue(ImageResponseFormat format) {
    return switch (format) {
      ImageResponseFormat.url => 'url',
      ImageResponseFormat.b64Json => 'b64_json',
    };
  }

  String _sanitizeBody(String body, ImageProviderConfig provider) {
    if (body.trim().isEmpty) {
      return '';
    }
    return sanitizeLlmError(body, provider.apiKey, maxLength: 180);
  }

  String _sanitizeError(Object error, ImageProviderConfig provider) {
    return sanitizeLlmError(error, provider.apiKey, maxLength: 180);
  }
}

class ImageGenerationClientException implements Exception {
  const ImageGenerationClientException(this.message);

  final String message;

  @override
  String toString() => message;
}
