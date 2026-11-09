enum PowerUpType {
  doublePoints,
  timeFreeze,
  shield,
  autoAnswer,
  extraAttempt,
  ropeFreeze,
}

class PowerUp {
  final PowerUpType type;
  final String name;
  final String description;

  const PowerUp({
    required this.type,
    required this.name,
    required this.description,
  });

  static const List<PowerUp> catalog = [
    PowerUp(
      type: PowerUpType.doublePoints,
      name: 'Double Points',
      description: 'La prochaine bonne réponse déplace la corde de 2.',
    ),
    PowerUp(
      type: PowerUpType.timeFreeze,
      name: 'Gel du temps',
      description: 'Fige le chrono adverse pendant 5 secondes.',
    ),
    PowerUp(
      type: PowerUpType.shield,
      name: 'Bouclier',
      description: 'Annule une mauvaise réponse.',
    ),
    PowerUp(
      type: PowerUpType.autoAnswer,
      name: 'Réponse auto',
      description: 'Affiche la bonne réponse.',
    ),
    PowerUp(
      type: PowerUpType.extraAttempt,
      name: 'Tentative en plus',
      description: 'Ajoute une tentative pour ce tour.',
    ),
    PowerUp(
      type: PowerUpType.ropeFreeze,
      name: 'Gel de corde',
      description: 'L\'adversaire ne peut pas déplacer la corde à son prochain tour.',
    ),
  ];
}