import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_spacing.dart';

/// "or" divider followed by third-party sign-in buttons.
class SocialSignInSection extends StatelessWidget {
  const SocialSignInSection({
    super.key,
    required this.onGoogle,
    required this.enabled,
  });

  final VoidCallback onGoogle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text('or', style: TextStyle(color: muted)),
              ),
              const Expanded(child: Divider()),
            ],
          ),
        ),
        OutlinedButton.icon(
          key: const Key('googleSignInButton'),
          onPressed: enabled ? onGoogle : null,
          icon: const Text(
            'G',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          label: const Text('Continue with Google'),
        ),
      ],
    );
  }
}
