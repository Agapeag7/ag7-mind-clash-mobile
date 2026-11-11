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
  Question? _visibleQuestion;
  Question? get visibleQuestion => _visibleQuestion ?? _question;

  int _attemptsLeft = GameConstants.defaultAttempts;
  int get attemptsLeft => _attemptsLeft;

  double _timeLeft = 0;
  double get timeLeft => _timeLeft;
  double get maxTime => config.secondsPerQuestion;
  double _turnTimeLimit = 0;
  double get turnTimeLimit => _turnTimeLimit;

  int _roundWinnerSide = -1;
  int get roundWinnerSide => _roundWinnerSide;

  int _gameWinnerSide = -1;
  int get gameWinnerSide => _gameWinnerSide;

  // Power-up flags
  bool _redDoubleNext = false;
  bool _blueDoubleNext = false;
  bool _redRopeFrozen = false;
  bool _blueRopeFrozen = false;
  bool _redTimeTheftNext = false;
  bool _blueTimeTheftNext = false;
  bool _redIllusionNext = false;
  bool _blueIllusionNext = false;

  Timer? _tick;
  Timer? _illusionTimer;
  bool _illusionPending = false;
  int _aiRequestGeneration = 0;
  bool _isDisposed = false;

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
    _redRopeFrozen = false;
    _blueRopeFrozen = false;
    _redTimeTheftNext = false;
    _blueTimeTheftNext = false;
    _redIllusionNext = false;
    _blueIllusionNext = false;

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
    _visibleQuestion = _question;
    _illusionTimer?.cancel();
    _illusionPending = false;
    final timeStolen = team.isRed ? _blueTimeTheftNext : _redTimeTheftNext;
    if (team.isRed) {
      _blueTimeTheftNext = false;
    } else {
      _redTimeTheftNext = false;
    }
    _turnTimeLimit = config.secondsPerQuestion * (timeStolen ? 0.7 : 1);
    _timeLeft = _turnTimeLimit;
    final illusionActive = team.isRed ? _blueIllusionNext : _redIllusionNext;
    if (team.isRed) {
      _blueIllusionNext = false;
    } else {
      _redIllusionNext = false;
    }
    _phase = GamePhase.activeTurn;
    notifyListeners();
    _startTimer();
    if (illusionActive) {
      _scheduleIllusion(_question!);
    }
    if (isVsAI && !team.isRed) {
      _scheduleAIResponse();
    }
  }

  void _scheduleIllusion(Question originalQuestion) {
    _illusionTimer?.cancel();
    _illusionPending = true;
    _illusionTimer = Timer(const Duration(seconds: 3), () {
      if (_isDisposed ||
          _phase != GamePhase.activeTurn ||
          !identical(_question, originalQuestion)) {
        _illusionPending = false;
        return;
      }
      _illusionPending = false;
      var decoy = _generator.generate();
      while (decoy.expression == originalQuestion.expression) {
        decoy = _generator.generate();
      }
      _visibleQuestion = decoy;
      notifyListeners();
    });
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
    _illusionTimer?.cancel();
    _illusionPending = false;
    _phase = GamePhase.answerValidated;
    notifyListeners();
    // Temps écoulé = perte d'une tentative
    _handleWrongAnswer(timedOut: true);
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
      _illusionTimer?.cancel();
      _illusionPending = false;
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

    // Gel de corde : l'équipe protégée ne peut pas déplacer la corde.
    final teamFrozen = team.isRed ? _redRopeFrozen : _blueRopeFrozen;
    if (teamFrozen) {
      if (team.isRed) {
        _redRopeFrozen = false;
      } else {
        _blueRopeFrozen = false;
      }
    } else {
      final pull = team.isRed ? -delta : delta;
      _rope = (_rope + pull).clamp(
        -GameConstants.maxRopePosition,
        GameConstants.maxRopePosition,
      );
    }

    // Drop de bonus (30%)
    if (DateTime.now().microsecondsSinceEpoch % 100 <
        GameConstants.bonusDropChancePercent) {
      final p =
          PowerUp.catalog[(DateTime.now().microsecondsSinceEpoch ~/ 100) %
              PowerUp.catalog.length];
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

  void _handleWrongAnswer({bool timedOut = false}) {
    final team = activeTeam;

    _attemptsLeft--;
    if (_attemptsLeft > 0) {
      _phase = GamePhase.activeTurn;
      if (timedOut) {
        _timeLeft = _turnTimeLimit;
      }
      notifyListeners();
      _startTimer();
      if (isVsAI && !team.isRed) {
        _scheduleAIResponse();
      }
    } else {
      _illusionTimer?.cancel();
      _illusionPending = false;
      // Perdu le tour, la corde va vers l'adversaire
      if (team.isRed) {
        _rope = (_rope + 1.0).clamp(
          -GameConstants.maxRopePosition,
          GameConstants.maxRopePosition,
        );
      } else {
        _rope = (_rope - 1.0).clamp(
          -GameConstants.maxRopePosition,
          GameConstants.maxRopePosition,
        );
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
    if (_isDisposed ||
        _phase == GamePhase.roundOver ||
        _phase == GamePhase.gameOver) {
      return;
    }
    _startTurn(activeTeam.isRed ? blue : red);
  }

  // -------------------------------------------------------------
  // IA
  // -------------------------------------------------------------

  void _scheduleAIResponse() {
    _cancelAI();
    if (!isVsAI || _question == null) return;
    final question = _question!;
    final requestGeneration = _aiRequestGeneration;
    unawaited(_respondAsAI(question, requestGeneration));
  }

  Future<void> _respondAsAI(Question question, int requestGeneration) async {
    final answer = await _ai.think(question);
    if (_isDisposed ||
        requestGeneration != _aiRequestGeneration ||
        _phase != GamePhase.activeTurn ||
        activeTeam.isRed ||
        !identical(_question, question)) {
      return;
    }
    final bonuses = List<PowerUp>.of(blueInventory.items);
    bonuses.sort((first, second) {
      final firstIsAutoAnswer = first.type == PowerUpType.autoAnswer;
      final secondIsAutoAnswer = second.type == PowerUpType.autoAnswer;
      return firstIsAutoAnswer == secondIsAutoAnswer
          ? 0
          : firstIsAutoAnswer
          ? 1
          : -1;
    });
    for (final bonus in bonuses) {
      if (_phase != GamePhase.activeTurn || activeTeam.isRed) return;
      usePowerUp(bonus);
    }
    if (_phase == GamePhase.activeTurn) submitAnswer(answer);
  }

  void _cancelAI() {
    _aiRequestGeneration++;
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
      case PowerUpType.timeTheft:
        if (activeTeam.isRed) {
          _redTimeTheftNext = true;
        } else {
          _blueTimeTheftNext = true;
        }
        break;
      case PowerUpType.illusion:
        if (activeTeam.isRed) {
          _redIllusionNext = true;
        } else {
          _blueIllusionNext = true;
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
      case PowerUpType.autoAnswer:
        if (_question != null) {
          submitAnswer(_question!.correctAnswer);
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
    _illusionTimer?.cancel();
    _cancelAI();
    _phase = GamePhase.paused;
    notifyListeners();
  }

  void resume() {
    if (_phase != GamePhase.paused) return;
    _phase = GamePhase.activeTurn;
    _startTimer();
    if (_illusionPending && _question != null) {
      _scheduleIllusion(_question!);
    }
    if (isVsAI && !activeTeam.isRed) {
      _scheduleAIResponse();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopTimer();
    _illusionTimer?.cancel();
    _cancelAI();
    super.dispose();
  }
}
