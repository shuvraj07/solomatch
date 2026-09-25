import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/session/session_provider.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/run_with_feedback.dart';
import '../../../../shared/widgets/player_avatar.dart';
import '../../../match_requests/domain/roster_entry.dart';
import '../../../matches/domain/football_match.dart';
import '../../data/review_providers.dart';
import '../../domain/review.dart';
import '../rate_sheet.dart';

/// "Rate players" on a played match: everyone who was there, for 7 days.
class RatePlayersCard extends ConsumerWidget {
  const RatePlayersCard({
    super.key,
    required this.match,
    required this.roster,
    required this.now,
  });

  final FootballMatch match;
  final List<RosterEntry> roster;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentProfileProvider);
    if (me == null || !ReviewRules.isOpen(match, now)) {
      return const SizedBox.shrink();
    }
    final everyone = ReviewRules.participants(match, roster);
    if (!everyone.contains(me.uid)) return const SizedBox.shrink();

    final rated = ref.watch(ratedByMeProvider(match.id)).value ?? const {};
    final names = {
      match.organizer.uid: (match.organizer.name, match.organizer.photoUrl),
      for (final e in roster) e.player.uid: (e.player.name, e.player.photoUrl),
    };
    final others = [
      for (final uid in everyone)
        if (uid != me.uid) uid,
    ];
    if (others.isEmpty) return const SizedBox.shrink();

    Future<void> rate(String uid) async {
      final (name, _) = names[uid]!;
      final input = await showRateSheet(
        context,
        name: name,
        matchTitle: match.title,
      );
      if (input == null || !context.mounted) return;
      await runWithFeedback(
        context,
        () => ref
            .read(reviewRepositoryProvider)
            .submit(
              Review(
                matchId: match.id,
                reviewerId: me.uid,
                revieweeId: uid,
                rating: input.rating,
                comment: input.comment,
                reviewerName: me.fullName,
                reviewerPhotoUrl: me.photoUrl,
                matchTitle: match.title,
              ),
            ),
        success: 'Thanks! Rating sent for $name',
      );
    }

    final closes = match.endAt.add(ReviewRules.window);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⭐ Rate players',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Open until ${Formatters.shortDate(closes)}. '
              '${rated.length}/${others.length} rated.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            for (final uid in others)
              ListTile(
                key: Key('rateRow_$uid'),
                contentPadding: EdgeInsets.zero,
                leading: PlayerAvatar(
                  name: names[uid]!.$1,
                  photoUrl: names[uid]!.$2,
                  radius: 18,
                ),
                title: Text(names[uid]!.$1),
                subtitle: uid == match.organizer.uid
                    ? const Text('Organizer')
                    : null,
                trailing: rated.contains(uid)
                    ? const Text('✓ Rated')
                    : OutlinedButton(
                        key: Key('rate_$uid'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                        ),
                        onPressed: () => rate(uid),
                        child: const Text('Rate'),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
