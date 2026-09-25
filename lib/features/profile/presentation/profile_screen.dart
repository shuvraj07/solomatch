import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/session/session_provider.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/player_avatar.dart';
import '../../../shared/widgets/position_badge.dart';
import '../../auth/data/auth_providers.dart';
import '../domain/player_profile.dart';

/// The signed-in player's own profile. Full editing, reviews and settings
/// arrive in later phases.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            key: const Key('signOutButton'),
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : _ProfileBody(profile: profile),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.profile});

  final PlayerProfile profile;

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
          '@${profile.username} · ${profile.city}',
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
            child: Row(
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
          ),
        ),
        if (profile.bio.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(profile.bio, style: theme.textTheme.bodyLarge),
        ],
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

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
