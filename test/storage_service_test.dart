import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ag7_mind_clash/services/storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('records match results and answer totals across games', () async {
    await StorageService.recordGameResult(
      won: true,
      correctAnswers: 4,
      totalAnswers: 6,
      difficulty: 1,
    );
    await StorageService.recordGameResult(
      won: true,
      correctAnswers: 3,
      totalAnswers: 5,
      difficulty: 1,
    );
    await StorageService.recordGameResult(
      won: false,
      correctAnswers: 2,
      totalAnswers: 7,
      difficulty: 2,
    );

    final stats = await StorageService.getStats();

    expect(stats['gamesPlayed'], 3);
    expect(stats['wins'], 2);
    expect(stats['losses'], 1);
    expect(stats['correctAnswers'], 9);
    expect(stats['totalAnswers'], 18);
    expect(stats['bestWinStreak'], 2);
    expect(stats['currentWinStreak'], 0);
    final byDifficulty = stats['byDifficulty'] as Map<String, dynamic>;
    expect(byDifficulty['1']['gamesPlayed'], 2);
    expect(byDifficulty['1']['wins'], 2);
    expect(byDifficulty['1']['correctAnswers'], 7);
    expect(byDifficulty['2']['gamesPlayed'], 1);
    expect(byDifficulty['2']['losses'], 1);
  });

  test('reset clears global and per-difficulty statistics', () async {
    await StorageService.recordGameResult(
      won: true,
      correctAnswers: 4,
      totalAnswers: 6,
      difficulty: 3,
    );

    await StorageService.resetStats();
    final stats = await StorageService.getStats();
    final byDifficulty = stats['byDifficulty'] as Map<String, dynamic>;

    expect(stats['gamesPlayed'], 0);
    expect(byDifficulty['3']['gamesPlayed'], 0);
  });
}
