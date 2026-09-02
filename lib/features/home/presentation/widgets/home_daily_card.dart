import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../../app/sudoku_controller.dart';
import '../../../../common/presentation/ui.dart';
import '../../../game/domain/puzzle.dart';

final class const DailyCard({
  required final SudokuController controller,
  required final DateTime today,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n, theme = context.rudiTheme;
    final daily = controller.dailyGames[dateKey(today)];
    final monday = DateTime(
      today.year,
      today.month,
      today.day - today.weekday + 1,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: .topLeft,
          end: .bottomRight,
          colors: [
            theme.colors.accent,
            Color.lerp(theme.colors.accent, const Color(0xff000000), .12)!,
          ],
        ),
        borderRadius: .circular(28),
      ),
      child: CustomPaint(
        painter: _DailyTexture(theme.colors.onAccent),
        child: Padding(
          padding: const .all(22),
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              RudiPressable(
                key: const ValueKey('daily-today'),
                onPressed: () =>
                    unawaited(controller.startDaily(DateTime.now())),
                builder: (context, state) => AnimatedOpacity(
                  opacity: state.pressed ? .75 : 1,
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : theme.motion.fast,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: .circular(10),
                      border: state.focused
                          ? Border.all(color: theme.colors.onAccent, width: 2)
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Row(
                          children: [
                            IconTheme(
                              data: IconThemeData(color: theme.colors.onAccent),
                              child: const AppIcon(
                                AppSymbol.calendar,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l.dailyTitle,
                                style: theme.text.label.copyWith(
                                  color: theme.colors.onAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          DateFormat.MMMMd(l.localeName).format(today),
                          style: theme.text.display.copyWith(
                            fontSize: 32,
                            color: theme.colors.onAccent,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                daily?.complete == true
                                    ? l.completed
                                    : daily == null
                                    ? l.playDaily
                                    : l.continueGame,
                                style: theme.text.label.copyWith(
                                  color: theme.colors.onAccent,
                                ),
                              ),
                            ),
                            AppIcon(
                              daily?.complete == true
                                  ? AppSymbol.check
                                  : AppSymbol.chevron,
                              color: theme.colors.onAccent,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 1,
                color: theme.colors.onAccent.withValues(alpha: .2),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (var offset = 0; offset < 7; offset++)
                    Expanded(
                      child: _WeekDay(
                        controller: controller,
                        today: today,
                        date: DateTime(
                          monday.year,
                          monday.month,
                          monday.day + offset,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class const _WeekDay({
  required final SudokuController controller,
  required final DateTime today,
  required final DateTime date,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n, theme = context.rudiTheme;
    final current = date == today, future = date.isAfter(today);
    final done = controller.dailyGames[dateKey(date)]?.complete == true;
    final ink = theme.colors.onAccent;
    return Semantics(
      selected: current,
      child: RudiPressable(
        key: ValueKey('home-day-${dateKey(date)}'),
        semanticLabel:
            '${DateFormat.yMMMMEEEEd(l.localeName).format(date)}, ${done
                ? l.completed
                : future
                ? l.futureDay
                : l.playDaily}',
        onPressed: future ? null : () => unawaited(controller.startDaily(date)),
        builder: (context, state) => Padding(
          padding: const .symmetric(vertical: 4),
          child: ExcludeSemantics(
            child: Column(
              children: [
                FittedBox(
                  fit: .scaleDown,
                  child: Text(
                    DateFormat.E(l.localeName).format(date),
                    style: theme.text.caption.copyWith(
                      color: ink.withValues(alpha: future ? .45 : .8),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 32,
                  height: 32,
                  alignment: .center,
                  decoration: BoxDecoration(
                    shape: .circle,
                    color: current || done
                        ? ink
                        : state.pressed || state.hovered
                        ? ink.withValues(alpha: .15)
                        : null,
                    border: state.focused
                        ? Border.all(color: ink, width: 2)
                        : null,
                  ),
                  child: done
                      ? AppIcon(
                          AppSymbol.check,
                          color: theme.colors.accent,
                          size: 18,
                        )
                      : Text(
                          '${date.day}',
                          textScaler: TextScaler.noScaling,
                          style: theme.text.caption.copyWith(
                            fontWeight: .w700,
                            color: current
                                ? theme.colors.accent
                                : ink.withValues(alpha: future ? .45 : 1),
                          ),
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

/// Static vector texture, confined to the card's right side and behind content.
final class _DailyTexture(final Color color) extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(28)),
    );
    for (var x = size.width * .46; x < size.width; x += 13) {
      final strength = (x / size.width - .46) / .54;
      final paint = Paint()
        ..color = color.withValues(alpha: .03 + strength * .12);
      for (var y = 8.0; y < size.height; y += 13) {
        canvas.drawCircle(Offset(x, y), 1.1, paint);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DailyTexture oldDelegate) => oldDelegate.color != color;
}
