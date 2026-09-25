import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/providers/clock_provider.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../data/venue_providers.dart';
import '../../domain/slot_planner.dart';

/// Lists many slots at once: opening hours split into equal slots,
/// optionally repeated over the next days. Pops the number added.
class AddSlotsSheet extends ConsumerStatefulWidget {
  const AddSlotsSheet({
    super.key,
    required this.venueId,
    required this.firstDay,
    required this.defaultPrice,
  });

  final String venueId;
  final DateTime firstDay;
  final int defaultPrice;

  @override
  ConsumerState<AddSlotsSheet> createState() => _AddSlotsSheetState();
}

const _lengths = [60, 90, 120];
const _repeat = {1: 'Just this day', 7: '7 days', 14: '14 days', 28: '4 weeks'};
const _weekdayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

class _AddSlotsSheetState extends ConsumerState<AddSlotsSheet> {
  var _from = 6 * 60;
  var _to = 22 * 60;
  var _length = 60;
  var _days = 1;
  var _weekdays = {1, 2, 3, 4, 5, 6, 7};
  late final _price = TextEditingController(
    text: widget.defaultPrice == 0 ? '' : '${widget.defaultPrice}',
  );
  var _busy = false;

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool from}) async {
    final minutes = from ? _from : _to;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: (minutes ~/ 60) % 24, minute: minutes % 60),
    );
    if (picked == null) return;
    var m = picked.hour * 60 + picked.minute;
    // Closing at 00:00 means midnight at the end of the day.
    if (!from && m == 0) m = 24 * 60;
    setState(() => from ? _from = m : _to = m);
  }

  Future<void> _save() async {
    final price = int.tryParse(_price.text.trim()) ?? 0;
    final repo = ref.read(venueRepositoryProvider);
    final now = ref.read(clockProvider)();
    final first = DateTime(
      widget.firstDay.year,
      widget.firstDay.month,
      widget.firstDay.day,
    );
    setState(() => _busy = true);
    try {
      final existing = await repo
          .watchSlots(
            widget.venueId,
            from: first,
            to: first.add(Duration(days: _days + 1)),
          )
          .first;
      final slots = SlotPlanner.plan(
        SlotPlan(
          firstDay: first,
          fromMinutes: _from,
          toMinutes: _to,
          lengthMinutes: _length,
          price: price,
          days: _days,
          weekdays: _days == 1 ? const {1, 2, 3, 4, 5, 6, 7} : _weekdays,
        ),
        now: now,
        existing: existing,
      );
      if (slots.isNotEmpty) await repo.addSlots(widget.venueId, slots);
      if (mounted) Navigator.pop(context, slots.length);
    } on ArgumentError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${e.message}')));
      }
    } on Object catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String label(int m) =>
        m == 24 * 60 ? 'Midnight' : Formatters.minutesOfDay(m);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen,
        0,
        AppSpacing.screen,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add slots', style: theme.textTheme.titleLarge),
            Text('From ${Formatters.longDate(widget.firstDay)}'),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('slotsFromButton'),
                    onPressed: () => _pickTime(from: true),
                    child: Text('Opens ${label(_from)}'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton(
                    key: const Key('slotsToButton'),
                    onPressed: () => _pickTime(from: false),
                    child: Text('Closes ${label(_to)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Each slot', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<int>(
              segments: [
                for (final l in _lengths)
                  ButtonSegment(
                    value: l,
                    label: Text(Formatters.duration(Duration(minutes: l))),
                  ),
              ],
              selected: {_length},
              onSelectionChanged: (s) => setState(() => _length = s.first),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              key: const Key('slotPriceField'),
              controller: _price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price per slot (NPR)',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Repeat', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final e in _repeat.entries)
                  ChoiceChip(
                    key: Key('repeat_${e.key}'),
                    label: Text(e.value),
                    selected: _days == e.key,
                    onSelected: (_) => setState(() => _days = e.key),
                  ),
              ],
            ),
            if (_days > 1) ...[
              const SizedBox(height: AppSpacing.md),
              Text('On these days', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                children: [
                  for (var d = 1; d <= 7; d++)
                    FilterChip(
                      key: Key('weekday_$d'),
                      label: Text(_weekdayLetters[d - 1]),
                      showCheckmark: false,
                      selected: _weekdays.contains(d),
                      onSelected: (on) => setState(
                        () => _weekdays = on
                            ? {..._weekdays, d}
                            : ({..._weekdays}..remove(d)),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              key: const Key('saveSlotsButton'),
              onPressed: _busy ? null : _save,
              child: Text(_busy ? 'Adding…' : 'Add slots'),
            ),
          ],
        ),
      ),
    );
  }
}
