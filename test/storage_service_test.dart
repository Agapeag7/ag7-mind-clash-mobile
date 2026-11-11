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
    );
    await StorageService.recordGameResult(
      won: true,
      correctAnswers: 3,
      totalAnswers: 5,
    );
    await StorageService.recordGameResult(
      won: false,
      correctAnswers: 2,
      totalAnswers: 7,
    );

    final stats = await StorageService.getStats();

    expect(stats['gamesPlayed'], 3);
    expect(stats['wins'], 2);
    expect(stats['losses'], 1);
    expect(stats['correctAnswers'], 9);
    expect(stats['totalAnswers'], 18);
    expect(stats['bestWinStreak'], 2);
    expect(stats['currentWinStreak'], 0);
  });
}
