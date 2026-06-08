import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class WorkflowTaskRecords extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get status => text()();
  TextColumn get title => text()();
  TextColumn get stage => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get previewDismissedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class WorkflowPromptTraceRecords extends Table {
  TextColumn get workflowTaskId =>
      text().references(WorkflowTaskRecords, #id)();
  TextColumn get traceMarkdown => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {workflowTaskId};
}

class ProviderConfigRecords extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get baseUrl => text()();
  TextColumn get apiKey => text()();
  TextColumn get defaultModel => text()();
  TextColumn get systemPrompt => text().withDefault(const Constant(''))();
  BoolColumn get isSystemPromptEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get testStatus => text()();
  DateTimeColumn get lastTestedAt => dateTime().nullable()();
  TextColumn get lastTestMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ProviderModelRecords extends Table {
  TextColumn get providerId => text().references(ProviderConfigRecords, #id)();
  TextColumn get modelName => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {providerId, modelName};
}

class ImageProviderConfigRecords extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get baseUrl => text()();
  TextColumn get apiKey => text()();
  TextColumn get defaultModel => text()();
  TextColumn get providerKind => text().withDefault(const Constant('gpt'))();
  TextColumn get defaultAspectRatio =>
      text().withDefault(const Constant('1:1'))();
  TextColumn get defaultSize => text().withDefault(const Constant('1K'))();
  TextColumn get defaultQuality => text().withDefault(const Constant('auto'))();
  TextColumn get defaultResponseFormat =>
      text().withDefault(const Constant('url'))();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get testStatus => text()();
  DateTimeColumn get lastTestedAt => dateTime().nullable()();
  TextColumn get lastTestMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ImageProviderModelRecords extends Table {
  TextColumn get providerId =>
      text().references(ImageProviderConfigRecords, #id)();
  TextColumn get modelName => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {providerId, modelName};
}

class ProjectRecords extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get status => text()();
  TextColumn get defaultProviderId => text().nullable()();
  TextColumn get defaultModelName => text().nullable()();
  TextColumn get styleProfileId => text().nullable()();
  TextColumn get plotProfileId => text().nullable()();
  TextColumn get origin => text().withDefault(const Constant('standard'))();
  TextColumn get language => text().withDefault(const Constant('简体中文'))();
  IntColumn get targetLength => integer().withDefault(const Constant(3000))();
  IntColumn get totalTargetLength =>
      integer().withDefault(const Constant(100000))();
  TextColumn get narrativePerspective =>
      text().withDefault(const Constant('第三人称有限视角'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class StyleSampleRecords extends Table {
  TextColumn get id => text()();
  TextColumn get sourceType => text()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  IntColumn get characterCount => integer()();
  TextColumn get projectId =>
      text().nullable().references(ProjectRecords, #id)();
  TextColumn get sourceFilename => text().nullable()();
  TextColumn get epubBookTitle => text().nullable()();
  TextColumn get epubAuthor => text().nullable()();
  TextColumn get epubChapterTitle => text().nullable()();
  IntColumn get epubChapterIndex => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class StyleAnalysisRunRecords extends Table {
  TextColumn get id => text()();
  TextColumn get workflowTaskId =>
      text().references(WorkflowTaskRecords, #id)();
  TextColumn get sampleId => text().references(StyleSampleRecords, #id)();
  TextColumn get providerId => text().references(ProviderConfigRecords, #id)();
  TextColumn get modelName => text()();
  TextColumn get styleName => text()();
  TextColumn get projectId =>
      text().nullable().references(ProjectRecords, #id)();
  TextColumn get status => text()();
  TextColumn get stage => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get logs => text().withDefault(const Constant(''))();
  TextColumn get analysisReportMarkdown => text().nullable()();
  TextColumn get voiceProfileMarkdown => text().nullable()();
  TextColumn get profileId => text().nullable()();
  IntColumn get chunkCount => integer().withDefault(const Constant(0))();
  IntColumn get characterCount => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class StyleProfileRecords extends Table {
  TextColumn get id => text()();
  TextColumn get sourceRunId =>
      text().unique().references(StyleAnalysisRunRecords, #id)();
  TextColumn get providerId => text().references(ProviderConfigRecords, #id)();
  TextColumn get modelName => text()();
  TextColumn get styleName => text()();
  TextColumn get profileMarkdown => text()();
  TextColumn get analysisReportMarkdown => text()();
  TextColumn get projectId =>
      text().nullable().references(ProjectRecords, #id)();
  TextColumn get sourceSampleId =>
      text().nullable().references(StyleSampleRecords, #id)();
  TextColumn get sourceTitle => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PlotSampleRecords extends Table {
  TextColumn get id => text()();
  TextColumn get sourceType => text()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  IntColumn get characterCount => integer()();
  TextColumn get projectId =>
      text().nullable().references(ProjectRecords, #id)();
  TextColumn get sourceFilename => text().nullable()();
  TextColumn get epubBookTitle => text().nullable()();
  TextColumn get epubAuthor => text().nullable()();
  IntColumn get epubChapterCount => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PlotAnalysisRunRecords extends Table {
  TextColumn get id => text()();
  TextColumn get workflowTaskId =>
      text().references(WorkflowTaskRecords, #id)();
  TextColumn get sampleId => text().references(PlotSampleRecords, #id)();
  TextColumn get providerId => text().references(ProviderConfigRecords, #id)();
  TextColumn get modelName => text()();
  TextColumn get plotName => text()();
  TextColumn get projectId =>
      text().nullable().references(ProjectRecords, #id)();
  TextColumn get status => text()();
  TextColumn get stage => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get logs => text().withDefault(const Constant(''))();
  TextColumn get analysisReportMarkdown => text().nullable()();
  TextColumn get plotSkeletonMarkdown => text().nullable()();
  TextColumn get storyEngineMarkdown => text().nullable()();
  TextColumn get profileId => text().nullable()();
  IntColumn get chunkCount => integer().withDefault(const Constant(0))();
  IntColumn get characterCount => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PlotProfileRecords extends Table {
  TextColumn get id => text()();
  TextColumn get sourceRunId =>
      text().unique().references(PlotAnalysisRunRecords, #id)();
  TextColumn get providerId => text().references(ProviderConfigRecords, #id)();
  TextColumn get modelName => text()();
  TextColumn get plotName => text()();
  TextColumn get storyEngineMarkdown => text()();
  TextColumn get analysisReportMarkdown => text()();
  TextColumn get plotSkeletonMarkdown => text()();
  TextColumn get projectId =>
      text().nullable().references(ProjectRecords, #id)();
  TextColumn get sourceSampleId =>
      text().nullable().references(PlotSampleRecords, #id)();
  TextColumn get sourceTitle => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ProjectRuntimeMemoryRecords extends Table {
  TextColumn get projectId => text()();
  TextColumn get runtimeState => text().withDefault(const Constant(''))();
  TextColumn get runtimeThreads => text().withDefault(const Constant(''))();
  TextColumn get storySummary => text().withDefault(const Constant(''))();
  TextColumn get continuityIndex => text().withDefault(const Constant(''))();
  TextColumn get chapterArchiveMarkdown =>
      text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {projectId};
}

class ProjectBibleRecords extends Table {
  TextColumn get projectId => text().references(ProjectRecords, #id)();
  TextColumn get descriptionMarkdown =>
      text().withDefault(const Constant(''))();
  TextColumn get worldBuildingMarkdown =>
      text().withDefault(const Constant(''))();
  TextColumn get charactersBlueprintMarkdown =>
      text().withDefault(const Constant(''))();
  TextColumn get outlineMasterMarkdown =>
      text().withDefault(const Constant(''))();
  TextColumn get outlineDetailYaml => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {projectId};
}

class ChapterVolumeRecords extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(ProjectRecords, #id)();
  IntColumn get volumeIndex => integer()();
  TextColumn get title => text().withDefault(const Constant(''))();
  IntColumn get targetLength => integer().withDefault(const Constant(0))();
  TextColumn get summary => text().withDefault(const Constant(''))();
  TextColumn get centralConflict => text().withDefault(const Constant(''))();
  TextColumn get characterProgression =>
      text().withDefault(const Constant(''))();
  TextColumn get endingHook => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {projectId, volumeIndex},
  ];
}

class ChapterPlanRecords extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(ProjectRecords, #id)();
  TextColumn get volumeId => text().withDefault(const Constant(''))();
  IntColumn get volumeIndex => integer().withDefault(const Constant(1))();
  TextColumn get volumeTitle => text().withDefault(const Constant('未分卷章节'))();
  IntColumn get chapterLocalIndex => integer().withDefault(const Constant(1))();
  IntColumn get chapterIndex => integer()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get objective => text().withDefault(const Constant(''))();
  TextColumn get pressureSource => text().withDefault(const Constant(''))();
  TextColumn get payoffTarget => text().withDefault(const Constant(''))();
  TextColumn get relationshipShift => text().withDefault(const Constant(''))();
  TextColumn get hookType => text().withDefault(const Constant(''))();
  TextColumn get coreEvent => text().withDefault(const Constant(''))();
  TextColumn get emotionArc => text().withDefault(const Constant(''))();
  TextColumn get chapterHook => text().withDefault(const Constant(''))();
  TextColumn get outlineMarkdown => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {projectId, chapterIndex},
  ];
}

class ProjectChapterRecords extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(ProjectRecords, #id)();
  TextColumn get chapterPlanId =>
      text().unique().references(ChapterPlanRecords, #id)();
  IntColumn get chapterIndex => integer()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get contentMarkdown => text().withDefault(const Constant(''))();
  TextColumn get contentHash => text().withDefault(const Constant(''))();
  TextColumn get continuityVerdict =>
      text().withDefault(const Constant('pass'))();
  TextColumn get continuityReportMarkdown =>
      text().withDefault(const Constant(''))();
  TextColumn get memorySyncStatus =>
      text().withDefault(const Constant('idle'))();
  TextColumn get memorySyncContentHash =>
      text().withDefault(const Constant(''))();
  TextColumn get memorySyncProposedRuntimeState =>
      text().withDefault(const Constant(''))();
  TextColumn get memorySyncProposedRuntimeThreads =>
      text().withDefault(const Constant(''))();
  TextColumn get memorySyncProposedStorySummary =>
      text().withDefault(const Constant(''))();
  TextColumn get memorySyncProposedContinuityIndex =>
      text().withDefault(const Constant(''))();
  TextColumn get memorySyncProposedChapterArchiveMarkdown =>
      text().withDefault(const Constant(''))();
  TextColumn get memorySyncPatchYaml =>
      text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {projectId, chapterIndex},
  ];
}

class ChapterIllustrationRecords extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(ProjectRecords, #id)();
  TextColumn get chapterId => text().references(ProjectChapterRecords, #id)();
  TextColumn get chapterPlanId => text().references(ChapterPlanRecords, #id)();
  IntColumn get paragraphIndex => integer()();
  TextColumn get anchorTextHash => text().withDefault(const Constant(''))();
  TextColumn get selectedText => text().withDefault(const Constant(''))();
  TextColumn get prompt => text().withDefault(const Constant(''))();
  TextColumn get providerId => text().withDefault(const Constant(''))();
  TextColumn get modelName => text().withDefault(const Constant(''))();
  TextColumn get localPath => text().withDefault(const Constant(''))();
  TextColumn get mimeType => text().withDefault(const Constant('image/png'))();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get acceptedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ChapterIllustrationGenerationRunRecords extends Table {
  TextColumn get id => text()();
  TextColumn get workflowTaskId =>
      text().references(WorkflowTaskRecords, #id)();
  TextColumn get projectId => text().references(ProjectRecords, #id)();
  TextColumn get chapterId => text().references(ProjectChapterRecords, #id)();
  TextColumn get chapterPlanId => text().references(ChapterPlanRecords, #id)();
  IntColumn get paragraphIndex => integer()();
  TextColumn get anchorTextHash => text().withDefault(const Constant(''))();
  TextColumn get selectedText => text().withDefault(const Constant(''))();
  TextColumn get prompt => text().withDefault(const Constant(''))();
  TextColumn get providerId => text().withDefault(const Constant(''))();
  TextColumn get modelName => text().withDefault(const Constant(''))();
  TextColumn get aspectRatio => text().withDefault(const Constant('1:1'))();
  TextColumn get size => text().withDefault(const Constant('1K'))();
  TextColumn get quality => text().withDefault(const Constant('auto'))();
  TextColumn get responseFormat => text().withDefault(const Constant('url'))();
  TextColumn get status => text()();
  TextColumn get stage => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get logs => text().withDefault(const Constant(''))();
  TextColumn get illustrationId =>
      text().nullable().references(ChapterIllustrationRecords, #id)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ChapterEnrichmentBatchRecords extends Table {
  TextColumn get id => text()();
  TextColumn get workflowTaskId =>
      text().references(WorkflowTaskRecords, #id)();
  TextColumn get projectId => text().references(ProjectRecords, #id)();
  TextColumn get instruction => text()();
  IntColumn get expansionRatioPercent =>
      integer().withDefault(const Constant(20))();
  TextColumn get providerId => text()();
  TextColumn get modelName => text()();
  TextColumn get status => text()();
  TextColumn get errorMessage => text().nullable()();
  IntColumn get totalCount => integer().withDefault(const Constant(0))();
  IntColumn get generatedCount => integer().withDefault(const Constant(0))();
  IntColumn get failedCount => integer().withDefault(const Constant(0))();
  IntColumn get appliedCount => integer().withDefault(const Constant(0))();
  TextColumn get logs => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ChapterEnrichmentItemRecords extends Table {
  TextColumn get id => text()();
  TextColumn get batchId =>
      text().references(ChapterEnrichmentBatchRecords, #id)();
  TextColumn get projectId => text().references(ProjectRecords, #id)();
  TextColumn get chapterId => text().references(ProjectChapterRecords, #id)();
  IntColumn get position => integer()();
  TextColumn get status => text()();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get originalContentMarkdown =>
      text().withDefault(const Constant(''))();
  TextColumn get generatedContentMarkdown =>
      text().withDefault(const Constant(''))();
  TextColumn get providerId => text().withDefault(const Constant(''))();
  TextColumn get modelName => text().withDefault(const Constant(''))();
  TextColumn get logs => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get appliedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {batchId, chapterId},
  ];
}

class ChapterGenerationBatchRecords extends Table {
  TextColumn get id => text()();
  TextColumn get workflowTaskId =>
      text().references(WorkflowTaskRecords, #id)();
  TextColumn get projectId => text().references(ProjectRecords, #id)();
  TextColumn get providerId => text()();
  TextColumn get modelName => text()();
  TextColumn get status => text()();
  TextColumn get errorMessage => text().nullable()();
  IntColumn get totalCount => integer().withDefault(const Constant(0))();
  IntColumn get syncedCount => integer().withDefault(const Constant(0))();
  IntColumn get failedCount => integer().withDefault(const Constant(0))();
  TextColumn get logs => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ChapterGenerationBatchItemRecords extends Table {
  TextColumn get id => text()();
  TextColumn get batchId =>
      text().references(ChapterGenerationBatchRecords, #id)();
  TextColumn get projectId => text().references(ProjectRecords, #id)();
  TextColumn get chapterPlanId => text().references(ChapterPlanRecords, #id)();
  TextColumn get chapterId =>
      text().nullable().references(ProjectChapterRecords, #id)();
  TextColumn get latestRunId =>
      text().nullable().references(ChapterGenerationRunRecords, #id)();
  IntColumn get position => integer()();
  TextColumn get status => text()();
  TextColumn get errorMessage => text().nullable()();
  IntColumn get draftAttemptCount => integer().withDefault(const Constant(0))();
  IntColumn get patchAttemptCount => integer().withDefault(const Constant(0))();
  TextColumn get logs => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {batchId, chapterPlanId},
  ];
}

class NovelCharacterRecords extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(ProjectRecords, #id)();
  TextColumn get name => text()();
  TextColumn get aliases => text().withDefault(const Constant(''))();
  TextColumn get tags => text().withDefault(const Constant(''))();
  TextColumn get faction => text().withDefault(const Constant(''))();
  TextColumn get role => text().withDefault(const Constant(''))();
  TextColumn get longTermGoal => text().withDefault(const Constant(''))();
  TextColumn get currentStatus => text().withDefault(const Constant(''))();
  TextColumn get secrets => text().withDefault(const Constant(''))();
  IntColumn get firstChapterIndex => integer().nullable()();
  IntColumn get lastChapterIndex => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {projectId, name},
  ];
}

class NovelRelationshipRecords extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(ProjectRecords, #id)();
  @ReferenceName('outgoingRelationships')
  TextColumn get fromCharacterId =>
      text().references(NovelCharacterRecords, #id)();
  @ReferenceName('incomingRelationships')
  TextColumn get toCharacterId =>
      text().references(NovelCharacterRecords, #id)();
  TextColumn get relationshipType => text().withDefault(const Constant(''))();
  IntColumn get strength => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get lastChangedChapterIndex => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {projectId, fromCharacterId, toCharacterId},
  ];
}

class ChapterGenerationRunRecords extends Table {
  TextColumn get id => text()();
  TextColumn get workflowTaskId =>
      text().references(WorkflowTaskRecords, #id)();
  TextColumn get projectId => text().references(ProjectRecords, #id)();
  TextColumn get chapterPlanId => text()();
  TextColumn get chapterId =>
      text().nullable().references(ProjectChapterRecords, #id)();
  TextColumn get providerId => text()();
  TextColumn get modelName => text()();
  TextColumn get status => text()();
  TextColumn get stage => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get logs => text().withDefault(const Constant(''))();
  TextColumn get contextWarningsMarkdown =>
      text().withDefault(const Constant(''))();
  TextColumn get draftMarkdown => text().withDefault(const Constant(''))();
  TextColumn get continuityVerdict =>
      text().withDefault(const Constant('pass'))();
  TextColumn get continuityReportMarkdown =>
      text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AssetGenerationRunRecords extends Table {
  TextColumn get id => text()();
  TextColumn get workflowTaskId =>
      text().references(WorkflowTaskRecords, #id)();
  TextColumn get projectId => text().references(ProjectRecords, #id)();
  TextColumn get targetVolumeId =>
      text().nullable().references(ChapterVolumeRecords, #id)();
  TextColumn get kind => text()();
  TextColumn get providerId => text()();
  TextColumn get modelName => text()();
  TextColumn get status => text()();
  TextColumn get stage => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get logs => text().withDefault(const Constant(''))();
  TextColumn get draftMarkdown => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get previousRunId => text().nullable()();
  TextColumn get userFeedback => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class MarketBookRecords extends Table {
  TextColumn get id => text()();
  TextColumn get platform => text()();
  TextColumn get platformBookId => text()();
  TextColumn get title => text()();
  TextColumn get author => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get categories => text().withDefault(const Constant('[]'))();
  TextColumn get tags => text().withDefault(const Constant('[]'))();
  IntColumn get totalWordCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('ongoing'))();
  DateTimeColumn get firstPublishDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {platform, platformBookId},
  ];
}

class MarketRankingRecords extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text().references(MarketBookRecords, #id)();
  TextColumn get chartName => text()();
  IntColumn get rank => integer()();
  TextColumn get runId => text().references(MarketScanRunRecords, #id)();
  IntColumn get favorites => integer().nullable()();
  IntColumn get recommendVotes => integer().nullable()();
  IntColumn get monthlyTickets => integer().nullable()();
  IntColumn get commentCount => integer().nullable()();
  DateTimeColumn get scrapedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class MarketScanRunRecords extends Table {
  TextColumn get id => text()();
  TextColumn get platform => text()();
  TextColumn get status => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get itemCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    WorkflowTaskRecords,
    WorkflowPromptTraceRecords,
    ProviderConfigRecords,
    ProviderModelRecords,
    ImageProviderConfigRecords,
    ImageProviderModelRecords,
    ProjectRecords,
    StyleSampleRecords,
    StyleAnalysisRunRecords,
    StyleProfileRecords,
    PlotSampleRecords,
    PlotAnalysisRunRecords,
    PlotProfileRecords,
    ProjectRuntimeMemoryRecords,
    ProjectBibleRecords,
    ChapterVolumeRecords,
    ChapterPlanRecords,
    ProjectChapterRecords,
    ChapterIllustrationRecords,
    ChapterIllustrationGenerationRunRecords,
    ChapterEnrichmentBatchRecords,
    ChapterEnrichmentItemRecords,
    ChapterGenerationBatchRecords,
    ChapterGenerationBatchItemRecords,
    NovelCharacterRecords,
    NovelRelationshipRecords,
    ChapterGenerationRunRecords,
    AssetGenerationRunRecords,
    MarketBookRecords,
    MarketRankingRecords,
    MarketScanRunRecords,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  static Future<File> databaseFile() async {
    final supportDir = await getApplicationSupportDirectory();
    final dbDir = Directory(p.join(supportDir.path, 'Persona'));
    if (!dbDir.existsSync()) {
      dbDir.createSync(recursive: true);
    }
    return File(p.join(dbDir.path, 'persona.sqlite'));
  }

  @override
  int get schemaVersion => 33;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) => migrator.createAll(),
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(providerConfigRecords);
        }
        if (from < 3) {
          await migrator.addColumn(
            providerConfigRecords,
            providerConfigRecords.systemPrompt,
          );
        }
        if (from < 4) {
          await migrator.createTable(projectRecords);
        }
        if (from < 5) {
          await migrator.createTable(styleSampleRecords);
          await migrator.createTable(styleAnalysisRunRecords);
          await migrator.createTable(styleProfileRecords);
        }
        if (from < 6) {
          await migrator.createTable(plotSampleRecords);
          await migrator.createTable(plotAnalysisRunRecords);
          await migrator.createTable(plotProfileRecords);
        }
        if (from < 7) {
          await migrator.createTable(workflowPromptTraceRecords);
        }
        if (from < 8) {
          await migrator.createTable(providerModelRecords);
          await customStatement('''
            INSERT INTO provider_model_records
              (provider_id, model_name, sort_order, created_at, updated_at)
            SELECT id, default_model, 0, created_at, updated_at
            FROM provider_config_records
            WHERE TRIM(default_model) <> ''
          ''');
          await migrator.addColumn(
            plotSampleRecords,
            plotSampleRecords.projectId,
          );
          await migrator.addColumn(
            plotAnalysisRunRecords,
            plotAnalysisRunRecords.projectId,
          );
          await migrator.addColumn(
            plotProfileRecords,
            plotProfileRecords.projectId,
          );
        }
        if (from < 9) {
          await migrator.addColumn(
            projectRecords,
            projectRecords.defaultProviderId,
          );
          await migrator.addColumn(
            projectRecords,
            projectRecords.defaultModelName,
          );
          await migrator.addColumn(
            projectRecords,
            projectRecords.styleProfileId,
          );
          await migrator.addColumn(
            projectRecords,
            projectRecords.plotProfileId,
          );
          await migrator.addColumn(projectRecords, projectRecords.language);
          await migrator.addColumn(projectRecords, projectRecords.targetLength);
          await migrator.addColumn(
            projectRecords,
            projectRecords.narrativePerspective,
          );
          await customStatement('''
            UPDATE project_records
            SET
              default_provider_id = (
                SELECT id
                FROM provider_config_records
                WHERE is_enabled = 1
                ORDER BY created_at ASC
                LIMIT 1
              ),
              default_model_name = (
                SELECT default_model
                FROM provider_config_records
                WHERE is_enabled = 1
                ORDER BY created_at ASC
                LIMIT 1
              )
            WHERE default_provider_id IS NULL
              AND default_model_name IS NULL
          ''');
        }
        if (from < 11) {
          await _dropNovelWorkshopPersistence();
        }
        if (from < 12) {
          await migrator.createTable(projectRuntimeMemoryRecords);
          await migrator.createTable(chapterPlanRecords);
          await migrator.createTable(projectChapterRecords);
        }
        if (from < 13) {
          await migrator.createTable(chapterGenerationRunRecords);
        }
        if (from < 14) {
          await migrator.createTable(projectBibleRecords);
          await migrator.createTable(chapterVolumeRecords);
          await _migrateWorkshopProjectBibleAndVolumes(migrator);
        }
        if (from < 15) {
          if (await _tableExists('provider_config_records')) {
            await migrator.addColumn(
              providerConfigRecords,
              providerConfigRecords.isSystemPromptEnabled,
            );
          }
        }
        if (from < 16) {
          await migrator.createTable(assetGenerationRunRecords);
        }
        if (from < 17) {
          if (await _tableExists('project_records') &&
              !await _columnExists('project_records', 'total_target_length')) {
            await migrator.addColumn(
              projectRecords,
              projectRecords.totalTargetLength,
            );
          }
          if (await _tableExists('chapter_volume_records')) {
            if (!await _columnExists(
              'chapter_volume_records',
              'target_length',
            )) {
              await migrator.addColumn(
                chapterVolumeRecords,
                chapterVolumeRecords.targetLength,
              );
            }
            if (!await _columnExists('chapter_volume_records', 'summary')) {
              await migrator.addColumn(
                chapterVolumeRecords,
                chapterVolumeRecords.summary,
              );
            }
            if (!await _columnExists(
              'chapter_volume_records',
              'central_conflict',
            )) {
              await migrator.addColumn(
                chapterVolumeRecords,
                chapterVolumeRecords.centralConflict,
              );
            }
            if (!await _columnExists(
              'chapter_volume_records',
              'character_progression',
            )) {
              await migrator.addColumn(
                chapterVolumeRecords,
                chapterVolumeRecords.characterProgression,
              );
            }
            if (!await _columnExists('chapter_volume_records', 'ending_hook')) {
              await migrator.addColumn(
                chapterVolumeRecords,
                chapterVolumeRecords.endingHook,
              );
            }
          }
          if (await _tableExists('project_chapter_records') &&
              !await _columnExists(
                'project_chapter_records',
                'memory_sync_patch_yaml',
              )) {
            await migrator.addColumn(
              projectChapterRecords,
              projectChapterRecords.memorySyncPatchYaml,
            );
          }
          if (!await _tableExists('novel_character_records')) {
            await migrator.createTable(novelCharacterRecords);
          }
          if (!await _tableExists('novel_relationship_records')) {
            await migrator.createTable(novelRelationshipRecords);
          }
          if (await _tableExists('asset_generation_run_records') &&
              !await _columnExists(
                'asset_generation_run_records',
                'target_volume_id',
              )) {
            await migrator.addColumn(
              assetGenerationRunRecords,
              assetGenerationRunRecords.targetVolumeId,
            );
          }
        }
        if (from < 18) {
          if (await _tableExists('project_records') &&
              !await _columnExists('project_records', 'origin')) {
            await migrator.addColumn(projectRecords, projectRecords.origin);
          }
          if (!await _tableExists('chapter_enrichment_batch_records')) {
            await migrator.createTable(chapterEnrichmentBatchRecords);
          }
          if (!await _tableExists('chapter_enrichment_item_records')) {
            await migrator.createTable(chapterEnrichmentItemRecords);
          }
        }
        if (from < 19) {
          if (await _tableExists('project_runtime_memory_records') &&
              await _columnExists(
                'project_runtime_memory_records',
                'characters_status',
              )) {
            await migrator.dropColumn(
              projectRuntimeMemoryRecords,
              'characters_status',
            );
          }
          if (await _tableExists('project_chapter_records') &&
              await _columnExists(
                'project_chapter_records',
                'memory_sync_proposed_characters_status',
              )) {
            await migrator.dropColumn(
              projectChapterRecords,
              'memory_sync_proposed_characters_status',
            );
          }
        }
        if (from < 20) {
          if (await _tableExists('project_runtime_memory_records')) {
            if (!await _columnExists(
              'project_runtime_memory_records',
              'continuity_index',
            )) {
              await migrator.addColumn(
                projectRuntimeMemoryRecords,
                projectRuntimeMemoryRecords.continuityIndex,
              );
            }
            if (!await _columnExists(
              'project_runtime_memory_records',
              'chapter_archive_markdown',
            )) {
              await migrator.addColumn(
                projectRuntimeMemoryRecords,
                projectRuntimeMemoryRecords.chapterArchiveMarkdown,
              );
            }
          }
          if (await _tableExists('project_chapter_records')) {
            if (!await _columnExists(
              'project_chapter_records',
              'memory_sync_proposed_continuity_index',
            )) {
              await migrator.addColumn(
                projectChapterRecords,
                projectChapterRecords.memorySyncProposedContinuityIndex,
              );
            }
            if (!await _columnExists(
              'project_chapter_records',
              'memory_sync_proposed_chapter_archive_markdown',
            )) {
              await migrator.addColumn(
                projectChapterRecords,
                projectChapterRecords.memorySyncProposedChapterArchiveMarkdown,
              );
            }
          }
        }
        if (from < 21) {
          if (await _tableExists('chapter_generation_run_records')) {
            if (!await _columnExists(
              'chapter_generation_run_records',
              'draft_markdown',
            )) {
              await customStatement('''
                ALTER TABLE chapter_generation_run_records
                ADD COLUMN draft_markdown TEXT NOT NULL DEFAULT ''
              ''');
            }
            if (!await _columnExists(
              'chapter_generation_run_records',
              'continuity_verdict',
            )) {
              await customStatement('''
                ALTER TABLE chapter_generation_run_records
                ADD COLUMN continuity_verdict TEXT NOT NULL DEFAULT 'pass'
              ''');
            }
            if (!await _columnExists(
              'chapter_generation_run_records',
              'continuity_report_markdown',
            )) {
              await customStatement('''
                ALTER TABLE chapter_generation_run_records
                ADD COLUMN continuity_report_markdown TEXT NOT NULL DEFAULT ''
              ''');
            }
          }
        }
        if (from < 22) {
          if (!await _tableExists('chapter_generation_batch_records')) {
            await migrator.createTable(chapterGenerationBatchRecords);
          }
          if (!await _tableExists('chapter_generation_batch_item_records')) {
            await migrator.createTable(chapterGenerationBatchItemRecords);
          }
        }
        if (from < 23) {
          if (await _tableExists('workflow_task_records') &&
              !await _columnExists(
                'workflow_task_records',
                'preview_dismissed_at',
              )) {
            await migrator.addColumn(
              workflowTaskRecords,
              workflowTaskRecords.previewDismissedAt,
            );
          }
        }
        if (from < 24) {
          if (!await _tableExists('image_provider_config_records')) {
            await migrator.createTable(imageProviderConfigRecords);
          }
          if (!await _tableExists('image_provider_model_records')) {
            await migrator.createTable(imageProviderModelRecords);
          }
        }
        if (from < 25 && await _tableExists('image_provider_config_records')) {
          if (!await _columnExists(
            'image_provider_config_records',
            'default_aspect_ratio',
          )) {
            await migrator.addColumn(
              imageProviderConfigRecords,
              imageProviderConfigRecords.defaultAspectRatio,
            );
          }
          if (!await _columnExists(
            'image_provider_config_records',
            'default_quality',
          )) {
            await migrator.addColumn(
              imageProviderConfigRecords,
              imageProviderConfigRecords.defaultQuality,
            );
          }
          await customStatement('''
            UPDATE image_provider_config_records
            SET
              default_quality = CASE default_quality
                WHEN 'low' THEN 'low'
                WHEN 'medium' THEN 'medium'
                WHEN 'high' THEN 'high'
                ELSE 'auto'
              END,
              default_size = CASE default_size
                WHEN '2048x2048' THEN '2K'
                WHEN '4096x4096' THEN '4K'
                WHEN '2k' THEN '2K'
                WHEN '2K' THEN '2K'
                WHEN '4k' THEN '4K'
                WHEN '4K' THEN '4K'
                ELSE '1K'
              END
          ''');
        }
        if (from < 26 && await _tableExists('image_provider_config_records')) {
          await customStatement('''
            UPDATE image_provider_config_records
            SET default_aspect_ratio = '1:1'
            WHERE default_aspect_ratio = 'auto'
          ''');
        }
        if (from < 27 && await _tableExists('image_provider_config_records')) {
          if (!await _columnExists(
            'image_provider_config_records',
            'provider_kind',
          )) {
            await migrator.addColumn(
              imageProviderConfigRecords,
              imageProviderConfigRecords.providerKind,
            );
          }
          await customStatement('''
            UPDATE image_provider_config_records
            SET provider_kind = 'gpt'
            WHERE provider_kind IS NULL OR TRIM(provider_kind) = ''
          ''');
        }
        if (from < 28) {
          if (!await _tableExists('chapter_illustration_records')) {
            await migrator.createTable(chapterIllustrationRecords);
          }
        }
        if (from < 29) {
          if (!await _tableExists(
            'chapter_illustration_generation_run_records',
          )) {
            await migrator.createTable(chapterIllustrationGenerationRunRecords);
          }
        }
        if (from < 30 && await _tableExists('chapter_illustration_records')) {
          await customStatement('''
            UPDATE chapter_illustration_records
            SET status = 'inserted'
            WHERE status = 'accepted'
          ''');
        }
        if (from < 31) {
          if (await _tableExists('asset_generation_run_records')) {
            if (!await _columnExists(
              'asset_generation_run_records',
              'previous_run_id',
            )) {
              await migrator.addColumn(
                assetGenerationRunRecords,
                assetGenerationRunRecords.previousRunId,
              );
            }
            if (!await _columnExists(
              'asset_generation_run_records',
              'user_feedback',
            )) {
              await migrator.addColumn(
                assetGenerationRunRecords,
                assetGenerationRunRecords.userFeedback,
              );
            }
          }
        }
        if (from < 32) {
          // MarketScanRunRecords must be created before MarketRankingRecords
          // because MarketRankingRecords has a FK reference to it.
          if (!await _tableExists('market_scan_run_records')) {
            await migrator.createTable(marketScanRunRecords);
          }
          if (!await _tableExists('market_book_records')) {
            await migrator.createTable(marketBookRecords);
          }
          if (!await _tableExists('market_ranking_records')) {
            await migrator.createTable(marketRankingRecords);
          }
        }
        if (from < 33) {
          await _removeJinjiangMarketScanData();
        }
      },
    );
  }

  Future<void> _removeJinjiangMarketScanData() async {
    final hasRankings = await _tableExists('market_ranking_records');
    final hasBooks = await _tableExists('market_book_records');
    final hasRuns = await _tableExists('market_scan_run_records');

    if (hasRankings && hasBooks) {
      await customStatement('''
        DELETE FROM market_ranking_records
        WHERE book_id IN (
          SELECT id FROM market_book_records WHERE platform = 'jinjiang'
        )
      ''');
    }
    if (hasRankings && hasRuns) {
      await customStatement('''
        DELETE FROM market_ranking_records
        WHERE run_id IN (
          SELECT id FROM market_scan_run_records WHERE platform = 'jinjiang'
        )
      ''');
    }
    if (hasBooks) {
      await customStatement('''
        DELETE FROM market_book_records
        WHERE platform = 'jinjiang'
      ''');
    }
    if (hasRuns) {
      await customStatement('''
        DELETE FROM market_scan_run_records
        WHERE platform = 'jinjiang'
      ''');
    }
  }

  Future<void> _migrateWorkshopProjectBibleAndVolumes(Migrator migrator) async {
    if (!await _tableExists('project_records')) {
      await _addWorkshopChapterPlanColumnsIfTableExists(migrator);
      return;
    }
    await customStatement('''
      INSERT INTO project_bible_records (
        project_id,
        description_markdown,
        world_building_markdown,
        characters_blueprint_markdown,
        outline_master_markdown,
        outline_detail_yaml,
        created_at,
        updated_at
      )
      SELECT
        id,
        COALESCE(description, ''),
        '',
        '',
        '',
        '',
        created_at,
        updated_at
      FROM project_records
      WHERE id NOT IN (SELECT project_id FROM project_bible_records)
    ''');

    await customStatement('''
      INSERT INTO chapter_volume_records (
        id,
        project_id,
        volume_index,
        title,
        created_at,
        updated_at
      )
      SELECT
        'legacy-default-volume-' || project_id,
        project_id,
        1,
        '未分卷章节',
        MIN(created_at),
        MAX(updated_at)
      FROM chapter_plan_records
      GROUP BY project_id
      HAVING project_id NOT IN (
        SELECT project_id FROM chapter_volume_records WHERE volume_index = 1
      )
    ''');

    await _addWorkshopChapterPlanColumnsIfTableExists(migrator);
  }

  Future<void> _addWorkshopChapterPlanColumnsIfTableExists(
    Migrator migrator,
  ) async {
    if (!await _tableExists('chapter_plan_records')) {
      return;
    }
    await _addChapterPlanColumnIfMissing(
      migrator,
      'volume_id',
      chapterPlanRecords.volumeId,
    );
    await _addChapterPlanColumnIfMissing(
      migrator,
      'volume_index',
      chapterPlanRecords.volumeIndex,
    );
    await _addChapterPlanColumnIfMissing(
      migrator,
      'volume_title',
      chapterPlanRecords.volumeTitle,
    );
    await _addChapterPlanColumnIfMissing(
      migrator,
      'chapter_local_index',
      chapterPlanRecords.chapterLocalIndex,
    );
    await _addChapterPlanColumnIfMissing(
      migrator,
      'core_event',
      chapterPlanRecords.coreEvent,
    );
    await _addChapterPlanColumnIfMissing(
      migrator,
      'emotion_arc',
      chapterPlanRecords.emotionArc,
    );
    await _addChapterPlanColumnIfMissing(
      migrator,
      'chapter_hook',
      chapterPlanRecords.chapterHook,
    );
    await _addChapterPlanColumnIfMissing(
      migrator,
      'outline_markdown',
      chapterPlanRecords.outlineMarkdown,
    );

    final nowExpression = _sqliteNowMillisecondsExpression;
    await customStatement('''
      UPDATE chapter_plan_records
      SET
        volume_id = 'legacy-default-volume-' || project_id,
        volume_index = 1,
        volume_title = '未分卷章节',
        chapter_local_index = chapter_index,
        updated_at = CASE
          WHEN updated_at > $nowExpression THEN updated_at
          ELSE $nowExpression
        END
      WHERE TRIM(volume_id) = ''
    ''');
  }

  String get _sqliteNowMillisecondsExpression =>
      "(CAST(strftime('%s', 'now') AS INTEGER) * 1000)";

  Future<void> _addChapterPlanColumnIfMissing(
    Migrator migrator,
    String columnName,
    GeneratedColumn column,
  ) async {
    if (!await _columnExists('chapter_plan_records', columnName)) {
      await migrator.addColumn(chapterPlanRecords, column);
    }
  }

  Future<void> _dropNovelWorkshopPersistence() async {
    final hasWorkflowTasks = await _tableExists('workflow_task_records');
    if (hasWorkflowTasks) {
      final hasPromptTraces = await _tableExists(
        'workflow_prompt_trace_records',
      );
      if (hasPromptTraces) {
        await customStatement('''
          DELETE FROM workflow_prompt_trace_records
          WHERE workflow_task_id IN (
            SELECT id FROM workflow_task_records
            WHERE kind = 'novel_chapter_draft'
          )
        ''');
      }
    }
    await customStatement('DROP TABLE IF EXISTS memory_projection_records');
    await customStatement('DROP TABLE IF EXISTS accepted_chapter_records');
    await customStatement('DROP TABLE IF EXISTS chapter_draft_run_records');
    await customStatement('DROP TABLE IF EXISTS chapter_plan_records');
    await customStatement('DROP TABLE IF EXISTS story_bible_records');
    if (hasWorkflowTasks) {
      await customStatement('''
        DELETE FROM workflow_task_records
        WHERE kind = 'novel_chapter_draft'
      ''');
    }
  }

  Future<bool> _tableExists(String tableName) async {
    final rows = await customSelect(
      '''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table' AND name = ?
      LIMIT 1
      ''',
      variables: [Variable.withString(tableName)],
    ).get();
    return rows.isNotEmpty;
  }

  Future<bool> _columnExists(String tableName, String columnName) async {
    final rows = await customSelect('PRAGMA table_info($tableName)').get();
    return rows.any((row) => row.data['name'] == columnName);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = await AppDatabase.databaseFile();
    return NativeDatabase.createInBackground(file);
  });
}
