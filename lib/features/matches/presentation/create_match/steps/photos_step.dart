import 'package:material_ui/material_ui.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../domain/match_draft.dart';
import '../../../domain/match_validator.dart';

class PhotosStep extends StatelessWidget {
  const PhotosStep({
    super.key,
    required this.draft,
    required this.busy,
    required this.onAdd,
    required this.onRemove,
  });

  final MatchDraft draft;
  final bool busy;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final canAdd = draft.photos.length < MatchValidator.maxPhotos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Optional: show the pitch, the venue entrance or last week’s game.',
        ),
        const SizedBox(height: AppSpacing.lg),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          children: [
            for (final url in draft.photos)
              Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Image.network(url, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: IconButton.filledTonal(
                      tooltip: 'Remove photo',
                      iconSize: 18,
                      onPressed: () => onRemove(url),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ],
              ),
            if (canAdd)
              OutlinedButton(
                onPressed: busy ? null : onAdd,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: busy
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.add_a_photo_outlined, size: 32),
              ),
          ],
        ),
      ],
    );
  }
}
