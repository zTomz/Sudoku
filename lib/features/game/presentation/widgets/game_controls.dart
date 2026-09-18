import 'dart:async';

import 'package:cue/cue.dart';
import 'package:flutter/widgets.dart';
import 'package:reel_text/reel_text.dart';
import 'package:rudi_ui/rudi_ui.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../../../app/sudoku_controller.dart';
import '../../../../common/presentation/ui.dart';
import '../../domain/game_session.dart';
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
    final controller = widget.controller;
    final game = controller.game!;
    final activeCoach = widget.coach;
    final visibleCoach = _visibleCoach;
    if (game.complete) {
      return _CompletionSummary(game: game, onLeave: controller.leaveGame);
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

final class const _CompletionSummary({
  required final GameSession game,
  required final VoidCallback onLeave,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final immediate = reduceMotion ? Duration.zero : null;
    return Cue.onMount(
      motion: reduceMotion ? CueMotion.none : .smooth(),
      child: Column(
        mainAxisSize: .min,
        children: [
          Actor(
            acts: const [.fadeIn(), .slideY(from: .12)],
            child: Text(l.finished, style: context.rudiTheme.text.headline),
          ),
          const SizedBox(height: 6),
          Actor(
            delay: immediate ?? const Duration(milliseconds: 70),
            acts: const [.fadeIn(), .scale(from: .94)],
            child: _AnimatedFinalScore(game: game),
          ),
          const SizedBox(height: 12),
          Actor(
            delay: immediate ?? const Duration(milliseconds: 150),
            acts: const [.fadeIn(), .slideY(from: .08)],
            child: _ScoreCalculation(game: game, reduceMotion: reduceMotion),
          ),
          const SizedBox(height: 14),
          Actor(
            delay: immediate ?? const Duration(milliseconds: 2250),
            acts: const [.fadeIn(), .slideY(from: .08)],
            child: RudiButton(
              label: l.backHome,
              expand: true,
              onPressed: onLeave,
            ),
          ),
        ],
      ),
    );
  }
}

final class const _AnimatedFinalScore({required final GameSession game})
    extends StatefulWidget {
  @override
  State<_AnimatedFinalScore> createState() => _AnimatedFinalScoreState();
}

final class _AnimatedFinalScoreState() extends State<_AnimatedFinalScore> {
  Timer? _mistakeTimer;
  Timer? _hintTimer;
  var _started = false;
  late var _visiblePoints = widget.game.pointsBeforeDeductions;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _visiblePoints = widget.game.finalPoints;
      return;
    }
    _mistakeTimer = Timer(const Duration(milliseconds: 850), () {
      if (mounted) {
        setState(() => _visiblePoints = widget.game.scoreBeforeHints);
      }
    });
    _hintTimer = Timer(const Duration(milliseconds: 1700), () {
      if (mounted) setState(() => _visiblePoints = widget.game.finalPoints);
    });
  }

  @override
  void dispose() {
    _mistakeTimer?.cancel();
    _hintTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = context.rudiTheme;
    return ReelText(
      l.pointsValue(_visiblePoints),
      key: const ValueKey('final-points'),
      semanticsLabel: l.pointsValue(_visiblePoints),
      options: ReelTextOptions(
        direction: ReelTextDirection.down,
        duration: const Duration(milliseconds: 420),
        stagger: const Duration(milliseconds: 34),
        exitOffset: const Duration(milliseconds: 42),
        curve: Curves.easeOutCubic,
        bounce: .18,
        color: theme.colors.accent,
      ),
      style: theme.text.display.copyWith(color: theme.colors.accent),
    );
  }
}

final class const _ScoreCalculation({
  required final GameSession game,
  required final bool reduceMotion,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = context.rudiTheme;
    final mistakeDelay = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 600);
    final hintDelay = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 1450);
    return Semantics(
      container: true,
      label: l.scoreBreakdown,
      child: Container(
        key: const ValueKey('score-breakdown'),
        width: double.infinity,
        padding: const .all(14),
        decoration: BoxDecoration(
          color: theme.colors.surfaceContainer,
          borderRadius: .circular(18),
          border: Border.all(
            color: theme.colors.outline.withValues(alpha: .35),
          ),
        ),
        child: Column(
          crossAxisAlignment: .stretch,
          mainAxisSize: .min,
          children: [
            Text(
              l.scoreBreakdown,
              style: theme.text.label.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 10),
            _CalculationStartRow(
              label: l.scoreBeforeDeductions,
              points: game.pointsBeforeDeductions,
            ),
            Padding(
              padding: const .symmetric(vertical: 8),
              child: ColoredBox(
                color: theme.colors.outline.withValues(alpha: .28),
                child: const SizedBox(height: 1),
              ),
            ),
            Actor(
              delay: mistakeDelay,
              acts: const [.fadeIn(), .slideY(from: .12)],
              child: _DeductionRow(
                key: const ValueKey('final-mistakes'),
                label: l.mistakesValue(game.mistakes),
                points: game.mistakeDeduction,
              ),
            ),
            const SizedBox(height: 4),
            Actor(
              delay: hintDelay,
              acts: const [.fadeIn(), .slideY(from: .12)],
              child: _DeductionRow(
                key: const ValueKey('final-hints'),
                label: l.hintsUsedValue(game.hintsUsed),
                points: game.hintDeduction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class const _CalculationStartRow({
  required final String label,
  required final int points,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: .center,
          decoration: BoxDecoration(
            color: theme.colors.accent.withValues(alpha: .12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            SolarIconsOutline.cup1,
            size: 19,
            color: theme.colors.accent,
            fill: 0,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: .ellipsis,
            style: theme.text.body,
          ),
        ),
        const SizedBox(width: 12),
        Text('$points', style: theme.text.label),
      ],
    );
  }
}

final class const _DeductionRow({
  required final String label,
  required final int points,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Padding(
      padding: const .symmetric(horizontal: 4, vertical: 5),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: .center,
            decoration: BoxDecoration(
              color: theme.colors.error.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Text(
              '−',
              style: theme.text.label.copyWith(color: theme.colors.error),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: .ellipsis,
              style: theme.text.body,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '−$points',
            style: theme.text.label.copyWith(color: theme.colors.error),
          ),
        ],
      ),
    );
  }
}
