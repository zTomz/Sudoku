import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../app/sudoku_controller.dart';
import '../../../common/presentation/ui.dart';
import '../../game/domain/puzzle.dart';

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
              _DailyCard(controller: controller, today: today),
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
                      l.monthProgress(solvedThisMonth),
                      style: theme.text.caption.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ),
              if (saved != null && !saved.complete) ...[
                const SizedBox(height: 24),
                _ResumeCard(controller: controller),
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
              LayoutBuilder(
                builder: (context, bounds) {
                  final stacked =
                      bounds.maxWidth < 300 ||
                      MediaQuery.textScalerOf(context).scale(16) > 22;
                  final options = [
                    for (final difficulty in Difficulty.values)
                      _DifficultyButton(
                        difficulty: difficulty,
                        onPressed: () =>
                            unawaited(_newGame(context, difficulty)),
                      ),
                  ];
                  return stacked
                      ? Column(
                          crossAxisAlignment: .stretch,
                          children: [
                            for (final (index, option) in options.indexed) ...[
                              if (index > 0) const SizedBox(height: 8),
                              option,
                            ],
                          ],
                        )
                      : Row(
                          children: [
                            for (final (index, option) in options.indexed) ...[
                              if (index > 0) const SizedBox(width: 10),
                              Expanded(child: option),
                            ],
                          ],
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class const _DailyCard({
  required final SudokuController controller,
  required final DateTime today,
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

final class const _ResumeCard({required final SudokuController controller})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n, theme = context.rudiTheme, game = controller.free!;
    return RudiPressable(
      key: const ValueKey('continue-game'),
      onPressed: controller.resumeFree,
      builder: (context, state) => AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : theme.motion.fast,
        padding: const .all(20),
        decoration: BoxDecoration(
          color: state.pressed
              ? theme.colors.surfaceContainer
              : theme.colors.surface,
          borderRadius: .circular(24),
          border: state.focused
              ? Border.all(color: theme.colors.accent, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Row(
              children: [
                IconTheme(
                  data: IconThemeData(color: theme.colors.accent),
                  child: const AppIcon(AppSymbol.play, size: 24, filled: true),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(l.continueGame, style: theme.text.title)),
                AppIcon(
                  AppSymbol.chevron,
                  color: theme.colors.mutedForeground,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${difficultyLabel(context, game.puzzle.difficulty)}${controller.settings.showTimer ? ' · ${durationLabel(game.elapsedSeconds)}' : ''}',
              style: theme.text.caption.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: .circular(4),
              child: SizedBox(
                height: 5,
                child: ColoredBox(
                  color: theme.colors.outline.withValues(alpha: .4),
                  child: Align(
                    alignment: .centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: game.filled / 81,
                      child: ColoredBox(
                        color: theme.colors.accent,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.progress(game.filled),
              style: theme.text.caption.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class const _DifficultyButton({
  required final Difficulty difficulty,
  required final VoidCallback onPressed,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return RudiPressable(
      key: ValueKey('start-${difficulty.name}'),
      onPressed: onPressed,
      builder: (context, state) => AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : theme.motion.fast,
        padding: const .symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: state.pressed || state.hovered
              ? theme.colors.surfaceContainer
              : theme.colors.surface,
          borderRadius: .circular(18),
          border: state.focused
              ? Border.all(color: theme.colors.accent, width: 2)
              : null,
        ),
        child: Column(
          mainAxisSize: .min,
          children: [
            Row(
              mainAxisSize: .min,
              crossAxisAlignment: .end,
              children: [
                for (var bar = 0; bar < 3; bar++)
                  Container(
                    width: 5,
                    height: 8.0 + bar * 5,
                    margin: const .symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: .circular(2),
                      color: bar <= difficulty.index
                          ? theme.colors.accent
                          : theme.colors.outline,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(difficultyLabel(context, difficulty), style: theme.text.label),
          ],
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
