import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/features/game/data/game_repository.dart';
import 'package:sudoku/features/game/domain/puzzle.dart';
import 'package:sudoku/features/statistics/application/solve_time_prediction.dart';

void main() {
  GameResult result(
    String id,
    Difficulty difficulty,
    int seconds, {
    int? effortScore,
  }) =>
      GameResult(id, difficulty, seconds, null, 0, 0, effortScore: effortScore);

  group('predictSolveTime', () {
    test('uses only completed games at the requested difficulty', () {
      final results = [
        result('easy', Difficulty.easy, 120),
        result('medium-1', Difficulty.medium, 300),
        result('medium-2', Difficulty.medium, 420),
        result('hard', Difficulty.hard, 900),
      ];

      expect(predictSolveTime(results, Difficulty.medium), 360);
    });

    test('uses the median so one outlier does not distort the estimate', () {
      final results = [
        result('one', Difficulty.hard, 600),
        result('two', Difficulty.hard, 660),
        result('outlier', Difficulty.hard, 7200),
      ];

      expect(predictSolveTime(results, Difficulty.hard), 660);
    });

    test('returns null without a usable matching result', () {
      final results = [result('zero', Difficulty.easy, 0)];

      expect(predictSolveTime(results, Difficulty.easy), isNull);
      expect(predictSolveTime(results, Difficulty.medium), isNull);
    });

    test('adjusts the estimate for the target puzzle effort score', () {
      final results = [
        result('low', Difficulty.medium, 300, effortScore: 100),
        result('middle', Difficulty.medium, 600, effortScore: 200),
        result('high', Difficulty.medium, 900, effortScore: 300),
      ];

      expect(
        predictSolveTime(results, Difficulty.medium, effortScore: 150),
        450,
      );
    });

    test('falls back to the difficulty median for legacy results', () {
      final results = [
        result('one', Difficulty.easy, 240),
        result('two', Difficulty.easy, 360),
      ];

      expect(predictSolveTime(results, Difficulty.easy, effortScore: 120), 300);
    });
  });

  group('GameResult effort score', () {
    test('round-trips while older results remain readable', () {
      final scored = result('scored', Difficulty.hard, 720, effortScore: 321);
      expect(GameResult.fromJson(scored.toJson()).effortScore, 321);

      final legacy = scored.toJson()..remove('effortScore');
      expect(GameResult.fromJson(legacy).effortScore, isNull);
    });

    test('rejects invalid effort scores', () {
      final json = result('bad', Difficulty.easy, 120).toJson()
        ..['effortScore'] = -1;
      expect(() => GameResult.fromJson(json), throwsFormatException);
    });
  });
}
