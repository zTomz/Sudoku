import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/app/sudoku_controller.dart';

import 'controller_harness.dart';

import 'package:sudoku/features/game/data/game_repository.dart';
import 'package:sudoku/features/game/domain/game_session.dart';
import 'package:sudoku/features/game/domain/puzzle.dart';
import 'package:sudoku/features/game/domain/sudoku_engine.dart';
import 'package:sudoku/features/settings/domain/app_settings.dart';

final class MemoryStore() implements SnapshotStore {
  String? value;
  bool failRead = false, failWrite = false;
  int writes = 0;
  @override
  Future<String?> read() async {
    if (failRead) throw StateError('read failure');
    return value;
  }

  @override
  Future<void> write(String snapshot) async {
    if (failWrite) throw StateError('write failure');
    writes++;
    value = snapshot;
  }
}

void main() {
  test('disposing during generation leaves the saved game untouched', () async {
    final puzzle = await SudokuEngine().generate(
      seed: 42,
      difficulty: Difficulty.easy,
    );
    final store = MemoryStore()
      ..value = SavedGames(free: GameSession.start(puzzle)).encode();
    final snapshot = store.value;
    final controllerHarness = ControllerHarness(GameRepository(store));
    final controller = controllerHarness.controller;
    await controller.initialize();
    final pending = controller.startFree(Difficulty.hard);
    expect(controller.busy, isTrue);
    controllerHarness.dispose();
    await pending;
    expect(store.value, snapshot);
    expect(store.writes, 0);
  });

  test(
    'free and daily sessions, preferences and undo survive reopening',
    () async {
      final store = MemoryStore();
      final controllerHarness = ControllerHarness(GameRepository(store));
      final controller = controllerHarness.controller;
      await controller.initialize();
      await controller.startFree(Difficulty.easy);
      final cell = controller.game!.puzzle.givens.indexOf(0);
      controller.selectCell(cell);
      controller.enter(controller.game!.puzzle.solution[cell]);
      final freeId = controller.game!.puzzle.id;
      controller.leaveGame();
      await controller.startDaily(DateTime(2026, 8, 1));
      controller.changeSettings(
        const AppSettings(errorCheck: ErrorCheck.off, showTimer: false),
      );
      controller.leaveGame();
      await controller.persist();
      controllerHarness.dispose();
      final loadedHarness = ControllerHarness(GameRepository(store));
      final loaded = loadedHarness.controller;
      await loaded.initialize();
      expect(loaded.free!.puzzle.id, freeId);
      expect(loaded.free!.canUndo, true);
      expect(loaded.dailyGames.containsKey('2026-08-01'), true);
      expect(loaded.settings.errorCheck, ErrorCheck.off);
      expect(loaded.settings.showTimer, false);
      loadedHarness.dispose();
    },
  );
  test('failed read preserves the original save and can be retried', () async {
    final store = MemoryStore()..value = 'corrupt data';
    final controllerHarness = ControllerHarness(GameRepository(store));
    final controller = controllerHarness.controller;
    await controller.initialize();
    expect(controller.loadFailed, true);
    expect(controller.ready, false);
    await controller.startFree(Difficulty.easy);
    await controller.persist();
    expect(store.value, 'corrupt data');
    expect(store.writes, 0);
    store.value = SavedGames().encode();
    await controller.initialize();
    expect(controller.ready, true);
    controllerHarness.dispose();
  });
  test('write failures are visible and retries recover', () async {
    final store = MemoryStore();
    final controllerHarness = ControllerHarness(GameRepository(store));
    final controller = controllerHarness.controller;
    await controller.initialize();
    store.failWrite = true;
    await controller.startFree(Difficulty.easy);
    expect(controller.saveFailed, true);
    store.failWrite = false;
    await controller.persist();
    expect(controller.saveFailed, false);
    expect(SavedGames.decode(store.value!).free, isNotNull);
    controllerHarness.dispose();
  });
  test('writes are serialized even when completion is delayed', () async {
    final events = <String>[];
    final first = Completer<void>();
    final store = _DelayedStore(events, first);
    final repo = GameRepository(store);
    final a = repo.save(SavedGames());
    final b = repo.save(
      SavedGames(settings: const AppSettings(showTimer: false)),
    );
    await Future<void>.delayed(Duration.zero);
    expect(events, ['start']);
    first.complete();
    await Future.wait([a, b]);
    expect(events, ['start', 'end', 'start', 'end']);
    expect(SavedGames.decode(store.value!).settings.showTimer, false);
  });
  test('number-first keyboard navigation never enters a number', () async {
    final controllerHarness = ControllerHarness(GameRepository(MemoryStore()));
    final controller = controllerHarness.controller;
    await controller.initialize();
    await controller.startFree(Difficulty.easy);
    controller.changeSettings(const AppSettings(numberFirst: true));
    controller.chooseDigit(3);
    final cell = controller.game!.puzzle.givens.indexOf(0);
    controller.moveSelection(cell);
    expect(controller.game!.values[cell], 0);
    controller.selectCell(cell);
    expect(controller.game!.values[cell], 3);
    controller.togglePause();
    controller.enter(5);
    expect(controller.game!.values[cell], 3);
    controllerHarness.dispose();
  });
  test('disposing during generation does not start timers or notify', () async {
    final controllerHarness = ControllerHarness(GameRepository(MemoryStore()));
    final controller = controllerHarness.controller;
    await controller.initialize();
    var notifications = 0;
    controllerHarness.container.listen(
      sudokuControllerProvider,
      (_, _) => notifications++,
    );
    final generating = controller.startFree(Difficulty.hard);
    final beforeDisposal = notifications;
    controllerHarness.dispose();
    await generating;
    expect(notifications, beforeDisposal);
  });
}

final class _DelayedStore(final List<String> events, final Completer<void> gate)
    implements SnapshotStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String snapshot) async {
    events.add('start');
    await gate.future;
    value = snapshot;
    events.add('end');
  }
}
