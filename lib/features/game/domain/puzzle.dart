import 'difficulty_rating.dart';

enum Difficulty() {
  easy,
  medium,
  hard,
}

final class Puzzle({
  required final String id,
  required final Difficulty difficulty,
  required List<int> givens,
  required List<int> solution,
  final String? dailyDate,
  final DifficultyRating rating = const DifficultyRating(),
}) {
  this
    : givens = List.unmodifiableOf(givens),
      solution = List.unmodifiableOf(solution);

  final List<int> givens;
  final List<int> solution;

  Map<String, Object?> toJson() => {
    'id': id,
    'difficulty': difficulty.name,
    'givens': givens,
    'solution': solution,
    'dailyDate': dailyDate,
    'rating': rating.toJson(),
  };

  factory fromJson(Map<String, Object?> json) {
    final givens = readCells(json['givens']);
    final solution = readCells(json['solution'], min: 1);
    for (var i = 0; i < 81; i++) {
      if (givens[i] != 0 && givens[i] != solution[i]) {
        throw const FormatException('Invalid puzzle clues');
      }
      if (peers(i).any((j) => solution[i] == solution[j])) {
        throw const FormatException('Invalid solution');
      }
    }
    return Puzzle(
      id: json['id'] as String,
      difficulty: Difficulty.values.byName(json['difficulty'] as String),
      givens: givens,
      solution: solution,
      dailyDate: json['dailyDate'] as String?,
      rating: DifficultyRating.fromJson(json['rating'] as Map<String, Object?>),
    );
  }
}

List<int> readCells(Object? value, {int min = 0, int max = 9}) {
  if (value is! List<Object?> || value.length != 81) {
    throw const FormatException('Expected 81 cells');
  }
  return value.map((cell) {
    if (cell is! int || cell < min || cell > max) {
      throw const FormatException('Invalid cell');
    }
    return cell;
  }).toList();
}

Iterable<int> peers(int cell) sync* {
  final row = cell ~/ 9, col = cell % 9;
  for (var i = 0; i < 81; i++) {
    if (i != cell &&
        (i ~/ 9 == row ||
            i % 9 == col ||
            (i ~/ 27 == row ~/ 3 && i % 9 ~/ 3 == col ~/ 3))) {
      yield i;
    }
  }
}

String dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
