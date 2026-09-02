import 'dart:async';
import 'dart:math' as math;

import 'package:cue/cue.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reel_text/reel_text.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../app/hint_provider.dart';
import '../../../app/sudoku_controller.dart';
import '../../../common/presentation/destination_transition.dart';
import '../../../common/presentation/ui.dart';
import '../../../common/presentation/app_sheet.dart';
import '../../settings/presentation/settings_page.dart';
import '../domain/game_hint.dart';
import '../domain/logical_solver.dart';
import 'hint_sheet.dart';
import 'sudoku_board.dart';

final class const GamePage({
  required final SudokuController controller,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

enum _HintPhase() {
  locate,
  reason,
  answer,
}

final class _HintCoachState(
  final GameHint hint, {
  final int stepIndex = 0,
  final _HintPhase phase = _HintPhase.locate,
}) {
  LogicalStep? get step =>
      hint.status == HintStatus.available ? hint.steps[stepIndex] : null;
}

final class _GamePageState() extends ConsumerState<GamePage> {
  _HintCoachState? _coach;
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
      _coach = _HintCoachState(hint);
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
        _HintPhase.locate => _HintCoachState(
          coach.hint,
          stepIndex: coach.stepIndex,
          phase: _HintPhase.reason,
        ),
        _HintPhase.reason
            when step.placement == null &&
                coach.stepIndex < coach.hint.steps.length - 1 =>
          _HintCoachState(
            coach.hint,
            stepIndex: coach.stepIndex + 1,
            phase: _HintPhase.reason,
          ),
        _HintPhase.reason => _HintCoachState(
          coach.hint,
          stepIndex: coach.stepIndex,
          phase: _HintPhase.answer,
        ),
        _HintPhase.answer => coach,
      };
    });
  }

  SudokuHintVisual? get _hintVisual {
    final coach = _coach, step = coach?.step;
    if (coach == null || step == null || controller.paused) return null;
    final placement = step.placement;
    final showingElimination =
        coach.phase == _HintPhase.reason && placement == null;
    return SudokuHintVisual(
      cells: switch (coach.phase) {
        _HintPhase.locate => step.cells.toSet(),
        _HintPhase.reason when placement != null => _placementEvidenceCells(
          step,
        ),
        _HintPhase.reason => step.cells.toSet(),
        _HintPhase.answer => {?placement},
      },
      focus: placement,
      candidates: showingElimination ? step.candidates : const {},
      removals: showingElimination ? _removalMasks(step) : const {},
      placement: coach.phase == _HintPhase.answer ? placement : null,
      digit: coach.phase == _HintPhase.answer && placement != null
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
      for (var cell = 0; cell < 81; cell++)
        if (controller.game!.values[cell] != 0 &&
            (cell ~/ 9 == placement ~/ 9 ||
                cell % 9 == placement % 9 ||
                (cell ~/ 27 == placement ~/ 27 &&
                    cell % 9 ~/ 3 == placement % 9 ~/ 3)))
          cell,
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
                                crossAxisAlignment: .center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${game.puzzle.dailyDate == null ? l.freePlay : l.daily} · ${difficultyLabel(context, game.puzzle.difficulty)}',
                                      style: theme.text.caption.copyWith(
                                        color: theme.colors.mutedForeground,
                                      ),
                                      maxLines: 1,
                                      overflow: .ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    flex: 2,
                                    child: Semantics(
                                      label:
                                          '${l.pointsValue(game.points)}, ${l.mistakesValue(game.mistakes)}${controller.settings.showTimer ? ', ${l.timer}: ${durationLabel(game.elapsedSeconds)}' : ''}',
                                      child: ExcludeSemantics(
                                        child: Row(
                                          key: const ValueKey('game-score'),
                                          mainAxisAlignment: .end,
                                          children: [
                                            SizedBox(
                                              width: 36,
                                              child: ReelText(
                                                '${game.points}',
                                                textAlign: .end,
                                                options: ReelTextOptions(
                                                  direction:
                                                      ReelTextDirection.down,
                                                  duration: const Duration(
                                                    milliseconds: 320,
                                                  ),
                                                  stagger: const Duration(
                                                    milliseconds: 28,
                                                  ),
                                                  exitOffset: const Duration(
                                                    milliseconds: 36,
                                                  ),
                                                  curve: Curves.easeOutCubic,
                                                  bounce: .15,
                                                  color: theme.colors.accent,
                                                ),
                                                style: theme.text.caption
                                                    .copyWith(
                                                      color:
                                                          theme.colors.accent,
                                                    ),
                                              ),
                                            ),
                                            Flexible(
                                              child: Text(
                                                ' ${l.pointsLabel} · ${l.mistakesValue(game.mistakes)}${controller.settings.showTimer ? ' · ${durationLabel(game.elapsedSeconds)}' : ''}',
                                                maxLines: 1,
                                                softWrap: false,
                                                overflow: .fade,
                                                style: theme.text.caption
                                                    .copyWith(
                                                      color:
                                                          theme.colors.accent,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
                                      child: Stack(
                                        clipBehavior: .none,
                                        children: [
                                          Positioned.fill(
                                            child: SudokuBoard(
                                              controller: controller,
                                              game: game,
                                              obscured: controller.paused,
                                              hint: _hintVisual,
                                            ),
                                          ),
                                          if (!controller.paused &&
                                              controller.scoreAwardPoints > 0)
                                            _ScorePopup(
                                              key: ValueKey(
                                                controller.scoreAwardSequence,
                                              ),
                                              points:
                                                  controller.scoreAwardPoints,
                                              cell: controller.scoreAwardCell,
                                              boardSize: size,
                                            ),
                                        ],
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
                                child: _GameControls(
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

final class const _GameControls({
  required final SudokuController controller,
  required final _HintCoachState? coach,
  required final VoidCallback onShowHint,
  required final VoidCallback onAdvanceHint,
  required final VoidCallback onExplainHint,
  required final VoidCallback onCloseHint,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n,
        theme = context.rudiTheme,
        game = controller.game!,
        activeCoach = coach;
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
    final scaledCaption = MediaQuery.textScalerOf(context).scale(14);
    final contextControlsHeight = 96.0 * math.max(1.0, scaledCaption / 14.0);
    final digitCounts = List<int>.filled(10, 0);
    for (final value in game.values) {
      digitCounts[value]++;
    }
    return Column(
      mainAxisSize: .min,
      children: [
        SizedBox(
          key: const ValueKey('game-context-controls'),
          height: contextControlsHeight,
          child: AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 240),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            layoutBuilder: (currentChild, previousChildren) => Stack(
              alignment: .topCenter,
              children: [...previousChildren, ?currentChild],
            ),
            child: activeCoach != null
                ? Cue.onMount(
                    key: ValueKey(
                      'hint-${activeCoach.hint.status.name}-${activeCoach.stepIndex}-${activeCoach.phase.name}',
                    ),
                    motion: MediaQuery.disableAnimationsOf(context)
                        ? CueMotion.none
                        : .smooth(),
                    acts: [.translateY(from: 6)],
                    child: _HintCoach(
                      coach: activeCoach,
                      onAdvance: onAdvanceHint,
                      onExplain: onExplainHint,
                      onClose: onCloseHint,
                    ),
                  )
                : _GameTools(
                    key: const ValueKey('game-tools'),
                    controller: controller,
                    enabled: enabled,
                    onShowHint: onShowHint,
                  ),
          ),
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
                    onPressed: enabled && digitCounts[number] < 9
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

final class const _ScorePopup({
  required final int points,
  required final int cell,
  required final double boardSize,
  super.key,
}) extends StatefulWidget {
  @override
  State<_ScorePopup> createState() => _ScorePopupState();
}

final class _ScorePopupState() extends State<_ScorePopup> {
  static const _animationDuration = Duration(milliseconds: 1400);

  Timer? _reducedMotionTimer;
  var _visible = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) &&
        _reducedMotionTimer == null) {
      _reducedMotionTimer = Timer(_animationDuration, () {
        if (mounted) setState(() => _visible = false);
      });
    }
  }

  @override
  void dispose() {
    _reducedMotionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final theme = context.rudiTheme;
    final cellSize = widget.boardSize / 9;
    final row = widget.cell ~/ 9, column = widget.cell % 9;
    const popupWidth = 56.0;
    final left = (column + .5) * cellSize - popupWidth / 2;
    final top = (row == 0 ? 4.0 : row * cellSize - 12) - 20;
    final label = SizedBox(
      width: popupWidth,
      child: DecoratedBox(
        key: const ValueKey('score-popup'),
        decoration: BoxDecoration(
          color: theme.colors.surface.withValues(alpha: .96),
          borderRadius: .circular(999),
          border: Border.all(color: theme.colors.accent.withValues(alpha: .18)),
          boxShadow: [
            BoxShadow(
              color: theme.colors.foreground.withValues(alpha: .12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),

        child: Center(
          child: Text(
            '+${widget.points}',
            textAlign: .center,
            textScaler: TextScaler.noScaling,
            maxLines: 1,
            softWrap: false,
            overflow: .visible,
            style: theme.text.title.copyWith(
              color: theme.colors.accent,
              fontWeight: .w700,
              height: 1,
            ),
          ),
        ),
      ),
    );
    return Positioned(
      left: left,
      top: top,
      width: popupWidth,
      height: 48,
      child: IgnorePointer(
        child: Semantics(
          liveRegion: true,
          label: context.l10n.pointsAwarded(widget.points),
          child: ExcludeSemantics(
            child: MediaQuery.disableAnimationsOf(context)
                ? label
                : Cue.onMount(
                    motion: .easeOut(_animationDuration),
                    acts: [
                      OpacityAct.keyframed(
                        frames: Keyframes.fractional(
                          const [
                            .key(1, at: 0),
                            .key(1, at: .65),
                            .key(0, at: 1),
                          ],
                          duration: _animationDuration,
                          curve: Curves.easeIn,
                        ),
                      ),
                      TranslateAct.keyframedY(
                        frames: Keyframes.fractional(
                          const [
                            .key(0, at: 0),
                            .key(-6, at: .65),
                            .key(-18, at: 1),
                          ],
                          duration: _animationDuration,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                    ],
                    child: label,
                  ),
          ),
        ),
      ),
    );
  }
}

final class const _GameTools({
  required final SudokuController controller,
  required final bool enabled,
  required final VoidCallback onShowHint,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n, theme = context.rudiTheme, game = controller.game!;
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

final class const _HintCoach({
  required final _HintCoachState coach,
  required final VoidCallback onAdvance,
  required final VoidCallback onExplain,
  required final VoidCallback onClose,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n, theme = context.rudiTheme, step = coach.step;
    final title = switch ((coach.hint.status, coach.phase, step)) {
      (HintStatus.available, _HintPhase.locate, _) => l.hintLookHere,
      (HintStatus.available, _HintPhase.reason, final LogicalStep step) =>
        techniqueLabel(l, step.technique),
      (HintStatus.available, _HintPhase.answer, _) => l.hintAnswerTitle,
      _ => l.hint,
    };
    final body = switch ((coach.hint.status, coach.phase, step)) {
      (HintStatus.incorrect, _, _) => l.hintIncorrect,
      (HintStatus.complete, _, _) => l.finished,
      (HintStatus.unavailable, _, _) => l.hintUnavailable,
      (HintStatus.available, _HintPhase.locate, final LogicalStep step)
          when step.placement != null =>
        l.hintLocateCell(hintCellLabel(l, step.placement!)),
      (HintStatus.available, _HintPhase.locate, _) => l.hintLocateArea,
      (HintStatus.available, _HintPhase.reason, final LogicalStep step)
          when step.placement != null =>
        l.hintReasonPlacement,
      (HintStatus.available, _HintPhase.reason, _) => l.hintReasonElimination,
      (HintStatus.available, _HintPhase.answer, final LogicalStep step) =>
        l.hintEnterValue(
          hintCellLabel(l, step.placement!),
          step.digits.bitLength - 1,
        ),
      _ => l.hintUnavailable,
    };
    final actionLabel = switch ((coach.phase, step)) {
      (_, null) || (_HintPhase.answer, _) => null,
      (_HintPhase.locate, _) => l.hintExplainWhy,
      (_HintPhase.reason, final LogicalStep step)
          when step.placement == null &&
              coach.stepIndex < coach.hint.steps.length - 1 =>
        l.hintContinue,
      (_HintPhase.reason, _) => l.hintShowAnswer,
    };
    return Semantics(
      key: const ValueKey('hint-coach'),
      container: true,
      liveRegion: true,
      label: '$title. $body',
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Expanded(
            child: ExcludeSemantics(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    title,
                    style: theme.text.label.copyWith(
                      color: coach.hint.status == HintStatus.available
                          ? theme.colors.accent
                          : theme.colors.foreground,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    body,
                    style: theme.text.caption.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                    maxLines: 2,
                    overflow: .ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: .end,
            children: [
              Row(
                mainAxisSize: .min,
                children: [
                  if (step != null && coach.phase == _HintPhase.answer)
                    RudiIconButton(
                      key: const ValueKey('hint-explanation'),
                      icon: const AppIcon(AppSymbol.info),
                      semanticLabel: l.hintExplanation,
                      onPressed: onExplain,
                    ),
                  RudiIconButton(
                    key: const ValueKey('hint-close'),
                    icon: const AppIcon(AppSymbol.close),
                    semanticLabel: l.close,
                    onPressed: onClose,
                  ),
                ],
              ),
              if (actionLabel != null)
                _HintCoachAction(label: actionLabel, onPressed: onAdvance),
            ],
          ),
        ],
      ),
    );
  }
}

final class const _HintCoachAction({
  required final String label,
  required final VoidCallback onPressed,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return RudiPressable(
      key: const ValueKey('hint-advance'),
      semanticLabel: label,
      onPressed: onPressed,
      builder: (context, state) => AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : theme.motion.fast,
        constraints: const BoxConstraints(minHeight: 36, minWidth: 48),
        padding: const .symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: state.pressed || state.hovered
              ? theme.colors.accent
              : theme.colors.surface,
          borderRadius: .circular(theme.radii.pill),
        ),
        child: Text(
          label,
          style: theme.text.caption.copyWith(
            color: state.pressed || state.hovered
                ? theme.colors.onPrimary
                : theme.colors.foreground,
          ),
        ),
      ),
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
