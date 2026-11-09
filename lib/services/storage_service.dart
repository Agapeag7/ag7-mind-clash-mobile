import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _kMusic = 'music_enabled';
  static const _kSfx = 'sfx_enabled';
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

  static Future<String> getLanguage() async =>
      (await _p).getString(_kLang) ?? 'fr';
  static Future<void> setLanguage(String v) async =>
      (await _p).setString(_kLang, v);

  // ----- Stats -----
  static Future<Map<String, dynamic>> getStats() async {
    final raw = (await _p).getString(_kStats);
    if (raw == null) return _emptyStats();
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return _emptyStats();
    }
  }

  static Future<void> saveStats(Map<String, dynamic> stats) async {
    await (await _p).setString(_kStats, jsonEncode(stats));
  }

  static Map<String, dynamic> _emptyStats() => {
        'gamesPlayed': 0,
        'wins': 0,
        'losses': 0,
        'correctAnswers': 0,
        'totalAnswers': 0,
        'bestWinStreak': 0,
      };
}