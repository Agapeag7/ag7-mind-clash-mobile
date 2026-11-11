import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/enums.dart';
import 'character_component.dart';

class TeamComponent extends PositionComponent {
  final TeamSide side;
  final List<CharacterComponent> members = [];
  final Color color;

  TeamComponent({
    required Vector2 position,
    required this.side,
    required this.color,
    required List<double> spacing,
    double charHeight = 160,
  }) : super(position: position) {
    for (var i = 0; i < spacing.length; i++) {
      final isLeader = (side == TeamSide.red && i == spacing.length - 1) ||
          (side == TeamSide.blue && i == 0);
      final c = CharacterComponent(
        position: Vector2(spacing[i], 0),
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
    for (final m in members) {
      m.play(AnimationState.idle);
    }
  }
}