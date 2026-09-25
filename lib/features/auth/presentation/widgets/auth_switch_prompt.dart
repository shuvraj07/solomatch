import 'package:material_ui/material_ui.dart';

/// "New to SoloMatch? Create account" footer. Wraps onto two lines on
/// narrow screens or with large text instead of overflowing.
class AuthSwitchPrompt extends StatelessWidget {
  const AuthSwitchPrompt({
    super.key,
    required this.question,
    required this.action,
    required this.onPressed,
  });

  final String question;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(question),
        TextButton(onPressed: onPressed, child: Text(action)),
      ],
    );
  }
}
