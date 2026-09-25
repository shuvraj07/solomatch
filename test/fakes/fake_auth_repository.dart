import 'dart:async';

import 'package:solomatch/features/auth/domain/auth_repository.dart';
import 'package:solomatch/features/auth/domain/auth_user.dart';

/// In-memory [AuthRepository]. Sign-in methods succeed and sign in
/// [nextUser] unless [error] is set, in which case they throw it.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AuthUser? signedIn}) : _user = signedIn;

  AuthUser? _user;
  final _changes = StreamController<AuthUser?>.broadcast();

  AuthUser nextUser = const AuthUser(uid: 'raj', email: 'raj@example.com');
  Object? error;
  final calls = <String>[];

  void emit(AuthUser? user) {
    _user = user;
    _changes.add(user);
  }

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield _user;
    yield* _changes.stream;
  }

  @override
  AuthUser? get currentUser => _user;

  Future<void> _signIn(String call) async {
    calls.add(call);
    if (error case final e?) throw e;
    emit(nextUser);
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) => _signIn('signInWithEmail:$email');

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) => _signIn('signUpWithEmail:$email');

  @override
  Future<void> signInWithGoogle() => _signIn('signInWithGoogle');

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    calls.add('sendPasswordResetEmail:$email');
    if (error case final e?) throw e;
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    emit(null);
  }
}
