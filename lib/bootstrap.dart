import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'app/config/env.dart';
import 'app/firebase_setup_required_app.dart';
import 'firebase_options.dart';

/// Initializes platform services, then runs the app.
///
/// If Firebase cannot be initialized (for example `google-services.json` has
/// not been added yet) a setup screen is shown instead of crashing.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on Object catch (error) {
    debugPrint('Firebase initialization failed: $error');
    runApp(FirebaseSetupRequiredApp(error: error));
    return;
  }

  if (Env.useFirebaseEmulators) {
    await _connectToEmulators();
  }
  _configureCrashReporting();

  runApp(const ProviderScope(child: SoloMatchApp()));
}

Future<void> _connectToEmulators() async {
  const host = Env.emulatorHost;
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  FirebaseFunctions.instanceFor(region: Env.functionsRegion)
      .useFunctionsEmulator(host, 5001);
  await FirebaseStorage.instance.useStorageEmulator(host, 9199);
}

void _configureCrashReporting() {
  final crashlytics = FirebaseCrashlytics.instance;
  unawaited(crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode));

  FlutterError.onError = crashlytics.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(crashlytics.recordError(error, stack, fatal: true));
    return true;
  };
}
