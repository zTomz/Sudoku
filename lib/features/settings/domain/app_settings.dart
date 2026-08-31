enum AppAppearance() {
  system,
  light,
  dark
}

enum ErrorCheck() {
  off,
  conflicts,
  solution
}

enum BoardTheme() {
  classic,
  paper,
  mist,
  midnight
}

final class const AppSettings({
  final AppAppearance appearance = AppAppearance.system,
  final ErrorCheck errorCheck = ErrorCheck.conflicts,
  final BoardTheme boardTheme = BoardTheme.classic,
  final bool showTimer = true,
  final bool cleanNotes = true,
  final bool haptics = true,
  final bool numberFirst = false,
}) {
  AppSettings copyWith({
    AppAppearance? appearance,
    ErrorCheck? errorCheck,
    BoardTheme? boardTheme,
    bool? showTimer,
    bool? cleanNotes,
    bool? haptics,
    bool? numberFirst,
  }) => AppSettings(
    appearance: appearance ?? this.appearance,
    errorCheck: errorCheck ?? this.errorCheck,
    boardTheme: boardTheme ?? this.boardTheme,
    showTimer: showTimer ?? this.showTimer,
    cleanNotes: cleanNotes ?? this.cleanNotes,
    haptics: haptics ?? this.haptics,
    numberFirst: numberFirst ?? this.numberFirst,
  );
  Map<String, Object?> toJson() => {
    'appearance': appearance.name,
    'errorCheck': errorCheck.name,
    'boardTheme': boardTheme.name,
    'showTimer': showTimer,
    'cleanNotes': cleanNotes,
    'haptics': haptics,
    'numberFirst': numberFirst,
  };
  factory fromJson(Map<String, Object?> json) => AppSettings(
    appearance: AppAppearance.values.byName(json['appearance'] as String),
    errorCheck: ErrorCheck.values.byName(json['errorCheck'] as String),
    // Version 0.1 saves did not contain a board theme.
    boardTheme: BoardTheme.values.byName(
      json['boardTheme'] as String? ?? 'classic',
    ),
    showTimer: json['showTimer'] as bool,
    cleanNotes: json['cleanNotes'] as bool,
    haptics: json['haptics'] as bool,
    numberFirst: json['numberFirst'] as bool,
  );
}
