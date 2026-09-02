import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game_repository.dart';
import 'puzzle_generator.dart';

part 'game_providers.g.dart';

@Riverpod(keepAlive: true)
GameRepository gameRepository(Ref ref) =>
    GameRepository(PreferencesSnapshotStore(SharedPreferencesAsync()));

@Riverpod(keepAlive: true)
PuzzleGenerator puzzleGenerator(Ref ref) => generatePuzzle;
