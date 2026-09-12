import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../app/sudoku_controller.dart';
import '../../../common/presentation/ui.dart';
import '../../game/domain/puzzle.dart';

final class const StatisticsPage({
  required final SudokuController controller,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n, theme = context.rudiTheme;
    final results = controller.results.toList();
    if (results.isEmpty) return const _EmptyStatistics();
    return ContentPage(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useDashboard =
              constraints.maxWidth >= 760 &&
              MediaQuery.textScalerOf(context).scale(16) <= 22;
          final totalTime = durationLabel(
            results.fold(0, (total, result) => total + result.seconds),
          );
          final breakdowns = [
            for (final difficulty in Difficulty.values)
              _DifficultyBreakdown(
                key: ValueKey('statistics-difficulty-${difficulty.name}'),
                difficulty: difficulty,
                solved: results
                    .where((result) => result.difficulty == difficulty)
                    .length,
                best: _minimumOrNull(
                  results
                      .where((result) => result.difficulty == difficulty)
                      .map((result) => result.seconds),
                ),
                mistakes: results
                    .where((result) => result.difficulty == difficulty)
                    .fold(0, (total, result) => total + result.mistakes),
                card: useDashboard,
              ),
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeading(l.statistics),
              if (useDashboard) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _StatisticCard(
                        label: l.solved,
                        value: '${results.length}',
                        accent: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatisticCard(
                        label: l.pointsLabel,
                        value: '${controller.totalPoints}',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatisticCard(
                        label: l.totalTime,
                        value: totalTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(l.difficulty, style: theme.text.headline),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (index, breakdown) in breakdowns.indexed) ...[
                      if (index > 0) const SizedBox(width: 16),
                      Expanded(child: breakdown),
                    ],
                  ],
                ),
              ] else ...[
                _Statistic(
                  label: l.solved,
                  value: '${results.length}',
                  prominent: true,
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 48,
                  runSpacing: 24,
                  children: [
                    _Statistic(
                      label: l.pointsLabel,
                      value: '${controller.totalPoints}',
                    ),
                    _Statistic(label: l.totalTime, value: totalTime),
                  ],
                ),
                const SizedBox(height: 40),
                Text(l.difficulty, style: theme.text.headline),
                const SizedBox(height: 8),
                ...breakdowns,
              ],
            ],
          );
        },
      ),
    );
  }
}

final class const _StatisticCard({
  required final String label,
  required final String value,
  final bool accent = false,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.text.body.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: theme.text.display.copyWith(
                  fontSize: 40,
                  color: accent ? theme.colors.accent : theme.colors.foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class const _DifficultyBreakdown({
  required final Difficulty difficulty,
  required final int solved,
  required final int? best,
  required final int mistakes,
  required final bool card,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n, theme = context.rudiTheme;
    final bestTime = best;
    if (card) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                difficultyLabel(context, difficulty),
                style: theme.text.title,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _CompactStatistic(label: l.solved, value: '$solved'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CompactStatistic(
                      label: l.bestTime,
                      value: bestTime == null ? '—' : durationLabel(bestTime),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l.mistakesValue(mistakes),
                style: theme.text.caption.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      );
    }
    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(difficultyLabel(context, difficulty), style: theme.text.title),
          const SizedBox(height: 14),
          Wrap(
            spacing: 28,
            runSpacing: 16,
            children: [
              _Statistic(label: l.solved, value: '$solved'),
              _Statistic(
                label: l.bestTime,
                value: bestTime == null ? '—' : durationLabel(bestTime),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l.mistakesValue(mistakes),
            style: theme.text.body.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colors.outline)),
      ),
      child: content,
    );
  }
}

final class const _CompactStatistic({
  required final String label,
  required final String value,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.text.caption.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 3),
          Text(value, style: theme.text.title),
        ],
      ),
    );
  }
}

int? _minimumOrNull(Iterable<int> values) {
  final iterator = values.iterator;
  if (!iterator.moveNext()) return null;
  var minimum = iterator.current;
  while (iterator.moveNext()) {
    if (iterator.current < minimum) minimum = iterator.current;
  }
  return minimum;
}

final class const _EmptyStatistics() extends StatelessWidget {
  @override
  Widget build(BuildContext context) => RudiPage(
    padding: EdgeInsets.zero,
    safeAreaBottom: false,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final inset = constraints.maxWidth < 600 ? 16.0 : 40.0;
        final useWideLayout =
            constraints.maxWidth >= 800 &&
            constraints.maxHeight >= 400 &&
            MediaQuery.textScalerOf(context).scale(16) <= 22;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                inset,
                inset,
                inset,
                appNavigationContentInset,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PageHeading(context.l10n.statistics),
                  Expanded(
                    child: useWideLayout
                        ? _WideEmptyStatistics(
                            artworkExtent: math.min(
                              240,
                              constraints.maxHeight - 238,
                            ),
                          )
                        : const _CompactEmptyStatistics(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

final class const _WideEmptyStatistics({required final double artworkExtent})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Center(
      child: ConstrainedBox(
        key: const ValueKey('statistics-empty-wide'),
        constraints: const BoxConstraints(maxWidth: 760),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.surface,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                SizedBox.square(
                  dimension: artworkExtent,
                  child: Image.asset(
                    'assets/statistics_empty.png',
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                ),
                const SizedBox(width: 36),
                const Expanded(
                  child: _EmptyStatisticsCopy(textAlign: TextAlign.start),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class const _CompactEmptyStatistics() extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      key: const ValueKey('statistics-empty-compact'),
      constraints: const BoxConstraints(maxWidth: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: Image.asset(
                  'assets/statistics_empty.png',
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _EmptyStatisticsCopy(textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}

final class const _EmptyStatisticsCopy({required final TextAlign textAlign})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.noStatistics,
          textAlign: textAlign,
          style: theme.text.headline,
        ),
        const SizedBox(height: 10),
        Text(
          context.l10n.noStatisticsDescription,
          textAlign: textAlign,
          style: theme.text.body.copyWith(color: theme.colors.mutedForeground),
        ),
      ],
    );
  }
}

final class const _Statistic({
  required final String label,
  required final String value,
  final bool prominent = false,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.text.body.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: (prominent ? theme.text.display : theme.text.headline)
                .copyWith(
                  fontSize: prominent ? 64 : null,
                  color: prominent
                      ? theme.colors.accent
                      : theme.colors.foreground,
                ),
          ),
        ],
      ),
    );
  }
}
