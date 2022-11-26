class Field {
  final int x;
  final int y;
  int? number;
  bool canEdit = true;

  Field({
    required this.x,
    required this.y,
  });

  void toggleNumber(int newNumber) {
    number = newNumber;
  }

  @override
  String toString() {
    return "Field: x = $x, y = $y, number = $number, can edit = $canEdit";
  }
}
