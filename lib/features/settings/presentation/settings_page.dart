import 'package:flutter/material.dart' show Icons;

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../../app/sudoku_controller.dart';
import '../../../common/presentation/app_sheet.dart';
import '../../../common/presentation/ui.dart';
import '../../game/presentation/board_palette.dart';
import '../domain/app_settings.dart';
import 'settings_information.dart';

String boardThemeLabel(BuildContext context, BoardTheme theme) =>
    switch (theme) {
      BoardTheme.classic => context.l10n.boardClassic,
      BoardTheme.paper => context.l10n.boardPaper,
      BoardTheme.mist => context.l10n.boardMist,
      BoardTheme.midnight => context.l10n.boardMidnight,
    };
String appearanceLabel(BuildContext context, AppAppearance value) =>
    switch (value) {
      AppAppearance.system => context.l10n.system,
      AppAppearance.light => context.l10n.light,
      AppAppearance.dark => context.l10n.dark,
    };
String errorLabel(BuildContext context, ErrorCheck value) => switch (value) {
  ErrorCheck.off => context.l10n.checkOff,
  ErrorCheck.conflicts => context.l10n.checkConflicts,
  ErrorCheck.solution => context.l10n.checkSolution,
};

Future<T?> _choose<T>(
  BuildContext context, {
  required String title,
  required T selected,
  required List<(T, String, Widget?)> options,
  String? description,
  String Function(T)? subtitle,
}) => showAppSheet<T>(
  context: context,
  title: title,
  showCloseButton: true,
  builder: (sheetContext) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (description != null) ...[
        Text(
          description,
          style: context.rudiTheme.text.body.copyWith(
            color: context.rudiTheme.colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 20),
      ],
      RudiSettingsGroup(
        children: [
          for (final option in options)
            RudiSettingsTile(
              title: option.$2,
              leading: option.$3,
              subtitle: subtitle?.call(option.$1),
              selected: option.$1 == selected,
              trailing: option.$1 == selected
                  ? const Icon(SolarIconsBold.checkCircle, size: 24)
                  : const SizedBox(width: 24),
              onPressed: () => Navigator.of(sheetContext).pop(option.$1),
            ),
        ],
      ),
    ],
  ),
);

Future<void> chooseBoardTheme(
  BuildContext context,
  SudokuController controller,
) async {
  final value = await _choose(
    context,
    title: context.l10n.boardTheme,
    selected: controller.settings.boardTheme,
    description: context.l10n.boardThemeDescription,
    options: [
      for (final theme in BoardTheme.values)
        (
          theme,
          boardThemeLabel(context, theme),
          BoardThemePreview(theme: theme),
        ),
    ],
  );
  if (value != null) {
    controller.changeSettings(controller.settings.copyWith(boardTheme: value));
  }
}

final class const SettingsPage({
  required final SudokuController controller,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ContentPage(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeading(context.l10n.settings),
        SettingsContent(controller: controller),
        const SizedBox(height: 28),
        const SettingsInformation(),
      ],
    ),
  );
}

final class const SettingsContent({
  required final SudokuController controller,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n, settings = controller.settings;
    final gameSettings = RudiSettingsGroup(
      key: const ValueKey('settings-gameplay'),
      title: l.gameSettings,
      children: [
        RudiSwitchTile(
          title: l.showTimer,
          leading: const Icon(SolarIconsOutline.stopwatch, size: 24),
          value: settings.showTimer,
          onChanged: (value) => controller.changeSettings(
            controller.settings.copyWith(showTimer: value),
          ),
        ),
        RudiSwitchTile(
          title: l.cleanNotes,
          leading: const Icon(SolarIconsOutline.pen2, size: 24),
          value: settings.cleanNotes,
          onChanged: (value) => controller.changeSettings(
            controller.settings.copyWith(cleanNotes: value),
          ),
        ),
        RudiSwitchTile(
          title: l.numberFirst,
          leading: const Icon(SolarIconsOutline.widget_5, size: 24),
          value: settings.numberFirst,
          onChanged: (value) => controller.changeSettings(
            controller.settings.copyWith(numberFirst: value),
          ),
        ),
        RudiSwitchTile(
          title: l.haptics,
          leading: const Icon(SolarIconsOutline.smartphoneVibration, size: 24),
          value: settings.haptics,
          onChanged: (value) => controller.changeSettings(
            controller.settings.copyWith(haptics: value),
          ),
        ),
      ],
    );
    final customization = RudiSettingsGroup(
      key: const ValueKey('settings-customization'),
      title: l.customization,
      children: [
        RudiSettingsTile(
          key: const ValueKey('setting-language'),
          title: l.language,
          leading: const Icon(Icons.language, size: 24),
          trailing: _SettingValue(
            switch (settings.language) {
              AppLanguage.system => l.system,
              AppLanguage.en => l.languageEnglish,
              AppLanguage.de => l.languageGerman,
            },
            leading: settings.language == AppLanguage.system
                ? null
                : _LanguageFlag(settings.language),
          ),
          onPressed: () async {
            final value = await _choose(
              context,
              title: l.language,
              selected: settings.language,
              options: [
                (
                  AppLanguage.system,
                  l.systemLanguage,
                  const Icon(Icons.language, size: 24),
                ),
                (
                  AppLanguage.en,
                  l.languageEnglish,
                  const _LanguageFlag(AppLanguage.en),
                ),
                (
                  AppLanguage.de,
                  l.languageGerman,
                  const _LanguageFlag(AppLanguage.de),
                ),
              ],
            );
            if (value != null) {
              controller.changeSettings(
                controller.settings.copyWith(language: value),
              );
            }
          },
        ),
        RudiSettingsTile(
          key: const ValueKey('setting-appearance'),
          title: l.appearance,
          leading: const Icon(SolarIconsOutline.moon, size: 24),
          trailing: _SettingValue(
            appearanceLabel(context, settings.appearance),
          ),
          onPressed: () async {
            final value = await _choose(
              context,
              title: l.appearance,
              selected: settings.appearance,
              subtitle: (mode) => switch (mode) {
                AppAppearance.system => l.systemThemeDescription,
                AppAppearance.light => l.lightThemeDescription,
                AppAppearance.dark => l.darkThemeDescription,
              },
              options: [
                for (final mode in AppAppearance.values)
                  (
                    mode,
                    appearanceLabel(context, mode),
                    Icon(switch (mode) {
                      AppAppearance.system => SolarIconsOutline.smartphone,
                      AppAppearance.light => SolarIconsOutline.sun,
                      AppAppearance.dark => SolarIconsOutline.moon,
                    }, size: 24),
                  ),
              ],
            );
            if (value != null) {
              controller.changeSettings(
                controller.settings.copyWith(appearance: value),
              );
            }
          },
        ),
        RudiSettingsTile(
          key: const ValueKey('setting-board'),
          title: l.boardTheme,
          leading: const Icon(SolarIconsOutline.paletteRound, size: 24),
          trailing: _SettingValue(
            boardThemeLabel(context, settings.boardTheme),
          ),
          onPressed: () => unawaited(chooseBoardTheme(context, controller)),
        ),
        RudiSettingsTile(
          key: const ValueKey('setting-errors'),
          title: l.errorCheck,
          leading: const Icon(SolarIconsOutline.checkCircle, size: 24),
          trailing: _SettingValue(errorLabel(context, settings.errorCheck)),
          onPressed: () async {
            final value = await _choose(
              context,
              title: l.errorCheck,
              description: l.errorDescription,
              selected: settings.errorCheck,
              options: [
                for (final mode in ErrorCheck.values)
                  (mode, errorLabel(context, mode), null),
              ],
            );
            if (value != null) {
              controller.changeSettings(
                controller.settings.copyWith(errorCheck: value),
              );
            }
          },
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 720) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: gameSettings),
              const SizedBox(width: 28),
              Expanded(child: customization),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [gameSettings, const SizedBox(height: 28), customization],
        );
      },
    );
  }
}

final class const _SettingValue(final String value, {final Widget? leading})
    extends StatelessWidget {
  static const _maximumWidth = 170.0;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maximumWidth),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 6)],
        Flexible(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: context.rudiTheme.text.body.copyWith(
              color: context.rudiTheme.colors.mutedForeground,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          SolarIconsOutline.altArrowRight,
          size: 18,
          color: context.rudiTheme.colors.mutedForeground,
        ),
      ],
    ),
  );
}

final class const BoardThemePreview({
  required final BoardTheme theme,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = BoardPalette.resolve(theme, context.rudiTheme.brightness);
    return SizedBox.square(
      dimension: 52,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: ColoredBox(
          color: palette.background,
          child: CustomPaint(
            foregroundPainter: SudokuGridPainter(
              palette: palette,
              pixelRatio: MediaQuery.devicePixelRatioOf(context),
            ),
            child: Center(
              child: Container(width: 17, height: 17, color: palette.selected),
            ),
          ),
        ),
      ),
    );
  }
}

final class const _LanguageFlag(final AppLanguage language)
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: 26,
      child: Text(
        switch (language) {
          AppLanguage.en => '🇬🇧',
          AppLanguage.de => '🇩🇪',
          AppLanguage.system => '',
        },
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, height: 1),
      ),
    ),
  );
}
