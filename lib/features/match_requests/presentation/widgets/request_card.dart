import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/models/fitness.dart';
import '../../../../shared/widgets/player_avatar.dart';
import '../../../../shared/widgets/position_badge.dart';
import '../../domain/join_request.dart';

/// One pending request with the player's football profile and
/// Accept / Reject buttons.
class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.request,
    required this.busy,
    required this.onAccept,
    required this.onReject,
    this.onMessage,
    this.fitness = Fitness.fit,
  });

  final JoinRequest request;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback? onMessage;

  /// The player's current fitness (from their live profile).
  final Fitness fitness;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = request.player;
    final muted = theme.colorScheme.onSurfaceVariant;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              key: Key('requestProfile_${p.uid}'),
              onTap: () => context.push(AppRoutes.playerProfile(p.uid)),
              child: Row(
                children: [
                  PlayerAvatar(name: p.name, photoUrl: p.photoUrl),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: theme.textTheme.titleMedium),
                        Text(
                          '@${p.username} · ${p.skillLevel.label}',
                          style: TextStyle(color: muted),
                        ),
                      ],
                    ),
                  ),
                  if (onMessage != null)
                    IconButton(
                      key: Key('messageRequester_${p.uid}'),
                      tooltip: 'Message ${p.name}',
                      onPressed: onMessage,
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                    ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                PositionBadge(
                  group: p.primaryPosition.group,
                  label: p.primaryPosition.shortLabel,
                  showEmoji: true,
                ),
                for (final s in p.secondaryPositions)
                  PositionBadge(group: s.group, label: s.shortLabel),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '⚽ ${p.gamesPlayed} matches · '
              '${p.ratingCount > 0 ? '⭐ ${p.ratingAvg.toStringAsFixed(1)}' : 'No rating yet'}'
              ' · wants ${request.preferredGroup.emoji} '
              '${request.preferredGroup.shortLabel}',
              style: TextStyle(color: muted),
            ),
            if (request.message.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('"${request.message}"', style: theme.textTheme.bodyMedium),
            ],
            if (fitness != Fitness.fit)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  fitness.canPlay
                      ? '${fitness.emoji} ${fitness.label}: check before accepting'
                      : '${fitness.emoji} Injured: can’t be selected right now',
                  key: Key('fitness_${p.uid}'),
                  style: TextStyle(
                    color: fitness.canPlay
                        ? AppColors.statusFilling
                        : theme.colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: Key('reject_${p.uid}'),
                    onPressed: busy ? null : onReject,
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton.icon(
                    key: Key('accept_${p.uid}'),
                    onPressed: busy || !fitness.canPlay ? null : onAccept,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
