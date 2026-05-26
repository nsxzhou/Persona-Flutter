import 'dart:io';

import 'package:epubx/epubx.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persona_flutter/src/features/novel_workshop/application/novel_export_service.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/novel_workshop.dart';
import 'package:persona_flutter/src/features/novel_workshop/domain/writing_context.dart';
import 'package:persona_flutter/src/features/projects/domain/writing_project.dart';

void main() {
  test('buildNovelTxt exports volumes all chapter headings and saved body', () {
    final text = buildNovelTxt(
      project: _project(),
      volumes: [_volume()],
      plans: [
        _plan(id: 'plan-1', index: 1, title: '雨夜门诊'),
        _plan(id: 'plan-2', index: 2, title: '空章'),
      ],
      chapters: [
        _chapter(
          planId: 'plan-1',
          index: 1,
          content: '''---
meta: value
---
# 雨夜门诊

庄子昂走进门诊。

**警报**在走廊尽头响起，[线索](https://example.com)浮出水面。
''',
        ),
      ],
    );

    expect(text, '''雾港纪事

第 1 卷 第一卷

第 1 章 雨夜门诊
雨夜门诊

庄子昂走进门诊。

警报在走廊尽头响起，线索浮出水面。

第 2 章 空章''');
  });

  test('plainTextFromMarkdown strips common markdown syntax', () {
    expect(
      plainTextFromMarkdown('''
```markdown
## 标题

- **重点**和*旁白*
- `暗号`
```
'''),
      '标题\n\n重点和旁白\n暗号',
    );
  });

  test(
    'buildNovelEpub includes inserted illustrations and excludes inactive illustrations',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'novel-epub-test',
      );
      addTearDown(() => directory.delete(recursive: true));
      final acceptedFile = File('${directory.path}/accepted.png');
      await acceptedFile.writeAsBytes(<int>[137, 80, 78, 71]);
      final draftFile = File('${directory.path}/draft.png');
      await draftFile.writeAsBytes(<int>[0, 1, 2, 3]);

      final bytes = await buildNovelEpub(
        project: _project(),
        volumes: [_volume()],
        plans: [_plan(id: 'plan-1', index: 1, title: '雨夜&门诊')],
        chapters: [
          _chapter(
            planId: 'plan-1',
            index: 1,
            content: '庄子昂走进门诊。\n\n警报在走廊尽头响起。',
          ),
        ],
        illustrations: [
          _illustration(
            id: 'inserted',
            localPath: acceptedFile.path,
            status: ChapterIllustrationStatus.inserted,
            selectedText: '警报 "亮起" & 转红',
            paragraphIndex: 1,
          ),
          _illustration(
            id: 'draft',
            localPath: draftFile.path,
            status: ChapterIllustrationStatus.draft,
            selectedText: '未采用草稿',
            paragraphIndex: 0,
          ),
          _illustration(
            id: 'unused',
            localPath: draftFile.path,
            status: ChapterIllustrationStatus.unused,
            selectedText: '已移出正文',
            paragraphIndex: 0,
          ),
        ],
      );
      final book = await EpubReader.readBook(bytes);
      final chapterXhtml =
          book.Content!.Html!['chapters/chapter-1.xhtml']!.Content!;

      expect(bytes, isNotEmpty);
      expect(book.Content!.AllFiles, contains('images/inserted.png'));
      expect(book.Content!.AllFiles, isNot(contains('images/draft.png')));
      expect(book.Content!.AllFiles, isNot(contains('images/unused.png')));
      expect(chapterXhtml, contains('../images/inserted.png'));
      expect(chapterXhtml, isNot(contains('images/draft.png')));
      expect(chapterXhtml, isNot(contains('images/unused.png')));
      expect(chapterXhtml, contains('警报 &quot;亮起&quot; &amp; 转红'));
      expect(book.Content!.AllFiles!['toc.ncx'], isNotNull);
    },
  );
}

WritingProject _project() {
  return WritingProject(
    id: 'project-1',
    title: '雾港纪事',
    description: '',
    status: ProjectStatus.active,
    defaultProviderId: null,
    defaultModelName: null,
    createdAt: DateTime(2026, 5, 24),
    updatedAt: DateTime(2026, 5, 24),
  );
}

ChapterVolume _volume() {
  return ChapterVolume(
    id: 'volume-1',
    projectId: 'project-1',
    volumeIndex: 1,
    title: '第一卷',
    createdAt: DateTime(2026, 5, 24),
    updatedAt: DateTime(2026, 5, 24),
  );
}

ChapterPlan _plan({
  required String id,
  required int index,
  required String title,
}) {
  return ChapterPlan(
    id: id,
    projectId: 'project-1',
    volumeId: 'volume-1',
    volumeIndex: 1,
    volumeTitle: '第一卷',
    chapterLocalIndex: index,
    chapterIndex: index,
    objectiveCard: ChapterObjectiveCard(chapterTitle: title),
    coreEvent: '',
    emotionArc: '',
    chapterHook: '',
    outlineMarkdown: '',
    createdAt: DateTime(2026, 5, 24),
    updatedAt: DateTime(2026, 5, 24),
  );
}

ProjectChapter _chapter({
  required String planId,
  required int index,
  required String content,
}) {
  return ProjectChapter(
    id: 'chapter-$index',
    projectId: 'project-1',
    chapterPlanId: planId,
    chapterIndex: index,
    title: '第 $index 章',
    contentMarkdown: content,
    contentHash: content.hashCode.toString(),
    continuityVerdict: ContinuityVerdict.pass,
    continuityReportMarkdown: '',
    memorySyncStatus: MemorySyncStatus.idle,
    memorySyncContentHash: '',
    memorySyncProposedRuntimeState: '',
    memorySyncProposedRuntimeThreads: '',
    memorySyncProposedStorySummary: '',
    createdAt: DateTime(2026, 5, 24),
    updatedAt: DateTime(2026, 5, 24),
  );
}

ChapterIllustration _illustration({
  required String id,
  required String localPath,
  required ChapterIllustrationStatus status,
  required String selectedText,
  required int paragraphIndex,
}) {
  return ChapterIllustration(
    id: id,
    projectId: 'project-1',
    chapterId: 'chapter-1',
    chapterPlanId: 'plan-1',
    paragraphIndex: paragraphIndex,
    anchorTextHash: 'hash-$id',
    selectedText: selectedText,
    prompt: selectedText,
    providerId: 'provider-1',
    modelName: 'image-model',
    localPath: localPath,
    mimeType: 'image/png',
    status: status,
    createdAt: DateTime(2026, 5, 24),
    updatedAt: DateTime(2026, 5, 24),
    acceptedAt: status == ChapterIllustrationStatus.inserted
        ? DateTime(2026, 5, 24)
        : null,
  );
}
