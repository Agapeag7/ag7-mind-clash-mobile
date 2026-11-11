import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/power_up.dart';
import '../widgets/game_ui.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comment jouer ?')),
      body: GamePageBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const GamePageHeading(
              title: 'Les règles du duel',
              subtitle: 'Prêt à tirer la corde vers ton équipe ?',
            ),
            const SizedBox(height: 16),
            const _InstructionStep(
              number: 1,
              icon: Icons.groups_rounded,
              text: 'Deux équipes s’affrontent autour de la corde.',
            ),
            const _InstructionStep(
              number: 2,
              icon: Icons.calculate_rounded,
              text: 'À ton tour, résous le calcul avant la fin du chrono.',
            ),
            const _InstructionStep(
              number: 3,
              icon: Icons.check_circle_rounded,
              text: 'Une bonne réponse fait avancer la corde vers ton équipe.',
            ),
            const _InstructionStep(
              number: 4,
              icon: Icons.timer_off_rounded,
              text: 'Tu as deux tentatives. Si le chrono s’écoule ou si elles échouent, la corde avance vers l’adversaire.',
            ),
            const _InstructionStep(
              number: 5,
              icon: Icons.flag_rounded,
              text: 'Amène la corde à la limite pour remporter la manche.',
            ),
            const _InstructionStep(
              number: 6,
              icon: Icons.emoji_events_rounded,
              text: 'La première équipe à gagner trois manches remporte la partie.',
            ),
            const SizedBox(height: 18),
            const GamePageHeading(
              title: 'Les bonus',
              subtitle: 'Utilise-les au bon moment pour prendre l’avantage.',
            ),
            const SizedBox(height: 12),
            GamePanel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < PowerUp.catalog.length;
                    index++
                  ) ...[
                    _BonusTile(powerUp: PowerUp.catalog[index]),
                    if (index < PowerUp.catalog.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final int number;
  final IconData icon;
  final String text;

  const _InstructionStep({
    required this.number,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GamePanel(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.navy,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(icon, color: AppColors.blue, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BonusTile extends StatelessWidget {
  final PowerUp powerUp;

  const _BonusTile({required this.powerUp});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.yellow.withValues(alpha: 0.22),
        child: Icon(_iconFor(powerUp.type), color: AppColors.navy),
      ),
      title: Text(
        powerUp.name,
        style: const TextStyle(
          color: AppColors.navy,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(powerUp.description),
    );
  }

  IconData _iconFor(PowerUpType type) => switch (type) {
    PowerUpType.doublePoints => Icons.bolt_rounded,
    PowerUpType.timeTheft => Icons.timer_rounded,
    PowerUpType.illusion => Icons.visibility_off_rounded,
    PowerUpType.autoAnswer => Icons.auto_awesome_rounded,
    PowerUpType.extraAttempt => Icons.favorite_rounded,
    PowerUpType.ropeFreeze => Icons.ac_unit_rounded,
  };
}
