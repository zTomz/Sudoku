import 'package:flutter/widgets.dart';

final class const BoardDigit(
  final String value, {
  required final TextStyle style,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Text(
    value,
    style: style.copyWith(letterSpacing: 0),
    textAlign: TextAlign.center,
    textHeightBehavior: const TextHeightBehavior(
      leadingDistribution: TextLeadingDistribution.even,
    ),
    textScaler: TextScaler.noScaling,
    maxLines: 1,
    softWrap: false,
  );
}
