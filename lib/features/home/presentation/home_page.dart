import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../app/sudoku_controller.dart';
import '../../../common/presentation/ui.dart';
import '../../game/domain/puzzle.dart';
import 'widgets/difficulty_selector.dart';
import 'widgets/home_daily_card.dart';
import 'widgets/home_resume_card.dart';

final class const HomePage({
  required final SudokuController controller,
  super.key,
}) extends StatelessWidget {
  Future<void> _newGame(BuildContext context, Difficulty difficulty) async {
    final l = context.l10n;
    if (controller.free case final game?
        when !game.complete && game.history.isNotEmpty) {
      final confirmed = await showRudiDialog<bool>(
        context: context,
        barrierLabel: l.close,
        builder: (dialogContext) => RudiDialog(
          title: Text(l.replaceTitle),
          content: Text(l.replaceMessage),
          actions: [
            RudiButton(
              label: l.cancel,
              variant: .subtle,
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            RudiButton(
              label: l.start,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
    }
    await controller.startFree(difficulty);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n, theme = context.rudiTheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final saved = controller.free;
    final solvedThisMonth = controller.results
        .where(
          (result) =>
              result.dailyDate?.startsWith(dateKey(today).substring(0, 7)) ==
              true,
        )
        .length;
    return RudiPage(
      padding: .zero,
      child: Align(
        alignment: .topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const .fromLTRB(16, 16, 16, 128),
            children: [
              Row(
                children: [
                  IconTheme(
                    data: IconThemeData(color: theme.colors.accent),
                    child: const AppIcon(AppSymbol.grid, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l.appTitle,
                      style: theme.text.headline.copyWith(letterSpacing: -.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l.homeSubtitle,
                style: theme.text.body.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 24),
              DailyCard(controller: controller, today: today),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconTheme(
                    data: IconThemeData(color: theme.colors.accent),
                    child: const AppIcon(AppSymbol.check, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l.monthProgress(solvedThisMonth)} · ${l.pointsValue(controller.totalPoints)}',
                      style: theme.text.caption.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ),
              if (saved != null && !saved.complete) ...[
                const SizedBox(height: 24),
                ResumeCard(controller: controller),
              ],
              const SizedBox(height: 28),
              Text(
                l.newGame,
                key: const ValueKey('new-game'),
                style: theme.text.title,
              ),
              const SizedBox(height: 6),
              Text(
                l.chooseDifficulty,
                style: theme.text.caption.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 14),
              DifficultySelector(
                onSelected: (difficulty) =>
                    unawaited(_newGame(context, difficulty)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
