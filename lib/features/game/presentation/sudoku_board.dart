import 'dart:async';

import 'package:cue/cue.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../app/sudoku_controller.dart';
import '../../settings/domain/app_settings.dart';
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
  final ValueChanged<int>? onSelectCell,
  final bool obscured = false,
  final bool showSelection = true,
  final SudokuHintVisual? hint,
  super.key,
}) extends StatefulWidget {
  @override
  State<SudokuBoard> createState() => _SudokuBoardState();
}

/// The shared visual Sudoku surface used by both games and learning examples.
///
/// Keeping this renderer independent from a game session lets teaching content
/// use the exact same cells, palette, grid, selection and value transitions
/// without creating a score-bearing game.
final class const SudokuBoardView({
  required final List<int> values,
  required final List<int> notes,
  required final List<int> givens,
  required final BoardTheme boardTheme,
  final Set<int> incorrectCells = const {},
  final ValueChanged<int>? onSelectCell,
  final int selected = -1,
  final int activeDigit = 0,
  final bool obscured = false,
  final bool showSelection = true,
  final SudokuHintVisual? hint,
  final Object revision = 0,
  final List<int> autoFillCells = const [],
  final Animation<double>? completionAnimation,
  final Set<int> completionCells = const {},
  final int completionOrigin = -1,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = BoardPalette.resolve(
      boardTheme,
      context.rudiTheme.brightness,
      highContrast: MediaQuery.highContrastOf(context),
      accentColor: context.rudiTheme.colors.accent,
    );
    final visibleHint = obscured ? null : hint;
    final visibleSelected = !obscured && showSelection ? selected : -1;
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
                  value: revision,
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
                                        values: values,
                                        notes: notes,
                                        givens: givens,
                                        incorrectCells: incorrectCells,
                                        onSelectCell: onSelectCell,
                                        hint: visibleHint,
                                        palette: palette,
                                        row: row,
                                        col: col,
                                        selected: visibleSelected,
                                        activeDigit: activeDigit,
                                        autoFillOrder: autoFillCells.indexOf(
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
                if (completionAnimation != null)
                  SudokuCompletionFlash(
                    animation: completionAnimation!,
                    cells: completionCells,
                    origin: completionOrigin,
                    values: values,
                    cellSize: cellSize,
                    palette: palette,
                  ),
                IgnorePointer(
                  child: Cue.onToggle(
                    key: const ValueKey('selection-visibility'),
                    toggled: !obscured && showSelection,
                    motion: MediaQuery.disableAnimationsOf(context)
                        ? CueMotion.none
                        : .easeOut(const Duration(milliseconds: 240)),
                    acts: const [.opacity(from: 0, to: 1)],
                    child: CustomPaint(
                      key: const ValueKey('board-selection'),
                      foregroundPainter: SudokuSelectionPainter(
                        palette: palette,
                        selected: selected,
                      ),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: CustomPaint(
                    key: const ValueKey('board-grid'),
                    foregroundPainter: SudokuGridPainter(
                      palette: palette,
                      pixelRatio: MediaQuery.devicePixelRatioOf(context),
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
      autoFillCells: _autoFillCells,
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
        selectionVisible = !obscured && widget.showSelection,
        selected = selectionVisible ? controller.selected : -1;
    final activeDigit = obscured
        ? 0
        : controller.settings.numberFirst
        ? controller.selectedDigit
        : selected < 0
        ? 0
        : game.values[selected];
    final incorrectCells = <int>{
      for (var cell = 0; cell < sudokuCellCount; cell++)
        if (!obscured &&
            game.isIncorrect(cell) &&
            switch (controller.settings.errorCheck) {
              ErrorCheck.off => false,
              ErrorCheck.conflicts => game.hasConflict(cell),
              ErrorCheck.solution => true,
            })
          cell,
    };
    return SudokuBoardView(
      values: game.values,
      notes: game.notes,
      givens: game.puzzle.givens,
      boardTheme: controller.settings.boardTheme,
      incorrectCells: incorrectCells,
      onSelectCell: widget.onSelectCell ?? controller.selectCell,
      selected: selected,
      activeDigit: activeDigit,
      obscured: obscured,
      showSelection: widget.showSelection,
      hint: hint,
      revision: game.cursor,
      autoFillCells: _autoFillCells,
      completionAnimation: _flashAnimation,
      completionCells: _flashCells,
      completionOrigin: _flashOrigin,
    );
  }
}
