import 'dart:io';

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
  }) : _saveFile = saveFile,
       _writeText = writeText;

  final Future<String?> Function({
    required String fileName,
    required FileType type,
    required List<String> allowedExtensions,
  })
  _saveFile;
  final Future<void> Function(String path, String content) _writeText;

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
