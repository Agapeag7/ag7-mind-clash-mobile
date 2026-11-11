import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ag7_mind_clash/core/difficulty.dart';
import 'package:ag7_mind_clash/core/enums.dart';
import 'package:ag7_mind_clash/game/game_manager.dart';
import 'package:ag7_mind_clash/models/power_up.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);

  test('Une nouvelle partie démarre avec corde à 0', () {
    final gm = GameManager(config: DifficultyConfig.byLevel(1), isVsAI: false);
    gm.startNewGame();
    expect(gm.ropePosition, greaterThan(0));
    expect(gm.red.roundsWon, 0);
    expect(gm.blue.roundsWon, 0);
    gm.dispose();
  });

  test('Bonne réponse déplace la corde vers le rouge', () {
    final gm = GameManager(config: DifficultyConfig.byLevel(1), isVsAI: false);
    gm.startNewGame();
    expect(gm.isRedTurn, isTrue);
    final answer = gm.question!.correctAnswer;
    gm.submitAnswer(answer);
    // -1 après une bonne réponse (peut être -1 ou -2 selon double)
    expect(gm.ropePosition, lessThan(0));
    gm.dispose();
  });

  test('Deux mauvaises réponses passent le tour', () {
    final gm = GameManager(config: DifficultyConfig.byLevel(1), isVsAI: false);
    gm.startNewGame();
    expect(gm.isRedTurn, isTrue);
    final wrong = gm.question!.correctAnswer + 999;
    gm.submitAnswer(wrong);
    gm.submitAnswer(wrong);
    // Après 2 mauvaises réponses, la corde bouge vers l'adversaire (bleu, positif)
    expect(gm.ropePosition, greaterThan(0));
    gm.dispose();
  });

  test('Une mauvaise réponse ne remet pas le chronomètre à zéro', () async {
    final gm = GameManager(config: DifficultyConfig.byLevel(1), isVsAI: false);
    gm.startNewGame();
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final timeBeforeWrongAnswer = gm.timeLeft;

    gm.submitAnswer(gm.question!.correctAnswer + 999);
    await Future<void>.delayed(const Duration(milliseconds: 220));

    expect(gm.timeLeft, lessThan(timeBeforeWrongAnswer));
    gm.dispose();
  });

  test('Le vol de temps réduit le prochain tour adverse à 70 %', () async {
    final gm = GameManager(config: DifficultyConfig.byLevel(1), isVsAI: false);
    gm.startNewGame();
    final bonus = PowerUp.catalog.singleWhere(
      (powerUp) => powerUp.type == PowerUpType.timeTheft,
    );
    gm.redInventory.add(bonus);

    expect(gm.usePowerUp(bonus), isTrue);
    gm.submitAnswer(gm.question!.correctAnswer);
    await Future<void>.delayed(const Duration(milliseconds: 650));

    expect(gm.isRedTurn, isFalse);
    expect(gm.turnTimeLimit, closeTo(gm.maxTime * 0.7, 0.001));
    gm.dispose();
  });

  test('L’illusion masque la question sans changer la réponse attendue', () async {
    final gm = GameManager(config: DifficultyConfig.byLevel(1), isVsAI: false);
    gm.startNewGame();
    final bonus = PowerUp.catalog.singleWhere(
      (powerUp) => powerUp.type == PowerUpType.illusion,
    );
    gm.redInventory.add(bonus);

    expect(gm.usePowerUp(bonus), isTrue);
    gm.submitAnswer(gm.question!.correctAnswer);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    final originalQuestion = gm.question!;

    expect(gm.visibleQuestion, same(originalQuestion));
    await Future<void>.delayed(const Duration(milliseconds: 3100));

    expect(gm.visibleQuestion, isNot(same(originalQuestion)));
    expect(
      gm.visibleQuestion!.expression,
      isNot(originalQuestion.expression),
    );
    expect(gm.submitAnswer(originalQuestion.correctAnswer), isTrue);
    expect(gm.ropePosition, greaterThan(0));
    gm.dispose();
  });

  test('L’IA répond automatiquement pendant le tour bleu', () async {
    final gm = GameManager(
      config: const DifficultyConfig(
        level: 1,
        name: 'Test',
        description: 'Test IA',
        secondsPerQuestion: 10,
        aiAccuracy: 1,
        aiMinDelay: 0.01,
        aiMaxDelay: 0.01,
      ),
      isVsAI: true,
    );
    gm.startNewGame();
    gm.submitAnswer(gm.question!.correctAnswer);

    await Future<void>.delayed(const Duration(milliseconds: 900));

    try {
      expect(gm.isRedTurn, isFalse);
      expect(gm.ropePosition, 0);
      expect(gm.phase, GamePhase.transition);
    } finally {
      gm.dispose();
    }
  });
}
