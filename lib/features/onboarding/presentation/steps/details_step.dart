import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../profile/domain/profile_rules.dart';
import '../onboarding_controller.dart';

class DetailsStep extends ConsumerWidget {
  const DetailsStep({super.key});

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final latest = DateTime(
      now.year - ProfileRules.minimumAge,
      now.month,
      now.day,
    );
    final current = ref.read(onboardingControllerProvider).dateOfBirth;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(latest.year - 6),
      firstDate: DateTime(now.year - 90),
      lastDate: latest,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Date of birth',
    );
    if (picked != null) {
      ref
          .read(onboardingControllerProvider.notifier)
          .update((s) => s.copyWith(dateOfBirth: picked));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final dob = state.dateOfBirth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          key: const Key('dateOfBirthField'),
          onTap: () => _pickDate(context, ref),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Date of birth',
              prefixIcon: Icon(Icons.cake_outlined),
              helperText: 'Not shown publicly · you must be 16 or older',
            ),
            child: Text(
              dob == null ? 'Select date' : DateFormat.yMMMMd().format(dob),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          key: const Key('cityField'),
          initialValue: state.city,
          textCapitalization: TextCapitalization.words,
          onChanged: (v) => controller.update((s) => s.copyWith(city: v)),
          decoration: const InputDecoration(
            labelText: 'City',
            hintText: 'e.g. Kathmandu',
            prefixIcon: Icon(Icons.location_city_rounded),
          ),
        ),
      ],
    );
  }
}
