import 'package:material_ui/material_ui.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../shared/models/venue.dart';
import '../../../domain/match_draft.dart';
import 'step_props.dart';

class VenueStep extends StatelessWidget {
  const VenueStep({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.defaultCity,
  });

  final MatchDraft draft;
  final DraftUpdate onChanged;

  /// Prefills the city (the organizer's profile city).
  final String defaultCity;

  Venue get _venue => draft.venue ?? Venue(name: '', city: defaultCity);

  void _set(Venue Function(Venue v) change) =>
      onChanged((d) => d.copyWith(venue: change(d.venue ?? _venue)));

  @override
  Widget build(BuildContext context) {
    final venue = _venue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
