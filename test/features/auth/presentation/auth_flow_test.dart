import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solomatch/core/errors/app_failure.dart';

import '../../../fakes/fake_auth_repository.dart';
import '../../../fakes/fake_profile_repository.dart';
import '../../../fakes/test_data.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('signed-out user sees sign in', (tester) async {
    await pumpApp(tester, auth: FakeAuthRepository());
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('sign in validates the form before calling the backend', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    await pumpApp(tester, auth: auth);

    await tester.tapVisible(find.byKey(const Key('signInButton')));
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    expect(auth.calls, isEmpty);
  });

  testWidgets('existing player signs in and lands on Home', (tester) async {
    final auth = FakeAuthRepository();
    await pumpApp(
      tester,
      auth: auth,
      profiles: FakeProfileRepository(profiles: [testProfile()]),
    );

    await tester.enterText(
      find.byKey(const Key('emailField')),
      'raj@example.com',
    );
    await tester.enterText(find.byKey(const Key('passwordField')), 'secret123');
    await tester.tapVisible(find.byKey(const Key('signInButton')));

    expect(auth.calls, ['signInWithEmail:raj@example.com']);
    expect(find.text('Find your next match ⚽'), findsOneWidget);
  });

  testWidgets('new user signs up and is sent to profile setup', (tester) async {
    final auth = FakeAuthRepository();
    await pumpApp(tester, auth: auth);

    await tester.tapVisible(find.text('Create account'));
    await tester.enterText(
      find.byKey(const Key('emailField')),
      'new@example.com',
    );
    await tester.enterText(find.byKey(const Key('passwordField')), 'password1');
    await tester.enterText(
      find.byKey(const Key('confirmPasswordField')),
      'password1',
    );
    await tester.tapVisible(find.byKey(const Key('signUpButton')));

    expect(auth.calls, ['signUpWithEmail:new@example.com']);
    expect(find.text('Step 1 of 5'), findsOneWidget);
  });

  testWidgets('sign-up rejects mismatched passwords', (tester) async {
    final auth = FakeAuthRepository();
    await pumpApp(tester, auth: auth);
    await tester.tapVisible(find.text('Create account'));

    await tester.enterText(find.byKey(const Key('emailField')), 'a@b.co');
    await tester.enterText(find.byKey(const Key('passwordField')), 'password1');
    await tester.enterText(
      find.byKey(const Key('confirmPasswordField')),
      'password2',
    );
    await tester.tapVisible(find.byKey(const Key('signUpButton')));

    expect(find.text("Passwords don't match"), findsOneWidget);
    expect(auth.calls, isEmpty);
  });

  testWidgets('backend errors are shown to the user', (tester) async {
    final auth = FakeAuthRepository()
      ..error = const AuthFailure('Incorrect email or password.');
    await pumpApp(tester, auth: auth);

    await tester.enterText(
      find.byKey(const Key('emailField')),
      'raj@example.com',
    );
    await tester.enterText(find.byKey(const Key('passwordField')), 'wrong');
    await tester.tapVisible(find.byKey(const Key('signInButton')));

    expect(find.text('Incorrect email or password.'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('forgot password sends a reset email', (tester) async {
    final auth = FakeAuthRepository();
    await pumpApp(tester, auth: auth);

    await tester.tapVisible(find.text('Forgot password?'));
    await tester.enterText(
      find.byKey(const Key('emailField')),
      'raj@example.com',
    );
    await tester.tapVisible(find.byKey(const Key('sendResetButton')));

    expect(auth.calls, ['sendPasswordResetEmail:raj@example.com']);
    expect(find.textContaining('reset link is on its way'), findsOneWidget);
  });

  testWidgets('signing out returns to sign in', (tester) async {
    final auth = FakeAuthRepository(signedIn: testUser);
    await pumpApp(
      tester,
      auth: auth,
      profiles: FakeProfileRepository(profiles: [testProfile()]),
    );

    await tester.tapVisible(find.bySemanticsLabel('Profile'));
    await tester.tapVisible(find.byKey(const Key('signOutButton')));

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
