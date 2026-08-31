import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../app/sudoku_controller.dart';
import '../../../common/presentation/ui.dart';
import '../../settings/domain/app_settings.dart';
import 'board_palette.dart';

final class const SudokuBoard({
  required final SudokuController controller,
  final bool obscured = false,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = controller.game!,
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
            child: CustomPaint(
              key: const ValueKey('board-grid'),
              foregroundPainter: SudokuGridPainter(
                palette: palette,
                pixelRatio: MediaQuery.devicePixelRatioOf(context),
                selected: selected,
                highContrast: MediaQuery.highContrastOf(context),
              ),
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
                                    final given = game.puzzle.givens[cell] != 0,
                                        isSelected = selected == cell;
                                    final related =
                                        selected >= 0 &&
                                        (selected ~/ 9 == row ||
                                            selected % 9 == col ||
                                            (selected ~/ 27 == row ~/ 3 &&
                                                selected % 9 ~/ 3 == col ~/ 3));
                                    final same =
                                        value != 0 && value == activeDigit;
                                    final error = switch (controller
                                        .settings
                                        .errorCheck) {
                                      ErrorCheck.off => false,
                                      ErrorCheck.conflicts => game.hasConflict(
                                        cell,
                                      ),
                                      ErrorCheck.solution =>
                                        value != 0 &&
                                            value != game.puzzle.solution[cell],
                                    };
                                    final candidates = [
                                      for (var n = 1; n <= 9; n++)
                                        if (notes & (1 << n) != 0) n,
                                    ];
                                    final description = value != 0
                                        ? (given
                                              ? context.l10n.givenValue(value)
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
                                          '$description${error ? ', ${context.l10n.conflict}' : ''}',
                                      child: RudiPressable(
                                        key: ValueKey('cell-$cell'),
                                        semanticLabel: context.l10n.cellLabel(
                                          row + 1,
                                          col + 1,
                                        ),
                                        onPressed: obscured
                                            ? null
                                            : () => controller.selectCell(cell),
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
                                                            style: context
                                                                .rudiTheme
                                                                .text
                                                                .title
                                                                .copyWith(
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
                                                                          var c =
                                                                              0;
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
          );
        },
      ),
    );
  }
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
