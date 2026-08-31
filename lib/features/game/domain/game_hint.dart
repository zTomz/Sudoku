import 'game_session.dart';
import 'logical_solver.dart';

enum HintStatus() {
  available,
  incorrect,
  complete,
  unavailable
}

/// A read-only proof prefix through the next placement. Player notes are not
/// premises: incomplete or mistaken notes must never produce false deductions.
final class GameHint(
  final HintStatus status, [
  List<LogicalStep> steps = const [],
]) {
  this : steps = List.unmodifiable(steps);
  final List<LogicalStep> steps;

  factory forGame(GameSession game) {
    if (game.complete) return GameHint(HintStatus.complete);
    if (List.generate(81, (cell) => cell).any(game.isIncorrect)) {
      return GameHint(HintStatus.incorrect);
    }
    final result = LogicalSolver().solve(
      game.values,
      stopAfterPlacement: true,
      assessDifficulty: false,
    );
    return GameHint(
      result.steps.isEmpty ? HintStatus.unavailable : HintStatus.available,
      result.steps,
    );
  }
}
