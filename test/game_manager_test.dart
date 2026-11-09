import 'package:flutter_test/flutter_test.dart';
import 'package:ag7_mind_clash/core/difficulty.dart';
import 'package:ag7_mind_clash/game/game_manager.dart';

void main() {
  test('Une nouvelle partie démarre avec corde à 0', () {
    final gm = GameManager(
      config: DifficultyConfig.byLevel(1),
      isVsAI: false,
    );
    gm.startNewGame();
    expect(gm.ropePosition, 0);
    expect(gm.red.roundsWon, 0);
    expect(gm.blue.roundsWon, 0);
  });

  test('Bonne réponse déplace la corde vers le rouge', () {
    final gm = GameManager(
      config: DifficultyConfig.byLevel(1),
      isVsAI: false,
    );
    gm.startNewGame();
    expect(gm.isRedTurn, isTrue);
    final answer = gm.question!.correctAnswer;
    gm.submitAnswer(answer);
    // -1 après une bonne réponse (peut être -1 ou -2 selon double)
    expect(gm.ropePosition, lessThan(0));
    gm.dispose();
  });

  test('Deux mauvaises réponses passent le tour', () {
    final gm = GameManager(
      config: DifficultyConfig.byLevel(1),
      isVsAI: false,
    );
    gm.startNewGame();
    expect(gm.isRedTurn, isTrue);
    final wrong = gm.question!.correctAnswer + 999;
    gm.submitAnswer(wrong);
    gm.submitAnswer(wrong);
    // Après 2 mauvaises réponses, la corde bouge vers l'adversaire (bleu, positif)
    expect(gm.ropePosition, greaterThan(0));
    gm.dispose();
  });
}