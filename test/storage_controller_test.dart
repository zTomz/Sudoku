import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/app/sudoku_controller.dart';

import 'controller_harness.dart';

import 'package:sudoku/features/game/data/game_repository.dart';
import 'package:sudoku/features/game/domain/difficulty_rating.dart';
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

final class RecoverableMemoryStore() implements RecoverableSnapshotStore {
  String? value;
  String? recovery;
  int remainingReadFailures = 0;

  @override
  Future<String?> read() async {
    if (remainingReadFailures > 0) {
      remainingReadFailures--;
      throw StateError('transient read failure');
    }
    return value;
  }

  @override
  Future<String?> readRecovery() async => recovery;

  @override
  Future<void> write(String snapshot) async => value = snapshot;

  @override
  Future<void> writeRecovery(String snapshot) async => recovery = snapshot;
}

void main() {
  test('version 2 saves without hint counters remain readable', () async {
    final puzzle = await SudokuEngine().generate(
      seed: 41,
      difficulty: Difficulty.easy,
    );
    final saved = SavedGames(
      free: GameSession.start(puzzle),
      results: {
        puzzle.id: GameResult(puzzle.id, puzzle.difficulty, 120, null, 500, 1),
      },
    );
    final json = jsonDecode(saved.encode()) as Map<String, Object?>;
    (json['free'] as Map<String, Object?>).remove('hintsUsed');
    final results = json['results'] as Map<String, Object?>;
    (results[puzzle.id] as Map<String, Object?>).remove('hintsUsed');

    final restored = SavedGames.decode(jsonEncode(json));

    expect(json['schemaVersion'], 2);
    expect(restored.free!.hintsUsed, 0);
    expect(restored.results[puzzle.id]!.hintsUsed, 0);
  });

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
  test('transient read failures are retried before showing an error', () async {
    final expected = SavedGames(settings: const AppSettings(showTimer: false));
    final store = RecoverableMemoryStore()
      ..value = expected.encode()
      ..remainingReadFailures = 2;

    final loaded = await GameRepository(store).load();

    expect(loaded.settings.showTimer, false);
    expect(store.remainingReadFailures, 0);
  });
  test('a corrupt primary snapshot falls back to the recovery copy', () async {
    final recovery = SavedGames(settings: const AppSettings(showTimer: false));
    final store = RecoverableMemoryStore()
      ..value = 'corrupt data'
      ..recovery = recovery.encode();

    final loaded = await GameRepository(store).load();

    expect(loaded.settings.showTimer, false);
    expect(store.value, 'corrupt data');
  });
  test('saving keeps the previous validated snapshot for recovery', () async {
    final original = SavedGames();
    final store = RecoverableMemoryStore()..value = original.encode();
    final repository = GameRepository(store);
    await repository.load();

    await repository.save(
      SavedGames(settings: const AppSettings(showTimer: false)),
    );

    expect(store.recovery, original.encode());
    expect(SavedGames.decode(store.value!).settings.showTimer, false);
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
  test('leaving stores the session and clears the active game', () async {
    final controllerHarness = ControllerHarness(GameRepository(MemoryStore()));
    final controller = controllerHarness.controller;
    await controller.initialize();
    await controller.startFree(Difficulty.easy);

    controller.leaveGame();

    expect(controller.playing, isFalse);
    expect(controller.game, isNull);
    expect(controller.free, isNotNull);
    controllerHarness.dispose();
  });
  test('debug simulation creates a valid near-complete saved game', () async {
    final puzzle = await SudokuEngine().generate(
      seed: 73,
      difficulty: Difficulty.easy,
    );
    final store = MemoryStore()
      ..value = SavedGames(free: GameSession.start(puzzle)).encode();
    final harness = ControllerHarness(GameRepository(store));
    addTearDown(harness.dispose);
    final controller = harness.controller;
    await controller.initialize();
    expect(controller.playing, isFalse);

    controller.simulateGameForDebug(filledCells: 80, mistakes: 2, hintsUsed: 3);
    await controller.persist();

    expect(controller.playing, isTrue);
    expect(controller.game!.filled, 80);
    expect(controller.game!.complete, isFalse);
    expect(controller.game!.mistakes, 2);
    expect(controller.game!.hintsUsed, 3);
    final restored = SavedGames.decode(store.value!).free!;
    expect(restored.values, controller.game!.values);
    expect(restored.mistakes, 2);
    expect(restored.hintsUsed, 3);
  });
  test('completed results retain the puzzle effort score', () async {
    final solution = List.generate(
      81,
      (cell) => (cell ~/ 9 * 3 + cell ~/ 27 + cell % 9) % 9 + 1,
    );
    final puzzle = Puzzle(
      id: 'scored-result',
      difficulty: Difficulty.easy,
      givens: [...solution]..[0] = 0,
      solution: solution,
      rating: const DifficultyRating(techniqueCost: 123),
    );
    final store = MemoryStore()
      ..value = SavedGames(free: GameSession.start(puzzle)).encode();
    final harness = ControllerHarness(GameRepository(store));
    addTearDown(harness.dispose);
    final controller = harness.controller;
    await controller.initialize();
    controller.resumeFree();

    controller.selectCell(0);
    controller.enter(solution[0]);
    await controller.persist();

    expect(controller.results.single.effortScore, 123);
    expect(
      SavedGames.decode(store.value!).results['scored-result']!.effortScore,
      123,
    );
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
