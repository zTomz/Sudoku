// A pure-Dart test entrypoint: compare its JSON on the VM and compiled JS.
import 'dart:convert';

import 'package:sudoku/features/game/domain/logical_solver.dart';
import 'package:sudoku/features/game/domain/puzzle.dart';
import 'package:sudoku/features/game/domain/sudoku_engine.dart';

Future<void> main() async {
  final engine = SudokuEngine();
  final solver = LogicalSolver();
  final puzzles = <Puzzle>[];
  for (final difficulty in Difficulty.values) {
    for (final seed in [0, 17, 991, 2147483646]) {
      puzzles.add(await engine.generate(seed: seed, difficulty: difficulty));
    }
  }
  for (final date in [DateTime(2026, 8, 31), DateTime(2028, 2, 29)]) {
    puzzles.add(await engine.daily(date));
  }
  final output = <Map<String, Object?>>[];
  for (final puzzle in puzzles) {
    final rating = solver.solve(puzzle.givens);
    if (rating.status != LogicalStatus.solved ||
        rating.difficulty != puzzle.difficulty) {
      throw StateError('Unexpected grade for ${puzzle.id}');
    }
    output.add({
      ...puzzle.toJson(),
      'steps': [
        for (final step in rating.steps)
          {
            'technique': step.technique.name,
            'cells': step.cells,
            'digits': step.digits,
            'placement': step.placement,
            'candidates': {
              for (final entry in step.candidates.entries)
                entry.key.toString(): entry.value,
            },
            'removals': [
              for (final removal in step.removals)
                {'cell': removal.cell, 'mask': removal.mask},
            ],
          },
      ],
    });
  }
  // ignore: avoid_print -- machine-readable output for the portability check.
  print(jsonEncode(output));
}
