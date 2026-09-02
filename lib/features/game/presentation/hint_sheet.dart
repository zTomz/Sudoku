import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../app/sudoku_controller.dart';
import '../../../common/presentation/app_sheet.dart';
import '../../../common/presentation/ui.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/difficulty_rating.dart';
import '../domain/logical_solver.dart';
import '../domain/sudoku_grid.dart';

Future<void> showHintExplanation(
  BuildContext context, {
  required LogicalStep step,
  required DifficultyRating? rating,
}) => showAppSheet<void>(
  context: context,
  title: context.l10n.hintExplanation,
  builder: (_) => HintExplanationContent(step: step, rating: rating),
);

final class const HintExplanationContent({
  required final LogicalStep step,
  required final DifficultyRating? rating,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n, theme = context.rudiTheme;
    final paused = ref.watch(sudokuControllerProvider.select((s) => s.paused));
    if (paused) return Text(l.paused, style: theme.text.body);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(techniqueLabel(l, step.technique), style: theme.text.title),
        const SizedBox(height: 12),
        Text(explainStep(l, step), style: theme.text.body),
        if (rating != null) ...[
          const SizedBox(height: 24),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.colors.outline.withValues(alpha: .55),
                ),
              ),
            ),
            child: Padding(
              padding: const .only(top: 16),
              child: Text(
                l.hintRating(rating!.score, rating!.steps, rating!.bottlenecks),
                style: theme.text.caption.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          ),
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

String hintCellLabel(AppLocalizations l, int cell) =>
    l.hintCell(rowOf(cell) + 1, columnOf(cell) + 1);

String explainStep(AppLocalizations l, LogicalStep step) {
  String cell(int c) => hintCellLabel(l, c);
  String digits(int mask) => [
    for (var d = 1; d <= sudokuSideLength; d++)
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
