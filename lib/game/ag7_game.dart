import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../core/enums.dart';
import 'components/rope_component.dart';
import 'components/team_component.dart';
import 'components/terrain_component.dart';

class Ag7Game extends FlameGame {
  static final Vector2 virtualSize = Vector2(900, 540);

  late TerrainComponent terrain;
  late TeamComponent redTeam;
  late TeamComponent blueTeam;
  late RopeComponent rope;

  final double groundY = 430;
  final double centerX = 450;
  final double winLineOffset = 120;
  double pixelsPerUnit = 0;

  bool _ready = false;

  @override
  Color backgroundColor() => const Color(0xFFB3E5FC);

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
      position: Vector2(centerX - 340, groundY),
      side: TeamSide.red,
      color: const Color(0xFFE53935),
      spacing: const [0, 80, 160],
    );
    add(redTeam);

    // Bleu : leader le plus à gauche (donc à centerX + 20).
    blueTeam = TeamComponent(
      position: Vector2(centerX + 20, groundY),
      side: TeamSide.blue,
      color: const Color(0xFF1E88E5),
      spacing: const [0, 80, 160],
    );
    add(blueTeam);

    rope = RopeComponent(
      ropeStartX: centerX - 160,
      ropeEndX: centerX + 160,
      ropeY: groundY - 78,
      pixelsPerUnit: pixelsPerUnit,
    );
    add(rope);

    _ready = true;
  }

  void setRopePosition(
    double pos, {
    AnimationState? redReaction,
    AnimationState? blueReaction,
  }) {
    if (!_ready) return;
    rope.setPosition(pos);
    if (redReaction != null) redTeam.playTeam(redReaction);
    if (blueReaction != null) blueTeam.playTeam(blueReaction);
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
    (side == TeamSide.red ? redTeam : blueTeam)
        .playTeam(AnimationState.powerUp);
  }

  void resetRound() {
    rope.setPosition(0);
    redTeam.resetTeam();
    blueTeam.resetTeam();
  }
}