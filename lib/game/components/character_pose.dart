import 'character_enums.dart';

class CharacterPose {
  final double bodyLean;
  final double headTilt;
  final double armL;
  final double armR;
  final double legL;
  final double legR;
  final double verticalOffset;
  final double horizontalOffset;
  final double squash;
  final EyeState eyes;
  final MouthState mouth;
  final double glow;
  final double sweat;

  const CharacterPose({
    this.bodyLean = 0,
    this.headTilt = 0,
    this.armL = 1.35,
    this.armR = 1.45,
    this.legL = -0.2,
    this.legR = 0.25,
    this.verticalOffset = 0,
    this.horizontalOffset = 0,
    this.squash = 1.0,
    this.eyes = EyeState.normal,
    this.mouth = MouthState.neutral,
    this.glow = 0,
    this.sweat = 0,
  });

  static CharacterPose lerp(CharacterPose a, CharacterPose b, double t) {
    t = t.clamp(0.0, 1.0);
    final eased = t * t * (3 - 2 * t);
    return CharacterPose(
      bodyLean: _l(a.bodyLean, b.bodyLean, eased),
      headTilt: _l(a.headTilt, b.headTilt, eased),
      armL: _l(a.armL, b.armL, eased),
      armR: _l(a.armR, b.armR, eased),
      legL: _l(a.legL, b.legL, eased),
      legR: _l(a.legR, b.legR, eased),
      verticalOffset: _l(a.verticalOffset, b.verticalOffset, eased),
      horizontalOffset: _l(a.horizontalOffset, b.horizontalOffset, eased),
      squash: _l(a.squash, b.squash, eased),
      eyes: t < 0.5 ? a.eyes : b.eyes,
      mouth: t < 0.5 ? a.mouth : b.mouth,
      glow: _l(a.glow, b.glow, eased),
      sweat: _l(a.sweat, b.sweat, eased),
    );
  }

  static double _l(double a, double b, double t) => a + (b - a) * t;
}
