import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/enums.dart';
import 'character_component.dart';

class TeamComponent extends PositionComponent {
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
         position: position,
         size: Vector2(spacing.last + charHeight * 0.62, charHeight),
       ) {
    final characterWidth = charHeight * 0.62;
    for (var i = 0; i < spacing.length; i++) {
      final isLeader =
          (side == TeamSide.red && i == spacing.length - 1) ||
          (side == TeamSide.blue && i == 0);
      final c = CharacterComponent(
        position: Vector2(characterWidth / 2 + spacing[i], charHeight),
        side: side,
        teamColor: color,
        isLeader: isLeader,
        phaseOffset: i * 0.09,
        height: charHeight,
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
