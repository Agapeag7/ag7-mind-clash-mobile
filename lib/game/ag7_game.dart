import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/enums.dart';
import 'components/rope_component.dart';
import 'components/team_component.dart';
import 'components/terrain_component.dart';

class Ag7Game extends FlameGame {
  static final Vector2 virtualSize = Vector2(720, 405);

  late TerrainComponent terrain;
  late TeamComponent redTeam;
  late TeamComponent blueTeam;
  late RopeComponent rope;

  final double groundY = 325;
  final double centerX = 360;
  final double winLineOffset = 85;
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

    // Rouge : 3 personnages à gauche. Le leader est le plus à droite.
    redTeam = TeamComponent(
      position: Vector2(centerX - 295, groundY),
      side: TeamSide.red,
      color: AppColors.red,
      spacing: const [0, 100, 200],
      charHeight: 180,
    );
    add(redTeam);

    // Bleu : leader le plus à gauche (donc à centerX + 20).
    blueTeam = TeamComponent(
      position: Vector2(centerX - 5, groundY),
      side: TeamSide.blue,
      color: AppColors.blue,
      spacing: const [0, 100, 200],
      charHeight: 180,
    );
    add(blueTeam);

    rope = RopeComponent(
      ropeStartX: centerX - 120,
      ropeEndX: centerX + 120,
      ropeY: groundY - 90,
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
