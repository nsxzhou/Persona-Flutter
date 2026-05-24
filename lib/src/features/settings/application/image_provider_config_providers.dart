import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/image_generation/application/image_generation_service.dart';
import '../../../core/image_generation/data/bearer_image_generation_client.dart';
import '../../../core/image_generation/domain/image_generation_client.dart';
import '../../../core/llm/domain/llm_error_utils.dart';
import '../data/drift_image_provider_config_repository.dart';
import '../domain/image_provider_config.dart';
import '../domain/image_provider_config_repository.dart';
import '../domain/provider_config.dart';

part 'image_provider_config_providers.g.dart';

const imageProviderSamplePrompt = '一只坐在书桌旁读小说的白猫，干净插画风格。';

@Riverpod(keepAlive: true)
http.Client imageProviderHttpClient(Ref ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
}

@Riverpod(keepAlive: true)
ImageProviderConfigRepository imageProviderConfigRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftImageProviderConfigRepository(database);
}

@Riverpod(keepAlive: true)
ImageGenerationClient imageGenerationClient(Ref ref) {
  return BearerImageGenerationClient(
    client: ref.watch(imageProviderHttpClientProvider),
  );
}

@Riverpod(keepAlive: true)
ImageGenerationService imageGenerationService(Ref ref) {
  return ImageGenerationService(
    client: ref.watch(imageGenerationClientProvider),
  );
}

@riverpod
Stream<List<ImageProviderConfig>> imageProviderConfigs(Ref ref) {
  final repository = ref.watch(imageProviderConfigRepositoryProvider);
  return repository.watchProviders();
}

@riverpod
Stream<ImageProviderConfig?> imageProviderConfig(Ref ref, String id) {
  final repository = ref.watch(imageProviderConfigRepositoryProvider);
  return repository.watchProvider(id);
}

@riverpod
class ImageProviderConfigController extends _$ImageProviderConfigController {
  @override
  FutureOr<void> build() {}

  Future<void> save({
    String? id,
    required ImageProviderConfigInput input,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(imageProviderConfigRepositoryProvider)
          .saveProvider(id: id, input: input);
    });
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(imageProviderConfigRepositoryProvider).deleteProvider(id);
    });
  }

  Future<void> test(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(imageProviderConfigRepositoryProvider);
      final provider = await repository.findProvider(id);
      if (provider == null) {
        throw StateError('图像 Provider 不存在。');
      }

      await repository.updateTestResult(
        id: id,
        status: ProviderTestStatus.testing,
        testedAt: DateTime.now(),
      );

      try {
        final result = await ref
            .read(imageGenerationServiceProvider)
            .generateImage(
              provider: provider.copyWith(
                defaultAspectRatio: ImageAspectRatioPreset.square,
                defaultSize: ImageSizePreset.oneK,
                defaultQuality: ImageQualityPreset.auto,
                defaultResponseFormat: ImageResponseFormat.url,
              ),
              prompt: imageProviderSamplePrompt,
              aspectRatio: ImageAspectRatioPreset.square,
              size: ImageSizePreset.oneK,
              quality: ImageQualityPreset.auto,
              responseFormat: ImageResponseFormat.url,
            );
        await repository.updateTestResult(
          id: id,
          status: ProviderTestStatus.succeeded,
          testedAt: DateTime.now(),
          message: '样例生图成功，返回 ${result.images.length} 张图片。',
        );
      } on Object catch (error) {
        await repository.updateTestResult(
          id: id,
          status: ProviderTestStatus.failed,
          testedAt: DateTime.now(),
          message: sanitizeLlmError(error, provider.apiKey),
        );
      }
    });
  }
}
