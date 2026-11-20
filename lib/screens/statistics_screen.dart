import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../core/difficulty.dart';
import '../providers/app_providers.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../widgets/game_ui.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    return AudioPageMusic(
      tracks: const ['bgm/music-page-statistique.mp3'],
      child: Scaffold(
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
              const SizedBox(height: 18),
              const GamePageHeading(
                title: 'Par difficulté',
                subtitle: 'Tes résultats pour chacun des six niveaux',
              ),
              const SizedBox(height: 10),
              for (final difficulty in DifficultyConfig.all)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DifficultyStats(
                    difficulty: difficulty,
                    values: Map<String, dynamic>.from(
                      (values['byDifficulty']
                          as Map<String, dynamic>)[
                        '${difficulty.level}'
                      ] as Map<String, dynamic>,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _confirmReset(context, ref),
                icon: const Icon(Icons.delete_sweep_rounded),
                label: const Text('Réinitialiser les statistiques'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.red,
                  side: BorderSide(color: AppColors.red.withValues(alpha: 0.6)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser les statistiques ?'),
        content: const Text(
          'Toutes les statistiques générales et par difficulté seront effacées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await StorageService.resetStats();
      ref.invalidate(statsProvider);
    } on Exception catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de réinitialiser : $error')),
        );
      }
    }
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

class _DifficultyStats extends StatelessWidget {
  final DifficultyConfig difficulty;
  final Map<String, dynamic> values;

  const _DifficultyStats({required this.difficulty, required this.values});

  @override
  Widget build(BuildContext context) {
    final answers = (values['totalAnswers'] as num).toInt();
    final correct = (values['correctAnswers'] as num).toInt();
    final accuracy = answers == 0 ? 0 : (correct * 100 / answers).round();

    return GamePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.blue.withValues(alpha: 0.12),
                child: Text(
                  '${difficulty.level}',
                  style: const TextStyle(
                    color: AppColors.blueDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  difficulty.name,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${values['gamesPlayed']} parties',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _Metric(label: 'Victoires', value: '${values['wins']}'),
              _Metric(label: 'Défaites', value: '${values['losses']}'),
              _Metric(label: 'Réussite', value: '$accuracy %'),
              _Metric(
                label: 'Réponses justes',
                value: '$correct / $answers',
              ),
              _Metric(label: 'Meilleure série', value: '${values['bestWinStreak']}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: const TextStyle(color: AppColors.muted, fontSize: 12),
        children: [
          TextSpan(text: '$label : '),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
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
