import 'package:flutter_test/flutter_test.dart';
import 'package:ag7_mind_clash/services/question_generator.dart';

void main() {
  test('Niveau 1 : questions dans les bornes 0-20', () {
    final gen = QuestionGenerator(1);
    for (var i = 0; i < 100; i++) {
      final q = gen.generate();
      expect(q.correctAnswer, greaterThanOrEqualTo(0));
      expect(q.expression, isNotEmpty);
    }
  });

  test('Niveau 3 : divisions exactes', () {
    final gen = QuestionGenerator(3);
    for (var i = 0; i < 200; i++) {
      final q = gen.generate();
      if (q.expression.contains('÷')) {
        final parts = q.expression.split(' ÷ ');
        final a = int.parse(parts[0]);
        final b = int.parse(parts[1]);
        expect(a % b, 0, reason: 'Division non entière : ${q.expression}');
        expect(a ~/ b, q.correctAnswer);
      }
    }
  });

  test('Tous les niveaux génèrent des questions', () {
    for (var lvl = 1; lvl <= 6; lvl++) {
      final gen = QuestionGenerator(lvl);
      for (var i = 0; i < 30; i++) {
        final q = gen.generate();
        expect(q.expression, isNotEmpty);
        expect(q.correctAnswer, isA<int>());
      }
    }
  });
}