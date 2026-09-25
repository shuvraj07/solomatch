import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/session/session_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/error_snackbar.dart';
import '../../../core/widgets/placeholder_view.dart';
import '../../../shared/widgets/player_avatar.dart';
import '../data/chat_providers.dart';
import '../domain/chat_models.dart';

/// Messages tab: every chat I'm in, most recent first. Live.
class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentProfileProvider)?.uid ?? '';
    final conversations = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: switch (conversations) {
        AsyncData(value: final list) when list.isEmpty => const PlaceholderView(
          icon: Icons.chat_bubble_rounded,
          title: 'No conversations yet',
          message:
              'Match group chats appear once you are on a roster. You can '
              'also message an organizer from a match page.',
        ),
        AsyncData(value: final list) => ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
          itemBuilder: (_, i) =>
              ConversationTile(conversation: list[i], me: me),
        ),
        AsyncError(:final error) => Center(child: Text(errorMessage(error))),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.me,
  });

  final Conversation conversation;
  final String me;

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    final theme = Theme.of(context);
    final unread = c.isUnreadFor(me);
    final other = c.participants[c.otherId(me)];
    final preview = c.lastMessageText == null
        ? (c.isGroup ? 'Say hi to your teammates 👋' : 'No messages yet')
        : '${c.lastMessageSenderId == me ? 'You: ' : ''}${c.lastMessageText}';

    return ListTile(
      key: Key('conversation_${c.id}'),
      onTap: () => context.push(AppRoutes.chat(c.id)),
      leading: c.isGroup
          ? const CircleAvatar(
              backgroundColor: AppColors.pitch,
              child: Text('⚽'),
            )
          : PlayerAvatar(name: other?.name ?? '?', photoUrl: other?.photoUrl),
      title: Text(
        c.displayName(me),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
      subtitle: Text(
        c.isGroup ? preview : '${c.title} · $preview',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: unread ? FontWeight.w700 : null,
          color: unread ? theme.colorScheme.onSurface : null,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (c.lastMessageAt != null && c.lastMessageText != null)
            Text(
              Formatters.relative(c.lastMessageAt!, DateTime.now()),
              style: theme.textTheme.labelSmall,
            ),
          if (unread)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: CircleAvatar(
                key: Key('unreadDot_${c.id}'),
                radius: 5,
                backgroundColor: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
