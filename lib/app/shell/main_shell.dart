import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../router/app_routes.dart';
import 'app_bottom_nav.dart';

/// Scaffold for the four tab branches plus the raised Create Match button.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      // Tapping the active tab again pops it back to its root.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.large(
        key: const Key('createMatchButton'),
        tooltip: 'Create match',
        onPressed: () => context.push(AppRoutes.createMatch),
        child: const Icon(Icons.add_rounded, size: 36),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onSelected: _onTabSelected,
      ),
    );
  }
}
