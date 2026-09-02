import 'dart:async';

final class GameClock({
  required final void Function(int elapsedSeconds) onTick,
  required final void Function() onAutosave,
}) {
  static const _autosaveIntervalSeconds = 15;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  var _baseSeconds = 0;
  var _nextAutosaveElapsedSeconds = _autosaveIntervalSeconds;

  bool get isRunning => _stopwatch.isRunning;

  void start(int elapsedSeconds) {
    if (isRunning) return;
    _baseSeconds = elapsedSeconds;
    _nextAutosaveElapsedSeconds = _autosaveIntervalSeconds;
    _stopwatch
      ..reset()
      ..start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _publishElapsed();
      if (_stopwatch.elapsed.inSeconds >= _nextAutosaveElapsedSeconds) {
        do {
          _nextAutosaveElapsedSeconds += _autosaveIntervalSeconds;
        } while (_stopwatch.elapsed.inSeconds >= _nextAutosaveElapsedSeconds);
        onAutosave();
      }
    });
  }

  void stop() {
    _publishElapsed();
    _stopwatch.stop();
    _ticker?.cancel();
    _ticker = null;
  }

  void capture() => _publishElapsed();

  void dispose() {
    _ticker?.cancel();
    _ticker = null;
    _stopwatch.stop();
  }

  void _publishElapsed() {
    if (isRunning) {
      onTick(_baseSeconds + _stopwatch.elapsed.inSeconds);
    }
  }
}
