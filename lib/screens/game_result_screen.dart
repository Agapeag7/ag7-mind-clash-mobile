import 'package:flutter/material.dart';
import '../core/constants.dart';
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
    return Scaffold(
      body: Container(
        color: gameWinnerRed ? AppColors.red : AppColors.blue,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 96, color: AppColors.yellow),
              const SizedBox(height: 16),
              Text(
                gameWinnerRed ? 'VICTOIRE ROUGE' : 'VICTOIRE BLEUE',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$redWins — $blueWins',
                style: const TextStyle(
                    color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (_) => false,
                  );
                },
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}