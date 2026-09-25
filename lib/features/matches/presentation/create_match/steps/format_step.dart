import 'package:material_ui/material_ui.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../shared/models/match_format.dart';
import '../../../domain/match_draft.dart';
import 'step_props.dart';

class FormatStep extends StatelessWidget {
  const FormatStep({super.key, required this.draft, required this.onChanged});

  final MatchDraft draft;
  final DraftUpdate onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.4,
      children: [
        for (final format in MatchFormat.values)
          _FormatTile(
            format: format,
            selected: draft.format == format,
            // Picking a format also suggests the standard roster size.
            onTap: () => onChanged(
              (d) => d.copyWith(
                format: format,
                maxPlayers: format.defaultMaxPlayers,
              ),
            ),
            textTheme: theme.textTheme,
          ),
      ],
    );
  }
}

class _FormatTile extends StatelessWidget {
  const _FormatTile({
    required this.format,
    required this.selected,
    required this.onTap,
    required this.textTheme,
  });

  final MatchFormat format;
  final bool selected;
  final VoidCallback onTap;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: selected ? scheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(format.label, style: textTheme.headlineSmall),
                Text(
                  '${format.defaultMaxPlayers} players',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
