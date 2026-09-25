import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers/clock_provider.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/session/session_provider.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../matches/data/match_providers.dart';
import '../../matches/domain/match_draft.dart';
import '../data/venue_providers.dart';
import '../domain/draft_booking.dart';
import '../domain/venue_models.dart';
import 'widgets/venue_widgets.dart';

/// A venue's page: details, free times and ratings. Tapping a free slot
/// books it for a new match (or, in [pick] mode, returns it to the
/// create-match flow).
class VenueDetailsScreen extends ConsumerStatefulWidget {
  const VenueDetailsScreen({
    super.key,
    required this.venueId,
    this.pick = false,
  });

  final String venueId;
  final bool pick;

  @override
  ConsumerState<VenueDetailsScreen> createState() => _VenueDetailsScreenState();
}

class _VenueDetailsScreenState extends ConsumerState<VenueDetailsScreen> {
  DateTime? _day;

  Future<void> _choose(VenueProfile venue, VenueSlot slot) async {
    if (widget.pick) {
      context.pop((venue, slot));
      return;
    }
    final go = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book this time?'),
        content: Text(
          '${venue.name}\n${Formatters.longDate(slot.startAt)}, '
          '${Formatters.timeRange(slot.startAt, slot.endAt)}\n\n'
          'You’ll set up the match next. The slot is booked when you publish.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            key: const Key('confirmBookSlotButton'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Set up match'),
          ),
        ],
      ),
    );
    final profile = ref.read(currentProfileProvider);
    if (go != true || profile == null || !mounted) return;
    final draft = MatchDraft(
      id: ref.read(matchRepositoryProvider).newMatchId(),
      organizerId: profile.uid,
    ).bookSlot(venue, slot);
    await context.push(AppRoutes.createMatchFlow, extra: draft);
  }

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(clockProvider)();
    // Date only: it's part of the slots provider key.
    final day = DateUtils.dateOnly(_day ?? now);
    final venue = ref.watch(venueProvider(widget.venueId));
    final slots = ref.watch(
      venueDaySlotsProvider((venueId: widget.venueId, day: day)),
    );
    final ratings = ref.watch(venueRatingsProvider(widget.venueId)).value ?? [];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.pick ? 'Pick a time' : 'Venue')),
      body: switch (venue) {
        AsyncData(value: final v?) => ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
              ),
              child: VenueInfo(venue: v),
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
              ),
              child: Text('Free times', style: theme.textTheme.titleLarge),
            ),
            const SizedBox(height: AppSpacing.sm),
            DayStrip(
              today: now,
              selected: day,
              onSelected: (d) => setState(() => _day = d),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
              ),
              child: switch (slots) {
                AsyncData(value: final list) => _Slots(
                  slots: [
                    for (final s in list)
                      if (s.isFree && s.startAt.isAfter(now)) s,
                  ],
                  bookedCount: list.where((s) => !s.isFree).length,
                  onTap: (s) => _choose(v, s),
                ),
                AsyncError() => const Text('Couldn’t load times.'),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ratings', style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  if (v.rating case final r?)
                    RatingBreakdown(rating: r)
                  else
                    const Text(
                      'No ratings yet. Players rate the venue after a match '
                      'booked here.',
                    ),
                  for (final r in ratings) VenueRatingTile(rating: r, now: now),
                ],
              ),
            ),
          ],
        ),
        AsyncData() => const Center(child: Text('This venue is not listed.')),
        AsyncError() => const Center(child: Text('Couldn’t load the venue.')),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Slots extends StatelessWidget {
  const _Slots({
    required this.slots,
    required this.bookedCount,
    required this.onTap,
  });

  final List<VenueSlot> slots;
  final int bookedCount;
  final ValueChanged<VenueSlot> onTap;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (slots.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              bookedCount > 0
                  ? 'Fully booked this day. Try another day.'
                  : 'No free times listed this day.',
              style: TextStyle(color: muted),
            ),
          ),
        for (final s in slots)
          SlotTile(
            slot: s,
            onTap: () => onTap(s),
            trailing: const Text('Book'),
          ),
        if (slots.isNotEmpty && bookedCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              '$bookedCount already booked',
              style: TextStyle(color: muted),
            ),
          ),
      ],
    );
  }
}
