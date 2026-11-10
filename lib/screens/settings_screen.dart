import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../providers/app_providers.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../widgets/game_ui.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: GamePageBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const GamePageHeading(
              title: 'Personnalise ta partie',
              subtitle: 'Ajuste le jeu selon tes envies',
            ),
            const SizedBox(height: 18),
            GamePanel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(
                      Icons.music_note_rounded,
                      color: AppColors.blue,
                    ),
                    title: const Text(
                      'Musique',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    value: settings.musicEnabled,
                    activeThumbColor: AppColors.green,
                    onChanged: (value) {
                      notifier.setMusic(value);
                      StorageService.setMusicEnabled(value);
                      AudioService.musicEnabled = value;
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    secondary: const Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.blue,
                    ),
                    title: const Text(
                      'Effets sonores',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    value: settings.sfxEnabled,
                    activeThumbColor: AppColors.green,
                    onChanged: (value) {
                      notifier.setSfx(value);
                      StorageService.setSfxEnabled(value);
                      AudioService.sfxEnabled = value;
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(
                      Icons.language_rounded,
                      color: AppColors.blue,
                    ),
                    title: const Text(
                      'Langue',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    trailing: DropdownButton<String>(
                      value: settings.language,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: 'fr', child: Text('Français')),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          notifier.setLanguage(value);
                          StorageService.setLanguage(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
