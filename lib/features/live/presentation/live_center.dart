import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/run_with_feedback.dart';
import '../../match_requests/domain/roster_entry.dart';
import '../../matches/domain/football_match.dart';
import '../data/live_repository.dart';
import '../domain/live_models.dart';

/// Scoreboard, timeline and (for the organizer) live controls. Anyone can
/// watch and follow; the organizer posts goals and cards.
class LiveCenter extends ConsumerStatefulWidget {
  const LiveCenter({
    super.key,
    required this.match,
    required this.roster,
    required this.viewerUid,
    required this.upcomingSlot,
  });

  final FootballMatch match;
  final List<RosterEntry> roster;
  final String viewerUid;

  /// The match page shows the center twice: at the top once the match has
  /// kicked off ([upcomingSlot] false), and lower down as a compact
  /// "Team A vs Team B · Follow" row before kick-off (true). Each instance
  /// renders only in its own phase.
  final bool upcomingSlot;

  @override
  ConsumerState<LiveCenter> createState() => _LiveCenterState();
}

class _LiveCenterState extends ConsumerState<LiveCenter> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // Keeps the match minute and phase current.
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  FootballMatch get m => widget.match;

  Future<void> _post(LiveEventType type, TeamSide? side) async {
    final now = DateTime.now();
    final event = await showModalBottomSheet<LiveEvent>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _EventSheet(
        match: m,
        roster: widget.roster,
        type: type,
        side: side,
        minute: LiveMatch.minute(m, now),
      ),
    );
    if (event == null || !mounted) return;
    await runWithFeedback(
      context,
      () => ref
          .read(liveRepositoryProvider)
          .addEvent(m.id, event, by: widget.viewerUid),
    );
  }

  Future<void> _undo(LiveEvent last) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Undo last update?'),
        content: Text(
          '${last.type.emoji} ${last.minute}\' '
          '${last.playerName.isEmpty ? last.type.label : last.playerName}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            key: const Key('confirmUndoButton'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Undo'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await runWithFeedback(
      context,
      () => ref.read(liveRepositoryProvider).deleteEvent(m.id, last.id),
    );
  }

  Future<void> _follow(bool following) => runWithFeedback(
    context,
    () => ref
        .read(liveRepositoryProvider)
        .setFollowing(m.id, widget.viewerUid, on: !following),
    success: following ? null : 'You’ll get goal alerts for this match',
  );

  Future<void> _editTeams() async {
    final teams = await showDialog<MatchTeams>(
      context: context,
      builder: (_) => _TeamsDialog(teams: m.teams),
    );
    if (teams == null || !mounted) return;
    await runWithFeedback(
      context,
      () => ref.read(liveRepositoryProvider).setTeams(m.id, teams),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final phase = LiveMatch.phase(m, now);
    if (phase == LivePhase.cancelled) return const SizedBox.shrink();
    final isUpcoming = phase == LivePhase.upcoming;
    if (isUpcoming != widget.upcomingSlot) return const SizedBox.shrink();
    final events = ref.watch(liveEventsProvider(m.id)).value ?? const [];
    // A finished match without live updates has nothing to show.
    if (phase == LivePhase.fullTime && events.isEmpty) {
      return const SizedBox.shrink();
    }
    final score = LiveMatch.scoreOf(events);
    final isOrganizer = m.isOrganizer(widget.viewerUid);
    final canPost = LiveMatch.canPost(m, widget.viewerUid, now);
    final following =
        ref
            .watch(isFollowingProvider((matchId: m.id, uid: widget.viewerUid)))
            .value ??
        false;
    final theme = Theme.of(context);
    final started = phase != LivePhase.upcoming;

    final status = switch (phase) {
      LivePhase.live => Text(
        '● LIVE ${LiveMatch.minute(m, now)}\'',
        key: const Key('liveMinute'),
        style: theme.textTheme.labelLarge?.copyWith(
          color: AppColors.live,
          fontWeight: FontWeight.w900,
        ),
      ),
      LivePhase.fullTime => Text(
        'FULL TIME',
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
      _ => Text(
        'Kick-off ${Formatters.shortDate(m.startAt)}, '
        '${Formatters.time(m.startAt)}',
        style: theme.textTheme.labelLarge,
      ),
    };

    Widget team(String name) => Expanded(
      child: Text(
        name,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    if (isUpcoming) {
      return Card(
        key: const Key('liveCenter'),
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: ListTile(
          title: Text(
            '${m.teams.home}  vs  ${m.teams.away}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Text(
            m.followerCount > 0
                ? '👀 ${m.followerCount} following · live score at kick-off'
                : 'Live score at kick-off',
          ),
          trailing: isOrganizer
              ? IconButton(
                  key: const Key('editTeamsButton'),
                  tooltip: 'Team names',
                  onPressed: _editTeams,
                  icon: const Icon(Icons.edit_rounded),
                )
              : IconButton.filledTonal(
                  key: const Key('followMatchButton'),
                  tooltip: following ? 'Following' : 'Follow match',
                  onPressed: () => _follow(following),
                  icon: Icon(
                    following
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_none_rounded,
                  ),
                ),
        ),
      );
    }

    return Card(
      key: const Key('liveCenter'),
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: status),
                if (m.followerCount > 0)
                  Text(
                    '👀 ${m.followerCount} following',
                    style: theme.textTheme.labelMedium,
                  ),
                if (isOrganizer)
                  IconButton(
                    key: const Key('editTeamsButton'),
                    tooltip: 'Team names',
                    visualDensity: VisualDensity.compact,
                    onPressed: _editTeams,
                    icon: const Icon(Icons.edit_rounded, size: 18),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                team(m.teams.home),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Text(
                    started ? '${score.home} – ${score.away}' : 'vs',
                    key: const Key('liveScore'),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                team(m.teams.away),
              ],
            ),
            if (!isOrganizer && phase != LivePhase.fullTime) ...[
              const SizedBox(height: AppSpacing.md),
              Center(
                child: FilledButton.tonalIcon(
                  key: const Key('followMatchButton'),
                  onPressed: () => _follow(following),
                  icon: Icon(
                    following
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_none_rounded,
                  ),
                  label: Text(following ? 'Following' : 'Follow match'),
                ),
              ),
            ],
            if (canPost) ...[
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  for (final side in TeamSide.values) ...[
                    if (side == TeamSide.away)
                      const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FilledButton(
                        key: Key('goal_${side.name}'),
                        onPressed: () => _post(LiveEventType.goal, side),
                        child: Text(
                          '⚽ ${side.nameIn(m.teams)}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('yellowCardButton'),
                      onPressed: () => _post(LiveEventType.yellow, null),
                      child: const Text('🟨 Yellow'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('redCardButton'),
                      onPressed: () => _post(LiveEventType.red, null),
                      child: const Text('🟥 Red'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton.outlined(
                    key: const Key('undoEventButton'),
                    tooltip: 'Undo last',
                    onPressed: events.isEmpty ? null : () => _undo(events.last),
                    icon: const Icon(Icons.undo_rounded),
                  ),
                ],
              ),
            ],
            if (events.isNotEmpty) ...[
              const Divider(height: AppSpacing.xl),
              for (final e in events.reversed)
                _EventRow(event: e, teams: m.teams),
            ] else if (started && !canPost)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Text(
                  'No goals yet. The organizer posts live updates here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.teams});

  final LiveEvent event;
  final MatchTeams teams;

  @override
  Widget build(BuildContext context) {
    final home = event.side == TeamSide.home;
    final who = event.playerName.isEmpty ? event.type.label : event.playerName;
    final text = Text(
      '${event.type.emoji} $who',
      overflow: TextOverflow.ellipsis,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: home ? text : const SizedBox.shrink()),
          SizedBox(
            width: 44,
            child: Text(
              "${event.minute}'",
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: home
                ? const SizedBox.shrink()
                : Align(alignment: Alignment.centerRight, child: text),
          ),
        ],
      ),
    );
  }
}

/// Pick the team (for cards), the player and the minute.
class _EventSheet extends StatefulWidget {
  const _EventSheet({
    required this.match,
    required this.roster,
    required this.type,
    required this.side,
    required this.minute,
  });

  final FootballMatch match;
  final List<RosterEntry> roster;
  final LiveEventType type;
  final TeamSide? side;
  final int minute;

  @override
  State<_EventSheet> createState() => _EventSheetState();
}

class _EventSheetState extends State<_EventSheet> {
  late var _side = widget.side ?? TeamSide.home;
  late var _minute = widget.minute;
  String? _playerUid;
  var _playerName = '';

  void _save() => Navigator.pop(
    context,
    LiveEvent(
      type: widget.type,
      side: _side,
      playerUid: _playerUid,
      playerName: _playerName,
      minute: _minute,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final teams = widget.match.teams;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen,
        0,
        AppSpacing.screen,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${widget.type.emoji} ${widget.type.label}',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            if (widget.side == null) ...[
              SegmentedButton<TeamSide>(
                segments: [
                  for (final s in TeamSide.values)
                    ButtonSegment(
                      value: s,
                      label: Text(
                        s.nameIn(teams),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                selected: {_side},
                onSelectionChanged: (s) => setState(() => _side = s.first),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            Row(
              children: [
                const Text('Minute'),
                const Spacer(),
                IconButton(
                  onPressed: _minute > 0
                      ? () => setState(() => _minute--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  "$_minute'",
                  key: const Key('eventMinute'),
                  style: theme.textTheme.titleMedium,
                ),
                IconButton(
                  onPressed: _minute < 200
                      ? () => setState(() => _minute++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            Text(
              widget.type == LiveEventType.goal ? 'Scorer' : 'Player',
              style: theme.textTheme.titleSmall,
            ),
            Flexible(
              child: RadioGroup<String>(
                groupValue: _playerUid ?? '',
                onChanged: (v) => setState(() {
                  _playerUid = v == null || v.isEmpty ? null : v;
                  _playerName =
                      widget.roster
                          .where((r) => r.player.uid == v)
                          .firstOrNull
                          ?.player
                          .name ??
                      '';
                }),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final r in widget.roster)
                      RadioListTile<String>(
                        key: Key('eventPlayer_${r.player.uid}'),
                        value: r.player.uid,
                        title: Text(r.player.name),
                      ),
                    const RadioListTile<String>(
                      key: Key('eventPlayer_none'),
                      value: '',
                      title: Text('Guest / not sure'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              key: const Key('saveEventButton'),
              onPressed: _save,
              child: Text('Post ${widget.type.label.toLowerCase()}'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamsDialog extends StatefulWidget {
  const _TeamsDialog({required this.teams});

  final MatchTeams teams;

  @override
  State<_TeamsDialog> createState() => _TeamsDialogState();
}

class _TeamsDialogState extends State<_TeamsDialog> {
  final _form = GlobalKey<FormState>();
  late var _home = widget.teams.home;
  late var _away = widget.teams.away;

  String? _valid(String? v) {
    final t = (v ?? '').trim();
    return t.isEmpty || t.length > 30 ? 'Use 1–30 characters' : null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Team names'),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              key: const Key('homeTeamField'),
              initialValue: _home,
              validator: _valid,
              onChanged: (v) => _home = v,
              decoration: const InputDecoration(labelText: 'Team 1'),
            ),
            TextFormField(
              key: const Key('awayTeamField'),
              initialValue: _away,
              validator: _valid,
              onChanged: (v) => _away = v,
              decoration: const InputDecoration(labelText: 'Team 2'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('saveTeamsButton'),
          onPressed: () {
            if (_form.currentState!.validate()) {
              Navigator.pop(context, (home: _home.trim(), away: _away.trim()));
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
