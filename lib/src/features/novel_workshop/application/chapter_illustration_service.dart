import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/image_generation/application/image_generation_service.dart';
import '../../../core/image_generation/domain/image_generation_request.dart';
import '../../settings/domain/image_provider_config.dart';
import '../domain/novel_workshop.dart';
import '../domain/novel_workshop_repository.dart';

class ChapterIllustrationService {
  ChapterIllustrationService({
    required NovelWorkshopRepository repository,
    required ImageGenerationService imageGenerationService,
    http.Client? httpClient,
    Future<Directory> Function()? supportDirectory,
  }) : _repository = repository,
       _imageGenerationService = imageGenerationService,
       _httpClient = httpClient ?? http.Client(),
       _supportDirectory = supportDirectory ?? getApplicationSupportDirectory;

  final NovelWorkshopRepository _repository;
  final ImageGenerationService _imageGenerationService;
  final http.Client _httpClient;
  final Future<Directory> Function() _supportDirectory;

  static const _uuid = Uuid();

  Future<ChapterIllustration> generateIllustration({
    required ProjectChapter chapter,
    required int paragraphIndex,
    required String selectedText,
    required String prompt,
    required ImageProviderConfig provider,
    required String modelName,
  }) async {
    final normalizedPrompt = prompt.trim();
    if (normalizedPrompt.isEmpty) {
      throw StateError('插图提示词不能为空。');
    }
    final result = await _imageGenerationService.generateImage(
      provider: provider,
      prompt: normalizedPrompt,
      modelName: modelName,
    );
    final image = result.images.cast<GeneratedImage?>().firstWhere(
      (item) => item?.hasImage ?? false,
      orElse: () => null,
    );
    if (image == null) {
      throw StateError('图像 Provider 没有返回可用图片。');
    }

    final stored = await _persistImage(
      projectId: chapter.projectId,
      image: image,
    );
    return _repository.createChapterIllustration(
      ChapterIllustrationInput(
        projectId: chapter.projectId,
        chapterId: chapter.id,
        chapterPlanId: chapter.chapterPlanId,
        paragraphIndex: paragraphIndex,
        anchorTextHash: anchorTextHash(selectedText),
        selectedText: selectedText,
        prompt: normalizedPrompt,
        providerId: provider.id,
        modelName: modelName,
        localPath: stored.path,
        mimeType: stored.mimeType,
      ),
    );
  }

  Future<_StoredIllustrationImage> _persistImage({
    required String projectId,
    required GeneratedImage image,
  }) async {
    final bytesAndMime = await _readImageBytes(image);
    final extension = _extensionForMime(bytesAndMime.mimeType);
    final directory = await _illustrationDirectory(projectId);
    final filename =
        '${DateTime.now().millisecondsSinceEpoch}-${_uuid.v4()}'
        '$extension';
    final file = File(p.join(directory.path, filename));
    await file.writeAsBytes(bytesAndMime.bytes, flush: true);
    return _StoredIllustrationImage(
      path: file.path,
      mimeType: bytesAndMime.mimeType,
    );
  }

  Future<_ImageBytes> _readImageBytes(GeneratedImage image) async {
    final b64 = image.b64Json?.trim();
    if (b64 != null && b64.isNotEmpty) {
      return _ImageBytes(bytes: base64Decode(b64), mimeType: 'image/png');
    }

    final url = image.url?.trim();
    if (url == null || url.isEmpty) {
      throw StateError('图像 Provider 没有返回图片 URL 或 base64 数据。');
    }
    final response = await _httpClient
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 120));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('下载生成图片失败：HTTP ${response.statusCode}');
    }
    final mimeType = response.headers['content-type']
        ?.split(';')
        .first
        .trim()
        .toLowerCase();
    return _ImageBytes(
      bytes: response.bodyBytes,
      mimeType: (mimeType == null || mimeType.isEmpty) ? 'image/png' : mimeType,
    );
  }

  Future<Directory> _illustrationDirectory(String projectId) async {
    final supportDir = await _supportDirectory();
    final directory = Directory(
      p.join(supportDir.path, 'Persona', 'illustrations', projectId),
    );
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    return directory;
  }
}

String anchorTextHash(String value) {
  return base64Url.encode(utf8.encode(value.trim())).replaceAll('=', '');
}

String _extensionForMime(String mimeType) {
  return switch (mimeType.toLowerCase()) {
    'image/jpeg' || 'image/jpg' => '.jpg',
    'image/webp' => '.webp',
    _ => '.png',
  };
}

class _ImageBytes {
  const _ImageBytes({required this.bytes, required this.mimeType});

  final List<int> bytes;
  final String mimeType;
}

class _StoredIllustrationImage {
  const _StoredIllustrationImage({required this.path, required this.mimeType});

  final String path;
  final String mimeType;
}
