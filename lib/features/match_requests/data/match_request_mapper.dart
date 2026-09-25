import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/models/player_card.dart';
import '../../../shared/models/position.dart';
import '../../../shared/models/position_group.dart';
import '../../../shared/models/skill_level.dart';
import '../../matches/domain/football_match.dart';
import '../../profile/domain/player_profile.dart';
import '../domain/join_request.dart';
import '../domain/roster_entry.dart';

/// Firestore ⇄ requests / roster. The player card and match snapshot
/// written here must satisfy `validNewRequest` in firestore.rules.
abstract final class MatchRequestMapper {
  static PlayerCard cardFrom(Map<String, dynamic> p) => PlayerCard(
    uid: p['uid'] as String,
    name: p['name'] as String,
    username: p['username'] as String,
    photoUrl: p['photoUrl'] as String?,
    primaryPosition: Position.fromName(p['primaryPosition'] as String),
    secondaryPositions: [
      for (final s in p['secondaryPositions'] as List<Object?>? ?? const [])
        Position.fromName(s! as String),
    ],
    skillLevel: SkillLevel.fromName(p['skillLevel'] as String),
    ratingAvg: (p['ratingAvg'] as num?)?.toDouble() ?? 0,
    ratingCount: (p['ratingCount'] as num?)?.toInt() ?? 0,
    gamesPlayed: (p['gamesPlayed'] as num?)?.toInt() ?? 0,
  );

  static PlayerCard cardFromProfile(PlayerProfile p) => PlayerCard(
    uid: p.uid,
    name: p.fullName,
    username: p.username,
    photoUrl: p.photoUrl,
    primaryPosition: p.primaryPosition,
    secondaryPositions: p.secondaryPositions,
    skillLevel: p.skillLevel,
    ratingAvg: p.stats.ratingAvg,
    ratingCount: p.stats.ratingCount,
    gamesPlayed: p.stats.gamesPlayed,
  );

  static Map<String, dynamic> cardTo(PlayerCard c) => {
    'uid': c.uid,
    'name': c.name,
    'username': c.username,
    'photoUrl': c.photoUrl,
    'primaryPosition': c.primaryPosition.name,
    'secondaryPositions': [for (final s in c.secondaryPositions) s.name],
    'skillLevel': c.skillLevel.name,
    'ratingAvg': c.ratingAvg,
    'ratingCount': c.ratingCount,
    'gamesPlayed': c.gamesPlayed,
  };

  static JoinRequest requestFrom(String matchId, Map<String, dynamic> d) {
    final assigned = d['assignedGroup'] as String?;
    return JoinRequest(
      matchId: matchId,
      player: cardFrom(d['player'] as Map<String, dynamic>),
      preferredGroup: PositionGroup.fromName(d['preferredGroup'] as String),
      message: d['message'] as String? ?? '',
      status: RequestStatus.fromName(d['status'] as String),
      assignedGroup: assigned == null ? null : PositionGroup.fromName(assigned),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  static Map<String, dynamic> newRequest({
    required FootballMatch match,
    required PlayerProfile player,
    required PositionGroup preferredGroup,
    required String message,
  }) => {
    'status': RequestStatus.pending.name,
    'player': cardTo(cardFromProfile(player)),
    'preferredGroup': preferredGroup.name,
    'message': message.trim(),
    'match': {
      'title': match.title,
      'startAt': Timestamp.fromDate(match.startAt),
      'venueName': match.venue.name,
    },
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  static RosterEntry rosterFrom(Map<String, dynamic> d) => RosterEntry(
    player: cardFrom(d['player'] as Map<String, dynamic>),
    group: PositionGroup.fromName(d['group'] as String),
    joinedAt: (d['joinedAt'] as Timestamp?)?.toDate(),
  );
}
