import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/session/session_provider.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/error_snackbar.dart';
import '../../../core/widgets/placeholder_view.dart';
import '../../../shared/widgets/match_card.dart';
import '../../../shared/widgets/player_avatar.dart';
import '../../matches/data/match_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final matches = ref.watch(upcomingMatchesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.lg,
                AppSpacing.screen,
                0,
              ),
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Find your next match ⚽',
                          style: theme.textTheme.headlineSmall,
                        ),
                      ),
                      if (profile != null)
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.profile),
                          child: PlayerAvatar(
                            name: profile.fullName,
                            photoUrl: profile.photoUrl,
                            radius: 20,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Search lives on Discover; this is a shortcut to it.
                  TextField(
                    readOnly: true,
                    onTap: () => context.go(AppRoutes.discover),
                    decoration: const InputDecoration(
                      hintText: 'Search matches or locations',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Upcoming matches', style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
            switch (matches) {
              AsyncData(value: final list) when list.isEmpty =>
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: PlaceholderView(
                    icon: Icons.sports_soccer_rounded,
                    title: 'No matches yet',
                    message: 'Be the first: tap + to post a match.',
                  ),
                ),
              AsyncData(value: final list) => SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  0,
                  AppSpacing.screen,
                  AppSpacing.xxl * 2,
                ),
                sliver: SliverList.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, i) => MatchCard(
                    match: list[i],
                    onTap: () =>
                        context.push(AppRoutes.matchDetails(list[i].id)),
                  ),
                ),
              ),
              AsyncError(:final error) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(errorMessage(error)),
                ),
              ),
              _ => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            },
          ],
        ),
      ),
    );
  }
}
