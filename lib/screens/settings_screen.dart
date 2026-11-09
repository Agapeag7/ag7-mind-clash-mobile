import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Musique'),
            value: settings.musicEnabled,
            onChanged: (v) {
              notifier.setMusic(v);
              StorageService.setMusicEnabled(v);
              AudioService.musicEnabled = v;
            },
          ),
          SwitchListTile(
            title: const Text('Effets sonores'),
            value: settings.sfxEnabled,
            onChanged: (v) {
              notifier.setSfx(v);
              StorageService.setSfxEnabled(v);
              AudioService.sfxEnabled = v;
            },
          ),
          ListTile(
            title: const Text('Langue'),
            subtitle: Text(settings.language.toUpperCase()),
            trailing: DropdownButton<String>(
              value: settings.language,
              items: const [
                DropdownMenuItem(value: 'fr', child: Text('Français')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (v) {
                if (v != null) {
                  notifier.setLanguage(v);
                  StorageService.setLanguage(v);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}