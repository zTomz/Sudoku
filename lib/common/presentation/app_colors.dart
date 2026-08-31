import 'package:flutter/widgets.dart';

/// Shared accent for app surfaces, number input and board selection.
Color sudokuAccent(Brightness brightness) => brightness == Brightness.dark
    ? const Color(0xff79b5ff)
    : const Color(0xff2673d9);
