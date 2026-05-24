import '../../../features/settings/domain/image_provider_config.dart';
import 'image_generation_request.dart';

abstract interface class ImageGenerationClient {
  Future<ImageGenerationResult> generateImage({
    required ImageProviderConfig provider,
    required ImageGenerationRequest request,
  });

  Future<ImageGenerationResult> editImage({
    required ImageProviderConfig provider,
    required ImageEditRequest request,
  });
}
