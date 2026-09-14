import '../../game/data/game_repository.dart';
import '../../game/domain/puzzle.dart';

/// Predicts the solve time for a concrete puzzle using its logical effort.
int? predictPuzzleSolveTime(Iterable<GameResult> results, Puzzle puzzle) =>
    predictSolveTime(
      results.where((result) => result.id != puzzle.id),
      puzzle.difficulty,
      effortScore: puzzle.rating.score,
    );

/// Returns a robust personal solve-time estimate for [difficulty].
///
/// Only completed games at the requested difficulty contribute. When both the
/// result history and target puzzle have an effort score, times are normalized
/// by that score. Medians keep unusually short or long sessions from
/// distorting either estimate.
int? predictSolveTime(
  Iterable<GameResult> results,
  Difficulty difficulty, {
  int? effortScore,
}) {
  final matching = [
    for (final result in results)
      if (result.difficulty == difficulty && result.seconds > 0) result,
  ];
  if (matching.isEmpty) return null;
  final typicalSeconds = _median([
    for (final result in matching) result.seconds.toDouble(),
  ]);
  if (effortScore == null || effortScore <= 0) return typicalSeconds.round();

  final secondsPerEffortPoint = [
    for (final result in matching)
      if (result.effortScore case final score? when score > 0)
        result.seconds / score,
  ];
  if (secondsPerEffortPoint.isEmpty) return typicalSeconds.round();
  final scoreAdjusted = _median(secondsPerEffortPoint) * effortScore;
  return scoreAdjusted.clamp(typicalSeconds * .6, typicalSeconds * 1.6).round();
}

double _median(List<double> values) {
  values.sort();
  final middle = values.length ~/ 2;
  if (values.length.isOdd) return values[middle];
  return (values[middle - 1] + values[middle]) / 2;
}
