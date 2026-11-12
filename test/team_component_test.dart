import 'package:flame/components.dart';
import 'package:ag7_mind_clash/core/enums.dart';
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

        expect((leader.position.x - other.position.x).abs(), characterSpacing);
        expect(leader.position.y, characterHeight);
        expect(other.position.y, leader.position.y);
        expect(leader.priority, other.priority);
        expect(team.priority, greaterThan(50));
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
    }
  });
}
