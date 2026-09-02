import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../../app/sudoku_controller.dart';
import '../../../../common/presentation/ui.dart';

final class const ResumeCard({
  required final SudokuController controller,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n, theme = context.rudiTheme, game = controller.free!;
    return RudiPressable(
      key: const ValueKey('continue-game'),
      onPressed: controller.resumeFree,
      builder: (context, state) => AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : theme.motion.fast,
        padding: const .all(20),
        decoration: BoxDecoration(
          color: state.pressed
              ? theme.colors.surfaceContainer
              : theme.colors.surface,
          borderRadius: .circular(24),
          border: state.focused
              ? Border.all(color: theme.colors.accent, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Row(
              children: [
                IconTheme(
                  data: IconThemeData(color: theme.colors.accent),
                  child: const AppIcon(AppSymbol.play, size: 24, filled: true),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(l.continueGame, style: theme.text.title)),
                AppIcon(
                  AppSymbol.chevron,
                  color: theme.colors.mutedForeground,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${difficultyLabel(context, game.puzzle.difficulty)}${controller.settings.showTimer ? ' · ${durationLabel(game.elapsedSeconds)}' : ''}',
              style: theme.text.caption.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: .circular(4),
              child: SizedBox(
                height: 5,
                child: ColoredBox(
                  color: theme.colors.outline.withValues(alpha: .4),
                  child: Align(
                    alignment: .centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: game.filled / 81,
                      child: ColoredBox(
                        color: theme.colors.accent,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.progress(game.filled),
              style: theme.text.caption.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
