import 'package:material_ui/material_ui.dart';

/// Circular avatar from a photo URL, falling back to the player's initials.
class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.radius = 24,
  });

  final String name;
  final String? photoUrl;
  final double radius;

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final url = photoUrl;
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      foregroundImage: url == null ? null : NetworkImage(url),
      child: Text(
        initials(name),
        style: TextStyle(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.w800,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
