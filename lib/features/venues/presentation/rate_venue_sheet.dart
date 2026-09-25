import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/session/session_provider.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/run_with_feedback.dart';
import '../../matches/domain/football_match.dart';
import '../data/venue_providers.dart';
import '../domain/venue_models.dart';
import 'widgets/venue_widgets.dart';

/// Rate the venue a match was played at: overall, pitch, facilities and
/// value (1–5 stars each) plus an optional comment.
Future<void> showRateVenueSheet(BuildContext context, FootballMatch match) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _RateVenueSheet(match: match),
    );

class _RateVenueSheet extends ConsumerStatefulWidget {
  const _RateVenueSheet({required this.match});

  final FootballMatch match;

  @override
  ConsumerState<_RateVenueSheet> createState() => _RateVenueSheetState();
}

class _RateVenueSheetState extends ConsumerState<_RateVenueSheet> {
  final _scores = {for (final p in RatingPart.values) p: 0};
  final _comment = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  bool get _complete => _scores.values.every((s) => s > 0);

  Future<void> _submit() async {
    final me = ref.read(currentProfileProvider);
    final venueId = widget.match.venue.venueId;
    if (me == null || venueId == null || !_complete) return;
    setState(() => _busy = true);
    final ok = await runWithFeedback(
      context,
      () => ref
          .read(venueRepositoryProvider)
          .rateVenue(
            VenueRating(
              venueId: venueId,
              matchId: widget.match.id,
              matchTitle: widget.match.title,
              reviewerId: me.uid,
              reviewerName: me.fullName,
              reviewerPhotoUrl: me.photoUrl,
              overall: _scores[RatingPart.overall]!,
              pitch: _scores[RatingPart.pitch]!,
              facilities: _scores[RatingPart.facilities]!,
              value: _scores[RatingPart.value]!,
              comment: _comment.text,
            ),
          ),
      success: 'Thanks for rating ${widget.match.venue.name}!',
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen,
        0,
        AppSpacing.screen,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Rate ${widget.match.venue.name}',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            for (final p in RatingPart.values)
              Row(
                children: [
                  Expanded(child: Text(p.label)),
                  StarInput(
                    keyPrefix: 'venueStar_${p.name}',
                    value: _scores[p]!,
                    onChanged: (v) => setState(() => _scores[p] = v),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              key: const Key('venueRatingComment'),
              controller: _comment,
              maxLength: 300,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Comment (optional)',
                hintText: 'Turf, changing rooms, lights…',
              ),
            ),
            FilledButton(
              key: const Key('submitVenueRatingButton'),
              onPressed: _complete && !_busy ? _submit : null,
              child: const Text('Submit rating'),
            ),
          ],
        ),
      ),
    );
  }
}
