import 'package:flame/components.dart';
import 'package:ag7_mind_clash/core/enums.dart';
import 'package:ag7_mind_clash/game/components/rope_component.dart';
import 'package:ag7_mind_clash/game/components/team_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TeamComponent', () {
    for (final side in TeamSide.values) {
      test('$side spaces both members on the same foreground plane', () {
        const characterHeight = 100.0;
        const characterSpacing = 55.0;
        final team = TeamComponent(
          position: Vector2.zero(),
          side: side,
          color: Colors.red,
          spacing: const [0, characterSpacing],
          charHeight: characterHeight,
        );
        final leader = team.members.singleWhere((member) => member.isLeader);
        final other = team.members.singleWhere((member) => !member.isLeader);
        final rope = RopeComponent(
          ropeStartX: 0,
          ropeEndX: 100,
          ropeY: 50,
          pixelsPerUnit: 1,
        );

        expect((leader.position.x - other.position.x).abs(), characterSpacing);
        expect(leader.position.y, characterHeight);
        expect(other.position.y, leader.position.y);
        expect(leader.priority, other.priority);
        expect(rope.priority, greaterThan(team.priority));
      });

      test('$side moves with the rope and returns to its starting point', () {
        final team = TeamComponent(
          position: Vector2(100, 0),
          side: side,
          color: Colors.red,
          spacing: const [0, 55],
          charHeight: 100,
        );
        final startX = team.position.x;

        team.moveWithRope(-20);
        expect(team.position.x, startX - 20);

        team.resetTeam();
        expect(team.position.x, startX);
      });

      test('$side follows the rope beyond the visible arena', () {
        final team = TeamComponent(
          position: Vector2(100, 0),
          side: side,
          color: Colors.red,
          spacing: const [0, 55],
          charHeight: 100,
        );

        team.moveWithRope(-200);

        expect(team.position.x, -100);
      });

      test('$side moves visibly in either rope direction', () {
        final team = TeamComponent(
          position: Vector2(100, 0),
          side: side,
          color: Colors.red,
          spacing: const [0, 55],
          charHeight: 100,
        );

        team.moveWithRope(20);
        expect(team.position.x, 120);

        team.moveWithRope(-30);
        expect(team.position.x, 90);
      });
    }

    test('each tug alternates retreat and advance without closing the gap', () {
      final redTeam = TeamComponent(
        position: Vector2(100, 0),
        side: TeamSide.red,
        color: Colors.red,
        spacing: const [0, 55],
        charHeight: 100,
      );
      final blueTeam = TeamComponent(
        position: Vector2(300, 0),
        side: TeamSide.blue,
        color: Colors.blue,
        spacing: const [0, 55],
        charHeight: 100,
      );
      final redStartX = redTeam.position.x;
      final blueStartX = blueTeam.position.x;
      final startingGap = blueStartX - (redStartX + redTeam.size.x);

      const redWinningMovement = -25.0;
      redTeam.moveWithRope(redWinningMovement);
      blueTeam.moveWithRope(redWinningMovement);

      expect(redTeam.position.x, lessThan(redStartX));
      expect(blueTeam.position.x, lessThan(blueStartX));
      expect(redStartX - redTeam.position.x, redWinningMovement.abs());
      expect(
        blueTeam.position.x - (redTeam.position.x + redTeam.size.x),
        closeTo(startingGap, 0.001),
      );

      const blueWinningMovement = 25.0;
      redTeam.moveWithRope(blueWinningMovement);
      blueTeam.moveWithRope(blueWinningMovement);

      expect(redTeam.position.x, greaterThan(redStartX - 25));
      expect(blueTeam.position.x, greaterThan(blueStartX - 25));
      expect(redTeam.position.x, closeTo(redStartX, 0.001));
      expect(blueTeam.position.x, closeTo(blueStartX, 0.001));
      expect(
        blueTeam.position.x - (redTeam.position.x + redTeam.size.x),
        closeTo(startingGap, 0.001),
      );
    });

    test('a character grip moves with the team position', () {
      final team = TeamComponent(
        position: Vector2(100, 0),
        side: TeamSide.red,
        color: Colors.red,
        spacing: const [0, 55],
        charHeight: 100,
      );
      final member = team.members.first;
      final topLeft = Offset(
        team.position.x + member.position.x - member.size.x / 2,
        team.position.y + member.position.y - member.size.y,
      );
      final gripBefore = member.ropeGripPosition(topLeft);

      team.moveWithRope(-30);
      final movedTopLeft = Offset(topLeft.dx - 30, topLeft.dy);
      final gripAfter = member.ropeGripPosition(movedTopLeft);

      expect(gripAfter.dx, closeTo(gripBefore.dx - 30, 0.001));
      expect(gripAfter.dy, closeTo(gripBefore.dy, 0.001));
    });

    test('team position stays attached to the rope after a layout change', () {
      final team = TeamComponent(
        position: Vector2(100, 0),
        side: TeamSide.red,
        color: Colors.red,
        spacing: const [0, 55],
        charHeight: 100,
      );

      team.moveWithRope(-20);
      team.layout(position: Vector2(200, 0), spacing: 66, charHeight: 120);

      expect(team.position.x, closeTo(176, 0.001));
    });

    test('rope eases toward its new position instead of teleporting', () {
      final rope = RopeComponent(
        ropeStartX: 0,
        ropeEndX: 400,
        ropeY: 100,
        pixelsPerUnit: 10,
      );

      rope.setPosition(-1);
      rope.advance(0.05);

      expect(rope.displayedPosition, lessThan(0));
      expect(rope.displayedPosition, greaterThan(-1));
    });
  });
}
