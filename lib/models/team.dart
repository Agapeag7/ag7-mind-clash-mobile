import '../core/enums.dart';

class Team {
  final TeamSide side;
  final String name;
  int roundsWon;

  Team({
    required this.side,
    required this.name,
    this.roundsWon = 0,
  });

  bool get isRed => side == TeamSide.red;
}