import 'package:cue/cue.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../domain/sudoku_grid.dart';
import '../board_palette.dart';
import 'board_digit.dart';

final class const AutoFillDigit({
  required final int order,
  required final Widget child,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (order < 0) return child;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return Actor(
      key: ValueKey('auto-fill-reveal-$order'),
      delay: reducedMotion ? Duration.zero : autoFillRevealDelay(order),
      acts: [.fadeIn(), .scale(from: .72), .slideY(from: .16)],
      child: child,
    );
  }
}

const _autoFillStaggerMilliseconds = 500;
const autoFillMotionMilliseconds = 300;
const _autoFillCompletionPauseMilliseconds = 250;

Duration autoFillRevealDelay(int order) => Duration(
  milliseconds: order < 0 ? 0 : order * _autoFillStaggerMilliseconds,
);

Duration autoFillSequenceDuration(int count) => count <= 0
    ? Duration.zero
    : Duration(
        milliseconds:
            (count - 1) * _autoFillStaggerMilliseconds +
            autoFillMotionMilliseconds +
            _autoFillCompletionPauseMilliseconds,
      );

final class const SudokuCompletionFlash({
  required final Animation<double> animation,
  required final Set<int> cells,
  required final int origin,
  required final List<int> values,
  required final double cellSize,
  required final BoardPalette palette,
  super.key,
}) extends StatelessWidget {
  static const durationMilliseconds = 2100;
  static const delayMilliseconds = 500;
  static const staggerMilliseconds = 90;
  static const _enterMilliseconds = 260;
  static const _holdMilliseconds = 240;
  static const _exitMilliseconds = 320;

  double _tiltDirection(int cell) {
    final rowDelta = rowOf(cell) - rowOf(origin),
        columnDelta = columnOf(cell) - columnOf(origin);
    if (columnDelta != 0) return columnDelta.sign.toDouble();
    if (rowDelta != 0) return -rowDelta.sign.toDouble();

    final center = sudokuSideLength ~/ 2;
    final originColumn = columnOf(origin);
    if (originColumn != center) return originColumn < center ? 1 : -1;
    return rowOf(origin) <= center ? 1 : -1;
  }

  ({double opacity, double shape, double angle}) _visual(int cell) {
    if (origin < 0) return (opacity: 0, shape: 1, angle: 0);
    final distance = _completionWaveDistance(cell, origin);
    final tilt = _tiltDirection(cell);
    final elapsed =
        animation.value * durationMilliseconds -
        delayMilliseconds -
        distance * staggerMilliseconds;
    if (elapsed <= 0 ||
        elapsed >= _enterMilliseconds + _holdMilliseconds + _exitMilliseconds) {
      return (opacity: 0, shape: 1, angle: -.0872665);
    }
    if (elapsed < _enterMilliseconds) {
      final linearProgress = elapsed / _enterMilliseconds;
      final shapeProgress = Curves.easeInOutCubic.transform(linearProgress);
      final rotationProgress = Curves.easeOutCubic.transform(linearProgress);
      return (
        opacity: Curves.easeOutCubic.transform(linearProgress),
        shape: 1 - shapeProgress,
        angle: .0558505 * tilt * (1 - rotationProgress),
      );
    }
    if (elapsed < _enterMilliseconds + _holdMilliseconds) {
      return (opacity: 1, shape: 0, angle: 0);
    }
    final progress = Curves.easeInOutCubic.transform(
      (elapsed - _enterMilliseconds - _holdMilliseconds) / _exitMilliseconds,
    );
    final opacity = progress < .25
        ? 1.0
        : 1 - Curves.easeInCubic.transform((progress - .25) / .75);
    final angle = progress < .35
        ? .0453786 * tilt * Curves.easeOutCubic.transform(progress / .35)
        : .0453786 * tilt +
              (-.0610865 * tilt - .0453786 * tilt) *
                  Curves.easeInOutCubic.transform((progress - .35) / .65);
    return (opacity: opacity, shape: progress, angle: angle);
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Stack(
        children: [
          for (final cell in cells)
            _CompletionTile(
              cell: cell,
              value: values[cell],
              cellSize: cellSize,
              palette: palette,
              visual: _visual(cell),
            ),
        ],
      ),
    ),
  );
}

final class const _CompletionTile({
  required final int cell,
  required final int value,
  required final double cellSize,
  required final BoardPalette palette,
  required final ({double opacity, double shape, double angle}) visual,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final inset = cellSize * .13 * visual.shape;
    return Positioned(
      key: ValueKey('completion-flash-$cell'),
      left: columnOf(cell) * cellSize + inset,
      top: rowOf(cell) * cellSize + inset,
      width: cellSize - inset * 2,
      height: cellSize - inset * 2,
      child: Opacity(
        opacity: visual.opacity,
        child: Transform.rotate(
          angle: visual.angle,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.accent,
              borderRadius: .circular(cellSize * .16 * visual.shape),
            ),
            child: Center(
              child: BoardDigit(
                '$value',
                style: context.rudiTheme.text.title.copyWith(
                  fontSize: cellSize * .56,
                  height: 1,
                  color: palette.onSelected,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Set<int> completionFlashCells(
  List<int> previous,
  List<int> current,
  List<int> solution,
) {
  assert(
    previous.length == sudokuCellCount &&
        current.length == sudokuCellCount &&
        solution.length == sudokuCellCount,
  );
  if (!current.contains(0) &&
      !listEquals(previous, solution) &&
      listEquals(current, solution)) {
    return {for (var cell = 0; cell < sudokuCellCount; cell++) cell};
  }

  final cells = <int>{};
  void addCorrectlyCompletedUnit(List<int> unit) {
    if (unit.any((cell) => previous[cell] != solution[cell]) &&
        unit.every((cell) => current[cell] == solution[cell])) {
      cells.addAll(unit);
    }
  }

  for (var digit = 1; digit <= sudokuSideLength; digit++) {
    addCorrectlyCompletedUnit([
      for (var cell = 0; cell < sudokuCellCount; cell++)
        if (solution[cell] == digit) cell,
    ]);
  }
  for (final type in SudokuUnitType.values) {
    for (var index = 0; index < sudokuSideLength; index++) {
      addCorrectlyCompletedUnit(SudokuUnit(type, index).cells.toList());
    }
  }
  return cells;
}

List<int> autoFillRevealCells(
  List<int> previous,
  List<int> current,
  List<int> solution, {
  required int preferredOrigin,
}) {
  assert(
    previous.length == sudokuCellCount &&
        current.length == sudokuCellCount &&
        solution.length == sudokuCellCount,
  );
  if (!listEquals(current, solution)) return const [];
  final changedCells = [
    for (var cell = 0; cell < sudokuCellCount; cell++)
      if (previous[cell] != current[cell] && current[cell] == solution[cell])
        cell,
  ];
  if (changedCells.length < 2 || !changedCells.contains(preferredOrigin)) {
    return const [];
  }
  final automaticCells =
      changedCells
          .where((cell) => cell != preferredOrigin && previous[cell] == 0)
          .toList()
        ..sort((a, b) {
          final distance = _completionWaveDistance(
            a,
            preferredOrigin,
          ).compareTo(_completionWaveDistance(b, preferredOrigin));
          return distance != 0 ? distance : a.compareTo(b);
        });
  return List.unmodifiable(automaticCells);
}

int completionFlashOrigin(
  List<int> previous,
  List<int> current, {
  required int preferredOrigin,
}) {
  assert(
    previous.length == sudokuCellCount && current.length == sudokuCellCount,
  );
  final enteredCells = [
    for (var cell = 0; cell < sudokuCellCount; cell++)
      if (previous[cell] != current[cell] && current[cell] != 0) cell,
  ];
  if (enteredCells.isEmpty) return -1;
  if (!current.contains(0) && enteredCells.length > 1) {
    return enteredCells.firstWhere(
      (cell) => cell != preferredOrigin && previous[cell] == 0,
      orElse: () => enteredCells.first,
    );
  }
  return enteredCells.contains(preferredOrigin)
      ? preferredOrigin
      : enteredCells.first;
}

List<Duration> completionHapticMoments(Set<int> cells, int origin) {
  if (origin < 0 || cells.isEmpty) return const [];
  final distances = <int>{
    for (final cell in cells) _completionWaveDistance(cell, origin),
  }.toList()..sort();
  return [
    for (final distance in distances)
      Duration(
        milliseconds:
            SudokuCompletionFlash.delayMilliseconds +
            distance * SudokuCompletionFlash.staggerMilliseconds,
      ),
  ];
}

int _completionWaveDistance(int cell, int origin) {
  final rowDistance = (rowOf(cell) - rowOf(origin)).abs(),
      columnDistance = (columnOf(cell) - columnOf(origin)).abs();
  return rowDistance > columnDistance ? rowDistance : columnDistance;
}
