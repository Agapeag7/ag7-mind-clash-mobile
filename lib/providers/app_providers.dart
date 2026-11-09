import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettings {
  final bool musicEnabled;
  final bool sfxEnabled;
  final String language;

  const AppSettings({
    this.musicEnabled = true,
    this.sfxEnabled = true,
    this.language = 'fr',
  });

  AppSettings copyWith({
    bool? musicEnabled,
    bool? sfxEnabled,
    String? language,
  }) =>
      AppSettings(
        musicEnabled: musicEnabled ?? this.musicEnabled,
        sfxEnabled: sfxEnabled ?? this.sfxEnabled,
        language: language ?? this.language,
      );
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings());

  void setMusic(bool v) => state = state.copyWith(musicEnabled: v);
  void setSfx(bool v) => state = state.copyWith(sfxEnabled: v);
  void setLanguage(String v) => state = state.copyWith(language: v);
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>(
  (ref) => AppSettingsNotifier(),
);

final statsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return {
    'gamesPlayed': 0,
    'wins': 0,
    'losses': 0,
    'correctAnswers': 0,
    'totalAnswers': 0,
    'bestWinStreak': 0,
  };
});