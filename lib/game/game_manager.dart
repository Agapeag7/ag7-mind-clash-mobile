import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../core/difficulty.dart';
import '../core/enums.dart';
import '../models/inventory.dart';
import '../models/power_up.dart';
import '../models/question.dart';
import '../models/team.dart';
import '../services/ai_controller.dart';
import '../services/audio_service.dart';
import '../services/question_generator.dart';

class GameManager extends ChangeNotifier {
  final DifficultyConfig config;
  final bool isVsAI;

  GameManager({required this.config, required this.isVsAI});

  late final QuestionGenerator _generator = QuestionGenerator(config.level);
  late final AIController _ai = AIController(config);

  final Team red = Team(side: TeamSide.red, name: 'Rouge');
  final Team blue = Team(side: TeamSide.blue, name: 'Bleu');

  final Inventory redInventory = Inventory();
  final Inventory blueInventory = Inventory();

  Team _active = Team(side: TeamSide.red, name: '');
  Team get activeTeam => _active == red || _active == blue ? _active : red;

  double _rope = 0;
  double get ropePosition => _rope;

  int _round = 1;
  int get currentRound => _round;

  GamePhase _phase = GamePhase.idle;
  GamePhase get phase => _phase;

  Question? _question;
  Question? get question => _question;

  int _attemptsLeft = GameConstants.defaultAttempts;
  int get attemptsLeft => _attemptsLeft;

  double _timeLeft = 0;
  double get timeLeft => _timeLeft;
  double get maxTime => config.secondsPerQuestion;

  int _roundWinnerSide = -1;
  int get roundWinnerSide => _roundWinnerSide;

  int _gameWinnerSide = -1;
  int get gameWinnerSide => _gameWinnerSide;

  // Power-up flags
  bool _redDoubleNext = false;
  bool _blueDoubleNext = false;
  bool _redShield = false;
  bool _blueShield = false;
  bool _redRopeFrozen = false;
  bool _blueRopeFrozen = false;

  Timer? _tick;
  Timer? _aiTimer;

  bool get isRedTurn => activeTeam.isRed;

  // -------------------------------------------------------------
  // Cycle de vie
  // -------------------------------------------------------------

  void startNewGame() {
    red.roundsWon = 0;
    blue.roundsWon = 0;
    redInventory.clear();
    blueInventory.clear();
    _round = 1;
    _gameWinnerSide = -1;
    _roundWinnerSide = -1;
    _rope = 0;
    _startRoundInternal();
  }

  void _startRoundInternal() {
    _rope = 0;
    _roundWinnerSide = -1;
    _redDoubleNext = false;
    _blueDoubleNext = false;
    _redShield = false;
    _blueShield = false;
    _redRopeFrozen = false;
    _blueRopeFrozen = false;

    // Les bonus apparaissent en début de manche
    _maybeDropBonus(red, redInventory);
    _maybeDropBonus(blue, blueInventory);

    // Rouge commence toujours la manche
    _startTurn(red);
  }

  void _maybeDropBonus(Team team, Inventory inv) {
    // Probabilité simple : 30% de chance d'avoir un bonus par manche
    final seed = DateTime.now().microsecondsSinceEpoch % 100;
    if (seed < GameConstants.bonusDropChancePercent) {
      final p = PowerUp.catalog[seed % PowerUp.catalog.length];
      inv.add(p);
    }
  }

  void _startTurn(Team team) {
    _active = team;
    _attemptsLeft = GameConstants.defaultAttempts;
    _question = _generator.generate();
    _timeLeft = config.secondsPerQuestion;
    _phase = GamePhase.activeTurn;
    notifyListeners();
    _startTimer();
    if (isVsAI && !team.isRed) {
      _scheduleAIResponse();
    }
  }

  // -------------------------------------------------------------
  // Chronomètre
  // -------------------------------------------------------------

  void _startTimer() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_phase != GamePhase.activeTurn) return;
      _timeLeft -= 0.1;
      if (_timeLeft <= 0) {
        _timeLeft = 0;
        _onTimeout();
      }
      notifyListeners();
    });
  }

  void _stopTimer() {
    _tick?.cancel();
    _tick = null;
  }

  void _onTimeout() {
    _stopTimer();
    _phase = GamePhase.answerValidated;
    notifyListeners();
    // Temps écoulé = perte d'une tentative
    _handleWrongAnswer();
  }

  // -------------------------------------------------------------
  // Soumission de réponse
  // -------------------------------------------------------------

  bool submitAnswer(int answer) {
    if (_phase != GamePhase.activeTurn || _question == null) return false;
    _stopTimer();
    _cancelAI();
    _phase = GamePhase.answerValidated;

    final correct = answer == _question!.correctAnswer;
    if (correct) {
      AudioService.correct();
      _handleCorrectAnswer();
    } else {
      AudioService.wrong();
      _handleWrongAnswer();
    }
    notifyListeners();
    return correct;
  }

  void _handleCorrectAnswer() {
    final team = activeTeam;
    double delta = 1.0;

    if (team.isRed && _redDoubleNext) {
      delta = 2.0;
      _redDoubleNext = false;
    } else if (!team.isRed && _blueDoubleNext) {
      delta = 2.0;
      _blueDoubleNext = false;
    }

    // Gel de corde : l'adversaire est protégé
    final opponentFrozen = team.isRed ? _blueRopeFrozen : _redRopeFrozen;
    if (opponentFrozen) {
      // On consomme le gel sans bouger la corde
      if (team.isRed) {
        _blueRopeFrozen = false;
      } else {
        _redRopeFrozen = false;
      }
    } else {
      if (team.isRed) {
        _rope = (_rope - delta).clamp(-GameConstants.maxRopePosition, 0.0);
      } else {
        _rope = (_rope + delta).clamp(0.0, GameConstants.maxRopePosition);
      }
    }

    // Drop de bonus (30%)
    if (DateTime.now().microsecondsSinceEpoch % 100 <
        GameConstants.bonusDropChancePercent) {
      final p = PowerUp.catalog[
          (DateTime.now().microsecondsSinceEpoch ~/ 100) % PowerUp.catalog.length];
      (team.isRed ? redInventory : blueInventory).add(p);
    }

    if (_rope <= -GameConstants.maxRopePosition ||
        _rope >= GameConstants.maxRopePosition) {
      _endRound(team.isRed ? red : blue);
      return;
    }

    _phase = GamePhase.transition;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 600), _switchTurn);
  }

  void _handleWrongAnswer() {
    final team = activeTeam;

    // Bouclier ?
    final hasShield = team.isRed ? _redShield : _blueShield;
    if (hasShield) {
      if (team.isRed) {
        _redShield = false;
      } else {
        _blueShield = false;
      }
      _phase = GamePhase.activeTurn;
      _timeLeft = config.secondsPerQuestion;
      notifyListeners();
      _startTimer();
      return;
    }

    _attemptsLeft--;
    if (_attemptsLeft > 0) {
      _phase = GamePhase.activeTurn;
      _timeLeft = config.secondsPerQuestion;
      notifyListeners();
      _startTimer();
      if (isVsAI && !team.isRed) {
        _scheduleAIResponse();
      }
    } else {
      // Perdu le tour, la corde va vers l'adversaire
      if (team.isRed) {
        _rope = (_rope + 1.0).clamp(-GameConstants.maxRopePosition,
            GameConstants.maxRopePosition);
      } else {
        _rope = (_rope - 1.0).clamp(-GameConstants.maxRopePosition,
            GameConstants.maxRopePosition);
      }
      if (_rope.abs() >= GameConstants.maxRopePosition) {
        _endRound(_rope < 0 ? red : blue);
      } else {
        _phase = GamePhase.transition;
        notifyListeners();
        Future.delayed(const Duration(milliseconds: 600), _switchTurn);
      }
    }
  }

  void _switchTurn() {
    if (_phase == GamePhase.roundOver || _phase == GamePhase.gameOver) return;
    _startTurn(activeTeam.isRed ? blue : red);
  }

  // -------------------------------------------------------------
  // IA
  // -------------------------------------------------------------

  void _scheduleAIResponse() {
    _cancelAI();
    if (!isVsAI || _question == null) return;
    _aiTimer = Timer(Duration(milliseconds:
        ((config.aiMinDelay + config.aiMaxDelay) * 500).round()), () async {
      if (_phase != GamePhase.activeTurn || activeTeam.isRed) return;
      final q = _question;
      if (q == null) return;
      final answer = await _ai.think(q);
      if (_phase != GamePhase.activeTurn || activeTeam.isRed) return;
      submitAnswer(answer);
    });
  }

  void _cancelAI() {
    _aiTimer?.cancel();
    _aiTimer = null;
  }

  // -------------------------------------------------------------
  // Fin de manche / partie
  // -------------------------------------------------------------

  void _endRound(Team winner) {
    _stopTimer();
    _cancelAI();
    winner.roundsWon++;
    _roundWinnerSide = winner.isRed ? 0 : 1;
    if (winner.roundsWon >= GameConstants.roundsToWin) {
      _gameWinnerSide = winner.isRed ? 0 : 1;
      _phase = GamePhase.gameOver;
    } else {
      _phase = GamePhase.roundOver;
    }
    AudioService.victory();
    notifyListeners();
  }

  void nextRound() {
    if (_phase != GamePhase.roundOver) return;
    _round++;
    _startRoundInternal();
  }

  // -------------------------------------------------------------
  // Power-ups
  // -------------------------------------------------------------

  bool usePowerUp(PowerUp powerUp) {
    if (_phase != GamePhase.activeTurn) return false;
    final inv = activeTeam.isRed ? redInventory : blueInventory;
    if (!inv.remove(powerUp)) return false;

    switch (powerUp.type) {
      case PowerUpType.doublePoints:
        if (activeTeam.isRed) {
          _redDoubleNext = true;
        } else {
          _blueDoubleNext = true;
        }
        break;
      case PowerUpType.shield:
        if (activeTeam.isRed) {
          _redShield = true;
        } else {
          _blueShield = true;
        }
        break;
      case PowerUpType.extraAttempt:
        _attemptsLeft++;
        break;
      case PowerUpType.ropeFreeze:
        if (activeTeam.isRed) {
          _blueRopeFrozen = true;
        } else {
          _redRopeFrozen = true;
        }
        break;
      case PowerUpType.timeFreeze:
        // Effet simplifié : +5 secondes pour l'équipe
        _timeLeft += 5;
        break;
      case PowerUpType.autoAnswer:
        if (_question != null) {
          _timeLeft += 0;
          notifyListeners();
        }
        break;
    }
    AudioService.powerUp();
    notifyListeners();
    return true;
  }

  // -------------------------------------------------------------
  // Pause
  // -------------------------------------------------------------

  void pause() {
    if (_phase != GamePhase.activeTurn) return;
    _stopTimer();
    _cancelAI();
    _phase = GamePhase.paused;
    notifyListeners();
  }

  void resume() {
    if (_phase != GamePhase.paused) return;
    _phase = GamePhase.activeTurn;
    _startTimer();
    if (isVsAI && !activeTeam.isRed) {
      _scheduleAIResponse();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    _cancelAI();
    super.dispose();
  }
}