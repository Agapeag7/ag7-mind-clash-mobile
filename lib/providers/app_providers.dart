import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/audio_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class AppSettings {
  final bool musicEnabled;
  final bool sfxEnabled;
  final bool remindersEnabled;
  final String language;

  const AppSettings({
    this.musicEnabled = true,
    this.sfxEnabled = true,
    this.remindersEnabled = true,
    this.language = 'fr',
  });

  AppSettings copyWith({
    bool? musicEnabled,
    bool? sfxEnabled,
    bool? remindersEnabled,
    String? language,
  }) => AppSettings(
    musicEnabled: musicEnabled ?? this.musicEnabled,
    sfxEnabled: sfxEnabled ?? this.sfxEnabled,
    remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    language: language ?? this.language,
  );
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier()
    : super(
        AppSettings(
          musicEnabled: AudioService.musicEnabled,
          sfxEnabled: AudioService.sfxEnabled,
          remindersEnabled: NotificationService.remindersEnabled,
        ),
      );

  void setMusic(bool v) => state = state.copyWith(musicEnabled: v);
  void setSfx(bool v) => state = state.copyWith(sfxEnabled: v);
  void setReminders(bool v) => state = state.copyWith(remindersEnabled: v);
  void setLanguage(String v) => state = state.copyWith(language: v);
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>(
      (ref) => AppSettingsNotifier(),
    );

final statsProvider = FutureProvider.autoDispose<Map<String, dynamic>>(
  (ref) => StorageService.getStats(),
);
