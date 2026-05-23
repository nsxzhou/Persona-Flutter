import '../domain/novel_workshop.dart';

bool canReviewAssetDraft(AssetGenerationRun? run) {
  if (run == null) return false;
  return run.status == AssetGenerationStatus.succeeded &&
      run.draftMarkdown.trim().isNotEmpty;
}
