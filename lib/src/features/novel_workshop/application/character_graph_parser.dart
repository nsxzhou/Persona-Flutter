import 'package:yaml/yaml.dart';

import '../domain/novel_workshop.dart';

class CharacterGraphDocument {
  const CharacterGraphDocument({
    required this.characters,
    required this.relationships,
  });

  final List<CharacterDraft> characters;
  final List<RelationshipDraft> relationships;
}

class CharacterDraft {
  const CharacterDraft({
    required this.name,
    required this.aliases,
    required this.tags,
    required this.faction,
    required this.role,
    required this.longTermGoal,
    required this.currentStatus,
    required this.secrets,
    required this.firstChapterIndex,
    required this.lastChapterIndex,
  });

  final String name;
  final String aliases;
  final String tags;
  final String faction;
  final String role;
  final String longTermGoal;
  final String currentStatus;
  final String secrets;
  final int? firstChapterIndex;
  final int? lastChapterIndex;

  NovelCharacterInput toInput(String projectId) {
    return NovelCharacterInput(
      projectId: projectId,
      name: name,
      aliases: aliases,
      tags: tags,
      faction: faction,
      role: role,
      longTermGoal: longTermGoal,
      currentStatus: currentStatus,
      secrets: secrets,
      firstChapterIndex: firstChapterIndex,
      lastChapterIndex: lastChapterIndex,
    );
  }
}

class RelationshipDraft {
  const RelationshipDraft({
    required this.fromName,
    required this.toName,
    required this.relationshipType,
    required this.strength,
    required this.status,
    required this.description,
    required this.lastChangedChapterIndex,
  });

  final String fromName;
  final String toName;
  final String relationshipType;
  final int strength;
  final String status;
  final String description;
  final int? lastChangedChapterIndex;
}

class CharacterGraphParser {
  const CharacterGraphParser();

  CharacterGraphDocument parse(String yamlText) {
    final trimmed = yamlText.trim();
    if (trimmed.isEmpty) {
      throw const CharacterGraphValidationException('角色 YAML 不能为空。');
    }
    final parsed = loadYaml(trimmed);
    if (parsed is! YamlMap) {
      throw const CharacterGraphValidationException('角色 YAML 根节点必须是对象。');
    }
    final characterItems = _optionalList(parsed['characters'], 'characters');
    final relationshipItems = _optionalList(
      parsed['relationships'],
      'relationships',
    );
    if (characterItems.isEmpty && relationshipItems.isEmpty) {
      throw const CharacterGraphValidationException(
        '角色 YAML 至少需要 characters 或 relationships。',
      );
    }

    return CharacterGraphDocument(
      characters: [
        for (var index = 0; index < characterItems.length; index += 1)
          _parseCharacter(characterItems[index], 'characters[$index]'),
      ],
      relationships: [
        for (var index = 0; index < relationshipItems.length; index += 1)
          _parseRelationship(relationshipItems[index], 'relationships[$index]'),
      ],
    );
  }

  CharacterDraft _parseCharacter(Object? value, String path) {
    final map = _requireMap(value, path);
    return CharacterDraft(
      name: _requiredString(map, 'name', path),
      aliases: _stringListOrString(map, 'aliases'),
      tags: _stringListOrString(map, 'tags'),
      faction: _string(map, 'faction'),
      role: _string(map, 'role'),
      longTermGoal: _string(map, 'longTermGoal'),
      currentStatus: _string(map, 'currentStatus'),
      secrets: _string(map, 'secrets'),
      firstChapterIndex: _optionalPositiveInt(map, 'firstChapterIndex', path),
      lastChapterIndex: _optionalPositiveInt(map, 'lastChapterIndex', path),
    );
  }

  RelationshipDraft _parseRelationship(Object? value, String path) {
    final map = _requireMap(value, path);
    return RelationshipDraft(
      fromName: _requiredString(map, 'from', path),
      toName: _requiredString(map, 'to', path),
      relationshipType: _string(map, 'type'),
      strength: _int(map, 'strength', path),
      status: _string(map, 'status'),
      description: _string(map, 'description'),
      lastChangedChapterIndex: _optionalPositiveInt(
        map,
        'lastChangedChapterIndex',
        path,
      ),
    );
  }

  List<Object?> _optionalList(Object? value, String key) {
    if (value == null) {
      return const [];
    }
    if (value is YamlList) {
      return value.nodes.map((node) => node.value).toList(growable: false);
    }
    if (value is List<Object?>) {
      return value;
    }
    throw CharacterGraphValidationException('$key 必须是列表。');
  }

  Map<Object?, Object?> _requireMap(Object? value, String path) {
    if (value is YamlMap) {
      return value;
    }
    if (value is Map<Object?, Object?>) {
      return value;
    }
    throw CharacterGraphValidationException('$path 必须是对象。');
  }

  String _requiredString(Map<Object?, Object?> map, String key, String path) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    throw CharacterGraphValidationException('$path.$key 必须是非空字符串。');
  }

  String _string(Map<Object?, Object?> map, String key) {
    final value = map[key];
    if (value == null) {
      return '';
    }
    if (value is String) {
      return value.trim();
    }
    throw CharacterGraphValidationException('$key 必须是字符串。');
  }

  String _stringListOrString(Map<Object?, Object?> map, String key) {
    final value = map[key];
    if (value == null) {
      return '';
    }
    if (value is String) {
      return value.trim();
    }
    if (value is YamlList || value is List<Object?>) {
      final items = (value as Iterable<Object?>)
          .map((item) {
            if (item is! String) {
              throw CharacterGraphValidationException('$key 只能包含字符串。');
            }
            return item.trim();
          })
          .where((item) => item.isNotEmpty);
      return items.join('、');
    }
    throw CharacterGraphValidationException('$key 必须是字符串或字符串列表。');
  }

  int _int(Map<Object?, Object?> map, String key, String path) {
    final value = map[key];
    if (value == null) {
      return 0;
    }
    if (value is int) {
      return value.clamp(-5, 5);
    }
    throw CharacterGraphValidationException('$path.$key 必须是整数。');
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
    throw CharacterGraphValidationException('$path.$key 必须是正整数。');
  }
}

class CharacterGraphValidationException implements Exception {
  const CharacterGraphValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
