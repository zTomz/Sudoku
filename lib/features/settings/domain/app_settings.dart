enum AppLanguage() {
  system,
  en,
  de,
}

enum AppAppearance() {
  system,
  light,
  dark,
}

enum ErrorCheck() {
  off,
  conflicts,
  solution,
}

enum BoardTheme() {
  classic,
  paper,
  mist,
  midnight,
}

final class const AppSettings({
  final AppLanguage language = AppLanguage.system,
  final AppAppearance appearance = AppAppearance.system,
  final ErrorCheck errorCheck = ErrorCheck.solution,
  final BoardTheme boardTheme = BoardTheme.classic,
  final bool showTimer = true,
  final bool cleanNotes = true,
  final bool autoFillEnding = true,
  final bool haptics = true,
  final bool numberFirst = false,
}) {
  AppSettings copyWith({
    AppLanguage? language,
    AppAppearance? appearance,
    ErrorCheck? errorCheck,
    BoardTheme? boardTheme,
    bool? showTimer,
    bool? cleanNotes,
    bool? autoFillEnding,
    bool? haptics,
    bool? numberFirst,
  }) => AppSettings(
    language: language ?? this.language,
    appearance: appearance ?? this.appearance,
    errorCheck: errorCheck ?? this.errorCheck,
    boardTheme: boardTheme ?? this.boardTheme,
    showTimer: showTimer ?? this.showTimer,
    cleanNotes: cleanNotes ?? this.cleanNotes,
    autoFillEnding: autoFillEnding ?? this.autoFillEnding,
    haptics: haptics ?? this.haptics,
    numberFirst: numberFirst ?? this.numberFirst,
  );
  Map<String, Object?> toJson() => {
    'language': language.name,
    'appearance': appearance.name,
    'errorCheck': errorCheck.name,
    'boardTheme': boardTheme.name,
    'showTimer': showTimer,
    'cleanNotes': cleanNotes,
    'autoFillEnding': autoFillEnding,
    'haptics': haptics,
    'numberFirst': numberFirst,
  };
  factory fromJson(Map<String, Object?> json) => AppSettings(
    language: json.containsKey('language')
        ? AppLanguage.values.byName(json['language'] as String)
        : AppLanguage.system,
    appearance: AppAppearance.values.byName(json['appearance'] as String),
    errorCheck: ErrorCheck.values.byName(json['errorCheck'] as String),
    boardTheme: BoardTheme.values.byName(json['boardTheme'] as String),
    showTimer: json['showTimer'] as bool,
    cleanNotes: json['cleanNotes'] as bool,
    autoFillEnding: json['autoFillEnding'] as bool? ?? true,
    haptics: json['haptics'] as bool,
    numberFirst: json['numberFirst'] as bool,
  );
}
