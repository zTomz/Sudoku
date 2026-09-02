import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/features/game/data/game_providers.dart';
import 'package:sudoku/app/sudoku_controller.dart';
import 'package:sudoku/features/game/data/game_repository.dart';
import 'package:sudoku/features/game/data/puzzle_generator.dart';

final class ControllerHarness(
  GameRepository repository, {
  PuzzleGenerator? generator,
}) {
  this
    : container = ProviderContainer(
        overrides: [
          gameRepositoryProvider.overrideWithValue(repository),
          if (generator != null)
            puzzleGeneratorProvider.overrideWithValue(generator),
        ],
      );
  final ProviderContainer container;
  SudokuController get controller =>
      container.read(sudokuControllerProvider.notifier);
  void dispose() => container.dispose();
}
