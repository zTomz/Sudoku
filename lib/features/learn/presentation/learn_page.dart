import 'package:cue/cue.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:rudi_ui/rudi_ui.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../../app/sudoku_controller.dart';
import '../../../common/presentation/ui.dart';
import '../domain/learning_lesson.dart';
import '../domain/learning_progress.dart';
import 'learn_lesson_page.dart';
import 'widgets/learning_progress_bar.dart';

final class const LearnPage({
  required final SudokuController controller,
  super.key,
}) extends StatelessWidget {
  static const path = '/learn';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final progress = controller.learningProgress;
    final lessons = learningLessons(l);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return RudiPage(
      padding: .zero,
      child: Column(
        children: [
          const _LearnHeader(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: CustomScrollView(
                  key: const ValueKey('learning-path'),
                  slivers: [
                    SliverPadding(
                      padding: .fromLTRB(
                        MediaQuery.sizeOf(context).width < 600 ? 24 : 48,
                        20,
                        MediaQuery.sizeOf(context).width < 600 ? 24 : 48,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _PathIntroduction(
                          completed: progress.completedCount,
                          total: lessons.length,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Cue.onMount(
                        motion: reduceMotion ? CueMotion.none : .smooth(),
                        child: _SkillPath(lessons: lessons, progress: progress),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 48)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class const _LearnHeader() extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const .fromLTRB(8, 4, 8, 0),
    child: Row(
      children: [
        RudiIconButton(
          icon: const RotatedBox(
            quarterTurns: 2,
            child: Icon(SolarIconsOutline.altArrowRight, size: 24),
          ),
          semanticLabel: context.l10n.back,
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            context.l10n.learnSudoku,
            style: context.rudiTheme.text.title,
          ),
        ),
      ],
    ),
  );
}

final class const _PathIntroduction({
  required final int completed,
  required final int total,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = context.rudiTheme;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(l.learnPathTitle, style: theme.text.display),
        const SizedBox(height: 8),
        Text(
          l.learnPathDescription,
          style: theme.text.body.copyWith(color: theme.colors.mutedForeground),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: LearningProgressBar(
                key: const ValueKey('learning-path-progress'),
                progress: total == 0 ? 0 : completed / total,
                height: 9,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              '$completed/$total',
              style: theme.text.label.copyWith(color: theme.colors.accent),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l.learnNoPoints,
          style: theme.text.caption.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

final class const _SkillPath({
  required final List<LearningLesson> lessons,
  required final LearningProgress progress,
}) extends StatelessWidget {
  static const _nodeSize = 78.0;
  static const _stepHeight = 132.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final center = constraints.maxWidth / 2;
      final spread = (constraints.maxWidth * .22).clamp(48.0, 104.0);
      final offsets = <double>[0, -.72, -1, -.55, .25, .92, .65, 0];
      final points = [
        for (var index = 0; index < lessons.length; index++)
          Offset(
            center + spread * offsets[index % offsets.length],
            68 + index * _stepHeight,
          ),
      ];
      final height = 110 + (lessons.length - 1) * _stepHeight + 92;
      return SizedBox(
        height: height,
        child: Stack(
          clipBehavior: .none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _SkillPathPainter(
                  points: points,
                  completedCount: progress.completedCount,
                  muted: context.rudiTheme.colors.surfaceContainer,
                  accent: context.rudiTheme.colors.accent,
                ),
              ),
            ),
            for (var index = 0; index < lessons.length; index++)
              Positioned(
                left: points[index].dx - 90,
                top: points[index].dy - _nodeSize / 2,
                width: 180,
                child: Actor(
                  delay: (index * 45).ms,
                  acts: [.fadeIn(), .scale(from: .82)],
                  child: _SkillNode(
                    lesson: lessons[index],
                    completed: progress.isCompleted(lessons[index].skill),
                    unlocked: progress.isUnlocked(lessons[index].skill),
                    current:
                        progress.isUnlocked(lessons[index].skill) &&
                        !progress.isCompleted(lessons[index].skill),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

final class const _SkillNode({
  required final LearningLesson lesson,
  required final bool completed,
  required final bool unlocked,
  required final bool current,
}) extends StatelessWidget {
  IconData get _techniqueIcon => switch (lesson.skill) {
    LearningSkill.rules => SolarIconsOutline.book,
    LearningSkill.candidates => SolarIconsOutline.pen2,
    LearningSkill.nakedSingle => SolarIconsOutline.target,
    LearningSkill.hiddenSingle => SolarIconsOutline.minimalisticMagnifier,
    LearningSkill.lockedCandidates => SolarIconsOutline.lockKeyhole,
    LearningSkill.pairs => SolarIconsOutline.copy,
    LearningSkill.triples => SolarIconsOutline.layers,
    LearningSkill.wings => SolarIconsOutline.routing3,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    final nodeColor = unlocked
        ? theme.colors.accent
        : theme.colors.surfaceContainer;
    final foreground = unlocked
        ? theme.colors.onAccent
        : theme.colors.mutedForeground;
    return Semantics(
      button: unlocked,
      enabled: unlocked,
      label: lesson.title,
      hint: unlocked ? lesson.summary : context.l10n.learnLocked,
      child: GestureDetector(
        key: ValueKey('lesson-${lesson.skill.name}'),
        behavior: .opaque,
        onTap: unlocked
            ? () => context.push(LearnLessonPage.pathFor(lesson.skill))
            : null,
        child: SizedBox(
          width: 180,
          child: Column(
            children: [
              AnimatedContainer(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: nodeColor,
                  shape: BoxShape.circle,
                  border: current
                      ? Border.all(
                          color: theme.colors.accent.withValues(alpha: .28),
                          width: 7,
                          strokeAlign: BorderSide.strokeAlignOutside,
                        )
                      : null,
                ),
                child: Icon(
                  completed ? SolarIconsBold.checkCircle : _techniqueIcon,
                  color: foreground,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                lesson.title,
                textAlign: .center,
                maxLines: 2,
                overflow: .ellipsis,
                style: theme.text.label.copyWith(
                  color: unlocked
                      ? theme.colors.foreground
                      : theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _SkillPathPainter({
  required final List<Offset> points,
  required final int completedCount,
  required final Color muted,
  required final Color accent,
}) extends CustomPainter {
  Path _pathUntil(int lastPoint) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 1; index <= lastPoint; index++) {
      final previous = points[index - 1], current = points[index];
      final middleY = (previous.dy + current.dy) / 2;
      path.cubicTo(
        previous.dx,
        middleY,
        current.dx,
        middleY,
        current.dx,
        current.dy,
      );
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    canvas.drawPath(
      _pathUntil(points.length - 1),
      Paint()
        ..color = muted
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );
    final reached = completedCount.clamp(0, points.length - 1);
    if (reached > 0) {
      canvas.drawPath(
        _pathUntil(reached),
        Paint()
          ..color = accent.withValues(alpha: .45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_SkillPathPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.completedCount != completedCount ||
      oldDelegate.muted != muted ||
      oldDelegate.accent != accent;
}
