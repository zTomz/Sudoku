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
          padding: EdgeInsets.fromLTRB(
            MediaQuery.sizeOf(context).width < 600 ? 16 : 40,
            MediaQuery.sizeOf(context).width < 600 ? 16 : 40,
            MediaQuery.sizeOf(context).width < 600 ? 16 : 40,
            128,
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
  shield,
  language,
  code,
  bug,
  external,
  document,
  device,
  idea,
  close,
}

final class const AppIcon(
  final AppSymbol symbol, {
  final double size = 24,
  final Color? color,
  final bool filled = false,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => symbol == AppSymbol.language
      ? SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _LanguageIconPainter(
              color ??
                  IconTheme.of(context).color ??
                  context.rudiTheme.colors.foreground,
            ),
          ),
        )
      : Icon(
          switch (symbol) {
            AppSymbol.grid =>
              filled ? SolarIconsBold.widget_5 : SolarIconsOutline.widget_5,
            AppSymbol.calendar =>
              filled
                  ? SolarIconsBold.calendarDate
                  : SolarIconsOutline.calendarDate,
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
            AppSymbol.check =>
              filled
                  ? SolarIconsBold.checkCircle
                  : SolarIconsOutline.checkCircle,
            AppSymbol.chevron => SolarIconsOutline.altArrowRight,
            AppSymbol.info => SolarIconsOutline.infoCircle,
            AppSymbol.shield => SolarIconsOutline.shieldCheck,
            AppSymbol.language => SolarIconsOutline.translation,
            AppSymbol.code => SolarIconsOutline.code,
            AppSymbol.bug => SolarIconsOutline.bugMinimalistic,
            AppSymbol.external => SolarIconsOutline.arrowRightUp,
            AppSymbol.document => SolarIconsOutline.documentText,
            AppSymbol.device => SolarIconsOutline.smartphone,
            AppSymbol.idea => SolarIconsOutline.lightbulb,
            AppSymbol.close => SolarIconsOutline.closeCircle,
          },
          size: size,
          color:
              color ??
              IconTheme.of(context).color ??
              context.rudiTheme.colors.foreground,
        );
}

final class _LanguageIconPainter(final Color color) extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Rect.fromLTWH(
      size.width * .12,
      size.height * .12,
      size.width * .76,
      size.height * .76,
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .075
      ..isAntiAlias = true;
    canvas.drawOval(bounds, paint);
    canvas.drawOval(
      Rect.fromCenter(
        center: bounds.center,
        width: bounds.width * .42,
        height: bounds.height,
      ),
      paint,
    );
    canvas.drawLine(
      Offset(bounds.left, bounds.center.dy),
      Offset(bounds.right, bounds.center.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(_LanguageIconPainter oldDelegate) =>
      color != oldDelegate.color;
}
