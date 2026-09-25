import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_providers.dart';

/// Runs one auth action at a time and exposes its progress/error to the UI.
///
/// Navigation is not done here: on success the session changes and the
/// router redirects automatically.
class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signInWithEmail(String email, String password) => _run(
    () => ref
        .read(authRepositoryProvider)
        .signInWithEmail(email: email, password: password),
  );

  Future<void> signUpWithEmail(String email, String password) => _run(
    () => ref
        .read(authRepositoryProvider)
        .signUpWithEmail(email: email, password: password),
  );

  Future<void> signInWithGoogle() =>
      _run(() => ref.read(authRepositoryProvider).signInWithGoogle());

  /// Returns true when the reset email was sent.
  Future<bool> sendPasswordReset(String email) async {
    await _run(
      () => ref.read(authRepositoryProvider).sendPasswordResetEmail(email),
    );
    return ref.mounted && !state.hasError;
  }

  Future<void> _run(Future<void> Function() action) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(action);
    if (ref.mounted) state = result;
  }
}

final authControllerProvider =
    AsyncNotifierProvider.autoDispose<AuthController, void>(AuthController.new);
