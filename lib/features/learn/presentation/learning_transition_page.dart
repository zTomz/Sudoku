import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

final class LearningTransitionPage extends CustomTransitionPage<void> {
  // A primary constructor cannot currently forward fixed superclass values.
  // ignore: use_primary_constructors, unnecessary_type_name_in_constructor
  const LearningTransitionPage({required super.child, super.key})
    : super(
        transitionDuration: const Duration(milliseconds: 360),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        transitionsBuilder: _buildLearningTransition,
      );
}

Widget _buildLearningTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  if (MediaQuery.disableAnimationsOf(context)) return child;
  final curved = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  return FadeTransition(
    opacity: curved,
    child: SlideTransition(
      position: Tween(
        begin: const Offset(.045, 0),
        end: Offset.zero,
      ).animate(curved),
      child: ScaleTransition(
        scale: Tween(begin: .99, end: 1.0).animate(curved),
        alignment: .centerRight,
        child: child,
      ),
    ),
  );
}
