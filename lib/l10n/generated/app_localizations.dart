import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Sudoku'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'A little space to think.'**
  String get tagline;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get play;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @newGame.
  ///
  /// In en, this message translates to:
  /// **'New game'**
  String get newGame;

  /// No description provided for @continueGame.
  ///
  /// In en, this message translates to:
  /// **'Continue game'**
  String get continueGame;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @difficultyNote.
  ///
  /// In en, this message translates to:
  /// **'Puzzles are rated by logical solving techniques and can be solved without guessing.'**
  String get difficultyNote;

  /// No description provided for @dailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your daily puzzle'**
  String get dailyTitle;

  /// No description provided for @dailyDescription.
  ///
  /// In en, this message translates to:
  /// **'The same puzzle for everyone. A fresh start every day.'**
  String get dailyDescription;

  /// No description provided for @playDaily.
  ///
  /// In en, this message translates to:
  /// **'Play today\'s puzzle'**
  String get playDaily;

  /// No description provided for @dailyArchive.
  ///
  /// In en, this message translates to:
  /// **'Daily calendar'**
  String get dailyArchive;

  /// No description provided for @calendarDescription.
  ///
  /// In en, this message translates to:
  /// **'Missed a day? Past puzzles stay available.'**
  String get calendarDescription;

  /// No description provided for @freePlay.
  ///
  /// In en, this message translates to:
  /// **'Free play'**
  String get freePlay;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Preparing your puzzle…'**
  String get loading;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Your saved games could not be loaded. They have not been overwritten.'**
  String get loadFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Saving failed. Keep the app open and try again.'**
  String get saveFailed;

  /// No description provided for @generationFailed.
  ///
  /// In en, this message translates to:
  /// **'The puzzle could not be created. Please try again.'**
  String get generationFailed;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @erase.
  ///
  /// In en, this message translates to:
  /// **'Erase'**
  String get erase;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notesOn.
  ///
  /// In en, this message translates to:
  /// **'Notes on'**
  String get notesOn;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @pausedMessage.
  ///
  /// In en, this message translates to:
  /// **'Take your time. Your puzzle will be here.'**
  String get pausedMessage;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Nicely done.'**
  String get finished;

  /// No description provided for @finishedMessage.
  ///
  /// In en, this message translates to:
  /// **'Another puzzle, solved at your own pace.'**
  String get finishedMessage;

  /// No description provided for @pointsValue.
  ///
  /// In en, this message translates to:
  /// **'{points} points'**
  String pointsValue(int points);

  /// No description provided for @pointsLabel.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get pointsLabel;

  /// No description provided for @pointsAwarded.
  ///
  /// In en, this message translates to:
  /// **'+{points} points'**
  String pointsAwarded(int points);

  /// No description provided for @mistakesValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {1 mistake} other {{count} mistakes}}'**
  String mistakesValue(int count);

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Back to start'**
  String get backHome;

  /// No description provided for @timer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timer;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'{filled} / 81 filled'**
  String progress(int filled);

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @gameSettings.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get gameSettings;

  /// No description provided for @showTimer.
  ///
  /// In en, this message translates to:
  /// **'Show timer'**
  String get showTimer;

  /// No description provided for @showTimerDescription.
  ///
  /// In en, this message translates to:
  /// **'Hide the clock and play at your own pace.'**
  String get showTimerDescription;

  /// No description provided for @cleanNotes.
  ///
  /// In en, this message translates to:
  /// **'Clean up notes'**
  String get cleanNotes;

  /// No description provided for @cleanNotesDescription.
  ///
  /// In en, this message translates to:
  /// **'Remove a placed number from notes in its row, column and block.'**
  String get cleanNotesDescription;

  /// No description provided for @haptics.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get haptics;

  /// No description provided for @hapticsDescription.
  ///
  /// In en, this message translates to:
  /// **'A subtle tap on supported devices.'**
  String get hapticsDescription;

  /// No description provided for @numberFirst.
  ///
  /// In en, this message translates to:
  /// **'Number-first input'**
  String get numberFirst;

  /// No description provided for @numberFirstDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a number, then tap cells to place it.'**
  String get numberFirstDescription;

  /// No description provided for @errorCheck.
  ///
  /// In en, this message translates to:
  /// **'Error checking'**
  String get errorCheck;

  /// No description provided for @checkOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get checkOff;

  /// No description provided for @checkConflicts.
  ///
  /// In en, this message translates to:
  /// **'Rule conflicts'**
  String get checkConflicts;

  /// No description provided for @checkSolution.
  ///
  /// In en, this message translates to:
  /// **'Compare with solution'**
  String get checkSolution;

  /// No description provided for @errorDescription.
  ///
  /// In en, this message translates to:
  /// **'Controls only the markings on the board. Rule conflicts mark repeated digits in a row, column or box. Mistakes are always counted.'**
  String get errorDescription;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About Sudoku'**
  String get about;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'An open-source Sudoku app by Tom Vogel. Built with Flutter and Rudi UI. All game data stays on this device.'**
  String get aboutDescription;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 0.1.0'**
  String get version;

  /// No description provided for @storageDescription.
  ///
  /// In en, this message translates to:
  /// **'Browser data can be cleared by your browser. There is no cloud backup or device sync.'**
  String get storageDescription;

  /// No description provided for @noStatistics.
  ///
  /// In en, this message translates to:
  /// **'Your first puzzle is waiting.'**
  String get noStatistics;

  /// No description provided for @noStatisticsDescription.
  ///
  /// In en, this message translates to:
  /// **'Completed puzzles and your best times will appear here.'**
  String get noStatisticsDescription;

  /// No description provided for @solved.
  ///
  /// In en, this message translates to:
  /// **'Solved'**
  String get solved;

  /// No description provided for @bestTime.
  ///
  /// In en, this message translates to:
  /// **'Best time'**
  String get bestTime;

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Time played'**
  String get totalTime;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'Not played'**
  String get notStarted;

  /// No description provided for @futureDay.
  ///
  /// In en, this message translates to:
  /// **'Not available yet'**
  String get futureDay;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @cellLabel.
  ///
  /// In en, this message translates to:
  /// **'Row {row}, column {column}'**
  String cellLabel(int row, int column);

  /// No description provided for @givenValue.
  ///
  /// In en, this message translates to:
  /// **'Given: {value}'**
  String givenValue(int value);

  /// No description provided for @enteredValue.
  ///
  /// In en, this message translates to:
  /// **'Value: {value}'**
  String enteredValue(int value);

  /// No description provided for @emptyCell.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get emptyCell;

  /// No description provided for @candidates.
  ///
  /// In en, this message translates to:
  /// **'Notes: {values}'**
  String candidates(String values);

  /// No description provided for @incorrectValue.
  ///
  /// In en, this message translates to:
  /// **'Incorrect value'**
  String get incorrectValue;

  /// No description provided for @selectedNumber.
  ///
  /// In en, this message translates to:
  /// **'Selected number: {number}'**
  String selectedNumber(int number);

  /// No description provided for @keyboardHelp.
  ///
  /// In en, this message translates to:
  /// **'1–9: number · N: notes · Delete: erase · Arrow keys: move · Ctrl+Z: undo'**
  String get keyboardHelp;

  /// No description provided for @replaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new puzzle?'**
  String get replaceTitle;

  /// No description provided for @replaceMessage.
  ///
  /// In en, this message translates to:
  /// **'Your unfinished free-play puzzle will be replaced. Daily puzzles are kept separately.'**
  String get replaceMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @monthProgress.
  ///
  /// In en, this message translates to:
  /// **'{count} completed this month'**
  String monthProgress(int count);

  /// No description provided for @notesHelp.
  ///
  /// In en, this message translates to:
  /// **'Add small candidate numbers to an empty cell.'**
  String get notesHelp;

  /// No description provided for @chooseDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Choose a difficulty to begin.'**
  String get chooseDifficulty;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get licenses;

  /// No description provided for @licenseNote.
  ///
  /// In en, this message translates to:
  /// **'Sudoku is licensed under MIT. Rudi UI is MIT-licensed. Google Sans is licensed under the SIL Open Font License. Solar Icons: 480 Design, CC BY 4.0 (solar-icons.vercel.app). Flutter package solar_icons: Sebastine Odeh, BSD-3-Clause.'**
  String get licenseNote;

  /// No description provided for @boardMist.
  ///
  /// In en, this message translates to:
  /// **'Mist'**
  String get boardMist;

  /// No description provided for @selectDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Choose difficulty'**
  String get selectDifficulty;

  /// No description provided for @boardThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the look of your puzzle.'**
  String get boardThemeDescription;

  /// No description provided for @boardClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get boardClassic;

  /// No description provided for @customization.
  ///
  /// In en, this message translates to:
  /// **'Customization'**
  String get customization;

  /// No description provided for @boardPaper.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get boardPaper;

  /// No description provided for @boardTheme.
  ///
  /// In en, this message translates to:
  /// **'Board theme'**
  String get boardTheme;

  /// No description provided for @boardMidnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get boardMidnight;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your daily moment to puzzle.'**
  String get homeSubtitle;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// No description provided for @hintIncorrect.
  ///
  /// In en, this message translates to:
  /// **'First correct or erase your incorrect entries. Hints will not build on a wrong number.'**
  String get hintIncorrect;

  /// No description provided for @hintUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No next step was found with the supported techniques. No number will be guessed.'**
  String get hintUnavailable;

  /// No description provided for @hintLookHere.
  ///
  /// In en, this message translates to:
  /// **'Look here'**
  String get hintLookHere;

  /// No description provided for @hintLocateCell.
  ///
  /// In en, this message translates to:
  /// **'Start with {cell}.'**
  String hintLocateCell(String cell);

  /// No description provided for @hintLocateArea.
  ///
  /// In en, this message translates to:
  /// **'Look at how the highlighted cells relate to each other.'**
  String get hintLocateArea;

  /// No description provided for @hintReasonPlacement.
  ///
  /// In en, this message translates to:
  /// **'The highlighted numbers rule out every other possibility.'**
  String get hintReasonPlacement;

  /// No description provided for @hintReasonElimination.
  ///
  /// In en, this message translates to:
  /// **'The highlighted candidates restrict each other. Crossed-out candidates can be eliminated.'**
  String get hintReasonElimination;

  /// No description provided for @hintAnswerTitle.
  ///
  /// In en, this message translates to:
  /// **'Your next move'**
  String get hintAnswerTitle;

  /// No description provided for @hintExplainWhy.
  ///
  /// In en, this message translates to:
  /// **'Why?'**
  String get hintExplainWhy;

  /// No description provided for @hintContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get hintContinue;

  /// No description provided for @hintShowAnswer.
  ///
  /// In en, this message translates to:
  /// **'Show answer'**
  String get hintShowAnswer;

  /// No description provided for @hintExplanation.
  ///
  /// In en, this message translates to:
  /// **'Why does this work?'**
  String get hintExplanation;

  /// No description provided for @hintEnterValue.
  ///
  /// In en, this message translates to:
  /// **'Enter {digit} in {cell}.'**
  String hintEnterValue(String cell, int digit);

  /// No description provided for @hintBoardRelevant.
  ///
  /// In en, this message translates to:
  /// **'Relevant to the hint'**
  String get hintBoardRelevant;

  /// No description provided for @hintBoardCandidates.
  ///
  /// In en, this message translates to:
  /// **'Hint candidates: {digits}'**
  String hintBoardCandidates(String digits);

  /// No description provided for @hintBoardRemoved.
  ///
  /// In en, this message translates to:
  /// **'Eliminate from hint: {digits}'**
  String hintBoardRemoved(String digits);

  /// No description provided for @hintBoardResult.
  ///
  /// In en, this message translates to:
  /// **'Hint answer: {digit}'**
  String hintBoardResult(int digit);

  /// No description provided for @hintCell.
  ///
  /// In en, this message translates to:
  /// **'row {row}, column {column}'**
  String hintCell(int row, int column);

  /// No description provided for @hintRating.
  ///
  /// In en, this message translates to:
  /// **'Puzzle effort: {score} · {steps} logical steps · {bottlenecks} bottlenecks. A heuristic within the technique tier, not a solve-time prediction.'**
  String hintRating(int score, int steps, int bottlenecks);

  /// No description provided for @techniqueNakedSingle.
  ///
  /// In en, this message translates to:
  /// **'Only possible candidate'**
  String get techniqueNakedSingle;

  /// No description provided for @techniqueHiddenSingle.
  ///
  /// In en, this message translates to:
  /// **'Only place in a unit'**
  String get techniqueHiddenSingle;

  /// No description provided for @techniqueLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked candidates'**
  String get techniqueLocked;

  /// No description provided for @techniqueNakedPair.
  ///
  /// In en, this message translates to:
  /// **'Naked pair'**
  String get techniqueNakedPair;

  /// No description provided for @techniqueHiddenPair.
  ///
  /// In en, this message translates to:
  /// **'Hidden pair'**
  String get techniqueHiddenPair;

  /// No description provided for @techniqueNakedTriple.
  ///
  /// In en, this message translates to:
  /// **'Naked triple'**
  String get techniqueNakedTriple;

  /// No description provided for @techniqueHiddenTriple.
  ///
  /// In en, this message translates to:
  /// **'Hidden triple'**
  String get techniqueHiddenTriple;

  /// No description provided for @techniqueXWing.
  ///
  /// In en, this message translates to:
  /// **'X-Wing'**
  String get techniqueXWing;

  /// No description provided for @techniqueXYWing.
  ///
  /// In en, this message translates to:
  /// **'XY-Wing'**
  String get techniqueXYWing;

  /// No description provided for @hintNakedSingle.
  ///
  /// In en, this message translates to:
  /// **'In {cell}, the row, column and block exclude every digit except {digits}. Enter {digits} here.'**
  String hintNakedSingle(String cell, String digits);

  /// No description provided for @hintHiddenSingle.
  ///
  /// In en, this message translates to:
  /// **'Within the unit containing {cells}, {digits} can only go in {cell}. Enter {digits} here.'**
  String hintHiddenSingle(String cells, String digits, String cell);

  /// No description provided for @hintLocked.
  ///
  /// In en, this message translates to:
  /// **'All remaining positions for {digits} in a row, column or block lie in its intersection with another unit: {cells}. This locks the digit into that intersection, excluding it from the rest of the other unit.'**
  String hintLocked(String digits, String cells);

  /// No description provided for @hintNakedSubset.
  ///
  /// In en, this message translates to:
  /// **'The cells {cells} share a unit and have only the candidates {digits}. These digits occupy these cells in some order and can be removed from the other cells in the unit.'**
  String hintNakedSubset(String cells, String digits);

  /// No description provided for @hintHiddenSubset.
  ///
  /// In en, this message translates to:
  /// **'Within a shared unit, the digits {digits} occur as candidates only in {cells}. These cells are reserved for those digits; remove their other candidates.'**
  String hintHiddenSubset(String digits, String cells);

  /// No description provided for @hintXWing.
  ///
  /// In en, this message translates to:
  /// **'For {digits}, two rows (or columns) have exactly the same two possible columns (or rows): {cells}. One digit must occupy each crossing unit, so it cannot occur elsewhere in those units.'**
  String hintXWing(String digits, String cells);

  /// No description provided for @hintXYWing.
  ///
  /// In en, this message translates to:
  /// **'These three two-candidate cells form an XY-Wing: {cells}. The first cell is the pivot and sees the other two. Either pivot value forces {digits} in one of the wings. Cells seeing both wings cannot contain {digits}.'**
  String hintXYWing(String cells, String digits);

  /// No description provided for @hintCandidate.
  ///
  /// In en, this message translates to:
  /// **'{cell}: {digits}'**
  String hintCandidate(String cell, String digits);

  /// No description provided for @hintCandidates.
  ///
  /// In en, this message translates to:
  /// **'Candidates at this step: {evidence}'**
  String hintCandidates(String evidence);

  /// No description provided for @hintRemoval.
  ///
  /// In en, this message translates to:
  /// **'Remove {digits} from {cell}.'**
  String hintRemoval(String digits, String cell);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
