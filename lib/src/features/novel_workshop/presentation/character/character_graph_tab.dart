import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/persona_page.dart';
import '../../application/novel_workshop_providers.dart';
import '../../domain/novel_workshop.dart';
import '../asset_review_state.dart';
import 'character_detail_panel.dart';
import 'relationship_canvas.dart';

/// Tab displaying the character relationship graph as the sole primary view.
///
/// Clicking a node slides in a detail panel from the right showing the
/// character's full information and relationships.
class CharacterGraphTab extends ConsumerStatefulWidget {
  const CharacterGraphTab({
    required this.projectId,
    required this.legacyMarkdown,
    required this.characters,
    required this.relationships,
    required this.latestRun,
    required this.onShowDraftReview,
    super.key,
  });

  final String projectId;
  final String legacyMarkdown;
  final AsyncValue<List<NovelCharacter>> characters;
  final AsyncValue<List<NovelRelationship>> relationships;
  final AssetGenerationRun? latestRun;

  /// Callback to show the draft review dialog. Receives the run and returns
  /// a result indicating the user's chosen action. This avoids coupling to a
  /// specific dialog implementation in the parent file.
  final Future<AssetDraftReviewResult> Function(
    BuildContext context,
    AssetGenerationRun run,
  ) onShowDraftReview;

  @override
  ConsumerState<CharacterGraphTab> createState() => _CharacterGraphTabState();
}

class _CharacterGraphTabState extends ConsumerState<CharacterGraphTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  NovelCharacter? _selectedCharacter;

  bool get _generating =>
      widget.latestRun?.status == AssetGenerationStatus.pending ||
      widget.latestRun?.status == AssetGenerationStatus.running;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final controllerState = ref.watch(novelWorkshopControllerProvider);
    return widget.characters.when(
      data: (characterItems) => widget.relationships.when(
        data: (relationshipItems) => _buildContent(
          context,
          controllerState,
          characterItems,
          relationshipItems,
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: Text('无法加载关系图：$e'),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(20),
        child: Text('无法加载角色卡片：$e'),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AsyncValue<void> controllerState,
    List<NovelCharacter> characterItems,
    List<NovelRelationship> relationshipItems,
  ) {
    final activeSelectedId = _selectedCharacter?.id;
    final activeSelectedCharacter = activeSelectedId == null
        ? null
        : characterItems
              .where((item) => item.id == activeSelectedId)
              .firstOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action bar.
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final description = Text(
                '结构化角色卡片和有向关系边会进入章节生成上下文。点击节点查看详情，或打开角色面板进行编辑。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              );
              final actions = Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: characterItems.isEmpty
                        ? null
                        : () => setState(
                            () => _selectedCharacter =
                                activeSelectedCharacter ?? characterItems.first,
                          ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(
                      activeSelectedCharacter == null ? '编辑角色' : '编辑已选角色',
                    ),
                  ),
                  OutlinedButton.icon(
                    key: const ValueKey('generate-asset-charactersBlueprint'),
                    onPressed: controllerState.isLoading || _generating
                        ? null
                        : () => _generateCharacters(context, ref),
                    icon: _generating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_fix_high_outlined, size: 18),
                    label: Text(_generating ? '生成中' : '生成角色草稿'),
                  ),
                  if (canReviewAssetDraft(widget.latestRun))
                    TextButton.icon(
                      onPressed: controllerState.isLoading
                          ? null
                          : () => _reviewAndHandleDraft(
                              context,
                              ref,
                              widget.latestRun!,
                            ),
                      icon: const Icon(Icons.rate_review_outlined, size: 18),
                      label: const Text('查看草稿'),
                    ),
                ],
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [description, const SizedBox(height: 12), actions],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: description),
                  const SizedBox(width: 20),
                  actions,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          // Graph canvas with optional sliding detail panel, or empty state.
          if (characterItems.isEmpty)
            SizedBox(
              height: 520,
              child: Center(
                child: PersonaEmptyStateCard(
                  icon: Icons.people_outline,
                  title: '暂无结构化角色',
                  description: '生成角色草稿后，角色卡片和关系边会在此展示；导入后可在关系图中选择角色并编辑。',
                  centered: true,
                  maxWidth: 620,
                  action: OutlinedButton.icon(
                    onPressed: _generating
                        ? null
                        : () => _generateCharacters(context, ref),
                    icon: _generating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_fix_high_outlined, size: 18),
                    label: Text(_generating ? '生成中' : '生成角色草稿'),
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 520,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: RelationshipCanvas(
                      characters: characterItems,
                      relationships: relationshipItems,
                      selectedCharacterId: activeSelectedCharacter?.id,
                      onCharacterTap: (character) {
                        setState(() => _selectedCharacter = character);
                      },
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, animation) {
                      return SizeTransition(
                        sizeFactor: animation,
                        axis: Axis.horizontal,
                        axisAlignment: 1,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: activeSelectedCharacter == null
                        ? const SizedBox.shrink(
                            key: ValueKey('character-detail-empty'),
                          )
                        : Padding(
                            key: ValueKey(
                              'character-detail-${activeSelectedCharacter.id}',
                            ),
                            padding: const EdgeInsets.only(left: 16),
                            child: SizedBox(
                              width: 340,
                              child: CharacterDetailPanel(
                                character: activeSelectedCharacter,
                                characters: characterItems,
                                relationships: relationshipItems,
                                onClose: () =>
                                    setState(() => _selectedCharacter = null),
                                onSaved: () => setState(() {}),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          // Legacy markdown reference.
          if (widget.legacyMarkdown.trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            const PersonaSectionHeader(
              title: '旧角色索引参考',
              description: '历史 Markdown 不自动迁移，仅供对照。',
            ),
            const SizedBox(height: 10),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: MarkdownBody(data: widget.legacyMarkdown.trim()),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _generateCharacters(BuildContext context, WidgetRef ref) async {
    try {
      final result = await ref
          .read(novelWorkshopControllerProvider.notifier)
          .generateAsset(
            projectId: widget.projectId,
            kind: AssetGenerationKind.charactersBlueprint,
          );
      if (!context.mounted) return;
      await _reviewAndHandleDraft(context, ref, result.run);
    } on Object {
      // Controller listener renders the error.
    }
  }

  /// Shows the review dialog and handles apply / regenerate / cancel actions.
  /// Loops back to regenerate if the user requests regeneration.
  Future<void> _reviewAndHandleDraft(
    BuildContext context,
    WidgetRef ref,
    AssetGenerationRun run,
  ) async {
    final reviewResult = await widget.onShowDraftReview(context, run);
    if (reviewResult.isApply) {
      try {
        await ref
            .read(novelWorkshopControllerProvider.notifier)
            .applyAssetDraft(run.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('角色草稿已导入。')));
      } on Object catch (error) {
        if (!context.mounted) return;
        _showApplyErrorSheet(
          context,
          ref,
          error: error.toString(),
          run: run,
        );
      }
    } else if (reviewResult.isRegenerate) {
      try {
        final regenResult = await ref
            .read(novelWorkshopControllerProvider.notifier)
            .regenerateAssetWithFeedback(
              projectId: widget.projectId,
              kind: AssetGenerationKind.charactersBlueprint,
              previousRunId: run.id,
              previousDraft: run.draftMarkdown,
              validationErrors: run.errorMessage ?? '',
              userFeedback: reviewResult.feedback ?? '',
            );
        if (!context.mounted) return;
        // Re-open review dialog with the new draft.
        await _reviewAndHandleDraft(context, ref, regenResult.run);
      } on Object {
        // Controller listener renders the error.
      }
    }
  }

  void _showApplyErrorSheet(
    BuildContext context,
    WidgetRef ref, {
    required String error,
    required AssetGenerationRun run,
  }) {
    final feedbackController = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(sheetContext).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '导入失败',
                      style: Theme.of(sheetContext).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SelectableText(
                error,
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(sheetContext).colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: feedbackController,
                decoration: const InputDecoration(
                  labelText: '修改意见（可选）',
                  hintText: '输入修改意见，让 AI 修正问题...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () {
                      final feedback = feedbackController.text.trim();
                      Navigator.of(sheetContext).pop();
                      _regenerateFromError(
                        context,
                        ref,
                        run: run,
                        error: error,
                        feedback: feedback,
                      );
                    },
                    icon: const Icon(Icons.refresh_outlined, size: 18),
                    label: const Text('重新生成'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _regenerateFromError(
    BuildContext context,
    WidgetRef ref, {
    required AssetGenerationRun run,
    required String error,
    String feedback = '',
  }) async {
    try {
      final regenResult = await ref
          .read(novelWorkshopControllerProvider.notifier)
          .regenerateAssetWithFeedback(
            projectId: widget.projectId,
            kind: AssetGenerationKind.charactersBlueprint,
            previousRunId: run.id,
            previousDraft: run.draftMarkdown,
            validationErrors: error,
            userFeedback: feedback,
          );
      if (!context.mounted) return;
      await _reviewAndHandleDraft(context, ref, regenResult.run);
    } on Object {
      // Controller listener renders the error.
    }
  }
}
