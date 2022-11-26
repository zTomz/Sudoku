import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/models/field.dart';
import 'package:sudoku/provider/game_field_notifier.dart';

final gameFieldsProvider = StateNotifierProvider<GameFieldNotifier, List<Field>>((ref) => GameFieldNotifier());

final selectedFieldProvider = StateProvider<Field?>((ref) => null);
