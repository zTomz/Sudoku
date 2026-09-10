import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rudi_ui/rudi_ui.dart';
import 'package:sudoku/app/app_theme.dart';
import 'package:sudoku/features/settings/domain/app_settings.dart';

void main() {
  test('dark theme inherits the Rudi surface palette', () {
    final sudoku = sudokuTheme(Brightness.dark, const AppSettings());
    final rudi = RudiThemeData.dark(accent: sudoku.colors.accent);

    expect(sudoku.colors.background, rudi.colors.background);
    expect(sudoku.colors.foreground, rudi.colors.foreground);
    expect(sudoku.colors.surface, rudi.colors.surface);
    expect(sudoku.colors.surfaceContainer, rudi.colors.surfaceContainer);
    expect(sudoku.colors.primary, rudi.colors.primary);
    expect(sudoku.colors.onPrimary, rudi.colors.onPrimary);
  });
}
