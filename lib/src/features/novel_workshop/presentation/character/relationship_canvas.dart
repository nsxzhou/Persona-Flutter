import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../domain/novel_workshop.dart';

class RelationshipCanvas extends StatefulWidget {
  const RelationshipCanvas({
    required this.characters,
    required this.relationships,
    this.selectedCharacterId,
    this.onCharacterTap,
    super.key,
  });

  final List<NovelCharacter> characters;
  final List<NovelRelationship> relationships;
  final String? selectedCharacterId;
  final ValueChanged<NovelCharacter>? onCharacterTap;

  @override
  State<RelationshipCanvas> createState() => _RelationshipCanvasState();
}

class _RelationshipCanvasState extends State<RelationshipCanvas>
    with SingleTickerProviderStateMixin {
  static const _minNodeGap = 104.0;
  static const _springLength = 185.0;
  static const _timeStep = 0.72;
  static const _damping = 0.82;
  static const _centerPull = 0.004;
  static const _repulsion = 18500.0;
  static const _spring = 0.026;
  static const _collision = 0.34;
  static const _maxVelocity = 18.0;

  late final Ticker _ticker;
  Size _canvasSize = Size.zero;
  final Map<String, Offset> _positions = {};
  final Map<String, Offset> _velocities = {};
  String? _draggingCharacterId;
  Offset _panOffset = Offset.zero;
  int _settledFrames = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void didUpdateWidget(covariant RelationshipCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameCharacterIds(oldWidget.characters, widget.characters)) {
      _positions.removeWhere(
        (id, _) => widget.characters.every((character) => character.id != id),
      );
      _velocities.removeWhere(
        (id, _) => widget.characters.every((character) => character.id != id),
      );
      _settledFrames = 0;
      if (!_ticker.isActive) _ticker.start();
    } else if (oldWidget.relationships != widget.relationships) {
      _settledFrames = 0;
      if (!_ticker.isActive) _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        _ensurePositions();
        return ClipRect(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: _handlePanStart,
              onPanUpdate: _handlePanUpdate,
              onPanEnd: _handlePanEnd,
              onPanCancel: _handlePanCancel,
              onTapUp: _handleTapUp,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RelationshipEdgePainter(
                        colorScheme: colorScheme,
                        relationships: _visibleRelationships,
                        positions: _positions,
                        selectedCharacterId: widget.selectedCharacterId,
                        panOffset: _panOffset,
                      ),
                    ),
                  ),
                  for (final character in widget.characters)
                    _buildNode(context, character),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNode(BuildContext context, NovelCharacter character) {
    final position = _positions[character.id] ?? Offset.zero;
    final relationCount = _relationCounts[character.id] ?? 0;
    final radius = _nodeRadius(relationCount);
    final selectedIds = _selectedIds;
    final isSelected = character.id == widget.selectedCharacterId;
    final isConnected = selectedIds.contains(character.id);
    return Positioned(
      left: position.dx + _panOffset.dx - radius,
      top: position.dy + _panOffset.dy - radius,
      width: radius * 2,
      height: radius * 2,
      child: _CharacterGraphNode(
        character: character,
        isSelected: isSelected,
        isConnected: isConnected,
        hasSelection: widget.selectedCharacterId != null,
        onTap: widget.onCharacterTap == null
            ? null
            : () => widget.onCharacterTap!(character),
      ),
    );
  }

  List<NovelRelationship> get _visibleRelationships {
    final ids = widget.characters.map((character) => character.id).toSet();
    return widget.relationships
        .where(
          (relationship) =>
              ids.contains(relationship.fromCharacterId) &&
              ids.contains(relationship.toCharacterId),
        )
        .toList(growable: false);
  }

  Map<String, int> get _relationCounts {
    final counts = {for (final character in widget.characters) character.id: 0};
    for (final relationship in _visibleRelationships) {
      counts[relationship.fromCharacterId] =
          (counts[relationship.fromCharacterId] ?? 0) + 1;
      counts[relationship.toCharacterId] =
          (counts[relationship.toCharacterId] ?? 0) + 1;
    }
    return counts;
  }

  Set<String> get _selectedIds {
    final selectedId = widget.selectedCharacterId;
    if (selectedId == null) return const {};
    final ids = <String>{selectedId};
    for (final relationship in _visibleRelationships) {
      if (relationship.fromCharacterId == selectedId) {
        ids.add(relationship.toCharacterId);
      }
      if (relationship.toCharacterId == selectedId) {
        ids.add(relationship.fromCharacterId);
      }
    }
    return ids;
  }

  void _ensurePositions() {
    if (!_canvasSize.isFinite || _canvasSize == Size.zero) return;
    final center = Offset(_canvasSize.width / 2, _canvasSize.height / 2);
    final radius = math.min(_canvasSize.width, _canvasSize.height) * 0.32;
    for (var i = 0; i < widget.characters.length; i++) {
      final character = widget.characters[i];
      _positions.putIfAbsent(character.id, () {
        final angle = (i / widget.characters.length) * math.pi * 2;
        return Offset(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius,
        );
      });
      _velocities.putIfAbsent(character.id, () => Offset.zero);
    }
  }

  void _tick(Duration elapsed) {
    if (!mounted || widget.characters.length < 2 || _canvasSize == Size.zero) {
      return;
    }
    final movement = _stepLayout();
    if (movement < 0.08) {
      _settledFrames += 1;
      if (_settledFrames > 45) _ticker.stop();
    } else {
      _settledFrames = 0;
    }
    setState(() {});
  }

  double _stepLayout() {
    final ids = widget.characters.map((character) => character.id).toList();
    final forces = {for (final id in ids) id: Offset.zero};
    final center = Offset(_canvasSize.width / 2, _canvasSize.height / 2);

    for (var i = 0; i < ids.length; i++) {
      for (var j = i + 1; j < ids.length; j++) {
        final a = ids[i];
        final b = ids[j];
        final delta = _positions[a]! - _positions[b]!;
        final distance = math.max(delta.distance, 1.0);
        final direction = delta / distance;
        final repel = _repulsion / (distance * distance);
        final overlap = math.max(0, _minNodeGap - distance) * _collision;
        final force = direction * (repel + overlap);
        forces[a] = forces[a]! + force;
        forces[b] = forces[b]! - force;
      }
    }

    for (final relationship in _visibleRelationships) {
      final from = relationship.fromCharacterId;
      final to = relationship.toCharacterId;
      final delta = _positions[to]! - _positions[from]!;
      final distance = math.max(delta.distance, 1.0);
      final direction = delta / distance;
      final strength = (relationship.strength.clamp(1, 10)) / 6.0;
      final force =
          direction * ((distance - _springLength) * _spring * strength);
      forces[from] = forces[from]! + force;
      forces[to] = forces[to]! - force;
    }

    var totalMovement = 0.0;
    for (final id in ids) {
      if (id == _draggingCharacterId) continue;
      final toCenter = (center - _positions[id]!) * _centerPull;
      final velocity = (_velocities[id]! + forces[id]! + toCenter) * _damping;
      final limited = _limit(velocity, _maxVelocity);
      final next = _clampToCanvas(_positions[id]! + limited * _timeStep);
      totalMovement += (next - _positions[id]!).distance;
      _velocities[id] = limited;
      _positions[id] = next;
    }
    return totalMovement / ids.length;
  }

  Offset _limit(Offset value, double maxLength) {
    final distance = value.distance;
    if (distance <= maxLength || distance == 0) return value;
    return value / distance * maxLength;
  }

  Offset _clampToCanvas(Offset value) {
    const padding = 48.0;
    return Offset(
      value.dx.clamp(padding, math.max(padding, _canvasSize.width - padding)),
      value.dy.clamp(padding, math.max(padding, _canvasSize.height - padding)),
    );
  }

  void _handlePanStart(DragStartDetails details) {
    final hit = _hitTest(details.localPosition);
    _draggingCharacterId = hit?.id;
    if (_draggingCharacterId != null) {
      _velocities[_draggingCharacterId!] = Offset.zero;
    }
    if (!_ticker.isActive) _ticker.start();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final draggingId = _draggingCharacterId;
    if (draggingId == null) {
      setState(() => _panOffset += details.delta);
      return;
    }
    setState(() {
      _positions[draggingId] = _clampToCanvas(
        _positions[draggingId]! + details.delta,
      );
      _velocities[draggingId] = Offset.zero;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    _draggingCharacterId = null;
    _settledFrames = 0;
    if (!_ticker.isActive) _ticker.start();
  }

  void _handlePanCancel() {
    _draggingCharacterId = null;
  }

  void _handleTapUp(TapUpDetails details) {
    final character = _hitTest(details.localPosition);
    if (character != null && widget.onCharacterTap != null) {
      widget.onCharacterTap!(character);
    }
  }

  NovelCharacter? _hitTest(Offset localPosition) {
    for (final character in widget.characters.reversed) {
      final position = _positions[character.id];
      if (position == null) continue;
      final radius = _nodeRadius(_relationCounts[character.id] ?? 0);
      if ((localPosition - (position + _panOffset)).distance <= radius + 8) {
        return character;
      }
    }
    return null;
  }

  double _nodeRadius(int relationCount) {
    return (34.0 + relationCount * 2.5).clamp(34.0, 46.0);
  }

  bool _sameCharacterIds(
    List<NovelCharacter> oldCharacters,
    List<NovelCharacter> newCharacters,
  ) {
    if (oldCharacters.length != newCharacters.length) return false;
    for (var i = 0; i < oldCharacters.length; i++) {
      if (oldCharacters[i].id != newCharacters[i].id) return false;
    }
    return true;
  }
}

class _RelationshipEdgePainter extends CustomPainter {
  const _RelationshipEdgePainter({
    required this.colorScheme,
    required this.relationships,
    required this.positions,
    required this.selectedCharacterId,
    required this.panOffset,
  });

  final ColorScheme colorScheme;
  final List<NovelRelationship> relationships;
  final Map<String, Offset> positions;
  final String? selectedCharacterId;
  final Offset panOffset;

  @override
  void paint(Canvas canvas, Size size) {
    for (final relationship in relationships) {
      final from = positions[relationship.fromCharacterId];
      final to = positions[relationship.toCharacterId];
      if (from == null || to == null) continue;
      final highlighted =
          relationship.fromCharacterId == selectedCharacterId ||
          relationship.toCharacterId == selectedCharacterId;
      final color = highlighted
          ? colorScheme.primary
          : colorScheme.primary.withValues(alpha: 0.24);
      final start = from + panOffset;
      final end = to + panOffset;
      final delta = end - start;
      if (delta.distance < 1) continue;
      final unit = delta / delta.distance;
      final clippedStart = start + unit * 36;
      final clippedEnd = end - unit * 36;

      canvas.drawLine(
        clippedStart,
        clippedEnd,
        Paint()
          ..color = color
          ..strokeWidth = highlighted ? 2.2 : 1.15
          ..strokeCap = StrokeCap.round,
      );
      _drawArrow(canvas, clippedEnd, unit, color);
    }
  }

  void _drawArrow(Canvas canvas, Offset tip, Offset unit, Color color) {
    final normal = Offset(-unit.dy, unit.dx);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        (tip - unit * 10 + normal * 5).dx,
        (tip - unit * 10 + normal * 5).dy,
      )
      ..lineTo(
        (tip - unit * 10 - normal * 5).dx,
        (tip - unit * 10 - normal * 5).dy,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _RelationshipEdgePainter oldDelegate) {
    return oldDelegate.relationships != relationships ||
        oldDelegate.positions != positions ||
        oldDelegate.selectedCharacterId != selectedCharacterId ||
        oldDelegate.panOffset != panOffset ||
        oldDelegate.colorScheme != colorScheme;
  }
}

class _CharacterGraphNode extends StatelessWidget {
  const _CharacterGraphNode({
    required this.character,
    required this.isSelected,
    required this.isConnected,
    required this.hasSelection,
    required this.onTap,
  });

  final NovelCharacter character;
  final bool isSelected;
  final bool isConnected;
  final bool hasSelection;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dimmed = hasSelection && !isConnected && !isSelected;
    final fillColor = isSelected
        ? colorScheme.primaryContainer
        : dimmed
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.55)
        : colorScheme.surface;
    final borderColor = isSelected
        ? colorScheme.primary
        : dimmed
        ? colorScheme.outlineVariant
        : colorScheme.outline;
    final textColor = isSelected
        ? colorScheme.onPrimaryContainer
        : dimmed
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurface;

    return Semantics(
      button: true,
      label: '角色 ${character.name}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('relationship-node-${character.id}'),
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: fillColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: isSelected ? 2.4 : 1.3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: 52,
                child: Text(
                  character.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: textTheme.labelMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
