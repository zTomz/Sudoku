import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/colors.dart';
import 'package:sudoku/provider/provider.dart';
import 'package:sudoku/widgets/number_field.dart';

class GamePage extends ConsumerWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameFields = ref.watch(gameFieldsProvider);
    final selectedField = ref.watch(selectedFieldProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Stopwatch stopwatch = Stopwatch()..start();
          ref.read(gameFieldsProvider.notifier).generateBoard();
          stopwatch.stop();
          print(stopwatch.elapsed);

          final snackBar = SnackBar(
            /// need to set following properties for best effect of awesome_snackbar_content
            duration: const Duration(milliseconds: 750),
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Buld field',
              message: 'Sudoku field built in ${stopwatch.elapsed}.',
              contentType: ContentType.success,
            ),
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        },
        child: const Icon(
          Icons.gesture_rounded,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 400,
              height: 400,
              child: GridView.builder(
                itemCount: gameFields.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 9,
                ),
                itemBuilder: (context, index) => GridTile(
                  child: InkWell(
                    onTap: () {
                      print(gameFields[index].toString());
                      if (selectedField == gameFields[index]) {
                        ref.read(selectedFieldProvider.notifier).state = null;
                        return;
                      }
                      ref.read(selectedFieldProvider.notifier).state =
                          gameFields[index];
                    },
                    hoverColor: kGrey,
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedField == gameFields[index]
                            ? kGrey
                            : numberColors[gameFields[index].number],
                        border: Border.all(
                          width: 2,
                          strokeAlign: StrokeAlign.center,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "${gameFields[index].number ?? ""}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: gameFields[index].canEdit
                                ? FontWeight.w400
                                : FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            NumberField(
              onTap: (number) {},
            )
          ],
        ),
      ),
    );
  }
}
