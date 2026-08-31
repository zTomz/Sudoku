import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../app/hint_provider.dart';
import '../../../app/sudoku_controller.dart';
import '../../../common/presentation/app_sheet.dart';
import '../../../common/presentation/ui.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/game_hint.dart';
import '../domain/logical_solver.dart';

Future<void> showHint(BuildContext context) => showAppSheet<void>(
  context: context,
  title: context.l10n.hint,
  builder: (_) => const HintContent(),
);

final class const HintContent({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n, theme = context.rudiTheme;
    final paused = ref.watch(sudokuControllerProvider.select((s) => s.paused));
    if (paused) return Text(l.paused, style: theme.text.body);
    final hint = ref.watch(gameHintProvider);
    final rating = ref.read(sudokuControllerProvider).game?.puzzle.rating;
    final message = switch (hint?.status) {
      HintStatus.available => l.hintIntro,
      HintStatus.incorrect => l.hintIncorrect,
      HintStatus.complete => l.finished,
      HintStatus.unavailable || null => l.hintUnavailable,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(message, style: theme.text.body),
        if (hint?.status == HintStatus.available) ...[
          for (var i = 0; i < hint!.steps.length; i++) ...[
            const SizedBox(height: 20),
            Text(
              l.hintStep(i + 1, techniqueLabel(l, hint.steps[i].technique)),
              style: theme.text.title,
            ),
            const SizedBox(height: 8),
            Text(explainStep(l, hint.steps[i]), style: theme.text.body),
          ],
          if (rating != null) ...[
            const SizedBox(height: 24),
            Text(
              l.hintRating(rating.score, rating.steps, rating.bottlenecks),
              style: theme.text.caption.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

String techniqueLabel(AppLocalizations l, SolveTechnique technique) =>
    switch (technique) {
      SolveTechnique.nakedSingle => l.techniqueNakedSingle,
      SolveTechnique.hiddenSingle => l.techniqueHiddenSingle,
      SolveTechnique.lockedCandidates => l.techniqueLocked,
      SolveTechnique.nakedPair => l.techniqueNakedPair,
      SolveTechnique.hiddenPair => l.techniqueHiddenPair,
      SolveTechnique.nakedTriple => l.techniqueNakedTriple,
      SolveTechnique.hiddenTriple => l.techniqueHiddenTriple,
      SolveTechnique.xWing => l.techniqueXWing,
      SolveTechnique.xyWing => l.techniqueXYWing,
    };

String explainStep(AppLocalizations l, LogicalStep step) {
  String cell(int c) => l.hintCell(c ~/ 9 + 1, c % 9 + 1);
  String digits(int mask) => [
    for (var d = 1; d <= 9; d++)
      if (mask & (1 << d) != 0) d,
  ].join(', ');
  final places = step.cells.map(cell).join('; ');
  final numbers = digits(step.digits);
  final reasoning = switch (step.technique) {
    SolveTechnique.nakedSingle => l.hintNakedSingle(
      cell(step.placement!),
      numbers,
    ),
    SolveTechnique.hiddenSingle => l.hintHiddenSingle(
      cell(step.placement!),
      numbers,
      places,
    ),
    SolveTechnique.lockedCandidates => l.hintLocked(numbers, places),
    SolveTechnique.nakedPair ||
    SolveTechnique.nakedTriple => l.hintNakedSubset(numbers, places),
    SolveTechnique.hiddenPair ||
    SolveTechnique.hiddenTriple => l.hintHiddenSubset(numbers, places),
    SolveTechnique.xWing => l.hintXWing(numbers, places),
    SolveTechnique.xyWing => l.hintXYWing(numbers, places),
  };
  final evidence = [
    for (final entry in step.candidates.entries)
      if (entry.value != 0)
        l.hintCandidate(cell(entry.key), digits(entry.value)),
  ].join('; ');
  final removals = [
    for (final removal in step.removals)
      l.hintRemoval(digits(removal.mask), cell(removal.cell)),
  ].join('\n');
  return [
    reasoning,
    if (evidence.isNotEmpty) l.hintCandidates(evidence),
    if (removals.isNotEmpty) removals,
  ].join('\n\n');
}
