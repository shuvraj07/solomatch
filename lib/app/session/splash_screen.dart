import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/widgets/error_snackbar.dart';
import '../../features/auth/data/auth_providers.dart';
import '../../features/profile/data/profile_providers.dart';
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

    return Scaffold(
      backgroundColor: AppColors.pitch,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.sports_soccer_rounded,
                size: 72,
                color: AppColors.volt,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (error == null)
                const CircularProgressIndicator(color: Colors.white)
              else ...[
                Text(
                  errorMessage(error),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
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
                  child: const Text(
                    'Sign out',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
