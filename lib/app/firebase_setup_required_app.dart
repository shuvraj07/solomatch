import 'package:material_ui/material_ui.dart';

import 'theme/app_theme.dart';

/// Shown when Firebase fails to initialize, so a fresh clone without Firebase
/// config explains what to do instead of crashing on launch.
class FirebaseSetupRequiredApp extends StatelessWidget {
  const FirebaseSetupRequiredApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Firebase is not configured',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add android/app/google-services.json and follow '
                  'docs/firebase-setup.md, then restart the app.',
                ),
                const SizedBox(height: 16),
                Text('$error', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
