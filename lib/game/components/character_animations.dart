import '../../core/enums.dart';
import 'character_enums.dart';
import 'character_pose.dart';

class AnimationDefinition {
  final List<({double time, CharacterPose pose})> keyframes;
  final bool loop;

  const AnimationDefinition(this.keyframes, {this.loop = false});

  double get duration => keyframes.last.time;

  CharacterPose poseAt(double t) {
    if (keyframes.isEmpty) return const CharacterPose();
    if (t <= keyframes.first.time) return keyframes.first.pose;
    if (t >= keyframes.last.time) return keyframes.last.pose;
    for (var i = 0; i < keyframes.length - 1; i++) {
      final a = keyframes[i];
      final b = keyframes[i + 1];
      if (t >= a.time && t <= b.time) {
        final k = (t - a.time) / (b.time - a.time);
        return CharacterPose.lerp(a.pose, b.pose, k);
      }
    }
    return keyframes.last.pose;
  }
}

class CharacterAnimations {
  static const base = CharacterPose();

  static final idle = AnimationDefinition(const [
    (time: 0.0, pose: base),
    (
      time: 0.6,
      pose: CharacterPose(verticalOffset: 1.5, headTilt: -0.025),
    ),
    (time: 1.2, pose: base),
  ], loop: true);

  static final pull = AnimationDefinition(const [
    (
      time: 0.0,
      pose: CharacterPose(
        bodyLean: -0.28,
        headTilt: 0.04,
        armL: 1.45,
        armR: 1.58,
        legL: -0.32,
        legR: 0.40,
        eyes: EyeState.determined,
        mouth: MouthState.gritted,
      )
    ),
    (
      time: 0.18,
      pose: CharacterPose(
        bodyLean: -0.62,
        headTilt: -0.08,
        armL: 1.72,
        armR: 1.82,
        legL: -0.52,
        legR: 0.56,
        verticalOffset: -2,
        horizontalOffset: -3,
        squash: 0.94,
        eyes: EyeState.determined,
        mouth: MouthState.gritted,
      )
    ),
    (
      time: 0.40,
      pose: CharacterPose(
        bodyLean: -0.50,
        headTilt: 0.03,
        armL: 1.62,
        armR: 1.72,
        legL: -0.40,
        legR: 0.47,
        verticalOffset: 1,
        horizontalOffset: -1,
        squash: 0.98,
        eyes: EyeState.determined,
        mouth: MouthState.gritted,
      )
    ),
    (
      time: 0.62,
      pose: CharacterPose(
        bodyLean: -0.22,
        armL: 1.38,
        armR: 1.48,
        legL: -0.28,
        legR: 0.35,
        verticalOffset: 2,
        eyes: EyeState.determined,
        mouth: MouthState.gritted,
      )
    ),
    (
      time: 0.88,
      pose: CharacterPose(
        bodyLean: -0.28,
        headTilt: 0.04,
        armL: 1.45,
        armR: 1.58,
        legL: -0.32,
        legR: 0.40,
        eyes: EyeState.determined,
        mouth: MouthState.gritted,
      )
    ),
  ], loop: true);

  static final struggle = AnimationDefinition(const [
    (
      time: 0.0,
      pose: CharacterPose(
        bodyLean: -0.20,
        headTilt: 0.06,
        armL: 1.38,
        armR: 1.54,
        legL: -0.26,
        legR: 0.34,
        eyes: EyeState.determined,
        mouth: MouthState.gritted,
        sweat: 0.25,
      )
    ),
    (
      time: 0.24,
      pose: CharacterPose(
        bodyLean: -0.38,
        headTilt: -0.08,
        armL: 1.56,
        armR: 1.70,
        legL: -0.42,
        legR: 0.45,
        verticalOffset: -1,
        eyes: EyeState.sad,
        mouth: MouthState.gritted,
        sweat: 0.75,
      )
    ),
    (
      time: 0.48,
      pose: CharacterPose(
        bodyLean: -0.24,
        headTilt: 0.10,
        armL: 1.43,
        armR: 1.58,
        legL: -0.30,
        legR: 0.38,
        eyes: EyeState.determined,
        mouth: MouthState.gritted,
        sweat: 0.5,
      )
    ),
    (
      time: 0.72,
      pose: CharacterPose(
        bodyLean: -0.32,
        headTilt: -0.02,
        armL: 1.50,
        armR: 1.65,
        legL: -0.36,
        legR: 0.42,
        eyes: EyeState.sad,
        mouth: MouthState.gritted,
        sweat: 0.7,
      )
    ),
    (
      time: 0.96,
      pose: CharacterPose(
        bodyLean: -0.20,
        headTilt: 0.06,
        armL: 1.38,
        armR: 1.54,
        legL: -0.26,
        legR: 0.34,
        eyes: EyeState.determined,
        mouth: MouthState.gritted,
        sweat: 0.25,
      )
    ),
  ], loop: true);

  static final strongPull = AnimationDefinition(const [
    (
      time: 0.0,
      pose: CharacterPose(
        bodyLean: -0.30,
        armL: 1.45,
        armR: 1.58,
        legL: -0.32,
        legR: 0.40,
        eyes: EyeState.determined,
        mouth: MouthState.gritted,
      )
    ),
    (
      time: 0.10,
      pose: CharacterPose(
        bodyLean: 0.10,
        armL: 1.25,
        armR: 1.35,
        squash: 0.95,
      )
    ),
    (
      time: 0.28,
      pose: CharacterPose(
        bodyLean: -0.55,
        headTilt: -0.10,
        armL: 1.76,
        armR: 1.86,
        legL: -0.55,
        legR: 0.50,
        verticalOffset: -3,
        horizontalOffset: -4,
        eyes: EyeState.determined,
        mouth: MouthState.gritted,
        squash: 0.93,
      )
    ),
    (
      time: 0.50,
      pose: CharacterPose(
        bodyLean: -0.40,
        armL: 1.66,
        armR: 1.76,
        legL: -0.45,
        legR: 0.40,
        eyes: EyeState.determined,
        mouth: MouthState.gritted,
      )
    ),
    (
      time: 0.70,
      pose: CharacterPose(
        bodyLean: -0.30,
        armL: 1.46,
        armR: 1.58,
        legL: -0.32,
        legR: 0.38,
        eyes: EyeState.determined,
        mouth: MouthState.gritted,
      )
    ),
  ]);

  static final slip = AnimationDefinition(const [
    (time: 0.0, pose: base),
    (
      time: 0.15,
      pose: CharacterPose(
        bodyLean: 0.35,
        legL: 0.50,
        legR: 0.60,
        armL: 1.70,
        armR: 1.80,
        eyes: EyeState.surprised,
        mouth: MouthState.open,
        horizontalOffset: 5,
        squash: 0.92,
      )
    ),
    (
      time: 0.40,
      pose: CharacterPose(
        bodyLean: 0.50,
        legL: 0.60,
        legR: 0.70,
        armL: 1.75,
        armR: 1.85,
        eyes: EyeState.surprised,
        mouth: MouthState.open,
        horizontalOffset: 12,
        squash: 0.88,
      )
    ),
  ]);

  static final fall = AnimationDefinition(const [
    (time: 0.0, pose: base),
    (
      time: 0.30,
      pose: CharacterPose(
        bodyLean: 0.80,
        legL: 0.70,
        legR: 0.80,
        eyes: EyeState.surprised,
        mouth: MouthState.open,
        horizontalOffset: 15,
        verticalOffset: 5,
      )
    ),
    (
      time: 0.60,
      pose: CharacterPose(
        bodyLean: 1.40,
        legL: 1.00,
        legR: 1.10,
        eyes: EyeState.closed,
        mouth: MouthState.open,
        horizontalOffset: 25,
        verticalOffset: 30,
        squash: 0.80,
      )
    ),
    (
      time: 0.90,
      pose: CharacterPose(
        bodyLean: 1.55,
        legL: 1.20,
        legR: 1.30,
        eyes: EyeState.closed,
        mouth: MouthState.frown,
        horizontalOffset: 30,
        verticalOffset: 45,
        squash: 0.75,
      )
    ),
  ]);

  static final victory = AnimationDefinition(const [
    (time: 0.0, pose: base),
    (
      time: 0.15,
      pose: CharacterPose(
        verticalOffset: 15,
        armL: -2.5,
        armR: 2.5,
        legL: 0.15,
        legR: -0.15,
        eyes: EyeState.happy,
        mouth: MouthState.smile,
      )
    ),
    (
      time: 0.35,
      pose: CharacterPose(
        verticalOffset: 0,
        armL: -2.5,
        armR: 2.5,
        eyes: EyeState.happy,
        mouth: MouthState.smile,
      )
    ),
    (
      time: 0.55,
      pose: CharacterPose(
        verticalOffset: 15,
        armL: -2.5,
        armR: 2.5,
        legL: 0.15,
        legR: -0.15,
        eyes: EyeState.happy,
        mouth: MouthState.smile,
      )
    ),
    (
      time: 0.90,
      pose: CharacterPose(
        verticalOffset: 0,
        armL: -2.5,
        armR: 2.5,
        eyes: EyeState.happy,
        mouth: MouthState.smile,
      )
    ),
  ], loop: true);

  static final defeat = AnimationDefinition(const [
    (time: 0.0, pose: base),
    (
      time: 0.40,
      pose: CharacterPose(
        bodyLean: 0.35,
        headTilt: 0.40,
        armL: 0.60,
        armR: 0.60,
        legL: 0.05,
        legR: 0.15,
        eyes: EyeState.sad,
        mouth: MouthState.frown,
      )
    ),
    (
      time: 0.70,
      pose: CharacterPose(
        bodyLean: 0.35,
        headTilt: 0.40,
        armL: 0.60,
        armR: 0.60,
        legL: 0.05,
        legR: 0.15,
        eyes: EyeState.sad,
        mouth: MouthState.frown,
        sweat: 0.3,
      )
    ),
  ]);

  static final powerUp = AnimationDefinition(const [
    (time: 0.0, pose: base),
    (
      time: 0.15,
      pose: CharacterPose(
        armL: 0.4,
        armR: 0.4,
        bodyLean: 0.1,
        eyes: EyeState.determined,
        glow: 0.4,
        squash: 0.9,
      )
    ),
    (
      time: 0.30,
      pose: CharacterPose(
        armL: 0.9,
        armR: 0.9,
        bodyLean: -0.1,
        eyes: EyeState.determined,
        mouth: MouthState.gritted,
        glow: 1.0,
        squash: 1.1,
      )
    ),
    (
      time: 0.50,
      pose: CharacterPose(
        armL: 1.4,
        armR: 1.5,
        glow: 0.0,
        eyes: EyeState.determined,
      )
    ),
  ]);

  static AnimationDefinition forState(AnimationState s) {
    switch (s) {
      case AnimationState.idle:
        return idle;
      case AnimationState.pull:
        return pull;
      case AnimationState.strongPull:
        return strongPull;
      case AnimationState.struggle:
        return struggle;
      case AnimationState.slip:
        return slip;
      case AnimationState.fall:
        return fall;
      case AnimationState.victory:
        return victory;
      case AnimationState.defeat:
        return defeat;
      case AnimationState.powerUp:
        return powerUp;
    }
  }
}