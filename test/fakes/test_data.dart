import 'package:solomatch/features/auth/domain/auth_user.dart';
import 'package:solomatch/features/profile/domain/player_profile.dart';
import 'package:solomatch/shared/models/position.dart';
import 'package:solomatch/shared/models/preferred_foot.dart';
import 'package:solomatch/shared/models/skill_level.dart';

const testUser = AuthUser(uid: 'raj', email: 'raj@example.com');

PlayerProfile testProfile({
  String uid = 'raj',
  String username = 'raj10',
  String fullName = 'Raj Shrestha',
}) => PlayerProfile(
  uid: uid,
  fullName: fullName,
  username: username,
  dateOfBirth: DateTime(1998, 5, 12),
  city: 'Kathmandu',
  primaryPosition: Position.centralMidfielder,
  secondaryPositions: const [Position.attackingMidfielder],
  skillLevel: SkillLevel.intermediate,
  preferredFoot: PreferredFoot.right,
);
