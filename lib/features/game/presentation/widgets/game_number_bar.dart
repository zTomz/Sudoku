import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../../app/sudoku_controller.dart';
import '../../../../common/presentation/ui.dart';
import '../../domain/puzzle.dart';

final class const GameNumberBar({
  required final SudokuController controller,
  required final bool enabled,
  required final List<int> digitCounts,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = context.rudiTheme;
    return Row(
      children: [
        for (var number = 1; number <= sudokuSideLength; number++)
          Expanded(
            child: Semantics(
              value: digitCounts[number] >= sudokuSideLength
                  ? l.completed
                  : null,
              selected:
                  controller.settings.numberFirst &&
                  controller.selectedDigit == number,
              child: RudiPressable(
                key: ValueKey('number-$number'),
                semanticLabel: '$number',
                onPressed: enabled && digitCounts[number] < sudokuSideLength
                    ? () => controller.chooseDigit(number)
                    : null,
                builder: (context, state) {
                  final selected =
                      controller.settings.numberFirst &&
                      controller.selectedDigit == number;
                  return AnimatedContainer(
                    height: 60,
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : theme.motion.fast,
                    curve: theme.motion.standardCurve,
                    padding: const .symmetric(horizontal: 2, vertical: 4),
                    decoration: BoxDecoration(
                      color: selected || state.hovered || state.pressed
                          ? theme.colors.surface
                          : const Color(0x00000000),
                      borderRadius: .circular(14),
                      border: state.focused
                          ? Border.all(color: theme.colors.accent)
                          : null,
                    ),
                    child: FittedBox(
                      fit: .scaleDown,
                      child: SizedBox(
                        height: 40,
                        child: Center(
                          child: digitCounts[number] >= sudokuSideLength
                              ? RudiGlyph(
                                  RudiGlyphType.check,
                                  size: 36,
                                  color: theme.colors.mutedForeground,
                                )
                              : Text(
                                  '$number',
                                  textAlign: .center,
                                  textHeightBehavior: const TextHeightBehavior(
                                    leadingDistribution:
                                        TextLeadingDistribution.even,
                                  ),
                                  style: theme.text.display.copyWith(
                                    fontSize: 40,
                                    height: 1,
                                    fontWeight: .w400,
                                    color: enabled
                                        ? theme.colors.accent
                                        : theme.colors.mutedForeground,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
