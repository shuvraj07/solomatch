import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_spacing.dart';
import '../onboarding_controller.dart';

class BasicsStep extends ConsumerWidget {
  const BasicsStep({super.key});

  Future<void> _pickPhoto(WidgetRef ref) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    ref
        .read(onboardingControllerProvider.notifier)
        .update((s) => s.copyWith(photoBytes: bytes));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final photo = state.photoBytes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 52,
                backgroundColor: scheme.primaryContainer,
                backgroundImage: photo == null ? null : MemoryImage(photo),
                child: photo == null
                    ? Icon(
                        Icons.person_rounded,
                        size: 52,
                        color: scheme.onPrimaryContainer,
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: IconButton.filled(
                  tooltip: 'Add photo',
                  onPressed: () => _pickPhoto(ref),
                  icon: const Icon(Icons.photo_camera_rounded),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        TextFormField(
          key: const Key('fullNameField'),
          initialValue: state.fullName,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          onChanged: (v) => controller.update((s) => s.copyWith(fullName: v)),
          decoration: const InputDecoration(labelText: 'Full name'),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          key: const Key('usernameField'),
          initialValue: state.username,
          autocorrect: false,
          onChanged: controller.setUsername,
          decoration: InputDecoration(
            labelText: 'Username',
            prefixText: '@',
            helperText: 'Letters, numbers and _ · shown on your profile',
            errorText: state.usernameError,
          ),
        ),
      ],
    );
  }
}
