import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/widgets/error_snackbar.dart';
import '../../features/auth/data/auth_providers.dart';
import '../../features/profile/data/profile_providers.dart';
import '../../shared/widgets/app_logo.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'session_provider.dart';
import 'sign_out.dart';

/// Shown while the session is resolving, or if loading it failed.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final error = session.error;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final onBackground = dark ? Colors.white : Colors.black87;

    return Scaffold(
      // Same as the native launch screen, so there's no flash between them.
      backgroundColor: dark ? const Color(0xFF121417) : Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLogo(size: 160),
              const SizedBox(height: AppSpacing.xl),
              if (error == null)
                const CircularProgressIndicator(color: AppColors.brandOrange)
              else ...[
                Text(
                  errorMessage(error),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: onBackground),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.tonal(
                  onPressed: () {
                    ref
                      ..invalidate(authStateProvider)
                      ..invalidate(playerProfileProvider);
                  },
                  child: const Text('Try again'),
                ),
                TextButton(
                  onPressed: () => ref.read(signOutProvider)(),
                  child: const Text('Sign out'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
