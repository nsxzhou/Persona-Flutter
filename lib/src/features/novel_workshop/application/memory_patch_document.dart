import 'package:yaml/yaml.dart';

import 'memory_patch_yaml.dart';

class MemoryPatchDocument {
  const MemoryPatchDocument({
    required this.rawYaml,
    required this.characters,
    required this.relationships,
    required this.runtimeMemory,
  });

  final String rawYaml;
  final List<Object?> characters;
  final List<Object?> relationships;
  final YamlMap? runtimeMemory;

  bool get hasCharacterGraphPatch =>
      characters.isNotEmpty || relationships.isNotEmpty;

  bool get hasRuntimeMemoryPatch => runtimeMemory != null;
}

class MemoryPatchParser {
  const MemoryPatchParser();

  MemoryPatchDocument parse(String rawYaml) {
    final cleaned = stripMemoryPatchCodeFence(rawYaml);
    if (cleaned.isEmpty) {
      return const MemoryPatchDocument(
        rawYaml: '',
        characters: [],
        relationships: [],
        runtimeMemory: null,
      );
    }
    try {
      final parsed = loadYaml(cleaned);
      if (parsed is! YamlMap) {
        throw const MemoryPatchValidationException('Patch YAML 根节点必须是对象。');
      }
      final runtimeMemory = _optionalMap(
        parsed['runtimeMemory'],
        'runtimeMemory',
      );
      return MemoryPatchDocument(
        rawYaml: cleaned,
        characters: _optionalList(parsed['characters']),
        relationships: _optionalList(parsed['relationships']),
        runtimeMemory: runtimeMemory,
      );
    } on MemoryPatchValidationException {
      rethrow;
    } on Object catch (error) {
      throw MemoryPatchValidationException('Patch YAML 解析失败：$error');
    }
  }

  List<Object?> _optionalList(Object? value) {
    if (value == null) {
      return const [];
    }
    if (value is YamlList) {
      return value.nodes.map((node) => node.value).toList(growable: false);
    }
    if (value is List<Object?>) {
      return value;
    }
    throw const MemoryPatchValidationException('Patch YAML 列表字段必须是列表。');
  }

  YamlMap? _optionalMap(Object? value, String key) {
    if (value == null) {
      return null;
    }
    if (value is YamlMap) {
      return value;
    }
    if (value is Map<Object?, Object?>) {
      return YamlMap.wrap(value);
    }
    throw MemoryPatchValidationException('$key 必须是对象。');
  }
}

class MemoryPatchValidationException implements Exception {
  const MemoryPatchValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
