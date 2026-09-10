import 'package:flutter/widgets.dart';
import 'package:rudi_ui/rudi_ui.dart';
import 'package:solar_icons/solar_icons.dart';

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
    destinations: [
      RudiNavigationDestination(
        icon: const Icon(SolarIconsOutline.widget_5, size: 24),
        selectedIcon: const Icon(SolarIconsBold.widget_5, size: 24),
        label: context.l10n.play,
      ),
      RudiNavigationDestination(
        icon: const Icon(SolarIconsOutline.calendar, size: 24),
        selectedIcon: const Icon(SolarIconsBold.calendar, size: 24),
        label: context.l10n.daily,
      ),
      RudiNavigationDestination(
        icon: const Icon(SolarIconsOutline.chart, size: 24),
        selectedIcon: const Icon(SolarIconsBold.chart, size: 24),
        label: context.l10n.statistics,
      ),
      RudiNavigationDestination(
        icon: const Icon(SolarIconsOutline.settings, size: 24),
        selectedIcon: const Icon(SolarIconsBold.settings, size: 24),
        label: context.l10n.settings,
      ),
    ],
  );
}
