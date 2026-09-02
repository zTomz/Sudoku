import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../../common/presentation/ui.dart';
import '../../domain/puzzle.dart';

const _popupSize = Size(56, 48);
const _popupCellOverlap = 16.0;
const _maximumTopOverflow = 20.0;

@visibleForTesting
Rect scorePopupRect({required Size boardSize, required int cell}) {
  assert(boardSize.width >= 0 && boardSize.height >= 0);
  assert(cell >= 0 && cell < sudokuCellCount);
  final safeCell = cell.clamp(0, sudokuCellCount - 1);
  final cellWidth = boardSize.width / sudokuSideLength;
  final cellHeight = boardSize.height / sudokuSideLength;
  final row = safeCell ~/ sudokuSideLength;
  final column = safeCell % sudokuSideLength;
  final maxLeft = math.max(0.0, boardSize.width - _popupSize.width);
  final left = ((column + .5) * cellWidth - _popupSize.width / 2).clamp(
    0.0,
    maxLeft,
  );
  final preferredTop = row * cellHeight - _popupSize.height + _popupCellOverlap;
  final top = math.max(-_maximumTopOverflow, preferredTop);
  return Offset(left, top) & _popupSize;
}

final class const ScorePopup({
  required final int points,
  required final int cell,
  super.key,
}) extends StatefulWidget {
  @override
  State<ScorePopup> createState() => _ScorePopupState();
}

final class _ScorePopupState()
    extends State<ScorePopup>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 1400);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
  )..addStatusListener(_handleAnimationStatus);
  late final Animation<double> _opacity = TweenSequence<double>([
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 65),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.easeIn)),
      weight: 35,
    ),
  ]).animate(_controller);
  late final Animation<double> _translation = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 0.0,
        end: -6.0,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 65,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: -6.0,
        end: -18.0,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 35,
    ),
  ]).animate(_controller);
  var _visible = true;

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() => _visible = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          clipBehavior: .none,
          children: [
            Positioned.fromRect(
              rect: scorePopupRect(
                boardSize: constraints.biggest,
                cell: widget.cell,
              ),
              child: IgnorePointer(
                child: Semantics(
                  liveRegion: true,
                  label: context.l10n.pointsAwarded(widget.points),
                  child: ExcludeSemantics(
                    child: AnimatedBuilder(
                      animation: _controller,
                      child: _ScoreLabel(points: widget.points),
                      builder: (context, child) => Opacity(
                        opacity: reduceMotion ? 1 : _opacity.value,
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            reduceMotion ? 0 : _translation.value,
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class const _ScoreLabel({required final int points})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return DecoratedBox(
      key: const ValueKey('score-popup'),
      decoration: BoxDecoration(
        color: theme.colors.surface.withValues(alpha: .96),
        borderRadius: .circular(999),
        border: Border.all(color: theme.colors.accent.withValues(alpha: .18)),
        boxShadow: [
          BoxShadow(
            color: theme.colors.foreground.withValues(alpha: .12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '+$points',
          textAlign: .center,
          textScaler: TextScaler.noScaling,
          maxLines: 1,
          softWrap: false,
          overflow: .visible,
          style: theme.text.title.copyWith(
            color: theme.colors.accent,
            fontWeight: .w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}
