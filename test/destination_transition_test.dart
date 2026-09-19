import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/common/presentation/destination_transition.dart';

void main() {
  testWidgets('keeps the outgoing destination visible during the transition', (
    tester,
  ) async {
    var currentIndex = 0;
    late StateSetter setState;
    await tester.pumpWidget(
      Directionality(
        textDirection: .ltr,
        child: StatefulBuilder(
          builder: (context, update) {
            setState = update;
            return DestinationTransitionStack(
              currentIndex: currentIndex,
              children: const [Text('First'), Text('Second')],
            );
          },
        ),
      ),
    );

    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsNothing);

    setState(() => currentIndex = 1);
    await tester.pump();

    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 40));
    setState(() => currentIndex = 0);
    await tester.pump();

    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
