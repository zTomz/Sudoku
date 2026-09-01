import 'puzzle.dart';

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
}) {
  this
    : values = List.unmodifiableOf(values),
      notes = List.unmodifiableOf(notes),
      history = List.unmodifiableOf(history.map(List<CellEdit>.unmodifiableOf));

  final List<int> values;
  final List<int> notes;
  final List<List<CellEdit>> history;

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
    return GameSession(
      puzzle: puzzle,
      values: nextValues,
      notes: nextNotes,
      history: [...history.take(cursor), changes],
      cursor: cursor + 1,
      elapsedSeconds: elapsedSeconds,
    );
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
    );
  }

  GameSession withElapsed(int seconds) => GameSession(
    puzzle: puzzle,
    values: values,
    notes: notes,
    history: history,
    cursor: cursor,
    elapsedSeconds: seconds,
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
  };

  factory fromJson(Map<String, Object?> json) {
    final puzzle = Puzzle.fromJson(json['puzzle'] as Map<String, Object?>);
    final values = readCells(json['values']),
        notes = readCells(json['notes'], max: 1022);
    final history = (json['history'] as List<Object?>)
        .map((move) => (move as List<Object?>).map(CellEdit.fromJson).toList())
        .toList();
    final cursor = json['cursor'] as int,
        seconds = json['elapsedSeconds'] as int;
    if (cursor < 0 || cursor > history.length || seconds < 0) {
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
    );
  }
}
