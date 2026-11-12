import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import 'arena_scale.dart';

class TerrainComponent extends PositionComponent {
  final double groundY;
  final double centerX;
  final double winLineOffset;

  TerrainComponent({
    required Vector2 size,
    required this.groundY,
    required this.centerX,
    required this.winLineOffset,
  }) : super(size: size, priority: -10);

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.scale(1, arenaVerticalScale);

    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.bgTop, AppColors.bgBottom],
      ).createShader(Rect.fromLTWH(0, 0, size.x, groundY));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, groundY), sky);

    _cloud(canvas, Offset(size.x * 0.2, groundY * 0.25), 24);
    _cloud(canvas, Offset(size.x * 0.75, groundY * 0.18), 28);
    _cloud(canvas, Offset(size.x * 0.5, groundY * 0.35), 20);

    final ground = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.groundTop, AppColors.groundBottom],
      ).createShader(Rect.fromLTWH(0, groundY, size.x, size.y - groundY));
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.x, size.y - groundY),
      ground,
    );

    canvas.drawLine(
      Offset(0, groundY),
      Offset(size.x, groundY),
      Paint()
        ..color = const Color(0xFF33691E)
        ..strokeWidth = 3,
    );

    _dashedLine(
      canvas,
      Offset(centerX, groundY - 4),
      Offset(centerX, groundY - 40),
      Colors.white,
    );
    _winMarker(canvas, centerX - winLineOffset, AppColors.red);
    _winMarker(canvas, centerX + winLineOffset, AppColors.blue);

    canvas.restore();
  }

  void _cloud(Canvas canvas, Offset c, double w) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawCircle(c, w * 0.5, p);
    canvas.drawCircle(Offset(c.dx - w * 0.5, c.dy + 4), w * 0.35, p);
    canvas.drawCircle(Offset(c.dx + w * 0.5, c.dy + 4), w * 0.4, p);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(c.dx - w * 0.6, c.dy, w * 1.2, w * 0.4),
        const Radius.circular(10),
      ),
      p,
    );
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3;
    const dash = 8.0, gap = 6.0;
    final dir = b - a;
    final len = dir.distance;
    if (len == 0) return;
    final n = Offset(dir.dx / len, dir.dy / len);
    var t = 0.0;
    while (t < len) {
      final end = (t + dash).clamp(0, len);
      final startOffset = a + Offset(n.dx * t, n.dy * t);
      final endOffset = a + Offset(n.dx * end, n.dy * end);
      canvas.drawLine(startOffset, endOffset, paint);
      t += dash + gap;
    }
  }

  void _winMarker(Canvas canvas, double x, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x, groundY - 4), Offset(x, groundY - 42), paint);
    canvas.drawCircle(Offset(x, groundY - 47), 5, Paint()..color = color);
  }
}
