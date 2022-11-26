import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/provider/provider.dart';

class NumberField extends StatelessWidget {
  final void Function(int number) onTap;
  const NumberField({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            NumberButton(number: 1),
            NumberButton(number: 2),
            NumberButton(number: 3),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            NumberButton(number: 4),
            NumberButton(number: 5),
            NumberButton(number: 6),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            NumberButton(number: 7),
            NumberButton(number: 8),
            NumberButton(number: 9),
          ],
        ),
        const NumberButton(number: 0),
      ],
    );
  }
}

class NumberButton extends ConsumerWidget {
  final int number;

  const NumberButton({
    Key? key,
    required this.number,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedField = ref.watch(selectedFieldProvider);

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: MaterialButton(
        onPressed: () {
          if (selectedField == null) return;
          if (!selectedField.canEdit) return;

          ref
              .read(gameFieldsProvider.notifier)
              .toggleFieldNumber(selectedField, number != 0 ? number : null);
          ref.read(selectedFieldProvider.notifier).state = null;
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 15,
          ),
          child: Text(
            number == 0 ? "x" : number.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
