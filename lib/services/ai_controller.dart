import 'dart:async';
import 'dart:math';
import '../core/difficulty.dart';
import '../models/question.dart';

class AIController {
  final DifficultyConfig config;
  final Random _rng = Random();

  AIController(this.config);

  Future<int> think(Question q) async {
    final delay = config.aiMinDelay +
        _rng.nextDouble() * (config.aiMaxDelay - config.aiMinDelay);
    await Future.delayed(Duration(milliseconds: (delay * 1000).round()));
    if (_rng.nextDouble() < config.aiAccuracy) {
      return q.correctAnswer;
    }
    final offset = _rng.nextBool() ? 1 : -1;
    return q.correctAnswer + offset * (1 + _rng.nextInt(3));
  }
}