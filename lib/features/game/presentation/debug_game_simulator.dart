import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../app/sudoku_controller.dart';
import '../../../common/presentation/app_sheet.dart';
import '../../../common/presentation/ui.dart';
import '../domain/puzzle.dart';

Future<void> showDebugGameSimulator(
  BuildContext context,
  SudokuController controller,
) {
  assert(kDebugMode, 'The game simulator is available only in debug builds.');
  return showAppSheet<void>(
    context: context,
    title: context.l10n.debugGameSimulator,
    showCloseButton: true,
    builder: (sheetContext) => _DebugGameSimulator(
      controller: controller,
      onApplied: () => Navigator.of(sheetContext).pop(),
    ),
  );
}

final class const _DebugGameSimulator({
  required final SudokuController controller,
  required final VoidCallback onApplied,
}) extends StatefulWidget {
  @override
  State<_DebugGameSimulator> createState() => _DebugGameSimulatorState();
}

final class _DebugGameSimulatorState() extends State<_DebugGameSimulator> {
  late final int _minimumFilled;
  late final TextEditingController _filled;
  late final TextEditingController _mistakes;
  late final TextEditingController _hints;
  var _validate = false;

  @override
  void initState() {
    super.initState();
    final game = widget.controller.gameForDebug!;
    _minimumFilled = game.puzzle.givens.where((value) => value != 0).length;
    _filled = TextEditingController(
      text: game.filled.clamp(_minimumFilled, sudokuCellCount - 1).toString(),
    );
    _mistakes = TextEditingController(text: game.mistakes.toString());
    _hints = TextEditingController(text: game.hintsUsed.toString());
  }

  @override
  void dispose() {
    _filled.dispose();
    _mistakes.dispose();
    _hints.dispose();
    super.dispose();
  }

  int? _read(TextEditingController controller, int minimum, int maximum) {
    final value = int.tryParse(controller.text);
    return value != null && value >= minimum && value <= maximum ? value : null;
  }

  void _apply() {
    final filled = _read(_filled, _minimumFilled, sudokuCellCount - 1);
    final mistakes = _read(_mistakes, 0, 99);
    final hints = _read(_hints, 0, 99);
    if (filled == null || mistakes == null || hints == null) {
      setState(() => _validate = true);
      return;
    }
    widget.controller.simulateGameForDebug(
      filledCells: filled,
      mistakes: mistakes,
      hintsUsed: hints,
    );
    widget.onApplied();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final formatters = <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly,
    ];
    String? errorFor(TextEditingController controller, int min, int max) =>
        _validate && _read(controller, min, max) == null
        ? l.debugValueRange(min, max)
        : null;

    return Column(
      crossAxisAlignment: .stretch,
      mainAxisSize: .min,
      children: [
        Text(
          l.debugGameSimulatorDescription,
          style: context.rudiTheme.text.body.copyWith(
            color: context.rudiTheme.colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 20),
        RudiTextField(
          key: const ValueKey('debug-filled-cells'),
          controller: _filled,
          label: l.debugFilledCells,
          errorText: errorFor(_filled, _minimumFilled, sudokuCellCount - 1),
          keyboardType: TextInputType.number,
          inputFormatters: formatters,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: .start,
          children: [
            Expanded(
              child: RudiTextField(
                key: const ValueKey('debug-mistakes'),
                controller: _mistakes,
                label: l.debugMistakes,
                errorText: errorFor(_mistakes, 0, 99),
                keyboardType: TextInputType.number,
                inputFormatters: formatters,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RudiTextField(
                key: const ValueKey('debug-hints'),
                controller: _hints,
                label: l.debugHints,
                errorText: errorFor(_hints, 0, 99),
                keyboardType: TextInputType.number,
                inputFormatters: formatters,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        RudiButton(
          key: const ValueKey('debug-apply-simulation'),
          label: l.debugApplySimulation,
          onPressed: _apply,
        ),
      ],
    );
  }
}
