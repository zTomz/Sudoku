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
  String get legal => 'Legal';

  @override
  String get privacyPolicy => 'Privacy Policy';

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
      'Puzzles are rated by logical solving techniques and can be solved without guessing.';

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
  String pointsValue(int points) {
    return '$points points';
  }

  @override
  String get pointsLabel => 'points';

  @override
  String pointsAwarded(int points) {
    return '+$points points';
  }

  @override
  String mistakesValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mistakes',
      one: '1 mistake',
    );
    return '$_temp0';
  }

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
      'Controls only the markings on the board. Rule conflicts mark repeated digits in a row, column or box. Mistakes are always counted.';

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
  String get incorrectValue => 'Incorrect value';

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

  @override
  String get hint => 'Hint';

  @override
  String get hintIncorrect =>
      'First correct or erase your incorrect entries. Hints will not build on a wrong number.';

  @override
  String get hintUnavailable =>
      'No next step was found with the supported techniques. No number will be guessed.';

  @override
  String get hintLookHere => 'Look here';

  @override
  String hintLocateCell(String cell) {
    return 'Start with $cell.';
  }

  @override
  String get hintLocateArea =>
      'Look at how the highlighted cells relate to each other.';

  @override
  String get hintReasonPlacement =>
      'The highlighted numbers rule out every other possibility.';

  @override
  String get hintReasonElimination =>
      'The highlighted candidates restrict each other. Crossed-out candidates can be eliminated.';

  @override
  String get hintAnswerTitle => 'Your next move';

  @override
  String get hintExplainWhy => 'Why?';

  @override
  String get hintContinue => 'Continue';

  @override
  String get hintShowAnswer => 'Show answer';

  @override
  String get hintExplanation => 'Why does this work?';

  @override
  String hintEnterValue(String cell, int digit) {
    return 'Enter $digit in $cell.';
  }

  @override
  String get hintBoardRelevant => 'Relevant to the hint';

  @override
  String hintBoardCandidates(String digits) {
    return 'Hint candidates: $digits';
  }

  @override
  String hintBoardRemoved(String digits) {
    return 'Eliminate from hint: $digits';
  }

  @override
  String hintBoardResult(int digit) {
    return 'Hint answer: $digit';
  }

  @override
  String hintCell(int row, int column) {
    return 'row $row, column $column';
  }

  @override
  String hintRating(int score, int steps, int bottlenecks) {
    return 'Puzzle effort: $score · $steps logical steps · $bottlenecks bottlenecks. A heuristic within the technique tier, not a solve-time prediction.';
  }

  @override
  String get techniqueNakedSingle => 'Only possible candidate';

  @override
  String get techniqueHiddenSingle => 'Only place in a unit';

  @override
  String get techniqueLocked => 'Locked candidates';

  @override
  String get techniqueNakedPair => 'Naked pair';

  @override
  String get techniqueHiddenPair => 'Hidden pair';

  @override
  String get techniqueNakedTriple => 'Naked triple';

  @override
  String get techniqueHiddenTriple => 'Hidden triple';

  @override
  String get techniqueXWing => 'X-Wing';

  @override
  String get techniqueXYWing => 'XY-Wing';

  @override
  String hintNakedSingle(String cell, String digits) {
    return 'In $cell, the row, column and block exclude every digit except $digits. Enter $digits here.';
  }

  @override
  String hintHiddenSingle(String cells, String digits, String cell) {
    return 'Within the unit containing $cells, $digits can only go in $cell. Enter $digits here.';
  }

  @override
  String hintLocked(String digits, String cells) {
    return 'All remaining positions for $digits in a row, column or block lie in its intersection with another unit: $cells. This locks the digit into that intersection, excluding it from the rest of the other unit.';
  }

  @override
  String hintNakedSubset(String cells, String digits) {
    return 'The cells $cells share a unit and have only the candidates $digits. These digits occupy these cells in some order and can be removed from the other cells in the unit.';
  }

  @override
  String hintHiddenSubset(String digits, String cells) {
    return 'Within a shared unit, the digits $digits occur as candidates only in $cells. These cells are reserved for those digits; remove their other candidates.';
  }

  @override
  String hintXWing(String digits, String cells) {
    return 'For $digits, two rows (or columns) have exactly the same two possible columns (or rows): $cells. One digit must occupy each crossing unit, so it cannot occur elsewhere in those units.';
  }

  @override
  String hintXYWing(String cells, String digits) {
    return 'These three two-candidate cells form an XY-Wing: $cells. The first cell is the pivot and sees the other two. Either pivot value forces $digits in one of the wings. Cells seeing both wings cannot contain $digits.';
  }

  @override
  String hintCandidate(String cell, String digits) {
    return '$cell: $digits';
  }

  @override
  String hintCandidates(String evidence) {
    return 'Candidates at this step: $evidence';
  }

  @override
  String hintRemoval(String digits, String cell) {
    return 'Remove $digits from $cell.';
  }
}
