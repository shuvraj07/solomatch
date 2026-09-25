import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../app/providers/firebase_providers.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import 'firebase_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(
    ref.watch(firebaseAuthProvider),
    GoogleSignIn.instance,
  ),
);

/// The signed-in user, or null. Rebuilds dependants on sign-in/out.
final authStateProvider = StreamProvider<AuthUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);
