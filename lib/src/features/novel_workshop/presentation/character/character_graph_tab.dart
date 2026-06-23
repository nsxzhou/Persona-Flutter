import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/glass_container.dart';
import '../../../../core/ui/persona_page.dart';
import '../../application/character_graph_parser.dart';
import '../../application/novel_workshop_providers.dart';
import '../../domain/novel_workshop.dart';
import '../asset_review_state.dart';
import 'character_detail_panel.dart';
import 'relationship_canvas.dart';

/// Dialog shown before draft generation to collect optional user feedback.
class _PreGenerationFeedbackDialog extends StatefulWidget {
  const _PreGenerationFeedbackDialog();

  @override
  State<_PreGenerationFeedbackDialog> createState() =>
      _PreGenerationFeedbackDialogState();
}

class _PreGenerationFeedbackDialogState
    extends State<_PreGenerationFeedbackDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_fix_high_outlined,
                  color: colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '生成指导',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '可选：告诉 AI 你的具体要求或偏好，让生成结果更符合预期。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 4,
            minLines: 2,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: '例如：侧重描写角色内心冲突，避免过多战斗场景...',
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop<String?>(null),
                child: const Text('跳过'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () =>
                    Navigator.of(context).pop<String>(_controller.text),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('开始生成'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
    required this.charactersYaml,
    super.key,
  });

  final String projectId;
  final String legacyMarkdown;
  final AsyncValue<List<NovelCharacter>> characters;
  final AsyncValue<List<NovelRelationship>> relationships;
  final AssetGenerationRun? latestRun;
  final String charactersYaml;

  /// Callback to show the draft review dialog. Receives the run and returns
  /// a result indicating the user's chosen action. This avoids coupling to a
  /// specific dialog implementation in the parent file.
  final Future<AssetDraftReviewResult> Function(
    BuildContext context,
    AssetGenerationRun run,
  )
  onShowDraftReview;

  @override
  ConsumerState<CharacterGraphTab> createState() => _CharacterGraphTabState();
}

class _CharacterGraphTabState extends ConsumerState<CharacterGraphTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  NovelCharacter? _selectedCharacter;

  late final TextEditingController _yamlController;
  late String _loadedYaml;
  bool _editingYaml = false;

  bool get _isDirty => _yamlController.text != _loadedYaml;

  bool get _generating =>
      widget.latestRun?.status == AssetGenerationStatus.pending ||
      widget.latestRun?.status == AssetGenerationStatus.running;

  @override
  void initState() {
    super.initState();
    _loadedYaml = widget.charactersYaml;
    _yamlController = TextEditingController(text: _loadedYaml);
    _yamlController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant CharacterGraphTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.charactersYaml != widget.charactersYaml && !_isDirty) {
      _loadedYaml = widget.charactersYaml;
      _yamlController.text = _loadedYaml;
    }
  }

  @override
  void dispose() {
    _yamlController.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _editingYaml = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _yamlController.text = _loadedYaml;
      _editingYaml = false;
    });
  }

  Future<void> _saveYaml() async {
    final yaml = _yamlController.text;
    try {
      const CharacterGraphParser().parse(yaml);
    } on CharacterGraphValidationException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('YAML 格式错误：${error.message}')));
      return;
    }
    try {
      await ref
          .read(novelWorkshopControllerProvider.notifier)
          .applyCharactersYaml(
            projectId: widget.projectId,
            charactersYaml: yaml,
          );
      if (!mounted) return;
      setState(() {
        _loadedYaml = yaml;
        _editingYaml = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('角色蓝图已保存。')));
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存失败：$error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_editingYaml) {
      return _buildYamlEditor(context);
    }
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
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Description with editorial accent + inline actions ---
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 720;
              final descBlock = Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const WorkbenchSectionLabel('描述'),
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        '结构化角色卡片和有向关系边会进入章节生成上下文。点击节点查看详情，或打开角色面板进行编辑。',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.7,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              );
              final actionBar = Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: _startEditing,
                    icon: const Icon(Icons.code_outlined, size: 18),
                    label: const Text('编辑 YAML'),
                  ),
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
                  children: [descBlock, const SizedBox(height: 12), actionBar],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [descBlock, const SizedBox(width: 20), actionBar],
              );
            },
          ),
          const SizedBox(height: 20),

          // --- Graph section ---
          const WorkbenchSectionLabel('关系图谱'),
          const SizedBox(height: 10),
          // Graph canvas with optional sliding detail panel, or empty state.
          if (characterItems.isEmpty)
            SizedBox(
              height: 520,
              child: Center(
                child: WorkbenchEmptyState(
                  sectionLabel: '角色索引',
                  title: '暂无结构化角色',
                  description: '生成角色草稿后，角色卡片和关系边会在此展示；导入后可在关系图中选择角色并编辑。',
                  actions: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _startEditing,
                        icon: const Icon(Icons.code_outlined, size: 18),
                        label: const Text('编辑 YAML'),
                      ),
                      OutlinedButton.icon(
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
                    ],
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
                        alignment: Alignment.centerRight,
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
            const WorkbenchSectionLabel('旧角色索引参考', major: true),
            Text(
              '历史 Markdown 不自动迁移，仅供对照。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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

  Widget _buildYamlEditor(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Live validation status.
    CharacterGraphValidationException? validationError;
    try {
      const CharacterGraphParser().parse(_yamlController.text);
    } on CharacterGraphValidationException catch (e) {
      validationError = e;
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '编辑角色蓝图 YAML — 修改后保存，结构化角色和关系会同步更新。',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(onPressed: _cancelEditing, child: const Text('取消')),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _isDirty ? _saveYaml : null,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('保存'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Validation status pill.
          if (validationError != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'YAML 错误：${validationError.message}',
                style: TextStyle(
                  color: colorScheme.onErrorContainer,
                  fontSize: 12,
                ),
              ),
            )
          else if (_yamlController.text.trim().isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'YAML 有效',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _yamlController,
              maxLines: null,
              minLines: 20,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '在此编辑角色和关系的 YAML...',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateCharacters(BuildContext context, WidgetRef ref) async {
    // Show feedback dialog before generation.
    final feedback = await showGlassDialog<String>(
      context: context,
      builder: (context) => const _PreGenerationFeedbackDialog(),
    );
    if (feedback == null) return; // User cancelled.
    try {
      final result = await ref
          .read(novelWorkshopControllerProvider.notifier)
          .generateAsset(
            projectId: widget.projectId,
            kind: AssetGenerationKind.charactersBlueprint,
            userFeedback: feedback,
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
        _showApplyErrorSheet(context, ref, error: error.toString(), run: run);
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
