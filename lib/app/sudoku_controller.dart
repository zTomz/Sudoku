import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'sudoku_state.dart';

import '../features/game/application/game_clock.dart';
import '../features/game/application/game_persistence.dart';
import '../features/game/data/game_repository.dart';
import '../features/game/data/game_providers.dart';
import '../features/game/data/puzzle_generator.dart';
import '../features/game/domain/game_session.dart';
import '../features/game/domain/puzzle.dart';
import '../features/settings/domain/app_settings.dart';

part 'sudoku_controller.g.dart';

@Riverpod(keepAlive: true)
class SudokuController() extends _$SudokuController {
  late GameRepository _repository;
  late PuzzleGenerator _generator;
  late GameClock _clock;
  late GamePersistence _persistence;
  GenerationJob? _generation;

  @override
  SudokuState build() {
    _repository = ref.read(gameRepositoryProvider);
    _generator = ref.read(puzzleGeneratorProvider);
    _persistence = GamePersistence(_repository);
    _clock = GameClock(
      onTick: _updateElapsed,
      onAutosave: () => unawaited(persist()),
    );
    ref.onDispose(() {
      _disposed = true;
      _clock.dispose();
      _persistence.dispose();
      _generation?.cancel();
    });
    return SudokuState(saved: SavedGames());
  }

  SavedGames get _saved => state.saved;
  set _saved(SavedGames value) => state = state.copyWith(saved: value);
  GameSession? get _game => state.game;
  set _game(GameSession? value) => state = value == null
      ? state.copyWith(clearGame: true)
      : state.copyWith(game: value);
  bool _disposed = false;
  bool _suspended = false;
  bool get ready => state.ready;
  set _ready(bool value) => state = state.copyWith(ready: value);
  bool get loadFailed => state.loadFailed;
  set _loadFailed(bool value) => state = state.copyWith(loadFailed: value);
  bool get saveFailed => state.saveFailed;
  set _saveFailed(bool value) => state = state.copyWith(saveFailed: value);
  bool get generationFailed => state.generationFailed;
  set _generationFailed(bool value) =>
      state = state.copyWith(generationFailed: value);
  bool get busy => state.busy;
  set _busy(bool value) => state = state.copyWith(busy: value);
  bool get playing => state.playing;
  set _playing(bool value) => state = state.copyWith(playing: value);
  bool get paused => state.paused;
  set _paused(bool value) => state = state.copyWith(paused: value);
  bool get pencil => state.pencil;
  set _pencil(bool value) => state = state.copyWith(pencil: value);
  int get selected => state.selected;
  set _selected(int value) => state = state.copyWith(selected: value);
  int get selectedDigit => state.selectedDigit;
  set _selectedDigit(int value) => state = state.copyWith(selectedDigit: value);

  AppSettings get settings => _saved.settings;
  GameSession? get game => _game;
  GameSession? get free => _saved.free;
  Map<String, GameSession> get dailyGames => _saved.daily;
  Iterable<GameResult> get results => _saved.results.values;
  int get totalPoints =>
      results.fold(0, (total, result) => total + result.points);
  int get scoreAwardSequence => state.scoreAwardSequence;
  int get scoreAwardPoints => state.scoreAwardPoints;
  int get scoreAwardCell => state.scoreAwardCell;

  Future<void> initialize() async {
    if (_disposed || busy || ready) return;
    _busy = true;
    _loadFailed = false;
    try {
      final loaded = await _repository.load();
      if (_disposed) return;
      _saved = loaded;
      _ready = true;
    } catch (_) {
      if (!_disposed) _loadFailed = true;
    } finally {
      if (!_disposed) _busy = false;
    }
  }

  Future<void> startFree(Difficulty difficulty) => _generate(
    GenerationRequest(
      seed: DateTime.now().microsecondsSinceEpoch % 2147483646,
      difficulty: difficulty,
    ),
  );

  Future<void> startDaily(DateTime day) async {
    if (_disposed || busy || !ready) return;
    final today = DateTime.now();
    if (DateTime(
      day.year,
      day.month,
      day.day,
    ).isAfter(DateTime(today.year, today.month, today.day))) {
      return;
    }
    if (_saved.daily[dateKey(day)] case final existing?) {
      _open(existing);
      return;
    }
    await _generate(
      GenerationRequest(
        seed: day.year * 10000 + day.month * 100 + day.day,
        difficulty: Difficulty.medium,
        dailyDate: dateKey(day),
      ),
    );
  }

  Future<void> _generate(GenerationRequest request) async {
    if (_disposed || busy || !ready) return;
    _busy = true;
    _generationFailed = false;
    try {
      _generation = _generator(request);
      final puzzle = await _generation!.result;
      if (_disposed) return;
      _open(GameSession.start(puzzle));
      await persist();
    } catch (_) {
      if (!_disposed) _generationFailed = true;
    } finally {
      _generation = null;
      if (!_disposed) _busy = false;
    }
  }

  void resumeFree() {
    if (free case final saved?) _open(saved);
  }

  void _open(GameSession session) {
    _stopClock();
    _game = session;
    _playing = true;
    _paused = _suspended;
    _pencil = false;
    _selected = session.values.indexOf(0);
    _selectedDigit = 0;
    state = state.copyWith(scoreAwardPoints: 0, scoreAwardCell: -1);
    _remember();
    _startClock();
  }

  void selectCell(int cell) {
    if (!playing || paused || cell < 0 || cell >= sudokuCellCount) return;
    _selected = cell;
    if (settings.numberFirst && selectedDigit != 0) {
      enter(selectedDigit);
    }
  }

  void moveSelection(int cell) {
    if (!playing || paused || cell < 0 || cell >= sudokuCellCount) return;
    _selected = cell;
  }

  void chooseDigit(int digit) {
    if (!playing || paused || _game?.isDigitAvailable(digit) != true) return;
    if (settings.numberFirst) {
      _selectedDigit = digit;
    } else {
      enter(digit);
    }
  }

  void enter(int digit) {
    if (!playing || paused || _game == null) return;
    final previousPoints = _game!.points;
    final awardCell = selected;
    final next = _game!.enter(
      selected,
      digit,
      pencil: pencil,
      cleanNotes: settings.cleanNotes,
    );
    if (identical(next, _game)) return;
    _game = next;
    final awarded = next.points - previousPoints;
    if (awarded > 0) {
      state = state.copyWith(
        scoreAwardSequence: state.scoreAwardSequence + 1,
        scoreAwardPoints: awarded,
        scoreAwardCell: awardCell,
      );
    }
    _afterMove();
  }

  void undo() {
    if (!playing || paused || _game == null) return;
    _game = _game!.undo();
    _afterMove();
  }

  void redo() {
    if (!playing || paused || _game == null) return;
    _game = _game!.redo();
    _afterMove();
  }

  void togglePencil() {
    if (!playing || paused || _game?.complete != false) return;
    _pencil = !pencil;
  }

  void _afterMove() {
    if (selectedDigit != 0 && !_game!.isDigitAvailable(selectedDigit)) {
      _selectedDigit = 0;
    }
    _clock.capture();
    if (_game!.complete) {
      _stopClock();
      final g = _game!;
      _saved = SavedGames(
        settings: settings,
        free: free,
        daily: dailyGames,
        results: {
          ..._saved.results,
          g.puzzle.id: GameResult(
            g.puzzle.id,
            g.puzzle.difficulty,
            g.elapsedSeconds,
            g.puzzle.dailyDate,
            g.finalPoints,
            g.mistakes,
          ),
        },
      );
    }
    _remember();
    unawaited(persist());
  }

  void leaveGame() {
    _stopClock();
    _playing = false;
    _paused = false;
    _remember();
    _game = null;
    unawaited(persist());
  }

  void togglePause() {
    if (!playing || _game?.complete != false) return;
    if (paused) {
      _paused = false;
      _startClock();
    } else {
      _pause();
    }
    unawaited(persist());
  }

  void suspend() {
    _suspended = true;
    if (playing && !paused && _game?.complete == false) {
      _pause();
    }
    if (ready) unawaited(persist());
  }

  // Returning to the app does not resume a paused game implicitly.
  void activate() => _suspended = false;

  void changeSettings(AppSettings value) {
    _saved = SavedGames(
      settings: value,
      free: free,
      daily: dailyGames,
      results: _saved.results,
    );
    _selectedDigit = 0;
    unawaited(persist());
  }

  void _startClock() {
    if (_suspended || paused || _game == null || _game!.complete) return;
    _clock.start(_game!.elapsedSeconds);
  }

  void _updateElapsed(int elapsedSeconds) {
    if (_game != null) _game = _game!.withElapsed(elapsedSeconds);
  }

  void _stopClock() {
    _clock.stop();
    _remember();
  }

  void _pause() {
    _stopClock();
    state = state.copyWith(
      paused: true,
      scoreAwardPoints: 0,
      scoreAwardCell: -1,
    );
  }

  void _remember() {
    if (_game case final game?) {
      final day = game.puzzle.dailyDate;
      _saved = SavedGames(
        settings: settings,
        free: day == null ? game : free,
        daily: day == null ? dailyGames : {...dailyGames, day: game},
        results: _saved.results,
      );
    }
  }

  Future<void> persist() async {
    if (_disposed || !ready) return;
    _remember();
    final saved = await _persistence.save(_saved);
    if (saved == true && saveFailed) _saveFailed = false;
    if (saved == false) _saveFailed = true;
  }
}
