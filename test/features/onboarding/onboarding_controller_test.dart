import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solomatch/core/errors/app_failure.dart';
import 'package:solomatch/features/auth/data/auth_providers.dart';
import 'package:solomatch/features/auth/domain/auth_user.dart';
import 'package:solomatch/features/onboarding/presentation/onboarding_controller.dart';
import 'package:solomatch/features/onboarding/presentation/onboarding_state.dart';
import 'package:solomatch/features/profile/data/profile_providers.dart';
import 'package:solomatch/shared/models/position.dart';
import 'package:solomatch/shared/models/skill_level.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_profile_repository.dart';

void main() {
  late FakeProfileRepository profiles;
  late ProviderContainer container;

  OnboardingController controller() =>
      container.read(onboardingControllerProvider.notifier);
  OnboardingState state() => container.read(onboardingControllerProvider);

  setUp(() {
    profiles = FakeProfileRepository()..takenUsernames.add('taken');
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          FakeAuthRepository(
            signedIn: const AuthUser(
              uid: 'raj',
              email: 'raj@example.com',
              displayName: 'Raj Shrestha',
            ),
          ),
        ),
        profileRepositoryProvider.overrideWithValue(profiles),
      ],
    );
    // Keep the auto-dispose controller alive for the whole test.
    container.listen(onboardingControllerProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  Future<void> fillAllSteps() async {
    controller().setUsername('Raj10');
    await controller().next();
    controller().update(
      (s) => s.copyWith(dateOfBirth: DateTime(1998, 5, 12), city: 'Kathmandu'),
    );
    await controller().next();
    controller().update(
      (s) => s.copyWith(primaryPosition: Position.centralMidfielder),
    );
    await controller().next();
    controller().update((s) => s.copyWith(skillLevel: SkillLevel.advanced));
    await controller().next();
  }

  test('prefills name from the auth account', () {
    expect(state().fullName, 'Raj Shrestha');
  });

  test('will not advance past an incomplete step', () async {
    await expectLater(controller().next(), throwsA(isA<ValidationFailure>()));
    expect(state().step, OnboardingStep.basics);
  });

  test('taken username blocks step 1 and shows an inline error', () async {
    controller().setUsername('taken');
    await expectLater(controller().next(), throwsA(isA<ValidationFailure>()));
    expect(state().step, OnboardingStep.basics);
    expect(state().usernameError, isNotNull);

    controller().setUsername('free');
    expect(state().usernameError, isNull);
  });

  test('finishing saves a normalized profile', () async {
    await fillAllSteps();
    expect(state().step, OnboardingStep.extras);

    await controller().next();
    final saved = profiles.profileOf('raj')!;
    expect(saved.username, 'raj10');
    expect(saved.fullName, 'Raj Shrestha');
    expect(saved.primaryPosition, Position.centralMidfielder);
    expect(saved.skillLevel, SkillLevel.advanced);
    expect(saved.languages, ['Nepali']);
  });

  test('username taken during save sends the user back to step 1', () async {
    await fillAllSteps();
    profiles.takenUsernames.add('raj10');

    await expectLater(controller().next(), throwsA(isA<ValidationFailure>()));
    expect(state().step, OnboardingStep.basics);
    expect(state().usernameError, isNotNull);
    expect(state().busy, isFalse);
  });
}
