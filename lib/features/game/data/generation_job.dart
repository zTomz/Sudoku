import 'dart:async';

import '../domain/puzzle.dart';
import '../domain/sudoku_engine.dart';

typedef PuzzleGenerator = GenerationJob Function(GenerationRequest request);

final class const GenerationRequest({
  required final int seed,
  required final Difficulty difficulty,
  final String? dailyDate,
}) {
  Future<Puzzle> run() => dailyDate == null
      ? SudokuEngine().generate(seed: seed, difficulty: difficulty)
      : SudokuEngine().daily(DateTime.parse(dailyDate!));

  Map<String, Object?> toJson() => {
    'seed': seed,
    'difficulty': difficulty.name,
    'dailyDate': dailyDate,
  };

  factory fromJson(Map<String, Object?> json) => GenerationRequest(
    seed: json['seed'] as int,
    difficulty: Difficulty.values.byName(json['difficulty'] as String),
    dailyDate: json['dailyDate'] as String?,
  );
}

/// Owns both the result and physical worker lifetime, including startup races.
final class GenerationJob({
  final Duration timeout = const Duration(minutes: 2),
}) {
  final _result = Completer<Puzzle>();
  void Function()? _stop;
  Timer? _timeout;

  Future<Puzzle> get result => _result.future;
  bool get completed => _result.isCompleted;

  void attach(void Function() stop) {
    if (completed) {
      stop();
    } else {
      _stop = stop;
      _timeout ??= Timer(
        timeout,
        () => fail(TimeoutException('Puzzle generation timed out')),
      );
    }
  }

  void succeed(Puzzle puzzle) {
    if (completed) return;
    _result.complete(puzzle);
    _cleanup();
  }

  void fail(Object error) {
    if (completed) return;
    _result.completeError(error);
    _cleanup();
  }

  void cancel() => fail(StateError('Puzzle generation cancelled'));

  void _cleanup() {
    _timeout?.cancel();
    _stop?.call();
    _stop = null;
  }
}
