class DifficultyConfig {
  final int level;
  final String name;
  final String description;
  final double secondsPerQuestion;
  final double aiAccuracy; // 0..1
  final double aiMinDelay;
  final double aiMaxDelay;

  const DifficultyConfig({
    required this.level,
    required this.name,
    required this.description,
    required this.secondsPerQuestion,
    required this.aiAccuracy,
    required this.aiMinDelay,
    required this.aiMaxDelay,
  });

  static const List<DifficultyConfig> all = [
    DifficultyConfig(
      level: 1,
      name: 'Débutant',
      description: 'Additions et soustractions simples. Nombres 0–20.',
      secondsPerQuestion: 30,
      aiAccuracy: 0.55,
      aiMinDelay: 3.0,
      aiMaxDelay: 6.0,
    ),
    DifficultyConfig(
      level: 2,
      name: 'Facile',
      description: 'Additions, soustractions, multiplications simples. 0–50.',
      secondsPerQuestion: 25,
      aiAccuracy: 0.65,
      aiMinDelay: 2.5,
      aiMaxDelay: 5.0,
    ),
    DifficultyConfig(
      level: 3,
      name: 'Intermédiaire',
      description: 'Les quatre opérations, divisions exactes.',
      secondsPerQuestion: 22,
      aiAccuracy: 0.75,
      aiMinDelay: 2.0,
      aiMaxDelay: 4.0,
    ),
    DifficultyConfig(
      level: 4,
      name: 'Avancé',
      description: 'Opérations mélangées, calculs à plusieurs étapes.',
      secondsPerQuestion: 20,
      aiAccuracy: 0.82,
      aiMinDelay: 1.5,
      aiMaxDelay: 3.5,
    ),
    DifficultyConfig(
      level: 5,
      name: 'Difficile',
      description: 'Priorités opératoires, parenthèses, temps réduit.',
      secondsPerQuestion: 16,
      aiAccuracy: 0.90,
      aiMinDelay: 1.0,
      aiMaxDelay: 3.0,
    ),
    DifficultyConfig(
      level: 6,
      name: 'Expert',
      description: 'Opérations complexes, chronomètre exigeant.',
      secondsPerQuestion: 12,
      aiAccuracy: 0.95,
      aiMinDelay: 0.8,
      aiMaxDelay: 2.5,
    ),
  ];

  static DifficultyConfig byLevel(int level) =>
      all.firstWhere((c) => c.level == level, orElse: () => all.first);
}