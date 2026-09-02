import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../settings/domain/app_settings.dart';
import '../domain/game_session.dart';
import '../domain/puzzle.dart';

abstract interface class SnapshotStore() {
  Future<String?> read();
  Future<void> write(String value);
}

final class PreferencesSnapshotStore(final SharedPreferencesAsync preferences)
    implements SnapshotStore {
  static const key = 'sudoku.snapshot.v1';
  @override
  Future<String?> read() => preferences.getString(key);
  @override
  Future<void> write(String value) => preferences.setString(key, value);
}

final class const GameResult(
  final String id,
  final Difficulty difficulty,
  final int seconds,
  final String? dailyDate,
  final int points,
  final int mistakes,
) {
  Map<String, Object?> toJson() => {
    'id': id,
    'difficulty': difficulty.name,
    'seconds': seconds,
    'dailyDate': dailyDate,
    'points': points,
    'mistakes': mistakes,
  };
  factory fromJson(Map<String, Object?> json) {
    final seconds = json['seconds'] as int;
    final points = json['points'] as int, mistakes = json['mistakes'] as int;
    if (seconds < 0 || points < 0 || mistakes < 0) {
      throw const FormatException('Invalid result');
    }
    return GameResult(
      json['id'] as String,
      Difficulty.values.byName(json['difficulty'] as String),
      seconds,
      json['dailyDate'] as String?,
      points,
      mistakes,
    );
  }
}

final class SavedGames({
  final AppSettings settings = const AppSettings(),
  final GameSession? free,
  Map<String, GameSession> daily = const {},
  Map<String, GameResult> results = const {},
}) {
  this
    : daily = Map.unmodifiableOf(daily), results = Map.unmodifiableOf(results);
  final Map<String, GameSession> daily;
  final Map<String, GameResult> results;

  String encode() => jsonEncode({
    'schemaVersion': 2,
    'settings': settings.toJson(),
    'free': free?.toJson(),
    'daily': daily.map((key, value) => MapEntry(key, value.toJson())),
    'results': results.map((key, value) => MapEntry(key, value.toJson())),
  });

  factory decode(String value) {
    final json = jsonDecode(value) as Map<String, Object?>;
    if (json['schemaVersion'] != 2) {
      throw const FormatException('Unsupported save version');
    }
    final daily = (json['daily'] as Map<String, Object?>).map((key, value) {
      final session = GameSession.fromJson(value as Map<String, Object?>);
      if (session.puzzle.dailyDate != key) {
        throw const FormatException('Invalid daily date');
      }
      return MapEntry(key, session);
    });
    final results = (json['results'] as Map<String, Object?>).map((key, value) {
      final result = GameResult.fromJson(value as Map<String, Object?>);
      if (result.id != key) throw const FormatException('Invalid result ID');
      return MapEntry(key, result);
    });
    return SavedGames(
      settings: AppSettings.fromJson(json['settings'] as Map<String, Object?>),
      free: json['free'] == null
          ? null
          : GameSession.fromJson(json['free'] as Map<String, Object?>),
      daily: daily,
      results: results,
    );
  }
}

final class GameRepository(final SnapshotStore store) {
  Future<void> _pending = Future.value();
  Future<SavedGames> load() async {
    final raw = await store.read();
    return raw == null ? SavedGames() : SavedGames.decode(raw);
  }

  Future<void> save(SavedGames games) {
    final snapshot = games.encode();
    // Serialize writes. A failed write must not poison subsequent retries.
    final result = _pending.then((_) => store.write(snapshot));
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }
}
