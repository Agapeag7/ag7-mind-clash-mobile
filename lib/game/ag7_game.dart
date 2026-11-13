import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/enums.dart';
import 'components/rope_component.dart';
import 'components/team_component.dart';
import 'components/terrain_component.dart';

class Ag7Game extends FlameGame {
  late TerrainComponent terrain;
  late TeamComponent redTeam;
  late TeamComponent blueTeam;
  late RopeComponent rope;

  double pixelsPerUnit = 0;

  bool _ready = false;
  TeamSide? _activeSide;

  @override
  Color backgroundColor() => AppColors.bgBottom;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.visibleGameSize = size;

    final characterHeight = math.min(size.x * 0.4, size.y * 0.6);
    final characterSpacing = characterHeight * 0.55;
    final teamWidth = characterHeight * 0.62 + characterSpacing;
    final teamCenterOffset = math.min(
      size.x * 0.23,
      size.x / 2 - teamWidth / 2 - size.x * 0.03,
    );
    final groundY = size.y * 0.78;
    final teamTop = groundY - characterHeight;

    terrain = TerrainComponent(
      size: size,
      groundY: groundY,
      centerX: size.x / 2,
      winLineOffset: size.x * 0.18,
    );
    add(terrain);

    redTeam = TeamComponent(
      position: Vector2(
        size.x / 2 - teamCenterOffset - teamWidth / 2,
        teamTop,
      ),
      side: TeamSide.red,
      color: AppColors.red,
      spacing: [0, characterSpacing],
      charHeight: characterHeight,
    );
    add(redTeam);

    blueTeam = TeamComponent(
      position: Vector2(
        size.x / 2 + teamCenterOffset - teamWidth / 2,
        teamTop,
      ),
      side: TeamSide.blue,
      color: AppColors.blue,
      spacing: [0, characterSpacing],
      charHeight: characterHeight,
    );
    add(blueTeam);

    rope = RopeComponent(
      ropeStartX: size.x * 0.02,
      ropeEndX: size.x * 0.98,
      ropeY: groundY - characterHeight * 0.52,
      pixelsPerUnit: size.x * 0.035,
    )..teams = [redTeam, blueTeam];
    add(rope);

    _ready = true;
    _layoutArena(size);
    setTugging(TeamSide.red);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    camera.viewfinder.visibleGameSize = size;
    if (_ready) _layoutArena(size);
  }

  void _layoutArena(Vector2 arenaSize) {
    final width = arenaSize.x;
    final height = arenaSize.y;
    final centerX = width / 2;
    final groundY = height * 0.78;
    final characterHeight = math.min(width * 0.4, height * 0.6);
    final characterSpacing = characterHeight * 0.55;
    final teamWidth = characterHeight * 0.62 + characterSpacing;
    final teamCenterOffset = math.min(
      width * 0.23,
      centerX - teamWidth / 2 - width * 0.03,
    );
    final teamTop = groundY - characterHeight;

    terrain.layout(
      size: arenaSize,
      groundY: groundY,
      centerX: centerX,
      winLineOffset: width * 0.18,
    );
    redTeam.layout(
      position: Vector2(
        centerX - teamCenterOffset - teamWidth / 2,
        teamTop,
      ),
      spacing: characterSpacing,
      charHeight: characterHeight,
    );
    blueTeam.layout(
      position: Vector2(
        centerX + teamCenterOffset - teamWidth / 2,
        teamTop,
      ),
      spacing: characterSpacing,
      charHeight: characterHeight,
    );
    pixelsPerUnit = width * 0.035;
    rope.layout(
      ropeStartX: width * 0.02,
      ropeEndX: width * 0.98,
      ropeY: groundY - characterHeight * 0.52,
      pixelsPerUnit: pixelsPerUnit,
    );
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
    final delta = position - rope.ropePosition;
    rope.setPosition(position);
    if (delta != 0) {
      final teamMovement = delta * pixelsPerUnit * 0.75;
      redTeam.moveWithRope(teamMovement);
      blueTeam.moveWithRope(teamMovement);
    }
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
