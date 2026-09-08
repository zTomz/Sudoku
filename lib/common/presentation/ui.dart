import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../features/game/domain/puzzle.dart';
import '../../l10n/generated/app_localizations.dart';

extension SudokuContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

String difficultyLabel(BuildContext context, Difficulty value) =>
    switch (value) {
      Difficulty.easy => context.l10n.easy,
      Difficulty.medium => context.l10n.medium,
      Difficulty.hard => context.l10n.hard,
    };
String durationLabel(int seconds) {
  final minutes = seconds ~/ 60;
  return '${minutes.toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
}

final class const PageHeading(
  final String title, {
  final String? subtitle,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.rudiTheme.text.display),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          Text(
            subtitle!,
            style: context.rudiTheme.text.body.copyWith(
              color: context.rudiTheme.colors.mutedForeground,
            ),
          ),
        ],
      ],
    ),
  );
}

final class const ContentPage({required final Widget child, super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => RudiPage(
    padding: EdgeInsets.zero,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            MediaQuery.sizeOf(context).width < 600 ? 16 : 40,
            MediaQuery.sizeOf(context).width < 600 ? 16 : 40,
            MediaQuery.sizeOf(context).width < 600 ? 16 : 40,
            128,
          ),
          children: [child],
        ),
      ),
    ),
  );
}
