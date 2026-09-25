import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/session/session_provider.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/error_snackbar.dart';
import '../../../core/widgets/placeholder_view.dart';
import '../../../shared/models/price.dart';
import '../data/venue_providers.dart';
import '../domain/venue_models.dart';
import 'widgets/venue_widgets.dart';

/// Venues listed on SoloMatch. In [pick] mode (from the create-match flow)
/// choosing a slot pops it back as `(VenueProfile, VenueSlot)`.
class VenuesScreen extends ConsumerStatefulWidget {
  const VenuesScreen({super.key, this.pick = false});

  final bool pick;

  @override
  ConsumerState<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends ConsumerState<VenuesScreen> {
  var _query = '';

  Future<void> _open(VenueProfile v) async {
    final picked = await context.push<(VenueProfile, VenueSlot)>(
      AppRoutes.venueDetails(v.id, pick: widget.pick),
    );
    if (picked != null && mounted) context.pop(picked);
  }

  @override
  Widget build(BuildContext context) {
    final venues = ref.watch(venuesProvider);
    final city = ref.watch(currentProfileProvider)?.city.trim().toLowerCase();
    final q = _query.trim().toLowerCase();

    List<VenueProfile> visible(List<VenueProfile> all) {
      final list = [
        for (final v in all)
          if (q.isEmpty ||
              '${v.name} ${v.address} ${v.city}'.toLowerCase().contains(q))
            v,
      ];
      // Venues in the player's city first, then best rated.
      list.sort((a, b) {
        final ac = a.city.trim().toLowerCase() == city ? 0 : 1;
        final bc = b.city.trim().toLowerCase() == city ? 0 : 1;
        if (ac != bc) return ac - bc;
        return (b.rating?.overall ?? 0).compareTo(a.rating?.overall ?? 0);
      });
      return list;
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.pick ? 'Book a venue' : 'Venues')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              0,
              AppSpacing.screen,
              AppSpacing.sm,
            ),
            child: TextField(
              key: const Key('venueSearchField'),
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search venues or areas',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: switch (venues) {
              AsyncData(:final value) when visible(value).isEmpty =>
                const PlaceholderView(
                  icon: Icons.stadium_outlined,
                  title: 'No venues yet',
                  message:
                      'Venue owners can list their futsal from the sign-in '
                      'screen: choose “Venue owner”.',
                ),
              AsyncData(:final value) => ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.sm,
                  AppSpacing.screen,
                  AppSpacing.xxl,
                ),
                itemCount: visible(value).length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final v = visible(value)[i];
                  final rating = v.rating;
                  return Card(
                    child: ListTile(
                      key: Key('venue_${v.id}'),
                      onTap: () => _open(v),
                      leading: const CircleAvatar(child: Text('🏟️')),
                      title: Text(v.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${v.shortLabel} · '
                            '${Price(amount: v.pricePerHour).display}/hr · '
                            '${v.isIndoor ? 'Indoor' : 'Outdoor'}',
                          ),
                          if (rating != null)
                            StarsLabel(
                              value: rating.overall,
                              count: rating.count,
                              size: 14,
                            ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    ),
                  );
                },
              ),
              AsyncError(:final error) => Center(
                child: Text(errorMessage(error)),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }
}
