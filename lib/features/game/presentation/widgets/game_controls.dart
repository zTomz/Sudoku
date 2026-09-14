import 'package:cue/cue.dart';
import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../../app/sudoku_controller.dart';
import '../../../../common/presentation/ui.dart';
import '../../domain/puzzle.dart';
import 'game_hint_coach.dart';
import 'game_number_bar.dart';
import 'game_tools.dart';

final class const GameControls({
  required final SudokuController controller,
  required final HintCoachState? coach,
  required final VoidCallback onShowHint,
  required final VoidCallback onAdvanceHint,
  required final VoidCallback onExplainHint,
  required final VoidCallback onCloseHint,
  super.key,
}) extends StatefulWidget {
  @override
  State<GameControls> createState() => _GameControlsState();
}

final class _GameControlsState() extends State<GameControls> {
  HintCoachState? _visibleCoach;

  @override
  void initState() {
    super.initState();
    _visibleCoach = widget.coach;
  }

  @override
  void didUpdateWidget(covariant GameControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.coach != null) _visibleCoach = widget.coach;
  }

  void _handleHintAnimationEnd(bool forward) {
    if (!forward && widget.coach == null && _visibleCoach != null) {
      setState(() => _visibleCoach = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = context.rudiTheme;
    final controller = widget.controller;
    final game = controller.game!;
    final activeCoach = widget.coach;
    final visibleCoach = _visibleCoach;
    if (game.complete) {
      return Column(
        mainAxisSize: .min,
        children: [
          Text(l.finished, style: theme.text.headline),
          const SizedBox(height: 8),
          Text(
            l.pointsValue(game.finalPoints),
            key: const ValueKey('final-points'),
            style: theme.text.display.copyWith(color: theme.colors.accent),
          ),
          const SizedBox(height: 4),
          Text(
            l.mistakesValue(game.mistakes),
            key: const ValueKey('final-mistakes'),
            style: theme.text.body.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
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
    final digitCounts = List<int>.filled(sudokuSideLength + 1, 0);
    for (final value in game.values) {
      digitCounts[value]++;
    }
    return Column(
      mainAxisSize: .min,
      children: [
        Stack(
          key: const ValueKey('game-context-controls'),
          alignment: .topCenter,
          children: [
            Visibility.maintain(
              visible: activeCoach == null,
              child: GameTools(
                key: const ValueKey('game-tools'),
                controller: controller,
                enabled: enabled,
                onShowHint: widget.onShowHint,
              ),
            ),
            IgnorePointer(
              ignoring: activeCoach == null,
              child: Cue.onToggle(
                key: const ValueKey('hint-transition'),
                toggled: activeCoach != null,
                onEnd: _handleHintAnimationEnd,
                motion: MediaQuery.disableAnimationsOf(context)
                    ? CueMotion.none
                    : .easeOut(const Duration(milliseconds: 240)),
                reverseMotion: MediaQuery.disableAnimationsOf(context)
                    ? CueMotion.none
                    : .easeIn(const Duration(milliseconds: 240)),
                acts: const [.opacity(from: 0, to: 1), .translateY(from: 6)],
                child: visibleCoach == null
                    ? const SizedBox(key: ValueKey('hint-hidden'))
                    : AnimatedSwitcher(
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 240),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: GameHintCoach(
                          key: ValueKey(
                            'hint-${visibleCoach.hint.status.name}-${visibleCoach.stepIndex}-${visibleCoach.phase.name}',
                          ),
                          coach: visibleCoach,
                          onAdvance: widget.onAdvanceHint,
                          onExplain: widget.onExplainHint,
                          onClose: widget.onCloseHint,
                        ),
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GameNumberBar(
          controller: controller,
          enabled: enabled,
          digitCounts: digitCounts,
        ),
      ],
    );
  }
}
