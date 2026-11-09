import 'dart:math';
import '../models/question.dart';

class QuestionGenerator {
  final int level;
  final Random _rng;

  QuestionGenerator(this.level, {int? seed}) : _rng = Random(seed);

  Question generate() {
    switch (level) {
      case 1:
        return _level1();
      case 2:
        return _level2();
      case 3:
        return _level3();
      case 4:
        return _level4();
      case 5:
        return _level5();
      case 6:
        return _level6();
      default:
        return _level1();
    }
  }

  Question _level1() {
    final a = _rng.nextInt(21);
    final b = _rng.nextInt(21);
    return _rng.nextBool()
        ? Question(expression: '$a + $b', correctAnswer: a + b)
        : _safeSub(a, b);
  }

  Question _safeSub(int a, int b) {
    final x = max(a, b);
    final y = min(a, b);
    return Question(expression: '$x − $y', correctAnswer: x - y);
  }

  Question _level2() {
    final a = _rng.nextInt(51);
    final b = _rng.nextInt(51);
    final op = _rng.nextInt(3);
    if (op == 0) return Question(expression: '$a + $b', correctAnswer: a + b);
    if (op == 1) return _safeSub(a, b);
    final m1 = _rng.nextInt(11);
    final m2 = _rng.nextInt(11);
    return Question(expression: '$m1 × $m2', correctAnswer: m1 * m2);
  }

  Question _level3() {
    final op = _rng.nextInt(4);
    if (op == 0 || op == 1) return _level2();
    if (op == 2) {
      final a = 2 + _rng.nextInt(12);
      final b = 2 + _rng.nextInt(12);
      return Question(expression: '$a × $b', correctAnswer: a * b);
    }
    final b = 2 + _rng.nextInt(11);
    final q = 1 + _rng.nextInt(12);
    final a = b * q;
    return Question(expression: '$a ÷ $b', correctAnswer: q);
  }

  Question _level4() {
    final a = _rng.nextInt(21);
    final b = _rng.nextInt(21);
    final c = _rng.nextInt(11);
    final op = _rng.nextInt(4);
    switch (op) {
      case 0:
        return Question(expression: '$a + $b − $c', correctAnswer: a + b - c);
      case 1:
        return Question(expression: '$a × $b + $c', correctAnswer: a * b + c);
      case 2:
        return _safeSub(a * b, c);
      default:
        return Question(
          expression: '($a + $b) × $c',
          correctAnswer: (a + b) * c,
        );
    }
  }

  Question _level5() {
    final a = 2 + _rng.nextInt(9);
    final b = 2 + _rng.nextInt(9);
    final c = 1 + _rng.nextInt(10);
    final options = [
      Question(expression: '$a × ($b + $c)', correctAnswer: a * (b + c)),
      Question(expression: '($a + $b) × $c', correctAnswer: (a + b) * c),
      Question(expression: '$a × $b − $c', correctAnswer: a * b - c),
    ];
    return options[_rng.nextInt(options.length)];
  }

  Question _level6() {
    final a = 2 + _rng.nextInt(12);
    final b = 2 + _rng.nextInt(12);
    final c = 1 + _rng.nextInt(15);
    final d = 1 + _rng.nextInt(10);
    final options = [
      Question(expression: '$a × $b + $c − $d', correctAnswer: a * b + c - d),
      Question(
        expression: '($a + $b) × $c − $d',
        correctAnswer: (a + b) * c - d,
      ),
      Question(
        expression: '$a × ($b + $c) ÷ $d',
        correctAnswer: (a * (b + c)) ~/ d,
      ),
    ];
    return options[_rng.nextInt(options.length)];
  }
}