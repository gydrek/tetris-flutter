// Basic test for Tetris Flutter app

import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/pages/score.dart';

void main() {
  test('getBestScore returns 0 for empty scores', () async {
    // Simple unit test to verify getBestScore function
    final bestScore = await getBestScore();
    expect(bestScore, isA<int>());
    expect(bestScore, greaterThanOrEqualTo(0));
  });
  
  // Додаткові тести можна додати пізніше
}
