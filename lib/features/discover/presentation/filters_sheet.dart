import 'package:material_ui/material_ui.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/models/match_format.dart';
import '../../../shared/models/position_group.dart';
import '../../../shared/models/skill_level.dart';
import '../domain/match_filters.dart';

/// Bottom sheet for the less common filters. Pops the new [MatchFilters]
/// when the player taps "Show matches".
class FiltersSheet extends StatefulWidget {
  const FiltersSheet({super.key, required this.initial});

  final MatchFilters initial;

  @override
  State<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<FiltersSheet> {
  late var _f = widget.initial;

  void _set(MatchFilters next) => setState(() => _f = next);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Text(text, style: theme.textTheme.titleSmall),
    );

    Widget chips(List<Widget> children) => Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: children,
    );

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screen,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Filters', style: theme.textTheme.titleLarge),
                    heading('Format'),
                    chips([
                      for (final format in MatchFormat.values)
                        FilterChip(
                          key: Key('filterFormat_${format.name}'),
                          label: Text(format.label),
                          selected: _f.formats.contains(format),
                          onSelected: (on) => _set(
                            _f.copyWith(
                              formats: on
                                  ? {..._f.formats, format}
                                  : ({..._f.formats}..remove(format)),
                            ),
                          ),
                        ),
                    ]),
                    heading('Level'),
                    chips([
                      ChoiceChip(
                        key: const Key('filterSkill_any'),
                        label: const Text('Any'),
                        selected: _f.skill == null,
                        onSelected: (_) => _set(_f.copyWith(skill: () => null)),
                      ),
                      for (final level in SkillLevel.playerLevels)
                        ChoiceChip(
                          key: Key('filterSkill_${level.name}'),
                          label: Text(level.label),
                          selected: _f.skill == level,
                          onSelected: (_) =>
                              _set(_f.copyWith(skill: () => level)),
                        ),
                    ]),
                    heading('Needs a player for'),
                    chips([
                      ChoiceChip(
                        key: const Key('filterPosition_any'),
                        label: const Text('Any position'),
                        selected: _f.position == null,
                        onSelected: (_) =>
                            _set(_f.copyWith(position: () => null)),
                      ),
                      for (final g in PositionGroup.specific)
                        ChoiceChip(
                          key: Key('filterPosition_${g.name}'),
                          label: Text('${g.emoji} ${g.shortLabel}'),
                          selected: _f.position == g,
                          onSelected: (_) =>
                              _set(_f.copyWith(position: () => g)),
                        ),
                    ]),
                    heading('Venue'),
                    chips([
                      for (final (key, label, value) in [
                        ('any', 'Any', null),
                        ('indoor', 'Indoor', true),
                        ('outdoor', 'Outdoor', false),
                      ])
                        ChoiceChip(
                          key: Key('filterVenue_$key'),
                          label: Text(label),
                          selected: _f.indoor == value,
                          onSelected: (_) =>
                              _set(_f.copyWith(indoor: () => value)),
                        ),
                    ]),
                    const SizedBox(height: AppSpacing.sm),
                    SwitchListTile(
                      key: const Key('freeOnlySwitch'),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Free matches only'),
                      value: _f.freeOnly,
                      onChanged: (v) => _set(_f.copyWith(freeOnly: v)),
                    ),
                    SwitchListTile(
                      key: const Key('showFullSwitch'),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Show full matches'),
                      value: !_f.hideFull,
                      onChanged: (v) => _set(_f.copyWith(hideFull: !v)),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: Row(
                children: [
                  TextButton(
                    key: const Key('resetFiltersButton'),
                    onPressed: () => _set(_f.reset()),
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton(
                      key: const Key('applyFiltersButton'),
                      onPressed: () => Navigator.pop(context, _f),
                      child: const Text('Show matches'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
