import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/character_graph_parser.dart';

void main() {
  test('parses character secrets from string', () {
    final document = const CharacterGraphParser().parse('''
characters:
  - name: 林岚
    secrets: 不要提前揭露旧案身份
''');

    expect(document.characters.single.secrets, '不要提前揭露旧案身份');
  });

  test('parses character secrets from string list', () {
    final document = const CharacterGraphParser().parse('''
characters:
  - name: 林岚
    secrets:
      - 不要提前揭露旧案身份
      - 曾经隐瞒关键证词
''');

    expect(document.characters.single.secrets, '不要提前揭露旧案身份、曾经隐瞒关键证词');
  });

  test('rejects character secrets with non-string values', () {
    expect(
      () => const CharacterGraphParser().parse('''
characters:
  - name: 林岚
    secrets:
      hidden: true
'''),
      throwsA(
        isA<CharacterGraphValidationException>().having(
          (error) => error.message,
          'message',
          contains('characters[0].secrets 必须是字符串或字符串列表'),
        ),
      ),
    );
  });

  test('rejects relationship referencing non-existent character in from', () {
    expect(
      () => const CharacterGraphParser().parse('''
characters:
  - name: 林岚
relationships:
  - from: 司空玄
    to: 林岚
    type: 敌对
    strength: -3
'''),
      throwsA(
        isA<CharacterGraphValidationException>().having(
          (error) => error.message,
          'message',
          contains('关系引用的角色不存在：司空玄'),
        ),
      ),
    );
  });

  test('rejects relationship referencing non-existent character in to', () {
    expect(
      () => const CharacterGraphParser().parse('''
characters:
  - name: 林岚
relationships:
  - from: 林岚
    to: 天魔宗
    type: 归属
    strength: 2
'''),
      throwsA(
        isA<CharacterGraphValidationException>().having(
          (error) => error.message,
          'message',
          contains('关系引用的角色不存在：天魔宗'),
        ),
      ),
    );
  });

  test('accepts valid relationships referencing existing characters', () {
    final document = const CharacterGraphParser().parse('''
characters:
  - name: 林岚
  - name: 司空玄
relationships:
  - from: 林岚
    to: 司空玄
    type: 敌对
    strength: -3
''');

    expect(document.characters, hasLength(2));
    expect(document.relationships, hasLength(1));
    expect(document.relationships.single.fromName, '林岚');
    expect(document.relationships.single.toName, '司空玄');
  });

  test('reports multiple reference errors at once', () {
    expect(
      () => const CharacterGraphParser().parse('''
characters:
  - name: 林岚
relationships:
  - from: 司空玄
    to: 天魔宗
    type: 敌对
    strength: -3
'''),
      throwsA(
        isA<CharacterGraphValidationException>().having(
          (error) => error.message,
          'message',
          allOf(contains('关系引用的角色不存在：司空玄'), contains('关系引用的角色不存在：天魔宗')),
        ),
      ),
    );
  });
}
