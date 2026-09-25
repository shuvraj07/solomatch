import 'package:material_ui/material_ui.dart';

import '../../app/theme/app_colors.dart';

/// Read-only ★★★★☆ for a 0–5 rating (rounded to the nearest half).
class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.size = 16});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final halves = (rating * 2).round();
    return Semantics(
      label: '${rating.toStringAsFixed(1)} out of 5 stars',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            Icon(
              halves >= i * 2
                  ? Icons.star_rounded
                  : halves == i * 2 - 1
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
              size: size,
              color: AppColors.goalkeeper,
            ),
        ],
      ),
    );
  }
}

/// Tappable 1–5 star picker.
class StarPicker extends StatelessWidget {
  const StarPicker({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            key: Key('star_$i'),
            tooltip: '$i ${i == 1 ? 'star' : 'stars'}',
            iconSize: 40,
            onPressed: () => onChanged(i),
            icon: Icon(
              i <= value ? Icons.star_rounded : Icons.star_outline_rounded,
              color: AppColors.goalkeeper,
            ),
          ),
      ],
    );
  }
}
