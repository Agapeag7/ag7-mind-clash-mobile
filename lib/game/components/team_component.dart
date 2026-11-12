import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/enums.dart';
import 'arena_scale.dart';
import 'character_component.dart';

class TeamComponent extends PositionComponent {
  static const double _spacingScale = 0.7;

  final TeamSide side;
  final List<CharacterComponent> members = [];
  final Color color;
  late final double _homeX = position.x;
  late double _targetX = position.x;

  TeamComponent({
    required Vector2 position,
    required this.side,
    required this.color,
    required List<double> spacing,
    double charHeight = 160,
  }) : super(
         position: Vector2(position.x, position.y * arenaVerticalScale),
         size: Vector2(
           spacing.last + charHeight * 0.62,
           charHeight * arenaVerticalScale,
         ),
       ) {
    final characterHeight = charHeight * arenaVerticalScale;
    final characterWidth = characterHeight * 0.62;
    final scaledSpacingEnd = spacing.last * _spacingScale;
    final horizontalOffset =
        (spacing.last + charHeight * 0.62 - characterWidth - scaledSpacingEnd) /
        2;
    for (var i = 0; i < spacing.length; i++) {
      final isLeader =
          (side == TeamSide.red && i == spacing.length - 1) ||
          (side == TeamSide.blue && i == 0);
      final c = CharacterComponent(
        position: Vector2(
          horizontalOffset + characterWidth / 2 + spacing[i] * _spacingScale,
          characterHeight,
        ),
        side: side,
        teamColor: color,
        isLeader: isLeader,
        phaseOffset: i * 0.09,
        height: characterHeight,
      );
      members.add(c);
      add(c);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    final delta = _targetX - position.x;
    if (delta.abs() < 0.1) {
      position.x = _targetX;
    } else {
      position.x += delta * (dt * 8).clamp(0.0, 1.0).toDouble();
    }
  }

  void setRopePosition(double ropePosition, double pixelsPerUnit) {
    final movement = ropePosition * pixelsPerUnit * 0.75;
    final teamMovement = side == TeamSide.red
        ? (movement > 0 ? movement : 0.0)
        : (movement < 0 ? movement : 0.0);
    _targetX = _homeX + teamMovement;
  }

  void playTeam(
    AnimationState state, {
    bool hold = false,
    AnimationState? returnTo,
  }) {
    for (final member in members) {
      member.play(state, hold: hold, returnTo: returnTo);
    }
  }

  void resetTeam() {
    _targetX = _homeX;
    position.x = _homeX;
    for (final m in members) {
      m.play(AnimationState.idle);
    }
  }
}
