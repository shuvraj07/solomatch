import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/session/session_provider.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/error_snackbar.dart';
import '../../../core/widgets/placeholder_view.dart';
import '../../../core/widgets/run_with_feedback.dart';
import '../../safety/data/safety_providers.dart';
import '../data/chat_providers.dart';
import '../domain/chat_models.dart';
import 'widgets/message_bubble.dart';

/// One conversation. New messages appear live; opening it (and new
/// messages arriving while it's open) moves my read marker.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  bool _sendingPhoto = false;
  DateTime? _markedUpTo;

  String get _me => ref.read(currentProfileProvider)?.uid ?? '';

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _markRead(List<ChatMessage> messages) {
    final newest = messages.lastOrNull?.sentAt;
    if (newest == null || _me.isEmpty) return;
    if (_markedUpTo != null && !newest.isAfter(_markedUpTo!)) return;
    _markedUpTo = newest;
    unawaited(
      ref
          .read(chatRepositoryProvider)
          .markRead(widget.conversationId, _me)
          .catchError((Object _) {}),
    );
  }

  Future<void> _sendText() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    await runWithFeedback(
      context,
      () => ref
          .read(chatRepositoryProvider)
          .sendText(widget.conversationId, _me, text),
    );
  }

  Future<void> _sendPhoto() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (file == null || !mounted) return;
    setState(() => _sendingPhoto = true);
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    await runWithFeedback(
      context,
      () => ref
          .read(chatRepositoryProvider)
          .sendImage(widget.conversationId, _me, bytes),
    );
    if (mounted) setState(() => _sendingPhoto = false);
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentProfileProvider)?.uid ?? '';
    final conversation = ref.watch(conversationProvider(widget.conversationId));
    final messages = ref.watch(messagesProvider(widget.conversationId));
    final blocked = ref.watch(blockedIdsProvider);

    ref.listen(messagesProvider(widget.conversationId), (_, next) {
      if (next.value case final list?) _markRead(list);
    });

    final c = conversation.value;
    if (conversation is AsyncData && c == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const PlaceholderView(
          icon: Icons.speaker_notes_off_rounded,
          title: 'Chat not available',
          message: "You're no longer part of this conversation.",
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: c == null
            ? null
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.displayName(me)),
                  Text(
                    c.isGroup ? '${c.participantIds.length} members' : c.title,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
        actions: [
          if (c != null)
            IconButton(
              tooltip: 'Open match',
              icon: const Icon(Icons.sports_soccer_rounded),
              onPressed: () => context.push(AppRoutes.matchDetails(c.matchId)),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: switch (messages) {
              AsyncData(value: final list) when list.isEmpty => Center(
                child: Text(
                  c?.isGroup ?? false
                      ? 'Say hi to your teammates 👋'
                      : 'Start the conversation 👋',
                ),
              ),
              AsyncData(value: final list) => _MessageList(
                messages: [
                  for (final msg in list)
                    if (!blocked.contains(msg.senderId)) msg,
                ],
                conversation: c,
                me: me,
              ),
              AsyncError(:final error) => Center(
                child: Text(errorMessage(error)),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.xs,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  IconButton(
                    key: const Key('sendPhotoButton'),
                    tooltip: 'Send photo',
                    onPressed: _sendingPhoto ? null : _sendPhoto,
                    icon: _sendingPhoto
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.photo_outlined),
                  ),
                  Expanded(
                    child: TextField(
                      key: const Key('chatInput'),
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 2000,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendText(),
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        counterText: '',
                      ),
                    ),
                  ),
                  IconButton.filled(
                    key: const Key('sendButton'),
                    tooltip: 'Send',
                    onPressed: _sendText,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.conversation,
    required this.me,
  });

  final List<ChatMessage> messages;
  final Conversation? conversation;
  final String me;

  String? _status(int index) {
    final m = messages[index];
    if (m.senderId != me) return null;
    // Only under my most recent message.
    if (messages.skip(index + 1).any((x) => x.senderId == me)) return null;
    final sentAt = m.sentAt;
    if (sentAt == null) return 'Sending…';
    final c = conversation;
    if (c == null) return null;
    final seen = c.seenBy(sentAt, me);
    if (seen == 0) return null;
    return c.isGroup ? 'Seen by $seen' : 'Seen';
  }

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: messages.length,
      itemBuilder: (_, i) {
        final index = messages.length - 1 - i;
        final m = messages[index];
        final isMine = m.senderId == me;
        final showName =
            !isMine &&
            (c?.isGroup ?? false) &&
            (index == 0 || messages[index - 1].senderId != m.senderId);
        return MessageBubble(
          key: Key('message_${m.id}'),
          message: m,
          isMine: isMine,
          senderName: showName ? c?.participants[m.senderId]?.name : null,
          status: _status(index),
        );
      },
    );
  }
}
