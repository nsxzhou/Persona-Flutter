import '../../projects/domain/project_repository.dart';
import '../../projects/domain/writing_project.dart';
import '../domain/novel_import.dart';
import '../domain/novel_workshop.dart';
import '../domain/novel_workshop_repository.dart';
import '../domain/writing_context.dart';

class NovelImportService {
  const NovelImportService({
    required ProjectRepository projectRepository,
    required NovelWorkshopRepository workshopRepository,
  }) : _projectRepository = projectRepository,
       _workshopRepository = workshopRepository;

  final ProjectRepository _projectRepository;
  final NovelWorkshopRepository _workshopRepository;

  Future<WritingProject> createImportedProject({
    required NovelImportDraft draft,
    required String defaultProviderId,
    required String defaultModelName,
    String? styleProfileId,
    String language = defaultProjectLanguage,
    int targetLength = defaultProjectTargetLength,
    int totalTargetLength = defaultProjectTotalTargetLength,
    String narrativePerspective = defaultProjectNarrativePerspective,
  }) async {
    final chapters = draft.chapters
        .where((chapter) => chapter.contentMarkdown.trim().isNotEmpty)
        .toList(growable: false);
    if (chapters.isEmpty) {
      throw StateError('导入草稿没有可创建的章节。');
    }
    final project = await _projectRepository.createProject(
      WritingProjectInput(
        title: draft.title,
        description:
            '从 ${draft.sourceFilename} 导入，共 ${chapters.length} 章，${draft.totalCharacterCount} 字。',
        status: ProjectStatus.active,
        defaultProviderId: defaultProviderId,
        defaultModelName: defaultModelName,
        styleProfileId: styleProfileId,
        plotProfileId: null,
        origin: ProjectOrigin.importedEnrichment,
        language: language,
        targetLength: targetLength,
        totalTargetLength: totalTargetLength,
        narrativePerspective: narrativePerspective,
      ),
    );
    final volume = await _workshopRepository.saveChapterVolume(
      input: ChapterVolumeInput(
        projectId: project.id,
        volumeIndex: 1,
        title: '导入正文',
        targetLength: draft.totalCharacterCount,
        summary: '从 ${draft.sourceFilename} 导入的正文。',
      ),
    );
    for (var index = 0; index < chapters.length; index += 1) {
      final chapter = chapters[index];
      final chapterIndex = index + 1;
      final title = chapter.title.trim().isEmpty
          ? '第$chapterIndex章'
          : chapter.title.trim();
      final plan = await _workshopRepository.saveChapterPlan(
        input: ChapterPlanInput(
          projectId: project.id,
          volumeId: volume.id,
          volumeIndex: volume.volumeIndex,
          volumeTitle: volume.title,
          chapterLocalIndex: chapterIndex,
          chapterIndex: chapterIndex,
          objectiveCard: ChapterObjectiveCard(
            chapterTitle: title,
            objective: '导入章节：以原正文为准。',
          ),
          outlineMarkdown: '导入章节：正文内容为准；本细纲仅用于章节导航兼容。',
        ),
      );
      await _workshopRepository.saveChapter(
        input: ProjectChapterInput(
          projectId: project.id,
          chapterPlanId: plan.id,
          chapterIndex: chapterIndex,
          title: title,
          contentMarkdown: chapter.contentMarkdown,
        ),
      );
    }
    await _workshopRepository.ensureProjectBible(project.id);
    return project;
  }
}
