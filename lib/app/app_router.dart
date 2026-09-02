import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rudi_ui/rudi_ui.dart';

import '../common/presentation/app_navigation.dart';
import '../common/presentation/destination_transition.dart';
import '../common/presentation/ui.dart';
import '../features/daily/presentation/daily_page.dart';
import '../features/game/presentation/game_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/privacy/presentation/privacy_policy_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/statistics/presentation/statistics_page.dart';
import 'sudoku_controller.dart';

GoRouter createSudokuRouter({String? initialLocation}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          _AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: _DestinationPage(destination: _Destination.home),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/daily',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: _DestinationPage(destination: _Destination.daily),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/statistics',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: _DestinationPage(destination: _Destination.statistics),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: _DestinationPage(destination: _Destination.settings),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: PrivacyPolicyPage.path,
      builder: (context, state) =>
          PrivacyPolicyPage(returnPath: state.extra as String? ?? '/'),
    ),
  ],
);

enum _Destination() {
  home,
  daily,
  statistics,
  settings,
}

final class const _DestinationPage({required final _Destination destination})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sudokuControllerProvider);
    final controller = ref.read(sudokuControllerProvider.notifier);
    return switch (destination) {
      _Destination.home => HomePage(controller: controller),
      _Destination.daily => DailyPage(controller: controller),
      _Destination.statistics => StatisticsPage(controller: controller),
      _Destination.settings => SettingsPage(controller: controller),
    };
  }
}

final class const _AppShell({
  required final StatefulNavigationShell navigationShell,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sudokuControllerProvider);
    final controller = ref.read(sudokuControllerProvider.notifier);
    final l = context.l10n;
    if (!controller.ready || controller.busy) {
      return RudiPage(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppIcon(AppSymbol.grid, size: 48),
                const SizedBox(height: 24),
                Text(
                  controller.loadFailed ? l.loadFailed : l.loading,
                  textAlign: TextAlign.center,
                ),
                if (controller.loadFailed) ...[
                  const SizedBox(height: 24),
                  RudiButton(
                    label: l.retry,
                    onPressed: () => unawaited(controller.initialize()),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    Widget content = controller.playing
        ? GamePage(controller: controller)
        : RudiPage(
            padding: EdgeInsets.zero,
            navigation: AppNavigation(
              selectedIndex: navigationShell.currentIndex,
              onSelected: (index) => navigationShell.goBranch(index),
            ),
            child: DestinationTransition(
              value: navigationShell.currentIndex,
              child: navigationShell,
            ),
          );
    if (controller.saveFailed || controller.generationFailed) {
      content = Column(
        children: [
          ColoredBox(
            color: context.rudiTheme.colors.surfaceContainer,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.saveFailed
                            ? l.saveFailed
                            : l.generationFailed,
                      ),
                    ),
                    if (controller.saveFailed)
                      RudiButton(
                        label: l.retry,
                        onPressed: () => unawaited(controller.persist()),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: content),
        ],
      );
    }
    return ColoredBox(
      color: context.rudiTheme.colors.background,
      child: content,
    );
  }
}
