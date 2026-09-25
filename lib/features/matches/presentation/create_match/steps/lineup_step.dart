import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../app/session/session_provider.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/widgets/count_stepper.dart';
import '../../../../../shared/models/position_group.dart';
import '../../../../../shared/widgets/player_avatar.dart';
import '../../../../profile/data/profile_providers.dart';
import '../../../../profile/domain/player_profile.dart';
import '../../../domain/lineup_player.dart';
import '../../../domain/match_draft.dart';
import 'step_props.dart';

/// "Your players": who is already confirmed before posting, so the match
/// only advertises the spots that are really left.
class LineupStep extends ConsumerStatefulWidget {
  const LineupStep({super.key, required this.draft, required this.onChanged});

  final MatchDraft draft;
  final DraftUpdate onChanged;

  @override
  ConsumerState<LineupStep> createState() => _LineupStepState();
}

class _LineupStepState extends ConsumerState<LineupStep> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => setState(() => _query = value.trim()),
    );
  }

  void _add(PlayerProfile p) {
    widget.onChanged(
      (d) => d.copyWith(
        lineup: [
          ...d.lineup,
          LineupPlayer(
            uid: p.uid,
            name: p.fullName,
            username: p.username,
            photoUrl: p.photoUrl,
            primaryPosition: p.primaryPosition,
            group: p.primaryPosition.group,
          ),
        ],
      ),
    );
    _search.clear();
    setState(() => _query = '');
  }

  void _remove(String uid) => widget.onChanged(
    (d) => d.copyWith(
      lineup: [
        for (final l in d.lineup)
          if (l.uid != uid) l,
      ],
    ),
  );

  void _setGroup(String uid, PositionGroup group) => widget.onChanged(
    (d) => d.copyWith(
      lineup: [
        for (final l in d.lineup) l.uid == uid ? l.copyWith(group: group) : l,
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final draft = widget.draft;
    final me = ref.watch(currentProfileProvider);
    final taken = {me?.uid, for (final l in draft.lineup) l.uid};
    final results = _query.length < 2
        ? const AsyncData(<PlayerProfile>[])
        : ref.watch(playerSearchProvider(_query));
    final open = draft.openSpots;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          key: const Key('lineupSummary'),
          color: open < 0
              ? theme.colorScheme.errorContainer
              : theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              '${draft.maxPlayers} players · ${draft.confirmedCount} already '
              'confirmed · ${open < 0 ? '${-open} too many' : '$open still needed'}',
              style: theme.textTheme.titleMedium,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Already have players? Add them here so only the open spots are '
          'advertised. Friends you add get a notification and can leave if '
          "they can't make it.",
          style: theme.textTheme.bodySmall,
        ),
        SwitchListTile(
          key: const Key('organizerPlayingSwitch'),
          contentPadding: EdgeInsets.zero,
          title: const Text("I'm playing too"),
          value: draft.organizerPlaying,
          onChanged: (v) => widget.onChanged(
            (d) => d.copyWith(
              organizerPlaying: v,
              organizerGroup: d.organizerGroup ?? me?.primaryPosition.group,
            ),
          ),
        ),
        if (draft.organizerPlaying)
          _GroupChips(
            selected: draft.organizerGroup ?? me?.primaryPosition.group,
            onSelected: (g) =>
                widget.onChanged((d) => d.copyWith(organizerGroup: g)),
          ),
        const SizedBox(height: AppSpacing.lg),
        Text('Friends on SoloMatch', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          key: const Key('playerSearchField'),
          controller: _search,
          onChanged: _onSearch,
          autocorrect: false,
          decoration: const InputDecoration(
            hintText: 'Search name or @username',
            prefixIcon: Icon(Icons.person_search_rounded),
          ),
        ),
        ...switch (results) {
          AsyncData(value: final list) => [
            for (final p in list)
              if (!taken.contains(p.uid))
                ListTile(
                  key: Key('searchResult_${p.uid}'),
                  contentPadding: EdgeInsets.zero,
                  leading: PlayerAvatar(name: p.fullName, photoUrl: p.photoUrl),
                  title: Text(p.fullName),
                  subtitle: Text(
                    '@${p.username} · ${p.primaryPosition.shortLabel}',
                  ),
                  trailing: const Icon(Icons.add_circle_outline_rounded),
                  onTap: () => _add(p),
                ),
          ],
          AsyncLoading() => const [LinearProgressIndicator()],
          _ => const <Widget>[],
        },
        for (final l in draft.lineup)
          Card(
            key: Key('lineup_${l.uid}'),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PlayerAvatar(
                        name: l.name,
                        photoUrl: l.photoUrl,
                        radius: 18,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          '${l.name}\n@${l.username} · ${l.primaryPosition.shortLabel}',
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove ${l.name}',
                        onPressed: () => _remove(l.uid),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  _GroupChips(
                    selected: l.group,
                    onSelected: (g) => _setGroup(l.uid, g),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: Text(
                'Friends not on SoloMatch',
                style: theme.textTheme.titleMedium,
              ),
            ),
            CountStepper(
              key: const Key('guestStepper'),
              value: draft.guestCount,
              max: draft.maxPlayers,
              label: 'guests',
              onChanged: (n) =>
                  widget.onChanged((d) => d.copyWith(guestCount: n)),
            ),
          ],
        ),
      ],
    );
  }
}

class _GroupChips extends StatelessWidget {
  const _GroupChips({required this.selected, required this.onSelected});

  final PositionGroup? selected;
  final ValueChanged<PositionGroup> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      children: [
        for (final g in PositionGroup.values)
          ChoiceChip(
            label: Text('${g.emoji} ${g.shortLabel}'),
            selected: selected == g,
            onSelected: (_) => onSelected(g),
          ),
      ],
    );
  }
}
