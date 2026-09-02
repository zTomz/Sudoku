import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../app/sudoku_controller.dart';
import '../../../common/presentation/ui.dart';
import '../../../common/presentation/app_sheet.dart';
import '../../settings/presentation/settings_page.dart';
import '../domain/logical_solver.dart';
import '../domain/puzzle.dart';
import 'hint_sheet.dart';
import 'providers/game_hint_provider.dart';
import 'sudoku_board.dart';
import 'widgets/game_controls.dart';
import 'widgets/game_board_viewport.dart';
import 'widgets/game_header.dart';
import 'widgets/game_hint_coach.dart';
import 'widgets/game_pause_dialog.dart';
import 'widgets/game_status_bar.dart';
import 'widgets/score_popup.dart';

final class const GamePage({
  required final SudokuController controller,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

final class _GamePageState() extends ConsumerState<GamePage> {
  HintCoachState? _coach;
  String? _coachValues;

  SudokuController get controller => widget.controller;

  String get _valuesFingerprint => controller.game!.values.join(',');

  @override
  void didUpdateWidget(covariant GamePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_coach != null && _coachValues != _valuesFingerprint) {
      _coach = null;
      _coachValues = null;
    }
  }

  void _showHint() {
    final hint = ref.read(gameHintProvider);
    if (hint == null) return;
    setState(() {
      _coach = HintCoachState(hint);
      _coachValues = _valuesFingerprint;
    });
  }

  void _closeHint() => setState(() {
    _coach = null;
    _coachValues = null;
  });

  void _advanceHint() {
    final coach = _coach, step = coach?.step;
    if (coach == null || step == null) return;
    setState(() {
      _coach = switch (coach.phase) {
        HintPhase.locate => HintCoachState(
          coach.hint,
          stepIndex: coach.stepIndex,
          phase: HintPhase.reason,
        ),
        HintPhase.reason
            when step.placement == null &&
                coach.stepIndex < coach.hint.steps.length - 1 =>
          HintCoachState(
            coach.hint,
            stepIndex: coach.stepIndex + 1,
            phase: HintPhase.reason,
          ),
        HintPhase.reason => HintCoachState(
          coach.hint,
          stepIndex: coach.stepIndex,
          phase: HintPhase.answer,
        ),
        HintPhase.answer => coach,
      };
    });
  }

  SudokuHintVisual? get _hintVisual {
    final coach = _coach, step = coach?.step;
    if (coach == null || step == null || controller.paused) return null;
    final placement = step.placement;
    final showingElimination =
        coach.phase == HintPhase.reason && placement == null;
    return SudokuHintVisual(
      cells: switch (coach.phase) {
        HintPhase.locate => step.cells.toSet(),
        HintPhase.reason when placement != null => _placementEvidenceCells(
          step,
        ),
        HintPhase.reason => step.cells.toSet(),
        HintPhase.answer => {?placement},
      },
      focus: placement,
      candidates: showingElimination ? step.candidates : const {},
      removals: showingElimination ? _removalMasks(step) : const {},
      placement: coach.phase == HintPhase.answer ? placement : null,
      digit: coach.phase == HintPhase.answer && placement != null
          ? step.digits.bitLength - 1
          : null,
    );
  }

  Set<int> _placementEvidenceCells(LogicalStep step) {
    final placement = step.placement!;
    if (step.technique == SolveTechnique.hiddenSingle) {
      return step.cells.toSet();
    }
    return {
      placement,
      for (final cell in peers(placement))
        if (controller.game!.values[cell] != 0) cell,
    };
  }

  Map<int, int> _removalMasks(LogicalStep step) {
    final result = <int, int>{};
    for (final removal in step.removals) {
      result.update(
        removal.cell,
        (mask) => mask | removal.mask,
        ifAbsent: () => removal.mask,
      );
    }
    return result;
  }

  Future<void> _showHintExplanation(BuildContext context) async {
    final coach = _coach, step = coach?.step;
    if (coach == null || step == null) return;
    await showHintExplanation(
      context,
      step: step,
      rating: controller.game!.puzzle.rating,
    );
  }

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
    if (digit != null && digit >= 1 && digit <= sudokuSideLength) {
      controller.chooseDigit(digit);
    } else if (key == LogicalKeyboardKey.keyN) {
      controller.togglePencil();
    } else if (key == LogicalKeyboardKey.delete ||
        key == LogicalKeyboardKey.backspace) {
      controller.enter(0);
    } else {
      final cell = controller.selected < 0 ? 0 : controller.selected;
      final direction = switch (key) {
        LogicalKeyboardKey.arrowLeft => SudokuDirection.left,
        LogicalKeyboardKey.arrowRight => SudokuDirection.right,
        LogicalKeyboardKey.arrowUp => SudokuDirection.up,
        LogicalKeyboardKey.arrowDown => SudokuDirection.down,
        _ => null,
      };
      if (direction == null) return KeyEventResult.ignored;
      // Arrow navigation must never place a number in number-first mode.
      controller.moveSelection(adjacentCell(cell, direction));
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
        builder: (context) => Consumer(
          builder: (context, ref, _) {
            ref.watch(sudokuControllerProvider);
            return SettingsContent(controller: controller);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme, game = controller.game!;
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
                            GameHeader(
                              controller: controller,
                              onOpenBoardTheme: () => unawaited(
                                _openSettings(context, boardOnly: true),
                              ),
                              onOpenSettings: () =>
                                  unawaited(_openSettings(context)),
                            ),
                            GameStatusBar(
                              game: game,
                              showTimer: controller.settings.showTimer,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const .symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: GameBoardViewport(
                                  board: SudokuBoard(
                                    controller: controller,
                                    game: game,
                                    obscured: controller.paused,
                                    hint: _hintVisual,
                                  ),
                                  overlay:
                                      !controller.paused &&
                                          controller.scoreAwardPoints > 0
                                      ? ScorePopup(
                                          key: ValueKey(
                                            controller.scoreAwardSequence,
                                          ),
                                          points: controller.scoreAwardPoints,
                                          cell: controller.scoreAwardCell,
                                        )
                                      : null,
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
                                child: GameControls(
                                  controller: controller,
                                  coach: controller.paused ? null : _coach,
                                  onShowHint: _showHint,
                                  onAdvanceHint: _advanceHint,
                                  onExplainHint: () =>
                                      unawaited(_showHintExplanation(context)),
                                  onCloseHint: _closeHint,
                                ),
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
              GamePauseDialog(controller: controller),
            ],
          ],
        ),
      ),
    );
  }
}
