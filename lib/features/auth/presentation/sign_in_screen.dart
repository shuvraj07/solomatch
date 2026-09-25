import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/error_snackbar.dart';
import '../../../core/widgets/loading_button.dart';
import 'auth_controller.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/auth_switch_prompt.dart';
import 'widgets/password_field.dart';
import 'widgets/social_sign_in_section.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(authControllerProvider.notifier)
        .signInWithEmail(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (_, next) {
      if (next case AsyncError(:final error)) showErrorSnackBar(context, error);
    });
    final loading = ref.watch(authControllerProvider).isLoading;

    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to find your next match.',
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                validator: Validators.requiredPassword,
                onSubmitted: (_) => _submit(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(AppRoutes.forgotPassword),
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              LoadingButton(
                key: const Key('signInButton'),
                label: 'Sign in',
                loading: loading,
                onPressed: _submit,
              ),
              SocialSignInSection(
                enabled: !loading,
                onGoogle: () => ref
                    .read(authControllerProvider.notifier)
                    .signInWithGoogle(),
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthSwitchPrompt(
                question: 'New to SoloMatch?',
                action: 'Create account',
                onPressed: () => context.go(AppRoutes.signUp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
