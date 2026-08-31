import 'package:flutter/widgets.dart';

import '../../settings/domain/app_settings.dart';
import '../../../common/presentation/app_colors.dart';

final class const BoardPalette({
  required final Color background,
  required final Color ink,
  required final Color note,
  required final Color thinLine,
  required final Color blockLine,
  required final Color accent,
  required final Color related,
  required final Color same,
  required final Color selected,
}) {
  Color get onSelected => selected.computeLuminance() > .179
      ? const Color(0xff101820)
      : const Color(0xffffffff);

  static BoardPalette resolve(
    BoardTheme theme,
    Brightness brightness, {
    bool highContrast = false,
    Color? accentColor,
  }) {
    final dark =
        theme == BoardTheme.midnight ||
        (theme == BoardTheme.classic && brightness == Brightness.dark);
    final background = switch (theme) {
      BoardTheme.paper => const Color(0xfffff8e8),
      BoardTheme.mist => const Color(0xffedf4fc),
      _ => dark ? const Color(0xff192433) : const Color(0xffffffff),
    };
    final accent = accentColor ?? sudokuAccent(brightness);
    return BoardPalette(
      background: background,
      ink: dark ? const Color(0xffeef3fb) : const Color(0xff182536),
      note: dark ? const Color(0xffbdcce0) : const Color(0xff52647b),
      thinLine: dark ? const Color(0xff46586f) : const Color(0xffbecbdc),
      blockLine: highContrast
          ? (dark ? const Color(0xffffffff) : const Color(0xff000000))
          : dark
          ? const Color(0xffa1b2c9)
          : const Color(0xff4a596e),
      accent: accent,
      related: Color.alphaBlend(
        accent.withValues(alpha: dark ? .09 : .07),
        background,
      ),
      same: Color.alphaBlend(
        accent.withValues(alpha: dark ? .22 : .17),
        background,
      ),
      selected: accent,
    );
  }
}

/// A single foreground layer keeps every grid line above all cell highlights.
final class SudokuGridPainter({
  required final BoardPalette palette,
  required final double pixelRatio,
  final int selected = -1,
  final bool highContrast = false,
}) extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final thick = highContrast ? 2.5 : 1.7;
    final thin = highContrast ? 1.0 : .65;
    double snap(double value) =>
        (value * pixelRatio).roundToDouble() / pixelRatio;
    if (selected >= 0) {
      final rect = Rect.fromLTWH(
        selected % 9 * size.width / 9,
        selected ~/ 9 * size.height / 9,
        size.width / 9,
        size.height / 9,
      ).deflate(2.5);
      canvas.drawRect(
        rect,
        Paint()
          ..color = palette.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3,
      );
    }
    for (var i = 1; i < 9; i++) {
      final major = i % 3 == 0;
      final paint = Paint()
        ..color = major ? palette.blockLine : palette.thinLine
        ..strokeWidth = major ? thick : thin;
      final x = snap(i * size.width / 9), y = snap(i * size.height / 9);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = palette.blockLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = thick * 2,
    );
  }

  @override
  bool shouldRepaint(SudokuGridPainter oldDelegate) =>
      oldDelegate.palette != palette ||
      oldDelegate.selected != selected ||
      oldDelegate.pixelRatio != pixelRatio ||
      oldDelegate.highContrast != highContrast;
}
