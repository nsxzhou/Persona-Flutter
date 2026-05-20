import 'package:yaml/yaml.dart';

import '../domain/novel_workshop.dart';

class VolumeBlueprintDocument {
  const VolumeBlueprintDocument({required this.volumes});

  final List<VolumeBlueprintDraft> volumes;
}

class VolumeBlueprintDraft {
  const VolumeBlueprintDraft({
    required this.volumeIndex,
    required this.title,
    required this.targetLength,
    required this.summary,
    required this.centralConflict,
    required this.characterProgression,
    required this.endingHook,
  });

  final int volumeIndex;
  final String title;
  final int targetLength;
  final String summary;
  final String centralConflict;
  final String characterProgression;
  final String endingHook;

  ChapterVolumeInput toInput(String projectId) {
    return ChapterVolumeInput(
      projectId: projectId,
      volumeIndex: volumeIndex,
      title: title,
      targetLength: targetLength,
      summary: summary,
      centralConflict: centralConflict,
      characterProgression: characterProgression,
      endingHook: endingHook,
    );
  }
}

class VolumeBlueprintParser {
  const VolumeBlueprintParser();

  VolumeBlueprintDocument parse(String yamlText) {
    final trimmed = yamlText.trim();
    if (trimmed.isEmpty) {
      throw const VolumeBlueprintValidationException('分卷规划 YAML 不能为空。');
    }
    final parsed = loadYaml(trimmed);
    if (parsed is! YamlMap) {
      throw const VolumeBlueprintValidationException('分卷规划 YAML 根节点必须是对象。');
    }
    final volumesValue = parsed['volumes'];
    if (volumesValue is! YamlList && volumesValue is! List) {
      throw const VolumeBlueprintValidationException('分卷规划 YAML 缺少 volumes。');
    }
    final items = volumesValue as Iterable<Object?>;
    if (items.isEmpty) {
      throw const VolumeBlueprintValidationException('至少需要一个分卷。');
    }
    final seenIndexes = <int>{};
    final volumes = <VolumeBlueprintDraft>[];
    for (var index = 0; index < items.length; index += 1) {
      final path = 'volumes[$index]';
      final map = _requireMap(items.elementAt(index), path);
      final volumeIndex = _requiredPositiveInt(map, 'index', path);
      if (!seenIndexes.add(volumeIndex)) {
        throw VolumeBlueprintValidationException('分卷序号重复：$volumeIndex。');
      }
      volumes.add(
        VolumeBlueprintDraft(
          volumeIndex: volumeIndex,
          title: _requiredString(map, 'title', path),
          targetLength: _optionalPositiveInt(map, 'targetLength', path) ?? 0,
          summary: _string(map, 'summary'),
          centralConflict: _string(map, 'centralConflict'),
          characterProgression: _string(map, 'characterProgression'),
          endingHook: _string(map, 'endingHook'),
        ),
      );
    }
    return VolumeBlueprintDocument(volumes: List.unmodifiable(volumes));
  }

  Map<Object?, Object?> _requireMap(Object? value, String path) {
    if (value is YamlMap) {
      return value;
    }
    if (value is Map<Object?, Object?>) {
      return value;
    }
    throw VolumeBlueprintValidationException('$path 必须是对象。');
  }

  int _requiredPositiveInt(Map<Object?, Object?> map, String key, String path) {
    final value = map[key];
    if (value is int && value > 0) {
      return value;
    }
    throw VolumeBlueprintValidationException('$path.$key 必须是正整数。');
  }

  int? _optionalPositiveInt(
    Map<Object?, Object?> map,
    String key,
    String path,
  ) {
    final value = map[key];
    if (value == null) {
      return null;
    }
    if (value is int && value > 0) {
      return value;
    }
    throw VolumeBlueprintValidationException('$path.$key 必须是正整数。');
  }

  String _requiredString(Map<Object?, Object?> map, String key, String path) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    throw VolumeBlueprintValidationException('$path.$key 必须是非空字符串。');
  }

  String _string(Map<Object?, Object?> map, String key) {
    final value = map[key];
    if (value == null) {
      return '';
    }
    if (value is String) {
      return value.trim();
    }
    throw VolumeBlueprintValidationException('$key 必须是字符串。');
  }
}

class VolumeBlueprintValidationException implements Exception {
  const VolumeBlueprintValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
