import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/placeholder_view.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: const PlaceholderView(
        icon: Icons.explore_rounded,
        title: 'Discover matches',
        message: 'Filter by distance, date, format and position needed.',
      ),
    );
  }
}
