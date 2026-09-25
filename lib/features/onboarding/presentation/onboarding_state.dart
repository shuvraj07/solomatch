import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/availability.dart';
import '../../../shared/models/position.dart';
import '../../../shared/models/preferred_foot.dart';
import '../../../shared/models/skill_level.dart';
import '../../profile/domain/profile_options.dart';

part 'onboarding_state.freezed.dart';

enum OnboardingStep {
  basics('About you'),
  details('Where you play'),
  positions('Your positions'),
  game('Your game'),
  extras('Final touches');

  const OnboardingStep(this.title);

  final String title;

  bool get isLast => this == values.last;
}

/// Draft profile being built across the onboarding steps.
@freezed
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(OnboardingStep.basics) OnboardingStep step,
    @Default('') String fullName,
    @Default('') String username,
    Uint8List? photoBytes,
    DateTime? dateOfBirth,
    @Default('') String city,
    Position? primaryPosition,
    @Default(<Position>[]) List<Position> secondaryPositions,
    SkillLevel? skillLevel,
    @Default(PreferredFoot.right) PreferredFoot preferredFoot,
    int? heightCm,
    @Default(0) int yearsPlaying,
    @Default(ProfileOptions.defaultLanguages) List<String> languages,
    @Default(Availability()) Availability availability,
    @Default('') String bio,

    /// True while checking the username or saving.
    @Default(false) bool busy,

    /// Shown under the username field (e.g. "already taken").
    String? usernameError,
  }) = _OnboardingState;
}
