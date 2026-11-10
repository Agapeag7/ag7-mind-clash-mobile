import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/game_ui.dart';

class RoundResultScreen extends StatelessWidget {
  final bool roundWinnerRed;
  final int roundNumber;
  final int redScore;
  final int blueScore;

  const RoundResultScreen({
    super.key,
    required this.roundWinnerRed,
    required this.roundNumber,
    required this.redScore,
    required this.blueScore,
  });

  @override
  Widget build(BuildContext context) {
    final winner = roundWinnerRed ? 'ROUGE' : 'BLEU';
    final winnerColor = roundWinnerRed ? AppColors.red : AppColors.blue;

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
                      Text(
                        'MANCHE $roundNumber',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'MANCHE REMPORTÉE !',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Par l’équipe $winner',
                        style: TextStyle(
                          color: winnerColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Image.asset(
                        roundWinnerRed
                            ? 'assets/images/characters/red/red_pnj_victory.png'
                            : 'assets/images/characters/blue/blue_pnj_victory.png',
                        height: 160,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.bgTop,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'SCORE DES MANCHES',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ROUGE  $redScore   -   $blueScore  BLEU',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.navy,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      GameActionButton(
                        label: 'MANCHE SUIVANTE',
                        color: AppColors.green,
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () => Navigator.pop(context, true),
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
