import 'puzzle.dart';

/// Version 1 is frozen so the same daily ID remains identical on every platform.
final class SudokuEngine() {
  static const version = 1;
  static const allDigits = 0x3fe;

  Future<Puzzle> generate({
    required int seed,
    required Difficulty difficulty,
    String? dailyDate,
  }) async {
    final random = _StableRandom(seed);
    final solution = dailyDate == null
        ? await _randomSolution(random)
        : _legacySolution(random);
    final givens = [...solution];
    final target = switch (difficulty) {
      Difficulty.easy => 42,
      Difficulty.medium => 34,
      Difficulty.hard => 28,
    };
    var clues = 81;
    for (final cell in random.shuffle(List.generate(81, (i) => i))) {
      final previous = givens[cell];
      givens[cell] = 0;
      if (countSolutions(givens) != 1) {
        givens[cell] = previous;
      } else {
        clues--;
      }
      if (clues <= target) break;
      // Yield between bounded searches, including on the single-threaded web.
      await Future<void>.delayed(Duration.zero);
    }
    return Puzzle(
      id: dailyDate == null
          ? 'v2-${difficulty.name}-$seed'
          : 'daily-v$version-$dailyDate',
      difficulty: difficulty,
      givens: givens,
      solution: solution,
      dailyDate: dailyDate,
    );
  }

  static List<int> _legacySolution(_StableRandom random) {
    final digits = random.shuffle(List.generate(9, (i) => i + 1));
    List<int> axis() => [
      for (final group in random.shuffle([0, 1, 2]))
        for (final offset in random.shuffle([0, 1, 2])) group * 3 + offset,
    ];
    final rows = axis(), cols = axis();
    final transpose = random.next(2) == 0;
    return List.generate(81, (cell) {
      final r = rows[transpose ? cell % 9 : cell ~/ 9];
      final c = cols[transpose ? cell ~/ 9 : cell % 9];
      return digits[(r * 3 + r ~/ 3 + c) % 9];
    });
  }

  // Randomized search constructs a solution from an empty grid instead of
  // permuting a single template. Budgets bound work on the web UI isolate.
  static Future<List<int>> _randomSolution(_StableRandom random) async {
    for (var attempt = 0; attempt < 20; attempt++) {
      final board = List.filled(81, 0);
      final rows = List.filled(9, 0),
          cols = List.filled(9, 0),
          boxes = List.filled(9, 0);
      var nodes = 0;
      bool search() {
        if (++nodes > 12000) return false;
        var best = -1, mask = 0, fewest = 10;
        for (var i = 0; i < 81; i++) {
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

  Future<Puzzle> daily(DateTime date) => generate(
    seed: date.year * 10000 + date.month * 100 + date.day,
    difficulty: Difficulty.medium,
    dailyDate: dateKey(date),
  );

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
