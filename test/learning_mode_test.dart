import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/app/sudoku_app.dart';
import 'package:sudoku/features/game/data/game_providers.dart';
import 'package:sudoku/features/game/data/game_repository.dart';
import 'package:sudoku/features/game/presentation/sudoku_board.dart';
import 'package:sudoku/features/learn/domain/learning_lesson.dart';
import 'package:sudoku/features/learn/domain/learning_progress.dart';
import 'package:sudoku/features/learn/presentation/learn_lesson_page.dart';
import 'package:sudoku/l10n/generated/app_localizations_en.dart';

import 'controller_harness.dart';
import 'storage_controller_test.dart' show MemoryStore;

void main() {
  test(
    'learning progress unlocks skills in order and survives persistence',
    () {
      var progress = LearningProgress.empty();

      expect(progress.isUnlocked(LearningSkill.rules), isTrue);
      expect(progress.isUnlocked(LearningSkill.candidates), isFalse);
      expect(progress.completeSkill(LearningSkill.candidates), same(progress));

      progress = progress.completeSkill(LearningSkill.rules);
      expect(progress.isCompleted(LearningSkill.rules), isTrue);
      expect(progress.isUnlocked(LearningSkill.candidates), isTrue);

      final restored = LearningProgress.fromJson(progress.toJson());
      expect(restored.completedSkills, {LearningSkill.rules});
    },
  );

  test('every lesson has two valid visual checks and curated videos', () {
    final lessons = learningLessons(AppLocalizationsEn());

    expect(lessons.length, LearningSkill.values.length);
    for (final lesson in lessons) {
      expect(lesson.questions.length, 2, reason: lesson.title);
      expect(lesson.tutorials, isNotEmpty, reason: lesson.title);
      for (final question in lesson.questions) {
        expect(question.answers.length, 3, reason: question.prompt);
        expect(
          question.correctAnswer,
          inInclusiveRange(0, question.answers.length - 1),
        );
        expect(question.board.values.length, 81);
        for (final entry in question.board.removedCandidates.entries) {
          expect(
            question.board.candidates[entry.key],
            containsAll(entry.value),
            reason: question.prompt,
          );
        }
      }
      for (final tutorial in lesson.tutorials) {
        expect(tutorial.uri.host, 'www.youtube.com');
        expect(tutorial.uri.path, '/watch');
        expect(tutorial.uri.queryParameters['v'], isNotEmpty);
      }
    }
  });

  test('older version 2 snapshots default to an empty learning path', () {
    final json = jsonDecode(SavedGames().encode()) as Map<String, Object?>
      ..remove('learningProgress');

    final restored = SavedGames.decode(jsonEncode(json));

    expect(restored.learningProgress.completedCount, 0);
  });

  test('completing a lesson adds no points or game result', () async {
    final store = MemoryStore();
    final harness = ControllerHarness(GameRepository(store));
    final controller = harness.controller;
    await controller.initialize();

    controller.completeLearningSkill(LearningSkill.rules);
    await controller.persist();

    expect(controller.totalPoints, 0);
    expect(controller.results, isEmpty);
    expect(controller.learningProgress.completedCount, 1);
    final restored = SavedGames.decode(store.value!);
    expect(restored.learningProgress.isCompleted(LearningSkill.rules), isTrue);
    harness.dispose();
  });

  testWidgets('direct URLs do not expose locked lesson content', (
    tester,
  ) async {
    final store = MemoryStore();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameRepositoryProvider.overrideWithValue(GameRepository(store)),
        ],
        child: const SudokuApp(
          locale: Locale('en'),
          initialLocation: '/learn/wings',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('learning-path')), findsOneWidget);
    expect(find.byType(LearnLessonPage), findsNothing);
  });

  testWidgets(
    'learning path completes a local check and unlocks the next skill',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final store = MemoryStore();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameRepositoryProvider.overrideWithValue(GameRepository(store)),
          ],
          child: const SudokuApp(
            locale: Locale('de'),
            initialLocation: '/learn',
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Sudoku lernen'), findsWidgets);
      expect(find.textContaining('keine Punkte'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('lesson-rules')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SudokuBoardView), findsOneWidget);
      expect(find.byKey(const ValueKey('board-grid')), findsOneWidget);
      final progressBar = find.byKey(const ValueKey('lesson-progress'));
      double progressWidth() => tester
          .widget<FractionallySizedBox>(
            find.descendant(
              of: progressBar,
              matching: find.byType(FractionallySizedBox),
            ),
          )
          .widthFactor!;
      expect(progressWidth(), 0);
      await tester.tap(find.byKey(const ValueKey('check-learning-answer')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      expect(progressWidth(), inExclusiveRange(0, .5));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('lesson-answer-0')),
        240,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.byKey(const ValueKey('lesson-answer-0')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('check-learning-answer')));
      await tester.pump();

      expect(find.byKey(const ValueKey('learning-feedback')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('check-learning-answer')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('lesson-answer-0')),
        240,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.byKey(const ValueKey('lesson-answer-0')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('check-learning-answer')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('check-learning-answer')));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Lektion geschafft!'), findsOneWidget);
      final backButton = find.byKey(const ValueKey('back-to-learning-path'));
      expect(backButton, findsOneWidget);
      expect(tester.getBottomLeft(backButton).dy, greaterThan(760));
      expect(tester.takeException(), isNull);
    },
  );
}
