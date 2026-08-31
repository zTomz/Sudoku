import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';

import 'ui.dart';

final class const AppNavigation({
  required final int selectedIndex,
  required final ValueChanged<int> onSelected,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => RudiFloatingNavigationBar(
    selectedIndex: selectedIndex,
    onDestinationSelected: onSelected,
    backgroundColor: const Color(0xff16171b),
    indicatorColor: const Color(0xfffafaf9),
    unselectedColor: const Color(0xffffffff),
    selectedColor: const Color(0xff16171b),
    destinations: [
      RudiNavigationDestination(
        icon: const AppIcon(AppSymbol.grid),
        selectedIcon: const AppIcon(AppSymbol.grid, filled: true),
        label: context.l10n.play,
      ),
      RudiNavigationDestination(
        icon: const AppIcon(AppSymbol.calendarSimple),
        selectedIcon: const AppIcon(AppSymbol.calendarSimple, filled: true),
        label: context.l10n.daily,
      ),
      RudiNavigationDestination(
        icon: const AppIcon(AppSymbol.chart),
        selectedIcon: const AppIcon(AppSymbol.chart, filled: true),
        label: context.l10n.statistics,
      ),
      RudiNavigationDestination(
        icon: const AppIcon(AppSymbol.settings),
        selectedIcon: const AppIcon(AppSymbol.settings, filled: true),
        label: context.l10n.settings,
      ),
    ],
  );
}
