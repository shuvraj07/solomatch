import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/models/match_format.dart';
import '../../domain/venue_models.dart';

/// Phone numbers the rules accept: digits, spaces, + and -, 7–20 chars.
final _phone = RegExp(r'^[+0-9 -]{7,20}$');

String? validatePhone(String? v) => _phone.hasMatch((v ?? '').trim())
    ? null
    : 'Enter a phone number players can call';

/// The editable venue fields, used in owner setup and "Edit venue". Wrap it
/// in a [Form] and validate before saving.
class VenueFormFields extends StatelessWidget {
  const VenueFormFields({
    super.key,
    required this.venue,
    required this.onChanged,
  });

  final VenueProfile venue;
  final ValueChanged<VenueProfile> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget heading(String t) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Text(t, style: theme.textTheme.titleSmall),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          key: const Key('venueNameInput'),
          initialValue: venue.name,
          textCapitalization: TextCapitalization.words,
          validator: (v) =>
              (v ?? '').trim().length < 2 ? 'Enter the venue name' : null,
          onChanged: (v) => onChanged(venue.copyWith(name: v)),
          decoration: const InputDecoration(
            labelText: 'Venue name',
            hintText: 'e.g. Dhuku Futsal',
            prefixIcon: Icon(Icons.stadium_rounded),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          key: const Key('venueAddressInput'),
          initialValue: venue.address,
          textCapitalization: TextCapitalization.words,
          onChanged: (v) => onChanged(venue.copyWith(address: v)),
          decoration: const InputDecoration(
            labelText: 'Area / address',
            hintText: 'e.g. Baneshwor',
            prefixIcon: Icon(Icons.signpost_outlined),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          key: const Key('venueCityInput'),
          initialValue: venue.city,
          textCapitalization: TextCapitalization.words,
          validator: (v) => (v ?? '').trim().isEmpty ? 'Enter the city' : null,
          onChanged: (v) => onChanged(venue.copyWith(city: v)),
          decoration: const InputDecoration(
            labelText: 'City',
            prefixIcon: Icon(Icons.location_city_rounded),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          key: const Key('venuePhoneInput'),
          initialValue: venue.phone,
          keyboardType: TextInputType.phone,
          validator: validatePhone,
          onChanged: (v) => onChanged(venue.copyWith(phone: v)),
          decoration: const InputDecoration(
            labelText: 'Booking phone',
            prefixIcon: Icon(Icons.phone_rounded),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          key: const Key('venuePriceInput'),
          initialValue: venue.pricePerHour == 0 ? '' : '${venue.pricePerHour}',
          keyboardType: TextInputType.number,
          validator: (v) {
            final n = int.tryParse((v ?? '').trim());
            return n == null || n < 0 || n > 100000
                ? 'Enter a price from 0 to 100000'
                : null;
          },
          onChanged: (v) => onChanged(
            venue.copyWith(pricePerHour: int.tryParse(v.trim()) ?? 0),
          ),
          decoration: const InputDecoration(
            labelText: 'Usual price per hour (NPR)',
            helperText: 'You can set a different price on each slot',
            prefixIcon: Icon(Icons.payments_outlined),
          ),
        ),
        SwitchListTile(
          key: const Key('venueIndoorSwitch'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Indoor'),
          subtitle: const Text('Futsal hall or covered pitch'),
          value: venue.isIndoor,
          onChanged: (v) => onChanged(venue.copyWith(isIndoor: v)),
        ),
        heading('Match sizes you can host'),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final f in MatchFormat.values)
              FilterChip(
                key: Key('venueFormat_${f.name}'),
                label: Text(f.label),
                selected: venue.formats.contains(f),
                onSelected: (on) => onChanged(
                  venue.copyWith(
                    formats: on
                        ? {...venue.formats, f}
                        : ({...venue.formats}..remove(f)),
                  ),
                ),
              ),
          ],
        ),
        heading('Facilities'),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final a in Amenity.values)
              FilterChip(
                key: Key('amenity_${a.name}'),
                label: Text('${a.emoji} ${a.label}'),
                selected: venue.amenities.contains(a),
                onSelected: (on) => onChanged(
                  venue.copyWith(
                    amenities: on
                        ? {...venue.amenities, a}
                        : ({...venue.amenities}..remove(a)),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        TextFormField(
          initialValue: venue.description,
          maxLines: 4,
          maxLength: 1000,
          onChanged: (v) => onChanged(venue.copyWith(description: v)),
          decoration: const InputDecoration(
            labelText: 'About the venue (optional)',
            hintText: 'Turf type, how to find you, rules…',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}
