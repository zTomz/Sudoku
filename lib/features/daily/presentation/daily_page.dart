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
    final l = context.l10n;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monthPrefix = dateKey(_month).substring(0, 7);
    final completed = widget.controller.dailyGames.entries
        .where(
          (entry) => entry.key.startsWith(monthPrefix) && entry.value.complete,
        )
        .length;

    RudiCalendarDayState stateFor(DateTime date) {
      if (date.isAfter(today)) return RudiCalendarDayState.unavailable;
      final game = widget.controller.dailyGames[dateKey(date)];
      if (game?.complete == true) return RudiCalendarDayState.completed;
      if (game != null) return RudiCalendarDayState.inProgress;
      return RudiCalendarDayState.available;
    }

    String semanticLabel(DateTime date, RudiCalendarDayState state) {
      final status = switch (state) {
        RudiCalendarDayState.completed => l.completed,
        RudiCalendarDayState.inProgress => l.inProgress,
        RudiCalendarDayState.unavailable => l.futureDay,
        RudiCalendarDayState.available => l.notStarted,
      };
      return '${DateFormat.yMMMMd(l.localeName).format(date)}, $status';
    }

    return ContentPage(
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          PageHeading(l.dailyArchive, subtitle: l.calendarDescription),
          RudiCalendar(
            initialMonth: DateTime(today.year, today.month),
            firstMonth: DateTime(1970),
            lastMonth: DateTime(today.year, today.month),
            today: today,
            weekdayLabels: [
              for (var index = 0; index < 7; index++)
                DateFormat.E(l.localeName).format(DateTime(2026, 8, 3 + index)),
            ],
            monthLabelBuilder: (month) =>
                DateFormat.yMMMM(l.localeName).format(month),
            dayStateBuilder: stateFor,
            daySemanticLabelBuilder: semanticLabel,
            previousMonthSemanticLabel: l.previousMonth,
            nextMonthSemanticLabel: l.nextMonth,
            onMonthChanged: (month) => setState(() => _month = month),
            onDayPressed: (date) =>
                unawaited(widget.controller.startDaily(date)),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.rudiTheme.colors.accent.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const .all(7),
                  child: AppIcon(
                    AppSymbol.check,
                    size: 16,
                    color: context.rudiTheme.colors.accent,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l.monthProgress(completed),
                  style: context.rudiTheme.text.label,
                ),
              ),
            ],
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
