import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/placeholder_view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const PlaceholderView(
        icon: Icons.person_rounded,
        title: 'Your football profile',
        message: 'Positions, skill level, stats and reviews.',
      ),
    );
  }
}
