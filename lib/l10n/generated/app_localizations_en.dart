// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sudoku';

  @override
  String get tagline => 'A little space to think.';

  @override
  String get play => 'Home';

  @override
  String get daily => 'Daily';

  @override
  String get statistics => 'Statistics';

  @override
  String get settings => 'Settings';

  @override
  String get newGame => 'New game';

  @override
  String get continueGame => 'Continue game';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get difficultyNote =>
      'Starter difficulty levels use clue counts. Strategy-based grading is planned.';

  @override
  String get dailyTitle => 'Your daily puzzle';

  @override
  String get dailyDescription =>
      'The same puzzle for everyone. A fresh start every day.';

  @override
  String get playDaily => 'Play today\'s puzzle';

  @override
  String get dailyArchive => 'Daily calendar';

  @override
  String get calendarDescription =>
      'Missed a day? Past puzzles stay available.';

  @override
  String get freePlay => 'Free play';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get loading => 'Preparing your puzzle…';

  @override
  String get loadFailed =>
      'Your saved games could not be loaded. They have not been overwritten.';

  @override
  String get retry => 'Try again';

  @override
  String get saveFailed => 'Saving failed. Keep the app open and try again.';

  @override
  String get generationFailed =>
      'The puzzle could not be created. Please try again.';

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';

  @override
  String get erase => 'Erase';

  @override
  String get notes => 'Notes';

  @override
  String get notesOn => 'Notes on';

  @override
  String get pause => 'Pause';

  @override
  String get paused => 'Paused';

  @override
  String get resume => 'Resume';

  @override
  String get pausedMessage => 'Take your time. Your puzzle will be here.';

  @override
  String get finished => 'Nicely done.';

  @override
  String get finishedMessage => 'Another puzzle, solved at your own pace.';

  @override
  String get backHome => 'Back to start';

  @override
  String get timer => 'Timer';

  @override
  String progress(int filled) {
    return '$filled / 81 filled';
  }

  @override
  String get appearance => 'Appearance';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get gameSettings => 'Game';

  @override
  String get showTimer => 'Show timer';

  @override
  String get showTimerDescription =>
      'Hide the clock and play at your own pace.';

  @override
  String get cleanNotes => 'Clean up notes';

  @override
  String get cleanNotesDescription =>
      'Remove a placed number from notes in its row, column and block.';

  @override
  String get haptics => 'Haptic feedback';

  @override
  String get hapticsDescription => 'A subtle tap on supported devices.';

  @override
  String get numberFirst => 'Number-first input';

  @override
  String get numberFirstDescription =>
      'Choose a number, then tap cells to place it.';

  @override
  String get errorCheck => 'Error checking';

  @override
  String get checkOff => 'Off';

  @override
  String get checkConflicts => 'Rule conflicts';

  @override
  String get checkSolution => 'Compare with solution';

  @override
  String get errorDescription =>
      'With checking off, no correctness feedback is shown.';

  @override
  String get about => 'About Sudoku';

  @override
  String get aboutDescription =>
      'An open-source Sudoku app by Tom Vogel. Built with Flutter and Rudi UI. All game data stays on this device.';

  @override
  String get version => 'Version 0.1.0';

  @override
  String get storageDescription =>
      'Browser data can be cleared by your browser. There is no cloud backup or device sync.';

  @override
  String get noStatistics => 'Your first puzzle is waiting.';

  @override
  String get noStatisticsDescription =>
      'Completed puzzles and your best times will appear here.';

  @override
  String get solved => 'Solved';

  @override
  String get bestTime => 'Best time';

  @override
  String get totalTime => 'Time played';

  @override
  String get completed => 'Completed';

  @override
  String get inProgress => 'In progress';

  @override
  String get notStarted => 'Not played';

  @override
  String get futureDay => 'Not available yet';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get today => 'Today';

  @override
  String cellLabel(int row, int column) {
    return 'Row $row, column $column';
  }

  @override
  String givenValue(int value) {
    return 'Given: $value';
  }

  @override
  String enteredValue(int value) {
    return 'Value: $value';
  }

  @override
  String get emptyCell => 'Empty';

  @override
  String candidates(String values) {
    return 'Notes: $values';
  }

  @override
  String get conflict => 'Conflict';

  @override
  String selectedNumber(int number) {
    return 'Selected number: $number';
  }

  @override
  String get keyboardHelp =>
      '1–9: number · N: notes · Delete: erase · Arrow keys: move · Ctrl+Z: undo';

  @override
  String get replaceTitle => 'Start a new puzzle?';

  @override
  String get replaceMessage =>
      'Your unfinished free-play puzzle will be replaced. Daily puzzles are kept separately.';

  @override
  String get cancel => 'Cancel';

  @override
  String get start => 'Start';

  @override
  String monthProgress(int count) {
    return '$count completed this month';
  }

  @override
  String get notesHelp => 'Add small candidate numbers to an empty cell.';

  @override
  String get chooseDifficulty => 'Choose a difficulty to begin.';

  @override
  String get licenses => 'Open-source licenses';

  @override
  String get licenseNote =>
      'Sudoku is licensed under MIT. Rudi UI is MIT-licensed. Google Sans is licensed under the SIL Open Font License. Solar Icons: 480 Design, CC BY 4.0 (solar-icons.vercel.app). Flutter package solar_icons: Sebastine Odeh, BSD-3-Clause.';

  @override
  String get boardMist => 'Mist';

  @override
  String get selectDifficulty => 'Choose difficulty';

  @override
  String get boardThemeDescription => 'Choose the look of your puzzle.';

  @override
  String get boardClassic => 'Classic';

  @override
  String get customization => 'Customization';

  @override
  String get boardPaper => 'Paper';

  @override
  String get boardTheme => 'Board theme';

  @override
  String get boardMidnight => 'Midnight';

  @override
  String get homeSubtitle => 'Your daily moment to puzzle.';
}
