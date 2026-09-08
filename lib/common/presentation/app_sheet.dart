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
  title: title,
  barrierLabel: context.l10n.close,
  closeIcon: showCloseButton ? const RudiGlyph(RudiGlyphType.close) : null,
  builder: builder,
);
