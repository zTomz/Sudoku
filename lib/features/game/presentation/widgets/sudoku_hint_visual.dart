import 'package:flutter/foundation.dart';

@immutable
final class const SudokuHintVisual._(
  final Set<int> cells,
  final Map<int, int> candidates,
  final Map<int, int> removals,
  final int? focus,
  final int? placement,
  final int? digit,
) {
  factory({
    required Set<int> cells,
    Map<int, int> candidates = const {},
    Map<int, int> removals = const {},
    int? focus,
    int? placement,
    int? digit,
  }) => SudokuHintVisual._(
    Set.unmodifiable(cells),
    Map.unmodifiable(candidates),
    Map.unmodifiable(removals),
    focus,
    placement,
    digit,
  );
}
