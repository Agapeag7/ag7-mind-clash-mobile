import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../services/audio_service.dart';
import '../widgets/game_ui.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AudioPageMusic(
      tracks: const ['bgm/theme-music-page-a-propos.mp3'],
      child: Scaffold(
        appBar: AppBar(title: const Text('À propos')),
        body: GamePageBackground(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: GamePanel(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/icon/icone_ag7mindclash.png',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'AG7 Mind Clash',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Le duel de calcul où chaque seconde compte ! '
                        'Défie un ami ou l’intelligence artificielle, '
                        'progresse à ton rythme et tire ton équipe vers la victoire.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Text(
                        'Développeur',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Agape Ag7',
                        style: TextStyle(
                          color: AppColors.blueDark,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
