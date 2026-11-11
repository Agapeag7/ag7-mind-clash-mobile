import 'package:flutter_test/flutter_test.dart';

import 'package:ag7_mind_clash/game/components/character_animations.dart';

void main() {
  group('CharacterAnimations', () {
    test('tugging and resisting animations are dynamic loops', () {
      final pull = CharacterAnimations.pull;
      final struggle = CharacterAnimations.struggle;

      expect(pull.loop, isTrue);
      expect(struggle.loop, isTrue);
      expect(pull.poseAt(0.18).bodyLean, lessThan(pull.poseAt(0.62).bodyLean));
      expect(
        struggle.poseAt(0.24).sweat,
        greaterThan(struggle.poseAt(0).sweat),
      );
    });

    test('looping animations return smoothly to their starting pose', () {
      for (final animation in [
        CharacterAnimations.pull,
        CharacterAnimations.struggle,
      ]) {
        final start = animation.poseAt(0);
        final end = animation.poseAt(animation.duration);

        expect(end.bodyLean, start.bodyLean);
        expect(end.headTilt, start.headTilt);
        expect(end.armL, start.armL);
        expect(end.armR, start.armR);
        expect(end.legL, start.legL);
        expect(end.legR, start.legR);
        expect(end.sweat, start.sweat);
      }
    });
  });
}
