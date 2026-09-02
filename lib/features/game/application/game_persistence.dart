import '../data/game_repository.dart';

final class GamePersistence(final GameRepository repository) {
  var _revision = 0;
  var _disposed = false;

  Future<bool?> save(SavedGames snapshot) async {
    if (_disposed) return null;
    final revision = ++_revision;
    try {
      await repository.save(snapshot);
      return !_disposed && revision == _revision ? true : null;
    } catch (_) {
      return !_disposed && revision == _revision ? false : null;
    }
  }

  void dispose() => _disposed = true;
}
