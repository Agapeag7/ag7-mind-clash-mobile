import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/enums.dart';
import 'components/rope_component.dart';
import 'components/team_component.dart';
import 'components/terrain_component.dart';

class Ag7Game extends FlameGame {
  static final Vector2 virtualSize = Vector2(720, 230);

  late TerrainComponent terrain;
  late TeamComponent redTeam;
  late TeamComponent blueTeam;
  late RopeComponent rope;

  final double groundY = 175;
  final double centerX = 360;
  final double winLineOffset = 85;
  final double characterHeight = 82;
  final double characterSpacing = 56;
  double pixelsPerUnit = 0;

  bool _ready = false;
  TeamSide? _activeSide;

  @override
  Color backgroundColor() => AppColors.bgBottom;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.visibleGameSize = virtualSize;
    pixelsPerUnit = winLineOffset / 5;

    terrain = TerrainComponent(
      size: virtualSize,
      groundY: groundY,
      centerX: centerX,
      winLineOffset: winLineOffset,
    );
    add(terrain);

    final teamWidth = characterHeight * 0.62 + characterSpacing * 2;
    final teamTop = groundY - characterHeight;
    const teamCenterOffset = 105.0;

    // Rouge : 3 personnages à gauche. Le leader est le plus à droite.
    redTeam = TeamComponent(
      position: Vector2(centerX - teamWidth / 2 - teamCenterOffset, teamTop),
      side: TeamSide.red,
      color: AppColors.red,
      spacing: [0, characterSpacing, characterSpacing * 2],
      charHeight: characterHeight,
    );
    add(redTeam);

    // Bleu : leader le plus à gauche.
    blueTeam = TeamComponent(
      position: Vector2(centerX - teamWidth / 2 + teamCenterOffset, teamTop),
      side: TeamSide.blue,
      color: AppColors.blue,
      spacing: [0, characterSpacing, characterSpacing * 2],
      charHeight: characterHeight,
    );
    add(blueTeam);

    rope = RopeComponent(
      ropeStartX: centerX - 120,
      ropeEndX: centerX + 120,
      ropeY: groundY - 43,
      pixelsPerUnit: pixelsPerUnit,
    );
    add(rope);

    _ready = true;
    setTugging(TeamSide.red);
  }

  void setTugging(TeamSide activeSide) {
    if (!_ready || _activeSide == activeSide) return;
    _activeSide = activeSide;
    final activeTeam = activeSide == TeamSide.red ? redTeam : blueTeam;
    final resistingTeam = activeSide == TeamSide.red ? blueTeam : redTeam;
    activeTeam.playTeam(AnimationState.pull);
    resistingTeam.playTeam(AnimationState.struggle);
  }

  void setRopePosition(
    double pos, {
    AnimationState? redReaction,
    AnimationState? blueReaction,
  }) {
    if (!_ready) return;
    final position = pos.clamp(-5.0, 5.0).toDouble();
    rope.setPosition(position);
    redTeam.setRopePosition(position, pixelsPerUnit);
    blueTeam.setRopePosition(position, pixelsPerUnit);
    final pullingSide = _activeSide ?? TeamSide.red;
    final pullingAnimation = pullingSide == TeamSide.red
        ? AnimationState.pull
        : AnimationState.struggle;
    final resistingAnimation = pullingSide == TeamSide.red
        ? AnimationState.struggle
        : AnimationState.pull;
    if (redReaction != null) {
      redTeam.playTeam(
        redReaction,
        returnTo: pullingSide == TeamSide.red
            ? pullingAnimation
            : resistingAnimation,
      );
    }
    if (blueReaction != null) {
      blueTeam.playTeam(
        blueReaction,
        returnTo: pullingSide == TeamSide.blue
            ? pullingAnimation
            : resistingAnimation,
      );
    }
  }

  void triggerVictory(TeamSide winner) {
    if (winner == TeamSide.red) {
      redTeam.playTeam(AnimationState.victory, hold: true);
      blueTeam.playTeam(AnimationState.defeat, hold: true);
    } else {
      blueTeam.playTeam(AnimationState.victory, hold: true);
      redTeam.playTeam(AnimationState.defeat, hold: true);
    }
  }

  void triggerPowerUp(TeamSide side) {
    (side == TeamSide.red ? redTeam : blueTeam).playTeam(
      AnimationState.powerUp,
    );
  }

  void resetRound() {
    rope.setPosition(0);
    redTeam.resetTeam();
    blueTeam.resetTeam();
    _activeSide = null;
    setTugging(TeamSide.red);
  }
}
