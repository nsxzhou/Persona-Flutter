import '../../../features/settings/domain/image_provider_config.dart';

class ImageGenerationRequest {
  const ImageGenerationRequest({
    required this.model,
    required this.prompt,
    required this.size,
    required this.quality,
    this.responseFormat = ImageResponseFormat.url,
    this.n = 1,
  });

  final String model;
  final String prompt;
  final String size;
  final String quality;
  final ImageResponseFormat responseFormat;
  final int n;
}

class ImageEditRequest {
  const ImageEditRequest({
    required this.model,
    required this.prompt,
    required this.imageBytes,
    required this.imageFilename,
    required this.size,
    required this.quality,
    this.responseFormat = ImageResponseFormat.url,
    this.n = 1,
    this.maskBytes,
    this.maskFilename,
  });

  final String model;
  final String prompt;
  final List<int> imageBytes;
  final String imageFilename;
  final String size;
  final String quality;
  final ImageResponseFormat responseFormat;
  final int n;
  final List<int>? maskBytes;
  final String? maskFilename;
}

class ImageGenerationResult {
  const ImageGenerationResult({
    required this.created,
    required this.images,
    this.usage,
    this.rawBody,
  });

  final int? created;
  final List<GeneratedImage> images;
  final Map<String, Object?>? usage;
  final String? rawBody;
}

class GeneratedImage {
  const GeneratedImage({this.url, this.b64Json, this.revisedPrompt});

  final String? url;
  final String? b64Json;
  final String? revisedPrompt;

  bool get hasImage {
    return (url != null && url!.trim().isNotEmpty) ||
        (b64Json != null && b64Json!.trim().isNotEmpty);
  }
}
