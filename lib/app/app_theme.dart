import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../features/settings/domain/app_settings.dart';
import '../common/presentation/app_colors.dart';

RudiThemeData sudokuTheme(Brightness brightness, AppSettings settings) {
  final dark = brightness == Brightness.dark;
  final base = dark
      ? RudiThemeData.dark(accent: sudokuAccent(brightness))
      : RudiThemeData.light(accent: sudokuAccent(brightness));
  final colors = base.colors;
  TextStyle font(TextStyle style) =>
      style.copyWith(fontFamily: 'GoogleSans', color: colors.foreground);
  return base.copyWith(
    colors: colors,
    motion: const RudiMotion(
      fast: Duration(milliseconds: 170),
      normal: Duration(milliseconds: 300),
      slow: Duration(milliseconds: 420),
      standardCurve: Curves.easeOutCubic,
      emphasizedCurve: Curves.easeOutQuart,
      spring: SpringDescription(mass: 1, stiffness: 440, damping: 42),
    ),
    feedback: RudiFeedbackPolicy(
      hapticsEnabled: settings.haptics,
      soundsEnabled: false,
    ),
    text: RudiTextTheme(
      display: font(base.text.display)
          .copyWith(fontSize: 42, letterSpacing: -1.6),
      headline: font(base.text.headline),
      title: font(base.text.title),
      body: font(base.text.body),
      label: font(base.text.label),
      caption: font(base.text.caption),
    ),
  );
}
