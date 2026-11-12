import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/enums.dart';
import 'character_component.dart';

class TeamComponent extends PositionComponent {
  static const double _spacingScale = 1;
  static const double _maxPullBackScale = 0.22;

  final TeamSide side;
  final List<CharacterComponent> members = [];
  final Color color;
  late double _homeX = position.x;
  late double _targetX = position.x;
  double _pullBackOffset = 0;

  TeamComponent({
    required Vector2 position,
    required this.side,
    required this.color,
    required List<double> spacing,
    double charHeight = 160,
  }) : super(
         position: position,
         size: Vector2(spacing.last + charHeight * 0.62, charHeight),
         priority: 60,
       ) {
    for (var i = 0; i < spacing.length; i++) {
      final isLeader =
          (side == TeamSide.red && i == spacing.length - 1) ||
          (side == TeamSide.blue && i == 0);
      final c = CharacterComponent(
        position: Vector2.zero(),
        side: side,
        teamColor: color,
        isLeader: isLeader,
        phaseOffset: i * 0.09,
        height: charHeight,
      );
      members.add(c);
      add(c);
    }
    _setMemberDepthOrder();
    _layoutMembers(spacing, charHeight);
  }

  void layout({
    required Vector2 position,
    required double spacing,
    required double charHeight,
  }) {
    this.position.setFrom(position);
    _homeX = position.x;
    _targetX = position.x;
    _pullBackOffset = 0;
    size.setValues(spacing + charHeight * 0.62, charHeight);
    _layoutMembers(
      List<double>.generate(members.length, (index) => index * spacing),
      charHeight,
    );
    _setMemberDepthOrder();
  }

  void _layoutMembers(List<double> spacing, double characterHeight) {
    final characterWidth = characterHeight * 0.62;
    final scaledSpacingEnd = spacing.last * _spacingScale;
    final horizontalOffset =
        (size.x - characterWidth - scaledSpacingEnd) / 2;
    for (var i = 0; i < members.length; i++) {
      members[i]
        ..position.setValues(
          horizontalOffset +
              characterWidth / 2 +
              spacing[i] * _spacingScale,
          characterHeight,
        )
        ..size.setValues(characterWidth, characterHeight);
    }
  }

  void _setMemberDepthOrder() {
    for (final member in members) {
      member.priority = 0;
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

  void pullBack(double distance) {
    final direction = side == TeamSide.red ? -1.0 : 1.0;
    final maxPullBack = size.y * _maxPullBackScale;
    _pullBackOffset = (_pullBackOffset + distance * direction)
        .clamp(-maxPullBack, maxPullBack)
        .toDouble();
    _targetX = _homeX + _pullBackOffset;
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
    _pullBackOffset = 0;
    _targetX = _homeX;
    position.x = _homeX;
    for (final m in members) {
      m.play(AnimationState.idle);
    }
  }
}
