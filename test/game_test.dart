import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/features/game/domain/game_session.dart';
import 'package:sudoku/features/game/domain/puzzle.dart';
import 'package:sudoku/features/game/domain/sudoku_engine.dart';

void main() {
  final engine = SudokuEngine();
  test('free v2 grids are diverse and not just symmetries of the cyclic template', () async {
    final solutions = <String>{};
    var rectangles = 0;
    for (var seed = 100; seed < 108; seed++) {
      final puzzle = await engine.generate(
        seed: seed,
        difficulty: Difficulty.easy,
      );
      expect(puzzle.id, startsWith('v2-'));
      solutions.add(puzzle.solution.join());
      final board = puzzle.solution;
      // A cyclic order-nine template has no two-row/two-column swaps.
      // This invariant survives all the old row, column and digit permutations.
      for (var a = 0; a < 9; a++) {
        for (var b = a + 1; b < 9; b++) {
          for (var x = 0; x < 9; x++) {
            for (var y = x + 1; y < 9; y++) {
              if (board[a * 9 + x] == board[b * 9 + y] &&
                  board[a * 9 + y] == board[b * 9 + x]) {
                rectangles++;
              }
            }
          }
        }
      }
    }
    expect(solutions.length, 8);
    expect(rectangles, greaterThan(0));
  });
  test('generated puzzles have valid clues and exactly one solution', () async {
    for (final difficulty in Difficulty.values) {
      for (var seed = 1; seed <= 12; seed++) {
        final puzzle = await engine.generate(
          seed: seed,
          difficulty: difficulty,
        );
        expect(
          engine.countSolutions(puzzle.givens),
          1,
          reason: '$difficulty / $seed',
        );
        for (var unit = 0; unit < 9; unit++) {
          expect(
            {for (var n = 0; n < 9; n++) puzzle.solution[unit * 9 + n]},
            {1, 2, 3, 4, 5, 6, 7, 8, 9},
          );
          expect(
            {for (var n = 0; n < 9; n++) puzzle.solution[n * 9 + unit]},
            {1, 2, 3, 4, 5, 6, 7, 8, 9},
          );
          expect(
            {
              for (var n = 0; n < 9; n++)
                puzzle.solution[(unit ~/ 3 * 3 + n ~/ 3) * 9 +
                    unit % 3 * 3 +
                    n % 3],
            },
            {1, 2, 3, 4, 5, 6, 7, 8, 9},
          );
        }
        expect(puzzle.givens.where((v) => v != 0).length, lessThan(50));
      }
    }
  });
  test('daily puzzles ignore time and are reproducible', () async {
    final a = await engine.daily(DateTime(2026, 8, 31, 1));
    final b = await engine.daily(DateTime(2026, 8, 31, 23));
    final c = await engine.daily(DateTime(2026, 9, 1));
    expect(a.givens, b.givens);
    expect(a.solution, b.solution);
    expect(a.id, 'daily-v1-2026-08-31');
    expect(
      a.givens.join(),
      '008573406000000009000810703000020000040901000273080501900135602007098010000700940',
    );
    expect(a.givens, isNot(c.givens));
  });
  test('invalid boards and exhausted searches cannot establish uniqueness', () {
    expect(engine.countSolutions(List.filled(81, 1)), 0);
    expect(engine.countSolutions(List.filled(81, 0)), 2);
    expect(engine.countSolutions(List.filled(81, 0), nodeBudget: 0), 2);
    expect(engine.countSolutions([1, 2]), 0);
  });
  test(
    'note cleanup, undo, redo and JSON restore retain the full move',
    () async {
      final puzzle = await engine.generate(
        seed: 42,
        difficulty: Difficulty.easy,
      );
      final first = puzzle.givens.indexOf(0);
      final peer = peers(first).firstWhere((p) => puzzle.givens[p] == 0);
      final digit = puzzle.solution[first];
      var game = GameSession.start(puzzle);
      game = game.enter(peer, digit, pencil: true);
      expect(game.notes[peer] & (1 << digit), isNonZero);
      final before = game;
      game = game.enter(first, digit);
      expect(game.notes[peer] & (1 << digit), 0);
      game = game.undo();
      expect(game.values, before.values);
      expect(game.notes, before.notes);
      final restored = GameSession.fromJson(
        jsonDecode(jsonEncode(game.toJson())) as Map<String, Object?>,
      );
      expect(restored.redo().values[first], digit);
      expect(restored.redo().notes[peer] & (1 << digit), 0);
      expect(restored.enter(first, digit == 9 ? 1 : digit + 1).canRedo, false);
      expect(() => game.values[0] = 9, throwsUnsupportedError);
    },
  );
  test(
    'givens cannot be edited; completed games are recognized and frozen',
    () async {
      final puzzle = await engine.generate(
        seed: 17,
        difficulty: Difficulty.easy,
      );
      var game = GameSession.start(puzzle);
      final given = puzzle.givens.indexWhere((v) => v != 0);
      expect(identical(game.enter(given, 0), game), true);
      for (var cell = 0; cell < 81; cell++) {
        if (puzzle.givens[cell] == 0) {
          game = game.enter(cell, puzzle.solution[cell]);
        }
      }
      expect(game.complete, true);
      expect(game.canUndo, false);
      expect(GameSession.fromJson(game.toJson()).complete, true);
    },
  );
  test('corrupt move history is rejected instead of altering givens', () async {
    final puzzle = await engine.generate(seed: 19, difficulty: Difficulty.easy);
    final session = GameSession.start(puzzle);
    final json = session.toJson();
    json['history'] = [
      [
        [puzzle.givens.indexWhere((v) => v != 0), 0, 1, 0, 0],
      ],
    ];
    expect(() => GameSession.fromJson(json), throwsFormatException);
  });
}
