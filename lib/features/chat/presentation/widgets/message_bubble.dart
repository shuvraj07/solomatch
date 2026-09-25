import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/chat_models.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.senderName,
    this.status,
  });

  final ChatMessage message;
  final bool isMine;

  /// Shown above others' messages in group chats.
  final String? senderName;

  /// "Seen", "Seen by 3", "Sending…" under my latest message.
  final String? status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bg = isMine ? scheme.primary : scheme.surfaceContainerHighest;
    final fg = isMine ? scheme.onPrimary : scheme.onSurface;
    final image = message.imageUrl;
    final sentAt = message.sentAt;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            crossAxisAlignment: isMine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (senderName case final name?)
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.sm,
                    bottom: 2,
                  ),
                  child: Text(name, style: theme.textTheme.labelSmall),
                ),
              Container(
                padding: image == null
                    ? const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      )
                    : const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: image == null
                    ? Text(message.text ?? '', style: TextStyle(color: fg))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg - 3),
                        child: Image.network(
                          image,
                          width: 220,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  [
                    if (sentAt != null) Formatters.time(sentAt),
                    ?status,
                  ].join(' · '),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
