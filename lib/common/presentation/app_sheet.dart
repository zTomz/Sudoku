import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import 'ui.dart';

Future<T?> showAppSheet<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
  bool showCloseButton = false,
}) => showRudiBottomSheet<T>(
  context: context,
  barrierLabel: context.l10n.close,
  useRootNavigator: true,
  builder: (sheetContext) => RudiBottomSheet(
    title: Text(title),
    trailing: showCloseButton
        ? RudiBottomSheetCloseButton(semanticLabel: context.l10n.close)
        : null,
    children: [builder(sheetContext)],
  ),
);
