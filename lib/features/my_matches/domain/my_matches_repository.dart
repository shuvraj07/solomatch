import 'my_match_entry.dart';

abstract interface class MyMatchesRepository {
  /// Live list of matches the user organizes or has asked to join.
  Stream<List<MyMatchEntry>> watchMyMatches(String uid);
}
