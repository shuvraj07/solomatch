import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'push/push_coordinator.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class SoloMatchApp extends ConsumerWidget {
  const SoloMatchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'SoloMatch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: ref.watch(appRouterProvider),
      scaffoldMessengerKey: ref.watch(scaffoldMessengerKeyProvider),
      builder: (context, child) =>
          PushCoordinator(child: child ?? const SizedBox.shrink()),
    );
  }
}
