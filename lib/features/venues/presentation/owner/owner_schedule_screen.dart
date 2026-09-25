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

  Future<void> _openSlot(VenueSlot slot) async {
    if (slot.isFree) {
      final remove = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(Formatters.timeRange(slot.startAt, slot.endAt)),
          content: const Text(
            'This slot is free. Remove it so organizers can’t book it?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep'),
            ),
            FilledButton(
              key: const Key('removeSlotButton'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove slot'),
            ),
          ],
        ),
      );
      if (remove == true && mounted) {
        await runWithFeedback(
          context,
          () => ref
              .read(venueRepositoryProvider)
              .deleteSlot(slot.venueId, slot.id),
        );
      }
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _BookingSheet(slot: slot),
    );
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
                    subtitle: b == null
                        ? null
                        : '📅 ${b.matchTitle} · by ${b.organizerName}',
                    trailing: s.isFree
                        ? const Text('Free')
                        : const Icon(Icons.chevron_right_rounded),
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
