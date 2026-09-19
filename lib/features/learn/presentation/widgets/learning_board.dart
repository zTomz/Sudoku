import 'package:flutter/widgets.dart';

import '../../../settings/domain/app_settings.dart';
import '../../../game/presentation/sudoku_board.dart';
import '../../domain/learning_lesson.dart';

final class const LearningBoardView({
  required final LearningBoard board,
  required final BoardTheme boardTheme,
  super.key,
}) extends StatelessWidget {
  int _mask(Set<int> digits) =>
      digits.fold(0, (mask, digit) => mask | 1 << digit);

  @override
  Widget build(BuildContext context) {
    final candidateMasks = {
      for (final entry in board.candidates.entries)
        entry.key: _mask(entry.value),
    };
    final removalMasks = {
      for (final entry in board.removedCandidates.entries)
        entry.key: _mask(entry.value),
    };
    final notes = List.generate(
      board.values.length,
      (cell) => candidateMasks[cell] ?? 0,
    );
    final selected = board.selectedCell ?? -1;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: SudokuBoardView(
          values: board.values,
          notes: notes,
          givens: board.values,
          boardTheme: boardTheme,
          selected: selected,
          activeDigit: selected < 0 ? 0 : board.values[selected],
          hint: SudokuHintVisual(
            cells: board.focusCells,
            candidates: candidateMasks,
            removals: removalMasks,
            focus: board.selectedCell,
          ),
          revision: board,
        ),
      ),
    );
  }
}
