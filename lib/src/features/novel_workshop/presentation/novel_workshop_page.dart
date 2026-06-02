import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:diff_match_patch/diff_match_patch.dart' as dmp;

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/reader_settings_provider.dart';
import '../../../core/ui/analysis_lab_widgets.dart';
import '../../../core/ui/glass_container.dart';
import '../../../core/ui/keep_alive_tab_wrapper.dart';
import '../../../core/ui/persona_page.dart';
import '../../../core/ui/skeleton_loader.dart';
import '../../plot_lab/application/plot_lab_providers.dart';
import '../../plot_lab/application/story_engine_normalizer.dart';
import '../../plot_lab/domain/plot_profile.dart';
import '../../projects/application/project_providers.dart';
import '../../projects/domain/writing_project.dart';
import '../../settings/application/image_provider_config_providers.dart';
import '../../settings/application/provider_config_providers.dart';
import '../../settings/domain/image_provider_config.dart';
import '../../settings/domain/provider_config.dart';
import '../../style_lab/application/style_lab_providers.dart';
import '../../style_lab/application/voice_profile_front_matter.dart';
import '../../style_lab/domain/style_profile.dart';
import '../application/character_graph_parser.dart';
import '../application/memory_patch_document.dart';
import '../application/memory_patch_yaml.dart';
import '../application/novel_export_service.dart';
import '../application/novel_workshop_providers.dart';
import '../application/outline_detail_parser.dart';
import '../domain/novel_workshop.dart';
import '../domain/writing_context.dart';
import 'asset_review_state.dart';
import 'character/character_graph_tab.dart';

part 'novel_workshop_page_reader.dart';
part 'novel_workshop_page_illustration.dart';
part 'novel_workshop_page_editor.dart';

const _readerFontFamily = 'Songti SC';

class NovelWorkshopPage extends ConsumerStatefulWidget {
  const NovelWorkshopPage({required this.projectId, super.key});

  final String projectId;

  @override
  ConsumerState<NovelWorkshopPage> createState() => _NovelWorkshopPageState();
}

class NovelEditorPage extends ConsumerStatefulWidget {
  const NovelEditorPage({required this.projectId, super.key});

  final String projectId;

  @override
  ConsumerState<NovelEditorPage> createState() => _NovelEditorPageState();
}

class NovelReaderPage extends ConsumerStatefulWidget {
  const NovelReaderPage({required this.projectId, super.key});

  final String projectId;

  @override
  ConsumerState<NovelReaderPage> createState() => _NovelReaderPageState();
}

class NovelIllustrationLibraryPage extends ConsumerStatefulWidget {
  const NovelIllustrationLibraryPage({
    required this.projectId,
    this.initialPlanId,
    super.key,
  });

  final String projectId;
  final String? initialPlanId;

  @override
  ConsumerState<NovelIllustrationLibraryPage> createState() =>
      _NovelIllustrationLibraryPageState();
}


class _IllustrationImagePreview extends StatefulWidget {
  const _IllustrationImagePreview({
    required this.localPath,
    this.width,
    this.height,
    this.maxHeight,
    this.borderRadius = 6,
    this.compactError = false,
  });

  final String localPath;
  final double? width;
  final double? height;
  final double? maxHeight;
  final double borderRadius;
  final bool compactError;

  @override
  State<_IllustrationImagePreview> createState() =>
      _IllustrationImagePreviewState();
}

class _IllustrationImagePreviewState extends State<_IllustrationImagePreview> {
  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;
  double? _aspectRatio;

  bool get _usesFixedFrame => widget.width != null && widget.height != null;

  @override
  void initState() {
    super.initState();
    if (!_usesFixedFrame) {
      _resolveAspectRatio();
    }
  }

  @override
  void didUpdateWidget(covariant _IllustrationImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localPath != widget.localPath ||
        (oldWidget.width != widget.width ||
            oldWidget.height != widget.height)) {
      _aspectRatio = null;
      _stopListening();
      if (!_usesFixedFrame) {
        _resolveAspectRatio();
      }
    }
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  void _resolveAspectRatio() {
    final provider = FileImage(File(widget.localPath));
    final stream = provider.resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (imageInfo, synchronousCall) {
        final width = imageInfo.image.width;
        final height = imageInfo.image.height;
        if (mounted && width > 0 && height > 0) {
          setState(() => _aspectRatio = width / height);
        }
        stream.removeListener(listener);
      },
      onError: (error, stackTrace) {
        if (mounted) {
          setState(() => _aspectRatio = null);
        }
        stream.removeListener(listener);
      },
    );
    _imageStream = stream;
    _imageListener = listener;
    stream.addListener(listener);
  }

  void _stopListening() {
    final listener = _imageListener;
    if (listener != null) {
      _imageStream?.removeListener(listener);
    }
    _imageStream = null;
    _imageListener = null;
  }

  @override
  Widget build(BuildContext context) {
    final content = _usesFixedFrame
        ? _fixedPreview(context)
        : _adaptivePreview(context);
    return Tooltip(
      message: '预览插图',
      child: Semantics(
        button: true,
        label: '预览插图',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () =>
                _showIllustrationFullscreenPreview(context, widget.localPath),
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _fixedPreview(BuildContext context) {
    return _previewFrame(
      context,
      width: widget.width,
      height: widget.height,
      child: _image(context, width: widget.width, height: widget.height),
    );
  }

  Widget _adaptivePreview(BuildContext context) {
    final viewHeight = MediaQuery.sizeOf(context).height;
    final maxHeight = widget.maxHeight ?? math.min(360, viewHeight * 0.42);
    final aspectRatio = _aspectRatio ?? 1;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = widget.width ?? constraints.maxWidth;
        return Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth.isFinite ? maxWidth : 520,
              maxHeight: maxHeight,
            ),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: _previewFrame(context, child: _image(context)),
            ),
          ),
        );
      },
    );
  }

  Widget _previewFrame(
    BuildContext context, {
    required Widget child,
    double? width,
    double? height,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Container(
        width: width,
        height: height,
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.48),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _image(BuildContext context, {double? width, double? height}) {
    return Image.file(
      File(widget.localPath),
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _illustrationImageError(
        context,
        widget.localPath,
        widget.compactError,
      ),
    );
  }
}

Widget _illustrationImageError(
  BuildContext context,
  String localPath,
  bool compactError,
) {
  final colorScheme = Theme.of(context).colorScheme;
  if (compactError) {
    return Icon(
      Icons.broken_image_outlined,
      color: colorScheme.onSurfaceVariant,
    );
  }
  return Padding(
    padding: const EdgeInsets.all(18),
    child: Text('插图文件不可用：$localPath'),
  );
}

void _showIllustrationFullscreenPreview(
  BuildContext context,
  String localPath,
) {
  showDialog<void>(
    context: context,
    useSafeArea: false,
    barrierColor: Colors.black.withValues(alpha: 0.92),
    builder: (context) => _IllustrationFullscreenPreview(localPath: localPath),
  );
}

class _IllustrationFullscreenPreview extends StatelessWidget {
  const _IllustrationFullscreenPreview({required this.localPath});

  final String localPath;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: InteractiveViewer(
                  minScale: 0.7,
                  maxScale: 5,
                  child: Image.file(
                    File(localPath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: DefaultTextStyle(
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(color: Colors.white),
                            child: _illustrationImageError(
                              context,
                              localPath,
                              false,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: SafeArea(
              child: IconButton.filledTonal(
                onPressed: () => Navigator.of(context).pop(),
                tooltip: '关闭预览',
                icon: const Icon(Icons.close),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _normalizeSelectionText(String value) {
  return value.replaceAll(RegExp(r'\s+'), '');
}

bool _hasSelectionOverlap(String selection, String paragraph) {
  if (selection.isEmpty || paragraph.isEmpty) {
    return false;
  }
  final selectionIsShorter = selection.length < paragraph.length;
  final shorter = selectionIsShorter ? selection : paragraph;
  final longer = selectionIsShorter ? paragraph : selection;
  final windowLength = shorter.length < 12 ? shorter.length : 12;
  if (windowLength < 4) {
    return longer.contains(shorter);
  }
  for (var start = 0; start <= shorter.length - windowLength; start += 1) {
    if (longer.contains(shorter.substring(start, start + windowLength))) {
      return true;
    }
  }
  return false;
}

class _WorkshopLoading extends StatelessWidget {
  const _WorkshopLoading();

  @override
  Widget build(BuildContext context) {
    return const PersonaPage(
      eyebrow: '写作工作台',
      title: '加载中',
      description: '正在读取项目、章节和生成任务。',
      children: [
        PersonaPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 180, height: 16),
              SizedBox(height: 14),
              SkeletonBox(width: 420, height: 12),
              SizedBox(height: 10),
              SkeletonBox(width: 360, height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

class _WorkshopError extends StatelessWidget {
  const _WorkshopError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: '写作工作台',
      title: '无法打开工作台',
      description: message,
      actions: [
        OutlinedButton.icon(
          onPressed: () => context.go('/projects'),
          icon: const Icon(Icons.arrow_back_outlined),
          label: const Text('返回项目'),
        ),
      ],
      children: [
        PersonaPanel(
          child: Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    );
  }
}

class _MissingProjectPage extends StatelessWidget {
  const _MissingProjectPage({required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: '写作工作台',
      title: '项目不存在',
      description: '没有找到项目：$projectId。',
      actions: [
        OutlinedButton.icon(
          onPressed: () => context.go('/projects'),
          icon: const Icon(Icons.arrow_back_outlined),
          label: const Text('返回项目'),
        ),
      ],
      children: const [
        PersonaEmptyStateCard(
          icon: Icons.link_off_outlined,
          title: '无法打开工作台',
          description: '该项目可能已被删除或归档数据不可用。',
        ),
      ],
    );
  }
}

class _ArchivedProjectPage extends StatelessWidget {
  const _ArchivedProjectPage({required this.project});

  final WritingProject project;

  @override
  Widget build(BuildContext context) {
    return PersonaPage(
      eyebrow: '写作工作台',
      title: '项目已归档',
      description: '「${project.title}」已归档，工作台只服务活动项目。',
      actions: [
        OutlinedButton.icon(
          onPressed: () => context.go('/projects'),
          icon: const Icon(Icons.arrow_back_outlined),
          label: const Text('返回项目'),
        ),
      ],
      children: const [
        PersonaEmptyStateCard(
          icon: Icons.inventory_2_outlined,
          title: '归档项目不可编辑',
          description: '请先在项目页恢复项目，再打开写作工作台。',
        ),
      ],
    );
  }
}

enum _DirtyEditorAction { save, discard, cancel }

void _showPlanDialog({
  required BuildContext context,
  required String projectId,
  required List<ChapterVolume> volumes,
  int nextIndex = 1,
  ChapterPlan? plan,
}) {
  showGlassDialog<void>(
    context: context,
    maxWidth: 680,
    maxHeight: MediaQuery.sizeOf(context).height * 0.9,
    builder: (context) => _ChapterPlanDialog(
      projectId: projectId,
      volumes: volumes,
      nextIndex: nextIndex,
      plan: plan,
    ),
  );
}

void _showVolumeDialog({
  required BuildContext context,
  required String projectId,
  int nextIndex = 1,
  ChapterVolume? volume,
}) {
  showGlassDialog<void>(
    context: context,
    maxWidth: 520,
    maxHeight: MediaQuery.sizeOf(context).height * 0.9,
    builder: (context) => _ChapterVolumeDialog(
      projectId: projectId,
      nextIndex: nextIndex,
      volume: volume,
    ),
  );
}

ProjectChapter? _chapterForPlan(List<ProjectChapter> chapters, String planId) {
  return chapters
      .where((chapter) => chapter.chapterPlanId == planId)
      .firstOrNull;
}

ChapterGenerationRun? _latestRunForPlan(
  List<ChapterGenerationRun> runs,
  String planId,
) {
  final matches = runs.where((run) => run.chapterPlanId == planId).toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return matches.firstOrNull;
}

AssetGenerationRun? _latestAssetRun(
  List<AssetGenerationRun> runs,
  AssetGenerationKind kind,
) {
  final matches = runs.where((run) => run.kind == kind).toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return matches.firstOrNull;
}

AssetGenerationKind _assetKindForField(_BibleField field) {
  return switch (field) {
    _BibleField.worldBuilding => AssetGenerationKind.worldBuilding,
    _BibleField.charactersBlueprint => AssetGenerationKind.charactersBlueprint,
    _BibleField.outlineMaster => AssetGenerationKind.outlineMaster,
  };
}

int _nextChapterIndex(List<ChapterPlan> plans) {
  if (plans.isEmpty) {
    return 1;
  }
  return plans
          .map((plan) => plan.chapterIndex)
          .reduce((a, b) => a > b ? a : b) +
      1;
}

int _nextVolumeIndex(List<ChapterVolume> volumes) {
  if (volumes.isEmpty) {
    return 1;
  }
  return volumes
          .map((volume) => volume.volumeIndex)
          .reduce((a, b) => a > b ? a : b) +
      1;
}

String _chapterTitle(ChapterPlan plan) {
  final title = plan.objectiveCard.chapterTitle.trim();
  return title.isEmpty ? '第 ${plan.chapterIndex} 章' : title;
}

String _objectiveSummary(ChapterObjectiveCard card) {
  final values = [
    card.objective,
    card.pressureSource,
    card.payoffTarget,
    card.relationshipShift,
    card.hookType,
  ].map((value) => value.trim()).where((value) => value.isNotEmpty);
  return values.isEmpty ? '未填写章节目标。' : values.take(2).join(' / ');
}

IconData _runIcon(ChapterGenerationStatus status) {
  return switch (status) {
    ChapterGenerationStatus.pending => Icons.schedule,
    ChapterGenerationStatus.running => Icons.sync,
    ChapterGenerationStatus.succeeded => Icons.check_circle_outline,
    ChapterGenerationStatus.failed => Icons.error_outline,
    ChapterGenerationStatus.abandoned => Icons.cancel_outlined,
  };
}

Color _runColor(BuildContext context, ChapterGenerationStatus status) {
  final colorScheme = Theme.of(context).colorScheme;
  return switch (status) {
    ChapterGenerationStatus.pending => colorScheme.onSurfaceVariant,
    ChapterGenerationStatus.running => colorScheme.primary,
    ChapterGenerationStatus.succeeded => Colors.green,
    ChapterGenerationStatus.failed => colorScheme.error,
    ChapterGenerationStatus.abandoned => colorScheme.onSurfaceVariant,
  };
}

String _runStatusLabel(ChapterGenerationStatus status) {
  return switch (status) {
    ChapterGenerationStatus.pending => '等待中',
    ChapterGenerationStatus.running => '运行中',
    ChapterGenerationStatus.succeeded => '成功',
    ChapterGenerationStatus.failed => '失败',
    ChapterGenerationStatus.abandoned => '已放弃',
  };
}

String _generationBatchStatusLabel(ChapterGenerationBatchStatus status) {
  return switch (status) {
    ChapterGenerationBatchStatus.pending => '等待中',
    ChapterGenerationBatchStatus.running => '生成中',
    ChapterGenerationBatchStatus.succeeded => '已完成',
    ChapterGenerationBatchStatus.failed => '已停止',
    ChapterGenerationBatchStatus.abandoned => '已放弃',
  };
}

IconData _generationBatchIcon(ChapterGenerationBatchStatus status) {
  return switch (status) {
    ChapterGenerationBatchStatus.pending => Icons.schedule,
    ChapterGenerationBatchStatus.running => Icons.sync,
    ChapterGenerationBatchStatus.succeeded => Icons.check_circle_outline,
    ChapterGenerationBatchStatus.failed => Icons.error_outline,
    ChapterGenerationBatchStatus.abandoned => Icons.cancel_outlined,
  };
}

Color _generationBatchColor(
  BuildContext context,
  ChapterGenerationBatchStatus status,
) {
  final colorScheme = Theme.of(context).colorScheme;
  return switch (status) {
    ChapterGenerationBatchStatus.pending => colorScheme.onSurfaceVariant,
    ChapterGenerationBatchStatus.running => colorScheme.primary,
    ChapterGenerationBatchStatus.succeeded => Colors.green,
    ChapterGenerationBatchStatus.failed => colorScheme.error,
    ChapterGenerationBatchStatus.abandoned => colorScheme.onSurfaceVariant,
  };
}

String _generationBatchItemStatusLabel(
  ChapterGenerationBatchItemStatus status,
) {
  return switch (status) {
    ChapterGenerationBatchItemStatus.waiting => '等待',
    ChapterGenerationBatchItemStatus.running => '处理中',
    ChapterGenerationBatchItemStatus.synced => '已闭环',
    ChapterGenerationBatchItemStatus.failed => '失败',
    ChapterGenerationBatchItemStatus.abandoned => '已放弃',
  };
}

IconData _generationBatchItemIcon(ChapterGenerationBatchItemStatus status) {
  return switch (status) {
    ChapterGenerationBatchItemStatus.waiting => Icons.schedule,
    ChapterGenerationBatchItemStatus.running => Icons.sync,
    ChapterGenerationBatchItemStatus.synced => Icons.check_circle_outline,
    ChapterGenerationBatchItemStatus.failed => Icons.error_outline,
    ChapterGenerationBatchItemStatus.abandoned => Icons.cancel_outlined,
  };
}

Color _generationBatchItemColor(
  BuildContext context,
  ChapterGenerationBatchItemStatus status,
) {
  final colorScheme = Theme.of(context).colorScheme;
  return switch (status) {
    ChapterGenerationBatchItemStatus.waiting => colorScheme.onSurfaceVariant,
    ChapterGenerationBatchItemStatus.running => colorScheme.primary,
    ChapterGenerationBatchItemStatus.synced => Colors.green,
    ChapterGenerationBatchItemStatus.failed => colorScheme.error,
    ChapterGenerationBatchItemStatus.abandoned => colorScheme.onSurfaceVariant,
  };
}

Color _continuityVerdictColor(BuildContext context, ContinuityVerdict verdict) {
  final colorScheme = Theme.of(context).colorScheme;
  return switch (verdict) {
    ContinuityVerdict.pass => const Color(0xFF16825D),
    ContinuityVerdict.warning => colorScheme.tertiary,
    ContinuityVerdict.fail => colorScheme.error,
  };
}

IconData _continuityVerdictIcon(ContinuityVerdict verdict) {
  return switch (verdict) {
    ContinuityVerdict.pass => Icons.verified_outlined,
    ContinuityVerdict.warning => Icons.report_problem_outlined,
    ContinuityVerdict.fail => Icons.error_outline,
  };
}

String _continuityVerdictLabel(ContinuityVerdict verdict) {
  return switch (verdict) {
    ContinuityVerdict.pass => '审计 pass',
    ContinuityVerdict.warning => '审计 warning',
    ContinuityVerdict.fail => '审计 fail',
  };
}

String _bibleCompletenessLabel(ProjectBible bible) {
  final sections = [
    bible.descriptionMarkdown,
    bible.worldBuildingMarkdown,
    bible.charactersBlueprintMarkdown,
    bible.outlineMasterMarkdown,
    bible.outlineDetailYaml,
  ];
  final filled = sections.where((value) => value.trim().isNotEmpty).length;
  return '$filled/${sections.length}';
}

bool _projectBibleIsEmpty(ProjectBible bible) {
  return [
    bible.descriptionMarkdown,
    bible.worldBuildingMarkdown,
    bible.charactersBlueprintMarkdown,
    bible.outlineMasterMarkdown,
    bible.outlineDetailYaml,
  ].every((value) => value.trim().isEmpty);
}

String _markdownFor(ProjectBible bible, _BibleField field) {
  return switch (field) {
    _BibleField.worldBuilding => bible.worldBuildingMarkdown,
    _BibleField.charactersBlueprint => bible.charactersBlueprintMarkdown,
    _BibleField.outlineMaster => bible.outlineMasterMarkdown,
  };
}

ProjectBibleInput _inputFor(
  ProjectBible bible,
  _BibleField field,
  String markdown,
) {
  return ProjectBibleInput(
    projectId: bible.projectId,
    descriptionMarkdown: bible.descriptionMarkdown,
    worldBuildingMarkdown: field == _BibleField.worldBuilding
        ? markdown
        : bible.worldBuildingMarkdown,
    charactersBlueprintMarkdown: field == _BibleField.charactersBlueprint
        ? markdown
        : bible.charactersBlueprintMarkdown,
    outlineMasterMarkdown: field == _BibleField.outlineMaster
        ? markdown
        : bible.outlineMasterMarkdown,
    outlineDetailYaml: bible.outlineDetailYaml,
  );
}

String _dateLabel(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')} '
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}

String _metadataValue(Object? value) {
  if (value == null) {
    return '';
  }
  if (value is Iterable) {
    return value.map((item) => item.toString()).join(', ');
  }
  return value.toString();
}

List<ChapterPlan> _orderedChapterPlans({
  required List<ChapterVolume> volumes,
  required List<ChapterPlan> plans,
}) {
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

ChapterPlan _emptyReaderPlan(String projectId) {
  final now = DateTime.now();
  return ChapterPlan(
    id: '',
    projectId: projectId,
    volumeId: '',
    volumeIndex: 0,
    volumeTitle: '',
    chapterLocalIndex: 0,
    chapterIndex: 0,
    objectiveCard: const ChapterObjectiveCard(),
    coreEvent: '',
    emotionArc: '',
    chapterHook: '',
    outlineMarkdown: '',
    createdAt: now,
    updatedAt: now,
  );
}

ProjectChapter _emptyReaderChapter(String projectId, ChapterPlan plan) {
  final now = DateTime.now();
  return ProjectChapter(
    id: '',
    projectId: projectId,
    chapterPlanId: plan.id,
    chapterIndex: plan.chapterIndex,
    title: _chapterTitle(plan),
    contentMarkdown: '',
    contentHash: '',
    continuityVerdict: ContinuityVerdict.pass,
    continuityReportMarkdown: '',
    memorySyncStatus: MemorySyncStatus.idle,
    memorySyncContentHash: '',
    memorySyncProposedRuntimeState: '',
    memorySyncProposedRuntimeThreads: '',
    memorySyncProposedStorySummary: '',
    createdAt: now,
    updatedAt: now,
  );
}

Future<bool> _showIllustrationDialog(
  BuildContext context, {
  required ProjectChapter chapter,
  required int paragraphIndex,
  required String selectedText,
  required List<ImageProviderConfig> providers,
  String? initialPrompt,
  String? initialPromptError,
}) {
  return showGlassDialog<bool>(
    context: context,
    maxWidth: 860,
    builder: (context) => _GenerateIllustrationDialog(
      chapter: chapter,
      paragraphIndex: paragraphIndex,
      selectedText: selectedText,
      providers: providers,
      initialPrompt: initialPrompt,
      initialPromptError: initialPromptError,
    ),
  ).then((value) => value ?? false);
}

class _GenerateIllustrationDialog extends ConsumerStatefulWidget {
  const _GenerateIllustrationDialog({
    required this.chapter,
    required this.paragraphIndex,
    required this.selectedText,
    required this.providers,
    this.initialPrompt,
    this.initialPromptError,
  });

  final ProjectChapter chapter;
  final int paragraphIndex;
  final String selectedText;
  final List<ImageProviderConfig> providers;
  final String? initialPrompt;
  final String? initialPromptError;

  @override
  ConsumerState<_GenerateIllustrationDialog> createState() =>
      _GenerateIllustrationDialogState();
}

class _GenerateIllustrationDialogState
    extends ConsumerState<_GenerateIllustrationDialog> {
  late final TextEditingController _promptController;
  ImageProviderConfig? _provider;
  String? _modelName;
  late ImageAspectRatioPreset _aspectRatio;
  late ImageSizePreset _size;
  late ImageQualityPreset _quality;
  bool _isOptimizingPrompt = false;
  String? _promptOptimizationError;

  @override
  void initState() {
    super.initState();
    _provider = widget.providers.firstOrNull;
    _modelName = _provider?.defaultModel;
    _aspectRatio =
        _provider?.defaultAspectRatio ?? ImageAspectRatioPreset.portrait;
    _size = _provider?.defaultSize ?? ImageSizePreset.oneK;
    _quality = _provider?.defaultQuality ?? ImageQualityPreset.auto;
    _promptOptimizationError = widget.initialPromptError;
    _promptController = TextEditingController(
      text: widget.initialPrompt ?? widget.selectedText,
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(novelWorkshopControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = _provider;
    final isGrok = provider?.providerKind == ImageProviderKind.grok;
    final modelNames = provider == null
        ? const <String>[]
        : {
            provider.defaultModel,
            ...provider.modelNames,
          }.where((model) => model.trim().isNotEmpty).toList(growable: false);
    return SizedBox(
      width: 840,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('生成章节插图', style: textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  '确认图像 Provider、Prompt 与尺寸后创建后台任务。',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 720;
                final source = _IllustrationSourcePanel(
                  selectedText: widget.selectedText,
                  paragraphIndex: widget.paragraphIndex,
                );
                final form = _IllustrationCreationForm(
                  providers: widget.providers,
                  provider: provider,
                  modelNames: modelNames,
                  modelName: _modelName,
                  aspectRatio: _aspectRatio,
                  size: _size,
                  quality: _quality,
                  isGrok: isGrok,
                  isBusy: controllerState.isLoading,
                  isOptimizingPrompt: _isOptimizingPrompt,
                  promptOptimizationError: _promptOptimizationError,
                  promptController: _promptController,
                  onOptimizePrompt: _optimizePrompt,
                  onProviderChanged: (value) {
                    setState(() {
                      _provider = value;
                      _modelName = value?.defaultModel;
                      _aspectRatio =
                          value?.defaultAspectRatio ??
                          ImageAspectRatioPreset.portrait;
                      _size = value?.defaultSize ?? ImageSizePreset.oneK;
                      _quality =
                          value?.defaultQuality ?? ImageQualityPreset.auto;
                    });
                  },
                  onModelChanged: (value) => setState(() => _modelName = value),
                  onAspectRatioChanged: (value) {
                    setState(() => _aspectRatio = value);
                  },
                  onSizeChanged: (value) => setState(() => _size = value),
                  onQualityChanged: (value) => setState(() => _quality = value),
                );
                if (!isWide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [source, const SizedBox(height: 14), form],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 260, child: source),
                    const SizedBox(width: 16),
                    Expanded(child: form),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '任务会在后台运行，完成后进入插图库待确认。',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: controllerState.isLoading
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: provider == null || controllerState.isLoading
                      ? null
                      : () async {
                          try {
                            await ref
                                .read(novelWorkshopControllerProvider.notifier)
                                .createAndRunChapterIllustration(
                                  chapter: widget.chapter,
                                  paragraphIndex: widget.paragraphIndex,
                                  selectedText: widget.selectedText,
                                  prompt: _promptController.text,
                                  provider: provider,
                                  modelName:
                                      _modelName ?? provider.defaultModel,
                                  aspectRatio: _aspectRatio,
                                  size: _size,
                                  quality: _quality,
                                  responseFormat:
                                      provider.defaultResponseFormat,
                                );
                            if (context.mounted) {
                              Navigator.of(context).pop(true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('插图任务已创建，可在插图库查看进度。'),
                                ),
                              );
                            }
                          } on Object catch (error) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('创建失败：$error')),
                            );
                          }
                        },
                  icon: controllerState.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome_outlined),
                  label: const Text('创建任务'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _optimizePrompt() async {
    if (_isOptimizingPrompt) {
      return;
    }
    setState(() {
      _isOptimizingPrompt = true;
      _promptOptimizationError = null;
    });
    try {
      final prompt = await ref
          .read(novelWorkshopControllerProvider.notifier)
          .generateChapterIllustrationPrompt(
            chapter: widget.chapter,
            paragraphIndex: widget.paragraphIndex,
            selectedText: widget.selectedText,
          );
      if (!mounted) {
        return;
      }
      _promptController.text = prompt;
      setState(() {
        _promptOptimizationError = null;
      });
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _promptOptimizationError = '$error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isOptimizingPrompt = false;
        });
      }
    }
  }
}

class _IllustrationSourcePanel extends StatelessWidget {
  const _IllustrationSourcePanel({
    required this.selectedText,
    required this.paragraphIndex,
  });

  final String selectedText;
  final int paragraphIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.22),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '选中文段',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '第 ${paragraphIndex + 1} 段',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(selectedText, maxLines: 7, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            Text(
              '插图将锚定到该段落。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IllustrationCreationForm extends StatelessWidget {
  const _IllustrationCreationForm({
    required this.providers,
    required this.provider,
    required this.modelNames,
    required this.modelName,
    required this.aspectRatio,
    required this.size,
    required this.quality,
    required this.isGrok,
    required this.isBusy,
    required this.isOptimizingPrompt,
    required this.promptOptimizationError,
    required this.promptController,
    required this.onOptimizePrompt,
    required this.onProviderChanged,
    required this.onModelChanged,
    required this.onAspectRatioChanged,
    required this.onSizeChanged,
    required this.onQualityChanged,
  });

  final List<ImageProviderConfig> providers;
  final ImageProviderConfig? provider;
  final List<String> modelNames;
  final String? modelName;
  final ImageAspectRatioPreset aspectRatio;
  final ImageSizePreset size;
  final ImageQualityPreset quality;
  final bool isGrok;
  final bool isBusy;
  final bool isOptimizingPrompt;
  final String? promptOptimizationError;
  final TextEditingController promptController;
  final VoidCallback onOptimizePrompt;
  final ValueChanged<ImageProviderConfig?> onProviderChanged;
  final ValueChanged<String?> onModelChanged;
  final ValueChanged<ImageAspectRatioPreset> onAspectRatioChanged;
  final ValueChanged<ImageSizePreset> onSizeChanged;
  final ValueChanged<ImageQualityPreset> onQualityChanged;

  @override
  Widget build(BuildContext context) {
    if (providers.isEmpty) {
      return const Text('没有已启用的图像 Provider。');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackControls = constraints.maxWidth < 560;

        Widget providerDropdown() {
          return DropdownButtonFormField<ImageProviderConfig>(
            initialValue: provider,
            decoration: const InputDecoration(labelText: '图像 Provider'),
            items: [
              for (final item in providers)
                DropdownMenuItem(value: item, child: Text(item.name)),
            ],
            onChanged: isBusy ? null : onProviderChanged,
          );
        }

        Widget modelDropdown() {
          return DropdownButtonFormField<String>(
            initialValue: modelNames.contains(modelName)
                ? modelName
                : modelNames.firstOrNull,
            decoration: const InputDecoration(labelText: '模型'),
            items: [
              for (final model in modelNames)
                DropdownMenuItem(value: model, child: Text(model)),
            ],
            onChanged: isBusy ? null : onModelChanged,
          );
        }

        Widget aspectRatioDropdown() {
          return DropdownButtonFormField<ImageAspectRatioPreset>(
            initialValue: aspectRatio,
            decoration: const InputDecoration(labelText: '比例'),
            items: [
              for (final item in ImageAspectRatioPreset.values)
                DropdownMenuItem(value: item, child: Text(item.label)),
            ],
            onChanged: isBusy || provider == null
                ? null
                : (value) {
                    if (value != null) onAspectRatioChanged(value);
                  },
          );
        }

        Widget sizeDropdown() {
          return DropdownButtonFormField<ImageSizePreset>(
            initialValue: size,
            decoration: const InputDecoration(labelText: '尺寸'),
            items: [
              for (final item in ImageSizePreset.values)
                DropdownMenuItem(value: item, child: Text(item.label)),
            ],
            onChanged: isBusy || provider == null
                ? null
                : (value) {
                    if (value != null) onSizeChanged(value);
                  },
          );
        }

        Widget qualityDropdown() {
          return DropdownButtonFormField<ImageQualityPreset>(
            initialValue: isGrok ? ImageQualityPreset.auto : quality,
            decoration: const InputDecoration(labelText: '质量'),
            items: [
              for (final item in ImageQualityPreset.values)
                DropdownMenuItem(value: item, child: Text(item.label)),
            ],
            onChanged: isBusy || provider == null || isGrok
                ? null
                : (value) {
                    if (value != null) onQualityChanged(value);
                  },
          );
        }

        final controlFields = stackControls
            ? <Widget>[
                providerDropdown(),
                const SizedBox(height: 10),
                modelDropdown(),
                const SizedBox(height: 10),
                aspectRatioDropdown(),
                const SizedBox(height: 10),
                sizeDropdown(),
                const SizedBox(height: 10),
                qualityDropdown(),
              ]
            : <Widget>[
                Row(
                  children: [
                    Expanded(child: providerDropdown()),
                    const SizedBox(width: 12),
                    Expanded(child: modelDropdown()),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: aspectRatioDropdown()),
                    const SizedBox(width: 12),
                    Expanded(child: sizeDropdown()),
                    const SizedBox(width: 12),
                    Expanded(child: qualityDropdown()),
                  ],
                ),
              ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...controlFields,
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Prompt',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: isBusy || isOptimizingPrompt
                      ? null
                      : onOptimizePrompt,
                  icon: isOptimizingPrompt
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_fix_high_outlined, size: 18),
                  label: const Text('重新优化'),
                ),
              ],
            ),
            if (promptOptimizationError?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 6),
              Text(
                '优化失败：${promptOptimizationError!.trim()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 8),
            TextField(
              controller: promptController,
              minLines: 7,
              maxLines: 9,
              decoration: const InputDecoration(
                labelText: '提示词',
                alignLabelWithHint: true,
              ),
            ),
          ],
        );
      },
    );
  }
}

_ParsedPromptDocument _parsePromptDocument(
  _PromptDocumentKind kind,
  String markdown,
) {
  try {
    return switch (kind) {
      _PromptDocumentKind.voiceProfile => (() {
        final document = const VoiceProfileFrontMatterParser().parse(markdown);
        return _ParsedPromptDocument(
          fields: document.fields,
          bodyMarkdown: document.bodyMarkdown,
        );
      })(),
      _PromptDocumentKind.storyEngine => (() {
        final document = const StoryEngineNormalizer().parse(markdown);
        return _ParsedPromptDocument(
          fields: document.fields,
          bodyMarkdown: document.bodyMarkdown,
        );
      })(),
    };
  } on Object catch (error) {
    return _ParsedPromptDocument(error: '$error');
  }
}

class _ParsedPromptDocument {
  const _ParsedPromptDocument({
    this.fields = const {},
    this.bodyMarkdown = '',
    this.error,
  });

  final Map<String, Object?> fields;
  final String bodyMarkdown;
  final String? error;
}
