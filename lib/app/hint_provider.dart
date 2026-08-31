import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/game/domain/game_hint.dart';
import 'sudoku_controller.dart';

part 'hint_provider.g.dart';

@riverpod
GameHint? gameHint(Ref ref) {
  // Timer ticks and note edits do not invalidate the logical board.
  ref.watch(
    sudokuControllerProvider.select(
      (s) => (s.game?.puzzle.id, s.game?.values.join(',')),
    ),
  );
  final game = ref.read(sudokuControllerProvider).game;
  return game == null ? null : GameHint.forGame(game);
}
