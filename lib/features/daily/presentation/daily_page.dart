import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../app/sudoku_controller.dart';
import '../../../common/presentation/ui.dart';
import '../../game/domain/puzzle.dart';

final class const DailyPage({
  required final SudokuController controller,
  super.key,
}) extends StatefulWidget {
  @override
  State<DailyPage> createState() => _DailyPageState();
}

final class _DailyPageState() extends State<DailyPage> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  @override
  Widget build(BuildContext context) {
    final l = context.l10n, theme = context.rudiTheme;
    final now = DateTime.now(), first = DateTime(_month.year, _month.month);
    final today = DateTime(now.year, now.month, now.day);
    final days = DateTime(_month.year, _month.month + 1, 0).day,
        offset = first.weekday - 1;
    final monthPrefix = dateKey(first).substring(0, 7);
    final completed = widget.controller.dailyGames.entries
        .where(
          (entry) => entry.key.startsWith(monthPrefix) && entry.value.complete,
        )
        .length;
    return ContentPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeading(l.dailyArchive, subtitle: l.calendarDescription),
          Row(
            children: [
              RudiIconButton(
                icon: const RotatedBox(
                  quarterTurns: 2,
                  child: AppIcon(AppSymbol.chevron),
                ),
                semanticLabel: l.previousMonth,
                onPressed: _month.year > 1970 || _month.month > 1
                    ? () => setState(
                        () => _month = DateTime(_month.year, _month.month - 1),
                      )
                    : null,
              ),
              Expanded(
                child: Text(
                  DateFormat.yMMMM(l.localeName).format(_month),
                  textAlign: TextAlign.center,
                  style: theme.text.title,
                ),
              ),
              RudiIconButton(
                icon: const AppIcon(AppSymbol.chevron),
                semanticLabel: l.nextMonth,
                onPressed:
                    DateTime(_month.year, _month.month + 1).isAfter(today)
                    ? null
                    : () => setState(
                        () => _month = DateTime(_month.year, _month.month + 1),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Text(
                    DateFormat.E(l.localeName).format(DateTime(2026, 8, 3 + i)),
                    textAlign: TextAlign.center,
                    style: theme.text.caption.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          for (var week = 0; week < (offset + days + 6) ~/ 7; week++)
            Row(
              children: [
                for (var weekday = 0; weekday < 7; weekday++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Builder(
                        builder: (context) {
                          final day = week * 7 + weekday - offset + 1;
                          if (day < 1 || day > days) {
                            return const SizedBox(height: 56);
                          }
                          final date = DateTime(_month.year, _month.month, day);
                          final future = date.isAfter(today),
                              game =
                                  widget.controller.dailyGames[dateKey(date)];
                          final status = future
                              ? l.futureDay
                              : game?.complete == true
                              ? l.completed
                              : game != null
                              ? l.inProgress
                              : l.notStarted;
                          return RudiPressable(
                            key: ValueKey('day-${dateKey(date)}'),
                            semanticLabel:
                                '${DateFormat.yMMMMd(l.localeName).format(date)}, $status',
                            onPressed: future
                                ? null
                                : () => unawaited(
                                    widget.controller.startDaily(date),
                                  ),
                            builder: (context, state) => Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: game?.complete == true
                                    ? theme.colors.accent
                                    : state.hovered
                                    ? theme.colors.surfaceContainer
                                    : null,
                                borderRadius: BorderRadius.circular(
                                  theme.radii.md,
                                ),
                                border: date == today || state.focused
                                    ? Border.all(
                                        color: theme.colors.accent,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$day',
                                    style: theme.text.label.copyWith(
                                      color: game?.complete == true
                                          ? theme.colors.onAccent
                                          : future
                                          ? theme.colors.mutedForeground
                                          : theme.colors.foreground,
                                    ),
                                  ),
                                  if (game != null)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: game.complete
                                            ? theme.colors.onAccent
                                            : theme.colors.accent,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 24),
          Text(
            l.monthProgress(completed),
            style: theme.text.label,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          RudiButton(
            label: l.playDaily,
            leading: const AppIcon(AppSymbol.play),
            expand: true,
            onPressed: () => unawaited(widget.controller.startDaily(today)),
          ),
        ],
      ),
    );
  }
}
