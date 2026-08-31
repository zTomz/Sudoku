import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../app/sudoku_controller.dart';
import '../../../common/presentation/destination_transition.dart';
import '../../../common/presentation/ui.dart';
import 'sudoku_board.dart';
import '../../../common/presentation/app_sheet.dart';
import '../../settings/presentation/settings_page.dart';

final class const GamePage({
  required final SudokuController controller,
  super.key,
}) extends StatelessWidget {
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent ||
        controller.paused ||
        controller.game!.complete) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isControlPressed || keyboard.isMetaPressed) {
      if (key == LogicalKeyboardKey.keyZ) {
        keyboard.isShiftPressed ? controller.redo() : controller.undo();
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.keyY) {
        controller.redo();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    final digit = int.tryParse(event.character ?? key.keyLabel);
    if (digit != null && digit >= 1 && digit <= 9) {
      controller.chooseDigit(digit);
    } else if (key == LogicalKeyboardKey.keyN) {
      controller.togglePencil();
    } else if (key == LogicalKeyboardKey.delete ||
        key == LogicalKeyboardKey.backspace) {
      controller.enter(0);
    } else {
      final cell = controller.selected < 0 ? 0 : controller.selected;
      final next = switch (key) {
        LogicalKeyboardKey.arrowLeft => cell % 9 > 0 ? cell - 1 : cell,
        LogicalKeyboardKey.arrowRight => cell % 9 < 8 ? cell + 1 : cell,
        LogicalKeyboardKey.arrowUp => cell >= 9 ? cell - 9 : cell,
        LogicalKeyboardKey.arrowDown => cell < 72 ? cell + 9 : cell,
        _ => null,
      };
      if (next == null) return KeyEventResult.ignored;
      // Arrow navigation must never place a number in number-first mode.
      controller.moveSelection(next);
    }
    return KeyEventResult.handled;
  }

  Future<void> _openSettings(
    BuildContext context, {
    bool boardOnly = false,
  }) async {
    if (boardOnly) {
      await chooseBoardTheme(context, controller);
    } else {
      await showAppSheet<void>(
        context: context,
        title: context.l10n.settings,
        builder: (context) => ListenableBuilder(
          listenable: controller,
          builder: (context, _) => SettingsContent(controller: controller),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n, theme = context.rudiTheme, game = controller.game!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          controller.paused ? controller.togglePause() : controller.leaveGame();
        }
      },
      child: Focus(
        autofocus: true,
        onKeyEvent: _onKey,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ExcludeFocus(
              excluding: controller.paused,
              child: ExcludeSemantics(
                excluding: controller.paused,
                child: IgnorePointer(
                  ignoring: controller.paused,
                  child: RudiPage(
                    padding: .zero,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          children: [
                            Padding(
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
                                    onPressed: () => unawaited(
                                      _openSettings(context, boardOnly: true),
                                    ),
                                  ),
                                  RudiIconButton(
                                    icon: const AppIcon(AppSymbol.settings),
                                    semanticLabel: l.settings,
                                    onPressed: () =>
                                        unawaited(_openSettings(context)),
                                  ),
                                  if (!game.complete)
                                    RudiIconButton(
                                      icon: const AppIcon(AppSymbol.pause),
                                      semanticLabel: controller.paused
                                          ? l.resume
                                          : l.pause,
                                      onPressed: controller.togglePause,
                                    ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const .fromLTRB(20, 12, 20, 8),
                              child: Row(
                                crossAxisAlignment: .start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${game.puzzle.dailyDate == null ? l.freePlay : l.daily} · ${difficultyLabel(context, game.puzzle.difficulty)}',
                                      style: theme.text.caption.copyWith(
                                        color: theme.colors.mutedForeground,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (controller.settings.showTimer)
                                    Semantics(
                                      label: l.timer,
                                      child: Text(
                                        durationLabel(game.elapsedSeconds),
                                        style: theme.text.label,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const .symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: LayoutBuilder(
                                  builder: (context, bounds) {
                                    final available = bounds.maxHeight < 230
                                        ? 320.0
                                        : bounds.maxHeight;
                                    final size = math.min(
                                      560.0,
                                      math.min(bounds.maxWidth, available),
                                    );
                                    final board = SizedBox.square(
                                      key: const ValueKey('game-puzzle'),
                                      dimension: size,
                                      child: SudokuBoard(
                                        controller: controller,
                                        obscured: controller.paused,
                                      ),
                                    );
                                    return Center(
                                      child: SingleChildScrollView(
                                        child: board,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              key: const ValueKey('game-toolbar'),
                              padding: const .fromLTRB(12, 4, 12, 12),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 600,
                                ),
                                child: _GameControls(controller: controller),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (controller.paused) ...[
              ModalBarrier(color: theme.colors.scrim, dismissible: false),
              _PauseDialog(controller: controller),
            ],
          ],
        ),
      ),
    );
  }
}

final class const _PauseDialog({required final SudokuController controller})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n, theme = context.rudiTheme;
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

final class const _GameControls({required final SudokuController controller})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n, theme = context.rudiTheme, game = controller.game!;
    if (game.complete) {
      return Column(
        mainAxisSize: .min,
        children: [
          Text(l.finished, style: theme.text.headline),
          const SizedBox(height: 12),
          RudiButton(
            label: l.backHome,
            expand: true,
            onPressed: controller.leaveGame,
          ),
        ],
      );
    }
    final enabled = !controller.paused;
    final digitCounts = List<int>.filled(10, 0);
    for (final value in game.values) {
      digitCounts[value]++;
    }
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
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var number = 1; number <= 9; number++)
              Expanded(
                child: Semantics(
                  value: digitCounts[number] >= 9 ? l.completed : null,
                  selected:
                      controller.settings.numberFirst &&
                      controller.selectedDigit == number,
                  child: RudiPressable(
                    key: ValueKey('number-$number'),
                    semanticLabel: '$number',
                    onPressed: enabled
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
                              child: digitCounts[number] >= 9
                                  ? RudiGlyph(
                                      RudiGlyphType.check,
                                      size: 36,
                                      color: theme.colors.mutedForeground,
                                    )
                                  : Text(
                                      '$number',
                                      textAlign: .center,
                                      textHeightBehavior:
                                          const TextHeightBehavior(
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
