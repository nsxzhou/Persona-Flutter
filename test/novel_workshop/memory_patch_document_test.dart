import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/memory_patch_document.dart';

void main() {
  test(
    'parses fenced memory patch with multiline runtime memory block scalar',
    () {
      final document = const MemoryPatchParser().parse('''
```yaml
runtimeMemory:
  storySummary: 林岚抵达雾港。
  chapterArchiveMarkdown: |-
    ## 第 1 章

    林岚抵达雾港。
characters:
  - name: 林岚
    currentStatus: 抵达雾港。
```
''');

      expect(document.hasRuntimeMemoryPatch, isTrue);
      expect(document.hasCharacterGraphPatch, isTrue);
      expect(document.rawYaml, contains('chapterArchiveMarkdown: |-'));
      expect(document.rawYaml, contains('storySummary: 林岚抵达雾港。'));
      expect(
        document.runtimeMemory?['chapterArchiveMarkdown'],
        contains('第 1 章'),
      );
    },
  );

  test(
    'parses unfenced memory patch with multiline runtime memory block scalar',
    () {
      final document = const MemoryPatchParser().parse('''
runtimeMemory:
  storySummary: 林岚抵达雾港。
  chapterArchiveMarkdown: |-
    ## 第 1 章

    林岚抵达雾港。
''');

      expect(document.hasRuntimeMemoryPatch, isTrue);
      expect(document.rawYaml, contains('chapterArchiveMarkdown: |-'));
      expect(document.runtimeMemory?['storySummary'], '林岚抵达雾港。');
    },
  );

  test('rejects malformed memory patch yaml', () {
    expect(
      () => const MemoryPatchParser().parse('''
runtimeMemory:
  chapterArchiveMarkdown: [not valid
'''),
      throwsA(
        isA<MemoryPatchValidationException>().having(
          (error) => error.message,
          'message',
          contains('Patch YAML 解析失败'),
        ),
      ),
    );
  });

  test('rejects non-map root memory patch yaml', () {
    expect(
      () => const MemoryPatchParser().parse('''
- runtimeMemory:
    storySummary: 林岚抵达雾港。
'''),
      throwsA(
        isA<MemoryPatchValidationException>().having(
          (error) => error.message,
          'message',
          contains('Patch YAML 根节点必须是对象'),
        ),
      ),
    );
  });

  test('accepts fenced yaml without restructuring content', () {
    final document = const MemoryPatchParser().parse('''
```yaml
runtimeMemory:
  storySummary: 林岚抵达雾港。
```
''');

    expect(document.rawYaml, contains('runtimeMemory:'));
    expect(document.rawYaml, contains('storySummary: 林岚抵达雾港。'));
  });
}
