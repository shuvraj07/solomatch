import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/error_snackbar.dart';
import '../../../core/widgets/placeholder_view.dart';
import '../../../core/widgets/run_with_feedback.dart';
import '../../../shared/models/fitness.dart';
import '../../chat/data/chat_providers.dart';
import '../../matches/data/match_providers.dart';
import '../../profile/data/profile_providers.dart';
import '../data/match_request_providers.dart';
import 'widgets/request_card.dart';

/// Organizer view of pending requests. New requests appear live; accepted
/// or rejected ones drop off as the server updates them.
class MatchRequestsScreen extends ConsumerStatefulWidget {
  const MatchRequestsScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<MatchRequestsScreen> createState() =>
      _MatchRequestsScreenState();
}

class _MatchRequestsScreenState extends ConsumerState<MatchRequestsScreen> {
  /// Players with a decision in flight (buttons disabled).
  final _busy = <String>{};

  Future<void> _decide(String playerId, {required bool accept}) async {
    setState(() => _busy.add(playerId));
    final repo = ref.read(matchRequestRepositoryProvider);
    await runWithFeedback(
      context,
      () => accept
          ? repo.accept(widget.matchId, playerId)
          : repo.reject(widget.matchId, playerId),
      success: accept ? 'Player added to the roster ⚽' : 'Request rejected',
    );
    if (mounted) setState(() => _busy.remove(playerId));
  }

  Future<void> _message(String playerId) async {
    try {
      final id = await ref
          .read(chatRepositoryProvider)
          .openDirectChat(matchId: widget.matchId, playerId: playerId);
      if (mounted) await context.push(AppRoutes.chat(id));
    } on Object catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final match = ref.watch(matchProvider(widget.matchId)).value;
    final requests = ref.watch(pendingRequestsProvider(widget.matchId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player requests'),
        bottom: match == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(28),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    '${match.currentPlayers}/${match.maxPlayers} players · '
                    '${match.spotsRemaining} spots left',
                    key: const Key('requestsRosterCount'),
                  ),
                ),
              ),
      ),
      body: switch (requests) {
        AsyncData(value: final list) when list.isEmpty => const PlaceholderView(
          icon: Icons.inbox_rounded,
          title: 'No pending requests',
          message: 'New requests show up here instantly.',
        ),
        AsyncData(value: final list) => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screen),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, i) {
            final r = list[i];
            return RequestCard(
              request: r,
              busy: _busy.contains(r.playerId),
              onAccept: () => _decide(r.playerId, accept: true),
              onReject: () => _decide(r.playerId, accept: false),
              onMessage: () => _message(r.playerId),
              fitness:
                  ref.watch(playerProfileProvider(r.playerId)).value?.fitness ??
                  Fitness.fit,
            );
          },
        ),
        AsyncError(:final error) => Center(child: Text(errorMessage(error))),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
