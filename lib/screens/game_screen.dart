import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants.dart';
import '../core/difficulty.dart';
import '../core/enums.dart';
import '../game/ag7_game.dart';
import '../game/game_manager.dart';
import '../models/power_up.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import 'game_result_screen.dart';
import 'pause_screen.dart';
import 'round_result_screen.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;
  final int difficulty;

  const GameScreen({super.key, required this.mode, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameManager _gm;
  late final Ag7Game _game;
  final TextEditingController _answerController = TextEditingController();
  double _lastRope = 0;
  bool _handlingEnd = false;
  bool _statsSaved = false;

  bool get _canPlayerAnswer =>
      _gm.phase == GamePhase.activeTurn &&
      (widget.mode != GameMode.playerVsAI || _gm.isRedTurn);
  bool get _isAiThinking =>
      _gm.isVsAI && !_gm.isRedTurn && _gm.phase == GamePhase.activeTurn;

  @override
  void initState() {
    super.initState();
    unawaited(
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
      ]),
    );
    _game = Ag7Game();
    _gm = GameManager(
      config: DifficultyConfig.byLevel(widget.difficulty),
      isVsAI: widget.mode == GameMode.playerVsAI,
    );
    _gm.addListener(_onManagerChanged);
    _gm.startNewGame();
  }

  @override
  void dispose() {
    unawaited(
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]),
    );
    _gm.removeListener(_onManagerChanged);
    _gm.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _onManagerChanged() {
    final rope = _gm.ropePosition;
    AnimationState? redReaction;
    AnimationState? blueReaction;
    final pullingSide = _gm.isRedTurn ? TeamSide.red : TeamSide.blue;
    final isTugging =
        _gm.phase == GamePhase.activeTurn ||
        _gm.phase == GamePhase.answerValidated ||
        _gm.phase == GamePhase.transition;
    if (isTugging) {
      _game.setTugging(pullingSide);
      if ((rope - _lastRope).abs() > 0.05) {
        if (pullingSide == TeamSide.red) {
          redReaction = AnimationState.strongPull;
          blueReaction = AnimationState.slip;
        } else {
          blueReaction = AnimationState.strongPull;
          redReaction = AnimationState.slip;
        }
      }
    }
    _lastRope = rope;
    _game.setRopePosition(
      rope,
      redReaction: redReaction,
      blueReaction: blueReaction,
    );

    if (_gm.phase == GamePhase.roundOver && !_handlingEnd) {
      _handlingEnd = true;
      _game.triggerVictory(
        _gm.roundWinnerSide == 0 ? TeamSide.red : TeamSide.blue,
      );
      Future.delayed(const Duration(milliseconds: 800), _showRoundResult);
    }
    if (_gm.phase == GamePhase.gameOver && !_handlingEnd) {
      _handlingEnd = true;
      _game.triggerVictory(
        _gm.gameWinnerSide == 0 ? TeamSide.red : TeamSide.blue,
      );
      Future.delayed(const Duration(milliseconds: 1000), _showGameResult);
    }
    if (_gm.phase == GamePhase.activeTurn) {
      _handlingEnd = false;
    }

    if (mounted) setState(() {});
  }

  Future<void> _showRoundResult() async {
    if (!mounted) return;
    final goNext = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RoundResultScreen(
          roundWinnerRed: _gm.roundWinnerSide == 0,
          roundNumber: _gm.currentRound,
          redScore: _gm.red.roundsWon,
          blueScore: _gm.blue.roundsWon,
        ),
      ),
    );
    if (goNext == true && mounted) {
      _game.resetRound();
      _gm.nextRound();
    }
  }

  Future<void> _showGameResult() async {
    if (!mounted || _statsSaved) return;
    _statsSaved = true;
    await StorageService.recordGameResult(
      won: _gm.gameWinnerSide == 0,
      correctAnswers: _gm.correctAnswers,
      totalAnswers: _gm.totalAnswers,
    );
    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => GameResultScreen(
          redWins: _gm.red.roundsWon,
          blueWins: _gm.blue.roundsWon,
          gameWinnerRed: _gm.gameWinnerSide == 0,
        ),
      ),
    );
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _onNumberTap(String digit) {
    if (!_canPlayerAnswer) return;
    if (_answerController.text.length >= 5) return;
    setState(() => _answerController.text += digit);
    AudioService.tap();
  }

  void _onBackspace() {
    if (!_canPlayerAnswer) return;
    final t = _answerController.text;
    if (t.isEmpty) return;
    setState(() => _answerController.text = t.substring(0, t.length - 1));
    AudioService.tap();
  }

  void _onClear() {
    if (!_canPlayerAnswer) return;
    setState(() => _answerController.clear());
    AudioService.tap();
  }

  void _onSubmit() {
    if (!_canPlayerAnswer) return;
    if (_answerController.text.isEmpty) return;
    final v = int.tryParse(_answerController.text);
    if (v == null) return;
    _answerController.clear();
    _gm.submitAnswer(v);
  }

  void _onPause() {
    _gm.pause();
    Navigator.push(
      context,
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: false,
        barrierColor: AppColors.navy.withValues(alpha: 0.72),
        pageBuilder: (context, animation, secondaryAnimation) => PauseScreen(
          onResume: () {
            Navigator.pop(context);
            _gm.resume();
          },
          onRestart: () {
            Navigator.pop(context);
            setState(() {
              _game.resetRound();
            });
            _gm.startNewGame();
          },
          onHome: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTeam = _gm.activeTeam;
    final activeColor = activeTeam.isRed ? AppColors.red : AppColors.blue;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(activeColor),
            Expanded(child: _buildQuestionPanel(activeColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildArena() {
    final game = _game;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.panelBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.08),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(child: GameWidget(game: game)),
              Positioned(
                top: 4,
                left: 6,
                child: _teamMarker('ROUGE', AppColors.red),
              ),
              Positioned(
                top: 4,
                right: 46,
                child: _teamMarker(
                  _gm.isVsAI ? 'BLEU · IA' : 'BLEU',
                  AppColors.blue,
                ),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: IconButton(
                  icon: const Icon(
                    Icons.pause_circle_filled,
                    size: 32,
                    color: AppColors.navy,
                  ),
                  onPressed: _onPause,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color activeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.panelBorder)),
      ),
      child: Row(
        children: [
          _scoreChip('Rouge', _gm.red.roundsWon, AppColors.red),
          const Spacer(),
          Column(
            children: [
              Text(
                'Manche ${_gm.currentRound}',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                _gm.isRedTurn
                    ? 'Tour ROUGE'
                    : _gm.isVsAI
                    ? 'Tour de l’IA'
                    : 'Tour BLEU',
                style: TextStyle(
                  color: activeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          _scoreChip(
            _gm.isVsAI ? 'IA' : 'Bleu',
            _gm.blue.roundsWon,
            AppColors.blue,
          ),
        ],
      ),
    );
  }

  Widget _scoreChip(String name, int score, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        '$name $score',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _teamMarker(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A102348),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildQuestionPanel(Color activeColor) {
    final q = _gm.visibleQuestion;
    final inventory = _gm.isRedTurn ? _gm.redInventory : _gm.blueInventory;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 560;
        final spacing = compact ? 4.0 : 8.0;
        const reservedHeight = 286.0;
        final keyHeight = compact
            ? ((constraints.maxHeight - reservedHeight) / 4)
                  .clamp(24.0, 44.0)
                  .toDouble()
            : 40.0;
        return Container(
          padding: EdgeInsets.fromLTRB(12, compact ? 5 : 10, 12, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(top: BorderSide(color: AppColors.panelBorder)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x140D2444),
                blurRadius: 10,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calculate_rounded,
                    color: AppColors.navy,
                    size: compact ? 16 : 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'QUESTION & CALCUL',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: compact ? 11 : 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _isAiThinking ? 'TOUR DE L’IA' : 'À TON TOUR',
                    style: TextStyle(
                      color: _isAiThinking ? AppColors.blue : activeColor,
                      fontSize: compact ? 9 : 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 3 : 6),
              Expanded(child: _buildArena()),
              SizedBox(height: spacing),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _gm.maxTime == 0
                          ? 0
                          : (_gm.timeLeft / _gm.maxTime).clamp(0.0, 1.0),
                      minHeight: compact ? 6 : 8,
                      backgroundColor: Colors.black12,
                      valueColor: AlwaysStoppedAnimation(activeColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_gm.timeLeft.toStringAsFixed(1)}s',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('♥ ${_gm.attemptsLeft}'),
                ],
              ),
              SizedBox(height: spacing),
              Container(
                width: double.infinity,
                height: compact ? 30 : 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.bgBottom.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.panelBorder),
                ),
                child: inventory.isEmpty
                    ? Text(
                        'Aucun bonus',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: compact ? 9 : 11,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: inventory.items
                              .map(
                                (powerUp) => _buildPowerUpIcon(
                                  powerUp,
                                  compact: compact,
                                ),
                              )
                              .toList(),
                        ),
                      ),
              ),
              SizedBox(height: spacing),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: compact ? 4 : 7),
                decoration: BoxDecoration(
                  color: AppColors.bgTop,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.panelBorder),
                ),
                child: Text(
                  q?.expression ?? '—',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: compact ? 23 : 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(height: spacing),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: compact ? 6 : 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bgTop,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: activeColor, width: 2),
                      ),
                      child: Text(
                        _answerController.text.isEmpty
                            ? _isAiThinking
                                  ? 'L’IA réfléchit…'
                                  : 'Ta réponse'
                            : _answerController.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _canPlayerAnswer
                              ? AppColors.navy
                              : AppColors.blueDark,
                          fontSize: compact ? 18 : 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: compact ? 76 : 96,
                    height: compact ? 38 : 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activeColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _canPlayerAnswer ? _onSubmit : null,
                      child: Text(
                        compact ? 'OK' : 'VALIDER',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(compact ? 3 : 4),
                decoration: BoxDecoration(
                  color: AppColors.bgBottom.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.panelBorder),
                ),
                child: _buildKeypad(activeColor, keyHeight),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPowerUpIcon(PowerUp powerUp, {bool compact = false}) {
    final icon = switch (powerUp.type) {
      PowerUpType.doublePoints => Icons.bolt_rounded,
      PowerUpType.timeTheft => Icons.timer_rounded,
      PowerUpType.illusion => Icons.visibility_off_rounded,
      PowerUpType.autoAnswer => Icons.auto_awesome_rounded,
      PowerUpType.extraAttempt => Icons.favorite_rounded,
      PowerUpType.ropeFreeze => Icons.ac_unit_rounded,
    };
    final enabled = _canPlayerAnswer;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: powerUp.name,
        child: Semantics(
          button: true,
          label: 'Utiliser le bonus ${powerUp.name}',
          child: SizedBox(
            width: compact ? 34 : 48,
            height: compact ? 34 : 48,
            child: InkWell(
              onTap: enabled ? () => _gm.usePowerUp(powerUp) : null,
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: Container(
                  width: compact ? 28 : 38,
                  height: compact ? 28 : 38,
                  decoration: BoxDecoration(
                    color: enabled
                        ? AppColors.yellow.withValues(alpha: 0.28)
                        : AppColors.bgBottom,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: enabled ? AppColors.yellow : AppColors.panelBorder,
                      width: 2,
                    ),
                    boxShadow: enabled
                        ? const [
                            BoxShadow(
                              color: Color(0x1A102348),
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    size: compact ? 16 : 20,
                    color: enabled ? AppColors.navy : AppColors.muted,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad(Color activeColor, double keyHeight) {
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['C', '0', '⌫'],
    ];
    return Column(
      children: rows.map((r) {
        return Row(
          children: r.map((label) {
            final isAction = label == 'C' || label == '⌫';
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: SizedBox(
                  height: keyHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAction
                          ? AppColors.bgBottom
                          : Colors.white,
                      foregroundColor: AppColors.navy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.panelBorder),
                      ),
                      elevation: 1,
                    ),
                    onPressed: _canPlayerAnswer
                        ? () {
                            if (label == 'C') {
                              _onClear();
                            } else if (label == '⌫') {
                              _onBackspace();
                            } else {
                              _onNumberTap(label);
                            }
                          }
                        : null,
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
