import 'package:flutter/material.dart';
import '../core/difficulty.dart';
import '../core/enums.dart';
import 'game_screen.dart';

class DifficultySelectionScreen extends StatelessWidget {
  final GameMode mode;
  const DifficultySelectionScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choisir une difficulté')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: DifficultyConfig.all.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final c = DifficultyConfig.all[i];
          return Card(
            child: ListTile(
              title: Text(
                'Niveau ${c.level} — ${c.name}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(c.description),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GameScreen(
                    mode: mode,
                    difficulty: c.level,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}