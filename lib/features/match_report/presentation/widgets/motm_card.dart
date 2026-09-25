import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/run_with_feedback.dart';
import '../../../../shared/widgets/player_avatar.dart';
import '../../../match_requests/domain/roster_entry.dart';
import '../../../matches/domain/football_match.dart';
import '../../data/match_report_providers.dart';

/// Man of the Match on a completed match: the result once decided,
/// otherwise the ballot for people who were there.
class MotmCard extends ConsumerWidget {
  const MotmCard({
    super.key,
    required this.match,
    required this.roster,
    required this.viewerUid,
    required this.now,
  });

  final FootballMatch match;
  final List<RosterEntry> roster;
  final String viewerUid;
  final DateTime now;

  bool get _canVote =>
      match.isPostMatchOpen(now) &&
      (match.isOrganizer(viewerUid) ||
          roster.any((e) => e.player.uid == viewerUid));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final result = match.motm;

    if (result != null) {
      return _Frame(
        child: result.winners.isEmpty
            ? const Text('No Man of the Match this time: nobody voted.')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.winners.length > 1
                        ? '🏆 Joint Men of the Match'
                        : '🏆 Man of the Match',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final w in result.winners)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: PlayerAvatar(name: w.name, photoUrl: w.photoUrl),
                      title: Text(w.name, key: Key('motmWinner_${w.uid}')),
                      subtitle: Text(
                        '${result.votes} of ${result.totalVotes} votes',
                      ),
                    ),
                ],
              ),
      );
    }

    if (!_canVote) {
      return const _Frame(
        child: Text('🏆 Man of the Match voting is open for players.'),
      );
    }

    final myVote = ref.watch(myMotmVoteProvider(match.id)).value;
    final nominees = [
      for (final e in roster)
        if (e.player.uid != viewerUid) e.player,
    ];

    return _Frame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🏆 Vote Man of the Match', style: theme.textTheme.titleMedium),
          Text(
            'Closes ${Formatters.shortDate(match.votingClosesAt!)} at '
            '${Formatters.time(match.votingClosesAt!)}. '
            'You can change your vote until then.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final p in nominees)
            ListTile(
              key: Key('motmNominee_${p.uid}'),
              contentPadding: EdgeInsets.zero,
              leading: PlayerAvatar(name: p.name, photoUrl: p.photoUrl),
              title: Text(p.name),
              subtitle: Text(p.primaryPosition.label),
              trailing: myVote == p.uid
                  ? const Icon(Icons.how_to_vote_rounded)
                  : const Icon(Icons.radio_button_unchecked_rounded),
              selected: myVote == p.uid,
              onTap: () => runWithFeedback(
                context,
                () => ref
                    .read(matchReportRepositoryProvider)
                    .vote(match.id, viewerUid, p.uid),
                success: 'Vote saved for ${p.name}',
              ),
            ),
        ],
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.volt.withValues(alpha: 0.18),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );
  }
}
