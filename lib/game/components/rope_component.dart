import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'arena_scale.dart';

class RopeComponent extends PositionComponent {
  double ropePosition = 0.0;
  final double pixelsPerUnit;
  final double ropeY;
  final double ropeStartX;
  final double ropeEndX;

  double _osc = 0;
  double _oscSpeed = 0;

  RopeComponent({
    required this.ropeStartX,
    required this.ropeEndX,
    required this.ropeY,
    required this.pixelsPerUnit,
  }) : super(priority: 50);

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
        _osc * arenaVerticalScale;
    final scaledRopeY = ropeY * arenaVerticalScale;

    final paint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = 8 * arenaVerticalScale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(currentStartX, scaledRopeY),
      Offset(currentEndX, scaledRopeY),
      paint,
    );
    canvas.drawLine(
      Offset(currentStartX, scaledRopeY),
      Offset(currentEndX, scaledRopeY),
      Paint()
        ..color = const Color(0xFF5D4037)
        ..strokeWidth = 2 * arenaVerticalScale
        ..style = PaintingStyle.stroke,
    );
    canvas.drawLine(
      Offset(currentStartX + 8, scaledRopeY - 1.5 * arenaVerticalScale),
      Offset(currentEndX - 8, scaledRopeY - 1.5 * arenaVerticalScale),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 2.5 * arenaVerticalScale,
    );

    canvas.drawCircle(
      Offset(knotX, scaledRopeY),
      12 * arenaVerticalScale,
      Paint()..color = const Color(0xFFFDD835),
    );
    canvas.drawCircle(
      Offset(knotX, scaledRopeY),
      12 * arenaVerticalScale,
      Paint()
        ..color = const Color(0xFFC49000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * arenaVerticalScale,
    );
    canvas.drawCircle(
      Offset(knotX, scaledRopeY),
      5 * arenaVerticalScale,
      Paint()..color = const Color(0xFFFFF176),
    );
  }
}
