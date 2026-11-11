import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/game_ui.dart';
import 'how_to_play_screen.dart';
import 'mode_selection_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GamePageBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/icon/icone_ag7mindclash.png',
                      width: 178,
                      height: 178,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'AG7',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const Text(
                      'MIND CLASH',
                      style: TextStyle(
                        color: AppColors.blueDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Le duel de calcul où chaque seconde compte !',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted, fontSize: 14),
                    ),
                    const SizedBox(height: 28),
                    GameActionButton(
                      label: 'JOUER',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ModeSelectionScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GameActionButton(
                      label: 'STATISTIQUES',
                      color: AppColors.blue,
                      icon: Icons.bar_chart_rounded,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StatisticsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GameActionButton(
                      label: 'PARAMÈTRES',
                      color: Colors.white,
                      foregroundColor: AppColors.navy,
                      icon: Icons.settings_rounded,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GameActionButton(
                      label: 'COMMENT JOUER',
                      color: Colors.white,
                      foregroundColor: AppColors.navy,
                      icon: Icons.help_outline_rounded,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HowToPlayScreen(),
                        ),
                      ),
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
}
