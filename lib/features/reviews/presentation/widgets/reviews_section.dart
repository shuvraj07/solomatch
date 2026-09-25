import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/player_avatar.dart';
import '../../../../shared/widgets/rating_stars.dart';
import '../../data/review_providers.dart';

/// Rating summary and latest reviews on a profile.
class ReviewsSection extends ConsumerWidget {
  const ReviewsSection({
    super.key,
    required this.uid,
    required this.ratingAvg,
    required this.ratingCount,
  });

  final String uid;
  final double ratingAvg;
  final int ratingCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reviews = ref.watch(reviewsForPlayerProvider(uid)).value ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Reviews', style: theme.textTheme.titleMedium),
            const SizedBox(width: AppSpacing.sm),
            if (ratingCount > 0) ...[
              RatingStars(rating: ratingAvg),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${ratingAvg.toStringAsFixed(1)} ($ratingCount)',
                key: const Key('ratingSummary'),
              ),
            ],
          ],
        ),
        if (reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              'No reviews yet.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          )
        else
          for (final r in reviews.take(5))
            ListTile(
              key: Key('review_${r.id}'),
              contentPadding: EdgeInsets.zero,
              leading: PlayerAvatar(
                name: r.reviewerName,
                photoUrl: r.reviewerPhotoUrl,
                radius: 18,
              ),
              title: Row(
                children: [
                  Flexible(
                    child: Text(
                      r.reviewerName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  RatingStars(rating: r.rating.toDouble(), size: 14),
                ],
              ),
              subtitle: Text(
                [
                  if (r.comment.isNotEmpty) '"${r.comment}"',
                  [
                    r.matchTitle,
                    if (r.createdAt case final t?) Formatters.shortDate(t),
                  ].join(' · '),
                ].join('\n'),
              ),
            ),
      ],
    );
  }
}
