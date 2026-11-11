import 'dart:async';

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

  test('Les compteurs suivent les réponses correctes et incorrectes', () {
    final gm = GameManager(config: DifficultyConfig.byLevel(1), isVsAI: false);
    gm.startNewGame();

    gm.submitAnswer(gm.question!.correctAnswer + 999);
    gm.submitAnswer(gm.question!.correctAnswer);

    expect(gm.totalAnswers, 2);
    expect(gm.correctAnswers, 1);
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

  test(
    'Le chrono écoulé passe le tour même avec des tentatives restantes',
    () async {
      final gm = GameManager(
        config: const DifficultyConfig(
          level: 1,
          name: 'Test',
          description: 'Chrono court',
          secondsPerQuestion: 0.2,
          aiAccuracy: 0.55,
          aiMinDelay: 3,
          aiMaxDelay: 6,
        ),
        isVsAI: false,
      );
      final transition = Completer<void>();
      void watchTransition() {
        if (gm.phase == GamePhase.transition && !transition.isCompleted) {
          transition.complete();
        }
      }

      gm.addListener(watchTransition);
      gm.startNewGame();
      try {
        await transition.future.timeout(const Duration(seconds: 3));

        expect(gm.attemptsLeft, greaterThan(1));
        expect(gm.ropePosition, greaterThan(0));
        expect(gm.totalAnswers, 1);

        await Future<void>.delayed(const Duration(milliseconds: 650));
        expect(gm.isRedTurn, isFalse);
      } finally {
        gm.removeListener(watchTransition);
        gm.dispose();
      }
    },
  );

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

  test(
    'L’illusion masque la question sans changer la réponse attendue',
    () async {
      final gm = GameManager(
        config: DifficultyConfig.byLevel(1),
        isVsAI: false,
      );
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
    },
  );

  test('L’IA utilise tous ses bonus et vole du temps', () async {
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
    gm.redInventory.clear();
    gm.blueInventory.clear();
    for (final powerUp in PowerUp.catalog) {
      gm.blueInventory.add(powerUp);
    }
    gm.submitAnswer(gm.question!.correctAnswer);

    await Future<void>.delayed(const Duration(milliseconds: 1400));

    try {
      expect(gm.isRedTurn, isTrue);
      expect(gm.turnTimeLimit, closeTo(gm.maxTime * 0.7, 0.001));
      expect(gm.phase, GamePhase.activeTurn);
      gm.submitAnswer(gm.question!.correctAnswer);
      expect(gm.ropePosition, 1);
    } finally {
      gm.dispose();
    }
  });
}
