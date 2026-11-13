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

      test('$side moves back smoothly when pulling', () {
        final team = TeamComponent(
          position: Vector2(100, 0),
          side: side,
          color: Colors.red,
          spacing: const [0, 55],
          charHeight: 100,
        );
        final startX = team.position.x;

        team.pullBack(20);
        team.update(0.1);

        if (side == TeamSide.red) {
          expect(team.position.x, lessThan(startX));
        } else {
          expect(team.position.x, greaterThan(startX));
        }

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
        team.update(1);

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
        team.update(1);
        expect(team.position.x, 120);

        team.moveWithRope(-30);
        team.update(1);
        expect(team.position.x, 90);
      });
    }

    test('the opposing team is dragged farther toward the pulling team', () {
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

      redTeam.moveWithRope(-25);
      blueTeam.moveWithRope(-50);
      redTeam.update(1);
      blueTeam.update(1);

      expect(redTeam.position.x, lessThan(redStartX));
      expect(blueTeam.position.x, lessThan(blueStartX));
      expect(
        blueStartX - blueTeam.position.x,
        greaterThan(redStartX - redTeam.position.x),
      );
      expect(
        blueTeam.position.x - (redTeam.position.x + redTeam.size.x),
        lessThan(blueStartX - (redStartX + redTeam.size.x)),
      );
    });
  });
}
