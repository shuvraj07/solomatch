import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/match_card.dart';
import '../../../match_requests/domain/join_request.dart';
import '../../../matches/data/match_providers.dart';
import '../../domain/my_match_entry.dart';

/// One entry in My Matches. Watches the match itself so status, counts and
/// cancellations are always current; falls back to the stored snapshot
/// while loading.
class MyMatchTile extends ConsumerWidget {
  const MyMatchTile({super.key, required this.entry});

  final MyMatchEntry entry;

  String get _note => switch (entry) {
    MyMatchEntry(role: MyMatchRole.organizer) => '📋 You organize this match',
    MyMatchEntry(requestStatus: RequestStatus.accepted) => "⚽ You're playing",
    MyMatchEntry(requestStatus: RequestStatus.pending) => '⏳ Request pending',
    MyMatchEntry(requestStatus: RequestStatus.rejected) => 'Request declined',
    _ => 'Request withdrawn',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final match = ref.watch(matchProvider(entry.matchId)).value;
    void open() => context.push(AppRoutes.matchDetails(entry.matchId));

    if (match == null) {
      return Card(
        child: ListTile(
          onTap: open,
          title: Text(entry.title),
          subtitle: Text(
            '${Formatters.shortDate(entry.startAt)} · ${entry.venueName}\n$_note',
          ),
        ),
      );
    }
    return MatchCard(match: match, onTap: open, note: _note);
  }
}
