import 'package:flutter/material.dart';

import '../../../../core/ui/persona_page.dart';
import '../../domain/novel_workshop.dart';

/// Sliding detail panel that displays a character's full information
/// and their relationships. Slides in from the right side of the canvas.
class CharacterDetailPanel extends StatelessWidget {
  const CharacterDetailPanel({
    required this.character,
    required this.characters,
    required this.relationships,
    this.onClose,
    super.key,
  });

  final NovelCharacter character;
  final List<NovelCharacter> characters;
  final List<NovelRelationship> relationships;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return PersonaPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    character.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClose,
                  tooltip: '关闭',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Scrollable content.
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildField(context, '角色', character.role),
                _buildField(context, '状态', character.currentStatus),
                _buildField(context, '别名', character.aliases),
                _buildField(context, '阵营', character.faction),
                _buildField(context, '长期目标', character.longTermGoal),
                _buildField(context, '秘密', character.secrets),
                _buildField(context, '标签', character.tags),
                _buildChapterRange(context),
                // Relationships section.
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
                  for (final rel in _characterRelationships) _buildRelationshipTile(context, rel),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<NovelRelationship> get _characterRelationships {
    return relationships
        .where((r) =>
            r.fromCharacterId == character.id ||
            r.toCharacterId == character.id)
        .toList();
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
    if (character.firstChapterIndex == null && character.lastChapterIndex == null) {
      return const SizedBox.shrink();
    }
    final first = character.firstChapterIndex;
    final last = character.lastChapterIndex;
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
    final isOutgoing = rel.fromCharacterId == character.id;
    final otherId = isOutgoing ? rel.toCharacterId : rel.fromCharacterId;
    final otherName = characters
        .where((c) => c.id == otherId)
        .map((c) => c.name)
        .firstOrNull ?? '未知角色';
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
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
