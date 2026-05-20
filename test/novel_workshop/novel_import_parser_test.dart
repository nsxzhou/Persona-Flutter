import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/novel_import_parser.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/novel_import.dart';

void main() {
  test('splits txt content by Chinese chapter headings', () {
    final draft = const NovelImportParser().parseTxt(
      '''
序章内容。

第一章 雾港
林岚抵达雾港。

第 二 章 追踪
港务处灯灭。
''',
      title: '雾港纪事',
      sourceFilename: 'fog.txt',
    );

    expect(draft.sourceType, NovelImportSourceType.txt);
    expect(draft.title, '雾港纪事');
    expect(draft.chapters, hasLength(2));
    expect(draft.chapters.first.title, '第一章 雾港');
    expect(draft.chapters.first.contentMarkdown, contains('序章内容'));
    expect(draft.chapters.last.title, '第二章 追踪');
    expect(draft.totalCharacterCount, greaterThan(0));
  });

  test('falls back to single chapter when headings are absent', () {
    final draft = const NovelImportParser().parseTxt(
      '没有标准标题的正文。',
      title: '',
      sourceFilename: 'draft.txt',
    );

    expect(draft.title, '导入小说');
    expect(draft.chapters, hasLength(1));
    expect(draft.chapters.single.title, '第1章');
    expect(
      draft.warnings,
      contains(NovelImportWarning.noStandardChapterHeadings),
    );
  });

  test('rejects empty txt content', () {
    expect(
      () => const NovelImportParser().parseTxt(
        ' \n\n ',
        title: '空文件',
        sourceFilename: 'empty.txt',
      ),
      throwsA(isA<NovelImportException>()),
    );
  });
}
