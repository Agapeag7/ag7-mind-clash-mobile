import 'package:flutter/material.dart';
import '../core/constants.dart';

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
    return Scaffold(
      body: Container(
        color: roundWinnerRed ? AppColors.red : AppColors.blue,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Manche $roundNumber',
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 12),
              Text(
                roundWinnerRed ? 'ROUGE gagne !' : 'BLEU gagne !',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Score : $redScore — $blueScore',
                style: const TextStyle(color: Colors.white, fontSize: 22),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continuer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}