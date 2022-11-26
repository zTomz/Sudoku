import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/models/field.dart';

class GameFieldNotifier extends StateNotifier<List<Field>> {
  GameFieldNotifier()
      : super(
          [
            for (int y = 1; y <= 9; y++)
              for (int x = 1; x <= 9; x++) Field(x: x, y: y),
          ],
        );

  void toggleFieldNumber(Field? fieldToToggle, int? newNumber) {
    if (fieldToToggle == null) {
      debugPrint("Field to toggle is null");
      return;
    }

    for (Field field in state) {
      if (field == fieldToToggle) {
        field.number = newNumber;
        break;
      }
    }
  }

  void generateBoard() {
    List<Field> generatedList = List.of(state);

    List<int> randomNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];

    for (int x = 1; x <= 3; x++) {
      for (int y = 1; y <= 3; y++) {
        // Possible fields are x - 1 * 3 to x * 3 and y - 1 * 3 to y * 3

        List<Field> possibleFields = generatedList.where((field) {
          if (field.x > (x - 1) * 3 &&
              field.x <= x * 3 &&
              field.y > (y - 1) * 3 &&
              field.y <= y * 3) {
            return true;
          }
          return false;
        }).toList();

        randomNumbers.shuffle();

        print("RUN: $x, $y");
        for (int i = 0; i < possibleFields.length; i++) {
          possibleFields[i].number = randomNumbers[i];
          possibleFields[i].canEdit = false;
        }
      }
    }

    for (Field selectedField in generatedList) {
      final number = selectedField.number;
      final x = selectedField.x;
      final y = selectedField.y;

      for (Field field in generatedList) {
        if (field != selectedField && field.number == number) {
          if (field.x == x || field.y == y) {
            field.number = null;
            field.canEdit = true;
          }
        }
      }
    }

    randomNumbers.shuffle();

    List<Field> firstRectFields = generatedList.where((field) {
      if (field.x > 0 && field.x <= 3 && field.y > 0 && field.y <= 3) {
        return true;
      }
      return false;
    }).toList();

    for (int number in randomNumbers.getRange(0, 3)) {
      print(number);
      firstRectFields[number-1].number = null;
      firstRectFields[number-1].canEdit = true;
    }

    state = generatedList;
  }
}
