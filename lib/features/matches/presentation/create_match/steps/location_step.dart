import 'package:material_ui/material_ui.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../domain/match_draft.dart';

/// Map pin for the venue. The Google Maps picker plugs in here (Phase 3);
/// until then this step is informational and can be skipped.
class LocationStep extends StatelessWidget {
  const LocationStep({super.key, required this.draft});

  final MatchDraft draft;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final venue = draft.venue;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(Icons.map_rounded, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: AppSpacing.md),
            Text(
              venue == null ? 'No venue yet' : venue.shortLabel,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            if (venue != null) Text(venue.city),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Dropping a pin on Google Maps is coming in the next update, '
              'so players can see distance and directions. '
              'Tap Continue to skip for now.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
