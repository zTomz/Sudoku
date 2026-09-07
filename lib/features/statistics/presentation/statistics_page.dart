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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeading(l.statistics),

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
              _Statistic(
                label: l.totalTime,
                value: durationLabel(
                  results.fold(0, (total, result) => total + result.seconds),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(l.difficulty, style: theme.text.headline),
          const SizedBox(height: 8),
          for (final difficulty in Difficulty.values)
            Builder(
              builder: (context) {
                final matching = results
                    .where((result) => result.difficulty == difficulty)
                    .toList();
                final best = matching.isEmpty
                    ? null
                    : matching
                          .map((result) => result.seconds)
                          .reduce((a, b) => a < b ? a : b);
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: theme.colors.outline),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        difficultyLabel(context, difficulty),
                        style: theme.text.title,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 40,
                        runSpacing: 20,
                        children: [
                          SizedBox(
                            width: 112,
                            child: _Statistic(
                              label: l.solved,
                              value: '${matching.length}',
                            ),
                          ),
                          _Statistic(
                            label: l.bestTime,
                            value: best == null ? '—' : durationLabel(best),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l.mistakesValue(
                          matching.fold(
                            0,
                            (total, result) => total + result.mistakes,
                          ),
                        ),
                        style: theme.text.body.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

final class const _EmptyStatistics() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final inset = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 40.0;
    return RudiPage(
      padding: EdgeInsets.zero,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(inset, inset, inset, 128),
                sliver: SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PageHeading(context.l10n.statistics),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/statistics_empty.png',
                                    fit: BoxFit.contain,
                                    excludeFromSemantics: true,
                                  ),
                                  const SizedBox(height: 20),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      context.l10n.noStatisticsDescription,
                                      textAlign: TextAlign.center,
                                      style: theme.text.body.copyWith(
                                        color: theme.colors.mutedForeground,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
