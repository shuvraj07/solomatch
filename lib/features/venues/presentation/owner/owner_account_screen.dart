import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/session/session_provider.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/run_with_feedback.dart';
import '../../../../shared/widgets/player_avatar.dart';
import '../../data/venue_providers.dart';
import '../../domain/venue_models.dart';
import '../widgets/venue_form.dart';

/// The owner's contact details, plus settings.
class OwnerAccountScreen extends ConsumerWidget {
  const OwnerAccountScreen({super.key});

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    OwnerProfile o,
  ) async {
    final updated = await showDialog<OwnerProfile>(
      context: context,
      builder: (_) => _EditOwnerDialog(owner: o),
    );
    if (updated == null || !context.mounted) return;
    await runWithFeedback(
      context,
      () => ref.read(venueRepositoryProvider).updateOwner(updated),
      success: 'Saved',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owner = ref.watch(currentOwnerProvider);
    if (owner == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        children: [
          ListTile(
            leading: PlayerAvatar(name: owner.name, radius: 24),
            title: Text(owner.name, style: theme.textTheme.titleMedium),
            subtitle: Text('Venue owner · ${owner.phone}'),
            trailing: IconButton(
              key: const Key('editOwnerButton'),
              tooltip: 'Edit',
              onPressed: () => _edit(context, ref, owner),
              icon: const Icon(Icons.edit_rounded),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            onTap: () => context.push(AppRoutes.notifications),
          ),
          ListTile(
            key: const Key('ownerSettingsTile'),
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            subtitle: const Text('Alerts, terms, sign out, delete account'),
            onTap: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
    );
  }
}

class _EditOwnerDialog extends StatefulWidget {
  const _EditOwnerDialog({required this.owner});

  final OwnerProfile owner;

  @override
  State<_EditOwnerDialog> createState() => _EditOwnerDialogState();
}

class _EditOwnerDialogState extends State<_EditOwnerDialog> {
  final _form = GlobalKey<FormState>();
  late var _name = widget.owner.name;
  late var _phone = widget.owner.phone;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Your details'),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _name,
              validator: (v) =>
                  (v ?? '').trim().length < 2 ? 'Enter your name' : null,
              onChanged: (v) => _name = v,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              initialValue: _phone,
              keyboardType: TextInputType.phone,
              validator: validatePhone,
              onChanged: (v) => _phone = v,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_form.currentState!.validate()) {
              Navigator.pop(
                context,
                widget.owner.copyWith(name: _name, phone: _phone),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
