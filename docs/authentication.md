# Authentication

## Supported methods

| Method | Status | Implemented in |
|---|---|---|
| Email + password | ✅ | `FirebaseAuthRepository.signInWithEmail` / `signUpWithEmail` |
| Forgot password | ✅ | `sendPasswordResetEmail` |
| Google | ✅ (needs console setup, below) | `signInWithGoogle` (google_sign_in 7 → Firebase credential) |
| Facebook | ⏳ waiting for a Facebook App ID and Client Token | — |
| Sign out | ✅ | `signOut` (also signs out of Google) |

Passwords are handled entirely by Firebase Auth. The app never stores or logs them.

## The session

```
authStateProvider (Stream<AuthUser?>)      playerProfileProvider(uid) (Stream<PlayerProfile?>)
              \                                 /
               └──────── sessionProvider ──────┘
                               │
        AsyncLoading | SignedOut | NeedsProfile(user) | Ready(user, profile)
                               │
                  GoRouter redirect (session_redirect.dart)
```

| Session | Allowed routes | Redirected to |
|---|---|---|
| loading / error | `/splash` | `/splash` |
| `SignedOut` | `/auth/*` | `/auth/sign-in` |
| `NeedsProfile` | `/onboarding` | `/onboarding` |
| `Ready` | everything except splash/auth/onboarding | `/home` |

Firebase persists the signed-in user between launches, so returning players go
straight from splash to Home. Screens never navigate after a sign-in or sign-out
themselves. The auth or profile stream changes, `sessionProvider` recomputes, and
the router's `refreshListenable` re-runs the redirect.

"Existing user" means a `players/{uid}` document exists. A new account, or one
that quit onboarding halfway, is sent to profile setup.

## Profile setup (onboarding)

`ProfileSetupScreen` has five steps: basics, details, positions, game, extras.
Its state lives in `OnboardingController` and is validated by
`validateOnboardingStep` (pure and unit-tested).

1. **Username** is checked for availability before leaving step 1.
2. **Finishing** runs one Firestore transaction that writes:
   - `usernames/{username}` → `{uid}` (the uniqueness claim)
   - `players/{uid}` (the public profile)
   - `users/{uid}` (private data: email)

   If someone else claimed the username in the meantime, the transaction fails
   and the user is sent back to step 1 with an inline error.
3. **Photo** (optional) is uploaded to `users/{uid}/profile/avatar.jpg` in Storage first.

Security rules require all three documents to be consistent. See
[firestore-schema.md](firestore-schema.md#security).

## Google Sign-In setup (Android)

1. Firebase console → Authentication → Sign-in method → **Google** → Enable.
2. Add the SHA-1 and SHA-256 of every signing key to the Android app in
   Project settings (see [firebase-setup.md](firebase-setup.md)).
3. Re-download the config so it includes the OAuth client:
   ```sh
   flutterfire configure --project=solomatch-26e58 --platforms=android --android-package-name=com.solomatch.app --yes
   ```
   Check that `oauth_client` in `android/app/google-services.json` is **not empty**.
   If it's empty, Google sign-in fails with "not configured for this build".

## Adding a provider

1. Add a method to `AuthRepository` and implement it in `FirebaseAuthRepository`
   by getting a provider credential and calling `signInWithCredential`.
2. Map provider-specific errors to `AuthFailure`.
3. Add a button to `SocialSignInSection` and an action to `AuthController`.
4. Add a case to `FakeAuthRepository` and a widget test.
