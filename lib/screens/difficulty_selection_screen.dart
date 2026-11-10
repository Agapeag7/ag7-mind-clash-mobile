import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/difficulty.dart';
import '../core/enums.dart';
import '../widgets/game_ui.dart';
import 'game_screen.dart';

class DifficultySelectionScreen extends StatelessWidget {
  final GameMode mode;

  const DifficultySelectionScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choisis ta difficulté')),
      body: GamePageBackground(
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: GamePageHeading(
                  title: 'Quel est ton niveau ?',
                  subtitle: 'Tu pourras toujours relever le défi',
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: DifficultyConfig.all.length,
                  itemBuilder: (context, index) {
                    final difficulty = DifficultyConfig.all[index];
                    return _DifficultyCard(
                      difficulty: difficulty,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameScreen(
                            mode: mode,
                            difficulty: difficulty.level,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final DifficultyConfig difficulty;
  final VoidCallback onTap;

  const _DifficultyCard({required this.difficulty, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = difficulty.level <= 2
        ? AppColors.green
        : difficulty.level <= 4
            ? AppColors.yellow
            : AppColors.red;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: GamePanel(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${difficulty.level}',
                  style: TextStyle(
                    color: color == AppColors.yellow
                        ? AppColors.navy
                        : color,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                difficulty.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                difficulty.description,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  height: 1.15,
                ),
              ),
              const Spacer(),
              Text(
                '${difficulty.secondsPerQuestion.toInt()} s / question',
                style: const TextStyle(
                  color: AppColors.blueDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
