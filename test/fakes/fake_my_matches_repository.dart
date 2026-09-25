import 'dart:async';

import 'package:solomatch/features/my_matches/domain/my_match_entry.dart';
import 'package:solomatch/features/my_matches/domain/my_matches_repository.dart';

class FakeMyMatchesRepository implements MyMatchesRepository {
  FakeMyMatchesRepository([this.entries = const []]);

  List<MyMatchEntry> entries;
  final _changes = StreamController<void>.broadcast();

  void set(List<MyMatchEntry> value) {
    entries = value;
    _changes.add(null);
  }

  @override
  Stream<List<MyMatchEntry>> watchMyMatches(String uid) async* {
    yield entries;
    yield* _changes.stream.map((_) => entries);
  }
}
