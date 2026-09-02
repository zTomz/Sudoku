import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../../common/presentation/ui.dart';
import '../../domain/game_hint.dart';
import '../../domain/logical_solver.dart';
import '../hint_sheet.dart';

enum HintPhase() {
  locate,
  reason,
  answer,
}

final class HintCoachState(
  final GameHint hint, {
  final int stepIndex = 0,
  final HintPhase phase = HintPhase.locate,
}) {
  LogicalStep? get step =>
      hint.status == HintStatus.available ? hint.steps[stepIndex] : null;
}

final class const GameHintCoach({
  required final HintCoachState coach,
  required final VoidCallback onAdvance,
  required final VoidCallback onExplain,
  required final VoidCallback onClose,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = context.rudiTheme;
    final step = coach.step;
    final title = switch ((coach.hint.status, coach.phase, step)) {
      (HintStatus.available, HintPhase.locate, _) => l.hintLookHere,
      (HintStatus.available, HintPhase.reason, final LogicalStep step) =>
        techniqueLabel(l, step.technique),
      (HintStatus.available, HintPhase.answer, _) => l.hintAnswerTitle,
      _ => l.hint,
    };
    final body = switch ((coach.hint.status, coach.phase, step)) {
      (HintStatus.incorrect, _, _) => l.hintIncorrect,
      (HintStatus.complete, _, _) => l.finished,
      (HintStatus.unavailable, _, _) => l.hintUnavailable,
      (HintStatus.available, HintPhase.locate, final LogicalStep step)
          when step.placement != null =>
        l.hintLocateCell(hintCellLabel(l, step.placement!)),
      (HintStatus.available, HintPhase.locate, _) => l.hintLocateArea,
      (HintStatus.available, HintPhase.reason, final LogicalStep step)
          when step.placement != null =>
        l.hintReasonPlacement,
      (HintStatus.available, HintPhase.reason, _) => l.hintReasonElimination,
      (HintStatus.available, HintPhase.answer, final LogicalStep step) =>
        l.hintEnterValue(
          hintCellLabel(l, step.placement!),
          step.digits.bitLength - 1,
        ),
      _ => l.hintUnavailable,
    };
    final actionLabel = switch ((coach.phase, step)) {
      (_, null) || (HintPhase.answer, _) => null,
      (HintPhase.locate, _) => l.hintExplainWhy,
      (HintPhase.reason, final LogicalStep step)
          when step.placement == null &&
              coach.stepIndex < coach.hint.steps.length - 1 =>
        l.hintContinue,
      (HintPhase.reason, _) => l.hintShowAnswer,
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
                  if (step != null && coach.phase == HintPhase.answer)
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
