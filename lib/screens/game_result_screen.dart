import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/game_ui.dart';
import 'home_screen.dart';

class GameResultScreen extends StatelessWidget {
  final int redWins;
  final int blueWins;
  final bool gameWinnerRed;

  const GameResultScreen({
    super.key,
    required this.redWins,
    required this.blueWins,
    required this.gameWinnerRed,
  });

  @override
  Widget build(BuildContext context) {
    final winner = gameWinnerRed ? 'ROUGE' : 'BLEU';
    final winnerColor = gameWinnerRed ? AppColors.red : AppColors.blue;

    return Scaffold(
      body: GamePageBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: GamePanel(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.celebration_rounded,
                        color: AppColors.yellow,
                        size: 60,
                      ),
                      const SizedBox(height: 8),
                      const GamePageHeading(title: 'Victoire !'),
                      Text(
                        'Équipe $winner',
                        style: TextStyle(
                          color: winnerColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Image.asset(
                        gameWinnerRed
                            ? 'assets/images/characters/red/red_pnj_victory.png'
                            : 'assets/images/characters/blue/blue_pnj_victory.png',
                        height: 190,
                        fit: BoxFit.contain,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.bgTop,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'SCORE FINAL',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '$redWins  -  $blueWins',
                              style: const TextStyle(
                                color: AppColors.navy,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      GameActionButton(
                        label: 'ACCUEIL',
                        color: AppColors.blue,
                        icon: Icons.home_rounded,
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                            (_) => false,
                          );
                        },
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
