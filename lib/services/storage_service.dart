import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/difficulty.dart';

class StorageService {
  static const _kMusic = 'music_enabled';
  static const _kSfx = 'sfx_enabled';
  static const _kReminders = 'reminders_enabled';
  static const _kLang = 'lang';
  static const _kStats = 'stats_json';

  static Future<void> init() async {}

  static Future<SharedPreferences> get _p => SharedPreferences.getInstance();

  // ----- Settings -----
  static Future<bool> getMusicEnabled() async =>
      (await _p).getBool(_kMusic) ?? true;
  static Future<void> setMusicEnabled(bool v) async =>
      (await _p).setBool(_kMusic, v);

  static Future<bool> getSfxEnabled() async =>
      (await _p).getBool(_kSfx) ?? true;
  static Future<void> setSfxEnabled(bool v) async =>
      (await _p).setBool(_kSfx, v);

  static Future<bool> getRemindersEnabled() async =>
      (await _p).getBool(_kReminders) ?? true;
  static Future<void> setRemindersEnabled(bool v) async =>
      (await _p).setBool(_kReminders, v);

  static Future<String> getLanguage() async =>
      (await _p).getString(_kLang) ?? 'fr';
  static Future<void> setLanguage(String v) async =>
      (await _p).setString(_kLang, v);

  // ----- Stats -----
  static Future<Map<String, dynamic>> getStats() async {
    final raw = (await _p).getString(_kStats);
    if (raw == null) return _emptyStats();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final stats = {..._emptyStats(), ...decoded};
        final storedByDifficulty = decoded['byDifficulty'];
        if (storedByDifficulty is Map) {
          final defaults = _emptyStats()['byDifficulty'] as Map<String, dynamic>;
          stats['byDifficulty'] = {
            ...defaults,
            for (final entry in storedByDifficulty.entries)
              if (entry.key is String && entry.value is Map)
                entry.key as String: {
                  ..._emptyDifficultyStats(),
                  ...(entry.value as Map).map(
                    (key, value) => MapEntry(key.toString(), value),
                  ),
                },
          };
        }
        return stats;
      }
      return _emptyStats();
    } on FormatException {
      return _emptyStats();
    }
  }

  static Future<void> saveStats(Map<String, dynamic> stats) async {
    await (await _p).setString(_kStats, jsonEncode(stats));
  }

  static Future<void> recordGameResult({
    required bool won,
    required int correctAnswers,
    required int totalAnswers,
    required int difficulty,
  }) async {
    final stats = await getStats();
    _recordResult(stats, won, correctAnswers, totalAnswers);

    final byDifficulty = Map<String, dynamic>.from(
      stats['byDifficulty'] as Map<String, dynamic>,
    );
    final levelStats = Map<String, dynamic>.from(
      byDifficulty['$difficulty'] as Map<String, dynamic>,
    );
    _recordResult(levelStats, won, correctAnswers, totalAnswers);
    byDifficulty['$difficulty'] = levelStats;
    stats['byDifficulty'] = byDifficulty;

    await saveStats(stats);
  }

  static Future<void> resetStats() async {
    await (await _p).remove(_kStats);
  }

  static void _recordResult(
    Map<String, dynamic> stats,
    bool won,
    int correctAnswers,
    int totalAnswers,
  ) {
    stats['gamesPlayed'] = _count(stats['gamesPlayed']) + 1;
    stats['correctAnswers'] = _count(stats['correctAnswers']) + correctAnswers;
    stats['totalAnswers'] = _count(stats['totalAnswers']) + totalAnswers;

    final currentStreak = won ? _count(stats['currentWinStreak']) + 1 : 0;
    stats['currentWinStreak'] = currentStreak;
    if (won) {
      stats['wins'] = _count(stats['wins']) + 1;
      final bestStreak = _count(stats['bestWinStreak']);
      stats['bestWinStreak'] = currentStreak > bestStreak
          ? currentStreak
          : bestStreak;
    } else {
      stats['losses'] = _count(stats['losses']) + 1;
    }
  }

  static int _count(Object? value) => value is num ? value.toInt() : 0;

  static Map<String, dynamic> _emptyDifficultyStats() => {
    'gamesPlayed': 0,
    'wins': 0,
    'losses': 0,
    'correctAnswers': 0,
    'totalAnswers': 0,
    'bestWinStreak': 0,
    'currentWinStreak': 0,
  };

  static Map<String, dynamic> _emptyStats() => {
    ..._emptyDifficultyStats(),
    'byDifficulty': {
      for (final difficulty in DifficultyConfig.all)
        '${difficulty.level}': _emptyDifficultyStats(),
    },
  };
}
