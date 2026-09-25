import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/session/session_provider.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../../core/widgets/run_with_feedback.dart';
import '../../data/venue_providers.dart';
import '../../domain/venue_models.dart';
import '../widgets/venue_form.dart';

const _maxPhotos = 5;

/// Edit the venue's details and photos.
class EditVenueScreen extends ConsumerStatefulWidget {
  const EditVenueScreen({super.key});

  @override
  ConsumerState<EditVenueScreen> createState() => _EditVenueScreenState();
}

class _EditVenueScreenState extends ConsumerState<EditVenueScreen> {
  final _form = GlobalKey<FormState>();
  VenueProfile? _venue;
  var _busy = false;

  Future<void> _addPhoto(VenueProfile venue) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (file == null || !mounted) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() => _busy = true);
    await runWithFeedback(context, () async {
      final url = await ref
          .read(venueRepositoryProvider)
          .uploadVenuePhoto(venue.id, bytes);
      if (mounted) {
        setState(
          () => _venue = (_venue ?? venue).copyWith(
            photos: [...(_venue ?? venue).photos, url],
          ),
        );
      }
    });
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _save(VenueProfile venue) async {
    if (!_form.currentState!.validate()) return;
    if (venue.formats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick at least one match size')),
      );
      return;
    }
    setState(() => _busy = true);
    final ok = await runWithFeedback(
      context,
      () => ref.read(venueRepositoryProvider).updateVenue(venue),
      success: 'Venue saved',
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final owner = ref.watch(currentOwnerProvider);
    final loaded = owner == null
        ? null
        : ref.watch(venueProvider(owner.uid)).value;
    final venue = _venue ?? loaded;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit venue')),
      body: venue == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.screen),
                children: [
                  Text('Photos', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final url in venue.photos)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              child: Image.network(
                                url,
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton.filledTonal(
                                tooltip: 'Remove photo',
                                iconSize: 16,
                                onPressed: () => setState(
                                  () => _venue = venue.copyWith(
                                    photos: [
                                      for (final p in venue.photos)
                                        if (p != url) p,
                                    ],
                                  ),
                                ),
                                icon: const Icon(Icons.close_rounded),
                              ),
                            ),
                          ],
                        ),
                      if (venue.photos.length < _maxPhotos)
                        SizedBox(
                          width: 96,
                          height: 96,
                          child: OutlinedButton(
                            onPressed: _busy ? null : () => _addPhoto(venue),
                            child: const Icon(Icons.add_a_photo_outlined),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  VenueFormFields(
                    venue: venue,
                    onChanged: (v) => setState(() => _venue = v),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  LoadingButton(
                    key: const Key('saveVenueButton'),
                    label: 'Save',
                    loading: _busy,
                    onPressed: () => _save(venue),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
    );
  }
}
