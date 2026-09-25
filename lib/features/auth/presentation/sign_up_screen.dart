import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/session/account_mode.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/error_snackbar.dart';
import '../../../core/widgets/loading_button.dart';
import 'auth_controller.dart';
import 'widgets/account_mode_toggle.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/auth_switch_prompt.dart';
import 'widgets/password_field.dart';
import 'widgets/social_sign_in_section.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(authControllerProvider.notifier)
        .signUpWithEmail(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (_, next) {
      if (next case AsyncError(:final error)) showErrorSnackBar(context, error);
    });
    final loading = ref.watch(authControllerProvider).isLoading;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    final owner = ref.watch(accountModeProvider) == AccountMode.owner;

    return AuthScaffold(
      title: owner ? 'List your venue' : 'Join the game',
      subtitle: owner
          ? 'Create a venue owner account so organizers can book your pitch.'
          : 'Create an account to find matches and fill your team.',
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AccountModeToggle(),
              TextFormField(
                key: const Key('emailField'),
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordField(
                key: const Key('passwordField'),
                controller: _password,
                validator: Validators.newPassword,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordField(
                key: const Key('confirmPasswordField'),
                controller: _confirm,
                label: 'Confirm password',
                autofillHints: const [AutofillHints.newPassword],
                validator: (value) =>
                    value != _password.text ? "Passwords don't match" : null,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.xl),
              LoadingButton(
                key: const Key('signUpButton'),
                label: 'Create account',
                loading: loading,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'By continuing you agree to the Terms and Community '
                'Guidelines.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: muted),
              ),
              SocialSignInSection(
                enabled: !loading,
                onGoogle: () => ref
                    .read(authControllerProvider.notifier)
                    .signInWithGoogle(),
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthSwitchPrompt(
                question: 'Already have an account?',
                action: 'Sign in',
                onPressed: () => context.go(AppRoutes.signIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
