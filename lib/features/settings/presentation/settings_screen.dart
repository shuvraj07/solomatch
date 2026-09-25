import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/session/session_provider.dart';
import '../../../app/session/sign_out.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/run_with_feedback.dart';
import '../../auth/data/auth_providers.dart';
import '../../profile/data/profile_providers.dart';
import '../data/settings_providers.dart';
import '../domain/settings_repository.dart';
import 'info_pages.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _DeleteAccountDialog(),
    );
    if (confirmed != true || !context.mounted) return;
    final ok = await runWithFeedback(
      context,
      () => ref.read(settingsRepositoryProvider).deleteAccount(),
    );
    // The login no longer exists; clear the local session.
    if (ok) await ref.read(authRepositoryProvider).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final user = ref.watch(authRepositoryProvider).currentUser;
    final prefs = ref.watch(notificationPrefsProvider).value;
    final theme = Theme.of(context);

    Widget section(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          section('Account'),
          ListTile(
            leading: const Icon(Icons.mail_outline_rounded),
            title: const Text('Email'),
            subtitle: Text(user?.email ?? '—'),
          ),
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: const Text('Edit football profile'),
            onTap: () => context.push(AppRoutes.editProfile),
          ),
          if (user?.email case final email?)
            ListTile(
              leading: const Icon(Icons.lock_reset_rounded),
              title: const Text('Change password'),
              subtitle: const Text('We’ll email you a reset link'),
              onTap: () => runWithFeedback(
                context,
                () => ref
                    .read(authRepositoryProvider)
                    .sendPasswordResetEmail(email),
                success: 'Password reset email sent to $email',
              ),
            ),
          section('Notifications'),
          for (final c in NotificationCategory.values)
            SwitchListTile(
              key: Key('pref_${c.name}'),
              title: Text(c.label),
              subtitle: Text(c.description),
              value: prefs?[c] ?? true,
              onChanged: profile == null
                  ? null
                  : (v) => runWithFeedback(
                      context,
                      () => ref
                          .read(settingsRepositoryProvider)
                          .setNotificationPref(profile.uid, c, v),
                    ),
            ),
          section('Privacy & safety'),
          if (profile != null)
            SwitchListTile(
              key: const Key('hideCitySwitch'),
              title: const Text('Hide my city'),
              subtitle: const Text('Other players won’t see where you live'),
              value: profile.hideCity,
              onChanged: (v) => runWithFeedback(
                context,
                () => ref
                    .read(profileRepositoryProvider)
                    .updateProfile(profile.copyWith(hideCity: v)),
              ),
            ),
          ListTile(
            key: const Key('blockedPlayersTile'),
            leading: const Icon(Icons.block_rounded),
            title: const Text('Blocked players'),
            onTap: () => context.push(AppRoutes.blockedPlayers),
          ),
          for (final page in InfoPage.values)
            ListTile(
              leading: Icon(switch (page) {
                InfoPage.guidelines => Icons.shield_outlined,
                InfoPage.terms => Icons.description_outlined,
                InfoPage.privacy => Icons.privacy_tip_outlined,
                InfoPage.help => Icons.help_outline_rounded,
              }),
              title: Text(page.title),
              onTap: () => context.push(AppRoutes.infoPage(page.name)),
            ),
          section('Session'),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Sign out'),
            onTap: () => ref.read(signOutProvider)(),
          ),
          ListTile(
            key: const Key('deleteAccountTile'),
            leading: Icon(
              Icons.delete_forever_rounded,
              color: theme.colorScheme.error,
            ),
            title: Text(
              'Delete account',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => _deleteAccount(context, ref),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ready = _confirm.text.trim().toUpperCase() == 'DELETE';
    return AlertDialog(
      title: const Text('Delete your account?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This permanently deletes your profile, photos and settings. '
            'You’ll leave upcoming matches, and matches you organize will be '
            'cancelled. Past matches, messages and ratings you gave stay, '
            'shown as “Deleted player”. This can’t be undone.',
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            key: const Key('deleteConfirmField'),
            controller: _confirm,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Type DELETE to confirm',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Keep account'),
        ),
        FilledButton(
          key: const Key('confirmDeleteButton'),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            minimumSize: const Size(0, 44),
          ),
          onPressed: ready ? () => Navigator.pop(context, true) : null,
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
