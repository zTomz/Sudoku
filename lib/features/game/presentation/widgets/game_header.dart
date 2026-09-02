import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../../app/sudoku_controller.dart';
import '../../../../common/presentation/ui.dart';

final class const GameHeader({
  required final SudokuController controller,
  required final VoidCallback onOpenBoardTheme,
  required final VoidCallback onOpenSettings,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = context.rudiTheme;
    return Padding(
      key: const ValueKey('game-header'),
      padding: const .fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          RudiIconButton(
            icon: const RotatedBox(
              quarterTurns: 2,
              child: AppIcon(AppSymbol.chevron),
            ),
            semanticLabel: l.back,
            onPressed: controller.leaveGame,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l.appTitle,
              style: theme.text.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          RudiIconButton(
            icon: const AppIcon(AppSymbol.palette),
            semanticLabel: l.boardTheme,
            onPressed: onOpenBoardTheme,
          ),
          RudiIconButton(
            icon: const AppIcon(AppSymbol.settings),
            semanticLabel: l.settings,
            onPressed: onOpenSettings,
          ),
          if (!controller.game!.complete)
            RudiIconButton(
              icon: const AppIcon(AppSymbol.pause),
              semanticLabel: controller.paused ? l.resume : l.pause,
              onPressed: controller.togglePause,
            ),
        ],
      ),
    );
  }
}
