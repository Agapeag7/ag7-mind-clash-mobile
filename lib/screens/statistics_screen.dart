import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: stats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (s) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _row('Parties jouées', '${s['gamesPlayed']}'),
            _row('Victoires', '${s['wins']}'),
            _row('Défaites', '${s['losses']}'),
            _row('Réponses correctes', '${s['correctAnswers']}'),
            _row('Réponses totales', '${s['totalAnswers']}'),
            _row('Meilleure série', '${s['bestWinStreak']}'),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
    );
  }
}