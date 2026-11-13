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

  double _displayPosition = 0;
  double _velocity = 0;
  double _osc = 0;
  double _oscVelocity = 0;

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
    _oscVelocity += delta.sign * delta.abs().clamp(0.0, 1.0).toDouble() * 5;
  }

  void snapToPosition(double pos) {
    ropePosition = pos.clamp(-5.0, 5.0).toDouble();
    _displayPosition = ropePosition;
    _velocity = 0;
    _osc = 0;
    _oscVelocity = 0;
  }

  double get displayedPosition => _displayPosition;

  void advance(double dt) {
    final error = ropePosition - _displayPosition;
    _velocity += (error * 100 - _velocity * 20) * dt;
    _displayPosition += _velocity * dt;
    if (error.abs() < 0.001 && _velocity.abs() < 0.01) {
      _displayPosition = ropePosition;
      _velocity = 0;
    }

    _oscVelocity += (-_osc * 90 - _oscVelocity * 18) * dt;
    _osc += _oscVelocity * dt;
  }

  @override
  void update(double dt) {
    advance(dt);
  }

  @override
  void render(Canvas canvas) {
    final movement = _displayPosition * pixelsPerUnit * 0.75;
    final currentStartX = ropeStartX + (movement > 0 ? movement : 0.0);
    final currentEndX = ropeEndX + (movement < 0 ? movement : 0.0);
    final knotX =
        (ropeStartX + ropeEndX) / 2 + _displayPosition * pixelsPerUnit + _osc;
    final knotY = ropeY + _osc;

    final ropePoints = <Offset>[
      Offset(currentStartX, ropeY),
      Offset(currentEndX, ropeY),
      Offset(knotX, knotY),
    ];
    for (final team in teams) {
      for (final member in team.members) {
        final topLeft = Offset(
          team.position.x + member.position.x - member.size.x / 2,
          team.position.y + member.position.y - member.size.y,
        );
        ropePoints.add(member.ropeGripPosition(topLeft));
      }
    }
    ropePoints.sort((a, b) => a.dx.compareTo(b.dx));
    final ropePath = Path()..moveTo(ropePoints.first.dx, ropePoints.first.dy);
    for (final point in ropePoints.skip(1)) {
      ropePath.lineTo(point.dx, point.dy);
    }

    final paint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(ropePath, paint);
    canvas.drawPath(
      ropePath,
      Paint()
        ..color = const Color(0xFF5D4037)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      ropePath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    canvas.drawCircle(
      Offset(knotX, knotY),
      8,
      Paint()..color = const Color(0xFFFDD835),
    );
    canvas.drawCircle(
      Offset(knotX, knotY),
      8,
      Paint()
        ..color = const Color(0xFFC49000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      Offset(knotX, knotY),
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
