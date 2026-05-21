import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/persona_page.dart';
import '../../application/novel_workshop_providers.dart';
import '../../domain/novel_workshop.dart';

/// Sliding detail panel that displays a character's full information
/// and their relationships. Supports inline editing of character fields.
class CharacterDetailPanel extends ConsumerStatefulWidget {
  const CharacterDetailPanel({
    required this.character,
    required this.characters,
    required this.relationships,
    this.onClose,
    this.onSaved,
    super.key,
  });

  final NovelCharacter character;
  final List<NovelCharacter> characters;
  final List<NovelRelationship> relationships;
  final VoidCallback? onClose;
  final VoidCallback? onSaved;

  @override
  ConsumerState<CharacterDetailPanel> createState() =>
      _CharacterDetailPanelState();
}

class _CharacterDetailPanelState extends ConsumerState<CharacterDetailPanel> {
  bool _editing = false;
  bool _saving = false;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl = TextEditingController();
  late final TextEditingController _roleCtrl = TextEditingController();
  late final TextEditingController _statusCtrl = TextEditingController();
  late final TextEditingController _aliasesCtrl = TextEditingController();
  late final TextEditingController _factionCtrl = TextEditingController();
  late final TextEditingController _goalCtrl = TextEditingController();
  late final TextEditingController _secretsCtrl = TextEditingController();
  late final TextEditingController _tagsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant CharacterDetailPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.character.id != widget.character.id) {
      _editing = false;
      _syncControllers();
    }
  }

  void _disposeControllers() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    _statusCtrl.dispose();
    _aliasesCtrl.dispose();
    _factionCtrl.dispose();
    _goalCtrl.dispose();
    _secretsCtrl.dispose();
    _tagsCtrl.dispose();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return PersonaPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with action buttons.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: _editing
                      ? TextFormField(
                          controller: _nameCtrl,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 4),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? '名称不能为空' : null,
                        )
                      : Text(
                          widget.character.name,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
                if (_editing) ...[
                  TextButton(
                    onPressed: () => setState(() {
                      _editing = false;
                      _resetControllers();
                    }),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 4),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('保存'),
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => setState(() => _editing = true),
                    tooltip: '编辑',
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: widget.onClose,
                  tooltip: '关闭',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Scrollable content.
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_editing) ...[
                    _buildEditField('角色', _roleCtrl),
                    _buildEditField('状态', _statusCtrl),
                    _buildEditField('别名', _aliasesCtrl),
                    _buildEditField('阵营', _factionCtrl),
                    _buildEditField('长期目标', _goalCtrl),
                    _buildEditField('秘密', _secretsCtrl),
                    _buildEditField('标签', _tagsCtrl),
                  ] else ...[
                    _buildField(context, '角色', widget.character.role),
                    _buildField(context, '状态', widget.character.currentStatus),
                    _buildField(context, '别名', widget.character.aliases),
                    _buildField(context, '阵营', widget.character.faction),
                    _buildField(context, '长期目标', widget.character.longTermGoal),
                    _buildField(context, '秘密', widget.character.secrets),
                    _buildField(context, '标签', widget.character.tags),
                    _buildChapterRange(context),
                  ],
                  // Relationships section (always read-only).
                  if (_characterRelationships.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      '关系',
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final rel in _characterRelationships)
                      _buildRelationshipTile(context, rel),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<NovelRelationship> get _characterRelationships {
    return widget.relationships
        .where(
          (r) =>
              r.fromCharacterId == widget.character.id ||
              r.toCharacterId == widget.character.id,
        )
        .toList();
  }

  void _syncControllers() {
    final c = widget.character;
    _nameCtrl.text = c.name;
    _roleCtrl.text = c.role;
    _statusCtrl.text = c.currentStatus;
    _aliasesCtrl.text = c.aliases;
    _factionCtrl.text = c.faction;
    _goalCtrl.text = c.longTermGoal;
    _secretsCtrl.text = c.secrets;
    _tagsCtrl.text = c.tags;
  }

  void _resetControllers() => _syncControllers();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(novelWorkshopRepositoryProvider)
          .saveCharacter(
            id: widget.character.id,
            input: NovelCharacterInput(
              projectId: widget.character.projectId,
              name: _nameCtrl.text.trim(),
              aliases: _aliasesCtrl.text.trim(),
              tags: _tagsCtrl.text.trim(),
              faction: _factionCtrl.text.trim(),
              role: _roleCtrl.text.trim(),
              longTermGoal: _goalCtrl.text.trim(),
              currentStatus: _statusCtrl.text.trim(),
              secrets: _secretsCtrl.text.trim(),
              firstChapterIndex: widget.character.firstChapterIndex,
              lastChapterIndex: widget.character.lastChapterIndex,
            ),
          );
      if (!mounted) return;
      setState(() => _editing = false);
      widget.onSaved?.call();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('角色已保存')));
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存失败：$e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildEditField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(labelText: label, isDense: true),
        maxLines: null,
      ),
    );
  }

  Widget _buildField(BuildContext context, String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(value.trim(), style: textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildChapterRange(BuildContext context) {
    if (widget.character.firstChapterIndex == null &&
        widget.character.lastChapterIndex == null) {
      return const SizedBox.shrink();
    }
    final first = widget.character.firstChapterIndex;
    final last = widget.character.lastChapterIndex;
    final range = first != null && last != null
        ? '第 $first - $last 章'
        : first != null
        ? '从第 $first 章起'
        : '截至第 $last 章';
    return _buildField(context, '出场章节', range);
  }

  Widget _buildRelationshipTile(BuildContext context, NovelRelationship rel) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isOutgoing = rel.fromCharacterId == widget.character.id;
    final otherId = isOutgoing ? rel.toCharacterId : rel.fromCharacterId;
    final otherName =
        widget.characters
            .where((c) => c.id == otherId)
            .map((c) => c.name)
            .firstOrNull ??
        '未知角色';
    final direction = isOutgoing ? '→' : '←';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            direction,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherName,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (rel.relationshipType.trim().isNotEmpty)
                  Text(
                    rel.relationshipType,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (rel.description.trim().isNotEmpty)
                  Text(
                    rel.description,
                    style: textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
