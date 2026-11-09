import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/difficulty.dart';
import '../core/enums.dart';
import '../game/ag7_game.dart';
import '../game/game_manager.dart';
import '../models/power_up.dart';
import '../services/audio_service.dart';
import 'game_result_screen.dart';
import 'pause_screen.dart';
import 'round_result_screen.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;
  final int difficulty;

  const GameScreen({
    super.key,
    required this.mode,
    required this.difficulty,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameManager _gm;
  late final Ag7Game _game;
  final TextEditingController _answerController = TextEditingController();
  double _lastRope = 0;
  bool _handlingEnd = false;

  @override
  void initState() {
    super.initState();
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
    _gm.removeListener(_onManagerChanged);
    _gm.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _onManagerChanged() {
    final rope = _gm.ropePosition;
    AnimationState? redReaction;
    AnimationState? blueReaction;
    if (rope < _lastRope - 0.05) {
      redReaction = AnimationState.strongPull;
      blueReaction = AnimationState.slip;
    } else if (rope > _lastRope + 0.05) {
      blueReaction = AnimationState.strongPull;
      redReaction = AnimationState.slip;
    } else if (_gm.phase == GamePhase.activeTurn && !_gm.isRedTurn) {
      // L'adversaire tire
      blueReaction = null;
      redReaction = null;
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
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameResultScreen(
          redWins: _gm.red.roundsWon,
          blueWins: _gm.blue.roundsWon,
          gameWinnerRed: _gm.gameWinnerSide == 0,
        ),
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  void _onNumberTap(String digit) {
    if (_gm.phase != GamePhase.activeTurn) return;
    if (_answerController.text.length >= 5) return;
    setState(() => _answerController.text += digit);
    AudioService.tap();
  }

  void _onBackspace() {
    final t = _answerController.text;
    if (t.isEmpty) return;
    setState(() =>
        _answerController.text = t.substring(0, t.length - 1));
    AudioService.tap();
  }

  void _onClear() {
    setState(() => _answerController.clear());
    AudioService.tap();
  }

  void _onSubmit() {
    if (_gm.phase != GamePhase.activeTurn) return;
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
      MaterialPageRoute(
        builder: (_) => PauseScreen(
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
      ),
    );
  }

  Future<void> _showPowerUpDialog() async {
    if (_gm.phase != GamePhase.activeTurn) return;
    final inv = _gm.isRedTurn ? _gm.redInventory : _gm.blueInventory;
    if (inv.isEmpty) return;
    final chosen = await showDialog<PowerUp>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Inventaire'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: inv.items
              .map(
                (p) => ListTile(
                  title: Text(p.name),
                  subtitle: Text(p.description),
                  onTap: () => Navigator.pop(context, p),
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
    if (chosen != null) {
      _gm.usePowerUp(chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTeam = _gm.activeTeam;
    final activeColor =
        activeTeam.isRed ? AppColors.red : AppColors.blue;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(activeColor),
            Expanded(
              child: Stack(
                children: [
                  GameWidget(game: _game),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.pause_circle_filled,
                          size: 40, color: Colors.white),
                      onPressed: _onPause,
                    ),
                  ),
                ],
              ),
            ),
            _buildQuestionPanel(activeColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color activeColor) {
    return Container(
      color: activeColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _scoreChip('Rouge', _gm.red.roundsWon, AppColors.red),
          const Spacer(),
          Column(
            children: [
              Text(
                'Manche ${_gm.currentRound}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
              Text(
                _gm.isRedTurn ? 'Tour ROUGE' : 'Tour BLEU',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          _scoreChip('Bleu', _gm.blue.roundsWon, AppColors.blue),
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
            color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildQuestionPanel(Color activeColor) {
    final q = _gm.question;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      color: Colors.black.withValues(alpha: 0.04),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: _gm.maxTime == 0
                      ? 0
                      : (_gm.timeLeft / _gm.maxTime).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.black12,
                  valueColor: AlwaysStoppedAnimation(activeColor),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_gm.timeLeft.toStringAsFixed(1)}s',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              Text('♥ ${_gm.attemptsLeft}'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            q?.expression ?? '—',
            style: const TextStyle(
                fontSize: 32, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: activeColor, width: 2),
            ),
            child: Text(
              _answerController.text.isEmpty ? '…' : _answerController.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          _buildKeypad(activeColor),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _gm.phase == GamePhase.activeTurn
                      ? _showPowerUpDialog
                      : null,
                  icon: const Icon(Icons.card_giftcard),
                  label: const Text('Bonus'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _gm.phase == GamePhase.activeTurn
                      ? _onSubmit
                      : null,
                  child: const Text('VALIDER'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad(Color activeColor) {
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
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAction
                          ? Colors.grey.shade300
                          : Colors.white,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 1,
                    ),
                    onPressed: _gm.phase == GamePhase.activeTurn
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
                          fontSize: 18, fontWeight: FontWeight.w700),
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