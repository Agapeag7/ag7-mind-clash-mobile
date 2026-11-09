import 'dart:async';
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
    double charHeight = 130,
  }) : super(position: position) {
    for (var i = 0; i < spacing.length; i++) {
      final isLeader = (side == TeamSide.red && i == spacing.length - 1) ||
          (side == TeamSide.blue && i == 0);
      final c = CharacterComponent(
        position: Vector2(spacing[i], 0),
        side: side,
        teamColor: color,
        isLeader: isLeader,
        height: charHeight,
      );
      members.add(c);
      add(c);
    }
  }

  void playTeam(AnimationState state, {bool hold = false}) {
    for (var i = 0; i < members.length; i++) {
      final delay = i * 0.045;
      if (delay <= 0) {
        members[i].play(state, hold: hold);
      } else {
        Future.delayed(Duration(milliseconds: (delay * 1000).round()), () {
          members[i].play(state, hold: hold);
        });
      }
    }
  }

  void resetTeam() {
    for (final m in members) {
      m.play(AnimationState.idle);
    }
  }
}