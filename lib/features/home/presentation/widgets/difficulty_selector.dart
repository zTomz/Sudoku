import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../../common/presentation/ui.dart';
import '../../../game/domain/puzzle.dart';

final class const DifficultySelector({
  required final ValueChanged<Difficulty> onSelected,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final stacked =
          bounds.maxWidth < 300 ||
          MediaQuery.textScalerOf(context).scale(16) > 22;
      final options = [
        for (final difficulty in Difficulty.values)
          _DifficultyButton(
            difficulty: difficulty,
            onPressed: () => onSelected(difficulty),
          ),
      ];
      return stacked
          ? Column(
              crossAxisAlignment: .stretch,
              children: [
                for (final (index, option) in options.indexed) ...[
                  if (index > 0) const SizedBox(height: 8),
                  option,
                ],
              ],
            )
          : Row(
              children: [
                for (final (index, option) in options.indexed) ...[
                  if (index > 0) const SizedBox(width: 10),
                  Expanded(child: option),
                ],
              ],
            );
    },
  );
}

final class const _DifficultyButton({
  required final Difficulty difficulty,
  required final VoidCallback onPressed,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return RudiPressable(
      key: ValueKey('start-${difficulty.name}'),
      onPressed: onPressed,
      builder: (context, state) => AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : theme.motion.fast,
        padding: const .symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: state.pressed || state.hovered
              ? theme.colors.surfaceContainer
              : theme.colors.surface,
          borderRadius: .circular(18),
          border: state.focused
              ? Border.all(color: theme.colors.accent, width: 2)
              : null,
        ),
        child: Column(
          mainAxisSize: .min,
          children: [
            Row(
              mainAxisSize: .min,
              crossAxisAlignment: .end,
              children: [
                for (var bar = 0; bar < 3; bar++)
                  Container(
                    width: 5,
                    height: 8.0 + bar * 5,
                    margin: const .symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: .circular(2),
                      color: bar <= difficulty.index
                          ? theme.colors.accent
                          : theme.colors.outline,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(difficultyLabel(context, difficulty), style: theme.text.label),
          ],
        ),
      ),
    );
  }
}
