const sudokuSideLength = 9;
const sudokuBoxSideLength = 3;
const sudokuCellCount = sudokuSideLength * sudokuSideLength;
const sudokuUnitCount = sudokuSideLength * 3;
const sudokuCandidateMask = (1 << (sudokuSideLength + 1)) - 2;

enum SudokuDirection() {
  left,
  right,
  up,
  down,
}

enum SudokuUnitType() {
  row,
  column,
  box,
}

int rowOf(int cell) => cell ~/ sudokuSideLength;
int columnOf(int cell) => cell % sudokuSideLength;
int boxOf(int cell) =>
    rowOf(cell) ~/ sudokuBoxSideLength * sudokuBoxSideLength +
    columnOf(cell) ~/ sudokuBoxSideLength;
int cellAt(int row, int column) => row * sudokuSideLength + column;
bool cellsShareUnit(int first, int second) =>
    rowOf(first) == rowOf(second) ||
    columnOf(first) == columnOf(second) ||
    boxOf(first) == boxOf(second);

final class const SudokuUnit(final SudokuUnitType type, final int index) {
  int get id => type.index * sudokuSideLength + index;

  Iterable<int> get cells sync* {
    for (var offset = 0; offset < sudokuSideLength; offset++) {
      yield switch (type) {
        SudokuUnitType.row => cellAt(index, offset),
        SudokuUnitType.column => cellAt(offset, index),
        SudokuUnitType.box => cellAt(
          index ~/ sudokuBoxSideLength * sudokuBoxSideLength +
              offset ~/ sudokuBoxSideLength,
          index % sudokuBoxSideLength * sudokuBoxSideLength +
              offset % sudokuBoxSideLength,
        ),
      };
    }
  }

  factory fromId(int id) {
    if (id < 0 || id >= sudokuUnitCount) {
      throw RangeError.range(id, 0, sudokuUnitCount - 1, 'id');
    }
    return .new(
      SudokuUnitType.values[id ~/ sudokuSideLength],
      id % sudokuSideLength,
    );
  }

  static List<SudokuUnit> containing(int cell) => [
    SudokuUnit(SudokuUnitType.row, rowOf(cell)),
    SudokuUnit(SudokuUnitType.column, columnOf(cell)),
    SudokuUnit(SudokuUnitType.box, boxOf(cell)),
  ];
}

int adjacentCell(int cell, SudokuDirection direction) {
  if (cell < 0 || cell >= sudokuCellCount) {
    throw RangeError.range(cell, 0, sudokuCellCount - 1, 'cell');
  }
  final row = rowOf(cell);
  final column = columnOf(cell);
  return switch (direction) {
    SudokuDirection.left when column > 0 => cell - 1,
    SudokuDirection.right when column < sudokuSideLength - 1 => cell + 1,
    SudokuDirection.up when row > 0 => cell - sudokuSideLength,
    SudokuDirection.down when row < sudokuSideLength - 1 =>
      cell + sudokuSideLength,
    _ => cell,
  };
}

Iterable<int> peers(int cell) sync* {
  final row = rowOf(cell);
  final column = columnOf(cell);
  final box = boxOf(cell);
  for (var candidate = 0; candidate < sudokuCellCount; candidate++) {
    if (candidate != cell &&
        (rowOf(candidate) == row ||
            columnOf(candidate) == column ||
            boxOf(candidate) == box)) {
      yield candidate;
    }
  }
}
