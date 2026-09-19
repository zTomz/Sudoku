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
  String get legal => 'Rechtliches';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

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
  String pointsValue(int points) {
    return '$points Punkte';
  }

  @override
  String get pointsLabel => 'Punkte';

  @override
  String pointsAwarded(int points) {
    return '+$points Punkte';
  }

  @override
  String mistakesValue(int count) {
    return '$count Fehler';
  }

  @override
  String hintsUsedValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Hinweise',
      one: '1 Hinweis',
    );
    return '$_temp0';
  }

  @override
  String get scoreBreakdown => 'Punkteübersicht';

  @override
  String get scorePuzzlePoints => 'Spielfeldpunkte';

  @override
  String get scoreCompletionBonus => 'Abschlussbonus';

  @override
  String get scorePerfectBonus => 'Fehlerfrei-Bonus';

  @override
  String get scoreDailyBonus => 'Tagesbonus';

  @override
  String get scoreBeforeDeductions => 'Punkte vor Abzügen';

  @override
  String get debugTools => 'Debug-Werkzeuge';

  @override
  String get debugGameSimulator => 'Spiel simulieren';

  @override
  String get debugGameSimulatorDescription =>
      'Bereite das aktuelle Rätsel zum Testen vor, ohne jedes Feld lösen zu müssen.';

  @override
  String get debugStartGameFirst =>
      'Starte ein Spiel oder setze es fort, um die Simulation zu verwenden.';

  @override
  String get debugFilledCells => 'Ausgefüllte Felder';

  @override
  String get debugMistakes => 'Fehler';

  @override
  String get debugHints => 'Genutzte Hinweise';

  @override
  String get debugApplySimulation => 'Simulation anwenden';

  @override
  String debugValueRange(int minimum, int maximum) {
    return 'Gib einen Wert von $minimum bis $maximum ein.';
  }

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
      'Entfernt passende Notizen in Zeile, Spalte und Block.';

  @override
  String get autoFillEnding => 'Ende automatisch ausfüllen';

  @override
  String get autoFillEndingDescription =>
      'Vervollständigt das Feld gegen Ende, wenn bei jedem verbleibenden Schritt nur eine Zahl möglich ist.';

  @override
  String get haptics => 'Haptisches Feedback';

  @override
  String get hapticsDescription =>
      'Ein dezentes Tippen auf unterstützten Geräten.';

  @override
  String get numberFirst => 'Zahl zuerst wählen';

  @override
  String get numberFirstDescription =>
      'Wähle erst eine Zahl, dann die gewünschten Felder.';

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
      'Steuert nur die Markierung im Spielfeld. Regelkonflikte markieren doppelte Zahlen in Zeile, Spalte oder Block. Der Fehlerzähler läuft immer mit.';

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
      'Deine Statistik erscheint, sobald du ein Rätsel gelöst hast.';

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
  String solveTimeEstimate(String time) {
    return 'Etwa $time';
  }

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

  @override
  String get language => 'Sprache';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get support => 'Hilfe & Feedback';

  @override
  String get repository => 'GitHub-Repository';

  @override
  String get reportBug => 'Fehler melden';

  @override
  String get linkOpenError =>
      'Der Link konnte nicht geöffnet werden. Du kannst die Adresse unten kopieren.';

  @override
  String versionLabel(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get versionUnavailable => 'Version nicht verfügbar';

  @override
  String get licensesLoadError =>
      'Lizenzen konnten nicht geladen werden. Bitte versuche es erneut.';

  @override
  String get copyLink => 'Link kopieren';

  @override
  String get licensesLoading => 'Lizenzen werden geladen...';

  @override
  String get featureRequest => 'Feature vorschlagen';

  @override
  String get systemLanguage => 'Systemsprache';

  @override
  String get systemThemeDescription => 'Darstellung des Geräts verwenden';

  @override
  String get lightThemeDescription => 'Immer das helle Design verwenden';

  @override
  String get darkThemeDescription => 'Immer das dunkle Design verwenden';

  @override
  String get learnSudoku => 'Sudoku lernen';

  @override
  String get learnHomeDescription =>
      'Lerne Schritt für Schritt – von den Regeln bis zu schweren Mustern.';

  @override
  String get learnPathTitle => 'Dein Skill-Pfad';

  @override
  String get learnPathDescription =>
      'Acht kurze Lektionen. Jede gelöste Aufgabe schaltet die nächste Technik frei.';

  @override
  String get learnNoPoints =>
      'Übungsmodus · keine Punkte, Zeiten oder Statistiken';

  @override
  String learnProgress(int completed, int total) {
    return '$completed von $total Lektionen abgeschlossen';
  }

  @override
  String get learnLocked => 'Schließe zuerst die vorherige Lektion ab.';

  @override
  String get learnCompleted => 'Abgeschlossen';

  @override
  String get learnStart => 'Lektion starten';

  @override
  String get learnRepeat => 'Lektion wiederholen';

  @override
  String get learnKnowledgeCheck => 'Wissens-Check';

  @override
  String get learnCheckAnswer => 'Antwort prüfen';

  @override
  String get learnCorrect => 'Genau richtig.';

  @override
  String get learnIncorrect =>
      'Noch nicht ganz. Lies die Erklärung noch einmal und versuche es erneut.';

  @override
  String get learnChooseAnswer => 'Wähle zuerst eine Antwort aus.';

  @override
  String get learnExternalTutorial => 'Externes Tutorial ansehen';

  @override
  String get learnExternalNotice =>
      'Öffnet YouTube im Browser. Erst nach deinem Tippen wird eine Verbindung hergestellt; dann gelten die Datenschutzbestimmungen von YouTube.';

  @override
  String get learnStartPractice => 'Übung starten';

  @override
  String get learnContinue => 'Weiter';

  @override
  String get learnFinishLesson => 'Lektion abschließen';

  @override
  String get learnBackToPath => 'Zurück zum Skill-Pfad';

  @override
  String get learnLessonCompleteTitle => 'Lektion geschafft!';

  @override
  String get learnLessonCompleteBody =>
      'Du hast beide Muster verstanden. Die nächste Station auf deinem Pfad ist bereit.';

  @override
  String learnQuestionProgress(int current, int total) {
    return 'Frage $current von $total';
  }

  @override
  String get learnTutorialsTitle => 'Noch genauer lernen';

  @override
  String learnTutorialBy(String creator) {
    return '$creator · YouTube';
  }

  @override
  String get learnLessonRulesTitle => 'Die Sudoku-Regeln';

  @override
  String get learnLessonRulesSummary =>
      'Verstehe Zeilen, Spalten, Blöcke und das Lösen ohne Raten.';

  @override
  String get learnLessonRulesBody =>
      'Fülle jedes leere Feld mit einer Zahl von 1 bis 9. Jede Zeile, jede Spalte und jeder 3×3-Block muss jede Zahl genau einmal enthalten. Ein gutes Rätsel lässt sich logisch lösen: Setze eine Zahl nur, wenn das aktuelle Spielfeld sie beweist.';

  @override
  String get learnLessonRulesQuestion =>
      'In der Zeile eines Feldes steht bereits eine 7. Was folgt daraus?';

  @override
  String get learnLessonRulesA => 'Das Feld kann keine 7 enthalten';

  @override
  String get learnLessonRulesB => 'Das Feld muss eine 7 enthalten';

  @override
  String get learnLessonRulesC => 'Die Zeile spielt keine Rolle mehr';

  @override
  String get learnLessonRulesQ2 =>
      'Der markierte 3×3-Block enthält bereits die Zahlen 1 bis 8. Welche Zahl vervollständigt ihn?';

  @override
  String get learnLessonRulesQ2A => '9';

  @override
  String get learnLessonRulesQ2B => 'Irgendeine Zahl, die in der Zeile fehlt';

  @override
  String get learnLessonRulesQ2C => 'Du musst raten';

  @override
  String get learnLessonRulesQ2Why =>
      'Jeder Block enthält 1 bis 9 genau einmal. Deshalb ist die einzige fehlende Zahl die 9.';

  @override
  String get learnLessonCandidatesTitle => 'Kandidaten und Notizen';

  @override
  String get learnLessonCandidatesSummary =>
      'Mache aus Ausschlüssen eine kleine, nützliche Kandidatenliste.';

  @override
  String get learnLessonCandidatesBody =>
      'Ein Kandidat ist eine Zahl, die durch Zeile, Spalte und Block noch nicht ausgeschlossen ist. Notizen sind Arbeitsinformationen, keine Vermutungen. Aktualisiere sie, wenn ein Eintrag Möglichkeiten in benachbarten Feldern entfernt.';

  @override
  String get learnLessonCandidatesQuestion =>
      'Wann sollte eine Zahl als Kandidat notiert werden?';

  @override
  String get learnLessonCandidatesA => 'Wenn sie wahrscheinlich aussieht';

  @override
  String get learnLessonCandidatesB =>
      'Nur wenn Zeile, Spalte und Block sie erlauben';

  @override
  String get learnLessonCandidatesC => 'Erst nach einem geratenen Zug';

  @override
  String get learnLessonCandidatesQ2 =>
      'Das markierte Feld sieht 1 und 2 in seiner Zeile, 3 und 4 in seiner Spalte sowie 5 und 6 in seinem Block. Welche Kandidaten bleiben?';

  @override
  String get learnLessonCandidatesQ2A => '7, 8 und 9';

  @override
  String get learnLessonCandidatesQ2B => '1, 2 und 3';

  @override
  String get learnLessonCandidatesQ2C => '4, 5 und 6';

  @override
  String get learnLessonCandidatesQ2Why =>
      'Nur 7, 8 und 9 bestehen alle drei Prüfungen. Kandidaten sind Möglichkeiten, keine Vermutungen.';

  @override
  String get learnLessonNakedSingleSummary =>
      'Finde ein Feld, in dem genau ein Kandidat übrig ist.';

  @override
  String get learnLessonNakedSingleBody =>
      'Wenn acht Zahlen für ein Feld ausgeschlossen sind, ist der letzte Kandidat erzwungen. Das ist ein offenes Single: Die Lösung ist direkt in der Kandidatenliste dieses Feldes sichtbar.';

  @override
  String get learnLessonNakedSingleQuestion =>
      'Ein Feld hat nur den Kandidaten 4. Was ist der logische Zug?';

  @override
  String get learnLessonNakedSingleA => '4 eintragen';

  @override
  String get learnLessonNakedSingleB => 'Die Notiz 4 löschen';

  @override
  String get learnLessonNakedSingleC => 'Auf einen zweiten Kandidaten warten';

  @override
  String get learnLessonNakedSingleQ2 =>
      'Das markierte Feld hat die Kandidaten 3 und 8. Ist es bereits ein offenes Single?';

  @override
  String get learnLessonNakedSingleQ2A => 'Nein, es bleiben zwei Möglichkeiten';

  @override
  String get learnLessonNakedSingleQ2B => 'Ja, trage 3 ein';

  @override
  String get learnLessonNakedSingleQ2C => 'Ja, trage 8 ein';

  @override
  String get learnLessonNakedSingleQ2Why =>
      'Ein offenes Single braucht genau einen verbleibenden Kandidaten. Bei zwei Kandidaten fehlen noch Informationen.';

  @override
  String get learnLessonHiddenSingleSummary =>
      'Finde den einzigen Platz für eine Zahl in einer Einheit.';

  @override
  String get learnLessonHiddenSingleBody =>
      'Ein Feld kann mehrere Kandidaten haben, während einer davon in seiner Zeile, Spalte oder seinem Block einzigartig ist. Kommt die 6 als Kandidat nur in einem Feld der Einheit vor, ist sie dort erzwungen.';

  @override
  String get learnLessonHiddenSingleQuestion =>
      'In einem Block kann nur ein Feld die 6 enthalten. Dieses Feld erlaubt auch die 2. Was kannst du setzen?';

  @override
  String get learnLessonHiddenSingleA => 'Nichts, weil es zwei Notizen hat';

  @override
  String get learnLessonHiddenSingleB =>
      'Die 6, weil sie im Block nur dort stehen kann';

  @override
  String get learnLessonHiddenSingleC => 'Die 2, weil sie kleiner ist';

  @override
  String get learnLessonHiddenSingleQ2 =>
      'Warum ist die 6 im markierten Feld erzwungen, obwohl das Feld auch die 2 erlaubt?';

  @override
  String get learnLessonHiddenSingleQ2A =>
      'Es ist das einzige Feld der Zeile, das 6 erlaubt';

  @override
  String get learnLessonHiddenSingleQ2B => '6 ist immer stärker als 2';

  @override
  String get learnLessonHiddenSingleQ2C =>
      'Das markierte Feld braucht den größten Kandidaten';

  @override
  String get learnLessonHiddenSingleQ2Why =>
      'Betrachte zuerst die Zahl: Alle anderen Felder der Zeile schließen 6 aus. Damit ist dies der einzige Platz für die 6.';

  @override
  String get learnLessonLockedSummary =>
      'Nutze die Überschneidung von Block und Zeile oder Spalte.';

  @override
  String get learnLessonLockedBody =>
      'Liegen alle Kandidaten einer Zahl in einem Block auf derselben Zeile, ist die Zahl an die Schnittmenge aus Block und Zeile gebunden. Streiche sie im Rest dieser Zeile. Dasselbe gilt für Spalten.';

  @override
  String get learnLessonLockedQuestion =>
      'Alle möglichen 5en eines Blocks liegen in Zeile 3. Wo kann die 5 gestrichen werden?';

  @override
  String get learnLessonLockedA =>
      'Im Rest von Zeile 3 außerhalb dieses Blocks';

  @override
  String get learnLessonLockedB => 'In jedem Feld des Blocks';

  @override
  String get learnLessonLockedC => 'In allen anderen Zeilen';

  @override
  String get learnLessonLockedQ2 =>
      'In der markierten Zeile liegen alle möglichen 4en im mittleren Block. Wo kann die 4 gestrichen werden?';

  @override
  String get learnLessonLockedQ2A => 'In den anderen Feldern dieses Blocks';

  @override
  String get learnLessonLockedQ2B => 'In der gesamten markierten Zeile';

  @override
  String get learnLessonLockedQ2C =>
      'Nirgendwo; zuerst muss eine Zahl gesetzt werden';

  @override
  String get learnLessonLockedQ2Why =>
      'Das ist Claiming: Die Zeile beansprucht ihre 4 innerhalb eines Blocks. Außerhalb dieser Zeile kann der Block keine weitere 4 enthalten.';

  @override
  String get learnLessonPairsTitle => 'Paare';

  @override
  String get learnLessonPairsSummary =>
      'Reserviere zwei Zahlen für zwei Felder.';

  @override
  String get learnLessonPairsBody =>
      'Ein offenes Paar besteht aus zwei Feldern einer Einheit mit denselben zwei Kandidaten; diese Zahlen entfallen in den anderen Feldern der Einheit. Bei einem versteckten Paar kommen zwei Zahlen nur in denselben zwei Feldern vor; dort können andere Notizen gestrichen werden.';

  @override
  String get learnLessonPairsQuestion =>
      'Zwei Felder einer Zeile enthalten beide nur 2 und 8. Was folgt daraus?';

  @override
  String get learnLessonPairsA =>
      '2 und 8 entfallen in den anderen Feldern dieser Zeile';

  @override
  String get learnLessonPairsB => 'Beide Felder müssen 2 sein';

  @override
  String get learnLessonPairsC => 'Das Paar hat keine Wirkung';

  @override
  String get learnLessonPairsQ2 =>
      'Nur die zwei markierten Felder einer Spalte können 4 oder 7 enthalten. Sie haben noch weitere Notizen. Was ist der Zug beim versteckten Paar?';

  @override
  String get learnLessonPairsQ2A =>
      'In diesen zwei Feldern nur 4 und 7 behalten';

  @override
  String get learnLessonPairsQ2B => '4 und 7 aus diesen zwei Feldern streichen';

  @override
  String get learnLessonPairsQ2C => 'In beide Felder eine 4 eintragen';

  @override
  String get learnLessonPairsQ2Why =>
      'Die beiden Felder sind in irgendeiner Reihenfolge für 4 und 7 reserviert. Ihre anderen Kandidaten können gestrichen werden.';

  @override
  String get learnLessonTriplesTitle => 'Tripel';

  @override
  String get learnLessonTriplesSummary =>
      'Erweitere die Teilmengenlogik von zwei auf drei Felder.';

  @override
  String get learnLessonTriplesBody =>
      'Drei Felder einer Einheit können genau drei Zahlen reservieren, auch wenn nicht jedes Feld alle drei zeigt. Bei einem offenen Tripel umfasst die Vereinigung ihrer Kandidaten genau drei Zahlen. Versteckte Tripel betrachten die Umkehrung: Drei Zahlen kommen nirgendwo sonst in der Einheit vor.';

  @override
  String get learnLessonTriplesQuestion =>
      'Drei Felder einer Zeile verwenden zusammen nur die Kandidaten 1, 4 und 9. Was darfst du tun?';

  @override
  String get learnLessonTriplesA =>
      '1, 4 und 9 aus den anderen Feldern der Zeile streichen';

  @override
  String get learnLessonTriplesB => 'Alle drei Zahlen in jedes Feld eintragen';

  @override
  String get learnLessonTriplesC =>
      'Alle anderen Kandidaten aus der Zeile streichen';

  @override
  String get learnLessonTriplesQ2 =>
      'In einem Block kommen 2, 5 und 6 nur in drei markierten Feldern vor. Was erlaubt das versteckte Tripel?';

  @override
  String get learnLessonTriplesQ2A =>
      'Andere Kandidaten aus diesen drei Feldern streichen';

  @override
  String get learnLessonTriplesQ2B =>
      '2, 5 und 6 aus diesen drei Feldern streichen';

  @override
  String get learnLessonTriplesQ2C => 'Alle drei Zahlen sofort eintragen';

  @override
  String get learnLessonTriplesQ2Why =>
      'Diese drei Felder müssen 2, 5 und 6 in irgendeiner Reihenfolge enthalten. Andere Notizen können dort entfernt werden.';

  @override
  String get learnLessonWingsTitle => 'Wings: X-Wing und XY-Wing';

  @override
  String get learnLessonWingsSummary =>
      'Erkenne verknüpfte Kandidatenmuster über mehrere Einheiten.';

  @override
  String get learnLessonWingsBody =>
      'Ein X-Wing nutzt eine Zahl in zwei Zeilen und denselben zwei Spalten, wodurch Streichungen in diesen Spalten möglich werden. Ein XY-Wing nutzt drei Felder mit je zwei Kandidaten: Ein Drehfeld sieht zwei Flügel, und jeder Wert des Drehfelds erzwingt den gemeinsamen Flügelkandidaten. Beides sind logische Streichmuster, kein Raten.';

  @override
  String get learnLessonWingsQuestion =>
      'Kandidat 5 bildet die vier Ecken des markierten Rechtecks über zwei Zeilen und zwei Spalten. Was folgt aus dem X-Wing?';

  @override
  String get learnLessonWingsA =>
      '5 aus anderen Feldern der beiden Spalten streichen';

  @override
  String get learnLessonWingsB => 'In alle vier Ecken eine 5 eintragen';

  @override
  String get learnLessonWingsC =>
      'Alle anderen Kandidaten aus den Ecken streichen';

  @override
  String get learnLessonWingsQ2 =>
      'Das Drehfeld hat 2/3; seine Flügel haben 2/7 und 3/7. Welche Zahl verliert ein Feld, das beide Flügel sieht?';

  @override
  String get learnLessonWingsQ2A => '2';

  @override
  String get learnLessonWingsQ2B => '3';

  @override
  String get learnLessonWingsQ2C => '7';

  @override
  String get learnLessonWingsQ2Why =>
      'Egal welchen Wert das Drehfeld annimmt: Einer der Flügel wird zur 7. Ein Feld, das beide Flügel sieht, kann deshalb keine 7 sein.';
}
