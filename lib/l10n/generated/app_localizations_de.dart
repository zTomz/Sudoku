// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Sudoku';

  @override
  String get tagline => 'Ein bisschen Raum zum Denken.';

  @override
  String get play => 'Start';

  @override
  String get daily => 'Täglich';

  @override
  String get statistics => 'Statistik';

  @override
  String get settings => 'Einstellungen';

  @override
  String get newGame => 'Neues Spiel';

  @override
  String get continueGame => 'Weiterspielen';

  @override
  String get difficulty => 'Schwierigkeit';

  @override
  String get easy => 'Leicht';

  @override
  String get medium => 'Mittel';

  @override
  String get hard => 'Schwer';

  @override
  String get difficultyNote =>
      'Die ersten Schwierigkeitsstufen basieren auf Vorgabenzahlen. Eine Bewertung nach Lösungsstrategien ist geplant.';

  @override
  String get dailyTitle => 'Dein Tagesrätsel';

  @override
  String get dailyDescription =>
      'Für alle dasselbe Rätsel. Jeden Tag ein neuer Anfang.';

  @override
  String get playDaily => 'Heutiges Rätsel spielen';

  @override
  String get dailyArchive => 'Tageskalender';

  @override
  String get calendarDescription =>
      'Einen Tag verpasst? Vergangene Rätsel bleiben spielbar.';

  @override
  String get freePlay => 'Freies Spiel';

  @override
  String get back => 'Zurück';

  @override
  String get close => 'Schließen';

  @override
  String get loading => 'Dein Rätsel wird vorbereitet …';

  @override
  String get loadFailed =>
      'Deine Spielstände konnten nicht geladen werden. Sie wurden nicht überschrieben.';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get saveFailed =>
      'Speichern fehlgeschlagen. Lass die App offen und versuche es erneut.';

  @override
  String get generationFailed =>
      'Das Rätsel konnte nicht erstellt werden. Bitte versuche es erneut.';

  @override
  String get undo => 'Zurück';

  @override
  String get redo => 'Vorwärts';

  @override
  String get erase => 'Löschen';

  @override
  String get notes => 'Notizen';

  @override
  String get notesOn => 'Notizen an';

  @override
  String get pause => 'Pause';

  @override
  String get paused => 'Pause';

  @override
  String get resume => 'Fortsetzen';

  @override
  String get pausedMessage => 'Lass dir Zeit. Dein Rätsel wartet auf dich.';

  @override
  String get finished => 'Gut gelöst.';

  @override
  String get finishedMessage => 'Ein weiteres Rätsel. In deinem Tempo gelöst.';

  @override
  String get backHome => 'Zur Startseite';

  @override
  String get timer => 'Spielzeit';

  @override
  String progress(int filled) {
    return '$filled / 81 ausgefüllt';
  }

  @override
  String get appearance => 'Darstellung';

  @override
  String get system => 'System';

  @override
  String get light => 'Hell';

  @override
  String get dark => 'Dunkel';

  @override
  String get gameSettings => 'Spiel';

  @override
  String get showTimer => 'Spielzeit anzeigen';

  @override
  String get showTimerDescription =>
      'Blende die Uhr aus und spiele in deinem Tempo.';

  @override
  String get cleanNotes => 'Notizen bereinigen';

  @override
  String get cleanNotesDescription =>
      'Entfernt gesetzte Zahlen aus Notizen in Zeile, Spalte und Block.';

  @override
  String get haptics => 'Haptisches Feedback';

  @override
  String get hapticsDescription =>
      'Ein dezentes Tippen auf unterstützten Geräten.';

  @override
  String get numberFirst => 'Zahl zuerst wählen';

  @override
  String get numberFirstDescription =>
      'Wähle eine Zahl und tippe dann auf die gewünschten Felder.';

  @override
  String get errorCheck => 'Fehlerprüfung';

  @override
  String get checkOff => 'Aus';

  @override
  String get checkConflicts => 'Regelkonflikte';

  @override
  String get checkSolution => 'Mit Lösung vergleichen';

  @override
  String get errorDescription =>
      'Bei ausgeschalteter Prüfung gibt es keine Rückmeldung zur Richtigkeit.';

  @override
  String get about => 'Über Sudoku';

  @override
  String get aboutDescription =>
      'Eine Open-Source-Sudoku-App von Tom Vogel. Entwickelt mit Flutter und Rudi UI. Alle Spieldaten bleiben auf diesem Gerät.';

  @override
  String get version => 'Version 0.1.0';

  @override
  String get storageDescription =>
      'Browserdaten können vom Browser gelöscht werden. Es gibt kein Cloud-Backup und keine Gerätesynchronisierung.';

  @override
  String get noStatistics => 'Dein erstes Rätsel wartet.';

  @override
  String get noStatisticsDescription =>
      'Hier erscheinen deine gelösten Rätsel und Bestzeiten.';

  @override
  String get solved => 'Gelöst';

  @override
  String get bestTime => 'Bestzeit';

  @override
  String get totalTime => 'Gespielte Zeit';

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get inProgress => 'Begonnen';

  @override
  String get notStarted => 'Noch nicht gespielt';

  @override
  String get futureDay => 'Noch nicht verfügbar';

  @override
  String get previousMonth => 'Vorheriger Monat';

  @override
  String get nextMonth => 'Nächster Monat';

  @override
  String get today => 'Heute';

  @override
  String cellLabel(int row, int column) {
    return 'Zeile $row, Spalte $column';
  }

  @override
  String givenValue(int value) {
    return 'Vorgegeben: $value';
  }

  @override
  String enteredValue(int value) {
    return 'Zahl: $value';
  }

  @override
  String get emptyCell => 'Leer';

  @override
  String candidates(String values) {
    return 'Notizen: $values';
  }

  @override
  String get conflict => 'Konflikt';

  @override
  String selectedNumber(int number) {
    return 'Gewählte Zahl: $number';
  }

  @override
  String get keyboardHelp =>
      '1–9: Zahl · N: Notizen · Entf: Löschen · Pfeile: Bewegen · Strg+Z: Zurück';

  @override
  String get replaceTitle => 'Neues Rätsel starten?';

  @override
  String get replaceMessage =>
      'Dein unvollständiges freies Spiel wird ersetzt. Tagesrätsel bleiben separat gespeichert.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get start => 'Starten';

  @override
  String monthProgress(int count) {
    return '$count diesen Monat gelöst';
  }

  @override
  String get notesHelp => 'Notiere mögliche Zahlen klein in einem leeren Feld.';

  @override
  String get chooseDifficulty => 'Wähle eine Schwierigkeit zum Starten.';

  @override
  String get licenses => 'Open-Source-Lizenzen';

  @override
  String get licenseNote =>
      'Sudoku und Rudi UI stehen unter der MIT-Lizenz. Google Sans steht unter der SIL Open Font License. Solar Icons: 480 Design, CC BY 4.0 (solar-icons.vercel.app). Flutter-Paket solar_icons: Sebastine Odeh, BSD-3-Clause.';

  @override
  String get boardMist => 'Nebel';

  @override
  String get selectDifficulty => 'Schwierigkeit wählen';

  @override
  String get boardThemeDescription => 'Wähle die Darstellung deines Rätsels.';

  @override
  String get boardClassic => 'Klassisch';

  @override
  String get customization => 'Anpassung';

  @override
  String get boardPaper => 'Papier';

  @override
  String get boardTheme => 'Spielfeld';

  @override
  String get boardMidnight => 'Nacht';

  @override
  String get homeSubtitle => 'Dein täglicher Moment zum Knobeln.';
}
