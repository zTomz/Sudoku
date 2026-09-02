import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../features/settings/domain/app_settings.dart';
import '../l10n/generated/app_localizations.dart';
import 'app_router.dart';
import 'app_theme.dart';
import 'sudoku_controller.dart';

final class const SudokuApp({
  final Locale? locale,
  final String? initialLocation,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<SudokuApp> createState() => _SudokuAppState();
}

final class _SudokuAppState()
    extends ConsumerState<SudokuApp>
    with WidgetsBindingObserver {
  AppSettings? _lastSettings;
  late RudiThemeData _light;
  late RudiThemeData _dark;
  late final _router = createSudokuRouter(
    initialLocation: widget.initialLocation,
  );
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
    _router.dispose();
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
    return RudiApp.router(
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
      routerConfig: _router,
    );
  }
}
