import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

final class const LearningProgressBar({
  required final double progress,
  final double height = 8,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: .circular(99),
    child: SizedBox(
      height: height,
      child: ColoredBox(
        color: context.rudiTheme.colors.surfaceContainer,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: progress.clamp(0, 1)),
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => FractionallySizedBox(
            alignment: .centerLeft,
            widthFactor: value,
            child: child,
          ),
          child: ColoredBox(color: context.rudiTheme.colors.accent),
        ),
      ),
    ),
  );
}
