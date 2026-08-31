import 'dart:async';

import 'package:flutter/foundation.dart';

import '../features/game/data/game_repository.dart';
import '../features/game/domain/game_session.dart';
import '../features/game/domain/puzzle.dart';
import '../features/game/domain/sudoku_engine.dart';
import '../features/settings/domain/app_settings.dart';

final class SudokuController(
  final GameRepository repository, {
  SudokuEngine? engine,
}) extends ChangeNotifier {
  this : _engine = engine ?? SudokuEngine();
  final SudokuEngine _engine;
  SavedGames _saved = SavedGames();
  GameSession? _game;
  Timer? _ticker;
  final Stopwatch _clock = Stopwatch();
  int _baseSeconds = 0;
  int _saveRevision = 0;
  bool _disposed = false;
  bool ready = false;
  bool loadFailed = false;
  bool saveFailed = false;
  bool generationFailed = false;
  bool busy = false;
  bool playing = false;
  bool paused = false;
  bool pencil = false;
  int selected = -1;
  int selectedDigit = 0;

  AppSettings get settings => _saved.settings;
  GameSession? get game => _game;
  GameSession? get free => _saved.free;
  Map<String, GameSession> get dailyGames => _saved.daily;
  Iterable<GameResult> get results => _saved.results.values;

  Future<void> initialize() async {
    if (busy || _disposed) return;
    busy = true;
    loadFailed = false;
    _notify();
    try {
      final loaded = await repository.load();
      if (_disposed) return;
      _saved = loaded;
      ready = true;
    } catch (_) {
      if (!_disposed) loadFailed = true;
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> startFree(Difficulty difficulty) => _generate(
    () => _engine.generate(
      seed: DateTime.now().microsecondsSinceEpoch % 2147483646,
      difficulty: difficulty,
    ),
  );

  Future<void> startDaily(DateTime day) async {
    if (busy || !ready || _disposed) return;
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
    await _generate(() => _engine.daily(day));
  }

  Future<void> _generate(Future<Puzzle> Function() create) async {
    if (busy || !ready || _disposed) return;
    busy = true;
    generationFailed = false;
    _notify();
    try {
      final puzzle = await create();
      if (_disposed) return;
      _open(GameSession.start(puzzle));
      await persist();
    } catch (_) {
      if (!_disposed) generationFailed = true;
    } finally {
      busy = false;
      _notify();
    }
  }

  void resumeFree() {
    if (free case final saved?) _open(saved);
  }

  void _open(GameSession session) {
    _stopClock();
    _game = session;
    playing = true;
    paused = false;
    pencil = false;
    selected = session.values.indexOf(0);
    selectedDigit = 0;
    _remember();
    _startClock();
    _notify();
  }

  void selectCell(int cell) {
    if (!playing || paused || cell < 0 || cell >= 81) return;
    selected = cell;
    if (settings.numberFirst && selectedDigit != 0) {
      enter(selectedDigit);
    } else {
      _notify();
    }
  }

  void moveSelection(int cell) {
    if (!playing || paused || cell < 0 || cell >= 81) return;
    selected = cell;
    _notify();
  }

  void chooseDigit(int digit) {
    if (!playing || paused) return;
    if (settings.numberFirst) {
      selectedDigit = digit;
      _notify();
    } else {
      enter(digit);
    }
  }

  void enter(int digit) {
    if (!playing || paused || _game == null) return;
    final next = _game!.enter(
      selected,
      digit,
      pencil: pencil,
      cleanNotes: settings.cleanNotes,
    );
    if (identical(next, _game)) return;
    _game = next;
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
    pencil = !pencil;
    _notify();
  }

  void _afterMove() {
    _captureTime();
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
          ),
        },
      );
    }
    _remember();
    _notify();
    unawaited(persist());
  }

  void leaveGame() {
    _stopClock();
    playing = false;
    paused = false;
    _remember();
    _notify();
    unawaited(persist());
  }

  void togglePause() {
    if (!playing || _game?.complete != false) return;
    if (paused) {
      paused = false;
      _startClock();
    } else {
      _stopClock();
      paused = true;
    }
    _notify();
    unawaited(persist());
  }

  void suspend() {
    if (playing && !paused && _game?.complete == false) {
      _stopClock();
      paused = true;
      _notify();
    }
    if (ready) unawaited(persist());
  }

  void changeSettings(AppSettings value) {
    _saved = SavedGames(
      settings: value,
      free: free,
      daily: dailyGames,
      results: _saved.results,
    );
    selectedDigit = 0;
    _notify();
    unawaited(persist());
  }

  void _startClock() {
    if (_game == null || _game!.complete) return;
    _baseSeconds = _game!.elapsedSeconds;
    _clock
      ..reset()
      ..start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _captureTime();
      _notify();
      if (_clock.elapsed.inSeconds % 15 == 0) unawaited(persist());
    });
  }

  void _captureTime() {
    if (_game != null && _clock.isRunning) {
      _game = _game!.withElapsed(_baseSeconds + _clock.elapsed.inSeconds);
    }
  }

  void _stopClock() {
    _captureTime();
    _clock.stop();
    _ticker?.cancel();
    _ticker = null;
    _remember();
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
    if (!ready || _disposed) return;
    _remember();
    final revision = ++_saveRevision;
    try {
      await repository.save(_saved);
      if (!_disposed && revision == _saveRevision && saveFailed) {
        saveFailed = false;
        _notify();
      }
    } catch (_) {
      if (!_disposed && revision == _saveRevision) {
        saveFailed = true;
        _notify();
      }
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker?.cancel();
    _clock.stop();
    super.dispose();
  }
}
