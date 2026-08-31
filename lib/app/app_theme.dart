import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../features/settings/domain/app_settings.dart';
import '../common/presentation/app_colors.dart';

RudiThemeData sudokuTheme(Brightness brightness, AppSettings settings) {
  final dark = brightness == Brightness.dark;
  final base = dark
      ? RudiThemeData.dark(accent: sudokuAccent(brightness))
      : RudiThemeData.light(accent: sudokuAccent(brightness));
  final colors = base.colors.copyWith(
    background: dark ? const Color(0xff141518) : const Color(0xfffafaf9),
    foreground: dark ? const Color(0xfff5f5f7) : const Color(0xff16171b),
    mutedForeground: dark ? const Color(0xffb3b8c2) : const Color(0xff646a76),
    surface: dark ? const Color(0xff26272d) : const Color(0xffeeedef),
    surfaceContainer: dark ? const Color(0xff202126) : const Color(0xfff2f2f4),
    primary: base.colors.accent,
    onPrimary: dark ? const Color(0xff0d2441) : const Color(0xffffffff),
    outline: dark ? const Color(0xff555965) : const Color(0xffc7ced9),
  );
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
