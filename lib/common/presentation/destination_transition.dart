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
