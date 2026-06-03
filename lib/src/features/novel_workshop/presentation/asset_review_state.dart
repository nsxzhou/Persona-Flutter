import '../domain/novel_workshop.dart';

bool canReviewAssetDraft(AssetGenerationRun? run) {
  if (run == null) return false;
  return run.status == AssetGenerationStatus.succeeded &&
      run.draftMarkdown.trim().isNotEmpty;
}

/// Result returned by the asset draft review dialog.
class AssetDraftReviewResult {
  const AssetDraftReviewResult.cancelled()
    : action = AssetDraftAction.cancel,
      feedback = null;

  const AssetDraftReviewResult.apply()
    : action = AssetDraftAction.apply,
      feedback = null;

  const AssetDraftReviewResult.regenerate([this.feedback])
    : action = AssetDraftAction.regenerate;

  final AssetDraftAction action;
  final String? feedback;

  bool get isApply => action == AssetDraftAction.apply;
  bool get isRegenerate => action == AssetDraftAction.regenerate;
  bool get isCancelled => action == AssetDraftAction.cancel;
}

enum AssetDraftAction { cancel, apply, regenerate }
