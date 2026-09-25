import 'package:material_ui/material_ui.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/models/position_group.dart';
import '../../matches/domain/football_match.dart';

/// What the player sends with a join request.
typedef JoinRequestInput = ({PositionGroup group, String message});

/// Bottom sheet: pick the position you want to play and add a note.
/// Groups that still need players are highlighted, but any can be chosen:
/// the organizer decides.
Future<JoinRequestInput?> showRequestToJoinSheet(
  BuildContext context, {
  required FootballMatch match,
  required PositionGroup suggested,
}) => showModalBottomSheet<JoinRequestInput>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _RequestSheet(match: match, suggested: suggested),
);

class _RequestSheet extends StatefulWidget {
  const _RequestSheet({required this.match, required this.suggested});

  final FootballMatch match;
  final PositionGroup suggested;

  @override
  State<_RequestSheet> createState() => _RequestSheetState();
}

class _RequestSheetState extends State<_RequestSheet> {
  late PositionGroup _group = widget.suggested;
  final _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final open = widget.match.slots.openByGroup;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Request to join', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(widget.match.title, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xl),
          Text('I want to play', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final g in PositionGroup.values)
                ChoiceChip(
                  label: Text(
                    open[g] == null
                        ? '${g.emoji} ${g.shortLabel}'
                        : '${g.emoji} ${g.shortLabel} · ${open[g]} open',
                  ),
                  selected: _group == g,
                  onSelected: (_) => setState(() => _group = g),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            key: const Key('requestMessageField'),
            controller: _message,
            maxLength: 200,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Message to organizer (optional)',
              hintText: 'Can also play in goal if needed',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            key: const Key('sendRequestButton'),
            onPressed: () =>
                Navigator.pop(context, (group: _group, message: _message.text)),
            child: const Text('Send request'),
          ),
        ],
      ),
    );
  }
}
