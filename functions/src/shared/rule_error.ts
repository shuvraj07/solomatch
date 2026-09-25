/**
 * A business-rule failure with a user-facing message. Callable wrappers
 * turn it into an HttpsError with the same code, which the app maps to a
 * failure shown to the user.
 */
export type RuleErrorCode =
  | 'invalid-argument'
  | 'not-found'
  | 'permission-denied'
  | 'failed-precondition';

export class RuleError extends Error {
  constructor(
    readonly code: RuleErrorCode,
    message: string,
  ) {
    super(message);
  }
}
