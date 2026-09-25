import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/providers/clock_provider.dart';
import '../../../../app/session/session_provider.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/widgets/placeholder_view.dart';
import '../../../../core/widgets/run_with_feedback.dart';
import '../../../notifications/presentation/notification_bell.dart';
import '../../data/venue_providers.dart';
import '../../domain/venue_models.dart';
import '../widgets/venue_widgets.dart';
import 'add_slots_sheet.dart';

/// The owner's day-by-day timetable: free and booked slots.
class OwnerScheduleScreen extends ConsumerStatefulWidget {
  const OwnerScheduleScreen({super.key});

  @override
  ConsumerState<OwnerScheduleScreen> createState() =>
      _OwnerScheduleScreenState();
}

class _OwnerScheduleScreenState extends ConsumerState<OwnerScheduleScreen> {
  DateTime? _day;

  Future<void> _addSlots(String venueId, DateTime day, int price) async {
    final added = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) =>
          AddSlotsSheet(venueId: venueId, firstDay: day, defaultPrice: price),
    );
    if (added != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            added == 0
                ? 'No new slots: those times are already listed'
                : 'Added $added ${added == 1 ? 'slot' : 'slots'}',
          ),
        ),
      );
    }
  }

  /// Flips a free slot to booked (phone/walk-in) or back to free.
  Future<void> _toggle(VenueSlot slot, {String note = ''}) {
    final repo = ref.read(venueRepositoryProvider);
    return runWithFeedback(
      context,
      () => slot.isFree
          ? repo.markBookedOffline(slot.venueId, slot.id, note: note)
          : repo.markFree(slot.venueId, slot.id),
    );
  }

  Future<void> _openSlot(VenueSlot slot) async {
    if (slot.bookedInApp) {
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => _BookingSheet(slot: slot),
      );
      return;
    }
    final choice = await showModalBottomSheet<_SlotChoice>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _OwnSlotSheet(slot: slot),
    );
    if (choice == null || !mounted) return;
    switch (choice) {
      case _Toggle(:final note):
        await _toggle(slot, note: note);
      case _Remove():
        await runWithFeedback(
          context,
          () => ref
              .read(venueRepositoryProvider)
              .deleteSlot(slot.venueId, slot.id),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final owner = ref.watch(currentOwnerProvider);
    final now = ref.watch(clockProvider)();
    // Date only: it's part of the slots provider key.
    final day = DateUtils.dateOnly(_day ?? now);
    if (owner == null) return const SizedBox.shrink();
    final venue = ref.watch(venueProvider(owner.uid)).value;
    final slots = ref.watch(
      venueDaySlotsProvider((venueId: owner.uid, day: day)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(venue?.name ?? 'Schedule'),
        actions: const [NotificationBell()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('addSlotsButton'),
        onPressed: () => _addSlots(owner.uid, day, venue?.pricePerHour ?? 0),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add slots'),
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          DayStrip(
            today: now,
            selected: day,
            onSelected: (d) => setState(() => _day = d),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.md,
              AppSpacing.screen,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    Formatters.longDate(day),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (slots case AsyncData(value: final list))
                  Text(
                    '${list.where((s) => !s.isFree).length} booked · '
                    '${list.where((s) => s.isFree).length} free',
                  ),
              ],
            ),
          ),
          Expanded(
            child: switch (slots) {
              AsyncData(value: final list) when list.isEmpty =>
                const PlaceholderView(
                  icon: Icons.event_note_rounded,
                  title: 'No slots this day',
                  message: 'Tap “Add slots” to list times organizers can book.',
                ),
              AsyncData(value: final list) => ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.sm,
                  AppSpacing.screen,
                  AppSpacing.xxl * 2,
                ),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final s = list[i];
                  final b = s.booking;
                  return SlotTile(
                    slot: s,
                    onTap: () => _openSlot(s),
                    subtitle: switch (s) {
                      _ when b != null =>
                        '📅 ${b.matchTitle} · by ${b.organizerName}',
                      VenueSlot(bookedOffline: true, :final offlineNote) =>
                        '📞 Booked by you'
                            '${offlineNote.isEmpty ? '' : ' · $offlineNote'}',
                      _ => null,
                    },
                    // App bookings are cancelled from the sheet (the
                    // organizer is told); the rest flip with the switch.
                    trailing: s.bookedInApp
                        ? const Icon(Icons.chevron_right_rounded)
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 32,
                                child: FittedBox(
                                  child: Switch(
                                    key: Key('toggle_${s.id}'),
                                    value: !s.isFree,
                                    onChanged: (_) => _toggle(s),
                                  ),
                                ),
                              ),
                              Text(
                                s.isFree ? 'Free' : 'Booked',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                  );
                },
              ),
              AsyncError(:final error) => Center(
                child: Text(errorMessage(error)),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }
}

/// Details of a booked slot, with "Cancel booking".
class _BookingSheet extends ConsumerStatefulWidget {
  const _BookingSheet({required this.slot});

  final VenueSlot slot;

  @override
  ConsumerState<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends ConsumerState<_BookingSheet> {
  final _reason = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _cancel() async {
    setState(() => _busy = true);
    final ok = await runWithFeedback(
      context,
      () => ref
          .read(venueRepositoryProvider)
          .cancelBooking(widget.slot.id, reason: _reason.text),
      success: 'Booking cancelled. The organizer has been told.',
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.slot;
    final b = s.booking;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen,
        0,
        AppSpacing.screen,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Booked', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${Formatters.longDate(s.startAt)}\n'
            '${Formatters.timeRange(s.startAt, s.endAt)}',
            style: theme.textTheme.titleMedium,
          ),
          if (b != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text('📅 ${b.matchTitle}'),
            Text('👤 Organizer: ${b.organizerName}'),
          ],
          const SizedBox(height: AppSpacing.xl),
          TextField(
            key: const Key('cancelReasonField'),
            controller: _reason,
            maxLength: 200,
            decoration: const InputDecoration(
              labelText: 'Reason (sent to the organizer)',
              hintText: 'e.g. Pitch closed for repairs',
            ),
          ),
          FilledButton.icon(
            key: const Key('cancelBookingButton'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            onPressed: _busy ? null : _cancel,
            icon: const Icon(Icons.event_busy_rounded),
            label: const Text('Cancel booking'),
          ),
        ],
      ),
    );
  }
}

sealed class _SlotChoice {
  const _SlotChoice();
}

final class _Toggle extends _SlotChoice {
  const _Toggle([this.note = '']);

  final String note;
}

final class _Remove extends _SlotChoice {
  const _Remove();
}

/// Options for a slot the owner controls: mark booked (with a note) or
/// free, or remove it.
class _OwnSlotSheet extends StatefulWidget {
  const _OwnSlotSheet({required this.slot});

  final VenueSlot slot;

  @override
  State<_OwnSlotSheet> createState() => _OwnSlotSheetState();
}

class _OwnSlotSheetState extends State<_OwnSlotSheet> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.slot;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen,
        0,
        AppSpacing.screen,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Formatters.timeRange(s.startAt, s.endAt),
            style: theme.textTheme.titleLarge,
          ),
          Text(
            s.isFree
                ? 'Free: organizers can book this in the app.'
                : 'Booked by you (phone or walk-in)'
                      '${s.offlineNote.isEmpty ? '' : ': ${s.offlineNote}'}',
          ),
          const SizedBox(height: AppSpacing.lg),
          if (s.isFree) ...[
            TextField(
              key: const Key('offlineNoteField'),
              controller: _note,
              maxLength: 80,
              decoration: const InputDecoration(
                labelText: 'Booked for (optional)',
                hintText: 'e.g. Ram’s team',
                helperText: 'A short note for you. Avoid phone numbers.',
              ),
            ),
            FilledButton.icon(
              key: const Key('markBookedButton'),
              onPressed: () => Navigator.pop(context, _Toggle(_note.text)),
              icon: const Icon(Icons.event_busy_rounded),
              label: const Text('Mark as booked'),
            ),
          ] else
            FilledButton.icon(
              key: const Key('markFreeButton'),
              onPressed: () => Navigator.pop(context, const _Toggle()),
              icon: const Icon(Icons.event_available_rounded),
              label: const Text('Mark as free'),
            ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            key: const Key('removeSlotButton'),
            onPressed: () => Navigator.pop(context, const _Remove()),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Remove slot'),
          ),
        ],
      ),
    );
  }
}
