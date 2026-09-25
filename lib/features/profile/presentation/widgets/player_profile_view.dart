import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/player_avatar.dart';
import '../../../../shared/widgets/position_badge.dart';
import '../../../reviews/presentation/widgets/reviews_section.dart';
import '../../domain/player_profile.dart';

/// Public football profile: identity, positions and career stats.
/// Used for your own Profile tab and for other players' profiles.
/// Never shows private fields (date of birth, email).
class PlayerProfileView extends StatelessWidget {
  const PlayerProfileView({
    super.key,
    required this.profile,
    this.actions = const [],
    this.isMe = false,
  });

  final PlayerProfile profile;

  /// Extra buttons under the header (e.g. "My matches" on your own).
  final List<Widget> actions;

  /// Viewing your own profile (privacy settings don't hide anything).
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final stats = profile.stats;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        Center(
          child: PlayerAvatar(
            name: profile.fullName,
            photoUrl: profile.photoUrl,
            radius: 48,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          profile.fullName,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        Text(
          profile.hideCity && !isMe
              ? '@${profile.username}'
              : '@${profile.username} · ${profile.city}',
          textAlign: TextAlign.center,
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            PositionBadge(
              group: profile.primaryPosition.group,
              label: profile.primaryPosition.shortLabel,
              showEmoji: true,
            ),
            for (final p in profile.secondaryPositions)
              PositionBadge(group: p.group, label: p.shortLabel),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  children: [
                    _Stat(value: '${stats.gamesPlayed}', label: 'Matches'),
                    _Stat(
                      value: stats.hasRating
                          ? '⭐ ${stats.ratingAvg.toStringAsFixed(1)}'
                          : '—',
                      label: 'Rating',
                    ),
                    _Stat(value: profile.skillLevel.label, label: 'Level'),
                  ],
                ),
                const Divider(height: AppSpacing.xl),
                Row(
                  children: [
                    _Stat(value: '⚽ ${stats.goals}', label: 'Goals'),
                    _Stat(value: '🅰️ ${stats.assists}', label: 'Assists'),
                    _Stat(
                      key: const Key('motmStat'),
                      value: '🏆 ${stats.motmAwards}',
                      label: 'MOTM',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _Stat(value: '🟨 ${stats.yellowCards}', label: 'Yellow'),
                    _Stat(value: '🟥 ${stats.redCards}', label: 'Red'),
                    _Stat(value: '${stats.gamesOrganized}', label: 'Organized'),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          ...actions,
        ],
        const SizedBox(height: AppSpacing.lg),
        Text('Football profile', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          [
            '${profile.preferredFoot.label} foot',
            '${profile.yearsPlaying} years playing',
            if (profile.heightCm case final h?) '$h cm',
            if (profile.languages.isNotEmpty) profile.languages.join(', '),
          ].join(' · '),
          key: const Key('profileDetails'),
          style: TextStyle(color: muted),
        ),
        if (profile.bio.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(profile.bio, style: theme.textTheme.bodyLarge),
        ],
        const SizedBox(height: AppSpacing.xl),
        ReviewsSection(
          uid: profile.uid,
          ratingAvg: stats.ratingAvg,
          ratingCount: stats.ratingCount,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Equal share of the row; long values ("Intermediate") shrink to fit.
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: theme.textTheme.titleLarge),
          ),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}
