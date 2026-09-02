import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../../app/sudoku_controller.dart';
import '../../../../common/presentation/ui.dart';
import '../../../settings/domain/app_settings.dart';
import '../../domain/game_session.dart';
import '../../domain/sudoku_grid.dart';
import '../board_palette.dart';
import 'board_digit.dart';
import 'sudoku_completion_effects.dart';
import 'sudoku_hint_visual.dart';

final class const SudokuCell({
  required final SudokuController controller,
  required final GameSession game,
  required final SudokuHintVisual? hint,
  required final BoardPalette palette,
  required final int row,
  required final int col,
  required final int selected,
  required final int activeDigit,
  required final int autoFillOrder,
  required final double cellSize,
  required final bool obscured,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final visualHint = hint;
    final cell = cellAt(row, col),
        value = game.values[cell],
        notes = game.notes[cell];
    final given = game.puzzle.givens[cell] != 0,
        isSelected = selected == cell,
        hintFocused = visualHint?.focus == cell,
        hintHighlighted =
            visualHint?.cells.contains(cell) == true ||
            visualHint?.removals.containsKey(cell) == true,
        hintResult = visualHint?.placement == cell && visualHint?.digit != null,
        hintCandidateMask = visualHint?.candidates[cell] ?? 0,
        hintRemovalMask = visualHint?.removals[cell] ?? 0,
        hintMask = hintCandidateMask | hintRemovalMask;
    final related = selected >= 0 && cellsShareUnit(selected, cell);
    final same = value != 0 && value == activeDigit;
    final error =
        !obscured &&
        game.isIncorrect(cell) &&
        switch (controller.settings.errorCheck) {
          ErrorCheck.off => false,
          ErrorCheck.conflicts => game.hasConflict(cell),
          ErrorCheck.solution => true,
        };
    final candidates = [
      for (var n = 1; n <= sudokuSideLength; n++)
        if (notes & (1 << n) != 0) n,
    ];
    final description = value != 0
        ? (given
              ? context.l10n.givenValue(value)
              : context.l10n.enteredValue(value))
        : notes == 0
        ? context.l10n.emptyCell
        : context.l10n.candidates(candidates.join(', '));
    String digitsIn(int mask) => [
      for (var digit = 1; digit <= sudokuSideLength; digit++)
        if (mask & (1 << digit) != 0) digit,
    ].join(', ');
    final hintDetails = [
      if (hintCandidateMask != 0)
        context.l10n.hintBoardCandidates(digitsIn(hintCandidateMask)),
      if (hintRemovalMask != 0)
        context.l10n.hintBoardRemoved(digitsIn(hintRemovalMask)),
    ];
    final hintDescription = hintResult
        ? context.l10n.hintBoardResult(visualHint!.digit!)
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
        semanticLabel: context.l10n.cellLabel(row + 1, col + 1),
        onPressed: obscured ? null : () => controller.selectCell(cell),
        builder: (context, state) => AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          color: isSelected
              ? palette.selected
              : hintResult
              ? palette.same
              : hintFocused
              ? palette.same
              : hintHighlighted
              ? Color.alphaBlend(
                  palette.accent.withValues(alpha: .14),
                  palette.background,
                )
              : same
              ? palette.same
              : related || state.hovered || state.focused
              ? palette.related
              : palette.background,
          child: obscured
              ? const SizedBox.expand()
              : ExcludeSemantics(
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween(begin: .96, end: 1.0).animate(animation),
                          child: child,
                        ),
                      ),
                      child: value != 0
                          ? AutoFillDigit(
                              order: autoFillOrder,
                              child: BoardDigit(
                                '$value',
                                key: ValueKey('value-$cell-$value'),
                                style: context.rudiTheme.text.title.copyWith(
                                  fontSize: cellSize * .56,
                                  height: 1,
                                  color: isSelected
                                      ? palette.onSelected
                                      : error
                                      ? const Color(0xffd5505b)
                                      : given
                                      ? palette.ink
                                      : palette.accent,
                                  fontWeight: FontWeight.w500,
                                  decoration: error
                                      ? TextDecoration.underline
                                      : null,
                                ),
                              ),
                            )
                          : hintResult
                          ? BoardDigit(
                              '${visualHint!.digit!}',
                              key: ValueKey(
                                'hint-answer-$cell-${visualHint.digit}',
                              ),
                              style: context.rudiTheme.text.title.copyWith(
                                fontSize: cellSize * .56,
                                height: 1,
                                color: isSelected
                                    ? palette.onSelected
                                    : palette.accent,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : _BoardCandidates(
                              key: ValueKey(
                                'candidates-$cell-$hintMask-$hintRemovalMask-${hintMask != 0}',
                              ),
                              mask: hintMask != 0 ? hintMask : notes,
                              removalMask: hintRemovalMask,
                              isHint: hintMask != 0,
                              selected: isSelected,
                              cell: cell,
                              cellSize: cellSize,
                              palette: palette,
                            ),
                    ),
                  ),
                ),
        ),
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
        for (var row = 0; row < sudokuBoxSideLength; row++)
          Expanded(
            child: Row(
              children: [
                for (var column = 0; column < sudokuBoxSideLength; column++)
                  Expanded(
                    child: Center(
                      child: Builder(
                        builder: (context) {
                          final digit = row * sudokuBoxSideLength + column + 1;
                          final visible = mask & (1 << digit) != 0;
                          final removed = removalMask & (1 << digit) != 0;
                          return BoardDigit(
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
