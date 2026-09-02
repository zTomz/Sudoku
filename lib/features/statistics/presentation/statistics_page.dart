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
    return ContentPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeading(l.statistics),
          if (results.isEmpty) ...[
            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: AppIcon(AppSymbol.chart, size: 48),
            ),
            const SizedBox(height: 24),
            Text(l.noStatistics, style: theme.text.headline),
            const SizedBox(height: 12),
            Text(l.noStatisticsDescription),
          ] else ...[
            Text(
              '${results.length}',
              style: theme.text.display.copyWith(
                fontSize: 80,
                color: theme.colors.accent,
              ),
            ),
            Text(l.solved, style: theme.text.title),
            const SizedBox(height: 8),
            Text(
              l.pointsValue(controller.totalPoints),
              style: theme.text.headline.copyWith(color: theme.colors.accent),
            ),
            const SizedBox(height: 24),
            Text(
              '${l.totalTime}: ${durationLabel(results.fold(0, (total, result) => total + result.seconds))}',
            ),
          ],
          const SizedBox(height: 40),
          for (final difficulty in Difficulty.values) ...[
            Container(height: 1, color: theme.colors.outline),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Builder(
                builder: (context) {
                  final matching =
                      results
                          .where((result) => result.difficulty == difficulty)
                          .toList()
                        ..sort((a, b) => a.seconds.compareTo(b.seconds));
                  return Wrap(
                    spacing: 24,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Text(
                        difficultyLabel(context, difficulty),
                        style: theme.text.title,
                      ),
                      Text('${matching.length} ${l.solved.toLowerCase()}'),
                      Text(
                        l.mistakesValue(
                          matching.fold(
                            0,
                            (total, result) => total + result.mistakes,
                          ),
                        ),
                      ),
                      Text(
                        matching.isEmpty
                            ? '—'
                            : durationLabel(matching.first.seconds),
                        semanticsLabel:
                            '${l.bestTime}: ${matching.isEmpty ? '—' : durationLabel(matching.first.seconds)}',
                        style: theme.text.title,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
