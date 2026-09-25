import 'package:material_ui/material_ui.dart';

import '../../../../../shared/models/skill_level.dart';
import '../../../domain/match_draft.dart';
import 'step_props.dart';

class SkillStep extends StatelessWidget {
  const SkillStep({super.key, required this.draft, required this.onChanged});

  final MatchDraft draft;
  final DraftUpdate onChanged;

  static const _hints = {
    SkillLevel.beginner: 'Casual, learning the game',
    SkillLevel.intermediate: 'Plays regularly',
    SkillLevel.advanced: 'Competitive, club level',
    SkillLevel.any: 'All levels welcome',
  };

  @override
  Widget build(BuildContext context) {
    return RadioGroup<SkillLevel>(
      groupValue: draft.skillLevel,
      onChanged: (v) {
        if (v != null) onChanged((d) => d.copyWith(skillLevel: v));
      },
      child: Column(
        children: [
          for (final level in SkillLevel.values)
            RadioListTile<SkillLevel>(
              value: level,
              title: Text(level.label),
              subtitle: Text(_hints[level]!),
            ),
        ],
      ),
    );
  }
}
