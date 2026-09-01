import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../app/sudoku_controller.dart';
import '../../../common/presentation/ui.dart';
import '../domain/game_session.dart';
import '../../settings/domain/app_settings.dart';
import 'board_palette.dart';

@immutable
final class const SudokuHintVisual._(
  final Set<int> cells,
  final Map<int, int> candidates,
  final Map<int, int> removals,
  final int? focus,
  final int? placement,
  final int? digit,
) {
  factory({
    required Set<int> cells,
    Map<int, int> candidates = const {},
    Map<int, int> removals = const {},
    int? focus,
    int? placement,
    int? digit,
  }) => SudokuHintVisual._(
    Set.unmodifiable(cells),
    Map.unmodifiable(candidates),
    Map.unmodifiable(removals),
    focus,
    placement,
    digit,
  );
}

final class const SudokuBoard({
  required final SudokuController controller,
  required final GameSession game,
  final bool obscured = false,
  final SudokuHintVisual? hint,
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
  )..addListener(_handleFlashTick);
  Set<int> _flashCells = const {};
  int _flashOrigin = -1;
  List<Duration> _hapticMoments = const [];
  int _nextHapticMoment = 0;

  void _handleFlashTick() {
    if (_nextHapticMoment >= _hapticMoments.length) return;
    final elapsed = _flashAnimation.lastElapsedDuration ?? Duration.zero;
    if (elapsed < _hapticMoments[_nextHapticMoment]) return;

    do {
      _nextHapticMoment++;
    } while (_nextHapticMoment < _hapticMoments.length &&
        elapsed >= _hapticMoments[_nextHapticMoment]);
    if (widget.controller.settings.haptics) {
      unawaited(HapticFeedback.lightImpact());
    }
  }

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
    _hapticMoments = completionHapticMoments(_flashCells, _flashOrigin);
    _nextHapticMoment = 0;
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
        hint = obscured ? null : widget.hint,
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
                                            isSelected = selected == cell,
                                            hintFocused = hint?.focus == cell,
                                            hintHighlighted =
                                                hint?.cells.contains(cell) ==
                                                    true ||
                                                hint?.removals.containsKey(
                                                      cell,
                                                    ) ==
                                                    true,
                                            hintResult =
                                                hint?.placement == cell &&
                                                hint?.digit != null,
                                            hintCandidateMask =
                                                hint?.candidates[cell] ?? 0,
                                            hintRemovalMask =
                                                hint?.removals[cell] ?? 0,
                                            hintMask =
                                                hintCandidateMask |
                                                hintRemovalMask;
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
                                        String digitsIn(int mask) => [
                                          for (
                                            var digit = 1;
                                            digit <= 9;
                                            digit++
                                          )
                                            if (mask & (1 << digit) != 0) digit,
                                        ].join(', ');
                                        final hintDetails = [
                                          if (hintCandidateMask != 0)
                                            context.l10n.hintBoardCandidates(
                                              digitsIn(hintCandidateMask),
                                            ),
                                          if (hintRemovalMask != 0)
                                            context.l10n.hintBoardRemoved(
                                              digitsIn(hintRemovalMask),
                                            ),
                                        ];
                                        final hintDescription = hintResult
                                            ? context.l10n.hintBoardResult(
                                                hint!.digit!,
                                              )
                                            : hintDetails.isNotEmpty
                                            ? hintDetails.join(', ')
                                            : hintHighlighted
                                            ? context.l10n.hintBoardRelevant
                                            : null;
                                        return Semantics(
                                          key: hintResult
                                              ? ValueKey('hint-result-$cell')
                                              : hintFocused
                                              ? ValueKey('hint-focus-$cell')
                                              : hintHighlighted
                                              ? ValueKey('hint-cell-$cell')
                                              : null,
                                          selected: isSelected,
                                          value:
                                              '$description${error ? ', ${context.l10n.incorrectValue}' : ''}${hintDescription == null ? '' : ', $hintDescription'}',
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
                                                      milliseconds: 240,
                                                    ),
                                              curve: Curves.easeOutCubic,
                                              color: isSelected
                                                  ? palette.selected
                                                  : hintResult
                                                  ? palette.same
                                                  : hintFocused
                                                  ? palette.same
                                                  : hintHighlighted
                                                  ? Color.alphaBlend(
                                                      palette.accent.withValues(
                                                        alpha: .14,
                                                      ),
                                                      palette.background,
                                                    )
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
                                                        child: AnimatedSwitcher(
                                                          duration:
                                                              MediaQuery.disableAnimationsOf(
                                                                context,
                                                              )
                                                              ? Duration.zero
                                                              : const Duration(
                                                                  milliseconds:
                                                                      220,
                                                                ),
                                                          switchInCurve: Curves
                                                              .easeOutCubic,
                                                          switchOutCurve: Curves
                                                              .easeInCubic,
                                                          transitionBuilder:
                                                              (
                                                                child,
                                                                animation,
                                                              ) => FadeTransition(
                                                                opacity:
                                                                    animation,
                                                                child: ScaleTransition(
                                                                  scale:
                                                                      Tween(
                                                                        begin:
                                                                            .96,
                                                                        end:
                                                                            1.0,
                                                                      ).animate(
                                                                        animation,
                                                                      ),
                                                                  child: child,
                                                                ),
                                                              ),
                                                          child: value != 0
                                                              ? _BoardDigit(
                                                                  '$value',
                                                                  key: ValueKey(
                                                                    'value-$cell-$value',
                                                                  ),
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
                                                              : hintResult
                                                              ? _BoardDigit(
                                                                  '${hint!.digit!}',
                                                                  key: ValueKey(
                                                                    'hint-answer-$cell-${hint.digit}',
                                                                  ),
                                                                  style: context.rudiTheme.text.title.copyWith(
                                                                    fontSize:
                                                                        cellSize *
                                                                        .56,
                                                                    height: 1,
                                                                    color:
                                                                        isSelected
                                                                        ? palette
                                                                              .onSelected
                                                                        : palette
                                                                              .accent,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                )
                                                              : _BoardCandidates(
                                                                  key: ValueKey(
                                                                    'candidates-$cell-$hintMask-$hintRemovalMask-${hintMask != 0}',
                                                                  ),
                                                                  mask:
                                                                      hintMask !=
                                                                          0
                                                                      ? hintMask
                                                                      : notes,
                                                                  removalMask:
                                                                      hintRemovalMask,
                                                                  isHint:
                                                                      hintMask !=
                                                                      0,
                                                                  selected:
                                                                      isSelected,
                                                                  cell: cell,
                                                                  cellSize:
                                                                      cellSize,
                                                                  palette:
                                                                      palette,
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

final class const _BoardCandidates({
  required final int mask,
  required final int removalMask,
  required final bool isHint,
  required final bool selected,
  required final int cell,
  required final double cellSize,
  required final BoardPalette palette,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const .all(2),
    child: Column(
      children: [
        for (var row = 0; row < 3; row++)
          Expanded(
            child: Row(
              children: [
                for (var column = 0; column < 3; column++)
                  Expanded(
                    child: Center(
                      child: Builder(
                        builder: (context) {
                          final digit = row * 3 + column + 1;
                          final visible = mask & (1 << digit) != 0;
                          final removed = removalMask & (1 << digit) != 0;
                          return _BoardDigit(
                            visible ? '$digit' : '',
                            key: isHint && visible
                                ? ValueKey(
                                    '${removed ? 'hint-removal' : 'hint-candidate'}-$cell-$digit',
                                  )
                                : null,
                            style: context.rudiTheme.text.caption.copyWith(
                              fontSize: cellSize * .23,
                              height: 1,
                              color: selected
                                  ? palette.onSelected
                                  : removed
                                  ? palette.note.withValues(alpha: .55)
                                  : isHint
                                  ? palette.accent
                                  : palette.note,
                              fontWeight: isHint ? .w600 : null,
                              decoration: removed
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: palette.accent,
                              decorationThickness: 2,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    ),
  );
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
  static const delayMilliseconds = 500;
  static const staggerMilliseconds = 90;
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

@visibleForTesting
List<Duration> completionHapticMoments(Set<int> cells, int origin) {
  if (origin < 0 || cells.isEmpty) return const [];
  final distances = <int>{
    for (final cell in cells) _completionWaveDistance(cell, origin),
  }.toList()..sort();
  return [
    for (final distance in distances)
      Duration(
        milliseconds:
            _CompletionFlash.delayMilliseconds +
            distance * _CompletionFlash.staggerMilliseconds,
      ),
  ];
}

int _completionWaveDistance(int cell, int origin) {
  final rowDistance = (cell ~/ 9 - origin ~/ 9).abs(),
      columnDistance = (cell % 9 - origin % 9).abs();
  return rowDistance > columnDistance ? rowDistance : columnDistance;
}

final class const _BoardDigit(
  final String value, {
  required final TextStyle style,
  super.key,
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
