import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/error_snackbar.dart';
import '../../../core/widgets/loading_button.dart';
import 'auth_controller.dart';
import 'widgets/auth_scaffold.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  String? _sentTo;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _email.text.trim();
    final sent = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(email);
    if (sent && mounted) setState(() => _sentTo = email);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (_, next) {
      if (next case AsyncError(:final error)) showErrorSnackBar(context, error);
    });
    final loading = ref.watch(authControllerProvider).isLoading;
    final sentTo = _sentTo;

    return AuthScaffold(
      showBack: true,
      title: 'Reset password',
      subtitle: sentTo == null
          ? "Enter your email and we'll send you a reset link."
          // Same wording whether or not the account exists, so this screen
          // can't be used to discover registered emails.
          : 'If an account exists for $sentTo, a reset link is on its way. '
                'Check your inbox and spam folder.',
      child: sentTo != null
          ? FilledButton(
              onPressed: () => context.pop(),
              child: const Text('Back to sign in'),
            )
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    key: const Key('emailField'),
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: Validators.email,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  LoadingButton(
                    key: const Key('sendResetButton'),
                    label: 'Send reset link',
                    loading: loading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
    );
  }
}
