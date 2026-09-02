import 'package:flutter/widgets.dart';
import 'package:reel_text/reel_text.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../../common/presentation/ui.dart';
import '../../domain/game_session.dart';

final class const GameStatusBar({
  required final GameSession game,
  required final bool showTimer,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = context.rudiTheme;
    final timerLabel = showTimer
        ? ', ${l.timer}: ${durationLabel(game.elapsedSeconds)}'
        : '';
    final visibleTimer = showTimer
        ? ' · ${durationLabel(game.elapsedSeconds)}'
        : '';
    return Padding(
      padding: const .fromLTRB(20, 12, 20, 8),
      child: Row(
        crossAxisAlignment: .center,
        children: [
          Expanded(
            child: Text(
              '${game.puzzle.dailyDate == null ? l.freePlay : l.daily} · ${difficultyLabel(context, game.puzzle.difficulty)}',
              style: theme.text.caption.copyWith(
                color: theme.colors.mutedForeground,
              ),
              maxLines: 1,
              overflow: .ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 2,
            child: Semantics(
              label:
                  '${l.pointsValue(game.points)}, ${l.mistakesValue(game.mistakes)}$timerLabel',
              child: ExcludeSemantics(
                child: Row(
                  key: const ValueKey('game-score'),
                  mainAxisAlignment: .end,
                  children: [
                    SizedBox(
                      width: 36,
                      child: ReelText(
                        '${game.points}',
                        textAlign: .end,
                        options: ReelTextOptions(
                          direction: ReelTextDirection.down,
                          duration: const Duration(milliseconds: 320),
                          stagger: const Duration(milliseconds: 28),
                          exitOffset: const Duration(milliseconds: 36),
                          curve: Curves.easeOutCubic,
                          bounce: .15,
                          color: theme.colors.accent,
                        ),
                        style: theme.text.caption.copyWith(
                          color: theme.colors.accent,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        ' ${l.pointsLabel} · ${l.mistakesValue(game.mistakes)}$visibleTimer',
                        maxLines: 1,
                        softWrap: false,
                        overflow: .fade,
                        style: theme.text.caption.copyWith(
                          color: theme.colors.accent,
                        ),
                      ),
                    ),
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
