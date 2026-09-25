import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/session/session_provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/error_snackbar.dart';
import '../../../core/widgets/placeholder_view.dart';
import '../data/notification_providers.dart';
import '../domain/app_notification.dart';

/// In-app inbox. Live: new notifications appear while it's open.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(inboxProvider);
    final uid = ref.watch(currentUidProvider);
    final unread = [
      for (final n in inbox.value ?? const <AppNotification>[])
        if (!n.read) n.id,
    ];

    Future<void> open(AppNotification n) async {
      if (uid != null && !n.read) {
        await ref.read(notificationRepositoryProvider).markRead(uid, n.id);
      }
      if (!context.mounted) return;
      final route = n.route;
      final matchId = n.matchId;
      if (route != null && route.startsWith(AppRoutes.owner)) {
        // Owner tabs are shell roots.
        context.go(route);
      } else if (route != null) {
        await context.push(route);
      } else if (matchId != null) {
        await context.push(AppRoutes.matchDetails(matchId));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unread.isNotEmpty && uid != null)
            TextButton(
              key: const Key('markAllReadButton'),
              onPressed: () => ref
                  .read(notificationRepositoryProvider)
                  .markAllRead(uid, unread),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: switch (inbox) {
        AsyncData(value: final list) when list.isEmpty => const PlaceholderView(
          icon: Icons.notifications_none_rounded,
          title: 'No notifications yet',
          message: 'Join requests, accepts and match reminders show up here.',
        ),
        AsyncData(value: final list) => ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final n = list[i];
            final theme = Theme.of(context);
            return ListTile(
              key: Key('notification_${n.id}'),
              onTap: () => open(n),
              tileColor: n.read
                  ? null
                  : theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                child: Text(n.emoji),
              ),
              title: Text(
                n.title,
                style: TextStyle(
                  fontWeight: n.read ? FontWeight.w500 : FontWeight.w800,
                ),
              ),
              subtitle: Text(n.body),
              trailing: n.createdAt == null
                  ? null
                  : Text(
                      Formatters.relative(n.createdAt!, DateTime.now()),
                      style: theme.textTheme.labelSmall,
                    ),
            );
          },
        ),
        AsyncError(:final error) => Center(child: Text(errorMessage(error))),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
