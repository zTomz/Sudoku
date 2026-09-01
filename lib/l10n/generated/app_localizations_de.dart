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
      'Rätsel werden nach logischen Lösungsstrategien bewertet und sind ohne Raten lösbar.';

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
      'Nur falsche Einträge werden markiert. Regelkonflikte markiert sie nur bei doppelten Zahlen in Zeile, Spalte oder Block. Bei ausgeschalteter Prüfung gibt es keine Rückmeldung zur Richtigkeit.';

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
  String get incorrectValue => 'Falscher Wert';

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

  @override
  String get hint => 'Hinweis';

  @override
  String get hintIncorrect =>
      'Korrigiere oder lösche zuerst deine falschen Einträge. Hinweise bauen nicht auf einer falschen Zahl auf.';

  @override
  String get hintUnavailable =>
      'Mit den unterstützten Techniken wurde kein nächster Schritt gefunden. Es wird keine Zahl geraten.';

  @override
  String get hintLookHere => 'Schau hier hin';

  @override
  String hintLocateCell(String cell) {
    return 'Beginne mit $cell.';
  }

  @override
  String get hintLocateArea =>
      'Sieh dir an, wie die markierten Felder zusammenhängen.';

  @override
  String get hintReasonPlacement =>
      'Die hervorgehobenen Zahlen schließen alle anderen Möglichkeiten aus.';

  @override
  String get hintReasonElimination =>
      'Die markierten Kandidaten bedingen einander. Durchgestrichene Kandidaten entfallen.';

  @override
  String get hintAnswerTitle => 'Dein nächster Zug';

  @override
  String get hintExplainWhy => 'Warum?';

  @override
  String get hintContinue => 'Weiter';

  @override
  String get hintShowAnswer => 'Lösung zeigen';

  @override
  String get hintExplanation => 'Warum funktioniert das?';

  @override
  String hintEnterValue(String cell, int digit) {
    return 'Trage $digit in $cell ein.';
  }

  @override
  String get hintBoardRelevant => 'Für den Hinweis relevantes Feld';

  @override
  String hintBoardCandidates(String digits) {
    return 'Hinweiskandidaten: $digits';
  }

  @override
  String hintBoardRemoved(String digits) {
    return 'Im Hinweis zu streichen: $digits';
  }

  @override
  String hintBoardResult(int digit) {
    return 'Hinweislösung: $digit';
  }

  @override
  String hintCell(int row, int column) {
    return 'Zeile $row, Spalte $column';
  }

  @override
  String hintRating(int score, int steps, int bottlenecks) {
    return 'Rätselaufwand: $score · $steps logische Schritte · $bottlenecks Engstellen. Eine Heuristik innerhalb der Technikstufe, keine Vorhersage der Lösungszeit.';
  }

  @override
  String get techniqueNakedSingle => 'Einziger möglicher Kandidat';

  @override
  String get techniqueHiddenSingle => 'Einziger Platz in einer Einheit';

  @override
  String get techniqueLocked => 'Gebundene Kandidaten';

  @override
  String get techniqueNakedPair => 'Offenes Paar';

  @override
  String get techniqueHiddenPair => 'Verstecktes Paar';

  @override
  String get techniqueNakedTriple => 'Offenes Tripel';

  @override
  String get techniqueHiddenTriple => 'Verstecktes Tripel';

  @override
  String get techniqueXWing => 'X-Wing';

  @override
  String get techniqueXYWing => 'XY-Wing';

  @override
  String hintNakedSingle(String cell, String digits) {
    return 'In $cell schließen Zeile, Spalte und Block alle Zahlen außer $digits aus. Trage hier $digits ein.';
  }

  @override
  String hintHiddenSingle(String cells, String digits, String cell) {
    return 'In der Einheit mit den Feldern $cells kann $digits nur in $cell stehen. Trage dort $digits ein.';
  }

  @override
  String hintLocked(String digits, String cells) {
    return 'Alle verbliebenen Positionen für $digits in einer Zeile, Spalte oder einem Block liegen im Schnittbereich mit einer anderen Einheit: $cells. Die Zahl ist an diesen Schnittbereich gebunden und entfällt im Rest der anderen Einheit.';
  }

  @override
  String hintNakedSubset(String cells, String digits) {
    return 'Die Felder $cells teilen eine Einheit und haben nur die Kandidaten $digits. Diese Zahlen belegen die Felder in irgendeiner Reihenfolge und können aus den übrigen Feldern der Einheit gestrichen werden.';
  }

  @override
  String hintHiddenSubset(String digits, String cells) {
    return 'Innerhalb einer gemeinsamen Einheit kommen die Zahlen $digits als Kandidaten nur in $cells vor. Diese Felder sind für diese Zahlen reserviert; streiche ihre anderen Kandidaten.';
  }

  @override
  String hintXWing(String digits, String cells) {
    return 'Für $digits haben zwei Zeilen (oder Spalten) genau dieselben zwei möglichen Spalten (oder Zeilen): $cells. In jeder kreuzenden Einheit muss die Zahl einmal stehen und kann dort nirgendwo anders vorkommen.';
  }

  @override
  String hintXYWing(String cells, String digits) {
    return 'Diese drei Felder mit je zwei Kandidaten bilden ein XY-Wing: $cells. Das erste Feld ist das Drehfeld und sieht die beiden anderen. Jeder Wert des Drehfelds erzwingt $digits in einem der Flügel. Felder, die beide Flügel sehen, können $digits nicht enthalten.';
  }

  @override
  String hintCandidate(String cell, String digits) {
    return '$cell: $digits';
  }

  @override
  String hintCandidates(String evidence) {
    return 'Kandidaten in diesem Schritt: $evidence';
  }

  @override
  String hintRemoval(String digits, String cell) {
    return 'Streiche $digits aus $cell.';
  }
}
