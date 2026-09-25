import 'package:material_ui/material_ui.dart';

import '../../../domain/match_draft.dart';
import '../../../domain/match_validator.dart';
import 'step_props.dart';

class TitleStep extends StatelessWidget {
  const TitleStep({super.key, required this.draft, required this.onChanged});

  final MatchDraft draft;
  final DraftUpdate onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('matchTitleField'),
      initialValue: draft.title,
      autofocus: true,
      maxLength: MatchValidator.maxTitle,
      textCapitalization: TextCapitalization.sentences,
      onChanged: (v) => onChanged((d) => d.copyWith(title: v)),
      decoration: const InputDecoration(
        labelText: 'Match name',
        hintText: 'e.g. Saturday Night Football',
      ),
    );
  }
}
