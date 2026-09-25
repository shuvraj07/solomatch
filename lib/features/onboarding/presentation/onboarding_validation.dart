import '../../profile/domain/profile_rules.dart';
import 'onboarding_state.dart';

/// Returns the first problem with the current step, or null if it is complete.
/// Username availability is checked separately because it needs the network.
String? validateOnboardingStep(OnboardingState s, {DateTime? today}) {
  return switch (s.step) {
    OnboardingStep.basics =>
      ProfileRules.validateFullName(s.fullName) ??
          ProfileRules.validateUsername(s.username),
    OnboardingStep.details =>
      ProfileRules.validateDateOfBirth(s.dateOfBirth, today: today) ??
          (s.city.trim().isEmpty ? 'Enter your city' : null),
    OnboardingStep.positions =>
      s.primaryPosition == null ? 'Pick your main position' : null,
    OnboardingStep.game =>
      s.skillLevel == null ? 'Pick your skill level' : null,
    OnboardingStep.extras =>
      s.bio.length > ProfileRules.maxBioLength
          ? 'Bio is too long (${ProfileRules.maxBioLength} characters max)'
          : null,
  };
}
