import '../../../features/settings/domain/image_provider_config.dart';
import '../domain/image_generation_client.dart';
import '../domain/image_generation_request.dart';

class ImageGenerationService {
  const ImageGenerationService({required ImageGenerationClient client})
    : _client = client;

  final ImageGenerationClient _client;

  Future<ImageGenerationResult> generateImage({
    required ImageProviderConfig provider,
    required String prompt,
    String? modelName,
    ImageAspectRatioPreset? aspectRatio,
    ImageSizePreset? size,
    ImageQualityPreset? quality,
    ImageResponseFormat? responseFormat,
  }) {
    final request = ImageGenerationRequest(
      model: _resolveModel(provider, modelName),
      prompt: prompt,
      size: resolveImageRequestSize(
        aspectRatio: aspectRatio ?? provider.defaultAspectRatio,
        size: size ?? provider.defaultSize,
      ),
      quality: (quality ?? provider.defaultQuality).quality,
      responseFormat: responseFormat ?? provider.defaultResponseFormat,
      n: 1,
    );
    return _client.generateImage(provider: provider, request: request);
  }

  Future<ImageGenerationResult> editImage({
    required ImageProviderConfig provider,
    required String prompt,
    required List<int> imageBytes,
    required String imageFilename,
    String? modelName,
    ImageAspectRatioPreset? aspectRatio,
    ImageSizePreset? size,
    ImageQualityPreset? quality,
    ImageResponseFormat? responseFormat,
    List<int>? maskBytes,
    String? maskFilename,
  }) {
    final request = ImageEditRequest(
      model: _resolveModel(provider, modelName),
      prompt: prompt,
      imageBytes: imageBytes,
      imageFilename: imageFilename,
      size: resolveImageRequestSize(
        aspectRatio: aspectRatio ?? provider.defaultAspectRatio,
        size: size ?? provider.defaultSize,
      ),
      quality: (quality ?? provider.defaultQuality).quality,
      responseFormat: responseFormat ?? provider.defaultResponseFormat,
      n: 1,
      maskBytes: maskBytes,
      maskFilename: maskFilename,
    );
    return _client.editImage(provider: provider, request: request);
  }

  String _resolveModel(ImageProviderConfig provider, String? modelName) {
    final candidate = modelName?.trim();
    if (candidate != null && candidate.isNotEmpty) {
      return candidate;
    }
    return provider.defaultModel;
  }
}
