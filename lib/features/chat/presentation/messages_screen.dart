import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/placeholder_view.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: const PlaceholderView(
        icon: Icons.chat_bubble_rounded,
        title: 'No conversations yet',
        message: 'Chats open once an organizer accepts you into a match.',
      ),
    );
  }
}
