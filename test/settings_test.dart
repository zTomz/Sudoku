import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rudi_ui/rudi_ui.dart';
import 'package:sudoku/app/sudoku_app.dart';
import 'package:sudoku/features/game/data/game_repository.dart';
import 'package:sudoku/features/settings/domain/app_settings.dart';

import 'controller_harness.dart';
import 'storage_controller_test.dart' show MemoryStore;

void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Sudoku',
      packageName: 'com.tomvogel.sudoku',
      version: '1.2.3',
      buildNumber: '42',
      buildSignature: '',
    );
  });

  test('language survives saves and missing language follows system', () {
    for (final language in AppLanguage.values) {
      final save = SavedGames(settings: AppSettings(language: language));
      expect(SavedGames.decode(save.encode()).settings.language, language);
    }
    final json = const AppSettings().toJson()..remove('language');
    expect(AppSettings.fromJson(json).language, AppLanguage.system);
    expect(
      () => AppSettings.fromJson({...json, 'language': 'fr'}),
      throwsArgumentError,
    );
    expect(
      () => AppSettings.fromJson({...json, 'language': null}),
      throwsA(isA<TypeError>()),
    );
  });

  test('endgame auto-fill survives saves and defaults on for older saves', () {
    final save = SavedGames(settings: const AppSettings(autoFillEnding: false));
    expect(SavedGames.decode(save.encode()).settings.autoFillEnding, isFalse);

    final json = const AppSettings().toJson()..remove('autoFillEnding');
    expect(AppSettings.fromJson(json).autoFillEnding, isTrue);
  });

  testWidgets('language changes immediately and is persisted', (tester) async {
    final store = MemoryStore();
    final harness = ControllerHarness(GameRepository(store));
    addTearDown(harness.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: harness.container,
        child: const SudokuApp(initialLocation: '/settings'),
      ),
    );
    await tester.pumpAndSettle();
    final languageTile = find.byKey(const ValueKey('setting-language'));
    await tester.ensureVisible(languageTile);
    await tester.tap(languageTile);
    await tester.pumpAndSettle();
    expect(find.text('System language'), findsOneWidget);
    expect(find.text('🇬🇧'), findsOneWidget);
    expect(find.text('🇩🇪'), findsOneWidget);
    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();
    expect(find.text('Sprache'), findsOneWidget);
    expect(harness.controller.settings.language, AppLanguage.de);
    expect(SavedGames.decode(store.value!).settings.language, AppLanguage.de);
    await tester.tap(languageTile);
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('theme picker descriptions and system appearance', (
    tester,
  ) async {
    final harness = ControllerHarness(GameRepository(MemoryStore()));
    addTearDown(harness.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: harness.container,
        child: const SudokuApp(
          locale: Locale('en'),
          initialLocation: '/settings',
        ),
      ),
    );
    await tester.pumpAndSettle();
    final tile = find.byKey(const ValueKey('setting-appearance'));
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(find.text('Follow your device appearance'), findsOneWidget);
    expect(find.text('Always use the light theme'), findsOneWidget);
    expect(find.text('Always use the dark theme'), findsOneWidget);
    expect(find.byType(RudiIconButton), findsWidgets);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(harness.controller.settings.appearance, AppAppearance.dark);
    await tester.tap(tile);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Follow your device appearance'));
    await tester.pumpAndSettle();
    expect(harness.controller.settings.appearance, AppAppearance.system);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'settings show actual version, offline licenses and link fallback',
    (tester) async {
      final harness = ControllerHarness(GameRepository(MemoryStore()));
      addTearDown(harness.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: harness.container,
          child: const SudokuApp(
            locale: Locale('en'),
            initialLocation: '/settings',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Version 1.2.3 (42)'), findsOneWidget);
      expect(find.text('About Sudoku'), findsNothing);
      final licenses = find.byKey(const ValueKey('setting-licenses'));
      await tester.ensureVisible(licenses);
      await tester.pumpAndSettle();
      await tester.tap(licenses);
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sudoku').last);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Permission is hereby granted'),
        findsOneWidget,
      );
      Navigator.of(
        tester.element(find.textContaining('Permission is hereby granted')),
      ).pop();
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.text('Sudoku').last)).pop();
      await tester.pumpAndSettle();
      const channel = MethodChannel('plugins.flutter.io/url_launcher');
      String? launched;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        launched = (call.arguments as Map)['url'] as String;
        return false;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      final repository = find.byKey(const ValueKey('setting-repository'));
      await tester.ensureVisible(repository);
      await tester.pumpAndSettle();
      await tester.tap(repository);
      await tester.pumpAndSettle();
      expect(launched, 'https://github.com/zTomz/Sudoku');
      expect(find.text('https://github.com/zTomz/Sudoku'), findsOneWidget);
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.tap(find.text('Copy link'));
      await tester.pumpAndSettle();
      expect(copied, 'https://github.com/zTomz/Sudoku');
      Navigator.of(tester.element(find.text('Copy link'))).pop();
      await tester.pumpAndSettle();
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        launched = (call.arguments as Map)['url'] as String;
        expect((call.arguments as Map)['useWebView'], isFalse);
        return true;
      });
      final report = find.byKey(const ValueKey('setting-report-bug'));
      await tester.ensureVisible(report);
      await tester.pumpAndSettle();
      await tester.tap(report);
      await tester.pumpAndSettle();
      expect(launched, 'https://github.com/zTomz/Sudoku/issues/new');
      expect(find.text('Copy link'), findsNothing);
      final feature = find.byKey(const ValueKey('setting-feature-request'));
      await tester.ensureVisible(feature);
      await tester.pumpAndSettle();
      await tester.tap(feature);
      await tester.pumpAndSettle();
      expect(Uri.parse(launched!).path, '/zTomz/Sudoku/issues/new');
      expect(
        Uri.parse(launched!).queryParameters['title'],
        '[Feature request] ',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
