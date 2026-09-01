import '../common/presentation/destination_transition.dart';

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../common/presentation/ui.dart';
import '../common/presentation/app_navigation.dart';
import '../features/daily/presentation/daily_page.dart';
import '../features/game/presentation/game_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/settings/domain/app_settings.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/statistics/presentation/statistics_page.dart';
import '../l10n/generated/app_localizations.dart';
import 'app_theme.dart';
import 'sudoku_controller.dart';

final class const SudokuApp({final Locale? locale, super.key})
    extends ConsumerStatefulWidget {
  @override
  ConsumerState<SudokuApp> createState() => _SudokuAppState();
}

final class _SudokuAppState()
    extends ConsumerState<SudokuApp>
    with WidgetsBindingObserver {
  AppSettings? _lastSettings;
  late RudiThemeData _light;
  late RudiThemeData _dark;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() {
      if (mounted) {
        unawaited(ref.read(sudokuControllerProvider.notifier).initialize());
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      ref.read(sudokuControllerProvider.notifier).suspend();
    } else {
      ref.read(sudokuControllerProvider.notifier).activate();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(
      sudokuControllerProvider.select((s) => s.saved.settings),
    );
    if (_lastSettings != settings) {
      _lastSettings = settings;
      _light = sudokuTheme(Brightness.light, settings);
      _dark = sudokuTheme(Brightness.dark, settings);
    }
    return RudiApp(
      title: 'Sudoku',
      theme: _light,
      darkTheme: _dark,
      locale: widget.locale,
      themeMode: switch (settings.appearance) {
        AppAppearance.system => RudiThemeMode.system,
        AppAppearance.light => RudiThemeMode.light,
        AppAppearance.dark => RudiThemeMode.dark,
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const _AppShell(),
    );
  }
}

final class const _AppShell() extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

final class _AppShellState() extends ConsumerState<_AppShell> {
  int _destination = 0;
  @override
  Widget build(BuildContext context) {
    ref.watch(sudokuControllerProvider);
    final c = ref.read(sudokuControllerProvider.notifier), l = context.l10n;
    if (!c.ready || c.busy) {
      return RudiPage(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppIcon(AppSymbol.grid, size: 48),
                const SizedBox(height: 24),
                Text(
                  c.loadFailed ? l.loadFailed : l.loading,
                  textAlign: TextAlign.center,
                ),
                if (c.loadFailed) ...[
                  const SizedBox(height: 24),
                  RudiButton(
                    label: l.retry,
                    onPressed: () => unawaited(c.initialize()),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
    Widget content = c.playing
        ? GamePage(controller: c)
        : _HomeShell(
            selectedIndex: _destination,
            onDestinationSelected: (value) =>
                setState(() => _destination = value),
            body: DestinationTransition(
              value: _destination,
              child: IndexedStack(
                index: _destination,
                children: [
                  HomePage(controller: c),
                  DailyPage(controller: c),
                  StatisticsPage(controller: c),
                  SettingsPage(controller: c),
                ],
              ),
            ),
          );
    if (c.saveFailed || c.generationFailed) {
      content = Column(
        children: [
          ColoredBox(
            color: context.rudiTheme.colors.surfaceContainer,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.saveFailed ? l.saveFailed : l.generationFailed,
                      ),
                    ),
                    if (c.saveFailed)
                      RudiButton(
                        label: l.retry,
                        onPressed: () => unawaited(c.persist()),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: content),
        ],
      );
    }
    return ColoredBox(
      color: context.rudiTheme.colors.background,
      child: content,
    );
  }
}

final class const _HomeShell({
  required final int selectedIndex,
  required final ValueChanged<int> onDestinationSelected,
  required final Widget body,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => RudiPage(
    padding: EdgeInsets.zero,
    navigation: AppNavigation(
      selectedIndex: selectedIndex,
      onSelected: onDestinationSelected,
    ),
    child: body,
  );
}
