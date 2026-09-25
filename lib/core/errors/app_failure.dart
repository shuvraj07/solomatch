/// Domain-level error that repositories throw and the UI knows how to show.
///
/// Data-layer code maps Firebase exceptions into these so presentation code
/// never depends on Firebase error types.
sealed class AppFailure implements Exception {
  const AppFailure(this.message);

  /// Human-readable message, safe to show to the user.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure([
    super.message = 'Check your connection and try again.',
  ]);
}

final class PermissionFailure extends AppFailure {
  const PermissionFailure([
    super.message = "You don't have permission to do that.",
  ]);
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure([super.message = 'That item no longer exists.']);
}

/// A business rule rejected the action, e.g. "Match is full".
final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

final class AuthFailure extends AppFailure {
  const AuthFailure(super.message);
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure([
    super.message = 'Something went wrong. Please try again.',
  ]);
}
