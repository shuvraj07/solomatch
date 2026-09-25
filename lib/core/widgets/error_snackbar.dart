import 'package:material_ui/material_ui.dart';

import '../errors/app_failure.dart';

/// User-facing text for any error: [AppFailure]s carry their own message,
/// anything else gets a generic one.
String errorMessage(Object error) =>
    error is AppFailure ? error.message : const UnknownFailure().message;

void showErrorSnackBar(BuildContext context, Object error) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(errorMessage(error))));
}
