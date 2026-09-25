import 'package:material_ui/material_ui.dart';

import '../../../domain/match_draft.dart';
import 'step_props.dart';

class DateStep extends StatelessWidget {
  const DateStep({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.today,
  });

  final MatchDraft draft;
  final DraftUpdate onChanged;
  final DateTime today;

  /// How far ahead matches can be scheduled.
  static const horizon = Duration(days: 90);

  @override
  Widget build(BuildContext context) {
    final first = DateTime(today.year, today.month, today.day);
    final selected = draft.date;
    return CalendarDatePicker(
      initialDate: selected != null && !selected.isBefore(first)
          ? selected
          : first,
      firstDate: first,
      lastDate: first.add(horizon),
      onDateChanged: (date) => onChanged((d) => d.copyWith(date: date)),
    );
  }
}
