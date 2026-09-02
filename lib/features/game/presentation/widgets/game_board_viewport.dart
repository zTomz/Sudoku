import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../domain/puzzle.dart';

const _maximumBoardExtent = 560.0;
const _minimumPlayableCellExtent = 36.0;
const _minimumPlayableBoardExtent =
    sudokuSideLength * _minimumPlayableCellExtent;

@visibleForTesting
double gameBoardExtent(BoxConstraints constraints) {
  final widthBoundedExtent = math.min(
    constraints.maxWidth,
    _maximumBoardExtent,
  );
  if (!constraints.hasBoundedHeight ||
      constraints.maxHeight >= widthBoundedExtent) {
    return widthBoundedExtent;
  }
  if (constraints.maxHeight >= _minimumPlayableBoardExtent) {
    return constraints.maxHeight;
  }
  return math.min(widthBoundedExtent, _minimumPlayableBoardExtent);
}

final class const GameBoardViewport({
  required final Widget board,
  final Widget? overlay,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final extent = gameBoardExtent(constraints);
      return Center(
        child: SingleChildScrollView(
          child: SizedBox.square(
            key: const ValueKey('game-puzzle'),
            dimension: extent,
            child: Stack(
              clipBehavior: .none,
              children: [
                Positioned.fill(child: board),
                ?overlay,
              ],
            ),
          ),
        ),
      );
    },
  );
}
