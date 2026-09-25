import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/session/session_provider.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/count_stepper.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../core/widgets/run_with_feedback.dart';
import '../../../shared/models/position.dart';
import '../../../shared/models/preferred_foot.dart';
import '../../../shared/models/skill_level.dart';
import '../../../shared/widgets/player_avatar.dart';
import '../data/profile_providers.dart';
import '../domain/player_profile.dart';
import '../domain/profile_options.dart';
import '../domain/profile_rules.dart';
import 'widgets/availability_grid.dart';
import 'widgets/position_chips.dart';

/// Edit your football profile. Username and date of birth can't change.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  PlayerProfile? _draft;
  Uint8List? _newPhoto;
  bool _saving = false;

  void _set(PlayerProfile Function(PlayerProfile p) change) =>
      setState(() => _draft = change(_draft!));

  String? _problem(PlayerProfile p) =>
      ProfileRules.validateFullName(p.fullName) ??
      (p.city.trim().isEmpty ? 'Enter your city' : null) ??
      (p.bio.length > ProfileRules.maxBioLength ? 'Bio is too long' : null) ??
      (p.heightCm != null &&
              (p.heightCm! < ProfileRules.minHeightCm ||
                  p.heightCm! > ProfileRules.maxHeightCm)
          ? 'Height must be ${ProfileRules.minHeightCm}–'
                '${ProfileRules.maxHeightCm} cm'
          : null);

  Future<void> _pickPhoto() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _newPhoto = bytes);
  }

  Future<void> _save() async {
    final draft = _draft!;
    final problem = _problem(draft);
    setState(() => _saving = true);
    final ok = await runWithFeedback(context, () async {
      if (problem != null) throw ValidationFailure(problem);
      final repo = ref.read(profileRepositoryProvider);
      final photo = _newPhoto;
      final photoUrl = photo == null
          ? draft.photoUrl
          : await repo.uploadProfilePhoto(draft.uid, photo);
      await repo.updateProfile(draft.copyWith(photoUrl: photoUrl));
    }, success: 'Profile updated');
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(currentProfileProvider);
    if (current == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final p = _draft ??= current;
    final theme = Theme.of(context);
    final photo = _newPhoto;

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.sm),
      child: Text(text, style: theme.textTheme.titleMedium),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Center(
            child: Stack(
              children: [
                photo == null
                    ? PlayerAvatar(
                        name: p.fullName,
                        photoUrl: p.photoUrl,
                        radius: 48,
                      )
                    : CircleAvatar(
                        radius: 48,
                        backgroundImage: MemoryImage(photo),
                      ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IconButton.filled(
                    tooltip: 'Change photo',
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.photo_camera_rounded),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '@${p.username} · username can’t be changed',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            key: const Key('editFullName'),
            initialValue: p.fullName,
            textCapitalization: TextCapitalization.words,
            onChanged: (v) => _set((x) => x.copyWith(fullName: v)),
            decoration: const InputDecoration(labelText: 'Full name'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            key: const Key('editCity'),
            initialValue: p.city,
            textCapitalization: TextCapitalization.words,
            onChanged: (v) => _set((x) => x.copyWith(city: v)),
            decoration: const InputDecoration(labelText: 'City'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            key: const Key('editBio'),
            initialValue: p.bio,
            maxLines: 3,
            maxLength: ProfileRules.maxBioLength,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (v) => _set((x) => x.copyWith(bio: v)),
            decoration: const InputDecoration(labelText: 'Bio'),
          ),
          heading('Main position'),
          PositionChips(
            selected: {p.primaryPosition},
            onTap: (pos) => _set(
              (x) => x.copyWith(
                primaryPosition: pos,
                secondaryPositions: [
                  for (final s in x.secondaryPositions)
                    if (s != pos) s,
                ],
              ),
            ),
          ),
          heading('Also plays (up to ${ProfileRules.maxSecondaryPositions})'),
          PositionChips(
            multiSelect: true,
            selected: p.secondaryPositions.toSet(),
            disabled: {p.primaryPosition},
            onTap: (pos) => _set((x) {
              final list = [...x.secondaryPositions];
              if (!list.remove(pos) &&
                  list.length < ProfileRules.maxSecondaryPositions) {
                list.add(pos);
              }
              return x.copyWith(secondaryPositions: List<Position>.of(list));
            }),
          ),
          heading('Skill level'),
          SegmentedButton<SkillLevel>(
            showSelectedIcon: false,
            segments: [
              for (final l in SkillLevel.playerLevels)
                ButtonSegment(value: l, label: Text(l.label)),
            ],
            selected: {p.skillLevel},
            onSelectionChanged: (v) =>
                _set((x) => x.copyWith(skillLevel: v.first)),
          ),
          heading('Preferred foot'),
          SegmentedButton<PreferredFoot>(
            showSelectedIcon: false,
            segments: [
              for (final f in PreferredFoot.values)
                ButtonSegment(value: f, label: Text(f.label)),
            ],
            selected: {p.preferredFoot},
            onSelectionChanged: (v) =>
                _set((x) => x.copyWith(preferredFoot: v.first)),
          ),
          heading('Years playing'),
          CountStepper(
            value: p.yearsPlaying,
            max: 60,
            label: 'years',
            onChanged: (n) => _set((x) => x.copyWith(yearsPlaying: n)),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: p.heightCm?.toString() ?? '',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            onChanged: (v) =>
                _set((x) => x.copyWith(heightCm: int.tryParse(v))),
            decoration: const InputDecoration(
              labelText: 'Height (optional)',
              suffixText: 'cm',
            ),
          ),
          heading('Languages'),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final lang in ProfileOptions.languages)
                FilterChip(
                  label: Text(lang),
                  selected: p.languages.contains(lang),
                  onSelected: (on) => _set(
                    (x) => x.copyWith(
                      languages: on
                          ? [...x.languages, lang]
                          : [
                              for (final l in x.languages)
                                if (l != lang) l,
                            ],
                    ),
                  ),
                ),
            ],
          ),
          heading('When you usually play'),
          AvailabilityGrid(
            value: p.availability,
            onChanged: (a) => _set((x) => x.copyWith(availability: a)),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: LoadingButton(
            key: const Key('saveProfileButton'),
            label: 'Save',
            loading: _saving,
            onPressed: _save,
          ),
        ),
      ),
    );
  }
}
