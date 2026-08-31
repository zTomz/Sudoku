import 'logical_solver.dart';
import 'puzzle.dart';

/// Deterministic, technique-graded generation for free and daily puzzles.
final class SudokuEngine() {
  static const dailyVersion = 2;
  static const freeVersion = 3;
  static const allDigits = 0x3fe;

  Future<Puzzle> generate({
    required int seed,
    required Difficulty difficulty,
    bool Function()? isCancelled,
  }) => _generateGraded(seed, difficulty, null, isCancelled);

  Future<Puzzle> _generateGraded(
    int seed,
    Difficulty difficulty,
    String? dailyDate,
    bool Function()? isCancelled,
  ) async {
    final random = _StableRandom(seed);
    final solver = LogicalSolver();
    await Future<void>.delayed(Duration.zero);
    final slice = Stopwatch()..start();
    final maxClues = switch (difficulty) {
      Difficulty.easy => 40,
      Difficulty.medium => 36,
      Difficulty.hard => 36,
    };
    // A fixed work budget keeps identities deterministic, unlike a time limit.
    // Never silently substitute an easier or ungraded puzzle on exhaustion.
    for (var attempt = 0; attempt < 256; attempt++) {
      if (isCancelled?.call() ?? false) {
        throw StateError('Generation cancelled');
      }
      final solution = await _randomSolution(random);
      final givens = [...solution];
      var clues = 81;
      // Prefer rotational symmetry; refine individual clues if paired removal
      // cannot reach the requested grade. Difficulty takes precedence over shape.
      final groups = <List<int>>[
        for (final c in random.shuffle(List.generate(41, (i) => i)))
          [c, if (c != 40) 80 - c],
        for (final c in random.shuffle(List.generate(81, (i) => i))) [c],
      ];
      for (final group in groups) {
        final cells = group.where((c) => givens[c] != 0).toList();
        if (cells.isEmpty) continue;
        // Time only controls scheduling, never random choices or acceptance.
        // Avoid one browser timer per clue, which would dominate generation.
        if (slice.elapsedMilliseconds >= 4) {
          await Future<void>.delayed(Duration.zero);
          slice.reset();
        }
        if (isCancelled?.call() ?? false) {
          throw StateError('Generation cancelled');
        }
        for (final cell in cells) {
          givens[cell] = 0;
        }
        final rating = solver.solve(
          givens,
          maxDifficulty: difficulty,
          assessDifficulty: false,
        );
        if (rating.status != LogicalStatus.solved ||
            countSolutions(givens) != 1) {
          for (final cell in cells) {
            givens[cell] = solution[cell];
          }
          continue;
        }
        clues -= cells.length;
        if (clues > maxClues || rating.difficulty != difficulty) continue;
        // A hard step in one path alone does not prove easier techniques fail.
        if (difficulty != Difficulty.easy &&
            solver
                    .solve(
                      givens,
                      maxDifficulty: Difficulty.values[difficulty.index - 1],
                      assessDifficulty: false,
                    )
                    .status ==
                LogicalStatus.solved) {
          continue;
        }
        return Puzzle(
          id: dailyDate == null
              ? 'v$freeVersion-${difficulty.name}-$seed'
              : 'daily-v$dailyVersion-$dailyDate',
          difficulty: difficulty,
          givens: givens,
          solution: solution,
          dailyDate: dailyDate,
          rating: solver.solve(givens).rating,
        );
      }
    }
    throw StateError(
      'Unable to construct a Sudoku of the requested difficulty',
    );
  }

  // Randomized search constructs a solution from an empty grid instead of
  // permuting a single template. Budgets bound work inside the worker.
  static Future<List<int>> _randomSolution(_StableRandom random) async {
    for (var attempt = 0; attempt < 20; attempt++) {
      final board = List.filled(81, 0);
      final order = random.shuffle(List.generate(81, (i) => i));
      final rows = List.filled(9, 0),
          cols = List.filled(9, 0),
          boxes = List.filled(9, 0);
      var nodes = 0;
      bool search() {
        if (++nodes > 12000) return false;
        var best = -1, mask = 0, fewest = 10;
        for (final i in order) {
          if (board[i] != 0) continue;
          final available =
              allDigits &
              ~(rows[i ~/ 9] | cols[i % 9] | boxes[i ~/ 27 * 3 + i % 9 ~/ 3]);
          final count = available.oneBitCount;
          if (count == 0) return false;
          if (count < fewest) {
            best = i;
            mask = available;
            fewest = count;
            if (count == 1) break;
          }
        }
        if (best == -1) return true;
        final row = best ~/ 9,
            col = best % 9,
            box = best ~/ 27 * 3 + best % 9 ~/ 3;
        for (final digit in random.shuffle([
          for (var n = 1; n <= 9; n++)
            if (mask & (1 << n) != 0) n,
        ])) {
          final bit = 1 << digit;
          board[best] = digit;
          rows[row] |= bit;
          cols[col] |= bit;
          boxes[box] |= bit;
          if (search()) return true;
          board[best] = 0;
          rows[row] &= ~bit;
          cols[col] &= ~bit;
          boxes[box] &= ~bit;
          if (nodes > 12000) return false;
        }
        return false;
      }

      if (search()) return board;
      await Future<void>.delayed(Duration.zero);
    }
    throw StateError('Unable to construct a Sudoku within the search budget');
  }

  Future<Puzzle> daily(DateTime date, {bool Function()? isCancelled}) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    return _generateGraded(seed, Difficulty.medium, dateKey(date), isCancelled);
  }

  /// Returns 0, 1 or 2 (multiple/unknown). Budget exhaustion never proves uniqueness.
  int countSolutions(List<int> input, {int nodeBudget = 20000}) {
    if (input.length != 81 || input.any((n) => n < 0 || n > 9)) return 0;
    final board = [...input];
    final rows = List.filled(9, 0),
        cols = List.filled(9, 0),
        boxes = List.filled(9, 0);
    for (var i = 0; i < 81; i++) {
      if (board[i] == 0) continue;
      final r = i ~/ 9, c = i % 9, b = i ~/ 27 * 3 + i % 9 ~/ 3;
      final bit = 1 << board[i];
      if ((rows[r] | cols[c] | boxes[b]) & bit != 0) return 0;
      rows[r] |= bit;
      cols[c] |= bit;
      boxes[b] |= bit;
    }
    var nodes = 0;
    int search() {
      if (++nodes > nodeBudget) return 2;
      var best = -1, mask = 0, fewest = 10;
      for (var i = 0; i < 81; i++) {
        if (board[i] != 0) continue;
        final available =
            allDigits &
            ~(rows[i ~/ 9] | cols[i % 9] | boxes[i ~/ 27 * 3 + i % 9 ~/ 3]);
        final count = available.oneBitCount;
        if (count == 0) return 0;
        if (count < fewest) {
          best = i;
          mask = available;
          fewest = count;
          if (count == 1) break;
        }
      }
      if (best == -1) return 1;
      final r = best ~/ 9, c = best % 9, b = best ~/ 27 * 3 + best % 9 ~/ 3;
      var total = 0;
      for (var digit = 1; digit <= 9; digit++) {
        final bit = 1 << digit;
        if (mask & bit == 0) continue;
        board[best] = digit;
        rows[r] |= bit;
        cols[c] |= bit;
        boxes[b] |= bit;
        total += search();
        board[best] = 0;
        rows[r] &= ~bit;
        cols[c] &= ~bit;
        boxes[b] &= ~bit;
        if (total >= 2) return 2;
      }
      return total;
    }

    return search();
  }

  static int candidates(List<int> values, int cell) {
    if (values[cell] != 0) return 0;
    var mask = allDigits;
    for (final peer in peers(cell)) {
      mask &= ~(1 << values[peer]);
    }
    return mask;
  }
}

/// Integer arithmetic stays exact in JavaScript; do not replace with Random(seed).
final class _StableRandom(int seed) {
  this : _state = seed % 2147483646 + 1;
  int _state;
  int next(int max) {
    _state = (_state * 16807) % 2147483647;
    return _state % max;
  }

  List<int> shuffle(List<int> list) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = next(i + 1);
      final previous = list[i];
      list[i] = list[j];
      list[j] = previous;
    }
    return list;
  }
}
