import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controller_harness.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rudi_ui/rudi_ui.dart';
import 'package:sudoku/app/app_theme.dart';
import 'package:sudoku/app/hint_provider.dart';
import 'package:sudoku/app/sudoku_app.dart';
import 'package:sudoku/app/sudoku_controller.dart';
import 'package:sudoku/features/game/data/game_repository.dart';
import 'package:sudoku/features/game/domain/game_session.dart';
import 'package:sudoku/features/game/domain/logical_solver.dart';
import 'package:sudoku/features/game/domain/puzzle.dart';
import 'package:sudoku/features/game/domain/sudoku_engine.dart';
import 'package:sudoku/features/game/presentation/board_palette.dart';
import 'package:sudoku/features/game/presentation/game_page.dart';
import 'package:sudoku/features/game/presentation/hint_sheet.dart';
import 'package:sudoku/features/game/presentation/sudoku_board.dart';
import 'package:sudoku/features/settings/domain/app_settings.dart';
import 'package:sudoku/l10n/generated/app_localizations.dart';

import 'storage_controller_test.dart' show MemoryStore;

void main() {
  late Puzzle puzzle, hardPuzzle;
  setUpAll(() async {
    await initializeDateFormatting();
    puzzle = await SudokuEngine().generate(
      seed: 991,
      difficulty: Difficulty.medium,
    );
    hardPuzzle = await SudokuEngine().generate(
      seed: 4,
      difficulty: Difficulty.hard,
    );
  });
  test('completion flash targets a newly completed digit', () {
    final previous = List<int>.filled(81, 0);
    final current = [...previous];
    const sevens = [0, 12, 24, 28, 40, 52, 56, 68, 80];
    for (final cell in sevens.take(8)) {
      previous[cell] = 7;
      current[cell] = 7;
    }
    current[sevens.last] = 7;

    expect(completionFlashCells(previous, current), sevens.toSet());
  });

  test('completion flash targets a newly filled three-by-three box', () {
    final previous = List<int>.filled(81, 0);
    final current = [...previous];
    const boxCells = [0, 1, 2, 9, 10, 11, 18, 19, 20];
    for (var index = 0; index < boxCells.length - 1; index++) {
      previous[boxCells[index]] = index + 1;
      current[boxCells[index]] = index + 1;
    }
    current[boxCells.last] = 9;

    expect(completionFlashCells(previous, current), boxCells.toSet());
    expect(completionFlashCells(current, previous), isEmpty);
  });

  test('completion flash targets newly filled rows and columns', () {
    for (final unit in [
      [for (var cell = 0; cell < 9; cell++) cell],
      [for (var cell = 0; cell < 81; cell += 9) cell],
    ]) {
      final previous = List<int>.filled(81, 0);
      final current = [...previous];
      for (var index = 0; index < unit.length - 1; index++) {
        previous[unit[index]] = index + 1;
        current[unit[index]] = index + 1;
      }
      current[unit.last] = 9;

      expect(completionFlashCells(previous, current), unit.toSet());
    }
  });

  test('completion haptics follow each visual wavefront once', () {
    const origin = 40;
    final cells = {40, 31, 39, 41, 49, 22, 38, 42, 58};

    expect(completionHapticMoments(cells, origin), const [
      Duration(milliseconds: 500),
      Duration(milliseconds: 590),
      Duration(milliseconds: 680),
    ]);
    expect(completionHapticMoments(cells, -1), isEmpty);
  });

  for (final numberFirst in [false, true]) {
    testWidgets(
      'completed digit blocks taps, keyboard and pencil; undo/erase restore it (numberFirst: $numberFirst)',
      (tester) async {
        final missing = [
          for (var c = 0; c < 81; c++)
            if (puzzle.solution[c] == 3 && puzzle.givens[c] == 0) c,
        ];
        expect(missing, isNotEmpty);
        var session = GameSession.start(puzzle);
        for (final c in missing.take(missing.length - 1)) {
          session = session.enter(c, 3);
        }
        final harness = ControllerHarness(
          GameRepository(
            MemoryStore()
              ..value = SavedGames(
                free: session,
                settings: AppSettings(numberFirst: numberFirst),
              ).encode(),
          ),
        );
        addTearDown(harness.dispose);
        final controller = harness.controller;
        await controller.initialize();
        controller.resumeFree();
        controller.moveSelection(missing.last);
        await tester.pumpWidget(
          _GameHarness(controller: controller, container: harness.container),
        );
        await tester.pumpAndSettle();
        final number = find.byKey(const ValueKey('number-3'));
        await tester.tap(number);
        if (numberFirst) {
          await tester.tap(find.byKey(ValueKey('cell-${missing.last}')));
        }
        await tester.pumpAndSettle();
        expect(controller.game!.values.where((v) => v == 3).length, 9);
        expect(controller.selectedDigit, 0);
        expect(tester.widget<RudiPressable>(number).onPressed, isNull);
        expect(
          find.descendant(of: number, matching: find.byType(RudiGlyph)),
          findsOneWidget,
        );
        final empty = controller.game!.values.indexOf(0);
        controller.moveSelection(empty);
        await tester.tap(number);
        await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
        controller.enter(3);
        controller.togglePencil();
        await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
        controller.enter(3);
        expect(controller.game!.values[empty], 0);
        expect(controller.game!.notes[empty], 0);
        controller.togglePencil();
        controller.undo();
        await tester.pumpAndSettle();
        expect(tester.widget<RudiPressable>(number).onPressed, isNotNull);
        controller.redo();
        await tester.pumpAndSettle();
        expect(tester.widget<RudiPressable>(number).onPressed, isNull);
        controller.moveSelection(missing.last);
        controller.enter(0);
        await tester.pumpAndSettle();
        expect(tester.widget<RudiPressable>(number).onPressed, isNotNull);
        expect(
          find.descendant(of: number, matching: find.text('3')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        controller.suspend();
      },
    );
  }
  for (final language in ['de', 'en']) {
    testWidgets(
      'localized hints are read-only, responsive and hidden while paused ($language)',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final harness = ControllerHarness(
          GameRepository(
            MemoryStore()
              ..value = SavedGames(free: GameSession.start(puzzle)).encode(),
          ),
        );
        addTearDown(harness.dispose);
        final controller = harness.controller;
        await controller.initialize();
        controller.resumeFree();
        final values = [...controller.game!.values],
            notes = [...controller.game!.notes];
        await tester.pumpWidget(
          _GameHarness(
            controller: controller,
            container: harness.container,
            textScale: 1.8,
            locale: Locale(language),
          ),
        );
        final l = await AppLocalizations.delegate.load(Locale(language));
        final hint = harness.container.read(gameHintProvider)!;
        final placement = hint.steps.first.placement!;
        final answer = hint.steps.first.digits.bitLength - 1;
        final initialBoardRect = tester.getRect(
          find.byKey(const ValueKey('game-puzzle')),
        );
        final initialContextControlsSize = tester.getSize(
          find.byKey(const ValueKey('game-context-controls')),
        );
        await tester.tap(find.text(l.hint));
        await tester.pumpAndSettle();
        expect(
          tester.getRect(find.byKey(const ValueKey('game-puzzle'))),
          initialBoardRect,
        );
        expect(
          tester.getSize(find.byKey(const ValueKey('game-context-controls'))),
          initialContextControlsSize,
        );
        expect(find.byKey(const ValueKey('hint-coach')), findsOneWidget);
        expect(find.text(l.hintLookHere), findsOneWidget);
        expect(
          find.text(l.hintLocateCell(hintCellLabel(l, placement))),
          findsOneWidget,
        );
        expect(find.byKey(ValueKey('hint-focus-$placement')), findsOneWidget);
        expect(find.byKey(ValueKey('hint-result-$placement')), findsNothing);
        expect(
          find.text(l.hintEnterValue(hintCellLabel(l, placement), answer)),
          findsNothing,
        );
        expect(controller.paused, isFalse);
        expect(controller.game!.values, values);
        expect(controller.game!.notes, notes);
        await tester.tap(find.byKey(const ValueKey('hint-advance')));
        await tester.pump(const Duration(milliseconds: 80));
        expect(
          find.byKey(const ValueKey('hint-available-0-locate')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('hint-available-0-reason')),
          findsOneWidget,
        );
        await tester.pumpAndSettle();
        expect(
          tester.getRect(find.byKey(const ValueKey('game-puzzle'))),
          initialBoardRect,
        );
        expect(find.text(l.hintReasonPlacement), findsOneWidget);
        expect(find.byKey(const ValueKey('hint-explanation')), findsNothing);
        expect(
          find.text(l.hintEnterValue(hintCellLabel(l, placement), answer)),
          findsNothing,
        );
        expect(controller.game!.values, values);
        expect(controller.game!.notes, notes);
        await tester.tap(find.byKey(const ValueKey('hint-advance')));
        await tester.pumpAndSettle();
        expect(
          tester.getRect(find.byKey(const ValueKey('game-puzzle'))),
          initialBoardRect,
        );
        expect(
          find.text(l.hintEnterValue(hintCellLabel(l, placement), answer)),
          findsOneWidget,
        );
        expect(find.byKey(ValueKey('hint-result-$placement')), findsOneWidget);
        expect(find.byKey(const ValueKey('hint-explanation')), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('hint-explanation')));
        await tester.pumpAndSettle();
        expect(find.byType(HintExplanationContent), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(HintExplanationContent),
            matching: find.text(techniqueLabel(l, hint.steps.first.technique)),
          ),
          findsOneWidget,
        );
        Navigator.of(tester.element(find.byType(HintExplanationContent))).pop();
        await tester.pumpAndSettle();
        final seconds = controller.game!.elapsedSeconds;
        await tester.pump(const Duration(seconds: 2));
        expect(controller.game!.elapsedSeconds, greaterThanOrEqualTo(seconds));
        controller.suspend();
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('hint-coach')), findsNothing);
        controller.activate();
        expect(controller.paused, isTrue);
        controller.togglePause();
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('hint-coach')), findsOneWidget);
        final cell = controller.game!.values.indexOf(0);
        controller.moveSelection(cell);
        controller.enter(puzzle.solution[cell] % 9 + 1);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('hint-coach')), findsNothing);
        await tester.tap(find.text(l.hint));
        await tester.pumpAndSettle();
        expect(find.text(l.hintIncorrect), findsOneWidget);
        expect(tester.takeException(), isNull);
        controller.suspend();
      },
    );
  }
  testWidgets(
    'hint coach visualizes elimination chains and reveals only the next placement',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var session = GameSession.start(hardPuzzle);
      for (final step in LogicalSolver().solve(hardPuzzle.givens).steps) {
        if (step.placement == null) break;
        session = session.enter(step.placement!, step.digits.bitLength - 1);
      }
      final harness = ControllerHarness(
        GameRepository(
          MemoryStore()..value = SavedGames(free: session).encode(),
        ),
      );
      addTearDown(harness.dispose);
      final controller = harness.controller;
      await controller.initialize();
      controller.resumeFree();
      await tester.pumpWidget(
        _GameHarness(controller: controller, container: harness.container),
      );
      final l = AppLocalizations.of(
        tester.element(find.byKey(const ValueKey('show-hint'))),
      );
      final hint = harness.container.read(gameHintProvider)!;
      expect(hint.steps.length, greaterThan(1));
      expect(hint.steps.first.removals, isNotEmpty);

      await tester.tap(find.byKey(const ValueKey('show-hint')));
      await tester.pumpAndSettle();
      expect(find.text(l.hintLocateArea), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('hint-advance')));
      await tester.pumpAndSettle();
      final removal = hint.steps.first.removals.first;
      final removedDigit = [
        for (var digit = 1; digit <= 9; digit++)
          if (removal.mask & (1 << digit) != 0) digit,
      ].first;
      final removalFinder = find.byKey(
        ValueKey('hint-removal-${removal.cell}-$removedDigit'),
      );
      expect(removalFinder, findsOneWidget);
      expect(
        tester
            .widget<Text>(
              find.descendant(of: removalFinder, matching: find.byType(Text)),
            )
            .style
            ?.decoration,
        TextDecoration.lineThrough,
      );

      for (var index = 1; index < hint.steps.length; index++) {
        await tester.tap(find.byKey(const ValueKey('hint-advance')));
        await tester.pumpAndSettle();
        expect(
          find.text(techniqueLabel(l, hint.steps[index].technique)),
          findsOneWidget,
        );
      }
      final placement = hint.steps.last.placement!;
      final digit = hint.steps.last.digits.bitLength - 1;
      expect(
        find.text(l.hintEnterValue(hintCellLabel(l, placement), digit)),
        findsNothing,
      );
      await tester.tap(find.byKey(const ValueKey('hint-advance')));
      await tester.pumpAndSettle();
      expect(
        find.text(l.hintEnterValue(hintCellLabel(l, placement), digit)),
        findsOneWidget,
      );
      expect(find.byKey(ValueKey('hint-result-$placement')), findsOneWidget);
      expect(controller.game!.values, session.values);

      controller.moveSelection(placement);
      controller.enter(digit);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('hint-coach')), findsNothing);
      expect(controller.game!.values[placement], digit);
      expect(tester.takeException(), isNull);
      controller.suspend();
    },
  );
  testWidgets('unavailable hint stays compact on a short large-text layout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final solution = List.generate(
      81,
      (i) => (i ~/ 9 * 3 + i ~/ 27 + i % 9) % 9 + 1,
    );
    final session = GameSession.start(
      Puzzle(
        id: 'unavailable-hint',
        difficulty: Difficulty.easy,
        givens: List.filled(81, 0),
        solution: solution,
      ),
    );
    final harness = ControllerHarness(
      GameRepository(MemoryStore()..value = SavedGames(free: session).encode()),
    );
    addTearDown(harness.dispose);
    final controller = harness.controller;
    await controller.initialize();
    controller.resumeFree();
    await tester.pumpWidget(
      _GameHarness(
        controller: controller,
        container: harness.container,
        textScale: 1.8,
        locale: const Locale('de'),
      ),
    );
    final l = AppLocalizations.of(
      tester.element(find.byKey(const ValueKey('show-hint'))),
    );

    await tester.tap(find.byKey(const ValueKey('show-hint')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('hint-coach')), findsOneWidget);
    expect(find.text(l.hintUnavailable), findsOneWidget);
    expect(find.byKey(const ValueKey('hint-advance')), findsNothing);
    expect(find.byKey(const ValueKey('hint-explanation')), findsNothing);
    expect(controller.game!.values, session.values);
    expect(tester.takeException(), isNull);
    controller.suspend();
  });
  for (final mode in ErrorCheck.values) {
    testWidgets('only wrong entries are marked with ${mode.name}', (
      tester,
    ) async {
      final solution = List.generate(
        81,
        (i) => (i ~/ 9 * 3 + i ~/ 27 + i % 9) % 9 + 1,
      );
      final givens = List.filled(81, 0)..[0] = solution[0];
      final sample = Puzzle(
        id: 'error-test',
        difficulty: Difficulty.easy,
        givens: givens,
        solution: solution,
      );
      final session = GameSession.start(sample).enter(1, 1).enter(73, 1);
      final store = MemoryStore()
        ..value = SavedGames(
          free: session,
          settings: AppSettings(errorCheck: mode),
        ).encode();
      final controllerHarness = ControllerHarness(GameRepository(store));
      final controller = controllerHarness.controller;
      addTearDown(controllerHarness.dispose);
      await controller.initialize();
      controller.resumeFree();
      controller.selectCell(2);
      await tester.pumpWidget(
        _GameHarness(
          container: controllerHarness.container,
          controller: controller,
        ),
      );
      await tester.pumpAndSettle();

      TextStyle style(int cell) => tester
          .widget<Text>(
            find.descendant(
              of: find.byKey(ValueKey('cell-$cell')),
              matching: find.text('${controller.game!.values[cell]}'),
            ),
          )
          .style!;
      void check({required bool wrong}) {
        expect(style(0).decoration, isNull);
        expect(style(73).decoration, isNull);
        expect(style(0).color, isNot(const Color(0xffd5505b)));
        expect(style(73).color, isNot(const Color(0xffd5505b)));
        expect(style(1).decoration, wrong ? TextDecoration.underline : isNull);
        if (controller.selected != 1) {
          expect(
            style(1).color,
            wrong ? const Color(0xffd5505b) : isNot(const Color(0xffd5505b)),
          );
        }
        final errorSemantics = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              (widget.properties.value?.contains('Falscher Wert') ?? false),
        );
        expect(errorSemantics, wrong ? findsOneWidget : findsNothing);
      }

      check(wrong: mode != ErrorCheck.off);
      await tester.tap(find.byKey(const ValueKey('cell-1')));
      await tester.pumpAndSettle();
      check(wrong: mode != ErrorCheck.off);
      controller.enter(solution[1]);
      await tester.pumpAndSettle();
      check(wrong: false);
      controller.undo();
      await tester.pumpAndSettle();
      check(wrong: mode != ErrorCheck.off);
      controller.redo();
      await tester.pumpAndSettle();
      check(wrong: false);
      controller.enter(9);
      controller.selectCell(2);
      await tester.pumpAndSettle();
      check(wrong: mode == ErrorCheck.solution);
      controller.suspend();
    });
  }

  test(
    'default checking compares only incorrect entries with the solution',
    () {
      expect(const AppSettings().errorCheck, ErrorCheck.solution);
    },
  );
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
      final controllerHarness = ControllerHarness(GameRepository(store));
      final controller = controllerHarness.controller;
      await controller.initialize();
      controller.resumeFree();
      addTearDown(controllerHarness.dispose);
      await tester.pumpWidget(
        _GameHarness(
          container: controllerHarness.container,
          controller: controller,
        ),
      );
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
    final controllerHarness = ControllerHarness(GameRepository(MemoryStore()));
    final controller = controllerHarness.controller;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: controllerHarness.container,
        child: const SudokuApp(locale: Locale('de')),
      ),
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
      final controllerHarness = ControllerHarness(
        GameRepository(
          MemoryStore()
            ..value = SavedGames(free: GameSession.start(puzzle)).encode(),
        ),
      );
      final controller = controllerHarness.controller;
      await controller.initialize();
      controller.resumeFree();
      addTearDown(controllerHarness.dispose);
      await tester.pumpWidget(
        _GameHarness(
          container: controllerHarness.container,
          controller: controller,
        ),
      );
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
    final controllerHarness = ControllerHarness(GameRepository(store));
    final controller = controllerHarness.controller;
    await controller.initialize();
    controller.resumeFree();
    addTearDown(controllerHarness.dispose);
    await tester.pumpWidget(
      _GameHarness(
        container: controllerHarness.container,
        controller: controller,
        textScale: 2,
      ),
    );
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
      final controllerHarness = ControllerHarness(
        GameRepository(
          MemoryStore()..value = SavedGames(free: session).encode(),
        ),
      );
      final controller = controllerHarness.controller;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: controllerHarness.container,
          child: const SudokuApp(locale: Locale('de')),
        ),
      );
      await tester.pumpAndSettle();
      final choice = find.byKey(const ValueKey('start-hard'));
      await tester.ensureVisible(choice);
      await tester.pumpAndSettle();
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
          ..addFont(rootBundle.load('assets/fonts/GoogleSans-Regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/GoogleSans-Medium.ttf'))
          ..addFont(rootBundle.load('assets/fonts/GoogleSans-SemiBold.ttf'))
          ..addFont(rootBundle.load('assets/fonts/GoogleSans-Bold.ttf'));
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
        final controllerHarness = ControllerHarness(
          GameRepository(
            MemoryStore()..value = SavedGames(free: sample).encode(),
          ),
        );
        final controller = controllerHarness.controller;
        await controller.initialize();
        controller.resumeFree();
        addTearDown(controllerHarness.dispose);
        await tester.pumpWidget(
          _GameHarness(
            container: controllerHarness.container,
            controller: controller,
          ),
        );
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

  test('each board theme survives save/load', () {
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
  required final ProviderContainer container,
  final double textScale = 1,
  final Locale locale = const Locale('de'),
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => UncontrolledProviderScope(
    container: container,
    child: RudiApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: sudokuTheme(Brightness.light, controller.settings),
      home: Consumer(
        builder: (context, ref, _) {
          ref.watch(sudokuControllerProvider);
          return RepaintBoundary(
            key: const ValueKey('game-render'),
            child: GamePage(controller: controller),
          );
        },
      ),
    ),
  );
}
