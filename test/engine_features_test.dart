import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/app/hint_provider.dart';
import 'package:sudoku/app/sudoku_controller.dart';
import 'package:sudoku/features/game/data/game_repository.dart';
import 'package:sudoku/features/game/data/puzzle_generator.dart';
import 'package:sudoku/features/game/domain/game_hint.dart';
import 'package:sudoku/features/game/domain/game_session.dart';
import 'package:sudoku/features/game/domain/logical_solver.dart';
import 'package:sudoku/features/game/domain/puzzle.dart';
import 'package:sudoku/features/game/domain/sudoku_engine.dart';

import 'controller_harness.dart';
import 'storage_controller_test.dart' show MemoryStore;

void main() {
  final engine = SudokuEngine();
  final solver = LogicalSolver();

  test(
    'completed and unsupported positions do not reveal arbitrary numbers',
    () {
      final solution = List.generate(
        81,
        (i) => (i ~/ 9 * 3 + i ~/ 27 + i % 9) % 9 + 1,
      );
      GameSession session(List<int> givens) => GameSession.start(
        Puzzle(
          id: 'hint-boundary',
          difficulty: Difficulty.easy,
          givens: givens,
          solution: solution,
        ),
      );
      final complete = GameHint.forGame(session(solution));
      expect(complete.status, HintStatus.complete);
      expect(complete.steps, isEmpty);
      final unavailable = GameHint.forGame(session(List.filled(81, 0)));
      expect(unavailable.status, HintStatus.unavailable);
      expect(unavailable.steps, isEmpty);
    },
  );

  test(
    'effort counts repeated techniques and scarce next moves separately',
    () async {
      final puzzle = await engine.generate(
        seed: 4,
        difficulty: Difficulty.hard,
      );
      final result = solver.solve(puzzle.givens);
      expect(
        result.rating.techniqueCost,
        result.steps.fold<int>(0, (cost, step) => cost + step.technique.effort),
      );
      expect(result.rating.searchCost, greaterThan(0));
      expect(result.rating.bottlenecks, greaterThan(0));
      expect(
        result.rating.score,
        result.rating.techniqueCost + result.rating.searchCost,
      );
      expect(puzzle.rating.toJson(), result.rating.toJson());
      expect(
        Puzzle.fromJson(puzzle.toJson()).rating.toJson(),
        result.rating.toJson(),
      );
      final one = [...puzzle.solution]..[0] = 0;
      final ten = [...puzzle.solution];
      for (var c = 0; c < 10; c++) {
        ten[c] = 0;
      }
      expect(solver.solve(one).difficulty, solver.solve(ten).difficulty);
      expect(
        solver.solve(ten).rating.techniqueCost,
        greaterThan(solver.solve(one).rating.techniqueCost),
      );
      expect(
        solver.solve(ten).rating.searchCost,
        0,
        reason: 'No artificial bottleneck in the trivial tail',
      );
      final unassessed = solver.solve(puzzle.givens, assessDifficulty: false);
      expect(unassessed.values, result.values);
      expect(unassessed.difficulty, result.difficulty);
      expect(
        unassessed.steps.map((s) => s.technique),
        result.steps.map((s) => s.technique),
      );
    },
  );

  test('hints explain an elimination chain through the next placement without changing the game', () async {
    final puzzle = await engine.generate(seed: 4, difficulty: Difficulty.hard);
    var game = GameSession.start(puzzle);
    final trace = solver.solve(puzzle.givens);
    for (final step in trace.steps) {
      if (step.placement == null) break;
      game = game.enter(step.placement!, step.digits.bitLength - 1);
    }
    final before = game.toJson();
    final hint = GameHint.forGame(game);
    expect(hint.status, HintStatus.available);
    expect(hint.steps.first.placement, isNull);
    expect(hint.steps.last.placement, isNotNull);
    expect(hint.steps.where((s) => s.placement != null).length, 1);
    for (final step in hint.steps) {
      expect(step.candidates, isNotEmpty);
      for (final removal in step.removals) {
        expect(removal.mask & (1 << puzzle.solution[removal.cell]), 0);
      }
    }
    final placement = hint.steps.last;
    expect(placement.digits, 1 << puzzle.solution[placement.placement!]);
    expect(game.toJson(), before);
    expect(() => hint.steps.clear(), throwsUnsupportedError);
    expect(() => hint.steps.first.candidates.clear(), throwsUnsupportedError);
  });

  test('hints reject wrong entries, ignore notes, and invalidate only for board changes', () async {
    final puzzle = await engine.generate(seed: 42, difficulty: Difficulty.easy);
    final store = MemoryStore()
      ..value = SavedGames(free: GameSession.start(puzzle)).encode();
    final harness = ControllerHarness(GameRepository(store));
    addTearDown(harness.dispose);
    final controller = harness.controller;
    await controller.initialize();
    controller.resumeFree();
    final subscription = harness.container.listen(gameHintProvider, (_, _) {});
    addTearDown(subscription.close);
    final initial = harness.container.read(gameHintProvider)!;
    final cell = initial.steps.last.placement!;
    controller.moveSelection(cell);
    controller.togglePencil();
    controller.enter(1);
    expect(harness.container.read(gameHintProvider), same(initial));
    controller.togglePencil();
    controller.enter(puzzle.solution[cell] % 9 + 1);
    expect(
      harness.container.read(gameHintProvider)!.status,
      HintStatus.incorrect,
    );
    controller.undo();
    expect(
      harness.container.read(gameHintProvider)!.status,
      HintStatus.available,
    );
    controller.enter(puzzle.solution[cell]);
    expect(
      harness.container.read(gameHintProvider)!.steps.last.placement,
      isNot(cell),
    );
  });

  test('native worker matches direct generation and keeps the event loop responsive', () async {
    const request = GenerationRequest(seed: 4, difficulty: Difficulty.hard);
    var ticks = 0;
    final timer = Timer.periodic(
      const Duration(milliseconds: 1),
      (_) => ticks++,
    );
    addTearDown(timer.cancel);
    final job = generatePuzzle(request);
    addTearDown(job.cancel);
    final background = await job.result;
    expect(ticks, greaterThan(0));
    expect(background.toJson(), (await request.run()).toJson());
    const daily = GenerationRequest(
      seed: 20260831,
      difficulty: Difficulty.medium,
      dailyDate: '2026-08-31',
    );
    expect(
      (await generatePuzzle(daily).result).toJson(),
      (await daily.run()).toJson(),
    );
  });

  test('worker cancellation before startup, failures and timeouts settle exactly once', () async {
    final cancelled = generatePuzzle(
      const GenerationRequest(seed: 1, difficulty: Difficulty.hard),
    );
    final cancellation = expectLater(cancelled.result, throwsStateError);
    cancelled.cancel();
    cancelled.cancel();
    await cancellation;
    final failed = generatePuzzle(
      const GenerationRequest(
        seed: 1,
        difficulty: Difficulty.easy,
        dailyDate: 'invalid',
      ),
    );
    await expectLater(failed.result, throwsStateError);
    var stops = 0;
    final timed = GenerationJob(timeout: const Duration(milliseconds: 1));
    timed.attach(() => stops++);
    await expectLater(timed.result, throwsA(isA<TimeoutException>()));
    timed.cancel();
    expect(stops, 1);
    timed.attach(() => stops++);
    expect(stops, 2, reason: 'Late worker startup must stop immediately');
  });

  test('Riverpod owns jobs, rejects concurrent requests and handles lifecycle and retry', () async {
    final puzzle = await engine.generate(seed: 42, difficulty: Difficulty.easy);
    var starts = 0;
    var stopped = false;
    late GenerationJob job;
    final harness = ControllerHarness(
      GameRepository(MemoryStore()),
      generator: (_) {
        starts++;
        job = GenerationJob()..attach(() => stopped = true);
        return job;
      },
    );
    final controller = harness.controller;
    await controller.initialize();
    final pending = controller.startFree(Difficulty.easy);
    await controller.startFree(Difficulty.hard);
    expect(starts, 1);
    controller.suspend();
    job.succeed(puzzle);
    await pending;
    expect(stopped, isTrue);
    expect(controller.paused, isTrue);
    controller.activate();
    expect(controller.paused, isTrue);
    controller.togglePause();
    expect(controller.paused, isFalse);
    controller.leaveGame();
    final failure = controller.startFree(Difficulty.easy);
    job.fail(StateError('worker failure'));
    await failure;
    expect(controller.generationFailed, isTrue);
    expect(controller.busy, isFalse);
    final retry = controller.startFree(Difficulty.easy);
    expect(controller.generationFailed, isFalse);
    final state = harness.container.read(sudokuControllerProvider);
    harness.dispose();
    await retry;
    expect(stopped, isTrue);
    expect(
      state.busy,
      isTrue,
      reason: 'Previously published snapshots remain immutable',
    );
  });
}
