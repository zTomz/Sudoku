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
            cell < sudokuCellCount &&
            before >= 0 &&
            before <= sudokuSideLength &&
            after >= 0 &&
            after <= sudokuSideLength &&
            notesBefore >= 0 &&
            notesBefore <= sudokuCandidateMask &&
            notesAfter >= 0 &&
            notesAfter <= sudokuCandidateMask) {
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
    notes: List.filled(sudokuCellCount, 0),
  );

  bool get complete => List.generate(
    sudokuCellCount,
    (i) => values[i] == puzzle.solution[i],
  ).every((x) => x);
  int get filled => values.where((v) => v != 0).length;
  bool get canUndo => cursor > 0 && !complete;
  bool get canRedo => cursor < history.length && !complete;
  int get points =>
      awardedCells.length * GameScoring.correctCell +
      awardedUnits.fold(0, (total, unit) {
        final bonus = switch (SudokuUnit.fromId(unit).type) {
          SudokuUnitType.row => GameScoring.completedRow,
          SudokuUnitType.column => GameScoring.completedColumn,
          SudokuUnitType.box => GameScoring.completedBox,
        };
        return total + bonus;
      });

  int get finalPoints =>
      points +
      GameScoring.completionBonus(puzzle.difficulty) +
      GameScoring.accuracyBonus(mistakes) +
      (puzzle.dailyDate == null ? 0 : GameScoring.dailyBonus);

  bool isDigitAvailable(int digit) =>
      digit >= 1 &&
      digit <= sudokuSideLength &&
      values.where((value) => value == digit).length < sudokuSideLength;

  GameSession enter(
    int cell,
    int digit, {
    bool pencil = false,
    bool cleanNotes = true,
  }) {
    if (cell < 0 ||
        cell >= sudokuCellCount ||
        digit < 0 ||
        digit > sudokuSideLength ||
        (digit != 0 && !isDigitAvailable(digit)) ||
        puzzle.givens[cell] != 0 ||
        complete) {
      return this;
    }
    final edited = _editBoard(
      cell,
      digit,
      pencil: pencil,
      cleanNotes: cleanNotes,
    );
    if (edited == null) return this;
    final (:nextValues, :nextNotes) = edited;
    final changes = _changesTo(nextValues, nextNotes);
    if (changes.isEmpty) return this;
    final score = _scoreEdit(
      cell,
      digit,
      pencil: pencil,
      changes: changes,
      nextValues: nextValues,
    );
    return GameSession(
      puzzle: puzzle,
      values: nextValues,
      notes: nextNotes,
      history: [...history.take(cursor), changes],
      cursor: cursor + 1,
      elapsedSeconds: elapsedSeconds,
      awardedCells: score.cells,
      awardedUnits: score.units,
      mistakes: score.mistakes,
    );
  }

  ({List<int> nextValues, List<int> nextNotes})? _editBoard(
    int cell,
    int digit, {
    required bool pencil,
    required bool cleanNotes,
  }) {
    final nextValues = [...values], nextNotes = [...notes];
    if (pencil && digit != 0) {
      if (values[cell] != 0) return null;
      nextNotes[cell] ^= 1 << digit;
      return (nextValues: nextValues, nextNotes: nextNotes);
    }

    nextValues[cell] = digit;
    nextNotes[cell] = 0;
    if (cleanNotes && digit != 0) {
      _removePeerNotes(nextNotes, cell, digit);
    }
    _completeFinalDigit(
      previousValues: values,
      values: nextValues,
      notes: nextNotes,
      enteredCell: cell,
      enteredDigit: digit,
      cleanNotes: cleanNotes,
    );
    return (nextValues: nextValues, nextNotes: nextNotes);
  }

  void _removePeerNotes(List<int> notes, int cell, int digit) {
    for (final peer in peers(cell)) {
      notes[peer] &= ~(1 << digit);
    }
  }

  void _completeFinalDigit({
    required List<int> previousValues,
    required List<int> values,
    required List<int> notes,
    required int enteredCell,
    required int enteredDigit,
    required bool cleanNotes,
  }) {
    if (enteredDigit == 0 ||
        values[enteredCell] == previousValues[enteredCell]) {
      return;
    }
    final emptyCells = [
      for (var index = 0; index < sudokuCellCount; index++)
        if (values[index] == 0) index,
    ];
    if (emptyCells.isEmpty ||
        emptyCells.any(
          (cell) => puzzle.solution[cell] != puzzle.solution[emptyCells.first],
        ) ||
        List.generate(
          sudokuCellCount,
          (index) =>
              values[index] == 0 || values[index] == puzzle.solution[index],
        ).any((matches) => !matches)) {
      return;
    }

    final finalDigit = puzzle.solution[emptyCells.first];
    for (final emptyCell in emptyCells) {
      values[emptyCell] = finalDigit;
      notes[emptyCell] = 0;
      if (cleanNotes) _removePeerNotes(notes, emptyCell, finalDigit);
    }
  }

  List<CellEdit> _changesTo(List<int> nextValues, List<int> nextNotes) => [
    for (var cell = 0; cell < sudokuCellCount; cell++)
      if (nextValues[cell] != values[cell] || nextNotes[cell] != notes[cell])
        CellEdit(
          cell,
          values[cell],
          nextValues[cell],
          notes[cell],
          nextNotes[cell],
        ),
  ];

  ({Set<int> cells, Set<int> units, int mistakes}) _scoreEdit(
    int cell,
    int digit, {
    required bool pencil,
    required List<CellEdit> changes,
    required List<int> nextValues,
  }) {
    final cells = {...awardedCells};
    final units = {...awardedUnits};
    if (pencil || digit == 0) {
      return (cells: cells, units: units, mistakes: mistakes);
    }
    if (digit != puzzle.solution[cell]) {
      return (cells: cells, units: units, mistakes: mistakes + 1);
    }

    final candidateUnits = <int>{};
    for (final edit in changes) {
      if (edit.beforeValue == edit.afterValue ||
          edit.afterValue != puzzle.solution[edit.cell]) {
        continue;
      }
      cells.add(edit.cell);
      candidateUnits.addAll(
        SudokuUnit.containing(edit.cell).map((unit) => unit.id),
      );
    }
    for (final unit in candidateUnits) {
      if (_unitIsCorrect(nextValues, unit)) units.add(unit);
    }
    return (cells: cells, units: units, mistakes: mistakes);
  }

  bool _unitIsCorrect(List<int> board, int unit) {
    for (final cell in SudokuUnit.fromId(unit).cells) {
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
        notes = readCells(json['notes'], max: sudokuCandidateMask);
    final history = (json['history'] as List<Object?>)
        .map((move) => (move as List<Object?>).map(CellEdit.fromJson).toList())
        .toList();
    final cursor = json['cursor'] as int,
        seconds = json['elapsedSeconds'] as int,
        mistakes = json['mistakes'] as int;
    final awardedCells = _readUniqueIndexes(
      json['awardedCells'],
      sudokuCellCount,
    );
    final awardedUnits = _readUniqueIndexes(
      json['awardedUnits'],
      sudokuUnitCount,
    );
    if (cursor < 0 ||
        cursor > history.length ||
        seconds < 0 ||
        mistakes < 0 ||
        awardedCells.any((cell) => puzzle.givens[cell] != 0)) {
      throw const FormatException('Invalid session');
    }
    // Replay all moves to verify both undo/redo and the saved board agree.
    final replay = [...puzzle.givens],
        replayNotes = List.filled(sudokuCellCount, 0);
    void verifyBoard() {
      for (var i = 0; i < sudokuCellCount; i++) {
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
