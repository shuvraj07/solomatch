import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/session/account_mode.dart';
import '../../../../app/session/session_provider.dart';
import '../../../../app/session/session_state.dart';
import '../../../../app/session/sign_out.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../../core/widgets/run_with_feedback.dart';
import '../../data/venue_providers.dart';
import '../../domain/venue_models.dart';
import '../widgets/venue_form.dart';

/// Setup for a new venue owner account: their contact and their venue.
/// Shown instead of the player profile setup when "Venue owner" was picked.
class OwnerSetupScreen extends ConsumerStatefulWidget {
  const OwnerSetupScreen({super.key});

  @override
  ConsumerState<OwnerSetupScreen> createState() => _OwnerSetupScreenState();
}

class _OwnerSetupScreenState extends ConsumerState<OwnerSetupScreen> {
  final _form = GlobalKey<FormState>();
  var _name = '';
  var _phone = '';
  var _venue = const VenueProfile(id: '', name: '', city: '', phone: '');
  var _saving = false;

  Future<void> _create() async {
    final session = ref.read(sessionProvider).value;
    if (session is! NeedsProfile) return;
    if (!_form.currentState!.validate()) return;
    if (_venue.formats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick at least one match size')),
      );
      return;
    }
    final uid = session.user.uid;
    setState(() => _saving = true);
    await runWithFeedback(
      context,
      () => ref
          .read(venueRepositoryProvider)
          .createOwner(
            OwnerProfile(uid: uid, name: _name, phone: _phone),
            _venue.copyWith(
              id: uid,
              phone: _venue.phone.trim().isEmpty ? _phone : _venue.phone,
            ),
          ),
    );
    // On success the session switches to the owner app by itself.
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set up your venue'),
        actions: [
          TextButton(
            onPressed: () => ref.read(signOutProvider)(),
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: [
            Text(
              'List your futsal or pitch so organizers can book free times '
              'right from the app.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('You', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              key: const Key('ownerNameInput'),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v ?? '').trim().length < 2 ? 'Enter your name' : null,
              onChanged: (v) => _name = v,
              decoration: const InputDecoration(
                labelText: 'Your name',
                prefixIcon: Icon(Icons.person_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              key: const Key('ownerPhoneInput'),
              keyboardType: TextInputType.phone,
              validator: validatePhone,
              onChanged: (v) => _phone = v,
              decoration: const InputDecoration(
                labelText: 'Your phone',
                prefixIcon: Icon(Icons.phone_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Your venue', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            VenueFormFields(
              venue: _venue,
              onChanged: (v) => setState(() => _venue = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            LoadingButton(
              key: const Key('createVenueButton'),
              label: 'Create venue',
              loading: _saving,
              onPressed: _create,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              key: const Key('switchToPlayerSetup'),
              onPressed: () => ref
                  .read(accountModeProvider.notifier)
                  .select(AccountMode.player),
              child: const Text('I’m a player, not a venue owner'),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
