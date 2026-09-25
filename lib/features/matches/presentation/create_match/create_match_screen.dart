import 'package:material_ui/material_ui.dart';

import '../../../../core/widgets/placeholder_view.dart';

class CreateMatchScreen extends StatelessWidget {
  const CreateMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create match')),
      body: const PlaceholderView(
        icon: Icons.add_circle_rounded,
        title: 'Post a match',
        message: 'Venue, time, format and the positions you need.',
      ),
    );
  }
}
