import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/novel_workshop.dart';

/// Force-directed layout engine for character relationship graphs.
///
/// Uses a spring-electric model: Coulomb repulsion between all node pairs
/// and Hooke attraction along edges. Pre-computes all positions before rendering.
class ForceDirectedLayout {
  ForceDirectedLayout({
    required this.characters,
    required this.relationships,
    required this.canvasSize,
    this.iterations = 200,
    this.repulsionStrength = 5000.0,
    this.attractionStrength = 0.005,
    this.damping = 0.85,
    this.padding = 50.0,
  });

  final List<NovelCharacter> characters;
  final List<NovelRelationship> relationships;
  final Size canvasSize;
  final int iterations;
  final double repulsionStrength;
  final double attractionStrength;
  final double damping;
  final double padding;

  late final Map<String, Offset> positions = _compute();
  late final Map<String, int> relationCounts = _countRelations();

  Map<String, int> _countRelations() {
    final counts = <String, int>{};
    for (final c in characters) {
      counts[c.id] = 0;
    }
    for (final r in relationships) {
      counts[r.fromCharacterId] = (counts[r.fromCharacterId] ?? 0) + 1;
      counts[r.toCharacterId] = (counts[r.toCharacterId] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, Offset> _compute() {
    if (characters.isEmpty) return {};

    // Initialize with circular seed positions.
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final seedRadius = (canvasSize.shortestSide / 2 - 80).clamp(60.0, 200.0);
    final velocities = <String, Offset>{};
    final pos = <String, Offset>{};

    for (var i = 0; i < characters.length; i++) {
      final angle = (i / characters.length) * 2 * math.pi - math.pi / 2;
      pos[characters[i].id] = Offset(
        center.dx + seedRadius * math.cos(angle),
        center.dy + seedRadius * math.sin(angle),
      );
      velocities[characters[i].id] = Offset.zero;
    }

    // For <3 characters, use static positions (no layout needed).
    if (characters.length < 3) {
      return pos;
    }

    // Build adjacency for quick lookup.
    final edges = relationships
        .where(
          (r) =>
              pos.containsKey(r.fromCharacterId) &&
              pos.containsKey(r.toCharacterId),
        )
        .toList();

    for (var iter = 0; iter < iterations; iter++) {
      final forces = <String, Offset>{};
      for (final c in characters) {
        forces[c.id] = Offset.zero;
      }

      // Repulsion between all pairs (Coulomb).
      for (var i = 0; i < characters.length; i++) {
        for (var j = i + 1; j < characters.length; j++) {
          final a = characters[i].id;
          final b = characters[j].id;
          final delta = pos[a]! - pos[b]!;
          final dist = delta.distance.clamp(1.0, double.infinity);
          final force = delta / dist * (repulsionStrength / (dist * dist));
          forces[a] = forces[a]! + force;
          forces[b] = forces[b]! - force;
        }
      }

      // Attraction along edges (Hooke).
      for (final edge in edges) {
        final delta = pos[edge.toCharacterId]! - pos[edge.fromCharacterId]!;
        final dist = delta.distance;
        if (dist < 0.1) continue;
        // Scale attraction by relationship strength (1-10).
        final strengthFactor = (edge.strength.clamp(1, 10)) / 5.0;
        final force = delta * dist * attractionStrength * strengthFactor;
        forces[edge.fromCharacterId] = forces[edge.fromCharacterId]! + force;
        forces[edge.toCharacterId] = forces[edge.toCharacterId]! - force;
      }

      // Update positions with damping.
      for (final c in characters) {
        final vel = (velocities[c.id]! + forces[c.id]!) * damping;
        velocities[c.id] = vel;
        final newPos = pos[c.id]! + vel;
        // Clamp to canvas bounds.
        pos[c.id] = Offset(
          newPos.dx.clamp(padding, canvasSize.width - padding),
          newPos.dy.clamp(padding, canvasSize.height - padding),
        );
      }
    }

    return pos;
  }

  /// Radius for a character node, scaled by relationship count.
  double nodeRadius(String characterId) {
    final count = relationCounts[characterId] ?? 0;
    return (26.0 + count * 2).clamp(26.0, 40.0);
  }
}

/// Interactive relationship graph canvas with force-directed layout.
///
/// Renders characters as circular nodes and relationships as directed
/// Bézier curve edges. Tapping a node triggers [onCharacterTap].
class RelationshipCanvas extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final layout = ForceDirectedLayout(
          characters: characters,
          relationships: relationships,
          canvasSize: size,
        );
        return GestureDetector(
          onTapUp: (details) => _handleTap(details, layout),
          child: CustomPaint(
            size: size,
            painter: _RelationshipPainter(
              colorScheme: colorScheme,
              characters: characters,
              relationships: relationships,
              layout: layout,
              selectedCharacterId: selectedCharacterId,
            ),
          ),
        );
      },
    );
  }

  void _handleTap(TapUpDetails details, ForceDirectedLayout layout) {
    if (onCharacterTap == null) return;
    final tapPos = details.localPosition;
    var closestDist = double.infinity;
    NovelCharacter? closest;

    for (final character in characters) {
      final nodePos = layout.positions[character.id];
      if (nodePos == null) continue;
      final dist = (tapPos - nodePos).distance;
      final radius = layout.nodeRadius(character.id);
      if (dist < radius + 10 && dist < closestDist) {
        closestDist = dist;
        closest = character;
      }
    }

    if (closest != null) {
      onCharacterTap!(closest);
    }
  }
}

class _RelationshipPainter extends CustomPainter {
  const _RelationshipPainter({
    required this.colorScheme,
    required this.characters,
    required this.relationships,
    required this.layout,
    required this.selectedCharacterId,
  });

  final ColorScheme colorScheme;
  final List<NovelCharacter> characters;
  final List<NovelRelationship> relationships;
  final ForceDirectedLayout layout;
  final String? selectedCharacterId;

  @override
  void paint(Canvas canvas, Size size) {
    if (characters.isEmpty) {
      _drawCenteredText(canvas, size, '暂无结构化角色');
      return;
    }

    final positions = layout.positions;

    // Determine which edges are connected to the selected node.
    final selectedIds = <String>{};
    if (selectedCharacterId != null) {
      selectedIds.add(selectedCharacterId!);
      for (final r in relationships) {
        if (r.fromCharacterId == selectedCharacterId) {
          selectedIds.add(r.toCharacterId);
        }
        if (r.toCharacterId == selectedCharacterId) {
          selectedIds.add(r.fromCharacterId);
        }
      }
    }

    // Draw edges.
    for (final relationship in relationships) {
      final from = positions[relationship.fromCharacterId];
      final to = positions[relationship.toCharacterId];
      if (from == null || to == null) continue;

      final isHighlighted =
          selectedCharacterId != null &&
          (relationship.fromCharacterId == selectedCharacterId ||
              relationship.toCharacterId == selectedCharacterId);

      final edgeColor = isHighlighted
          ? colorScheme.primary
          : colorScheme.primary.withValues(alpha: 0.35);
      final strokeWidth = isHighlighted ? 2.4 : 1.2;

      // Bézier curve with control point offset perpendicular to the edge.
      final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
      final delta = to - from;
      final dist = delta.distance;
      final normal = dist > 0
          ? Offset(-delta.dy / dist, delta.dx / dist)
          : Offset.zero;
      final curvature = dist * 0.15;
      final control = mid + normal * curvature;

      final path = Path()
        ..moveTo(from.dx, from.dy)
        ..quadraticBezierTo(control.dx, control.dy, to.dx, to.dy);

      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = edgeColor,
      );

      // Arrowhead at the target end.
      _drawArrowhead(
        canvas,
        control,
        to,
        edgeColor,
        layout.nodeRadius(relationship.toCharacterId),
      );
    }

    // Draw nodes.
    for (final character in characters) {
      final position = positions[character.id];
      if (position == null) continue;

      final radius = layout.nodeRadius(character.id);
      final isSelected = character.id == selectedCharacterId;
      final isConnected = selectedIds.contains(character.id);
      final dimmed = selectedCharacterId != null && !isConnected && !isSelected;

      final fillColor = isSelected
          ? colorScheme.primaryContainer
          : dimmed
          ? colorScheme.surface.withValues(alpha: 0.5)
          : colorScheme.surface;
      final borderColor = isSelected
          ? colorScheme.primary
          : dimmed
          ? colorScheme.outline.withValues(alpha: 0.3)
          : colorScheme.outline;
      final textColor = isSelected
          ? colorScheme.onPrimaryContainer
          : dimmed
          ? colorScheme.onSurface.withValues(alpha: 0.3)
          : colorScheme.onSurface;

      canvas.drawCircle(position, radius, Paint()..color = fillColor);
      canvas.drawCircle(
        position,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 2.4 : 1.4
          ..color = borderColor,
      );
      _drawText(canvas, character.name, position, textColor, radius);
    }
  }

  void _drawArrowhead(
    Canvas canvas,
    Offset from,
    Offset to,
    Color color,
    double nodeRadius,
  ) {
    final direction = to - from;
    final length = direction.distance;
    if (length < 1) return;
    final unit = direction / length;
    final tip = to - unit * (nodeRadius + 2);
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

  void _drawCenteredText(Canvas canvas, Size size, String text) {
    _drawText(
      canvas,
      text,
      Offset(size.width / 2, size.height / 2),
      colorScheme.onSurfaceVariant,
      30,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    Color color,
    double maxRadius,
  ) {
    final maxWidth = maxRadius * 1.6;
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _RelationshipPainter oldDelegate) {
    return oldDelegate.characters != characters ||
        oldDelegate.relationships != relationships ||
        oldDelegate.colorScheme != colorScheme ||
        oldDelegate.selectedCharacterId != selectedCharacterId;
  }
}
