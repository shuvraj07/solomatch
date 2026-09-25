import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/price.dart';
import '../../domain/venue_models.dart';

/// Horizontal picker for the next [days] days. Keys: `day_0` = today.
class DayStrip extends StatelessWidget {
  const DayStrip({
    super.key,
    required this.today,
    required this.selected,
    required this.onSelected,
    this.days = 14,
  });

  final DateTime today;
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;
  final int days;

  @override
  Widget build(BuildContext context) {
    final start = DateTime(today.year, today.month, today.day);
    final theme = Theme.of(context);
    return SizedBox(
      height: 64,
      child: ListView.separated(
        key: const Key('dayStrip'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
        itemCount: days,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final day = start.add(Duration(days: i));
          final isSelected = DateUtils.isSameDay(day, selected);
          final fg = isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface;
          return InkWell(
            key: Key('day_$i'),
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: () => onSelected(day),
            child: Container(
              width: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    i == 0 ? 'Today' : DateFormat('EEE').format(day),
                    style: theme.textTheme.labelSmall?.copyWith(color: fg),
                  ),
                  Text(
                    '${day.day}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Read-only stars, e.g. "★★★★☆ 4.2".
class StarsLabel extends StatelessWidget {
  const StarsLabel({
    super.key,
    required this.value,
    this.count,
    this.size = 16,
  });

  final double value;
  final int? count;
  final double size;

  @override
  Widget build(BuildContext context) {
    final count = this.count;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            value >= i - 0.25
                ? Icons.star_rounded
                : value >= i - 0.75
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded,
            size: size,
            color: AppColors.goalkeeper,
          ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          value.toStringAsFixed(1) + (count == null ? '' : ' ($count)'),
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }
}

/// Tappable 1–5 stars. Keys: `<keyPrefix>_1` … `<keyPrefix>_5`.
class StarInput extends StatelessWidget {
  const StarInput({
    super.key,
    required this.value,
    required this.onChanged,
    required this.keyPrefix,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            key: Key('${keyPrefix}_$i'),
            visualDensity: VisualDensity.compact,
            onPressed: () => onChanged(i),
            icon: Icon(
              i <= value ? Icons.star_rounded : Icons.star_outline_rounded,
              color: AppColors.goalkeeper,
              size: 30,
            ),
          ),
      ],
    );
  }
}

/// Name, place, facilities and contact of a venue.
class VenueInfo extends StatelessWidget {
  const VenueInfo({super.key, required this.venue});

  final VenueProfile venue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final rating = venue.rating;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (venue.photos.isNotEmpty) ...[
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: venue.photos.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (_, i) => ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.network(
                  venue.photos[i],
                  width: 240,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Text('🏟️ ${venue.name}', style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Text('📍 ${venue.shortLabel}', style: TextStyle(color: muted)),
        const SizedBox(height: AppSpacing.xs),
        if (rating != null)
          StarsLabel(value: rating.overall, count: rating.count)
        else
          Text('No ratings yet', style: TextStyle(color: muted)),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            Chip(label: Text(venue.isIndoor ? '🏠 Indoor' : '🌤️ Outdoor')),
            for (final f in venue.formats) Chip(label: Text(f.label)),
            Chip(
              label: Text(
                '${Price(amount: venue.pricePerHour).display} / hour',
              ),
            ),
          ],
        ),
        if (venue.amenities.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              for (final a in Amenity.values)
                if (venue.amenities.contains(a))
                  Text('${a.emoji} ${a.label}', style: TextStyle(color: muted)),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Text('📞 ${venue.phone}', style: theme.textTheme.bodyLarge),
        if (venue.description.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(venue.description),
        ],
      ],
    );
  }
}

/// Average per rating part with bars.
class RatingBreakdown extends StatelessWidget {
  const RatingBreakdown({super.key, required this.rating});

  final VenueRatingSummary rating;

  @override
  Widget build(BuildContext context) {
    double valueOf(RatingPart p) => switch (p) {
      RatingPart.overall => rating.overall,
      RatingPart.pitch => rating.pitch,
      RatingPart.facilities => rating.facilities,
      RatingPart.value => rating.value,
    };
    return Column(
      children: [
        for (final p in RatingPart.values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                SizedBox(width: 120, child: Text(p.label)),
                Expanded(
                  child: LinearProgressIndicator(
                    value: valueOf(p) / 5,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(valueOf(p).toStringAsFixed(1)),
              ],
            ),
          ),
      ],
    );
  }
}

/// One player's rating in a list.
class VenueRatingTile extends StatelessWidget {
  const VenueRatingTile({super.key, required this.rating, required this.now});

  final VenueRating rating;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final created = rating.createdAt;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Flexible(
            child: Text(rating.reviewerName, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: AppSpacing.sm),
          StarsLabel(value: rating.overall.toDouble(), size: 14),
        ],
      ),
      subtitle: Text(
        [
          if (rating.comment.isNotEmpty) '“${rating.comment}”',
          'Pitch ${rating.pitch} · Facilities ${rating.facilities} · '
              'Value ${rating.value}'
              '${created == null ? '' : ' · ${Formatters.relative(created, now)}'}',
        ].join('\n'),
      ),
    );
  }
}

/// A slot row: time, price and status.
class SlotTile extends StatelessWidget {
  const SlotTile({
    super.key,
    required this.slot,
    this.onTap,
    this.trailing,
    this.subtitle,
  });

  final VenueSlot slot;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = slot.isFree ? AppColors.statusOpen : AppColors.statusFull;
    return Card(
      child: ListTile(
        key: Key('slot_${slot.id}'),
        onTap: onTap,
        leading: Icon(
          slot.isFree
              ? Icons.event_available_rounded
              : Icons.event_busy_rounded,
          color: color,
        ),
        title: Text(
          Formatters.timeRange(slot.startAt, slot.endAt),
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          subtitle ??
              '${Price(amount: slot.price).display} · '
                  '${slot.isFree ? 'Free' : 'Booked'}',
        ),
        trailing: trailing,
      ),
    );
  }
}
