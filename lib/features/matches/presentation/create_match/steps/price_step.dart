import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../domain/match_draft.dart';
import 'step_props.dart';

class PriceStep extends StatefulWidget {
  const PriceStep({super.key, required this.draft, required this.onChanged});

  final MatchDraft draft;
  final DraftUpdate onChanged;

  @override
  State<PriceStep> createState() => _PriceStepState();
}

class _PriceStepState extends State<PriceStep> {
  late bool _paid = widget.draft.priceAmount > 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: false, label: Text('Free')),
            ButtonSegment(value: true, label: Text('Paid')),
          ],
          selected: {_paid},
          onSelectionChanged: (v) {
            setState(() => _paid = v.first);
            if (!_paid) widget.onChanged((d) => d.copyWith(priceAmount: 0));
          },
        ),
        if (_paid) ...[
          const SizedBox(height: AppSpacing.xl),
          TextFormField(
            key: const Key('priceField'),
            initialValue: widget.draft.priceAmount == 0
                ? ''
                : '${widget.draft.priceAmount}',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            onChanged: (v) => widget.onChanged(
              (d) => d.copyWith(priceAmount: int.tryParse(v) ?? 0),
            ),
            decoration: const InputDecoration(
              labelText: 'Price per player',
              prefixText: '${AppConstants.defaultCurrency} ',
              helperText:
                  'Collected by you at the venue. SoloMatch does '
                  'not handle payments.',
            ),
          ),
        ],
      ],
    );
  }
}
