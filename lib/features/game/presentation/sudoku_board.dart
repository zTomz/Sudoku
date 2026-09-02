import 'dart:async';

import 'package:cue/cue.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../app/sudoku_controller.dart';
import '../domain/game_session.dart';
import '../domain/sudoku_grid.dart';
import 'board_palette.dart';
import 'widgets/sudoku_cell.dart';
import 'widgets/sudoku_completion_effects.dart';
import 'widgets/sudoku_hint_visual.dart';

export 'widgets/sudoku_hint_visual.dart';
export 'widgets/sudoku_completion_effects.dart'
    show
        autoFillRevealCells,
        autoFillRevealDelay,
        autoFillSequenceDuration,
        completionFlashCells,
        completionFlashOrigin,
        completionHapticMoments;

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
      milliseconds: SudokuCompletionFlash.durationMilliseconds,
    ),
  )..addListener(_handleFlashTick);
  Set<int> _flashCells = const {};
  List<int> _autoFillCells = const [];
  int _flashOrigin = -1;
  List<Duration> _hapticMoments = const [];
  int _nextHapticMoment = 0;
  Timer? _flashDelayTimer;

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
    _autoFillCells = autoFillRevealCells(
      oldWidget.game.values,
      widget.game.values,
      widget.game.puzzle.solution,
      preferredOrigin: widget.controller.selected,
    );
    _flashCells = completionFlashCells(
      oldWidget.game.values,
      widget.game.values,
      widget.game.puzzle.solution,
    );
    _flashOrigin = completionFlashOrigin(
      oldWidget.game.values,
      widget.game.values,
      preferredOrigin: widget.controller.selected,
    );
    _hapticMoments = completionHapticMoments(_flashCells, _flashOrigin);
    _nextHapticMoment = 0;
    _flashDelayTimer?.cancel();
    if (_flashCells.isEmpty || MediaQuery.disableAnimationsOf(context)) {
      _flashAnimation.value = 0;
    } else if (_autoFillCells.isNotEmpty) {
      _flashAnimation.value = 0;
      _flashDelayTimer = Timer(
        autoFillSequenceDuration(_autoFillCells.length),
        () {
          if (mounted) _flashAnimation.forward(from: 0);
        },
      );
    } else {
      _flashAnimation.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _flashDelayTimer?.cancel();
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
          final cellSize = constraints.maxWidth / sudokuSideLength;
          return ClipRect(
            child: Stack(
              fit: .expand,
              children: [
                Cue.onChange(
                  value: game.cursor,
                  motion: MediaQuery.disableAnimationsOf(context)
                      ? CueMotion.none
                      : .easeOut(
                          const Duration(
                            milliseconds: autoFillMotionMilliseconds,
                          ),
                        ),
                  child: CustomPaint(
                    child: ColoredBox(
                      color: palette.background,
                      child: Column(
                        children: [
                          for (var row = 0; row < sudokuSideLength; row++)
                            Expanded(
                              child: Row(
                                children: [
                                  for (
                                    var col = 0;
                                    col < sudokuSideLength;
                                    col++
                                  )
                                    Expanded(
                                      child: SudokuCell(
                                        controller: controller,
                                        game: game,
                                        hint: hint,
                                        palette: palette,
                                        row: row,
                                        col: col,
                                        selected: selected,
                                        activeDigit: activeDigit,
                                        autoFillOrder: _autoFillCells.indexOf(
                                          cellAt(row, col),
                                        ),
                                        cellSize: cellSize,
                                        obscured: obscured,
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
                SudokuCompletionFlash(
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
