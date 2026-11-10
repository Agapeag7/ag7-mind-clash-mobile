import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/enums.dart';
import '../widgets/game_ui.dart';
import 'difficulty_selection_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choisis ton mode')),
      body: GamePageBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: [
                    const GamePageHeading(
                      title: 'À toi de jouer !',
                      subtitle: 'Choisis ton adversaire',
                    ),
                    const SizedBox(height: 22),
                    _ModeCard(
                      title: 'JOUEUR VS JOUEUR',
                      subtitle: 'Défie un ami sur le même appareil',
                      includeRobot: false,
                      onTap: () =>
                          _goToDifficulty(context, GameMode.playerVsPlayer),
                    ),
                    const SizedBox(height: 16),
                    _ModeCard(
                      title: 'JOUEUR VS IA',
                      subtitle: 'Affronte notre robot calculateur',
                      includeRobot: true,
                      onTap: () =>
                          _goToDifficulty(context, GameMode.playerVsAI),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goToDifficulty(BuildContext context, GameMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DifficultySelectionScreen(mode: mode),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool includeRobot;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.includeRobot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: GamePanel(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
          child: Column(
            children: [
              GameCharacterPair(height: 128, includeRobot: includeRobot),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
