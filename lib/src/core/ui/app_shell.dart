import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _navigationRailWidth = 144.0;

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = navigationShell.currentIndex;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            SizedBox(
              width: _navigationRailWidth,
              child: NavigationRail(
                selectedIndex: selectedIndex,
                labelType: NavigationRailLabelType.all,
                minWidth: _navigationRailWidth,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.folder_outlined),
                    selectedIcon: Icon(Icons.folder),
                    label: Text('Projects'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.palette_outlined),
                    selectedIcon: Icon(Icons.palette),
                    label: Text('Style Lab'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.account_tree_outlined),
                    selectedIcon: Icon(Icons.account_tree),
                    label: Text('Plot Lab'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.sync_alt_outlined),
                    selectedIcon: Icon(Icons.sync_alt),
                    label: Text('Workflow Runs'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: Text('Settings'),
                  ),
                ],
                onDestinationSelected: (index) {
                  navigationShell.goBranch(
                    index,
                    initialLocation: index == selectedIndex,
                  );
                },
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      ),
    );
  }
}
