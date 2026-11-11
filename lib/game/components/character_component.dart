import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/enums.dart';
import 'character_animations.dart';
import 'character_enums.dart';
import 'character_pose.dart';

class CharacterComponent extends PositionComponent {
  final TeamSide side;
  final Color teamColor;
  final Color teamColorDark;
  final Color skinColor;
  final bool isLeader;
  final double phaseOffset;

  AnimationState _state = AnimationState.idle;
  double _stateTime = 0;
  bool _forcedHold = false;
  AnimationState? _returnState;

  CharacterComponent({
    required Vector2 position,
    required this.side,
    required this.teamColor,
    Color? teamColorDark,
    this.skinColor = const Color(0xFFFFCC9E),
    this.isLeader = false,
    this.phaseOffset = 0,
    double height = 160,
  })  : teamColorDark = teamColorDark ?? _darker(teamColor),
        super(
          position: position,
          size: Vector2(height * 0.62, height),
          anchor: Anchor.bottomCenter,
        );

  void play(
    AnimationState state, {
    bool hold = false,
    AnimationState? returnTo,
  }) {
    if (_state == state && !_forcedHold) {
      _returnState = returnTo;
      return;
    }
    _state = state;
    _stateTime = phaseOffset;
    _forcedHold = hold;
    _returnState = returnTo;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _stateTime += dt;
    if (_stateTime < 0) return;
    final def = CharacterAnimations.forState(_state);
    if (!def.loop && _stateTime > def.duration + 0.05 && !_forcedHold) {
      final nextState = _returnState ?? AnimationState.idle;
      _returnState = null;
      play(nextState);
    }
  }

  @override
  void render(Canvas canvas) {
    final def = CharacterAnimations.forState(_state);
    final t = def.loop
        ? (_stateTime % def.duration).toDouble()
        : _stateTime.clamp(0.0, def.duration).toDouble();
    final pose = def.poseAt(t);

    canvas.save();
    if (side == TeamSide.blue) {
      canvas.translate(size.x.toDouble(), 0);
      canvas.scale(-1, 1);
    }
    _drawCharacter(canvas, pose);
    canvas.restore();
  }

  void _drawCharacter(Canvas canvas, CharacterPose pose) {
    final cx = size.x / 2;
    final feetY = size.y - 3;

    final shadowWidth = 30.0 + pose.verticalOffset * 0.15;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + pose.horizontalOffset, feetY + 2),
        width: shadowWidth,
        height: 8,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.22),
    );

    canvas.save();
    canvas.translate(pose.horizontalOffset, pose.verticalOffset);

    if (pose.squash != 1.0) {
      canvas.translate(cx, feetY);
      canvas.scale(1.0, pose.squash);
      canvas.translate(-cx, -feetY);
    }

    final hipY = feetY - 40;
    final shoulderY = hipY - 42;
    final headCenterY = shoulderY - 22;

    _drawLeg(canvas, Offset(cx - 3, hipY), pose.legL, 40, back: true);
    _drawLeg(canvas, Offset(cx + 3, hipY), pose.legR, 40, back: false);

    canvas.save();
    canvas.translate(cx, hipY);
    canvas.rotate(pose.bodyLean);
    canvas.translate(-cx, -hipY);

    if (pose.glow > 0.01) {
      canvas.drawCircle(
        Offset(cx, (shoulderY + hipY) / 2),
        42,
        Paint()
          ..color = Colors.amber.withValues(alpha: pose.glow * 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }

    _drawTorso(canvas, cx, shoulderY, hipY);
    _drawArm(canvas, cx - 6, shoulderY + 3, pose.armL, back: true);
    _drawArm(canvas, cx + 6, shoulderY + 3, pose.armR, back: false);

    canvas.save();
    canvas.translate(cx, shoulderY);
    canvas.rotate(pose.headTilt);
    canvas.translate(-cx, -shoulderY);
    _drawHead(canvas, Offset(cx, headCenterY), pose);
    canvas.restore();

    canvas.restore();
    canvas.restore();
  }

  void _drawLeg(Canvas canvas, Offset hip, double angle, double length,
      {required bool back}) {
    final foot = Offset(
      hip.dx + math.sin(angle) * length,
      hip.dy + math.cos(angle) * length,
    );
    final knee = Offset(
      hip.dx + math.sin(angle * 0.75) * length * 0.55,
      hip.dy + math.cos(angle * 0.75) * length * 0.55,
    );
    final color = back ? _darker(skinColor, 0.15) : skinColor;
    final outline = Paint()
      ..color = teamColorDark
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(hip, knee, outline);
    canvas.drawLine(
      hip,
      knee,
      Paint()
        ..color = teamColor
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      knee,
      foot,
      Paint()
        ..color = color
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: foot.translate(side == TeamSide.red ? 4 : -4, 1),
        width: 18,
        height: 10,
      ),
      Paint()..color = teamColorDark,
    );
  }

  void _drawTorso(Canvas canvas, double cx, double shoulderY, double hipY) {
    final rect = Rect.fromLTRB(cx - 13, shoulderY - 2, cx + 13, hipY + 4);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(9));
    canvas.drawRRect(rrect, Paint()..color = teamColor);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = teamColorDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    if (isLeader) {
      canvas.drawCircle(
        Offset(cx, hipY - 12),
        4,
        Paint()..color = Colors.amber,
      );
    }
  }

  void _drawArm(
    Canvas canvas,
    double shoulderX,
    double shoulderY,
    double angle, {
    required bool back,
  }) {
    const upperLength = 17.0;
    const forearmLength = 15.0;
    final shoulder = Offset(shoulderX, shoulderY);
    final elbow = Offset(
      shoulderX + math.sin(angle) * upperLength,
      shoulderY + math.cos(angle) * upperLength,
    );
    final forearmAngle = angle + (back ? -0.48 : 0.48);
    final hand = Offset(
      elbow.dx + math.sin(forearmAngle) * forearmLength,
      elbow.dy + math.cos(forearmAngle) * forearmLength,
    );
    final color = back ? _darker(skinColor, 0.15) : skinColor;
    final outline = Paint()
      ..color = teamColorDark
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    final upper = Paint()
      ..color = color
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round;
    final forearm = Paint()
      ..color = color
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(shoulder, elbow, outline);
    canvas.drawLine(elbow, hand, outline);
    canvas.drawLine(shoulder, elbow, upper);
    canvas.drawLine(elbow, hand, forearm);
    canvas.drawCircle(elbow, 3.8, Paint()..color = color);
    canvas.drawCircle(hand, 5, Paint()..color = color);
    canvas.drawCircle(
      hand,
      5,
      Paint()
        ..color = _darker(color, 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _drawHead(Canvas canvas, Offset c, CharacterPose pose) {
    const r = 15.0;

    canvas.drawCircle(c, r, Paint()..color = skinColor);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = _darker(skinColor, 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    final hair = Path()
      ..moveTo(c.dx - 14, c.dy - 4)
      ..quadraticBezierTo(c.dx - 12, c.dy - 18, c.dx - 3, c.dy - 15)
      ..quadraticBezierTo(c.dx, c.dy - 19, c.dx + 5, c.dy - 15)
      ..quadraticBezierTo(c.dx + 13, c.dy - 18, c.dx + 14, c.dy - 4)
      ..quadraticBezierTo(c.dx + 8, c.dy - 8, c.dx, c.dy - 8)
      ..quadraticBezierTo(c.dx - 8, c.dy - 8, c.dx - 14, c.dy - 4)
      ..close();
    canvas.drawPath(hair, Paint()..color = teamColor);
    canvas.drawPath(
      hair,
      Paint()
        ..color = teamColorDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    _drawEye(canvas, Offset(c.dx - 5.5, c.dy - 1), pose.eyes, left: true);
    _drawEye(canvas, Offset(c.dx + 5.5, c.dy - 1), pose.eyes, left: false);
    _drawMouth(canvas, Offset(c.dx, c.dy + 7), pose.mouth);

    if (pose.sweat > 0.01) {
      final p = Paint()..color = const Color(0xFF64B5F6).withValues(alpha: pose.sweat);
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(c.dx + 13, c.dy - 4), width: 4, height: 6),
        p,
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(c.dx + 16, c.dy + 4), width: 3, height: 5),
        p,
      );
    }
  }

  void _drawEye(Canvas canvas, Offset pos, EyeState s, {required bool left}) {
    final black = Paint()..color = Colors.black;
    final white = Paint()..color = Colors.white;
    final line = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    switch (s) {
      case EyeState.normal:
        canvas.drawCircle(pos, 2.4, black);
        canvas.drawCircle(Offset(pos.dx + 0.6, pos.dy - 0.6), 0.8, white);
        break;
      case EyeState.happy:
        final p = Path()
          ..moveTo(pos.dx - 3.5, pos.dy + 1)
          ..quadraticBezierTo(pos.dx, pos.dy - 3.5, pos.dx + 3.5, pos.dy + 1);
        canvas.drawPath(p, line..strokeWidth = 1.8);
        break;
      case EyeState.sad:
        canvas.drawCircle(pos, 2.2, black);
        canvas.drawLine(
          Offset(pos.dx - 3, pos.dy - (left ? 5 : 4)),
          Offset(pos.dx + 3, pos.dy - (left ? 4 : 5)),
          line..strokeWidth = 1.5,
        );
        break;
      case EyeState.determined:
        canvas.drawLine(
          Offset(pos.dx - 3, pos.dy),
          Offset(pos.dx + 3, pos.dy),
          line..strokeWidth = 2.4,
        );
        break;
      case EyeState.surprised:
        canvas.drawCircle(pos, 4, white);
        canvas.drawCircle(
          pos,
          4,
          Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
        canvas.drawCircle(pos, 2, black);
        break;
      case EyeState.gritted:
        canvas.drawLine(
          Offset(pos.dx - 3, pos.dy - 1.8),
          Offset(pos.dx + 3, pos.dy + 1.8),
          line..strokeWidth = 2.4,
        );
        break;
      case EyeState.closed:
        canvas.drawLine(
          Offset(pos.dx - 3, pos.dy),
          Offset(pos.dx + 3, pos.dy),
          line..strokeWidth = 1.8,
        );
        break;
    }
  }

  void _drawMouth(Canvas canvas, Offset pos, MouthState s) {
    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    switch (s) {
      case MouthState.neutral:
        canvas.drawLine(
            Offset(pos.dx - 3, pos.dy), Offset(pos.dx + 3, pos.dy), stroke);
        break;
      case MouthState.smile:
        final p = Path()
          ..moveTo(pos.dx - 4.5, pos.dy - 1)
          ..quadraticBezierTo(pos.dx, pos.dy + 4, pos.dx + 4.5, pos.dy - 1);
        canvas.drawPath(p, stroke);
        break;
      case MouthState.frown:
        final p = Path()
          ..moveTo(pos.dx - 4.5, pos.dy + 1.5)
          ..quadraticBezierTo(pos.dx, pos.dy - 3.5, pos.dx + 4.5, pos.dy + 1.5);
        canvas.drawPath(p, stroke);
        break;
      case MouthState.open:
        canvas.drawOval(
          Rect.fromCenter(center: pos, width: 6.5, height: 8.5),
          Paint()..color = const Color(0xFF7A0E0E),
        );
        break;
      case MouthState.gritted:
        final r = Rect.fromCenter(center: pos, width: 9, height: 4.5);
        canvas.drawRect(r, Paint()..color = Colors.white);
        canvas.drawRect(r, stroke..strokeWidth = 1);
        canvas.drawLine(
          Offset(pos.dx, pos.dy - 2.2),
          Offset(pos.dx, pos.dy + 2.2),
          stroke..strokeWidth = 0.8,
        );
        break;
      case MouthState.o:
        canvas.drawCircle(pos, 2.6, stroke);
        break;
    }
  }

  static Color _darker(Color c, [double amount = 0.25]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness * (1 - amount)).clamp(0.0, 1.0))
        .toColor();
  }
}