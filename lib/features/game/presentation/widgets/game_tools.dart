import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../../app/sudoku_controller.dart';
import '../../../../common/presentation/ui.dart';

final class const GameTools({
  required final SudokuController controller,
  required final bool enabled,
  required final VoidCallback onShowHint,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = context.rudiTheme;
    final game = controller.game!;
    return Column(
      mainAxisSize: .min,
      children: [
        Text(
          l.progress(game.filled),
          style: theme.text.caption.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _Tool(
              label: l.undo,
              symbol: AppSymbol.undo,
              onPressed: enabled && game.canUndo ? controller.undo : null,
            ),
            _Tool(
              label: l.redo,
              symbol: AppSymbol.redo,
              onPressed: enabled && game.canRedo ? controller.redo : null,
            ),
            _Tool(
              label: l.erase,
              symbol: AppSymbol.erase,
              onPressed: enabled ? () => controller.enter(0) : null,
            ),
            _Tool(
              label: l.notes,
              symbol: AppSymbol.pencil,
              selected: controller.pencil,
              onPressed: enabled ? controller.togglePencil : null,
            ),
            _Tool(
              key: const ValueKey('show-hint'),
              label: l.hint,
              symbol: AppSymbol.info,
              onPressed: enabled ? onShowHint : null,
            ),
          ],
        ),
      ],
    );
  }
}

final class const _Tool({
  required final String label,
  required final AppSymbol symbol,
  required final VoidCallback? onPressed,
  final bool selected = false,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Expanded(
      child: Semantics(
        selected: selected,
        child: RudiPressable(
          semanticLabel: label,
          onPressed: onPressed,
          builder: (context, state) => AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : theme.motion.fast,
            padding: const .symmetric(vertical: 8, horizontal: 2),
            decoration: BoxDecoration(
              color: selected || state.pressed || state.hovered
                  ? theme.colors.surface
                  : const Color(0x00000000),
              borderRadius: .circular(16),
              border: state.focused
                  ? Border.all(color: theme.colors.accent)
                  : null,
            ),
            child: Column(
              mainAxisSize: .min,
              children: [
                IconTheme(
                  data: IconThemeData(
                    color: selected
                        ? theme.colors.accent
                        : theme.colors.mutedForeground,
                  ),
                  child: AppIcon(symbol, size: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 1,
                  overflow: .ellipsis,
                  style: theme.text.caption.copyWith(
                    color: selected
                        ? theme.colors.accent
                        : theme.colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
