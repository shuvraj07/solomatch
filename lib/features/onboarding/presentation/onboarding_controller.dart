import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_failure.dart';
import '../../auth/data/auth_providers.dart';
import '../../profile/data/profile_providers.dart';
import '../../profile/domain/player_profile.dart';
import '../../profile/domain/profile_rules.dart';
import 'onboarding_state.dart';
import 'onboarding_validation.dart';

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    // Prefill from the auth provider (e.g. Google display name).
    final user = ref.read(authRepositoryProvider).currentUser;
    return OnboardingState(fullName: user?.displayName ?? '');
  }

  void update(OnboardingState Function(OnboardingState s) change) {
    state = change(state);
  }

  void setUsername(String value) {
    state = state.copyWith(username: value, usernameError: null);
  }

  void back() {
    if (state.step.index > 0) {
      state = state.copyWith(step: OnboardingStep.values[state.step.index - 1]);
    }
  }

  /// Validates the current step and advances. On the last step, saves the
  /// profile; the session then switches to Ready and the router leaves
  /// onboarding. Throws [AppFailure] with a message for the UI.
  Future<void> next() async {
    if (state.busy) return;
    final problem = validateOnboardingStep(state);
    if (problem != null) throw ValidationFailure(problem);

    if (state.step == OnboardingStep.basics) {
      await _checkUsername();
    }
    if (state.step.isLast) {
      await _save();
    } else {
      state = state.copyWith(step: OnboardingStep.values[state.step.index + 1]);
    }
  }

  Future<void> _checkUsername() async {
    state = state.copyWith(busy: true);
    try {
      final available = await ref
          .read(profileRepositoryProvider)
          .isUsernameAvailable(state.username);
      if (!available) {
        state = state.copyWith(usernameError: 'That username is taken');
        throw const ValidationFailure('That username is taken');
      }
    } finally {
      if (ref.mounted) state = state.copyWith(busy: false);
    }
  }

  Future<void> _save() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) throw const AuthFailure('You are signed out.');
    final repo = ref.read(profileRepositoryProvider);

    state = state.copyWith(busy: true);
    try {
      final photo = state.photoBytes;
      final photoUrl = photo == null
          ? user.photoUrl
          : await repo.uploadProfilePhoto(user.uid, photo);

      await repo.createProfile(
        _toProfile(user.uid, photoUrl),
        email: user.email,
      );
    } on ValidationFailure {
      // Username was claimed between the check and the save.
      if (ref.mounted) {
        state = state.copyWith(
          step: OnboardingStep.basics,
          usernameError: 'That username is taken',
        );
      }
      rethrow;
    } finally {
      if (ref.mounted) state = state.copyWith(busy: false);
    }
  }

  PlayerProfile _toProfile(String uid, String? photoUrl) => PlayerProfile(
    uid: uid,
    fullName: state.fullName.trim(),
    username: ProfileRules.normalizeUsername(state.username),
    photoUrl: photoUrl,
    dateOfBirth: state.dateOfBirth!,
    city: state.city.trim(),
    bio: state.bio.trim(),
    primaryPosition: state.primaryPosition!,
    secondaryPositions: state.secondaryPositions,
    skillLevel: state.skillLevel!,
    preferredFoot: state.preferredFoot,
    heightCm: state.heightCm,
    yearsPlaying: state.yearsPlaying,
    languages: state.languages,
    availability: state.availability,
  );
}

final onboardingControllerProvider =
    NotifierProvider.autoDispose<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );
