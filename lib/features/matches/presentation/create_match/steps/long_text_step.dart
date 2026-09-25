import 'package:material_ui/material_ui.dart';

import '../../../domain/match_validator.dart';

/// Optional multi-line text (description, rules).
class LongTextStep extends StatelessWidget {
  const LongTextStep({
    super.key,
    required this.initialValue,
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  final String initialValue;
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      minLines: 5,
      maxLines: 10,
      maxLength: MatchValidator.maxText,
      textCapitalization: TextCapitalization.sentences,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: '$label (optional)',
        hintText: hint,
        alignLabelWithHint: true,
      ),
    );
  }
}
