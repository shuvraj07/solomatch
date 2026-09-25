import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which side of the app someone signs up for, picked on the sign-in and
/// sign-up screens. Decides which setup screen a new account sees. Existing
/// accounts always open their own side, whatever is picked.
enum AccountMode {
  player('Player'),
  owner('Venue owner');

  const AccountMode(this.label);

  final String label;
}

class AccountModeNotifier extends Notifier<AccountMode> {
  @override
  AccountMode build() => AccountMode.player;

  void select(AccountMode mode) => state = mode;
}

final accountModeProvider = NotifierProvider<AccountModeNotifier, AccountMode>(
  AccountModeNotifier.new,
);
