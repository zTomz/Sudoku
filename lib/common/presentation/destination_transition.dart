import 'package:cue/cue.dart';
import 'package:flutter/widgets.dart';

/// Replays a restrained entrance when the active destination changes.
/// Keep the child keyed or in an IndexedStack to retain its local state.
final class const DestinationTransition({
  required final Object value,
  required final Widget child,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Cue.onChange(
    value: value,
    motion: MediaQuery.disableAnimationsOf(context)
        ? CueMotion.none
        : .smooth(),
    fromCurrentValue: true,
    acts: [.opacity(from: .35, to: 1), .translateY(from: 8)],
    child: child,
  );
}

/// Cross-fades between persistent router branches without resetting them.
final class const DestinationTransitionStack({
  required final int currentIndex,
  required final List<Widget> children,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final indexedChildren = children.indexed.toList(growable: false);
    final paintOrder = [
      ...indexedChildren.where((entry) => entry.$1 != currentIndex),
      indexedChildren[currentIndex],
    ];

    return Stack(
      fit: .expand,
      children: [
        for (final (index, child) in paintOrder)
          _DestinationTransitionBranch(
            key: ValueKey(index),
            selected: index == currentIndex,
            motion: reducedMotion ? CueMotion.none : .gentle(),
            child: child,
          ),
      ],
    );
  }
}

final class const _DestinationTransitionBranch({
  required final bool selected,
  required final CueMotion motion,
  required final Widget child,
  super.key,
}) extends StatefulWidget {
  @override
  State<_DestinationTransitionBranch> createState() =>
      _DestinationTransitionBranchState();
}

final class _DestinationTransitionBranchState()
    extends State<_DestinationTransitionBranch> {
  late bool _offstage = !widget.selected;

  @override
  void didUpdateWidget(_DestinationTransitionBranch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected) _offstage = false;
  }

  @override
  Widget build(BuildContext context) => Offstage(
    offstage: _offstage,
    child: Cue.onToggle(
      toggled: widget.selected,
      motion: widget.motion,
      onEnd: (forward) {
        if (!forward && !widget.selected && mounted) {
          setState(() => _offstage = true);
        }
      },
      acts: [.fadeIn(), .slideY(from: .02)],
      child: ExcludeFocus(
        excluding: !widget.selected,
        child: ExcludeSemantics(
          excluding: !widget.selected,
          child: IgnorePointer(
            ignoring: !widget.selected,
            child: TickerMode(enabled: widget.selected, child: widget.child),
          ),
        ),
      ),
    ),
  );
}
