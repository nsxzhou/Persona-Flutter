import 'package:yaml/yaml.dart';

import '../domain/writing_context.dart';

class OutlineDetailDocument {
  const OutlineDetailDocument({required this.volumes});

  final List<OutlineVolumeDraft> volumes;

  List<OutlineChapterDraft> get chapters {
    return [for (final volume in volumes) ...volume.chapters];
  }
}

class OutlineVolumeDraft {
  const OutlineVolumeDraft({
    required this.volumeIndex,
    required this.title,
    required this.chapters,
  });

  final int volumeIndex;
  final String title;
  final List<OutlineChapterDraft> chapters;
}

class OutlineChapterDraft {
  const OutlineChapterDraft({
    required this.volumeIndex,
    required this.volumeTitle,
    required this.chapterLocalIndex,
    required this.chapterIndex,
    required this.objectiveCard,
    required this.coreEvent,
    required this.emotionArc,
    required this.chapterHook,
    required this.outlineMarkdown,
  });

  final int volumeIndex;
  final String volumeTitle;
  final int chapterLocalIndex;
  final int chapterIndex;
  final ChapterObjectiveCard objectiveCard;
  final String coreEvent;
  final String emotionArc;
  final String chapterHook;
  final String outlineMarkdown;
}

class OutlineDetailParser {
  const OutlineDetailParser();

  OutlineDetailDocument parse(String yamlText) {
    final trimmed = yamlText.trim();
    if (trimmed.isEmpty) {
      throw const OutlineDetailValidationException('分卷与章节细纲不能为空。');
    }

    final parsed = loadYaml(trimmed);
    if (parsed is! YamlMap) {
      throw const OutlineDetailValidationException('细纲 YAML 根节点必须是对象。');
    }
    final volumesValue = parsed['volumes'];
    if (volumesValue is! YamlList && volumesValue is! List) {
      throw const OutlineDetailValidationException('细纲 YAML 缺少 volumes 分卷列表。');
    }

    final volumeItems = volumesValue as Iterable<Object?>;
    if (volumeItems.isEmpty) {
      throw const OutlineDetailValidationException('细纲 YAML 至少需要一个 volume。');
    }

    final seenVolumeIndexes = <int>{};
    final volumes = <OutlineVolumeDraft>[];
    var wholeBookIndex = 1;
    for (
      var volumeOffset = 0;
      volumeOffset < volumeItems.length;
      volumeOffset += 1
    ) {
      final volumePath = 'volumes[$volumeOffset]';
      final volumeMap = _requireMap(
        volumeItems.elementAt(volumeOffset),
        volumePath,
      );
      final volumeIndex = _requiredPositiveInt(volumeMap, 'index', volumePath);
      final volumeTitle = _requiredString(volumeMap, 'title', volumePath);
      if (!seenVolumeIndexes.add(volumeIndex)) {
        throw OutlineDetailValidationException('分卷序号重复：$volumeIndex。');
      }

      final chaptersValue = volumeMap['chapters'];
      if (chaptersValue is! YamlList && chaptersValue is! List) {
        throw OutlineDetailValidationException('$volumePath 缺少 chapters 章节列表。');
      }
      final chapterItems = chaptersValue as Iterable<Object?>;
      if (chapterItems.isEmpty) {
        throw OutlineDetailValidationException('$volumePath 至少需要一个 chapter。');
      }

      final seenChapterIndexes = <int>{};
      final chapters = <OutlineChapterDraft>[];
      for (
        var chapterOffset = 0;
        chapterOffset < chapterItems.length;
        chapterOffset += 1
      ) {
        final chapterPath = '$volumePath.chapters[$chapterOffset]';
        final chapterMap = _requireMap(
          chapterItems.elementAt(chapterOffset),
          chapterPath,
        );
        final localIndex = _requiredPositiveInt(
          chapterMap,
          'index',
          chapterPath,
        );
        final title = _requiredString(chapterMap, 'title', chapterPath);
        if (!seenChapterIndexes.add(localIndex)) {
          throw OutlineDetailValidationException(
            '$volumePath 章节序号重复：$localIndex。',
          );
        }
        final objective = _string(chapterMap, 'objective');
        final pressureSource = _string(chapterMap, 'pressureSource');
        final payoffTarget = _string(chapterMap, 'payoffTarget');
        final relationshipShift = _string(chapterMap, 'relationshipShift');
        final hookType = _string(chapterMap, 'hookType');
        final coreEvent = _string(chapterMap, 'coreEvent');
        final emotionArc = _string(chapterMap, 'emotionArc');
        final chapterHook = _string(chapterMap, 'chapterHook');
        final outlineMarkdown = _string(chapterMap, 'outlineMarkdown');
        chapters.add(
          OutlineChapterDraft(
            volumeIndex: volumeIndex,
            volumeTitle: volumeTitle,
            chapterLocalIndex: localIndex,
            chapterIndex: wholeBookIndex,
            objectiveCard: ChapterObjectiveCard(
              chapterTitle: title,
              objective: objective,
              pressureSource: pressureSource,
              payoffTarget: payoffTarget,
              relationshipShift: relationshipShift,
              hookType: hookType,
            ),
            coreEvent: coreEvent,
            emotionArc: emotionArc,
            chapterHook: chapterHook,
            outlineMarkdown: outlineMarkdown,
          ),
        );
        wholeBookIndex += 1;
      }

      volumes.add(
        OutlineVolumeDraft(
          volumeIndex: volumeIndex,
          title: volumeTitle,
          chapters: List.unmodifiable(chapters),
        ),
      );
    }

    return OutlineDetailDocument(volumes: List.unmodifiable(volumes));
  }

  Map<Object?, Object?> _requireMap(Object? value, String path) {
    if (value is YamlMap) {
      return value;
    }
    if (value is Map<Object?, Object?>) {
      return value;
    }
    throw OutlineDetailValidationException('$path 必须是对象。');
  }

  int _requiredPositiveInt(Map<Object?, Object?> map, String key, String path) {
    final value = map[key];
    if (value == null) {
      throw OutlineDetailValidationException('$path 缺少 $key。');
    }
    if (value is! int || value <= 0) {
      throw OutlineDetailValidationException('$path.$key 必须是正整数。');
    }
    return value;
  }

  String _requiredString(Map<Object?, Object?> map, String key, String path) {
    final value = map[key];
    if (value == null) {
      throw OutlineDetailValidationException('$path 缺少 $key。');
    }
    if (value is! String || value.trim().isEmpty) {
      throw OutlineDetailValidationException('$path.$key 必须是非空字符串。');
    }
    return value.trim();
  }

  String _string(Map<Object?, Object?> map, String key) {
    final value = map[key];
    if (value == null) {
      return '';
    }
    if (value is! String) {
      throw OutlineDetailValidationException('$key 必须是字符串。');
    }
    return value.trim();
  }
}

class OutlineDetailValidationException implements Exception {
  const OutlineDetailValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
