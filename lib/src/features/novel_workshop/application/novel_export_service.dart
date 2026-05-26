import 'dart:io';

import 'package:epubx/epubx.dart';
import 'package:file_picker/file_picker.dart';

import '../../projects/domain/writing_project.dart';
import '../domain/novel_workshop.dart';

class NovelExportService {
  const NovelExportService({
    Future<String?> Function({
          required String fileName,
          required FileType type,
          required List<String> allowedExtensions,
        })
        saveFile =
        FilePicker.saveFile,
    Future<void> Function(String path, String content) writeText =
        _defaultWriteText,
    Future<void> Function(String path, List<int> bytes) writeBytes =
        _defaultWriteBytes,
  }) : _saveFile = saveFile,
       _writeText = writeText,
       _writeBytes = writeBytes;

  final Future<String?> Function({
    required String fileName,
    required FileType type,
    required List<String> allowedExtensions,
  })
  _saveFile;
  final Future<void> Function(String path, String content) _writeText;
  final Future<void> Function(String path, List<int> bytes) _writeBytes;

  Future<String?> exportTxt({
    required WritingProject project,
    required List<ChapterVolume> volumes,
    required List<ChapterPlan> plans,
    required List<ProjectChapter> chapters,
  }) async {
    final destination = await _saveFile(
      fileName: '${_safeFilename(project.title)}.txt',
      type: FileType.custom,
      allowedExtensions: const ['txt'],
    );
    if (destination == null) {
      return null;
    }

    final content = buildNovelTxt(
      project: project,
      volumes: volumes,
      plans: plans,
      chapters: chapters,
    );
    await _writeText(destination, content);
    return destination;
  }

  Future<String?> exportEpub({
    required WritingProject project,
    required List<ChapterVolume> volumes,
    required List<ChapterPlan> plans,
    required List<ProjectChapter> chapters,
    required List<ChapterIllustration> illustrations,
  }) async {
    final destination = await _saveFile(
      fileName: '${_safeFilename(project.title)}.epub',
      type: FileType.custom,
      allowedExtensions: const ['epub'],
    );
    if (destination == null) {
      return null;
    }

    final bytes = await buildNovelEpub(
      project: project,
      volumes: volumes,
      plans: plans,
      chapters: chapters,
      illustrations: illustrations,
    );
    await _writeBytes(destination, bytes);
    return destination;
  }
}

Future<List<int>> buildNovelEpub({
  required WritingProject project,
  required List<ChapterVolume> volumes,
  required List<ChapterPlan> plans,
  required List<ProjectChapter> chapters,
  required List<ChapterIllustration> illustrations,
}) async {
  final orderedPlans = _orderedPlans(volumes: volumes, plans: plans);
  final chapterByPlanId = {
    for (final chapter in chapters) chapter.chapterPlanId: chapter,
  };
  final insertedIllustrations =
      illustrations
          .where((item) => item.status == ChapterIllustrationStatus.inserted)
          .toList(growable: false)
        ..sort((a, b) {
          final paragraph = a.paragraphIndex.compareTo(b.paragraphIndex);
          if (paragraph != 0) return paragraph;
          return a.createdAt.compareTo(b.createdAt);
        });
  final illustrationsByChapterId = <String, List<ChapterIllustration>>{};
  for (final illustration in insertedIllustrations) {
    illustrationsByChapterId
        .putIfAbsent(illustration.chapterId, () => <ChapterIllustration>[])
        .add(illustration);
  }

  final content = EpubContent();
  final manifestItems = <EpubManifestItem>[];
  final spineItems = <EpubSpineItemRef>[];
  _addTextFile(
    content,
    manifestItems,
    'style.css',
    'css/style.css',
    'text/css',
    EpubContentType.CSS,
    _epubCss,
  );
  _addTextFile(
    content,
    manifestItems,
    'toc',
    'toc.ncx',
    'application/x-dtbncx+xml',
    EpubContentType.DTBOOK_NCX,
    _buildNcx(project.title, orderedPlans),
  );

  for (var index = 0; index < orderedPlans.length; index += 1) {
    final plan = orderedPlans[index];
    final chapter = chapterByPlanId[plan.id];
    final fileName = 'chapters/chapter-${index + 1}.xhtml';
    final id = 'chapter-${index + 1}';
    final chapterIllustrations = chapter == null
        ? const <ChapterIllustration>[]
        : illustrationsByChapterId[chapter.id] ?? const <ChapterIllustration>[];
    final imageRefs = <String, String>{};
    for (
      var imageIndex = 0;
      imageIndex < chapterIllustrations.length;
      imageIndex += 1
    ) {
      final illustration = chapterIllustrations[imageIndex];
      final bytes = await File(illustration.localPath).readAsBytes();
      final imagePath =
          'images/${illustration.id}${_extensionForMime(illustration.mimeType)}';
      _addByteFile(
        content,
        manifestItems,
        'image-${illustration.id}',
        imagePath,
        illustration.mimeType,
        _contentTypeForMime(illustration.mimeType),
        bytes,
      );
      imageRefs[illustration.id] = '../$imagePath';
    }

    _addTextFile(
      content,
      manifestItems,
      id,
      fileName,
      'application/xhtml+xml',
      EpubContentType.XHTML_1_1,
      _buildChapterXhtml(
        title: _chapterTitle(plan),
        bodyMarkdown: chapter?.contentMarkdown ?? '',
        illustrations: chapterIllustrations,
        imageRefs: imageRefs,
      ),
    );
    spineItems.add(
      EpubSpineItemRef()
        ..IdRef = id
        ..IsLinear = true,
    );
  }

  final book = EpubBook()
    ..Title = project.title.trim()
    ..Author = ''
    ..AuthorList = <String>[]
    ..Content = content
    ..Chapters = <EpubChapter>[]
    ..Schema = (EpubSchema()
      ..ContentDirectoryPath = 'OEBPS'
      ..Package = (EpubPackage()
        ..Version = EpubVersion.Epub2
        ..Metadata = (EpubMetadata()
          ..Titles = [project.title.trim()]
          ..Creators = <EpubMetadataCreator>[]
          ..Subjects = <String>[]
          ..Description = project.description.trim().isEmpty
              ? null
              : project.description.trim()
          ..Publishers = <String>[]
          ..Types = <String>[]
          ..Formats = ['application/epub+zip']
          ..Identifiers = []
          ..Sources = <String>[]
          ..Languages = [_epubLanguage(project.language)]
          ..Relations = <String>[]
          ..Coverages = <String>[]
          ..Rights = <String>[])
        ..Manifest = (EpubManifest()..Items = manifestItems)
        ..Spine = (EpubSpine()
          ..TableOfContents = 'toc'
          ..Items = spineItems
          ..ltr = true)
        ..Guide = (EpubGuide()..Items = <EpubGuideReference>[]))
      ..Navigation = null);

  final bytes = EpubWriter.writeBook(book);
  if (bytes == null || bytes.isEmpty) {
    throw StateError('EPUB 生成失败。');
  }
  return bytes;
}

String buildNovelTxt({
  required WritingProject project,
  required List<ChapterVolume> volumes,
  required List<ChapterPlan> plans,
  required List<ProjectChapter> chapters,
}) {
  final buffer = StringBuffer()..writeln(project.title.trim());
  final sortedVolumes = [...volumes]
    ..sort((a, b) => a.volumeIndex.compareTo(b.volumeIndex));
  final sortedPlans = [...plans]
    ..sort((a, b) {
      final volumeCompare = a.volumeIndex.compareTo(b.volumeIndex);
      if (volumeCompare != 0) {
        return volumeCompare;
      }
      return a.chapterIndex.compareTo(b.chapterIndex);
    });
  final chapterByPlanId = {
    for (final chapter in chapters) chapter.chapterPlanId: chapter,
  };

  for (final volume in sortedVolumes) {
    final volumePlans = sortedPlans
        .where((plan) => plan.volumeId == volume.id)
        .toList(growable: false);
    if (volumePlans.isEmpty) {
      continue;
    }
    _writeSeparatedLine(buffer, _volumeTitle(volume));
    for (final plan in volumePlans) {
      _writeSeparatedLine(buffer, _chapterTitle(plan));
      final body = plainTextFromMarkdown(
        chapterByPlanId[plan.id]?.contentMarkdown ?? '',
      );
      if (body.isNotEmpty) {
        buffer.writeln(body);
      }
    }
  }

  final knownPlanIds = sortedVolumes
      .expand(
        (volume) => sortedPlans
            .where((plan) => plan.volumeId == volume.id)
            .map((plan) => plan.id),
      )
      .toSet();
  for (final plan in sortedPlans.where(
    (plan) => !knownPlanIds.contains(plan.id),
  )) {
    _writeSeparatedLine(buffer, _chapterTitle(plan));
    final body = plainTextFromMarkdown(
      chapterByPlanId[plan.id]?.contentMarkdown ?? '',
    );
    if (body.isNotEmpty) {
      buffer.writeln(body);
    }
  }

  return buffer.toString().trimRight();
}

String plainTextFromMarkdown(String markdown) {
  var text = _stripFrontMatter(markdown).trim();
  text = _stripFenceWrapper(text);
  final lines = text
      .split('\n')
      .map((line) {
        var value = line.trimRight();
        value = value.replaceFirst(RegExp(r'^\s{0,3}#{1,6}\s+'), '');
        value = value.replaceAllMapped(
          RegExp(r'!?\[([^\]]*)\]\([^)]+\)'),
          (match) => match.group(1) ?? '',
        );
        value = value.replaceAllMapped(
          RegExp(r'(\*\*|__)(.*?)\1'),
          (match) => match.group(2) ?? '',
        );
        value = value.replaceAllMapped(
          RegExp(r'(\*|_)(.*?)\1'),
          (match) => match.group(2) ?? '',
        );
        value = value.replaceAllMapped(
          RegExp(r'`([^`]*)`'),
          (match) => match.group(1) ?? '',
        );
        value = value.replaceFirst(RegExp(r'^\s*[-*+]\s+'), '');
        value = value.replaceFirst(RegExp(r'^\s*\d+\.\s+'), '');
        return value.trimRight();
      })
      .toList(growable: false);
  return lines.join('\n').trim();
}

Future<void> _defaultWriteText(String path, String content) {
  return File(path).writeAsString(content, flush: true);
}

Future<void> _defaultWriteBytes(String path, List<int> bytes) {
  return File(path).writeAsBytes(bytes, flush: true);
}

List<ChapterPlan> _orderedPlans({
  required List<ChapterVolume> volumes,
  required List<ChapterPlan> plans,
}) {
  final sortedVolumes = [...volumes]
    ..sort((a, b) => a.volumeIndex.compareTo(b.volumeIndex));
  final sortedPlans = [...plans]
    ..sort((a, b) {
      final volumeCompare = a.volumeIndex.compareTo(b.volumeIndex);
      if (volumeCompare != 0) return volumeCompare;
      return a.chapterIndex.compareTo(b.chapterIndex);
    });
  final ordered = <ChapterPlan>[];
  final knownPlanIds = <String>{};
  for (final volume in sortedVolumes) {
    final volumePlans = sortedPlans
        .where((plan) => plan.volumeId == volume.id)
        .toList(growable: false);
    ordered.addAll(volumePlans);
    knownPlanIds.addAll(volumePlans.map((plan) => plan.id));
  }
  ordered.addAll(sortedPlans.where((plan) => !knownPlanIds.contains(plan.id)));
  return ordered;
}

void _addTextFile(
  EpubContent content,
  List<EpubManifestItem> manifest,
  String id,
  String fileName,
  String mimeType,
  EpubContentType contentType,
  String fileContent,
) {
  final file = EpubTextContentFile()
    ..FileName = fileName
    ..ContentMimeType = mimeType
    ..ContentType = contentType
    ..Content = fileContent;
  content.AllFiles![fileName] = file;
  if (contentType == EpubContentType.XHTML_1_1) {
    content.Html![fileName] = file;
  } else if (contentType == EpubContentType.CSS) {
    content.Css![fileName] = file;
  }
  manifest.add(
    EpubManifestItem()
      ..Id = id
      ..Href = fileName
      ..MediaType = mimeType,
  );
}

void _addByteFile(
  EpubContent content,
  List<EpubManifestItem> manifest,
  String id,
  String fileName,
  String mimeType,
  EpubContentType contentType,
  List<int> bytes,
) {
  final file = EpubByteContentFile()
    ..FileName = fileName
    ..ContentMimeType = mimeType
    ..ContentType = contentType
    ..Content = bytes;
  content.AllFiles![fileName] = file;
  if (_isImageContentType(contentType)) {
    content.Images![fileName] = file;
  }
  manifest.add(
    EpubManifestItem()
      ..Id = id
      ..Href = fileName
      ..MediaType = mimeType,
  );
}

bool _isImageContentType(EpubContentType type) {
  return switch (type) {
    EpubContentType.IMAGE_GIF ||
    EpubContentType.IMAGE_JPEG ||
    EpubContentType.IMAGE_PNG ||
    EpubContentType.IMAGE_SVG ||
    EpubContentType.IMAGE_BMP => true,
    _ => false,
  };
}

String _buildChapterXhtml({
  required String title,
  required String bodyMarkdown,
  required List<ChapterIllustration> illustrations,
  required Map<String, String> imageRefs,
}) {
  final illustrationsByParagraph = <int, List<ChapterIllustration>>{};
  for (final illustration in illustrations) {
    illustrationsByParagraph
        .putIfAbsent(illustration.paragraphIndex, () => <ChapterIllustration>[])
        .add(illustration);
  }
  final paragraphs = readerParagraphsFromMarkdown(bodyMarkdown);
  final body = StringBuffer()..writeln('<h1>${_xml(title)}</h1>');
  for (var index = 0; index < paragraphs.length; index += 1) {
    body.writeln('<p>${_xml(paragraphs[index])}</p>');
    for (final illustration
        in illustrationsByParagraph[index] ?? const <ChapterIllustration>[]) {
      final src = imageRefs[illustration.id];
      if (src == null) continue;
      body
        ..writeln('<div class="illustration">')
        ..writeln(
          '<img src="${_xmlAttribute(src)}" '
          'alt="${_xmlAttribute(illustration.selectedText)}" />',
        )
        ..writeln('<p class="caption">${_xml(illustration.selectedText)}</p>')
        ..writeln('</div>');
    }
  }
  if (paragraphs.isEmpty) {
    body.writeln('<p></p>');
  }
  return '''<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="zh-CN">
<head>
  <title>${_xml(title)}</title>
  <link rel="stylesheet" type="text/css" href="../css/style.css" />
</head>
<body>
${body.toString().trimRight()}
</body>
</html>''';
}

String _buildNcx(String title, List<ChapterPlan> plans) {
  final buffer = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="utf-8"?>')
    ..writeln(
      '<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">',
    )
    ..writeln(
      '<head><meta name="dtb:uid" '
      'content="${_xmlAttribute(title)}" /></head>',
    )
    ..writeln('<docTitle><text>${_xml(title)}</text></docTitle>')
    ..writeln('<navMap>');
  for (var index = 0; index < plans.length; index += 1) {
    final chapterTitle = _chapterTitle(plans[index]);
    buffer
      ..writeln(
        '<navPoint id="nav-chapter-${index + 1}" playOrder="${index + 1}">',
      )
      ..writeln('<navLabel><text>${_xml(chapterTitle)}</text></navLabel>')
      ..writeln('<content src="chapters/chapter-${index + 1}.xhtml" />')
      ..writeln('</navPoint>');
  }
  buffer
    ..writeln('</navMap>')
    ..writeln('</ncx>');
  return buffer.toString();
}

List<String> readerParagraphsFromMarkdown(String markdown) {
  final text = plainTextFromMarkdown(markdown);
  if (text.trim().isEmpty) {
    return const <String>[];
  }
  return text
      .split(RegExp(r'\n\s*\n'))
      .map((paragraph) => paragraph.trim())
      .where((paragraph) => paragraph.isNotEmpty)
      .toList(growable: false);
}

String _xml(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}

String _xmlAttribute(String value) {
  return _xml(value).replaceAll('"', '&quot;').replaceAll("'", '&apos;');
}

String _epubLanguage(String language) {
  final normalized = language.trim().toLowerCase();
  if (normalized.contains('中文') || normalized.contains('chinese')) {
    return 'zh-CN';
  }
  if (normalized.isEmpty) {
    return 'zh-CN';
  }
  return normalized;
}

String _extensionForMime(String mimeType) {
  return switch (mimeType.toLowerCase()) {
    'image/jpeg' || 'image/jpg' => '.jpg',
    'image/webp' => '.webp',
    'image/gif' => '.gif',
    'image/svg+xml' => '.svg',
    'image/bmp' => '.bmp',
    _ => '.png',
  };
}

EpubContentType _contentTypeForMime(String mimeType) {
  return switch (mimeType.toLowerCase()) {
    'image/jpeg' || 'image/jpg' => EpubContentType.IMAGE_JPEG,
    'image/gif' => EpubContentType.IMAGE_GIF,
    'image/svg+xml' => EpubContentType.IMAGE_SVG,
    'image/bmp' => EpubContentType.IMAGE_BMP,
    _ => EpubContentType.IMAGE_PNG,
  };
}

const _epubCss = '''
body {
  font-family: serif;
  line-height: 1.85;
  margin: 1.2em 1.4em;
}
h1 {
  font-size: 1.5em;
  margin-bottom: 1.2em;
}
p {
  margin: 0 0 1em 0;
}
.illustration {
  margin: 1.4em 0;
  text-align: center;
}
img {
  max-width: 100%;
  height: auto;
}
.caption {
  color: #666;
  font-size: .86em;
  margin-top: .5em;
}
''';

void _writeSeparatedLine(StringBuffer buffer, String line) {
  if (buffer.isNotEmpty) {
    buffer.writeln();
  }
  buffer.writeln(line);
}

String _volumeTitle(ChapterVolume volume) {
  final title = volume.title.trim();
  return title.isEmpty
      ? '第 ${volume.volumeIndex} 卷'
      : '第 ${volume.volumeIndex} 卷 $title';
}

String _chapterTitle(ChapterPlan plan) {
  final title = plan.objectiveCard.chapterTitle.trim();
  return title.isEmpty
      ? '第 ${plan.chapterIndex} 章'
      : '第 ${plan.chapterIndex} 章 $title';
}

String _safeFilename(String value) {
  final normalized = value.trim().replaceAll(RegExp(r'[\\/:*?"<>|]+'), '_');
  return normalized.isEmpty ? 'persona-novel' : normalized;
}

String _stripFrontMatter(String markdown) {
  final normalized = markdown.trimLeft();
  if (!normalized.startsWith('---\n')) {
    return markdown;
  }
  final end = normalized.indexOf('\n---', 4);
  if (end < 0) {
    return markdown;
  }
  final bodyStart = normalized.indexOf('\n', end + 4);
  return bodyStart < 0 ? '' : normalized.substring(bodyStart);
}

String _stripFenceWrapper(String raw) {
  final trimmed = raw.trim();
  final match = RegExp(
    r'^```(?:markdown|md|text|txt)?\s*([\s\S]*?)\s*```$',
    caseSensitive: false,
  ).firstMatch(trimmed);
  return match?.group(1)?.trim() ?? trimmed;
}
