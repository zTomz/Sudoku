import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/features/game/domain/logical_solver.dart';
import 'package:sudoku/features/game/domain/puzzle.dart';
import 'package:sudoku/features/game/domain/sudoku_engine.dart';

void main() {
  final engine = SudokuEngine();
  final solver = LogicalSolver();
  const samples = int.fromEnvironment('SUDOKU_SAMPLES', defaultValue: 24);

  group('Graded generation', () {
    for (final difficulty in Difficulty.values) {
      test('${difficulty.name}: independent uniqueness and logical grade', () async {
        final times = <int>[];
        final boards = <String>{};
        for (var seed = 0; seed < samples; seed++) {
          final watch = Stopwatch()..start();
          final puzzle = await engine.generate(
            seed: seed,
            difficulty: difficulty,
          );
          times.add(watch.elapsedMicroseconds);
          final reason = '${difficulty.name}, seed $seed';
          expect(boards.add(puzzle.givens.join()), isTrue, reason: reason);
          expect(_countIndependently(puzzle.givens), 1, reason: reason);
          final rating = solver.solve(puzzle.givens);
          expect(rating.status, LogicalStatus.solved, reason: reason);
          expect(rating.difficulty, difficulty, reason: reason);
          expect(rating.values, puzzle.solution, reason: reason);
          expect(
            puzzle.rating.toJson(),
            rating.rating.toJson(),
            reason: reason,
          );
          expect(rating.steps.length, lessThanOrEqualTo(729), reason: reason);
          if (difficulty != Difficulty.easy) {
            expect(
              solver
                  .solve(
                    puzzle.givens,
                    maxDifficulty: Difficulty.values[difficulty.index - 1],
                  )
                  .status,
              LogicalStatus.stuck,
              reason: reason,
            );
          }
          _verifyTrace(puzzle, rating);
        }
        times.sort();
        // ignore: avoid_print -- explicit benchmark output from the test runner.
        print(
          '${difficulty.name}: $samples puzzles; '
          'median ${(times[times.length ~/ 2] / 1000).toStringAsFixed(1)} ms; '
          'p95 ${(times[((times.length - 1) * .95).ceil()] / 1000).toStringAsFixed(1)} ms; '
          'max ${(times.last / 1000).toStringAsFixed(1)} ms',
        );
      }, timeout: const Timeout(Duration(minutes: 10)));
    }

    test('same seed and grade reproduce the same puzzle', () async {
      for (final difficulty in Difficulty.values) {
        for (final seed in [-2147483647, 0, 2147483646]) {
          final a = await engine.generate(seed: seed, difficulty: difficulty);
          final b = await engine.generate(seed: seed, difficulty: difficulty);
          expect(a.id, 'v3-${difficulty.name}-$seed');
          expect(a.givens, b.givens);
          expect(a.solution, b.solution);
        }
      }
    });

    test('daily puzzles are graded and deterministic', () async {
      final date = DateTime(2026, 8, 31);
      final a = await engine.daily(date);
      final b = await engine.daily(DateTime(2026, 8, 31, 23, 59));
      expect(a.id, 'daily-v2-2026-08-31');
      expect(a.dailyDate, '2026-08-31');
      expect(a.givens, b.givens);
      expect(a.solution, b.solution);
      expect(solver.solve(a.givens).difficulty, Difficulty.medium);
      expect(_countIndependently(a.givens), 1);
      expect(
        a.givens.join(),
        '000752000007000050210430000009000006046829510100000800000067025090000700000983000',
      );
    });

    test('generation yields and can be cancelled between searches', () async {
      var cancelled = false;
      final timer = Timer(Duration.zero, () => cancelled = true);
      addTearDown(timer.cancel);
      await expectLater(
        engine.generate(
          seed: 4,
          difficulty: Difficulty.hard,
          isCancelled: () => cancelled,
        ),
        throwsStateError,
      );
      await expectLater(
        engine.daily(DateTime(2026, 8, 31), isCancelled: () => true),
        throwsStateError,
      );
    });
  });

  group('Logical solver boundaries', () {
    test(
      'multiple solutions stay ungraded; uniqueness is never assumed',
      () async {
        final puzzle = await engine.generate(
          seed: 42,
          difficulty: Difficulty.easy,
        );
        final ambiguous = [
          for (final digit in puzzle.solution) digit <= 2 ? 0 : digit,
        ];
        expect(_countIndependently(ambiguous), 2);
        final result = solver.solve(ambiguous);
        expect(result.status, LogicalStatus.stuck);
        expect(result.steps, isEmpty);
        expect(result.difficulty, isNull);
      },
    );

    test(
      'a unit with no place for a digit is invalid even with nonempty cells',
      () {
        final board = List.filled(81, 0);
        final filled = [1, 2, 4, 5, 6, 7, 8];
        for (var i = 0; i < filled.length; i++) {
          board[filled[i]] = i + 1;
        }
        board[27] = board[57] = 8;
        for (var c = 0; c < 81; c++) {
          if (board[c] == 0) {
            expect(SudokuEngine.candidates(board, c), isNonZero);
          }
        }
        expect(solver.solve(board).status, LogicalStatus.invalid);
      },
    );

    final fixtures = <SolveTechnique, String>{
      SolveTechnique.lockedCandidates: '000040300020006054000000009538400001000000000600002845100000600490600070003070000',
      SolveTechnique.nakedPair: '007092060004100000200603000500000640800000001013000007000301008000004100060870200',
      SolveTechnique.hiddenPair: '143000000000500060500804000000070030082000900090010000000205008000007000070000296',
      SolveTechnique.nakedTriple: '405300000000040005009015003060080004080906010900050060200700400800090000000002100',
      SolveTechnique.hiddenTriple: '090750046670000000400039000060090004050060030100080060000170009000000057980046010',
      SolveTechnique.xWing: '450000070003080000007005010900051004000604000700390081080000100540010300070020058',
      SolveTechnique.xyWing: '090000057038925000106400002000002409860090021409600000500003608000286570680000010',
    };
    for (final fixture in fixtures.entries) {
      test('${fixture.key.name} regression and symmetry transforms', () {
        final givens = fixture.value.split('').map(int.parse).toList();
        final original = solver.solve(givens);
        expect(original.status, LogicalStatus.solved);
        expect(original.steps.map((s) => s.technique), contains(fixture.key));
        expect(_countIndependently(givens), 1);
        for (var transform = 0; transform < 4; transform++) {
          List<int> convert(List<int> board) => [
            for (var i = 0; i < 81; i++)
              switch (transform) {
                0 => board[i],
                1 => board[i % 9 * 9 + i ~/ 9],
                2 => board[80 - i],
                _ => board[i] == 0 ? 0 : 10 - board[i],
              },
          ];
          final puzzle = Puzzle(
            id: 'fixture',
            difficulty: fixture.key.difficulty,
            givens: convert(givens),
            solution: convert(original.values),
          );
          final rating = solver.solve(puzzle.givens);
          expect(rating.status, LogicalStatus.solved);
          _verifyTrace(puzzle, rating);
        }
      });
    }

    test('invalid and unconstrained inputs are never graded', () {
      for (final input in [
        [1, 2],
        List.filled(81, 1),
        List.filled(81, -1),
        List.filled(81, 10),
      ]) {
        final rating = solver.solve(input);
        expect(rating.status, LogicalStatus.invalid);
        expect(rating.difficulty, isNull);
      }
      final empty = solver.solve(List.filled(81, 0));
      expect(empty.status, LogicalStatus.stuck);
      expect(empty.difficulty, isNull);
      expect(empty.steps, isEmpty);
    });

    test('contradictions without duplicate givens are detected', () {
      final board = List.filled(81, 0);
      for (var c = 0; c < 8; c++) {
        board[c] = c + 1;
      }
      board[17] = 9;
      expect(solver.solve(board).status, LogicalStatus.invalid);
    });

    test('input, result and explanation snapshots are immutable', () async {
      final puzzle = await engine.generate(
        seed: 12,
        difficulty: Difficulty.medium,
      );
      final input = [...puzzle.givens];
      final rating = solver.solve(input);
      expect(input, puzzle.givens);
      input[0] = -1;
      expect(rating.values, puzzle.solution);
      expect(() => rating.values[0] = 0, throwsUnsupportedError);
      expect(() => rating.steps.clear(), throwsUnsupportedError);
      expect(() => rating.steps.first.cells.clear(), throwsUnsupportedError);
      expect(() => rating.steps.first.removals.clear(), throwsUnsupportedError);
      final complete = solver.solve(puzzle.solution);
      expect(complete.status, LogicalStatus.solved);
      expect(complete.steps, isEmpty);
    });
  });
}

void _verifyTrace(Puzzle puzzle, LogicalResult result) {
  final values = [...puzzle.givens];
  final masks = [
    for (var c = 0; c < 81; c++) SudokuEngine.candidates(values, c),
  ];
  for (final step in result.steps) {
    expect(step.cells, isNotEmpty);
    if (step.placement case final cell?) {
      expect(values[cell], 0);
      expect(step.digits.oneBitCount, 1);
      expect(masks[cell] & step.digits, step.digits);
      expect(step.digits, 1 << puzzle.solution[cell]);
      if (step.technique == SolveTechnique.nakedSingle) {
        expect(masks[cell], step.digits);
      } else {
        expect(step.technique, SolveTechnique.hiddenSingle);
        expect(step.cells.where((c) => masks[c] & step.digits != 0), [cell]);
      }
      values[cell] = step.digits.bitLength - 1;
      masks[cell] = 0;
      for (final peer in peers(cell)) {
        masks[peer] &= ~step.digits;
      }
      expect(step.removals, isEmpty);
    } else {
      expect(step.removals, isNotEmpty);
      for (final removal in step.removals) {
        expect(values[removal.cell], 0);
        expect(removal.mask, isNot(0));
        expect(masks[removal.cell] & removal.mask, removal.mask);
        expect(
          removal.mask & (1 << puzzle.solution[removal.cell]),
          0,
          reason: '${step.technique} removed the solution',
        );
        masks[removal.cell] &= ~removal.mask;
      }
    }
  }
  expect(values, puzzle.solution);
}

// Deliberately independent of the production bitmask solver and its budget.
int _countIndependently(List<int> input) {
  final board = [...input];
  List<int> available(int cell) {
    final used = <int>{};
    for (var n = 0; n < 9; n++) {
      used.add(board[cell ~/ 9 * 9 + n]);
      used.add(board[n * 9 + cell % 9]);
      used.add(
        board[(cell ~/ 27 * 3 + n ~/ 3) * 9 + cell % 9 ~/ 3 * 3 + n % 3],
      );
    }
    return [
      for (var d = 1; d <= 9; d++)
        if (!used.contains(d)) d,
    ];
  }

  int search() {
    var best = -1;
    List<int>? options;
    for (var c = 0; c < 81; c++) {
      if (board[c] != 0) continue;
      final candidates = available(c);
      if (candidates.isEmpty) return 0;
      if (options == null || candidates.length < options.length) {
        best = c;
        options = candidates;
        if (options.length == 1) break;
      }
    }
    if (best == -1) return 1;
    var count = 0;
    for (final digit in options!) {
      board[best] = digit;
      count += search();
      board[best] = 0;
      if (count >= 2) return 2;
    }
    return count;
  }

  return search();
}
