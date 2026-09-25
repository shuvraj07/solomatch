import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/placeholder_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find your next match ⚽')),
      body: const PlaceholderView(
        icon: Icons.sports_soccer_rounded,
        title: 'Matches near you',
        message: 'Nearby matches will appear here.',
      ),
    );
  }
}
