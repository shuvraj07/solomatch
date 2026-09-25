import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/models/match_format.dart';
import '../../../shared/models/position_group.dart';
import '../../../shared/models/price.dart';
import '../../../shared/models/skill_level.dart';
import '../../../shared/models/user_summary.dart';
import '../../../shared/models/venue.dart';
import '../../match_report/domain/match_report.dart';
import '../domain/football_match.dart';
import '../domain/match_draft.dart';
import '../domain/match_status.dart';
import '../domain/position_slots.dart';

/// Converts matches and drafts to/from Firestore. Field names are the
/// contract documented in docs/firestore-schema.md.
abstract final class MatchMapper {
  // ---------- matches/{id} ----------

  static FootballMatch fromFirestore(String id, Map<String, dynamic> d) =>
      FootballMatch(
        id: id,
        organizer: userSummaryFrom(d['organizer'] as Map<String, dynamic>),
        title: d['title'] as String,
        venue: venueFrom(d['venue'] as Map<String, dynamic>),
        startAt: (d['startAt'] as Timestamp).toDate(),
        endAt: (d['endAt'] as Timestamp).toDate(),
        format: MatchFormat.fromName(d['format'] as String),
        maxPlayers: _int(d['maxPlayers']),
        currentPlayers: _int(d['currentPlayers']),
        slots: slotsFrom(d['slots'] as Map<String, dynamic>),
        skillLevel: SkillLevel.fromName(d['skillLevel'] as String),
        price: Price.fromJson(d['price'] as Map<String, dynamic>),
        isIndoor: d['isIndoor'] as bool? ?? false,
        description: d['description'] as String? ?? '',
        rules: d['rules'] as String? ?? '',
        photos: _strings(d['photos']),
        status: MatchStatus.fromName(d['status'] as String),
        createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
        votingClosesAt: (d['votingClosesAt'] as Timestamp?)?.toDate(),
        report: switch (d['report']) {
          final Map<String, dynamic> r => reportFrom(r),
          _ => null,
        },
        motm: switch (d['motm']) {
          final Map<String, dynamic> m => motmFrom(m),
          _ => null,
        },
      );

  static MatchReport reportFrom(Map<String, dynamic> r) => MatchReport(
    players: {
      for (final e
          in (r['players'] as Map<String, dynamic>? ?? const {}).entries)
        e.key: lineFrom(e.value as Map<String, dynamic>),
    },
    submittedAt: (r['submittedAt'] as Timestamp?)?.toDate(),
  );

  static PlayerMatchLine lineFrom(Map<String, dynamic> l) => PlayerMatchLine(
    goals: _int(l['goals']),
    assists: _int(l['assists']),
    yellowCards: _int(l['yellowCards']),
    redCard: l['redCard'] as bool? ?? false,
  );

  static Map<String, dynamic> lineTo(PlayerMatchLine l) => {
    'goals': l.goals,
    'assists': l.assists,
    'yellowCards': l.yellowCards,
    'redCard': l.redCard,
  };

  static MotmResult motmFrom(Map<String, dynamic> m) => MotmResult(
    winners: [
      for (final w in m['winners'] as List<Object?>? ?? const [])
        userSummaryFrom(w! as Map<String, dynamic>),
    ],
    votes: _int(m['votes']),
    totalVotes: _int(m['totalVotes']),
  );

  /// The document written when a draft is published.
  static Map<String, dynamic> newMatch(
    MatchDraft draft,
    UserSummary organizer,
  ) {
    final title = draft.title.trim();
    return {
      'organizer': userSummaryTo(organizer),
      'title': title,
      'searchTitle': title.toLowerCase(),
      'venue': venueTo(draft.venue!),
      'startAt': Timestamp.fromDate(draft.startAt!),
      'endAt': Timestamp.fromDate(draft.endAt!),
      'format': draft.format.name,
      'maxPlayers': draft.maxPlayers,
      'currentPlayers': 0,
      'spotsRemaining': draft.maxPlayers,
      'slots': slotsTo(draft.slots),
      'skillLevel': draft.skillLevel.name,
      'price': Price(amount: draft.priceAmount).toJson(),
      'isIndoor': draft.isIndoor,
      'description': draft.description.trim(),
      'rules': draft.rules.trim(),
      'photos': draft.photos,
      'status': MatchStatus.published.name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ---------- match_drafts/{id} ----------

  static MatchDraft draftFromFirestore(String id, Map<String, dynamic> d) {
    final venue = d['venue'] as Map<String, dynamic>?;
    final date = d['date'] as Timestamp?;
    final needed = d['neededPositions'] as Map<String, dynamic>? ?? const {};
    return MatchDraft(
      id: id,
      organizerId: d['organizerId'] as String,
      title: d['title'] as String? ?? '',
      venue: venue == null ? null : venueFrom(venue),
      date: date == null ? null : _calendarDate(date),
      startMinutes: (d['startMinutes'] as num?)?.toInt(),
      endMinutes: (d['endMinutes'] as num?)?.toInt(),
      format: MatchFormat.fromName(d['format'] as String? ?? 'fiveASide'),
      maxPlayers: (d['maxPlayers'] as num?)?.toInt() ?? 10,
      neededPositions: {
        for (final e in needed.entries)
          PositionGroup.fromName(e.key): _int(e.value),
      },
      skillLevel: SkillLevel.fromName(d['skillLevel'] as String? ?? 'any'),
      priceAmount: (d['priceAmount'] as num?)?.toInt() ?? 0,
      isIndoor: d['isIndoor'] as bool? ?? false,
      description: d['description'] as String? ?? '',
      rules: d['rules'] as String? ?? '',
      photos: _strings(d['photos']),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  static Map<String, dynamic> draftTo(MatchDraft d) {
    final venue = d.venue;
    final date = d.date;
    return {
      'organizerId': d.organizerId,
      'title': d.title,
      'venue': venue == null ? null : venueTo(venue),
      'date': date == null
          ? null
          : Timestamp.fromDate(DateTime.utc(date.year, date.month, date.day)),
      'startMinutes': d.startMinutes,
      'endMinutes': d.endMinutes,
      'format': d.format.name,
      'maxPlayers': d.maxPlayers,
      'neededPositions': {
        for (final e in d.neededPositions.entries) e.key.name: e.value,
      },
      'skillLevel': d.skillLevel.name,
      'priceAmount': d.priceAmount,
      'isIndoor': d.isIndoor,
      'description': d.description,
      'rules': d.rules,
      'photos': d.photos,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ---------- shared pieces ----------

  static Venue venueFrom(Map<String, dynamic> v) => Venue(
    name: v['name'] as String,
    address: v['address'] as String? ?? '',
    city: v['city'] as String,
    placeId: v['placeId'] as String?,
    lat: (v['lat'] as num?)?.toDouble(),
    lng: (v['lng'] as num?)?.toDouble(),
  );

  static Map<String, dynamic> venueTo(Venue v) => {
    'name': v.name.trim(),
    'address': v.address.trim(),
    'city': v.city.trim(),
    'placeId': v.placeId,
    'lat': v.lat,
    'lng': v.lng,
  };

  static UserSummary userSummaryFrom(Map<String, dynamic> u) => UserSummary(
    uid: u['uid'] as String,
    name: u['name'] as String,
    username: u['username'] as String,
    photoUrl: u['photoUrl'] as String?,
  );

  static Map<String, dynamic> userSummaryTo(UserSummary u) => {
    'uid': u.uid,
    'name': u.name,
    'username': u.username,
    'photoUrl': u.photoUrl,
  };

  static PositionSlots slotsFrom(Map<String, dynamic> s) => PositionSlots({
    for (final g in PositionGroup.values)
      if (s[g.name] case final Map<String, dynamic> c)
        g: (needed: _int(c['needed']), filled: _int(c['filled'])),
  });

  static Map<String, dynamic> slotsTo(PositionSlots slots) => {
    for (final g in PositionGroup.values)
      g.name: {'needed': slots[g].needed, 'filled': slots[g].filled},
  };

  static int _int(Object? v) => (v as num?)?.toInt() ?? 0;

  static List<String> _strings(Object? value) => [
    for (final item in value as List<Object?>? ?? const []) item as String,
  ];

  static DateTime _calendarDate(Timestamp ts) {
    final utc = ts.toDate().toUtc();
    return DateTime(utc.year, utc.month, utc.day);
  }
}
