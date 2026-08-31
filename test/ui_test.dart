import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rudi_ui/rudi_ui.dart';
import 'package:sudoku/app/app_theme.dart';
import 'package:sudoku/app/sudoku_app.dart';
import 'package:sudoku/app/sudoku_controller.dart';
import 'package:sudoku/features/game/data/game_repository.dart';
import 'package:sudoku/features/game/domain/game_session.dart';
import 'package:sudoku/features/game/domain/puzzle.dart';
import 'package:sudoku/features/game/domain/sudoku_engine.dart';
import 'package:sudoku/features/game/presentation/board_palette.dart';
import 'package:sudoku/features/game/presentation/game_page.dart';
import 'package:sudoku/features/settings/domain/app_settings.dart';
import 'package:sudoku/l10n/generated/app_localizations.dart';

import 'storage_controller_test.dart' show MemoryStore;

void main() {
  late Puzzle puzzle;
  setUpAll(() async {
    await initializeDateFormatting();
    puzzle = await SudokuEngine().generate(
      seed: 991,
      difficulty: Difficulty.medium,
    );
  });
  for (final size in [
    const Size(390, 844),
    const Size(320, 568),
    const Size(844, 390),
    const Size(1200, 900),
  ]) {
    testWidgets('game anchors header and controls at $size', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final store = MemoryStore()
        ..value = SavedGames(free: GameSession.start(puzzle)).encode();
      final controller = SudokuController(GameRepository(store));
      await controller.initialize();
      controller.resumeFree();
      addTearDown(controller.dispose);
      await tester.pumpWidget(_GameHarness(controller: controller));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('game-header'))).dy,
        0,
      );
      expect(
        tester.getBottomLeft(find.byKey(const ValueKey('game-toolbar'))).dy,
        size.height,
      );
      expect(find.byKey(const ValueKey('number-9')), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('cell-0')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final boardRect = tester.getRect(
        find.byKey(const ValueKey('board-grid')),
      );
      controller.togglePause();
      await tester.pumpAndSettle();
      expect(find.text('Pause'), findsOneWidget);
      expect(find.byKey(const ValueKey('pause-dialog')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(GamePage),
          matching: find.byType(ModalBarrier),
        ),
        findsOneWidget,
      );
      expect(
        tester.getRect(find.byKey(const ValueKey('board-grid'))),
        boardRect,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('board-grid')),
          matching: find.byType(Text),
        ),
        findsNothing,
      );
      final pausedValues = controller.game!.values.toList();
      controller.chooseDigit(9);
      expect(controller.game!.values, pausedValues);
      await tester.tap(find.text('Fortsetzen'));
      await tester.pumpAndSettle();
      expect(controller.paused, false);
      expect(find.byKey(const ValueKey('pause-dialog')), findsNothing);
      expect(tester.takeException(), isNull);
      controller.suspend();
    });
  }
  testWidgets('home, rapid navigation, grouped settings and theme selection', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final controller = SudokuController(GameRepository(MemoryStore()));
    await tester.pumpWidget(
      SudokuApp(controller: controller, locale: const Locale('de')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('new-game')), findsOneWidget);
    expect(tester.takeException(), isNull);
    for (final index in [1, 2, 0, 3]) {
      await tester.tap(find.byKey(ValueKey('nav-$index')));
      await tester.pump(const Duration(milliseconds: 60));
    }
    await tester.pumpAndSettle();
    final setting = find.byKey(const ValueKey('setting-board'));
    await tester.ensureVisible(setting);
    await tester.tap(setting);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nacht'));
    await tester.pumpAndSettle();
    expect(controller.settings.boardTheme, BoardTheme.midnight);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'lifecycle pause is modal and system back resumes the same game',
    (tester) async {
      final controller = SudokuController(
        GameRepository(
          MemoryStore()
            ..value = SavedGames(free: GameSession.start(puzzle)).encode(),
        ),
      );
      await controller.initialize();
      controller.resumeFree();
      addTearDown(controller.dispose);
      await tester.pumpWidget(_GameHarness(controller: controller));
      await tester.pumpAndSettle();
      final cell = puzzle.givens.indexOf(0);
      controller.selectCell(cell);
      controller.suspend();
      await tester.pumpAndSettle();
      final elapsed = controller.game!.elapsedSeconds;
      await tester.sendKeyEvent(LogicalKeyboardKey.digit9);
      await tester.pump(const Duration(seconds: 2));
      expect(controller.game!.values[cell], 0);
      expect(controller.game!.elapsedSeconds, elapsed);
      expect(find.byKey(const ValueKey('pause-dialog')), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(controller.playing, true);
      expect(controller.paused, false);
      expect(controller.game!.puzzle.id, puzzle.id);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit9);
      expect(controller.game!.values[cell], 9);
      controller.suspend();
    },
  );

  testWidgets('large text keeps game controls reachable', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.reset);
    final store = MemoryStore()
      ..value = SavedGames(free: GameSession.start(puzzle)).encode();
    final controller = SudokuController(GameRepository(store));
    await controller.initialize();
    controller.resumeFree();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_GameHarness(controller: controller, textScale: 2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      tester.getBottomLeft(find.byKey(const ValueKey('game-toolbar'))).dy,
      568,
    );
    await tester.tap(find.byKey(const ValueKey('number-9')));
    controller.suspend();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'direct difficulty selection preserves an unfinished game on cancel',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final cell = puzzle.givens.indexOf(0);
      final session = GameSession.start(puzzle)
          .enter(cell, puzzle.solution[cell]);
      final controller = SudokuController(
        GameRepository(
          MemoryStore()..value = SavedGames(free: session).encode(),
        ),
      );
      await tester.pumpWidget(
        SudokuApp(controller: controller, locale: const Locale('de')),
      );
      await tester.pumpAndSettle();
      final choice = find.byKey(const ValueKey('start-hard'));
      await tester.scrollUntilVisible(
        choice,
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(choice);
      await tester.pumpAndSettle();
      expect(find.text('Neues Rätsel starten?'), findsOneWidget);
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();
      expect(controller.free!.puzzle.id, puzzle.id);
      expect(controller.free!.values[cell], puzzle.solution[cell]);
      expect(controller.playing, false);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  test('selection and board numbers share the app accent', () {
    for (final brightness in Brightness.values) {
      final accent = sudokuTheme(brightness, const AppSettings()).colors.accent;
      for (final board in BoardTheme.values) {
        final palette = BoardPalette.resolve(
          board,
          brightness,
          accentColor: accent,
        );
        expect(palette.accent, accent);
        expect(palette.selected, accent);
        final a = palette.selected.computeLuminance(),
            b = palette.onSelected.computeLuminance();
        final contrast = a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05);
        expect(contrast, greaterThanOrEqualTo(4.5));
      }
    }
  });

  for (final viewport in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(1200, 900),
  ]) {
    testWidgets(
      'numeral text layout stays centered inside each cell at $viewport',
      (tester) async {
        final loader = FontLoader('GoogleSans')
          ..addFont(rootBundle.load('assets/fonts/GoogleSans.ttf'));
        await loader.load();
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = viewport;
        addTearDown(tester.view.reset);
        var sample = GameSession.start(puzzle);
        for (final cell in [
          for (var c = 0; c < 81; c++)
            if (puzzle.givens[c] == 0) c,
        ].take(9)) {
          sample = sample.enter(cell, puzzle.solution[cell]);
        }
        final controller = SudokuController(
          GameRepository(
            MemoryStore()..value = SavedGames(free: sample).encode(),
          ),
        );
        await controller.initialize();
        controller.resumeFree();
        addTearDown(controller.dispose);
        await tester.pumpWidget(_GameHarness(controller: controller));
        await tester.pumpAndSettle();
        for (var cell = 0; cell < 81; cell++) {
          if (sample.values[cell] == 0) continue;
          final cellFinder = find.byKey(ValueKey('cell-$cell'));
          final digitFinder = find.descendant(
            of: cellFinder,
            matching: find.text('${sample.values[cell]}'),
          );
          expect(digitFinder, findsOneWidget);
          final cellRect = tester.getRect(cellFinder);
          final textRect = tester.getRect(digitFinder);
          expect(
            textRect.center.dx,
            moreOrLessEquals(cellRect.center.dx),
            reason: 'horizontal alignment of cell $cell',
          );
          expect(
            textRect.center.dy,
            moreOrLessEquals(cellRect.center.dy),
            reason: 'vertical alignment of cell $cell',
          );
          expect(cellRect.contains(textRect.topLeft), isTrue);
          expect(cellRect.contains(textRect.bottomRight), isTrue);
        }
        controller.suspend();
      },
    );
  }

  test('old settings migrate and each board theme survives save/load', () {
    final old = const AppSettings().toJson()..remove('boardTheme');
    expect(AppSettings.fromJson(old).boardTheme, BoardTheme.classic);
    for (final theme in BoardTheme.values) {
      final save = SavedGames(settings: AppSettings(boardTheme: theme));
      expect(SavedGames.decode(save.encode()).settings.boardTheme, theme);
    }
  });
  test(
    'grid boundaries remain identical for every selection and palette',
    () async {
      for (final theme in BoardTheme.values) {
        final palette = BoardPalette.resolve(theme, Brightness.light);
        Future<List<int>> boundaryPixels(int selected) async {
          final recorder = ui.PictureRecorder();
          final canvas = Canvas(recorder);
          canvas.drawColor(palette.selected, BlendMode.src);
          SudokuGridPainter(
            palette: palette,
            pixelRatio: 1,
            selected: selected,
          ).paint(canvas, const Size(360, 360));
          final picture = recorder.endRecording();
          final image = await picture.toImage(360, 360);
          final bytes = (await image.toByteData())!.buffer.asUint8List();
          final result = <int>[
            for (final line in [0, 120, 240, 359])
              for (var p = 0; p < 360; p++) ...[
                for (var c = 0; c < 4; c++) bytes[(p * 360 + line) * 4 + c],
                for (var c = 0; c < 4; c++) bytes[(line * 360 + p) * 4 + c],
              ],
          ];
          image.dispose();
          picture.dispose();
          return result;
        }

        final reference = await boundaryPixels(-1);
        for (final selected in [0, 2, 3, 20, 30, 40, 60, 80]) {
          expect(
            await boundaryPixels(selected),
            reference,
            reason: '$theme / $selected',
          );
        }
      }
    },
  );
}

final class const _GameHarness({
  required final SudokuController controller,
  final double textScale = 1,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => RudiApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    locale: const Locale('de'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    theme: sudokuTheme(Brightness.light, controller.settings),
    home: ListenableBuilder(
      listenable: controller,
      builder: (context, _) => RepaintBoundary(
        key: const ValueKey('game-render'),
        child: GamePage(controller: controller),
      ),
    ),
  );
}
