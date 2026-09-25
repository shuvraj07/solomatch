import 'package:material_ui/material_ui.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/rating_stars.dart';
import '../domain/review.dart';

typedef RatingInput = ({int rating, String comment});

/// Stars + optional comment for one person. Returns null if dismissed.
Future<RatingInput?> showRateSheet(
  BuildContext context, {
  required String name,
  required String matchTitle,
}) => showModalBottomSheet<RatingInput>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _RateSheet(name: name, matchTitle: matchTitle),
);

class _RateSheet extends StatefulWidget {
  const _RateSheet({required this.name, required this.matchTitle});

  final String name;
  final String matchTitle;

  @override
  State<_RateSheet> createState() => _RateSheetState();
}

class _RateSheetState extends State<_RateSheet> {
  int _rating = 0;
  final _comment = TextEditingController();

  static const _labels = [
    '',
    'Poor',
    'Below average',
    'Good',
    'Great',
    'Outstanding',
  ];

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Rate ${widget.name}', style: theme.textTheme.headlineSmall),
          Text(widget.matchTitle, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          StarPicker(
            value: _rating,
            onChanged: (v) => setState(() => _rating = v),
          ),
          Text(
            _labels[_rating],
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            key: const Key('reviewCommentField'),
            controller: _comment,
            maxLength: ReviewRules.maxComment,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Comment (optional)',
              hintText: 'Fair play, great passing, on time…',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ratings are public and can\'t be changed later. Be fair and kind.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            key: const Key('submitRatingButton'),
            onPressed: _rating == 0
                ? null
                : () => Navigator.pop(context, (
                    rating: _rating,
                    comment: _comment.text.trim(),
                  )),
            child: const Text('Submit rating'),
          ),
        ],
      ),
    );
  }
}
