import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../providers/app_providers.dart';
import '../widgets/game_ui.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mes statistiques')),
      body: GamePageBackground(
        child: stats.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.blue),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Impossible de charger les statistiques : $error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (values) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const GamePageHeading(
                title: 'Tes performances',
                subtitle: 'Chaque calcul te fait progresser !',
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Parties jouées',
                      value: '${values['gamesPlayed']}',
                      icon: Icons.sports_esports_rounded,
                      color: AppColors.blue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'Victoires',
                      value: '${values['wins']}',
                      icon: Icons.emoji_events_rounded,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'Défaites',
                      value: '${values['losses']}',
                      icon: Icons.trending_up_rounded,
                      color: AppColors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GamePanel(
                child: Column(
                  children: [
                    _statRow(
                      'Réponses correctes',
                      '${values['correctAnswers']}',
                      Icons.check_circle_rounded,
                    ),
                    const Divider(height: 24),
                    _statRow(
                      'Réponses totales',
                      '${values['totalAnswers']}',
                      Icons.calculate_rounded,
                    ),
                    const Divider(height: 24),
                    _statRow(
                      'Meilleure série',
                      '${values['bestWinStreak']}',
                      Icons.local_fire_department_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.blue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: const TextStyle(color: AppColors.muted)),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GamePanel(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Column(
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
