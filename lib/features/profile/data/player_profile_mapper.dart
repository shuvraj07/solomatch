import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/models/availability.dart';
import '../../../shared/models/position.dart';
import '../../../shared/models/preferred_foot.dart';
import '../../../shared/models/skill_level.dart';
import '../domain/player_profile.dart';
import '../domain/player_stats.dart';

/// Converts between [PlayerProfile] and the `players/{uid}` document.
/// Field names here are the contract documented in docs/firestore-schema.md.
abstract final class PlayerProfileMapper {
  static PlayerProfile fromFirestore(String uid, Map<String, dynamic> data) {
    final stats = data['stats'] as Map<String, dynamic>? ?? const {};
    return PlayerProfile(
      uid: uid,
      fullName: data['fullName'] as String,
      username: data['username'] as String,
      photoUrl: data['photoUrl'] as String?,
      dateOfBirth: _calendarDate(data['dateOfBirth'] as Timestamp),
      city: data['city'] as String,
      bio: data['bio'] as String? ?? '',
      primaryPosition: Position.fromName(data['primaryPosition'] as String),
      secondaryPositions: [
        for (final name in _strings(data['secondaryPositions']))
          Position.fromName(name),
      ],
      skillLevel: SkillLevel.fromName(data['skillLevel'] as String),
      preferredFoot: PreferredFoot.values.byName(
        data['preferredFoot'] as String,
      ),
      heightCm: (data['heightCm'] as num?)?.toInt(),
      yearsPlaying: (data['yearsPlaying'] as num?)?.toInt() ?? 0,
      languages: _strings(data['languages']),
      availability: Availability.fromStrings(_strings(data['availability'])),
      stats: PlayerStats(
        gamesPlayed: (stats['gamesPlayed'] as num?)?.toInt() ?? 0,
        gamesOrganized: (stats['gamesOrganized'] as num?)?.toInt() ?? 0,
        ratingAvg: (stats['ratingAvg'] as num?)?.toDouble() ?? 0,
        ratingCount: (stats['ratingCount'] as num?)?.toInt() ?? 0,
        goals: (stats['goals'] as num?)?.toInt() ?? 0,
        assists: (stats['assists'] as num?)?.toInt() ?? 0,
        yellowCards: (stats['yellowCards'] as num?)?.toInt() ?? 0,
        redCards: (stats['redCards'] as num?)?.toInt() ?? 0,
        motmAwards: (stats['motmAwards'] as num?)?.toInt() ?? 0,
      ),
    );
  }

  /// Fields a player may write. Excludes `stats` (server-only) and
  /// `username` (only set on creation, together with its claim).
  static Map<String, dynamic> editableFields(PlayerProfile p) => {
    'fullName': p.fullName.trim(),
    'searchName': p.fullName.trim().toLowerCase(),
    'photoUrl': p.photoUrl,
    'dateOfBirth': Timestamp.fromDate(
      DateTime.utc(p.dateOfBirth.year, p.dateOfBirth.month, p.dateOfBirth.day),
    ),
    'city': p.city.trim(),
    'bio': p.bio.trim(),
    'primaryPosition': p.primaryPosition.name,
    'secondaryPositions': [for (final s in p.secondaryPositions) s.name],
    'skillLevel': p.skillLevel.name,
    'preferredFoot': p.preferredFoot.name,
    'heightCm': p.heightCm,
    'yearsPlaying': p.yearsPlaying,
    'languages': p.languages,
    'availability': p.availability.toStrings(),
  };

  /// Birthdays are stored as UTC midnight; read them back as a local
  /// calendar date so the day never shifts with the device time zone.
  static DateTime _calendarDate(Timestamp ts) {
    final utc = ts.toDate().toUtc();
    return DateTime(utc.year, utc.month, utc.day);
  }

  static List<String> _strings(Object? value) => [
    for (final item in value as List<Object?>? ?? const []) item as String,
  ];
}
