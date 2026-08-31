import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/game/data/game_repository.dart';
import '../features/game/data/puzzle_generator.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
GameRepository gameRepository(Ref ref) =>
    GameRepository(PreferencesSnapshotStore(SharedPreferencesAsync()));

@Riverpod(keepAlive: true)
PuzzleGenerator puzzleGenerator(Ref ref) => generatePuzzle;
