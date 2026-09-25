import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../core/widgets/placeholder_view.dart';
import '../../../core/widgets/run_with_feedback.dart';
import '../../live/data/live_repository.dart';
import '../../live/domain/live_models.dart';
import '../../match_requests/data/match_request_providers.dart';
import '../../matches/data/match_providers.dart';
import '../data/match_report_providers.dart';
import '../domain/match_report.dart';
import 'widgets/player_line_editor.dart';

/// Organizer enters goals, assists and cards for everyone who played.
/// Editable until Man of the Match voting closes.
class MatchReportScreen extends ConsumerStatefulWidget {
  const MatchReportScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<MatchReportScreen> createState() => _MatchReportScreenState();
}

class _MatchReportScreenState extends ConsumerState<MatchReportScreen> {
  /// Edited lines; seeded from the saved report the first time it loads.
  Map<String, PlayerMatchLine>? _lines;
  bool _saving = false;

  Future<void> _save() async {
    final lines = _lines;
    if (lines == null) return;
    setState(() => _saving = true);
    final ok = await runWithFeedback(
      context,
      () => ref.read(matchReportRepositoryProvider).saveReport(widget.matchId, {
        for (final e in lines.entries)
          if (!e.value.isEmpty) e.key: e.value,
      }),
      success: 'Match report saved ⚽',
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final match = ref.watch(matchProvider(widget.matchId)).value;
    final roster = ref.watch(rosterProvider(widget.matchId)).value;
    final events = ref.watch(liveEventsProvider(widget.matchId)).value;

    if (match == null || roster == null || events == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // First report: start from the goals and cards posted live.
    final lines = _lines ??= {
      ...(match.report?.players ?? LiveMatch.reportLines(events)),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Match report')),
      body: roster.isEmpty
          ? const PlaceholderView(
              icon: Icons.group_off_rounded,
              title: 'Nobody on the roster',
              message: 'There are no players to report on.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screen),
              itemCount: roster.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, i) {
                if (i == 0) {
                  return Text(
                    'Record what happened for each player. Totals appear on '
                    'their profiles. You can edit this until Man of the '
                    'Match voting closes.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
                }
                final player = roster[i - 1].player;
                return PlayerLineEditor(
                  player: player,
                  line: lines[player.uid] ?? const PlayerMatchLine(),
                  onChanged: (line) => setState(() => lines[player.uid] = line),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: LoadingButton(
            key: const Key('saveReportButton'),
            label: 'Save report',
            loading: _saving,
            onPressed: roster.isEmpty ? null : _save,
          ),
        ),
      ),
    );
  }
}
