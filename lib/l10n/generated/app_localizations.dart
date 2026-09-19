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

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

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

  /// No description provided for @hintsUsedValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {1 hint} other {{count} hints}}'**
  String hintsUsedValue(int count);

  /// No description provided for @scoreBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Score breakdown'**
  String get scoreBreakdown;

  /// No description provided for @scorePuzzlePoints.
  ///
  /// In en, this message translates to:
  /// **'Board points'**
  String get scorePuzzlePoints;

  /// No description provided for @scoreCompletionBonus.
  ///
  /// In en, this message translates to:
  /// **'Completion bonus'**
  String get scoreCompletionBonus;

  /// No description provided for @scorePerfectBonus.
  ///
  /// In en, this message translates to:
  /// **'No-mistake bonus'**
  String get scorePerfectBonus;

  /// No description provided for @scoreDailyBonus.
  ///
  /// In en, this message translates to:
  /// **'Daily bonus'**
  String get scoreDailyBonus;

  /// No description provided for @scoreBeforeDeductions.
  ///
  /// In en, this message translates to:
  /// **'Score before deductions'**
  String get scoreBeforeDeductions;

  /// No description provided for @debugTools.
  ///
  /// In en, this message translates to:
  /// **'Debug tools'**
  String get debugTools;

  /// No description provided for @debugGameSimulator.
  ///
  /// In en, this message translates to:
  /// **'Game simulator'**
  String get debugGameSimulator;

  /// No description provided for @debugGameSimulatorDescription.
  ///
  /// In en, this message translates to:
  /// **'Set up the current puzzle for testing without solving every cell.'**
  String get debugGameSimulatorDescription;

  /// No description provided for @debugStartGameFirst.
  ///
  /// In en, this message translates to:
  /// **'Start or resume a game to use the simulator.'**
  String get debugStartGameFirst;

  /// No description provided for @debugFilledCells.
  ///
  /// In en, this message translates to:
  /// **'Filled cells'**
  String get debugFilledCells;

  /// No description provided for @debugMistakes.
  ///
  /// In en, this message translates to:
  /// **'Mistakes'**
  String get debugMistakes;

  /// No description provided for @debugHints.
  ///
  /// In en, this message translates to:
  /// **'Hints used'**
  String get debugHints;

  /// No description provided for @debugApplySimulation.
  ///
  /// In en, this message translates to:
  /// **'Apply simulation'**
  String get debugApplySimulation;

  /// No description provided for @debugValueRange.
  ///
  /// In en, this message translates to:
  /// **'Enter a value from {minimum} to {maximum}.'**
  String debugValueRange(int minimum, int maximum);

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
  /// **'Removes matching notes in its row, column and block.'**
  String get cleanNotesDescription;

  /// No description provided for @autoFillEnding.
  ///
  /// In en, this message translates to:
  /// **'Auto-fill ending'**
  String get autoFillEnding;

  /// No description provided for @autoFillEndingDescription.
  ///
  /// In en, this message translates to:
  /// **'Finishes the board near the end when every remaining step has only one possible number.'**
  String get autoFillEndingDescription;

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
  /// **'Choose a number, then tap the cells.'**
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
  /// **'Your statistics will appear once you solve a puzzle.'**
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

  /// No description provided for @solveTimeEstimate.
  ///
  /// In en, this message translates to:
  /// **'About {time}'**
  String solveTimeEstimate(String time);

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

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Help & feedback'**
  String get support;

  /// No description provided for @repository.
  ///
  /// In en, this message translates to:
  /// **'GitHub repository'**
  String get repository;

  /// No description provided for @reportBug.
  ///
  /// In en, this message translates to:
  /// **'Report a bug'**
  String get reportBug;

  /// No description provided for @linkOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link. You can copy the address below.'**
  String get linkOpenError;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build})'**
  String versionLabel(String version, String build);

  /// No description provided for @versionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Version unavailable'**
  String get versionUnavailable;

  /// No description provided for @licensesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load licenses. Please try again.'**
  String get licensesLoadError;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @licensesLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading licenses...'**
  String get licensesLoading;

  /// No description provided for @featureRequest.
  ///
  /// In en, this message translates to:
  /// **'Request a feature'**
  String get featureRequest;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get systemLanguage;

  /// No description provided for @systemThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow your device appearance'**
  String get systemThemeDescription;

  /// No description provided for @lightThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Always use the light theme'**
  String get lightThemeDescription;

  /// No description provided for @darkThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Always use the dark theme'**
  String get darkThemeDescription;

  /// No description provided for @learnSudoku.
  ///
  /// In en, this message translates to:
  /// **'Learn Sudoku'**
  String get learnSudoku;

  /// No description provided for @learnHomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Build your skills step by step, from the rules to advanced patterns.'**
  String get learnHomeDescription;

  /// No description provided for @learnPathTitle.
  ///
  /// In en, this message translates to:
  /// **'Your skill path'**
  String get learnPathTitle;

  /// No description provided for @learnPathDescription.
  ///
  /// In en, this message translates to:
  /// **'Eight short lessons. Each check unlocks the next skill.'**
  String get learnPathDescription;

  /// No description provided for @learnNoPoints.
  ///
  /// In en, this message translates to:
  /// **'Practice mode · no points, times, or statistics'**
  String get learnNoPoints;

  /// No description provided for @learnProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} lessons completed'**
  String learnProgress(int completed, int total);

  /// No description provided for @learnLocked.
  ///
  /// In en, this message translates to:
  /// **'Complete the previous lesson first.'**
  String get learnLocked;

  /// No description provided for @learnCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get learnCompleted;

  /// No description provided for @learnStart.
  ///
  /// In en, this message translates to:
  /// **'Start lesson'**
  String get learnStart;

  /// No description provided for @learnRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat lesson'**
  String get learnRepeat;

  /// No description provided for @learnKnowledgeCheck.
  ///
  /// In en, this message translates to:
  /// **'Knowledge check'**
  String get learnKnowledgeCheck;

  /// No description provided for @learnCheckAnswer.
  ///
  /// In en, this message translates to:
  /// **'Check answer'**
  String get learnCheckAnswer;

  /// No description provided for @learnCorrect.
  ///
  /// In en, this message translates to:
  /// **'Exactly right.'**
  String get learnCorrect;

  /// No description provided for @learnIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Not quite. Revisit the explanation and try again.'**
  String get learnIncorrect;

  /// No description provided for @learnChooseAnswer.
  ///
  /// In en, this message translates to:
  /// **'Choose an answer first.'**
  String get learnChooseAnswer;

  /// No description provided for @learnExternalTutorial.
  ///
  /// In en, this message translates to:
  /// **'Watch an external tutorial'**
  String get learnExternalTutorial;

  /// No description provided for @learnExternalNotice.
  ///
  /// In en, this message translates to:
  /// **'Opens YouTube in your browser. No connection is made until you tap the link; YouTube\'s privacy terms then apply.'**
  String get learnExternalNotice;

  /// No description provided for @learnStartPractice.
  ///
  /// In en, this message translates to:
  /// **'Start practice'**
  String get learnStartPractice;

  /// No description provided for @learnContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get learnContinue;

  /// No description provided for @learnFinishLesson.
  ///
  /// In en, this message translates to:
  /// **'Finish lesson'**
  String get learnFinishLesson;

  /// No description provided for @learnBackToPath.
  ///
  /// In en, this message translates to:
  /// **'Back to skill path'**
  String get learnBackToPath;

  /// No description provided for @learnLessonCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson complete!'**
  String get learnLessonCompleteTitle;

  /// No description provided for @learnLessonCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'You understood both patterns. The next stop on your path is ready.'**
  String get learnLessonCompleteBody;

  /// No description provided for @learnQuestionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String learnQuestionProgress(int current, int total);

  /// No description provided for @learnTutorialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Go deeper'**
  String get learnTutorialsTitle;

  /// No description provided for @learnTutorialBy.
  ///
  /// In en, this message translates to:
  /// **'{creator} · YouTube'**
  String learnTutorialBy(String creator);

  /// No description provided for @learnLessonRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'The Sudoku rules'**
  String get learnLessonRulesTitle;

  /// No description provided for @learnLessonRulesSummary.
  ///
  /// In en, this message translates to:
  /// **'Understand rows, columns, blocks, and the no-guessing mindset.'**
  String get learnLessonRulesSummary;

  /// No description provided for @learnLessonRulesBody.
  ///
  /// In en, this message translates to:
  /// **'Fill every empty cell with a digit from 1 to 9. Every row, every column, and every 3×3 block must contain each digit exactly once. A well-formed puzzle can be solved with logic: place a digit only when the current grid proves it.'**
  String get learnLessonRulesBody;

  /// No description provided for @learnLessonRulesQuestion.
  ///
  /// In en, this message translates to:
  /// **'A 7 already appears in a cell\'s row. What follows?'**
  String get learnLessonRulesQuestion;

  /// No description provided for @learnLessonRulesA.
  ///
  /// In en, this message translates to:
  /// **'The cell cannot contain 7'**
  String get learnLessonRulesA;

  /// No description provided for @learnLessonRulesB.
  ///
  /// In en, this message translates to:
  /// **'The cell must contain 7'**
  String get learnLessonRulesB;

  /// No description provided for @learnLessonRulesC.
  ///
  /// In en, this message translates to:
  /// **'The row no longer matters'**
  String get learnLessonRulesC;

  /// No description provided for @learnLessonRulesQ2.
  ///
  /// In en, this message translates to:
  /// **'The highlighted 3×3 block already contains 1 through 8. Which digit completes it?'**
  String get learnLessonRulesQ2;

  /// No description provided for @learnLessonRulesQ2A.
  ///
  /// In en, this message translates to:
  /// **'9'**
  String get learnLessonRulesQ2A;

  /// No description provided for @learnLessonRulesQ2B.
  ///
  /// In en, this message translates to:
  /// **'Any digit missing from the row'**
  String get learnLessonRulesQ2B;

  /// No description provided for @learnLessonRulesQ2C.
  ///
  /// In en, this message translates to:
  /// **'You have to guess'**
  String get learnLessonRulesQ2C;

  /// No description provided for @learnLessonRulesQ2Why.
  ///
  /// In en, this message translates to:
  /// **'Every block contains 1 through 9 exactly once, so the only missing digit is 9.'**
  String get learnLessonRulesQ2Why;

  /// No description provided for @learnLessonCandidatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Candidates and notes'**
  String get learnLessonCandidatesTitle;

  /// No description provided for @learnLessonCandidatesSummary.
  ///
  /// In en, this message translates to:
  /// **'Turn exclusions into a small, useful candidate list.'**
  String get learnLessonCandidatesSummary;

  /// No description provided for @learnLessonCandidatesBody.
  ///
  /// In en, this message translates to:
  /// **'A candidate is a digit that is not already excluded by the cell\'s row, column, or block. Notes are working information, not guesses. Update them when a placement removes a possibility nearby.'**
  String get learnLessonCandidatesBody;

  /// No description provided for @learnLessonCandidatesQuestion.
  ///
  /// In en, this message translates to:
  /// **'When should a digit be written as a candidate?'**
  String get learnLessonCandidatesQuestion;

  /// No description provided for @learnLessonCandidatesA.
  ///
  /// In en, this message translates to:
  /// **'Whenever it looks likely'**
  String get learnLessonCandidatesA;

  /// No description provided for @learnLessonCandidatesB.
  ///
  /// In en, this message translates to:
  /// **'Only when row, column, and block allow it'**
  String get learnLessonCandidatesB;

  /// No description provided for @learnLessonCandidatesC.
  ///
  /// In en, this message translates to:
  /// **'Only after making a guess'**
  String get learnLessonCandidatesC;

  /// No description provided for @learnLessonCandidatesQ2.
  ///
  /// In en, this message translates to:
  /// **'The highlighted cell sees 1 and 2 in its row, 3 and 4 in its column, and 5 and 6 in its block. Which candidates remain?'**
  String get learnLessonCandidatesQ2;

  /// No description provided for @learnLessonCandidatesQ2A.
  ///
  /// In en, this message translates to:
  /// **'7, 8, and 9'**
  String get learnLessonCandidatesQ2A;

  /// No description provided for @learnLessonCandidatesQ2B.
  ///
  /// In en, this message translates to:
  /// **'1, 2, and 3'**
  String get learnLessonCandidatesQ2B;

  /// No description provided for @learnLessonCandidatesQ2C.
  ///
  /// In en, this message translates to:
  /// **'4, 5, and 6'**
  String get learnLessonCandidatesQ2C;

  /// No description provided for @learnLessonCandidatesQ2Why.
  ///
  /// In en, this message translates to:
  /// **'Only 7, 8, and 9 survive all three checks. Candidates are possibilities, not guesses.'**
  String get learnLessonCandidatesQ2Why;

  /// No description provided for @learnLessonNakedSingleSummary.
  ///
  /// In en, this message translates to:
  /// **'Find a cell with exactly one candidate left.'**
  String get learnLessonNakedSingleSummary;

  /// No description provided for @learnLessonNakedSingleBody.
  ///
  /// In en, this message translates to:
  /// **'If eight digits are excluded from one cell, its remaining candidate is forced. This is a naked single: the answer is visible directly in that cell\'s candidate list.'**
  String get learnLessonNakedSingleBody;

  /// No description provided for @learnLessonNakedSingleQuestion.
  ///
  /// In en, this message translates to:
  /// **'A cell has only candidate 4. What is the logical move?'**
  String get learnLessonNakedSingleQuestion;

  /// No description provided for @learnLessonNakedSingleA.
  ///
  /// In en, this message translates to:
  /// **'Enter 4'**
  String get learnLessonNakedSingleA;

  /// No description provided for @learnLessonNakedSingleB.
  ///
  /// In en, this message translates to:
  /// **'Erase the note 4'**
  String get learnLessonNakedSingleB;

  /// No description provided for @learnLessonNakedSingleC.
  ///
  /// In en, this message translates to:
  /// **'Wait for a second candidate'**
  String get learnLessonNakedSingleC;

  /// No description provided for @learnLessonNakedSingleQ2.
  ///
  /// In en, this message translates to:
  /// **'The highlighted cell has candidates 3 and 8. Is this already a naked single?'**
  String get learnLessonNakedSingleQ2;

  /// No description provided for @learnLessonNakedSingleQ2A.
  ///
  /// In en, this message translates to:
  /// **'No, two possibilities remain'**
  String get learnLessonNakedSingleQ2A;

  /// No description provided for @learnLessonNakedSingleQ2B.
  ///
  /// In en, this message translates to:
  /// **'Yes, enter 3'**
  String get learnLessonNakedSingleQ2B;

  /// No description provided for @learnLessonNakedSingleQ2C.
  ///
  /// In en, this message translates to:
  /// **'Yes, enter 8'**
  String get learnLessonNakedSingleQ2C;

  /// No description provided for @learnLessonNakedSingleQ2Why.
  ///
  /// In en, this message translates to:
  /// **'A naked single requires exactly one remaining candidate. With two candidates, more information is needed.'**
  String get learnLessonNakedSingleQ2Why;

  /// No description provided for @learnLessonHiddenSingleSummary.
  ///
  /// In en, this message translates to:
  /// **'Find the only place for a digit inside one unit.'**
  String get learnLessonHiddenSingleSummary;

  /// No description provided for @learnLessonHiddenSingleBody.
  ///
  /// In en, this message translates to:
  /// **'A cell may have several candidates, yet one of them can be unique within its row, column, or block. If 6 appears as a candidate in only one cell of that unit, 6 is forced there.'**
  String get learnLessonHiddenSingleBody;

  /// No description provided for @learnLessonHiddenSingleQuestion.
  ///
  /// In en, this message translates to:
  /// **'In a block, only one cell can contain 6. That cell also allows 2. What can you place?'**
  String get learnLessonHiddenSingleQuestion;

  /// No description provided for @learnLessonHiddenSingleA.
  ///
  /// In en, this message translates to:
  /// **'Nothing, because it has two notes'**
  String get learnLessonHiddenSingleA;

  /// No description provided for @learnLessonHiddenSingleB.
  ///
  /// In en, this message translates to:
  /// **'6, because it has the only place in the block'**
  String get learnLessonHiddenSingleB;

  /// No description provided for @learnLessonHiddenSingleC.
  ///
  /// In en, this message translates to:
  /// **'2, because it is smaller'**
  String get learnLessonHiddenSingleC;

  /// No description provided for @learnLessonHiddenSingleQ2.
  ///
  /// In en, this message translates to:
  /// **'Why is 6 forced in the highlighted cell even though that cell also allows 2?'**
  String get learnLessonHiddenSingleQ2;

  /// No description provided for @learnLessonHiddenSingleQ2A.
  ///
  /// In en, this message translates to:
  /// **'It is the only cell in the row that allows 6'**
  String get learnLessonHiddenSingleQ2A;

  /// No description provided for @learnLessonHiddenSingleQ2B.
  ///
  /// In en, this message translates to:
  /// **'6 is always stronger than 2'**
  String get learnLessonHiddenSingleQ2B;

  /// No description provided for @learnLessonHiddenSingleQ2C.
  ///
  /// In en, this message translates to:
  /// **'The highlighted cell must use its largest candidate'**
  String get learnLessonHiddenSingleQ2C;

  /// No description provided for @learnLessonHiddenSingleQ2Why.
  ///
  /// In en, this message translates to:
  /// **'Look digit-first: every other cell in the row excludes 6, so this is 6\'s only place.'**
  String get learnLessonHiddenSingleQ2Why;

  /// No description provided for @learnLessonLockedSummary.
  ///
  /// In en, this message translates to:
  /// **'Use the overlap between a block and a row or column.'**
  String get learnLessonLockedSummary;

  /// No description provided for @learnLessonLockedBody.
  ///
  /// In en, this message translates to:
  /// **'If every candidate for a digit in a block lies on the same row, that digit is locked into the block-row intersection. Remove it from the rest of that row. The same logic works with columns.'**
  String get learnLessonLockedBody;

  /// No description provided for @learnLessonLockedQuestion.
  ///
  /// In en, this message translates to:
  /// **'All possible 5s in a block lie in row 3. Where can 5 be removed?'**
  String get learnLessonLockedQuestion;

  /// No description provided for @learnLessonLockedA.
  ///
  /// In en, this message translates to:
  /// **'From the rest of row 3 outside that block'**
  String get learnLessonLockedA;

  /// No description provided for @learnLessonLockedB.
  ///
  /// In en, this message translates to:
  /// **'From every cell in the block'**
  String get learnLessonLockedB;

  /// No description provided for @learnLessonLockedC.
  ///
  /// In en, this message translates to:
  /// **'From all other rows'**
  String get learnLessonLockedC;

  /// No description provided for @learnLessonLockedQ2.
  ///
  /// In en, this message translates to:
  /// **'In the highlighted row, every possible 4 lies inside the middle block. Where can 4 be removed?'**
  String get learnLessonLockedQ2;

  /// No description provided for @learnLessonLockedQ2A.
  ///
  /// In en, this message translates to:
  /// **'From the other cells of that block'**
  String get learnLessonLockedQ2A;

  /// No description provided for @learnLessonLockedQ2B.
  ///
  /// In en, this message translates to:
  /// **'From the entire highlighted row'**
  String get learnLessonLockedQ2B;

  /// No description provided for @learnLessonLockedQ2C.
  ///
  /// In en, this message translates to:
  /// **'Nowhere; a placement is required first'**
  String get learnLessonLockedQ2C;

  /// No description provided for @learnLessonLockedQ2Why.
  ///
  /// In en, this message translates to:
  /// **'This is claiming: the row claims its 4 inside one block, so the block cannot contain 4 outside that row.'**
  String get learnLessonLockedQ2Why;

  /// No description provided for @learnLessonPairsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pairs'**
  String get learnLessonPairsTitle;

  /// No description provided for @learnLessonPairsSummary.
  ///
  /// In en, this message translates to:
  /// **'Reserve two digits for two cells.'**
  String get learnLessonPairsSummary;

  /// No description provided for @learnLessonPairsBody.
  ///
  /// In en, this message translates to:
  /// **'A naked pair is two cells in one unit containing the same two candidates; those digits can be removed from other cells in the unit. A hidden pair is two digits that occur only in the same two cells; other notes can be removed from those cells.'**
  String get learnLessonPairsBody;

  /// No description provided for @learnLessonPairsQuestion.
  ///
  /// In en, this message translates to:
  /// **'Two cells in a row both contain only 2 and 8. What follows?'**
  String get learnLessonPairsQuestion;

  /// No description provided for @learnLessonPairsA.
  ///
  /// In en, this message translates to:
  /// **'2 and 8 can be removed from the other cells in that row'**
  String get learnLessonPairsA;

  /// No description provided for @learnLessonPairsB.
  ///
  /// In en, this message translates to:
  /// **'Both cells must be 2'**
  String get learnLessonPairsB;

  /// No description provided for @learnLessonPairsC.
  ///
  /// In en, this message translates to:
  /// **'The pair has no effect'**
  String get learnLessonPairsC;

  /// No description provided for @learnLessonPairsQ2.
  ///
  /// In en, this message translates to:
  /// **'Only the two highlighted cells in a column can contain 4 or 7. They also contain other notes. What is the hidden-pair move?'**
  String get learnLessonPairsQ2;

  /// No description provided for @learnLessonPairsQ2A.
  ///
  /// In en, this message translates to:
  /// **'Keep only 4 and 7 in those two cells'**
  String get learnLessonPairsQ2A;

  /// No description provided for @learnLessonPairsQ2B.
  ///
  /// In en, this message translates to:
  /// **'Remove 4 and 7 from those two cells'**
  String get learnLessonPairsQ2B;

  /// No description provided for @learnLessonPairsQ2C.
  ///
  /// In en, this message translates to:
  /// **'Place 4 in both cells'**
  String get learnLessonPairsQ2C;

  /// No description provided for @learnLessonPairsQ2Why.
  ///
  /// In en, this message translates to:
  /// **'The two cells are reserved for 4 and 7 in some order, so their other candidates can be removed.'**
  String get learnLessonPairsQ2Why;

  /// No description provided for @learnLessonTriplesTitle.
  ///
  /// In en, this message translates to:
  /// **'Triples'**
  String get learnLessonTriplesTitle;

  /// No description provided for @learnLessonTriplesSummary.
  ///
  /// In en, this message translates to:
  /// **'Extend subset logic from two cells to three.'**
  String get learnLessonTriplesSummary;

  /// No description provided for @learnLessonTriplesBody.
  ///
  /// In en, this message translates to:
  /// **'Three cells in one unit can reserve exactly three digits even when not every cell shows all three. For a naked triple, the union of their candidates has size three. Hidden triples use the inverse view: three digits occur nowhere else in the unit.'**
  String get learnLessonTriplesBody;

  /// No description provided for @learnLessonTriplesQuestion.
  ///
  /// In en, this message translates to:
  /// **'Three cells in one row use only the combined candidates 1, 4, and 9. What may you do?'**
  String get learnLessonTriplesQuestion;

  /// No description provided for @learnLessonTriplesA.
  ///
  /// In en, this message translates to:
  /// **'Remove 1, 4, and 9 from the row\'s other cells'**
  String get learnLessonTriplesA;

  /// No description provided for @learnLessonTriplesB.
  ///
  /// In en, this message translates to:
  /// **'Put all three digits into each cell'**
  String get learnLessonTriplesB;

  /// No description provided for @learnLessonTriplesC.
  ///
  /// In en, this message translates to:
  /// **'Remove every other candidate from the row'**
  String get learnLessonTriplesC;

  /// No description provided for @learnLessonTriplesQ2.
  ///
  /// In en, this message translates to:
  /// **'In one block, the digits 2, 5, and 6 occur only in three highlighted cells. What does the hidden triple allow?'**
  String get learnLessonTriplesQ2;

  /// No description provided for @learnLessonTriplesQ2A.
  ///
  /// In en, this message translates to:
  /// **'Remove other candidates from those three cells'**
  String get learnLessonTriplesQ2A;

  /// No description provided for @learnLessonTriplesQ2B.
  ///
  /// In en, this message translates to:
  /// **'Remove 2, 5, and 6 from those three cells'**
  String get learnLessonTriplesQ2B;

  /// No description provided for @learnLessonTriplesQ2C.
  ///
  /// In en, this message translates to:
  /// **'Place all three digits immediately'**
  String get learnLessonTriplesQ2C;

  /// No description provided for @learnLessonTriplesQ2Why.
  ///
  /// In en, this message translates to:
  /// **'Those three cells must contain 2, 5, and 6 in some order. Notes outside that set can be cleared from the three cells.'**
  String get learnLessonTriplesQ2Why;

  /// No description provided for @learnLessonWingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Wings: X-Wing and XY-Wing'**
  String get learnLessonWingsTitle;

  /// No description provided for @learnLessonWingsSummary.
  ///
  /// In en, this message translates to:
  /// **'Read linked candidate patterns across multiple units.'**
  String get learnLessonWingsSummary;

  /// No description provided for @learnLessonWingsBody.
  ///
  /// In en, this message translates to:
  /// **'An X-Wing uses one digit in two rows and the same two columns, allowing eliminations in those columns. An XY-Wing uses three two-candidate cells: a pivot sees two wings, and either pivot value forces the shared wing candidate. These are elimination patterns, not guesses.'**
  String get learnLessonWingsBody;

  /// No description provided for @learnLessonWingsQuestion.
  ///
  /// In en, this message translates to:
  /// **'Candidate 5 forms the four corners of the highlighted rectangle across two rows and two columns. What is the X-Wing conclusion?'**
  String get learnLessonWingsQuestion;

  /// No description provided for @learnLessonWingsA.
  ///
  /// In en, this message translates to:
  /// **'Remove 5 from other cells in the two columns'**
  String get learnLessonWingsA;

  /// No description provided for @learnLessonWingsB.
  ///
  /// In en, this message translates to:
  /// **'Place 5 in all four corners'**
  String get learnLessonWingsB;

  /// No description provided for @learnLessonWingsC.
  ///
  /// In en, this message translates to:
  /// **'Remove every other candidate from the corners'**
  String get learnLessonWingsC;

  /// No description provided for @learnLessonWingsQ2.
  ///
  /// In en, this message translates to:
  /// **'The pivot has 2/3; its wings have 2/7 and 3/7. What can a cell that sees both wings lose?'**
  String get learnLessonWingsQ2;

  /// No description provided for @learnLessonWingsQ2A.
  ///
  /// In en, this message translates to:
  /// **'2'**
  String get learnLessonWingsQ2A;

  /// No description provided for @learnLessonWingsQ2B.
  ///
  /// In en, this message translates to:
  /// **'3'**
  String get learnLessonWingsQ2B;

  /// No description provided for @learnLessonWingsQ2C.
  ///
  /// In en, this message translates to:
  /// **'7'**
  String get learnLessonWingsQ2C;

  /// No description provided for @learnLessonWingsQ2Why.
  ///
  /// In en, this message translates to:
  /// **'Whichever value the pivot takes, one wing must become 7. A cell seeing both wings therefore cannot be 7.'**
  String get learnLessonWingsQ2Why;
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
