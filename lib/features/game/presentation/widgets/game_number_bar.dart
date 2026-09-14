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
    return Row(
      children: [
        for (var number = 1; number <= sudokuSideLength; number++)
          Expanded(
            child: _NumberButton(
              number: number,
              count: digitCounts[number],
              enabled: enabled,
              selected:
                  controller.settings.numberFirst &&
                  controller.selectedDigit == number,
              completedLabel: l.completed,
              onPressed: () => controller.chooseDigit(number),
            ),
          ),
      ],
    );
  }
}

final class const _NumberButton({
  required final int number,
  required final int count,
  required final bool enabled,
  required final bool selected,
  required final String completedLabel,
  required final VoidCallback onPressed,
}) extends StatefulWidget {
  @override
  State<_NumberButton> createState() => _NumberButtonState();
}

final class _NumberButtonState() extends State<_NumberButton> {
  bool _pointerHovered = false;

  void _setPointerHovered(bool value) {
    if (_pointerHovered != value) setState(() => _pointerHovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final available = widget.enabled && widget.count < sudokuSideLength;
    return Semantics(
      value: widget.count >= sudokuSideLength ? widget.completedLabel : null,
      selected: widget.selected,
      child: MouseRegion(
        onEnter: (_) => _setPointerHovered(true),
        onExit: (_) => _setPointerHovered(false),
        child: RudiPressable(
          key: ValueKey('number-${widget.number}'),
          semanticLabel: '${widget.number}',
          onPressed: available ? widget.onPressed : null,
          builder: (context, state) => AnimatedContainer(
            key: ValueKey('number-surface-${widget.number}'),
            height: 60,
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : theme.motion.fast,
            curve: theme.motion.standardCurve,
            padding: const .symmetric(horizontal: 2, vertical: 4),
            decoration: BoxDecoration(
              color:
                  widget.selected ||
                      (available && (_pointerHovered || state.hovered)) ||
                      state.pressed
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
                  child: widget.count >= sudokuSideLength
                      ? RudiGlyph(
                          RudiGlyphType.check,
                          size: 36,
                          color: theme.colors.mutedForeground,
                        )
                      : Text(
                          '${widget.number}',
                          textAlign: .center,
                          textHeightBehavior: const TextHeightBehavior(
                            leadingDistribution: TextLeadingDistribution.even,
                          ),
                          style: theme.text.display.copyWith(
                            fontSize: 40,
                            height: 1,
                            fontWeight: .w400,
                            color: widget.enabled
                                ? theme.colors.accent
                                : theme.colors.mutedForeground,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
