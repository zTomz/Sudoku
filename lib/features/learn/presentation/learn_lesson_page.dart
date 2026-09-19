import 'package:cue/cue.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:rudi_ui/rudi_ui.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../../app/sudoku_controller.dart';
import '../../../common/presentation/external_link.dart';
import '../../../common/presentation/ui.dart';
import '../../settings/domain/app_settings.dart';
import '../domain/learning_lesson.dart';
import '../domain/learning_progress.dart';
import 'learn_page.dart';
import 'widgets/learning_board.dart';
import 'widgets/learning_progress_bar.dart';

enum _LessonStage() {
  introduction,
  question,
  complete,
}

final class const LearnLessonPage({
  required final SudokuController controller,
  required final LearningSkill skill,
  super.key,
}) extends StatefulWidget {
  static String pathFor(LearningSkill skill) => '/learn/${skill.name}';

  @override
  State<LearnLessonPage> createState() => _LearnLessonPageState();
}

final class _LearnLessonPageState() extends State<LearnLessonPage> {
  _LessonStage _stage = .introduction;
  int _questionIndex = 0;
  int? _selectedAnswer;
  bool _checked = false;

  void _start() => setState(() => _stage = .question);

  void _select(int answer) {
    if (_checked && _selectedAnswer == _currentQuestion.correctAnswer) return;
    setState(() {
      _selectedAnswer = answer;
      _checked = false;
    });
  }

  late LearningLesson _lesson;
  LearningQuestion get _currentQuestion => _lesson.questions[_questionIndex];
  bool get _correct =>
      _selectedAnswer != null &&
      _selectedAnswer == _currentQuestion.correctAnswer;

  void _primaryAction() {
    if (_stage == .introduction) {
      _start();
      return;
    }
    if (!_checked || !_correct) {
      setState(() => _checked = true);
      return;
    }
    if (_questionIndex < _lesson.questions.length - 1) {
      setState(() {
        _questionIndex++;
        _selectedAnswer = null;
        _checked = false;
      });
      return;
    }
    widget.controller.completeLearningSkill(_lesson.skill);
    setState(() => _stage = .complete);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    _lesson = learningLessons(l)
        .firstWhere((lesson) => lesson.skill == widget.skill);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return RudiPage(
      padding: .zero,
      child: Column(
        children: [
          _LessonHeader(
            lesson: _lesson,
            stage: _stage,
            questionIndex: _questionIndex,
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Cue.onChange(
                  value: '$_stage-$_questionIndex',
                  motion: reduceMotion ? CueMotion.none : .smooth(),
                  acts: [.fadeIn(), .slideX(from: .06)],
                  child: switch (_stage) {
                    .introduction => _LessonIntroduction(
                      lesson: _lesson,
                      boardTheme: widget.controller.settings.boardTheme,
                    ),
                    .question => _QuestionView(
                      question: _currentQuestion,
                      boardTheme: widget.controller.settings.boardTheme,
                      selectedAnswer: _selectedAnswer,
                      checked: _checked,
                      onSelected: _select,
                    ),
                    .complete => _LessonComplete(lesson: _lesson),
                  },
                ),
              ),
            ),
          ),
          _BottomAction(
            buttonKey: _stage == .complete
                ? const ValueKey('back-to-learning-path')
                : const ValueKey('check-learning-answer'),
            label: switch (_stage) {
              .introduction => l.learnStartPractice,
              .question when _checked && _correct =>
                _questionIndex == _lesson.questions.length - 1
                    ? l.learnFinishLesson
                    : l.learnContinue,
              .question => l.learnCheckAnswer,
              .complete => l.learnBackToPath,
            },
            onPressed: _stage == .complete
                ? () => context.go(LearnPage.path)
                : _primaryAction,
          ),
        ],
      ),
    );
  }
}

final class const _LessonHeader({
  required final LearningLesson lesson,
  required final _LessonStage stage,
  required final int questionIndex,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final progress = switch (stage) {
      .introduction => 0.0,
      .question => (questionIndex + 1) / lesson.questions.length,
      .complete => 1.0,
    };
    return Padding(
      padding: const .fromLTRB(8, 4, 16, 8),
      child: Row(
        children: [
          RudiIconButton(
            icon: const RotatedBox(
              quarterTurns: 2,
              child: Icon(SolarIconsOutline.altArrowRight, size: 24),
            ),
            semanticLabel: context.l10n.back,
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lesson.title,
                        maxLines: 1,
                        overflow: .ellipsis,
                        style: theme.text.label,
                      ),
                    ),
                    if (stage == .question)
                      Text(
                        context.l10n.learnQuestionProgress(
                          questionIndex + 1,
                          lesson.questions.length,
                        ),
                        style: theme.text.caption.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 7),
                LearningProgressBar(
                  key: const ValueKey('lesson-progress'),
                  progress: progress,
                  height: 7,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class const _LessonIntroduction({
  required final LearningLesson lesson,
  required final BoardTheme boardTheme,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        MediaQuery.sizeOf(context).width < 600 ? 24 : 48,
        20,
        MediaQuery.sizeOf(context).width < 600 ? 24 : 48,
        36,
      ),
      children: [
        Text(lesson.title, style: theme.text.display),
        const SizedBox(height: 8),
        Text(
          lesson.summary,
          style: theme.text.body.copyWith(color: theme.colors.mutedForeground),
        ),
        const SizedBox(height: 28),
        LearningBoardView(
          board: lesson.questions.first.board,
          boardTheme: boardTheme,
        ),
        const SizedBox(height: 28),
        Text(lesson.explanation, style: theme.text.body.copyWith(height: 1.55)),
      ],
    );
  }
}

final class const _QuestionView({
  required final LearningQuestion question,
  required final BoardTheme boardTheme,
  required final int? selectedAnswer,
  required final bool checked,
  required final ValueChanged<int> onSelected,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final correct = selectedAnswer == question.correctAnswer;
    return ListView(
      key: const ValueKey('learning-question'),
      padding: EdgeInsets.fromLTRB(
        MediaQuery.sizeOf(context).width < 600 ? 20 : 48,
        16,
        MediaQuery.sizeOf(context).width < 600 ? 20 : 48,
        32,
      ),
      children: [
        LearningBoardView(board: question.board, boardTheme: boardTheme),
        const SizedBox(height: 24),
        Text(question.prompt, style: theme.text.title.copyWith(height: 1.25)),
        const SizedBox(height: 18),
        for (var index = 0; index < question.answers.length; index++) ...[
          _AnswerOption(
            key: ValueKey('lesson-answer-$index'),
            label: question.answers[index],
            selected: selectedAnswer == index,
            correct: checked && selectedAnswer == index && correct,
            incorrect: checked && selectedAnswer == index && !correct,
            onPressed: () => onSelected(index),
          ),
          if (index != question.answers.length - 1) const SizedBox(height: 10),
        ],
        if (checked) ...[
          const SizedBox(height: 20),
          _Feedback(
            correct: correct,
            text: correct
                ? question.rationale
                : selectedAnswer == null
                ? context.l10n.learnChooseAnswer
                : context.l10n.learnIncorrect,
          ),
        ],
      ],
    );
  }
}

final class const _AnswerOption({
  required final String label,
  required final bool selected,
  required final bool correct,
  required final bool incorrect,
  required final VoidCallback onPressed,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final color = incorrect ? theme.colors.error : theme.colors.accent;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: .opaque,
        onTap: onPressed,
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 160),
          padding: const .symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: correct || incorrect ? .12 : .09)
                : theme.colors.surfaceContainer.withValues(alpha: .55),
            borderRadius: .circular(14),
            border: Border.all(
              color: selected
                  ? color
                  : theme.colors.foreground.withValues(alpha: .08),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(child: Text(label, style: theme.text.body)),
              if (selected) ...[
                const SizedBox(width: 12),
                Icon(
                  incorrect
                      ? SolarIconsOutline.closeCircle
                      : SolarIconsBold.checkCircle,
                  color: color,
                  size: 22,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

final class const _Feedback({
  required final bool correct,
  required final String text,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final color = correct ? theme.colors.accent : theme.colors.error;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: .circular(14),
      ),
      child: Padding(
        padding: const .all(16),
        child: Row(
          crossAxisAlignment: .start,
          children: [
            Icon(
              correct
                  ? SolarIconsBold.checkCircle
                  : SolarIconsOutline.closeCircle,
              color: color,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                key: const ValueKey('learning-feedback'),
                style: theme.text.body.copyWith(color: color, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class const _LessonComplete({required final LearningLesson lesson})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = context.rudiTheme;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        MediaQuery.sizeOf(context).width < 600 ? 24 : 48,
        32,
        MediaQuery.sizeOf(context).width < 600 ? 24 : 48,
        48,
      ),
      children: [
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: theme.colors.accent,
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colors.accent.withValues(alpha: .18),
                width: 8,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            ),
            child: Icon(
              SolarIconsBold.checkCircle,
              color: theme.colors.onAccent,
              size: 44,
            ),
          ),
        ),
        const SizedBox(height: 30),
        Text(
          l.learnLessonCompleteTitle,
          textAlign: .center,
          style: theme.text.display,
        ),
        const SizedBox(height: 10),
        Text(
          l.learnLessonCompleteBody,
          textAlign: .center,
          style: theme.text.body.copyWith(color: theme.colors.mutedForeground),
        ),
        const SizedBox(height: 36),
        Text(l.learnTutorialsTitle, style: theme.text.title),
        const SizedBox(height: 6),
        Text(
          l.learnExternalNotice,
          style: theme.text.caption.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 12),
        for (final tutorial in lesson.tutorials)
          _TutorialLink(tutorial: tutorial),
        const SizedBox(height: 20),
      ],
    );
  }
}

final class const _TutorialLink({required final LearningTutorial tutorial})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return Semantics(
      link: true,
      child: GestureDetector(
        behavior: .opaque,
        onTap: () => openExternalLink(context, tutorial.uri.toString()),
        child: Padding(
          padding: const .symmetric(vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colors.accent.withValues(alpha: .1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  SolarIconsOutline.play,
                  color: theme.colors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(tutorial.title, style: theme.text.label),
                    const SizedBox(height: 3),
                    Text(
                      context.l10n.learnTutorialBy(tutorial.creator),
                      style: theme.text.caption.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(SolarIconsOutline.arrowRightUp, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

final class const _BottomAction({
  required final Key buttonKey,
  required final String label,
  required final VoidCallback onPressed,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.rudiTheme.colors.background,
    child: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const .fromLTRB(20, 12, 20, 12),
            child: SizedBox(
              width: double.infinity,
              child: RudiButton(
                key: buttonKey,
                label: label,
                onPressed: onPressed,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
