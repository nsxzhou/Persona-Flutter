import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/persona_page.dart';
import '../../application/novel_workshop_providers.dart';
import '../../domain/novel_workshop.dart';
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
  /// whether the draft should be applied. This avoids coupling to a specific
  /// dialog implementation in the parent file.
  final Future<bool?> Function(BuildContext context, AssetGenerationRun run)
  onShowDraftReview;

  @override
  ConsumerState<CharacterGraphTab> createState() => _CharacterGraphTabState();
}

class _CharacterGraphTabState extends ConsumerState<CharacterGraphTab> {
  NovelCharacter? _selectedCharacter;

  bool get _generating =>
      widget.latestRun?.status == AssetGenerationStatus.pending ||
      widget.latestRun?.status == AssetGenerationStatus.running;

  @override
  Widget build(BuildContext context) {
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
                  if (_canReview(widget.latestRun))
                    TextButton.icon(
                      onPressed: controllerState.isLoading
                          ? null
                          : () => _reviewCharacterDraft(
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
              child: Stack(
                children: [
                  Positioned.fill(
                    child: RelationshipCanvas(
                      characters: characterItems,
                      relationships: relationshipItems,
                      selectedCharacterId: activeSelectedCharacter?.id,
                      onCharacterTap: (character) {
                        setState(() => _selectedCharacter = character);
                      },
                    ),
                  ),
                  // Detail panel slides in from the right.
                  AnimatedSlide(
                    offset: activeSelectedCharacter != null
                        ? Offset.zero
                        : const Offset(1, 0),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 340,
                        child: activeSelectedCharacter != null
                            ? CharacterDetailPanel(
                                character: activeSelectedCharacter,
                                characters: characterItems,
                                relationships: relationshipItems,
                                onClose: () =>
                                    setState(() => _selectedCharacter = null),
                                onSaved: () => setState(() {}),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Legacy markdown reference.
          if (widget.legacyMarkdown.trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            PersonaSectionHeader(
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
      await _reviewCharacterDraft(context, ref, result.run);
    } on Object {
      // Controller listener renders the error.
    }
  }

  Future<void> _reviewCharacterDraft(
    BuildContext context,
    WidgetRef ref,
    AssetGenerationRun run,
  ) async {
    final shouldApply = await widget.onShowDraftReview(context, run);
    if (shouldApply != true) return;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('导入失败：$error')));
    }
  }
}

bool _canReview(AssetGenerationRun? run) {
  if (run == null) return false;
  return (run.status == AssetGenerationStatus.succeeded ||
          run.status == AssetGenerationStatus.applied) &&
      run.draftMarkdown.trim().isNotEmpty;
}
