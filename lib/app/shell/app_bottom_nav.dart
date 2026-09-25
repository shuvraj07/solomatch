import 'package:material_ui/material_ui.dart';

class _NavItem {
  const _NavItem(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _items = [
  _NavItem('Home', Icons.home_outlined, Icons.home_rounded),
  _NavItem('Discover', Icons.explore_outlined, Icons.explore_rounded),
  _NavItem(
    'Messages',
    Icons.chat_bubble_outline_rounded,
    Icons.chat_bubble_rounded,
  ),
  _NavItem('Profile', Icons.person_outline_rounded, Icons.person_rounded),
];

/// Bottom bar with a notch in the middle for the Create Match button.
/// Indexes map 1:1 to the shell branches.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelected,
    this.messagesBadge = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;

  /// Unread conversations, shown on the Messages tab.
  final int messagesBadge;

  @override
  Widget build(BuildContext context) {
    Widget item(int index) => Expanded(
      child: _NavButton(
        item: _items[index],
        selected: index == currentIndex,
        onTap: () => onSelected(index),
        badge: index == 2 ? messagesBadge : 0,
      ),
    );

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      padding: EdgeInsets.zero,
      height: 72,
      child: Row(
        children: [
          item(0),
          item(1),
          const SizedBox(width: 96),
          item(2),
          item(3),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });

  final _NavItem item;
  final int badge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;

    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Badge(
              isLabelVisible: badge > 0,
              label: Text('$badge'),
              child: Icon(
                selected ? item.selectedIcon : item.icon,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
