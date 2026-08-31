import 'puzzle.dart';
import 'difficulty_rating.dart';

/// Ordered from simple placements to advanced candidate eliminations.
enum SolveTechnique() {
  nakedSingle,
  hiddenSingle,
  lockedCandidates,
  nakedPair,
  hiddenPair,
  nakedTriple,
  hiddenTriple,
  xWing,
  xyWing;

  Difficulty get difficulty => switch (this) {
    nakedSingle || hiddenSingle => Difficulty.easy,
    lockedCandidates || nakedPair || hiddenPair => Difficulty.medium,
    nakedTriple || hiddenTriple || xWing || xyWing => Difficulty.hard,
  };

  int get effort => switch (this) {
    nakedSingle => 1,
    hiddenSingle => 3,
    lockedCandidates => 8,
    nakedPair => 12,
    hiddenPair => 16,
    nakedTriple => 24,
    hiddenTriple => 30,
    xWing => 40,
    xyWing => 50,
  };
}

typedef CandidateRemoval = ({int cell, int mask});

/// Machine-readable evidence, without consulting a stored solution.
final class LogicalStep({
  required final SolveTechnique technique,
  required List<int> cells,
  required final int digits,
  final int? placement,
  List<CandidateRemoval> removals = const [],
  Map<int, int> candidates = const {},
}) {
  this
    : cells = List.unmodifiable(cells),
      removals = List.unmodifiable(removals),
      candidates = Map.unmodifiable(candidates);

  final List<int> cells;
  final List<CandidateRemoval> removals;
  final Map<int, int> candidates;
}

enum LogicalStatus() {
  solved,
  progress,
  stuck,
  invalid
}

final class LogicalResult({
  required final LogicalStatus status,
  required List<int> values,
  required List<LogicalStep> steps,
  final DifficultyRating rating = const DifficultyRating(),
}) {
  this : values = List.unmodifiable(values), steps = List.unmodifiable(steps);

  final List<int> values;
  final List<LogicalStep> steps;

  Difficulty? get difficulty {
    if (status != LogicalStatus.solved) return null;
    var result = Difficulty.easy;
    for (final step in steps) {
      if (step.technique.difficulty.index > result.index) {
        result = step.technique.difficulty;
      }
    }
    return result;
  }
}

/// Deterministic, easiest-first deduction. Never guesses or assumes uniqueness.
final class LogicalSolver() {
  static const _all = 0x3fe;
  static final _units = <List<int>>[
    for (var r = 0; r < 9; r++) [for (var c = 0; c < 9; c++) r * 9 + c],
    for (var c = 0; c < 9; c++) [for (var r = 0; r < 9; r++) r * 9 + c],
    for (var b = 0; b < 9; b++)
      [
        for (var n = 0; n < 9; n++)
          (b ~/ 3 * 3 + n ~/ 3) * 9 + b % 3 * 3 + n % 3,
      ],
  ];
  static final _peers = [for (var i = 0; i < 81; i++) peers(i).toList()];

  LogicalResult solve(
    List<int> input, {
    Difficulty maxDifficulty = Difficulty.hard,
    bool stopAfterPlacement = false,
    bool assessDifficulty = true,
  }) {
    final values = [...input];
    final steps = <LogicalStep>[];
    var techniqueCost = 0, searchCost = 0, bottlenecks = 0;
    LogicalResult result(LogicalStatus status) => LogicalResult(
      status: status,
      values: values,
      steps: steps,
      rating: DifficultyRating(
        techniqueCost: techniqueCost,
        searchCost: searchCost,
        bottlenecks: bottlenecks,
        steps: steps.length,
      ),
    );
    if (values.length != 81 || values.any((v) => v < 0 || v > 9)) {
      return result(LogicalStatus.invalid);
    }
    final masks = List.filled(81, 0);
    for (var cell = 0; cell < 81; cell++) {
      if (values[cell] != 0) {
        if (_peers[cell].any((p) => values[p] == values[cell])) {
          return result(LogicalStatus.invalid);
        }
      } else {
        masks[cell] = _all;
        for (final peer in _peers[cell]) {
          masks[cell] &= ~(1 << values[peer]);
        }
      }
    }
    // Every iteration fills a cell or removes at least one of 729 candidates.
    while (true) {
      for (var cell = 0; cell < 81; cell++) {
        if (values[cell] == 0 && masks[cell] == 0) {
          return result(LogicalStatus.invalid);
        }
      }
      for (final unit in _units) {
        var possible = 0;
        for (final cell in unit) {
          possible |= values[cell] == 0 ? masks[cell] : 1 << values[cell];
        }
        if (possible != _all) return result(LogicalStatus.invalid);
      }
      if (!values.contains(0)) return result(LogicalStatus.solved);
      final step = _next(masks, maxDifficulty);
      if (step == null) return result(LogicalStatus.stuck);
      if (assessDifficulty) techniqueCost += step.technique.effort;
      // Ignore the trivial tail. Count distinct immediately forced cells,
      // including hidden singles, instead of counting the same move per unit.
      if (assessDifficulty && values.where((v) => v == 0).length > 12) {
        final choices = _singleChoices(masks);
        searchCost += 12 ~/ (choices + 1);
        if (choices <= 1) bottlenecks++;
      }
      steps.add(
        LogicalStep(
          technique: step.technique,
          cells: step.cells,
          digits: step.digits,
          placement: step.placement,
          removals: step.removals,
          candidates: {for (final cell in step.cells) cell: masks[cell]},
        ),
      );
      if (step.placement case final cell?) {
        values[cell] = step.digits.bitLength - 1;
        masks[cell] = 0;
        for (final peer in _peers[cell]) {
          masks[peer] &= ~step.digits;
        }
        if (stopAfterPlacement) {
          return result(
            values.contains(0) ? LogicalStatus.progress : LogicalStatus.solved,
          );
        }
      } else {
        for (final removal in step.removals) {
          masks[removal.cell] &= ~removal.mask;
        }
      }
    }
  }

  static int _singleChoices(List<int> masks) {
    final cells = <int>{
      for (var c = 0; c < 81; c++)
        if (masks[c].oneBitCount == 1) c,
    };
    for (final unit in _units) {
      for (var digit = 1; digit <= 9; digit++) {
        var only = -1;
        for (final c in unit) {
          if (masks[c] & (1 << digit) == 0) continue;
          if (only != -1) {
            only = -2;
            break;
          }
          only = c;
        }
        if (only >= 0) cells.add(only);
      }
    }
    return cells.length;
  }

  static LogicalStep? _next(List<int> masks, Difficulty limit) {
    for (var cell = 0; cell < 81; cell++) {
      if (masks[cell].oneBitCount == 1) {
        return LogicalStep(
          technique: SolveTechnique.nakedSingle,
          cells: [cell],
          digits: masks[cell],
          placement: cell,
        );
      }
    }
    for (final unit in _units) {
      for (var digit = 1; digit <= 9; digit++) {
        final bit = 1 << digit;
        final cells = [
          for (final c in unit)
            if (masks[c] & bit != 0) c,
        ];
        if (cells.length == 1) {
          return LogicalStep(
            technique: SolveTechnique.hiddenSingle,
            cells: unit,
            digits: bit,
            placement: cells.single,
          );
        }
      }
    }
    if (limit == Difficulty.easy) return null;
    final medium =
        _locked(masks) ??
        _subset(masks, 2, hidden: false) ??
        _subset(masks, 2, hidden: true);
    if (medium != null || limit == Difficulty.medium) return medium;
    return _subset(masks, 3, hidden: false) ??
        _subset(masks, 3, hidden: true) ??
        _xWing(masks) ??
        _xyWing(masks);
  }

  static LogicalStep? _eliminate(
    List<int> masks,
    SolveTechnique technique,
    List<int> evidence,
    int digits,
    Iterable<int> targets,
  ) {
    final removals = <CandidateRemoval>[
      for (final cell in targets)
        if (masks[cell] & digits != 0) (cell: cell, mask: masks[cell] & digits),
    ];
    if (removals.isEmpty) return null;
    return LogicalStep(
      technique: technique,
      cells: evidence,
      digits: digits,
      removals: removals,
    );
  }

  static LogicalStep? _locked(List<int> masks) {
    for (var u = 0; u < 27; u++) {
      for (var digit = 1; digit <= 9; digit++) {
        final bit = 1 << digit;
        final cells = [
          for (final c in _units[u])
            if (masks[c] & bit != 0) c,
        ];
        if (cells.length < 2) continue;
        final first = cells.first;
        final destinations = <int>[
          if (u >= 18 && cells.every((c) => c ~/ 9 == first ~/ 9)) first ~/ 9,
          if (u >= 18 && cells.every((c) => c % 9 == first % 9)) 9 + first % 9,
          if (u < 18 && cells.every((c) => _box(c) == _box(first)))
            18 + _box(first),
        ];
        for (final destination in destinations) {
          final step = _eliminate(
            masks,
            SolveTechnique.lockedCandidates,
            cells,
            bit,
            _units[destination].where((c) => !_units[u].contains(c)),
          );
          if (step != null) return step;
        }
      }
    }
    return null;
  }

  static int _box(int cell) => cell ~/ 27 * 3 + cell % 9 ~/ 3;

  static LogicalStep? _xyWing(List<int> masks) {
    for (var pivot = 0; pivot < 81; pivot++) {
      if (masks[pivot].oneBitCount != 2) continue;
      final wings = [
        for (final c in _peers[pivot])
          if (masks[c].oneBitCount == 2 &&
              (masks[c] & masks[pivot]).oneBitCount == 1 &&
              (masks[c] | masks[pivot]).oneBitCount == 3)
            c,
      ];
      for (var a = 0; a < wings.length; a++) {
        for (var b = a + 1; b < wings.length; b++) {
          final left = wings[a], right = wings[b];
          final common = masks[left] & masks[right];
          if (common.oneBitCount != 1 ||
              common & masks[pivot] != 0 ||
              (masks[left] | masks[right] | masks[pivot]).oneBitCount != 3) {
            continue;
          }
          final step = _eliminate(
            masks,
            SolveTechnique.xyWing,
            [pivot, left, right],
            common,
            _peers[left].where((c) => c != pivot && _peers[right].contains(c)),
          );
          if (step != null) return step;
        }
      }
    }
    return null;
  }

  static LogicalStep? _subset(
    List<int> masks,
    int size, {
    required bool hidden,
  }) {
    final technique = hidden
        ? (size == 2 ? SolveTechnique.hiddenPair : SolveTechnique.hiddenTriple)
        : (size == 2 ? SolveTechnique.nakedPair : SolveTechnique.nakedTriple);
    for (final unit in _units) {
      final items = hidden
          ? [
              for (var d = 1; d <= 9; d++)
                if (unit.any((c) => masks[c] & (1 << d) != 0)) d,
            ]
          : [
              for (final c in unit)
                if (masks[c].oneBitCount >= 2 && masks[c].oneBitCount <= size)
                  c,
            ];
      for (var a = 0; a < items.length; a++) {
        for (var b = a + 1; b < items.length; b++) {
          for (var k = size == 2 ? b : b + 1; k < items.length; k++) {
            final selected = [items[a], items[b], if (size == 3) items[k]];
            var digits = 0;
            for (final item in selected) {
              digits |= hidden ? 1 << item : masks[item];
            }
            final cells = hidden
                ? [
                    for (final c in unit)
                      if (masks[c] & digits != 0) c,
                  ]
                : selected;
            if (cells.length == size && digits.oneBitCount == size) {
              final step = _eliminate(
                masks,
                technique,
                cells,
                hidden ? _all & ~digits : digits,
                hidden ? cells : unit.where((c) => !cells.contains(c)),
              );
              if (step != null) {
                return LogicalStep(
                  technique: technique,
                  cells: cells,
                  digits: digits,
                  removals: step.removals,
                );
              }
            }
            if (size == 2) break;
          }
        }
      }
    }
    return null;
  }

  static LogicalStep? _xWing(List<int> masks) {
    for (var orientation = 0; orientation < 2; orientation++) {
      int cell(int base, int cross) =>
          orientation == 0 ? base * 9 + cross : cross * 9 + base;
      for (var digit = 1; digit <= 9; digit++) {
        final bit = 1 << digit;
        final positions = [
          for (var base = 0; base < 9; base++)
            [
              for (var cross = 0; cross < 9; cross++)
                if (masks[cell(base, cross)] & bit != 0) cross,
            ],
        ];
        for (var a = 0; a < 9; a++) {
          if (positions[a].length != 2) continue;
          for (var b = a + 1; b < 9; b++) {
            if (positions[b].length != 2 ||
                positions[a][0] != positions[b][0] ||
                positions[a][1] != positions[b][1]) {
              continue;
            }
            final step = _eliminate(
              masks,
              SolveTechnique.xWing,
              [
                for (final base in [a, b])
                  for (final cross in positions[a]) cell(base, cross),
              ],
              bit,
              [
                for (var base = 0; base < 9; base++)
                  if (base != a && base != b)
                    for (final cross in positions[a]) cell(base, cross),
              ],
            );
            if (step != null) return step;
          }
        }
      }
    }
    return null;
  }
}
