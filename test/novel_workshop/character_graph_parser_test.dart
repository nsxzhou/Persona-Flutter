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
}
