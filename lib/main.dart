import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/sudoku_app.dart';
import 'app/sudoku_controller.dart';
import 'features/game/data/game_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  final repository = GameRepository(
    PreferencesSnapshotStore(SharedPreferencesAsync()),
  );
  runApp(SudokuApp(controller: SudokuController(repository)));
}
