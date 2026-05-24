import 'image_provider_config.dart';
import 'provider_config.dart';

abstract interface class ImageProviderConfigRepository {
  Stream<List<ImageProviderConfig>> watchProviders();

  Future<void> saveProvider({
    String? id,
    required ImageProviderConfigInput input,
  });

  Future<void> deleteProvider(String id);

  Future<ImageProviderConfig?> findProvider(String id);

  Stream<ImageProviderConfig?> watchProvider(String id);

  Future<void> updateTestResult({
    required String id,
    required ProviderTestStatus status,
    required DateTime testedAt,
    String? message,
  });
}
