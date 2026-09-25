import 'package:material_ui/material_ui.dart';

import 'error_snackbar.dart';

/// Runs [action]; shows [success] (if given) or the error in a snackbar.
/// Returns true on success.
Future<bool> runWithFeedback(
  BuildContext context,
  Future<void> Function() action, {
  String? success,
}) async {
  try {
    await action();
  } on Object catch (e) {
    if (context.mounted) showErrorSnackBar(context, e);
    return false;
  }
  if (success != null && context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(success)));
  }
  return true;
}
