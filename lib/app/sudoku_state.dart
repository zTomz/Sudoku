import '../features/game/data/game_repository.dart';
import '../features/game/domain/game_session.dart';

final class SudokuState({
  required final SavedGames saved,
  final GameSession? game,
  final bool ready = false,
  final bool loadFailed = false,
  final bool saveFailed = false,
  final bool generationFailed = false,
  final bool busy = false,
  final bool playing = false,
  final bool paused = false,
  final bool pencil = false,
  final int selected = -1,
  final int selectedDigit = 0,
}) {
  SudokuState copyWith({
    SavedGames? saved,
    GameSession? game,
    bool? ready,
    bool? loadFailed,
    bool? saveFailed,
    bool? generationFailed,
    bool? busy,
    bool? playing,
    bool? paused,
    bool? pencil,
    int? selected,
    int? selectedDigit,
  }) => SudokuState(
    saved: saved ?? this.saved,
    game: game ?? this.game,
    ready: ready ?? this.ready,
    loadFailed: loadFailed ?? this.loadFailed,
    saveFailed: saveFailed ?? this.saveFailed,
    generationFailed: generationFailed ?? this.generationFailed,
    busy: busy ?? this.busy,
    playing: playing ?? this.playing,
    paused: paused ?? this.paused,
    pencil: pencil ?? this.pencil,
    selected: selected ?? this.selected,
    selectedDigit: selectedDigit ?? this.selectedDigit,
  );
}
