import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/session/session_provider.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/run_with_feedback.dart';
import '../data/safety_providers.dart';
import '../domain/safety_repository.dart';

/// Report a player or a match. Reports go to the moderation queue; the
/// reported person isn't told who reported them.
Future<void> showReportSheet(
  BuildContext context, {
  required ReportTarget type,
  required String targetId,
  required String targetName,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) =>
      _ReportSheet(type: type, targetId: targetId, targetName: targetName),
);

class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({
    required this.type,
    required this.targetId,
    required this.targetName,
  });

  final ReportTarget type;
  final String targetId;
  final String targetName;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  ReportReason? _reason;
  final _details = TextEditingController();

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final me = ref.read(currentProfileProvider)?.uid;
    final reason = _reason;
    if (me == null || reason == null) return;
    final navigator = Navigator.of(context);
    final ok = await runWithFeedback(
      context,
      () => ref
          .read(safetyRepositoryProvider)
          .report(
            reporterId: me,
            type: widget.type,
            targetId: widget.targetId,
            targetName: widget.targetName,
            reason: reason,
            details: _details.text,
          ),
      success: 'Thanks. Our team will review this report.',
    );
    if (ok && mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.type == ReportTarget.player
                  ? 'Report ${widget.targetName}'
                  : 'Report this match',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            RadioGroup<ReportReason>(
              groupValue: _reason,
              onChanged: (r) => setState(() => _reason = r),
              child: Column(
                children: [
                  for (final r in ReportReason.values)
                    RadioListTile<ReportReason>(
                      key: Key('reason_${r.name}'),
                      contentPadding: EdgeInsets.zero,
                      value: r,
                      title: Text(r.label),
                    ),
                ],
              ),
            ),
            TextField(
              key: const Key('reportDetailsField'),
              controller: _details,
              maxLength: 500,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'What happened? (optional)',
              ),
            ),
            FilledButton(
              key: const Key('submitReportButton'),
              onPressed: _reason == null ? null : _submit,
              child: const Text('Send report'),
            ),
          ],
        ),
      ),
    );
  }
}
