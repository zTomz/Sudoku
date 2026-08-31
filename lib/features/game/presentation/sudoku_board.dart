import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../app/sudoku_controller.dart';
import '../../../common/presentation/ui.dart';
import '../domain/game_session.dart';
import '../../settings/domain/app_settings.dart';
import 'board_palette.dart';

final class const SudokuBoard({
  required final SudokuController controller,
  required final GameSession game,
  final bool obscured = false,
  super.key,
}) extends StatefulWidget {
  @override
  State<SudokuBoard> createState() => _SudokuBoardState();
}

final class _SudokuBoardState()
    extends State<SudokuBoard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flashAnimation = AnimationController(
    vsync: this,
    duration: const Duration(
      milliseconds: _CompletionFlash.durationMilliseconds,
    ),
  );
  Set<int> _flashCells = const {};
  int _flashOrigin = -1;

  @override
  void didUpdateWidget(covariant SudokuBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (listEquals(oldWidget.game.values, widget.game.values)) return;
    _flashCells = completionFlashCells(
      oldWidget.game.values,
      widget.game.values,
    );
    _flashOrigin = List.generate(81, (cell) => cell).firstWhere(
      (cell) =>
          oldWidget.game.values[cell] != widget.game.values[cell] &&
          widget.game.values[cell] != 0,
      orElse: () => -1,
    );
    if (_flashCells.isEmpty || MediaQuery.disableAnimationsOf(context)) {
      _flashAnimation.value = 0;
    } else {
      _flashAnimation.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _flashAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game,
        controller = widget.controller,
        obscured = widget.obscured,
        selected = obscured ? -1 : controller.selected;
    final palette = BoardPalette.resolve(
      controller.settings.boardTheme,
      context.rudiTheme.brightness,
      highContrast: MediaQuery.highContrastOf(context),
      accentColor: context.rudiTheme.colors.accent,
    );
    final activeDigit = obscured
        ? 0
        : controller.settings.numberFirst
        ? controller.selectedDigit
        : selected < 0
        ? 0
        : game.values[selected];
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellSize = constraints.maxWidth / 9;
          return ClipRect(
            child: Stack(
              fit: .expand,
              children: [
                CustomPaint(
                  child: ColoredBox(
                    color: palette.background,
                    child: Column(
                      children: [
                        for (var row = 0; row < 9; row++)
                          Expanded(
                            child: Row(
                              children: [
                                for (var col = 0; col < 9; col++)
                                  Expanded(
                                    child: Builder(
                                      builder: (context) {
                                        final cell = row * 9 + col,
                                            value = game.values[cell],
                                            notes = game.notes[cell];
                                        final given =
                                                game.puzzle.givens[cell] != 0,
                                            isSelected = selected == cell;
                                        final related =
                                            selected >= 0 &&
                                            (selected ~/ 9 == row ||
                                                selected % 9 == col ||
                                                (selected ~/ 27 == row ~/ 3 &&
                                                    selected % 9 ~/ 3 ==
                                                        col ~/ 3));
                                        final same =
                                            value != 0 && value == activeDigit;
                                        final error =
                                            !obscured &&
                                            game.isIncorrect(cell) &&
                                            switch (controller
                                                .settings
                                                .errorCheck) {
                                              ErrorCheck.off => false,
                                              ErrorCheck.conflicts =>
                                                game.hasConflict(cell),
                                              ErrorCheck.solution => true,
                                            };
                                        final candidates = [
                                          for (var n = 1; n <= 9; n++)
                                            if (notes & (1 << n) != 0) n,
                                        ];
                                        final description = value != 0
                                            ? (given
                                                  ? context.l10n.givenValue(
                                                      value,
                                                    )
                                                  : context.l10n.enteredValue(
                                                      value,
                                                    ))
                                            : notes == 0
                                            ? context.l10n.emptyCell
                                            : context.l10n.candidates(
                                                candidates.join(', '),
                                              );
                                        return Semantics(
                                          selected: isSelected,
                                          value:
                                              '$description${error ? ', ${context.l10n.incorrectValue}' : ''}',
                                          child: RudiPressable(
                                            key: ValueKey('cell-$cell'),
                                            semanticLabel: context.l10n
                                                .cellLabel(row + 1, col + 1),
                                            onPressed: obscured
                                                ? null
                                                : () => controller.selectCell(
                                                    cell,
                                                  ),
                                            builder: (context, state) => AnimatedContainer(
                                              duration:
                                                  MediaQuery.disableAnimationsOf(
                                                    context,
                                                  )
                                                  ? Duration.zero
                                                  : const Duration(
                                                      milliseconds: 150,
                                                    ),
                                              curve: Curves.easeOutCubic,
                                              color: isSelected
                                                  ? palette.selected
                                                  : same
                                                  ? palette.same
                                                  : related ||
                                                        state.hovered ||
                                                        state.focused
                                                  ? palette.related
                                                  : palette.background,
                                              child: obscured
                                                  ? const SizedBox.expand()
                                                  : ExcludeSemantics(
                                                      child: Center(
                                                        child: value != 0
                                                            ? _BoardDigit(
                                                                '$value',
                                                                style: context.rudiTheme.text.title.copyWith(
                                                                  fontSize:
                                                                      cellSize *
                                                                      .56,
                                                                  height: 1,
                                                                  color:
                                                                      isSelected
                                                                      ? palette
                                                                            .onSelected
                                                                      : error
                                                                      ? const Color(
                                                                          0xffd5505b,
                                                                        )
                                                                      : given
                                                                      ? palette
                                                                            .ink
                                                                      : palette
                                                                            .accent,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  decoration:
                                                                      error
                                                                      ? TextDecoration
                                                                            .underline
                                                                      : null,
                                                                ),
                                                              )
                                                            : Padding(
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      2,
                                                                    ),
                                                                child: Column(
                                                                  children: [
                                                                    for (
                                                                      var r = 0;
                                                                      r < 3;
                                                                      r++
                                                                    )
                                                                      Expanded(
                                                                        child: Row(
                                                                          children: [
                                                                            for (
                                                                              var c = 0;
                                                                              c < 3;
                                                                              c++
                                                                            )
                                                                              Expanded(
                                                                                child: Center(
                                                                                  child: _BoardDigit(
                                                                                    notes & (1 << (r * 3 + c + 1)) != 0 ? '${r * 3 + c + 1}' : '',
                                                                                    style: context.rudiTheme.text.caption.copyWith(
                                                                                      fontSize: cellSize * .23,
                                                                                      height: 1,
                                                                                      color: isSelected ? palette.onSelected : palette.note,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ),
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                _CompletionFlash(
                  animation: _flashAnimation,
                  cells: _flashCells,
                  origin: _flashOrigin,
                  values: game.values,
                  cellSize: cellSize,
                  palette: palette,
                ),
                IgnorePointer(
                  child: CustomPaint(
                    key: const ValueKey('board-grid'),
                    foregroundPainter: SudokuGridPainter(
                      palette: palette,
                      pixelRatio: MediaQuery.devicePixelRatioOf(context),
                      selected: selected,
                      highContrast: MediaQuery.highContrastOf(context),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

final class const _CompletionFlash({
  required final Animation<double> animation,
  required final Set<int> cells,
  required final int origin,
  required final List<int> values,
  required final double cellSize,
  required final BoardPalette palette,
}) extends StatelessWidget {
  static const durationMilliseconds = 2100;
  static const _delayMilliseconds = 500;
  static const _staggerMilliseconds = 90;
  static const _enterMilliseconds = 260;
  static const _holdMilliseconds = 240;
  static const _exitMilliseconds = 320;

  double _tiltDirection(int cell) {
    final rowDelta = cell ~/ 9 - origin ~/ 9,
        columnDelta = cell % 9 - origin % 9;
    if (columnDelta != 0) return columnDelta.sign.toDouble();
    if (rowDelta != 0) return -rowDelta.sign.toDouble();

    final originColumn = origin % 9;
    if (originColumn != 4) return originColumn < 4 ? 1 : -1;
    return origin ~/ 9 <= 4 ? 1 : -1;
  }

  ({double opacity, double shape, double angle}) _visual(int cell) {
    if (origin < 0) return (opacity: 0, shape: 1, angle: 0);
    final rowDistance = (cell ~/ 9 - origin ~/ 9).abs(),
        columnDistance = (cell % 9 - origin % 9).abs(),
        distance = rowDistance > columnDistance ? rowDistance : columnDistance;
    final tilt = _tiltDirection(cell);
    final elapsed =
        animation.value * durationMilliseconds -
        _delayMilliseconds -
        distance * _staggerMilliseconds;
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
      left: cell % 9 * cellSize + inset,
      top: cell ~/ 9 * cellSize + inset,
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
              child: _BoardDigit(
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

@visibleForTesting
Set<int> completionFlashCells(List<int> previous, List<int> current) {
  assert(previous.length == 81 && current.length == 81);
  final previousCounts = List<int>.filled(10, 0),
      currentCounts = List<int>.filled(10, 0);
  for (var cell = 0; cell < 81; cell++) {
    previousCounts[previous[cell]]++;
    currentCounts[current[cell]]++;
  }
  final completedDigits = {
    for (var digit = 1; digit <= 9; digit++)
      if (previousCounts[digit] < 9 && currentCounts[digit] == 9) digit,
  };
  final cells = <int>{
    for (var cell = 0; cell < 81; cell++)
      if (completedDigits.contains(current[cell])) cell,
  };
  void addCompletedUnit(List<int> unit) {
    if (unit.any((cell) => previous[cell] == 0) &&
        unit.every((cell) => current[cell] != 0)) {
      cells.addAll(unit);
    }
  }

  for (var row = 0; row < 9; row++) {
    addCompletedUnit([for (var col = 0; col < 9; col++) row * 9 + col]);
  }
  for (var col = 0; col < 9; col++) {
    addCompletedUnit([for (var row = 0; row < 9; row++) row * 9 + col]);
  }
  for (var box = 0; box < 9; box++) {
    final boxCells = [
      for (var row = box ~/ 3 * 3; row < box ~/ 3 * 3 + 3; row++)
        for (var col = box % 3 * 3; col < box % 3 * 3 + 3; col++) row * 9 + col,
    ];
    addCompletedUnit(boxCells);
  }
  return cells;
}

final class const _BoardDigit(
  final String value, {
  required final TextStyle style,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Text(
    value,
    style: style.copyWith(letterSpacing: 0),
    textAlign: TextAlign.center,
    textHeightBehavior: const TextHeightBehavior(
      leadingDistribution: TextLeadingDistribution.even,
    ),
    textScaler: TextScaler.noScaling,
    maxLines: 1,
    softWrap: false,
  );
}
