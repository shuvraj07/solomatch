import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/providers/clock_provider.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../app/session/session_provider.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../data/venue_providers.dart';
import '../widgets/venue_widgets.dart';

/// The owner's venue as players see it, plus ratings.
class OwnerVenueScreen extends ConsumerWidget {
  const OwnerVenueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owner = ref.watch(currentOwnerProvider);
    if (owner == null) return const SizedBox.shrink();
    final venue = ref.watch(venueProvider(owner.uid)).value;
    final ratings = ref.watch(venueRatingsProvider(owner.uid)).value ?? [];
    final now = ref.watch(clockProvider)();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your venue'),
        actions: [
          IconButton(
            key: const Key('editVenueButton'),
            tooltip: 'Edit venue',
            onPressed: () => context.push(AppRoutes.ownerEditVenue),
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
      body: venue == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.screen),
              children: [
                VenueInfo(venue: venue),
                const SizedBox(height: AppSpacing.xl),
                Text('Ratings', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                if (venue.rating case final r?)
                  RatingBreakdown(rating: r)
                else
                  const Text(
                    'Players can rate your venue after a match booked here.',
                  ),
                for (final r in ratings) VenueRatingTile(rating: r, now: now),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
    );
  }
}
