import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../../../common/presentation/ui.dart';

const privacyDeveloperName = 'Tom Vogel';
const privacyContactEmail = 'tom.vogel.dev@gmail.com';

final class const PrivacyPolicyPage({final String returnPath = '/', super.key})
    extends StatefulWidget {
  static const path = '/privacy-policy';

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

final class _PrivacyPolicyPageState() extends State<PrivacyPolicyPage> {
  final _selectionFocusNode = FocusNode();

  @override
  void dispose() {
    _selectionFocusNode.dispose();
    super.dispose();
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(widget.returnPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rudiTheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack(context);
      },
      child: RudiPage(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  RudiIconButton(
                    key: const ValueKey('privacy-back'),
                    icon: const RotatedBox(
                      quarterTurns: 2,
                      child: AppIcon(AppSymbol.chevron),
                    ),
                    semanticLabel: context.l10n.back,
                    onPressed: () => _goBack(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.privacyPolicy,
                      style: theme.text.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: SelectableRegion(
                    focusNode: _selectionFocusNode,
                    selectionControls: emptyTextSelectionControls,
                    child: ListView(
                      key: const ValueKey('privacy-policy-content'),
                      padding: EdgeInsets.fromLTRB(
                        MediaQuery.sizeOf(context).width < 600 ? 20 : 48,
                        24,
                        MediaQuery.sizeOf(context).width < 600 ? 20 : 48,
                        48,
                      ),
                      children: const [
                        _PolicyTitle(),
                        _PolicySection(
                          title: '1. Scope of this policy',
                          body: 'This Privacy Policy applies to Sudoku, an open-source puzzle app for Android and Windows, and to the same Flutter app made available on the web at https://ztomz.github.io/Sudoku/. It explains what the app processes, what remains on your device, and what happens when you access the hosted web version.\n\nIt does not cover services that you choose to visit separately, such as Google Play, GitHub, your browser provider, or your operating-system provider. Those services operate under their own privacy terms.',
                        ),
                        _PolicySection(
                          title: '2. Developer and privacy contact',
                          body:
                              'Developer: $privacyDeveloperName\nApp: Sudoku\nPrivacy and support contact: $privacyContactEmail',
                        ),
                        _PolicySection(
                          title: '3. Privacy summary',
                          body: 'Sudoku does not require an account and does not have an application backend. The native app does not collect or upload personal data, gameplay data, or device identifiers. There is no advertising, analytics, tracking, cloud synchronization, remote puzzle service, social feature, or automatic crash-reporting service.\n\nYour puzzles and preferences stay in local app storage. The only routine network processing described by this policy occurs when the web version is loaded or updated: your browser must request the app files from GitHub Pages, and GitHub processes ordinary web-request information to provide and secure that hosting.',
                        ),
                        _PolicySection(
                          title: '4. Data processed locally',
                          body: 'To provide the game, Sudoku processes the following information locally on your device or in your browser:\n\n• generated puzzle definitions, clues, solutions, identifiers, difficulty ratings, and daily-puzzle dates;\n• your entered numbers and pencil notes;\n• undo and redo history;\n• selected cells and temporary game controls while the app is running;\n• elapsed game time, mistakes, points, completion results, and statistics;\n• preferences such as appearance, board theme, timer visibility, note cleanup, input mode, error checking, and haptic feedback; and\n• ordinary display and device settings needed to render and operate the interface, such as locale, brightness, available screen size, text scaling, reduced-motion preference, app lifecycle state, keyboard input, and touch input.\n\nThis processing is used only to generate puzzles, run the game, restore progress, provide undo and redo, display statistics, apply your preferences, support accessibility, and provide optional haptic feedback. The local date is used to select the daily puzzle. These values are not used for advertising, profiling, or automated decisions about you and are not transmitted by Sudoku.',
                        ),
                        _PolicySection(
                          title: '5. Native app storage and permissions',
                          body: 'Sudoku stores one versioned save snapshot through the shared_preferences package. On Android and Windows, that snapshot is kept in application storage managed by the operating system. It contains the locally saved game and preference information described above. It is not a remote database and is not synchronized between devices.\n\nThe Android release manifest requests no Android permissions, including no Internet, location, contacts, camera, microphone, photos, advertising identifier, or broad file-storage permission. Android automatic backup is disabled. Development and profile builds may use Internet access for Flutter development tooling; that permission is not part of the distributed release configuration.\n\nSudoku does not read the clipboard. If you explicitly copy selectable policy text, the operating system or browser handles that copy action. Optional haptic feedback asks the operating system to produce a vibration response but does not provide sensor data to Sudoku.',
                        ),
                        _PolicySection(
                          title: '6. Web storage and offline operation',
                          body: 'The web version stores the save snapshot in browser local storage. It also uses the browser\'s Cache Storage and a service worker to cache the compiled Flutter app, puzzle worker, fonts, icons, and other static files. This allows the app to work offline after a successful online visit. The cached app files are not a user profile.\n\nPuzzles are generated locally in a dedicated web worker. Requests sent between the page and that worker remain inside your browser and are not sent to a puzzle server. Sudoku does not add analytics scripts, advertising scripts, tracking pixels, social-media SDKs, or its own cookies. The release build hosts its app resources under the same GitHub Pages site rather than loading runtime resources from an external CDN.\n\nBrowser storage is controlled by your browser. It may be limited, evicted, cleared, exposed to browser extensions, or included in device or browser-profile backups according to settings outside Sudoku\'s control. Multiple open tabs are not synchronized and may overwrite the same local save.',
                        ),
                        _PolicySection(
                          title: '7. GitHub Pages and web-request data',
                          body: 'The public web version is hosted by GitHub Pages. When you open or update it, your browser makes HTTPS requests to GitHub for files needed to run the app. Like other website hosts, GitHub can process request information such as your IP address, approximate location inferred from the IP address, browser and device information, operating system, requested URL or file, date and time, and security or diagnostic information. GitHub states that it logs and stores a visitor\'s IP address for security purposes.\n\nThis hosting information is separate from your Sudoku save. Sudoku does not include your puzzle, entries, notes, statistics, preferences, or locally generated identifiers in those web requests. Tom Vogel does not operate a separate analytics or visitor-log system for Sudoku. GitHub determines its own retention, security, processing locations, subprocessors, and handling of privacy requests under the GitHub General Privacy Statement:\nhttps://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement',
                        ),
                        _PolicySection(
                          title: '8. Collection, disclosure, and sale',
                          body: 'Sudoku application code does not collect personal or sensitive user data by transmitting it away from your device. It does not disclose or sell personal data, game data, or device data to advertisers, data brokers, analytics providers, or other companies. No third-party SDK is configured to collect data from the app.\n\nGitHub receives the limited web-request information described above when it hosts the web version. Google Play, an operating system, a browser, a network provider, or a distribution platform may independently process information when you download, install, update, back up, or access software. That independent processing is not controlled by Sudoku and does not give Sudoku access to your account or payment information.',
                        ),
                        _PolicySection(
                          title: '9. Retention and deletion',
                          body: 'Sudoku keeps local save data until it is overwritten through normal play or you remove it. There is currently no Sudoku account, cloud copy, server archive, export service, or recovery service.\n\n• Android: clear Sudoku\'s storage in Android settings or uninstall the app. Automatic Android backup is disabled.\n• Windows: remove Sudoku\'s data from the application-data location managed for the app. Whether an uninstaller removes application data depends on the Windows installation method.\n• Web: clear the site data for ztomz.github.io to remove local storage and cached offline files. Clearing only the browser cache may remove offline app files without removing the local-storage save; clearing all site data removes both.\n\nOperating-system backups, browser backups, extensions, or other tools may retain copies outside Sudoku\'s control. GitHub controls retention and deletion of its hosting logs under its own privacy statement.',
                        ),
                        _PolicySection(
                          title: '10. Security',
                          body: 'Sudoku minimizes risk by keeping gameplay data local, requesting no Android release permissions, disabling Android automatic backup, and avoiding accounts, remote storage, analytics, and advertising SDKs. The hosted web app is delivered over HTTPS.\n\nLocal app storage and browser local storage are not encrypted vaults and should not be used for sensitive information. Anyone with sufficient access to your device, operating-system account, browser profile, backups, or extensions may be able to read, change, or delete local data. No storage or transmission method can be guaranteed completely secure.',
                        ),
                        _PolicySection(
                          title: '11. Children\'s privacy',
                          body:
                              'Sudoku does not ask users for their name, age, contact details, or an account, and its application code does not collect personal data from users, including children. The app\'s data handling does not change based on age. Accessing the web version still produces the ordinary GitHub Pages requests described above. A parent or guardian with a privacy concern may contact Tom Vogel at $privacyContactEmail.',
                        ),
                        _PolicySection(
                          title: '12. Support and voluntary communications',
                          body:
                              'Sudoku never sends support messages automatically. If you choose to email $privacyContactEmail, the email service will provide Tom Vogel with the information you voluntarily include, such as your email address, message, and attachments. That information is used to answer the request, investigate an issue, maintain necessary correspondence, and protect against abuse. Do not send passwords or other unnecessary sensitive information.\n\nThe support mailbox is provided through Gmail. Google may process email content and metadata to provide and secure that service under the Google Privacy Policy:\nhttps://policies.google.com/privacy\n\nSupport correspondence is retained only for as long as reasonably needed for those purposes or to meet applicable legal obligations, and is not sold or used for advertising. You may request deletion of a support message by emailing the same address, subject to any legal obligation or legitimate need to retain it.',
                        ),
                        _PolicySection(
                          title: '13. Your choices and requests',
                          body:
                              'You can use the native app offline and can control or delete its local data using your device settings. You can manage browser storage and permissions using your browser settings. Because Sudoku has no account or application server, Tom Vogel cannot identify, retrieve, correct, export, or remotely delete a local save on your behalf.\n\nFor questions about this policy, Sudoku, or voluntarily submitted support correspondence, contact $privacyContactEmail. Requests concerning information processed independently by GitHub, Google Play, your browser, or your operating-system provider should also be directed to the relevant provider.',
                        ),
                        _PolicySection(
                          title: '14. Changes to this policy',
                          body: 'This policy may be updated if Sudoku\'s features, storage, permissions, dependencies, hosting, or legal obligations change. The revised policy will remain available on this page and the date at the top will be updated. Material changes to data handling will be described before they apply where required.',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class const _PolicyTitle() extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Privacy Policy', style: context.rudiTheme.text.display),
      const SizedBox(height: 10),
      Text(
        'Effective and last updated: September 2, 2026',
        style: context.rudiTheme.text.body.copyWith(
          color: context.rudiTheme.colors.mutedForeground,
        ),
      ),
      const SizedBox(height: 32),
    ],
  );
}

final class const _PolicySection({
  required final String title,
  required final String body,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.rudiTheme.text.title),
        const SizedBox(height: 8),
        Text(body, style: context.rudiTheme.text.body.copyWith(height: 1.55)),
      ],
    ),
  );
}
