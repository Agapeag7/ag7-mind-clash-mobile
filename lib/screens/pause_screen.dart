import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/game_ui.dart';

class PauseScreen extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const PauseScreen({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: GamePanel(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.pause_circle_filled_rounded,
                    color: AppColors.blue,
                    size: 52,
                  ),
                  const SizedBox(height: 8),
                  const GamePageHeading(title: 'Pause'),
                  const SizedBox(height: 22),
                  GameActionButton(
                    label: 'REPRENDRE',
                    color: AppColors.green,
                    icon: Icons.play_arrow_rounded,
                    onPressed: onResume,
                  ),
                  const SizedBox(height: 10),
                  GameActionButton(
                    label: 'RECOMMENCER',
                    color: AppColors.blue,
                    icon: Icons.refresh_rounded,
                    onPressed: onRestart,
                  ),
                  const SizedBox(height: 10),
                  GameActionButton(
                    label: 'ACCUEIL',
                    color: Colors.white,
                    foregroundColor: AppColors.navy,
                    icon: Icons.home_rounded,
                    onPressed: onHome,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
