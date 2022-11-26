import 'package:flutter/material.dart';
import 'package:sudoku/colors.dart';

class DividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final space = size.width / 9;
    final paint = Paint()..color = kBlack..strokeWidth = 2.5..strokeCap = StrokeCap.round;

    for (int x = 0; x <= 9; x++) {
      canvas.drawLine(
        Offset(space * x, 0),
        Offset(space * x, size.height),
        paint,
      );
    }

    for (int y = 0; y <= 9; y++) {
      canvas.drawLine(
        Offset(0, space * y),
        Offset(size.width, space * y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DividerPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(DividerPainter oldDelegate) => false;
}
