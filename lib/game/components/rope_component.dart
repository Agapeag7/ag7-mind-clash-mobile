import 'package:flame/components.dart';
import 'package:flutter/material.dart';

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
    ropePosition = pos.clamp(-5.0, 5.0);
    _oscSpeed = 8.0 * (pos - ropePosition).sign;
    _oscSpeed = 8.0;
  }

  @override
  void update(double dt) {
    _osc *= 0.9;
    _oscSpeed += -_osc * 30 * dt;
    _osc += _oscSpeed * dt;
  }

  @override
  void render(Canvas canvas) {
    final knotX = (ropeStartX + ropeEndX) / 2 +
        ropePosition * pixelsPerUnit +
        _osc;

    final paint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(ropeStartX, ropeY), Offset(ropeEndX, ropeY), paint);
    canvas.drawLine(
      Offset(ropeStartX, ropeY),
      Offset(ropeEndX, ropeY),
      Paint()
        ..color = const Color(0xFF5D4037)
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke,
    );
    canvas.drawLine(
      Offset(ropeStartX + 8, ropeY - 1.5),
      Offset(ropeEndX - 8, ropeY - 1.5),
      Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..strokeWidth = 1.5,
    );

    canvas.drawCircle(
      Offset(knotX, ropeY),
      9,
      Paint()..color = const Color(0xFFFDD835),
    );
    canvas.drawCircle(
      Offset(knotX, ropeY),
      9,
      Paint()
        ..color = const Color(0xFFC49000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      Offset(knotX, ropeY),
      4,
      Paint()..color = const Color(0xFFFFF176),
    );
  }
}