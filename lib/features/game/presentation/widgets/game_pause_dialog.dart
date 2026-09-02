import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../../app/sudoku_controller.dart';
import '../../../../common/presentation/destination_transition.dart';
import '../../../../common/presentation/ui.dart';

final class const GamePauseDialog({
  required final SudokuController controller,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = context.rudiTheme;
    return FocusScope(
      autofocus: true,
      child: Semantics(
        scopesRoute: true,
        namesRoute: true,
        label: l.paused,
        explicitChildNodes: true,
        child: DestinationTransition(
          value: 'pause',
          child: RudiDialog(
            key: const ValueKey('pause-dialog'),
            title: Text(l.paused),
            icon: AppIcon(
              AppSymbol.pause,
              filled: true,
              color: theme.colors.foreground,
            ),
            content: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .stretch,
              children: [
                Text(
                  difficultyLabel(context, controller.game!.puzzle.difficulty),
                  textAlign: .center,
                  style: theme.text.body.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                if (controller.settings.showTimer) ...[
                  const SizedBox(height: 8),
                  Text(
                    durationLabel(controller.game!.elapsedSeconds),
                    textAlign: .center,
                    style: theme.text.title,
                  ),
                ],
              ],
            ),
            actions: [
              RudiButton(
                label: l.resume,
                autofocus: true,
                onPressed: controller.togglePause,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
