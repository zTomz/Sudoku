import 'puzzle.dart';

abstract final class GameScoring() {
  static const correctCell = 10;
  static const completedRow = 20;
  static const completedColumn = 20;
  static const completedBox = 25;
  static const dailyBonus = 50;

  static int completionBonus(Difficulty difficulty) => switch (difficulty) {
    Difficulty.easy => 100,
    Difficulty.medium => 200,
    Difficulty.hard => 350,
  };

  static int accuracyBonus(int mistakes) => switch (mistakes) {
    0 => 100,
    1 => 60,
    2 => 30,
    _ => 0,
  };
}

final class const CellEdit(
  final int cell,
  final int beforeValue,
  final int afterValue,
  final int beforeNotes,
  final int afterNotes,
) {
  List<int> toJson() => [
    cell,
    beforeValue,
    afterValue,
    beforeNotes,
    afterNotes,
  ];

  factory fromJson(Object? value) {
    if (value
        case [int cell, int before, int after, int notesBefore, int notesAfter]
        when cell >= 0 &&
            cell < 81 &&
            before >= 0 &&
            before <= 9 &&
            after >= 0 &&
            after <= 9 &&
            notesBefore >= 0 &&
            notesBefore <= 1022 &&
            notesAfter >= 0 &&
            notesAfter <= 1022) {
      return CellEdit(cell, before, after, notesBefore, notesAfter);
    }
    throw const FormatException('Invalid move');
  }
}

final class GameSession({
  required final Puzzle puzzle,
  required List<int> values,
  required List<int> notes,
  List<List<CellEdit>> history = const [],
  final int cursor = 0,
  final int elapsedSeconds = 0,
  Set<int> awardedCells = const {},
  Set<int> awardedUnits = const {},
  final int mistakes = 0,
}) {
  this
    : values = List.unmodifiableOf(values),
      notes = List.unmodifiableOf(notes),
      history = List.unmodifiableOf(history.map(List<CellEdit>.unmodifiableOf)),
      awardedCells = Set.unmodifiable(awardedCells),
      awardedUnits = Set.unmodifiable(awardedUnits);

  final List<int> values;
  final List<int> notes;
  final List<List<CellEdit>> history;
  final Set<int> awardedCells;
  final Set<int> awardedUnits;

  factory start(Puzzle puzzle) => GameSession(
    puzzle: puzzle,
    values: puzzle.givens,
    notes: List.filled(81, 0),
  );

  bool get complete =>
      List.generate(81, (i) => values[i] == puzzle.solution[i]).every((x) => x);
  int get filled => values.where((v) => v != 0).length;
  bool get canUndo => cursor > 0 && !complete;
  bool get canRedo => cursor < history.length && !complete;
  int get points =>
      awardedCells.length * GameScoring.correctCell +
      awardedUnits.fold(0, (total, unit) {
        if (unit < 9) return total + GameScoring.completedRow;
        if (unit < 18) return total + GameScoring.completedColumn;
        return total + GameScoring.completedBox;
      });

  int get finalPoints =>
      points +
      GameScoring.completionBonus(puzzle.difficulty) +
      GameScoring.accuracyBonus(mistakes) +
      (puzzle.dailyDate == null ? 0 : GameScoring.dailyBonus);

  bool isDigitAvailable(int digit) =>
      digit >= 1 &&
      digit <= 9 &&
      values.where((value) => value == digit).length < 9;

  GameSession enter(
    int cell,
    int digit, {
    bool pencil = false,
    bool cleanNotes = true,
  }) {
    if (cell < 0 ||
        cell >= 81 ||
        digit < 0 ||
        digit > 9 ||
        (digit != 0 && !isDigitAvailable(digit)) ||
        puzzle.givens[cell] != 0 ||
        complete) {
      return this;
    }
    final nextValues = [...values], nextNotes = [...notes];
    if (pencil && digit != 0) {
      if (values[cell] != 0) return this;
      nextNotes[cell] ^= 1 << digit;
    } else {
      nextValues[cell] = digit;
      nextNotes[cell] = 0;
      if (cleanNotes && digit != 0) {
        for (final peer in peers(cell)) {
          nextNotes[peer] &= ~(1 << digit);
        }
      }
      final emptyCells = [
        for (var index = 0; index < 81; index++)
          if (nextValues[index] == 0) index,
      ];
      if (digit != 0 &&
          nextValues[cell] != values[cell] &&
          emptyCells.isNotEmpty &&
          emptyCells.every(
            (emptyCell) =>
                puzzle.solution[emptyCell] == puzzle.solution[emptyCells.first],
          ) &&
          List.generate(
            81,
            (index) =>
                nextValues[index] == 0 ||
                nextValues[index] == puzzle.solution[index],
          ).every((matches) => matches)) {
        final lastDigit = puzzle.solution[emptyCells.first];
        for (final emptyCell in emptyCells) {
          nextValues[emptyCell] = lastDigit;
          nextNotes[emptyCell] = 0;
          if (cleanNotes) {
            for (final peer in peers(emptyCell)) {
              nextNotes[peer] &= ~(1 << lastDigit);
            }
          }
        }
      }
    }
    final changes = [
      for (var i = 0; i < 81; i++)
        if (nextValues[i] != values[i] || nextNotes[i] != notes[i])
          CellEdit(i, values[i], nextValues[i], notes[i], nextNotes[i]),
    ];
    if (changes.isEmpty) return this;
    final nextAwardedCells = {...awardedCells};
    final nextAwardedUnits = {...awardedUnits};
    var nextMistakes = mistakes;
    if (!pencil && digit != 0) {
      if (digit == puzzle.solution[cell]) {
        final candidateUnits = <int>{};
        for (final edit in changes) {
          if (edit.beforeValue == edit.afterValue ||
              edit.afterValue != puzzle.solution[edit.cell]) {
            continue;
          }
          nextAwardedCells.add(edit.cell);
          final row = edit.cell ~/ 9, column = edit.cell % 9;
          candidateUnits.addAll({
            row,
            9 + column,
            18 + row ~/ 3 * 3 + column ~/ 3,
          });
        }
        for (final unit in candidateUnits) {
          if (_unitIsCorrect(nextValues, unit)) nextAwardedUnits.add(unit);
        }
      } else {
        nextMistakes++;
      }
    }
    return GameSession(
      puzzle: puzzle,
      values: nextValues,
      notes: nextNotes,
      history: [...history.take(cursor), changes],
      cursor: cursor + 1,
      elapsedSeconds: elapsedSeconds,
      awardedCells: nextAwardedCells,
      awardedUnits: nextAwardedUnits,
      mistakes: nextMistakes,
    );
  }

  bool _unitIsCorrect(List<int> board, int unit) {
    for (var offset = 0; offset < 9; offset++) {
      final cell = switch (unit) {
        < 9 => unit * 9 + offset,
        < 18 => offset * 9 + unit - 9,
        _ =>
          ((unit - 18) ~/ 3 * 3 + offset ~/ 3) * 9 +
              (unit - 18) % 3 * 3 +
              offset % 3,
      };
      if (board[cell] != puzzle.solution[cell]) return false;
    }
    return true;
  }

  GameSession undo() => canUndo ? _travel(false) : this;
  GameSession redo() => canRedo ? _travel(true) : this;

  GameSession _travel(bool forward) {
    final nextValues = [...values], nextNotes = [...notes];
    for (final edit in history[forward ? cursor : cursor - 1]) {
      nextValues[edit.cell] = forward ? edit.afterValue : edit.beforeValue;
      nextNotes[edit.cell] = forward ? edit.afterNotes : edit.beforeNotes;
    }
    return GameSession(
      puzzle: puzzle,
      values: nextValues,
      notes: nextNotes,
      history: history,
      cursor: cursor + (forward ? 1 : -1),
      elapsedSeconds: elapsedSeconds,
      awardedCells: awardedCells,
      awardedUnits: awardedUnits,
      mistakes: mistakes,
    );
  }

  GameSession withElapsed(int seconds) => GameSession(
    puzzle: puzzle,
    values: values,
    notes: notes,
    history: history,
    cursor: cursor,
    elapsedSeconds: seconds,
    awardedCells: awardedCells,
    awardedUnits: awardedUnits,
    mistakes: mistakes,
  );

  bool hasConflict(int cell) =>
      values[cell] != 0 &&
      peers(cell).any((peer) => values[peer] == values[cell]);

  bool isIncorrect(int cell) =>
      puzzle.givens[cell] == 0 &&
      values[cell] != 0 &&
      values[cell] != puzzle.solution[cell];

  Map<String, Object?> toJson() => {
    'puzzle': puzzle.toJson(),
    'values': values,
    'notes': notes,
    'history': [
      for (final move in history) [for (final edit in move) edit.toJson()],
    ],
    'cursor': cursor,
    'elapsedSeconds': elapsedSeconds,
    'awardedCells': awardedCells.toList()..sort(),
    'awardedUnits': awardedUnits.toList()..sort(),
    'mistakes': mistakes,
  };

  factory fromJson(Map<String, Object?> json) {
    final puzzle = Puzzle.fromJson(json['puzzle'] as Map<String, Object?>);
    final values = readCells(json['values']),
        notes = readCells(json['notes'], max: 1022);
    final history = (json['history'] as List<Object?>)
        .map((move) => (move as List<Object?>).map(CellEdit.fromJson).toList())
        .toList();
    final cursor = json['cursor'] as int,
        seconds = json['elapsedSeconds'] as int,
        mistakes = json['mistakes'] as int;
    final awardedCells = _readUniqueIndexes(json['awardedCells'], 81);
    final awardedUnits = _readUniqueIndexes(json['awardedUnits'], 27);
    if (cursor < 0 ||
        cursor > history.length ||
        seconds < 0 ||
        mistakes < 0 ||
        awardedCells.any((cell) => puzzle.givens[cell] != 0)) {
      throw const FormatException('Invalid session');
    }
    // Replay all moves to verify both undo/redo and the saved board agree.
    final replay = [...puzzle.givens], replayNotes = List.filled(81, 0);
    void verifyBoard() {
      for (var i = 0; i < 81; i++) {
        if (replay[i] != values[i] || replayNotes[i] != notes[i]) {
          throw const FormatException('Inconsistent saved board');
        }
      }
    }

    if (cursor == 0) verifyBoard();
    for (var m = 0; m < history.length; m++) {
      final touched = <int>{};
      for (final edit in history[m]) {
        if (!touched.add(edit.cell) ||
            puzzle.givens[edit.cell] != 0 ||
            replay[edit.cell] != edit.beforeValue ||
            replayNotes[edit.cell] != edit.beforeNotes ||
            edit.afterNotes & 1 != 0 ||
            (edit.afterValue != 0 && edit.afterNotes != 0)) {
          throw const FormatException('Inconsistent move history');
        }
        replay[edit.cell] = edit.afterValue;
        replayNotes[edit.cell] = edit.afterNotes;
      }
      if (m + 1 == cursor) verifyBoard();
    }
    return GameSession(
      puzzle: puzzle,
      values: values,
      notes: notes,
      history: history,
      cursor: cursor,
      elapsedSeconds: seconds,
      awardedCells: awardedCells,
      awardedUnits: awardedUnits,
      mistakes: mistakes,
    );
  }
}

Set<int> _readUniqueIndexes(Object? value, int upperBound) {
  if (value is! List<Object?>) throw const FormatException('Invalid awards');
  final indexes = <int>{};
  for (final index in value) {
    if (index is! int ||
        index < 0 ||
        index >= upperBound ||
        !indexes.add(index)) {
      throw const FormatException('Invalid awards');
    }
  }
  return indexes;
}
