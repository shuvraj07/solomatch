import 'package:material_ui/material_ui.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../shared/models/venue.dart';
import '../../../../venues/domain/draft_booking.dart';
import '../../../domain/match_draft.dart';
import 'step_props.dart';

class VenueStep extends StatelessWidget {
  const VenueStep({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.defaultCity,
    this.onBookVenue,
  });

  final MatchDraft draft;
  final DraftUpdate onChanged;

  /// Prefills the city (the organizer's profile city).
  final String defaultCity;

  /// Opens the venue list to pick a free slot at a SoloMatch venue.
  final VoidCallback? onBookVenue;

  Venue get _venue => draft.venue ?? Venue(name: '', city: defaultCity);

  void _set(Venue Function(Venue v) change) =>
      onChanged((d) => d.copyWith(venue: change(d.venue ?? _venue)));

  @override
  Widget build(BuildContext context) {
    final venue = _venue;
    final theme = Theme.of(context);
    final booked = draft.booking != null;
    final start = draft.startAt;
    final end = draft.endAt;

    if (booked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            key: const Key('bookedVenueCard'),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✅ Booking', style: theme.textTheme.labelLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text('🏟️ ${venue.name}', style: theme.textTheme.titleMedium),
                  Text(
                    '📍 ${[venue.address, venue.city].where((s) => s.isNotEmpty).join(', ')}',
                  ),
                  if (start != null && end != null)
                    Text(
                      '🗓 ${Formatters.longDate(start)}\n'
                      '⏰ ${Formatters.timeRange(start, end)}',
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'The slot is booked for you when you publish. '
                    'Date and time come from the booking.',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              if (onBookVenue != null)
                TextButton.icon(
                  onPressed: onBookVenue,
                  icon: const Icon(Icons.swap_horiz_rounded),
                  label: const Text('Change'),
                ),
              TextButton.icon(
                key: const Key('removeBookingButton'),
                onPressed: () => onChanged((d) => d.withoutBooking()),
                icon: const Icon(Icons.close_rounded),
                label: const Text('Type a venue instead'),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onBookVenue != null) ...[
          FilledButton.tonalIcon(
            key: const Key('bookVenueButton'),
            onPressed: onBookVenue,
            icon: const Icon(Icons.event_available_rounded),
            label: const Text('Book a free slot at a SoloMatch venue'),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Or type the venue yourself:',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        TextFormField(
          key: const Key('venueNameField'),
          initialValue: venue.name,
          textCapitalization: TextCapitalization.words,
          onChanged: (v) => _set((x) => x.copyWith(name: v)),
          decoration: const InputDecoration(
            labelText: 'Venue name',
            hintText: 'e.g. Dhuku Futsal',
            prefixIcon: Icon(Icons.stadium_rounded),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          initialValue: venue.address,
          textCapitalization: TextCapitalization.words,
          onChanged: (v) => _set((x) => x.copyWith(address: v)),
          decoration: const InputDecoration(
            labelText: 'Area / address',
            hintText: 'e.g. Baneshwor',
            prefixIcon: Icon(Icons.signpost_outlined),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          key: const Key('venueCityField'),
          initialValue: venue.city,
          textCapitalization: TextCapitalization.words,
          onChanged: (v) => _set((x) => x.copyWith(city: v)),
          decoration: const InputDecoration(
            labelText: 'City',
            prefixIcon: Icon(Icons.location_city_rounded),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Indoor venue'),
          subtitle: const Text('Futsal hall, covered pitch…'),
          value: draft.isIndoor,
          onChanged: (v) => onChanged((d) => d.copyWith(isIndoor: v)),
        ),
      ],
    );
  }
}
