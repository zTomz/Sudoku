import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rudi_ui/rudi_ui.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/presentation/app_sheet.dart';
import '../../../common/presentation/ui.dart';
import '../../privacy/presentation/privacy_policy_page.dart';

const repositoryUrl = 'https://github.com/zTomz/Sudoku';
const reportBugUrl = '$repositoryUrl/issues/new';
final featureRequestUrl = Uri.parse(reportBugUrl)
    .replace(queryParameters: {'title': '[Feature request] '})
    .toString();

Future<void> openSettingsLink(BuildContext context, String url) async {
  try {
    if (await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      return;
    }
  } catch (_) {
    // The address remains available when no browser can handle the link.
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

final class const SettingsInformation({super.key}) extends StatefulWidget {
  @override
  State<SettingsInformation> createState() => _SettingsInformationState();
}

final class _SettingsInformationState() extends State<SettingsInformation> {
  late final _version = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      RudiSettingsGroup(
        title: context.l10n.support,
        children: [
          RudiSettingsTile(
            key: const ValueKey('setting-report-bug'),
            title: context.l10n.reportBug,
            leading: const Icon(SolarIconsOutline.bugMinimalistic),
            trailing: const Icon(SolarIconsOutline.arrowRightUp),
            onPressed: () => openSettingsLink(context, reportBugUrl),
          ),
          RudiSettingsTile(
            key: const ValueKey('setting-feature-request'),
            title: context.l10n.featureRequest,
            leading: const Icon(SolarIconsOutline.lightbulb),
            trailing: const Icon(SolarIconsOutline.arrowRightUp),
            onPressed: () => openSettingsLink(context, featureRequestUrl),
          ),
          RudiSettingsTile(
            key: const ValueKey('setting-repository'),
            title: context.l10n.repository,
            leading: const Icon(SolarIconsOutline.code),
            trailing: const Icon(SolarIconsOutline.arrowRightUp),
            onPressed: () => openSettingsLink(context, repositoryUrl),
          ),
        ],
      ),
      const SizedBox(height: 28),
      RudiSettingsGroup(
        title: context.l10n.legal,
        children: [
          RudiSettingsTile(
            key: const ValueKey('setting-privacy-policy'),
            title: context.l10n.privacyPolicy,
            leading: const Icon(SolarIconsOutline.shieldCheck),
            trailing: const Icon(SolarIconsOutline.altArrowRight),
            onPressed: () =>
                context.go(PrivacyPolicyPage.path, extra: '/settings'),
          ),
          RudiSettingsTile(
            key: const ValueKey('setting-licenses'),
            title: context.l10n.licenses,
            leading: const Icon(SolarIconsOutline.documentText),
            trailing: const Icon(SolarIconsOutline.altArrowRight),
            onPressed: () => showAppSheet<void>(
              context: context,
              title: context.l10n.licenses,
              builder: (_) => const _Licenses(),
            ),
          ),
        ],
      ),
      const SizedBox(height: 28),
      FutureBuilder<PackageInfo>(
        future: _version,
        builder: (context, snapshot) => Text(
          key: const ValueKey('settings-version'),
          snapshot.hasData
              ? context.l10n.versionLabel(
                  snapshot.data!.version,
                  snapshot.data!.buildNumber,
                )
              : snapshot.hasError
              ? context.l10n.versionUnavailable
              : 'Sudoku',
          textAlign: TextAlign.center,
          style: context.rudiTheme.text.body.copyWith(
            color: context.rudiTheme.colors.mutedForeground,
          ),
        ),
      ),
    ],
  );
}

final class const _Licenses() extends StatefulWidget {
  @override
  State<_Licenses> createState() => _LicensesState();
}

final class _LicensesState() extends State<_Licenses> {
  late Future<List<LicenseEntry>> _licenses = _load();

  Future<List<LicenseEntry>> _load() async => [
    LicenseEntryWithLineBreaks([
      'Sudoku',
    ], await rootBundle.loadString('LICENSE')),
    LicenseEntryWithLineBreaks([
      'Google Sans',
    ], await rootBundle.loadString('assets/fonts/OFL.txt')),
    LicenseEntryWithLineBreaks([
      'Solar Icons',
    ], await rootBundle.loadString('assets/licenses/solar-icons.txt')),
    ...await LicenseRegistry.licenses.toList(),
  ];

  @override
  Widget build(BuildContext context) => FutureBuilder<List<LicenseEntry>>(
    future: _licenses,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Column(
          children: [
            Text(context.l10n.licensesLoadError),
            RudiButton(
              onPressed: () => setState(() => _licenses = _load()),
              label: context.l10n.retry,
            ),
          ],
        );
      }
      if (!snapshot.hasData) return Text(context.l10n.licensesLoading);
      return RudiSettingsGroup(
        children: [
          for (final entry in snapshot.data!)
            RudiSettingsTile(
              title: entry.packages.join(', '),
              trailing: const Icon(SolarIconsOutline.altArrowRight),
              onPressed: () => showAppSheet<void>(
                context: context,
                title: entry.packages.join(', '),
                builder: (_) => Text(
                  entry.paragraphs.map((p) => p.text).join('\n\n'),
                  style: context.rudiTheme.text.body,
                ),
              ),
            ),
        ],
      );
    },
  );
}
