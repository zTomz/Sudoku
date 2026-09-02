import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../app/sudoku_controller.dart';
import '../../../common/presentation/app_sheet.dart';
import '../../../common/presentation/ui.dart';
import '../../game/presentation/board_palette.dart';
import '../../privacy/presentation/privacy_policy_page.dart';
import '../domain/app_settings.dart';

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
}) => showAppSheet<T>(
  context: context,
  title: title,
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
              selected: option.$1 == selected,
              trailing: option.$1 == selected
                  ? const AppIcon(AppSymbol.check)
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
        RudiSettingsGroup(
          title: context.l10n.legal,
          children: [
            RudiSettingsTile(
              key: const ValueKey('setting-privacy-policy'),
              title: context.l10n.privacyPolicy,
              leading: const AppIcon(AppSymbol.shield),
              trailing: const AppIcon(AppSymbol.chevron),
              onPressed: () =>
                  context.go(PrivacyPolicyPage.path, extra: '/settings'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        RudiSettingsTile(
          title: context.l10n.about,
          leading: const AppIcon(AppSymbol.info),
          trailing: const AppIcon(AppSymbol.chevron),
          onPressed: () => unawaited(
            showAppSheet<void>(
              context: context,
              title: context.l10n.about,
              builder: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.aboutDescription),
                  const SizedBox(height: 16),
                  Text(context.l10n.storageDescription),
                  const SizedBox(height: 16),
                  Text(context.l10n.difficultyNote),
                  const SizedBox(height: 16),
                  Text(context.l10n.licenseNote),
                  const SizedBox(height: 24),
                  Text(context.l10n.version),
                ],
              ),
            ),
          ),
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        RudiSettingsGroup(
          title: l.gameSettings,
          children: [
            RudiSwitchTile(
              title: l.showTimer,
              leading: const AppIcon(AppSymbol.timer),
              value: settings.showTimer,
              onChanged: (value) => controller.changeSettings(
                controller.settings.copyWith(showTimer: value),
              ),
            ),
            RudiSwitchTile(
              title: l.cleanNotes,
              leading: const AppIcon(AppSymbol.pencil),
              value: settings.cleanNotes,
              onChanged: (value) => controller.changeSettings(
                controller.settings.copyWith(cleanNotes: value),
              ),
            ),
            RudiSwitchTile(
              title: l.numberFirst,
              leading: const AppIcon(AppSymbol.grid),
              value: settings.numberFirst,
              onChanged: (value) => controller.changeSettings(
                controller.settings.copyWith(numberFirst: value),
              ),
            ),
            RudiSwitchTile(
              title: l.haptics,
              leading: const AppIcon(AppSymbol.haptics),
              value: settings.haptics,
              onChanged: (value) => controller.changeSettings(
                controller.settings.copyWith(haptics: value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        RudiSettingsGroup(
          title: l.customization,
          children: [
            RudiSettingsTile(
              key: const ValueKey('setting-appearance'),
              title: l.appearance,
              leading: const AppIcon(AppSymbol.moon),
              trailing: _SettingValue(
                appearanceLabel(context, settings.appearance),
              ),
              onPressed: () async {
                final value = await _choose(
                  context,
                  title: l.appearance,
                  selected: settings.appearance,
                  options: [
                    for (final mode in AppAppearance.values)
                      (
                        mode,
                        appearanceLabel(context, mode),
                        AppIcon(
                          mode == AppAppearance.light
                              ? AppSymbol.sun
                              : AppSymbol.moon,
                        ),
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
              leading: const AppIcon(AppSymbol.palette),
              trailing: _SettingValue(
                boardThemeLabel(context, settings.boardTheme),
              ),
              onPressed: () => unawaited(chooseBoardTheme(context, controller)),
            ),
            RudiSettingsTile(
              key: const ValueKey('setting-errors'),
              title: l.errorCheck,
              leading: const AppIcon(AppSymbol.check),
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
        ),
      ],
    );
  }
}

final class const _SettingValue(final String value) extends StatelessWidget {
  static const _maximumWidth = 170.0;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maximumWidth),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        AppIcon(
          AppSymbol.chevron,
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
