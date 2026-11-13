import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'team_component.dart';

class RopeComponent extends PositionComponent {
  double ropePosition = 0.0;
  double pixelsPerUnit;
  double ropeY;
  double ropeStartX;
  double ropeEndX;
  List<TeamComponent> teams = [];

  double _osc = 0;
  double _oscSpeed = 0;

  RopeComponent({
    required this.ropeStartX,
    required this.ropeEndX,
    required this.ropeY,
    required this.pixelsPerUnit,
  }) : super(priority: 70);

  void layout({
    required double ropeStartX,
    required double ropeEndX,
    required double ropeY,
    required double pixelsPerUnit,
  }) {
    this.ropeStartX = ropeStartX;
    this.ropeEndX = ropeEndX;
    this.ropeY = ropeY;
    this.pixelsPerUnit = pixelsPerUnit;
  }

  void setPosition(double pos) {
    final targetPosition = pos.clamp(-5.0, 5.0).toDouble();
    final delta = targetPosition - ropePosition;
    ropePosition = targetPosition;
    _oscSpeed = 8.0 * delta.sign;
  }

  @override
  void update(double dt) {
    _osc *= 0.9;
    _oscSpeed += -_osc * 30 * dt;
    _osc += _oscSpeed * dt;
  }

  @override
  void render(Canvas canvas) {
    final movement = ropePosition * pixelsPerUnit * 0.75;
    final currentStartX = ropeStartX + (movement > 0 ? movement : 0.0);
    final currentEndX = ropeEndX + (movement < 0 ? movement : 0.0);
    final knotX =
        (ropeStartX + ropeEndX) / 2 +
        ropePosition * pixelsPerUnit +
        _osc;

    final paint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(currentStartX, ropeY),
      Offset(currentEndX, ropeY),
      paint,
    );
    canvas.drawLine(
      Offset(currentStartX, ropeY),
      Offset(currentEndX, ropeY),
      Paint()
        ..color = const Color(0xFF5D4037)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    canvas.drawLine(
      Offset(currentStartX + 8, ropeY - 1.5),
      Offset(currentEndX - 8, ropeY - 1.5),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 2.5,
    );

    canvas.drawCircle(
      Offset(knotX, ropeY),
      8,
      Paint()..color = const Color(0xFFFDD835),
    );
    canvas.drawCircle(
      Offset(knotX, ropeY),
      8,
      Paint()
        ..color = const Color(0xFFC49000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      Offset(knotX, ropeY),
      3,
      Paint()..color = const Color(0xFFFFF176),
    );

    for (final team in teams) {
      for (final member in team.members) {
        member.renderRopeArm(
          canvas,
          Offset(
            team.position.x + member.position.x - member.size.x / 2,
            team.position.y + member.position.y - member.size.y,
          ),
        );
      }
    }
  }
}
