import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../features/game/domain/puzzle.dart';
import '../../l10n/generated/app_localizations.dart';

extension SudokuContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

String difficultyLabel(BuildContext context, Difficulty value) =>
    switch (value) {
      Difficulty.easy => context.l10n.easy,
      Difficulty.medium => context.l10n.medium,
      Difficulty.hard => context.l10n.hard,
    };
String durationLabel(int seconds) {
  final minutes = seconds ~/ 60;
  return '${minutes.toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
}

final class const PageHeading(
  final String title, {
  final String? subtitle,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.rudiTheme.text.display),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          Text(
            subtitle!,
            style: context.rudiTheme.text.body.copyWith(
              color: context.rudiTheme.colors.mutedForeground,
            ),
          ),
        ],
      ],
    ),
  );
}

final class const ContentPage({required final Widget child, super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => RudiPage(
    padding: EdgeInsets.zero,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: ListView(
          padding: EdgeInsets.all(
            MediaQuery.sizeOf(context).width < 600 ? 16 : 40,
          ),
          children: [child],
        ),
      ),
    ),
  );
}

enum AppSymbol() {
  grid,
  calendar,
  calendarSimple,
  chart,
  settings,
  pencil,
  undo,
  redo,
  erase,
  pause,
  palette,
  timer,
  haptics,
  sun,
  moon,
  play,
  check,
  chevron,
  info,
  close
}

final class const AppIcon(
  final AppSymbol symbol, {
  final double size = 24,
  final Color? color,
  final bool filled = false,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Icon(
    switch (symbol) {
      AppSymbol.grid =>
        filled ? SolarIconsBold.widget_5 : SolarIconsOutline.widget_5,
      AppSymbol.calendar =>
        filled ? SolarIconsBold.calendarDate : SolarIconsOutline.calendarDate,
      AppSymbol.calendarSimple =>
        filled ? SolarIconsBold.calendar : SolarIconsOutline.calendar,
      AppSymbol.chart =>
        filled ? SolarIconsBold.chart : SolarIconsOutline.chart,
      AppSymbol.settings =>
        filled ? SolarIconsBold.settings : SolarIconsOutline.settings,
      AppSymbol.pencil => SolarIconsOutline.pen2,
      AppSymbol.undo => SolarIconsOutline.undoLeftRound,
      AppSymbol.redo => SolarIconsOutline.undoRightRound,
      AppSymbol.erase => SolarIconsOutline.eraser,
      AppSymbol.pause =>
        filled ? SolarIconsBold.pause : SolarIconsOutline.pause,
      AppSymbol.palette => SolarIconsOutline.paletteRound,
      AppSymbol.timer => SolarIconsOutline.stopwatch,
      AppSymbol.haptics => SolarIconsOutline.smartphoneVibration,
      AppSymbol.sun => SolarIconsOutline.sun,
      AppSymbol.moon => SolarIconsOutline.moon,
      AppSymbol.play => SolarIconsBold.play,
      AppSymbol.check => SolarIconsOutline.checkCircle,
      AppSymbol.chevron => SolarIconsOutline.altArrowRight,
      AppSymbol.info => SolarIconsOutline.infoCircle,
      AppSymbol.close => SolarIconsOutline.closeCircle,
    },
    size: size,
    color:
        color ??
        IconTheme.of(context).color ??
        context.rudiTheme.colors.foreground,
  );
}
