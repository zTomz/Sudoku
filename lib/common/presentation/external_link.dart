import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_sheet.dart';
import 'ui.dart';

Future<void> openExternalLink(BuildContext context, String url) async {
  try {
    if (await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      return;
    }
  } catch (_) {
    // Keep the address available when no browser can handle the link.
  }
  if (!context.mounted) return;
  await showAppSheet<void>(
    context: context,
    title: context.l10n.linkOpenError,
    builder: (_) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(url),
        const SizedBox(height: 16),
        RudiButton(
          label: context.l10n.copyLink,
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: url));
          },
        ),
      ],
    ),
  );
}
