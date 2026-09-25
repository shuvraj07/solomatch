import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme/app_spacing.dart';
import '../../match_requests/domain/roster_entry.dart';
import '../../matches/domain/football_match.dart';
import '../data/venue_providers.dart';
import 'rate_venue_sheet.dart';

/// After a match at a SoloMatch venue: "Rate the venue" for the people who
/// played (up to 14 days after, once).
class RateVenueCard extends ConsumerWidget {
  const RateVenueCard({
    super.key,
    required this.match,
    required this.roster,
    required this.viewerUid,
    required this.now,
  });

  static const window = Duration(days: 14);

  final FootballMatch match;
  final List<RosterEntry> roster;
  final String viewerUid;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venueId = match.venue.venueId;
    final wasThere =
        match.isOrganizer(viewerUid) ||
        roster.any((r) => r.player.uid == viewerUid);
    if (venueId == null || !wasThere || now.isAfter(match.endAt.add(window))) {
      return const SizedBox.shrink();
    }
    final rated = ref.watch(
      hasRatedVenueProvider((
        venueId: venueId,
        matchId: match.id,
        uid: viewerUid,
      )),
    );
    if (rated.value != false) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: OutlinedButton.icon(
        key: const Key('rateVenueButton'),
        onPressed: () => showRateVenueSheet(context, match),
        icon: const Icon(Icons.stadium_rounded),
        label: Text('Rate ${match.venue.name}'),
      ),
    );
  }
}
