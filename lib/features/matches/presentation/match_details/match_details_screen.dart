import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/session/session_provider.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/widgets/placeholder_view.dart';
import '../../../../core/widgets/run_with_feedback.dart';
import '../../../../shared/widgets/player_avatar.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../chat/presentation/widgets/match_chat_buttons.dart';
import '../../../match_report/presentation/widgets/motm_card.dart';
import '../../../match_requests/data/match_request_providers.dart';
import '../../../match_requests/domain/join_request.dart';
import '../../../match_requests/domain/roster_entry.dart';
import '../../../match_requests/presentation/request_to_join_sheet.dart';
import '../../../reviews/presentation/widgets/rate_players_card.dart';
import '../../data/match_providers.dart';
import '../../domain/football_match.dart';
import '../../domain/match_action.dart';
import '../../domain/match_status.dart';
import 'widgets/match_action_bar.dart';
import 'widgets/roster_summary.dart';

/// Live match page. The match, the viewer's own request and the roster are
/// separate Firestore streams, so counts, names and the action button all
/// change on screen the moment anything changes on the server.
class MatchDetailsScreen extends ConsumerWidget {
  const MatchDetailsScreen({super.key, required this.matchId});

  final String matchId;

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String keep,
    required String confirm,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(keep),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirm),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _cancelMatch(BuildContext context, WidgetRef ref) async {
    final ok = await _confirm(
      context,
      title: 'Cancel this match?',
      body:
          'Everyone who asked to join will see it as cancelled. '
          "This can't be undone.",
      keep: 'Keep match',
      confirm: 'Cancel match',
    );
    if (!ok || !context.mounted) return;
    await runWithFeedback(
      context,
      () => ref.read(matchRepositoryProvider).cancelMatch(matchId),
    );
  }

  Future<void> _requestToJoin(
    BuildContext context,
    WidgetRef ref,
    FootballMatch match,
  ) async {
    final profile = ref.read(currentProfileProvider);
    if (profile == null) return;
    final input = await showRequestToJoinSheet(
      context,
      match: match,
      suggested: profile.primaryPosition.group,
    );
    if (input == null || !context.mounted) return;
    await runWithFeedback(
      context,
      () => ref
          .read(matchRequestRepositoryProvider)
          .requestToJoin(
            match: match,
            player: profile,
            preferredGroup: input.group,
            message: input.message,
          ),
      success: 'Request sent. The organizer will get back to you.',
    );
  }

  Future<void> _withdraw(BuildContext context, WidgetRef ref) async {
    final uid = ref.read(currentProfileProvider)?.uid;
    if (uid == null) return;
    await runWithFeedback(
      context,
      () => ref
          .read(matchRequestRepositoryProvider)
          .withdrawRequest(matchId, uid),
      success: 'Request withdrawn',
    );
  }

  Future<void> _leave(BuildContext context, WidgetRef ref) async {
    final ok = await _confirm(
      context,
      title: 'Leave this match?',
      body: 'Your place opens up for someone else.',
      keep: 'Stay',
      confirm: 'Leave match',
    );
    if (!ok || !context.mounted) return;
    await runWithFeedback(
      context,
      () => ref.read(matchRequestRepositoryProvider).leave(matchId),
      success: 'You left the match',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final match = ref.watch(matchProvider(matchId));
    final uid = ref.watch(currentProfileProvider)?.uid ?? '';
    final myRequest = ref.watch(myRequestProvider(matchId)).value;
    final roster = ref.watch(rosterProvider(matchId)).value ?? const [];

    // The organizer deciding shows up here in real time.
    ref.listen(myRequestProvider(matchId), (previous, next) {
      final was = previous?.value?.status;
      final now = next.value?.status;
      if (was != RequestStatus.pending || was == now) return;
      final message = switch (now) {
        RequestStatus.accepted => "You're in! ⚽",
        RequestStatus.rejected => "Your request wasn't accepted this time.",
        _ => null,
      };
      if (message != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      }
    });

    return switch (match) {
      AsyncData(value: final m?) => _Loaded(
        match: m,
        roster: roster,
        myRequest: myRequest,
        viewerUid: uid,
        now: DateTime.now(),
        action: resolveMatchAction(m, uid, myRequest: myRequest),
        pendingRequests: m.isOrganizer(uid)
            ? ref.watch(pendingRequestsProvider(matchId)).value?.length ?? 0
            : 0,
        onCancel: () => _cancelMatch(context, ref),
        onRequestToJoin: () => _requestToJoin(context, ref, m),
        onWithdraw: () => _withdraw(context, ref),
        onLeave: () => _leave(context, ref),
        onManageRequests: () => context.push(AppRoutes.matchRequests(matchId)),
        onEditReport: () => context.push(AppRoutes.matchReport(matchId)),
      ),
      AsyncData() => Scaffold(
        appBar: AppBar(),
        body: const PlaceholderView(
          icon: Icons.search_off_rounded,
          title: 'Match not found',
          message: 'It may have been removed.',
        ),
      ),
      AsyncError(:final error) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(errorMessage(error))),
      ),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({
    required this.match,
    required this.roster,
    required this.myRequest,
    required this.viewerUid,
    required this.now,
    required this.action,
    required this.pendingRequests,
    required this.onCancel,
    required this.onRequestToJoin,
    required this.onWithdraw,
    required this.onLeave,
    required this.onManageRequests,
    required this.onEditReport,
  });

  final FootballMatch match;
  final List<RosterEntry> roster;
  final JoinRequest? myRequest;
  final String viewerUid;
  final DateTime now;
  final MatchAction action;
  final int pendingRequests;
  final VoidCallback onCancel;
  final VoidCallback onRequestToJoin;
  final VoidCallback onWithdraw;
  final VoidCallback onLeave;
  final VoidCallback onManageRequests;
  final VoidCallback onEditReport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = match;

    Widget info(IconData icon, String title, [String? subtitle]) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
    );

    Widget section(String title, String body) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(body, style: theme.textTheme.bodyLarge),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (action == MatchAction.organizer)
            PopupMenuButton<String>(
              key: const Key('matchMenu'),
              onSelected: (_) => onCancel(),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'cancel', child: Text('Cancel match')),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          0,
          AppSpacing.screen,
          AppSpacing.xl,
        ),
        children: [
          if (m.photos.isNotEmpty) ...[
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: m.photos.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.network(m.photos[i], fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          StatusChip(status: m.status),
          const SizedBox(height: AppSpacing.sm),
          Text(m.title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            key: const Key('organizerLink'),
            onTap: () => context.push(AppRoutes.playerProfile(m.organizer.uid)),
            child: Row(
              children: [
                PlayerAvatar(
                  name: m.organizer.name,
                  photoUrl: m.organizer.photoUrl,
                  radius: 16,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Organized by ${m.organizer.name}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          info(
            Icons.place_rounded,
            m.venue.shortLabel,
            '${m.venue.city} · ${m.isIndoor ? 'Indoor' : 'Outdoor'}',
          ),
          info(
            Icons.event_rounded,
            Formatters.longDate(m.startAt),
            '${Formatters.timeRange(m.startAt, m.endAt)} · '
            '${Formatters.duration(m.duration)}',
          ),
          info(
            Icons.sports_soccer_rounded,
            '${m.format.label} · ${m.maxPlayers} players',
            'Skill: ${m.skillLevel.label}',
          ),
          info(Icons.payments_outlined, m.price.display, 'Per player'),
          const SizedBox(height: AppSpacing.md),
          MatchChatButtons(
            match: m,
            roster: roster,
            myRequest: myRequest,
            viewerUid: viewerUid,
          ),
          if (m.status == MatchStatus.completed) ...[
            MotmCard(match: m, roster: roster, viewerUid: viewerUid, now: now),
            const SizedBox(height: AppSpacing.md),
            RatePlayersCard(match: m, roster: roster, now: now),
            if (m.isOrganizer(viewerUid) && m.isPostMatchOpen(now))
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: OutlinedButton.icon(
                  key: const Key('editReportButton'),
                  onPressed: onEditReport,
                  icon: const Icon(Icons.edit_note_rounded),
                  label: Text(
                    m.report == null
                        ? 'Add match report (goals, cards)'
                        : 'Edit match report',
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
          ],
          RosterSummary(match: m, roster: roster),
          if (m.description.isNotEmpty) section('About', m.description),
          if (m.rules.isNotEmpty) section('Rules', m.rules),
        ],
      ),
      bottomNavigationBar: MatchActionBar(
        action: action,
        pendingRequests: pendingRequests,
        onRequestToJoin: onRequestToJoin,
        onWithdraw: onWithdraw,
        onLeave: onLeave,
        onManageRequests: onManageRequests,
      ),
    );
  }
}
