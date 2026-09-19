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
  String hintsUsedValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hints',
      one: '1 hint',
    );
    return '$_temp0';
  }

  @override
  String get scoreBreakdown => 'Score breakdown';

  @override
  String get scorePuzzlePoints => 'Board points';

  @override
  String get scoreCompletionBonus => 'Completion bonus';

  @override
  String get scorePerfectBonus => 'No-mistake bonus';

  @override
  String get scoreDailyBonus => 'Daily bonus';

  @override
  String get scoreBeforeDeductions => 'Score before deductions';

  @override
  String get debugTools => 'Debug tools';

  @override
  String get debugGameSimulator => 'Game simulator';

  @override
  String get debugGameSimulatorDescription =>
      'Set up the current puzzle for testing without solving every cell.';

  @override
  String get debugStartGameFirst =>
      'Start or resume a game to use the simulator.';

  @override
  String get debugFilledCells => 'Filled cells';

  @override
  String get debugMistakes => 'Mistakes';

  @override
  String get debugHints => 'Hints used';

  @override
  String get debugApplySimulation => 'Apply simulation';

  @override
  String debugValueRange(int minimum, int maximum) {
    return 'Enter a value from $minimum to $maximum.';
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
      'Removes matching notes in its row, column and block.';

  @override
  String get autoFillEnding => 'Auto-fill ending';

  @override
  String get autoFillEndingDescription =>
      'Finishes the board near the end when every remaining step has only one possible number.';

  @override
  String get haptics => 'Haptic feedback';

  @override
  String get hapticsDescription => 'A subtle tap on supported devices.';

  @override
  String get numberFirst => 'Number-first input';

  @override
  String get numberFirstDescription => 'Choose a number, then tap the cells.';

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
      'Your statistics will appear once you solve a puzzle.';

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
  String solveTimeEstimate(String time) {
    return 'About $time';
  }

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

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get support => 'Help & feedback';

  @override
  String get repository => 'GitHub repository';

  @override
  String get reportBug => 'Report a bug';

  @override
  String get linkOpenError =>
      'Could not open the link. You can copy the address below.';

  @override
  String versionLabel(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get versionUnavailable => 'Version unavailable';

  @override
  String get licensesLoadError => 'Could not load licenses. Please try again.';

  @override
  String get copyLink => 'Copy link';

  @override
  String get licensesLoading => 'Loading licenses...';

  @override
  String get featureRequest => 'Request a feature';

  @override
  String get systemLanguage => 'System language';

  @override
  String get systemThemeDescription => 'Follow your device appearance';

  @override
  String get lightThemeDescription => 'Always use the light theme';

  @override
  String get darkThemeDescription => 'Always use the dark theme';

  @override
  String get learnSudoku => 'Learn Sudoku';

  @override
  String get learnHomeDescription =>
      'Build your skills step by step, from the rules to advanced patterns.';

  @override
  String get learnPathTitle => 'Your skill path';

  @override
  String get learnPathDescription =>
      'Eight short lessons. Each check unlocks the next skill.';

  @override
  String get learnNoPoints => 'Practice mode · no points, times, or statistics';

  @override
  String learnProgress(int completed, int total) {
    return '$completed of $total lessons completed';
  }

  @override
  String get learnLocked => 'Complete the previous lesson first.';

  @override
  String get learnCompleted => 'Completed';

  @override
  String get learnStart => 'Start lesson';

  @override
  String get learnRepeat => 'Repeat lesson';

  @override
  String get learnKnowledgeCheck => 'Knowledge check';

  @override
  String get learnCheckAnswer => 'Check answer';

  @override
  String get learnCorrect => 'Exactly right.';

  @override
  String get learnIncorrect =>
      'Not quite. Revisit the explanation and try again.';

  @override
  String get learnChooseAnswer => 'Choose an answer first.';

  @override
  String get learnExternalTutorial => 'Watch an external tutorial';

  @override
  String get learnExternalNotice =>
      'Opens YouTube in your browser. No connection is made until you tap the link; YouTube\'s privacy terms then apply.';

  @override
  String get learnStartPractice => 'Start practice';

  @override
  String get learnContinue => 'Continue';

  @override
  String get learnFinishLesson => 'Finish lesson';

  @override
  String get learnBackToPath => 'Back to skill path';

  @override
  String get learnLessonCompleteTitle => 'Lesson complete!';

  @override
  String get learnLessonCompleteBody =>
      'You understood both patterns. The next stop on your path is ready.';

  @override
  String learnQuestionProgress(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get learnTutorialsTitle => 'Go deeper';

  @override
  String learnTutorialBy(String creator) {
    return '$creator · YouTube';
  }

  @override
  String get learnLessonRulesTitle => 'The Sudoku rules';

  @override
  String get learnLessonRulesSummary =>
      'Understand rows, columns, blocks, and the no-guessing mindset.';

  @override
  String get learnLessonRulesBody =>
      'Fill every empty cell with a digit from 1 to 9. Every row, every column, and every 3×3 block must contain each digit exactly once. A well-formed puzzle can be solved with logic: place a digit only when the current grid proves it.';

  @override
  String get learnLessonRulesQuestion =>
      'A 7 already appears in a cell\'s row. What follows?';

  @override
  String get learnLessonRulesA => 'The cell cannot contain 7';

  @override
  String get learnLessonRulesB => 'The cell must contain 7';

  @override
  String get learnLessonRulesC => 'The row no longer matters';

  @override
  String get learnLessonRulesQ2 =>
      'The highlighted 3×3 block already contains 1 through 8. Which digit completes it?';

  @override
  String get learnLessonRulesQ2A => '9';

  @override
  String get learnLessonRulesQ2B => 'Any digit missing from the row';

  @override
  String get learnLessonRulesQ2C => 'You have to guess';

  @override
  String get learnLessonRulesQ2Why =>
      'Every block contains 1 through 9 exactly once, so the only missing digit is 9.';

  @override
  String get learnLessonCandidatesTitle => 'Candidates and notes';

  @override
  String get learnLessonCandidatesSummary =>
      'Turn exclusions into a small, useful candidate list.';

  @override
  String get learnLessonCandidatesBody =>
      'A candidate is a digit that is not already excluded by the cell\'s row, column, or block. Notes are working information, not guesses. Update them when a placement removes a possibility nearby.';

  @override
  String get learnLessonCandidatesQuestion =>
      'When should a digit be written as a candidate?';

  @override
  String get learnLessonCandidatesA => 'Whenever it looks likely';

  @override
  String get learnLessonCandidatesB =>
      'Only when row, column, and block allow it';

  @override
  String get learnLessonCandidatesC => 'Only after making a guess';

  @override
  String get learnLessonCandidatesQ2 =>
      'The highlighted cell sees 1 and 2 in its row, 3 and 4 in its column, and 5 and 6 in its block. Which candidates remain?';

  @override
  String get learnLessonCandidatesQ2A => '7, 8, and 9';

  @override
  String get learnLessonCandidatesQ2B => '1, 2, and 3';

  @override
  String get learnLessonCandidatesQ2C => '4, 5, and 6';

  @override
  String get learnLessonCandidatesQ2Why =>
      'Only 7, 8, and 9 survive all three checks. Candidates are possibilities, not guesses.';

  @override
  String get learnLessonNakedSingleSummary =>
      'Find a cell with exactly one candidate left.';

  @override
  String get learnLessonNakedSingleBody =>
      'If eight digits are excluded from one cell, its remaining candidate is forced. This is a naked single: the answer is visible directly in that cell\'s candidate list.';

  @override
  String get learnLessonNakedSingleQuestion =>
      'A cell has only candidate 4. What is the logical move?';

  @override
  String get learnLessonNakedSingleA => 'Enter 4';

  @override
  String get learnLessonNakedSingleB => 'Erase the note 4';

  @override
  String get learnLessonNakedSingleC => 'Wait for a second candidate';

  @override
  String get learnLessonNakedSingleQ2 =>
      'The highlighted cell has candidates 3 and 8. Is this already a naked single?';

  @override
  String get learnLessonNakedSingleQ2A => 'No, two possibilities remain';

  @override
  String get learnLessonNakedSingleQ2B => 'Yes, enter 3';

  @override
  String get learnLessonNakedSingleQ2C => 'Yes, enter 8';

  @override
  String get learnLessonNakedSingleQ2Why =>
      'A naked single requires exactly one remaining candidate. With two candidates, more information is needed.';

  @override
  String get learnLessonHiddenSingleSummary =>
      'Find the only place for a digit inside one unit.';

  @override
  String get learnLessonHiddenSingleBody =>
      'A cell may have several candidates, yet one of them can be unique within its row, column, or block. If 6 appears as a candidate in only one cell of that unit, 6 is forced there.';

  @override
  String get learnLessonHiddenSingleQuestion =>
      'In a block, only one cell can contain 6. That cell also allows 2. What can you place?';

  @override
  String get learnLessonHiddenSingleA => 'Nothing, because it has two notes';

  @override
  String get learnLessonHiddenSingleB =>
      '6, because it has the only place in the block';

  @override
  String get learnLessonHiddenSingleC => '2, because it is smaller';

  @override
  String get learnLessonHiddenSingleQ2 =>
      'Why is 6 forced in the highlighted cell even though that cell also allows 2?';

  @override
  String get learnLessonHiddenSingleQ2A =>
      'It is the only cell in the row that allows 6';

  @override
  String get learnLessonHiddenSingleQ2B => '6 is always stronger than 2';

  @override
  String get learnLessonHiddenSingleQ2C =>
      'The highlighted cell must use its largest candidate';

  @override
  String get learnLessonHiddenSingleQ2Why =>
      'Look digit-first: every other cell in the row excludes 6, so this is 6\'s only place.';

  @override
  String get learnLessonLockedSummary =>
      'Use the overlap between a block and a row or column.';

  @override
  String get learnLessonLockedBody =>
      'If every candidate for a digit in a block lies on the same row, that digit is locked into the block-row intersection. Remove it from the rest of that row. The same logic works with columns.';

  @override
  String get learnLessonLockedQuestion =>
      'All possible 5s in a block lie in row 3. Where can 5 be removed?';

  @override
  String get learnLessonLockedA => 'From the rest of row 3 outside that block';

  @override
  String get learnLessonLockedB => 'From every cell in the block';

  @override
  String get learnLessonLockedC => 'From all other rows';

  @override
  String get learnLessonLockedQ2 =>
      'In the highlighted row, every possible 4 lies inside the middle block. Where can 4 be removed?';

  @override
  String get learnLessonLockedQ2A => 'From the other cells of that block';

  @override
  String get learnLessonLockedQ2B => 'From the entire highlighted row';

  @override
  String get learnLessonLockedQ2C => 'Nowhere; a placement is required first';

  @override
  String get learnLessonLockedQ2Why =>
      'This is claiming: the row claims its 4 inside one block, so the block cannot contain 4 outside that row.';

  @override
  String get learnLessonPairsTitle => 'Pairs';

  @override
  String get learnLessonPairsSummary => 'Reserve two digits for two cells.';

  @override
  String get learnLessonPairsBody =>
      'A naked pair is two cells in one unit containing the same two candidates; those digits can be removed from other cells in the unit. A hidden pair is two digits that occur only in the same two cells; other notes can be removed from those cells.';

  @override
  String get learnLessonPairsQuestion =>
      'Two cells in a row both contain only 2 and 8. What follows?';

  @override
  String get learnLessonPairsA =>
      '2 and 8 can be removed from the other cells in that row';

  @override
  String get learnLessonPairsB => 'Both cells must be 2';

  @override
  String get learnLessonPairsC => 'The pair has no effect';

  @override
  String get learnLessonPairsQ2 =>
      'Only the two highlighted cells in a column can contain 4 or 7. They also contain other notes. What is the hidden-pair move?';

  @override
  String get learnLessonPairsQ2A => 'Keep only 4 and 7 in those two cells';

  @override
  String get learnLessonPairsQ2B => 'Remove 4 and 7 from those two cells';

  @override
  String get learnLessonPairsQ2C => 'Place 4 in both cells';

  @override
  String get learnLessonPairsQ2Why =>
      'The two cells are reserved for 4 and 7 in some order, so their other candidates can be removed.';

  @override
  String get learnLessonTriplesTitle => 'Triples';

  @override
  String get learnLessonTriplesSummary =>
      'Extend subset logic from two cells to three.';

  @override
  String get learnLessonTriplesBody =>
      'Three cells in one unit can reserve exactly three digits even when not every cell shows all three. For a naked triple, the union of their candidates has size three. Hidden triples use the inverse view: three digits occur nowhere else in the unit.';

  @override
  String get learnLessonTriplesQuestion =>
      'Three cells in one row use only the combined candidates 1, 4, and 9. What may you do?';

  @override
  String get learnLessonTriplesA =>
      'Remove 1, 4, and 9 from the row\'s other cells';

  @override
  String get learnLessonTriplesB => 'Put all three digits into each cell';

  @override
  String get learnLessonTriplesC => 'Remove every other candidate from the row';

  @override
  String get learnLessonTriplesQ2 =>
      'In one block, the digits 2, 5, and 6 occur only in three highlighted cells. What does the hidden triple allow?';

  @override
  String get learnLessonTriplesQ2A =>
      'Remove other candidates from those three cells';

  @override
  String get learnLessonTriplesQ2B =>
      'Remove 2, 5, and 6 from those three cells';

  @override
  String get learnLessonTriplesQ2C => 'Place all three digits immediately';

  @override
  String get learnLessonTriplesQ2Why =>
      'Those three cells must contain 2, 5, and 6 in some order. Notes outside that set can be cleared from the three cells.';

  @override
  String get learnLessonWingsTitle => 'Wings: X-Wing and XY-Wing';

  @override
  String get learnLessonWingsSummary =>
      'Read linked candidate patterns across multiple units.';

  @override
  String get learnLessonWingsBody =>
      'An X-Wing uses one digit in two rows and the same two columns, allowing eliminations in those columns. An XY-Wing uses three two-candidate cells: a pivot sees two wings, and either pivot value forces the shared wing candidate. These are elimination patterns, not guesses.';

  @override
  String get learnLessonWingsQuestion =>
      'Candidate 5 forms the four corners of the highlighted rectangle across two rows and two columns. What is the X-Wing conclusion?';

  @override
  String get learnLessonWingsA =>
      'Remove 5 from other cells in the two columns';

  @override
  String get learnLessonWingsB => 'Place 5 in all four corners';

  @override
  String get learnLessonWingsC =>
      'Remove every other candidate from the corners';

  @override
  String get learnLessonWingsQ2 =>
      'The pivot has 2/3; its wings have 2/7 and 3/7. What can a cell that sees both wings lose?';

  @override
  String get learnLessonWingsQ2A => '2';

  @override
  String get learnLessonWingsQ2B => '3';

  @override
  String get learnLessonWingsQ2C => '7';

  @override
  String get learnLessonWingsQ2Why =>
      'Whichever value the pivot takes, one wing must become 7. A cell seeing both wings therefore cannot be 7.';
}
