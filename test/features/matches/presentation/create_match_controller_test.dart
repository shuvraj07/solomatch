import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solomatch/app/session/session_provider.dart';
import 'package:solomatch/core/errors/app_failure.dart';
import 'package:solomatch/features/matches/data/match_providers.dart';
import 'package:solomatch/features/matches/domain/create_match_step.dart';
import 'package:solomatch/features/matches/domain/match_draft.dart';
import 'package:solomatch/features/matches/domain/match_status.dart';
import 'package:solomatch/features/matches/presentation/create_match/create_match_controller.dart';
import 'package:solomatch/features/matches/presentation/create_match/create_match_state.dart';

import '../../../fakes/fake_match_repository.dart';
import '../../../fakes/match_test_data.dart';
import '../../../fakes/test_data.dart';

void main() {
  late FakeMatchRepository repo;
  late ProviderContainer container;

  // The controller normally uses DateTime.now; pin it to testNow.
  final provider = NotifierProvider.autoDispose
      .family<CreateMatchController, CreateMatchState, MatchDraft>(
        (draft) => CreateMatchController(draft, now: () => testNow),
      );

  setUp(() {
    repo = FakeMatchRepository();
    container = ProviderContainer(
      overrides: [
        matchRepositoryProvider.overrideWithValue(repo),
        currentProfileProvider.overrideWithValue(testProfile()),
      ],
    );
  });
  tearDown(() => container.dispose());

  late MatchDraft current;

  CreateMatchController start(MatchDraft draft) {
    current = draft;
    container.listen(provider(draft), (_, _) {});
    return container.read(provider(draft).notifier);
  }

  CreateMatchState state() => container.read(provider(current));

  test('next() blocks on an invalid step and advances on a valid one', () {
    final c = start(const MatchDraft(id: 'd1', organizerId: 'raj'));
    expect(c.next, throwsA(isA<ValidationFailure>()));
    expect(state().step, CreateMatchStep.title);

    c.update((d) => d.copyWith(title: 'Friday Futsal'));
    c.next();
    expect(state().step, CreateMatchStep.venue);
    expect(state().dirty, isTrue);

    c.back();
    expect(state().step, CreateMatchStep.title);
  });

  test('saveDraft stores the draft and clears dirty', () async {
    final c = start(const MatchDraft(id: 'd1', organizerId: 'raj'));
    c.update((d) => d.copyWith(title: 'Friday Futsal'));
    await c.saveDraft();
    expect(repo.drafts['d1']?.title, 'Friday Futsal');
    expect(state().dirty, isFalse);
  });

  test('photos upload under the draft id and can be removed', () async {
    final c = start(completeDraft());
    await c.addPhoto(Uint8List(4));
    expect(state().draft.photos, hasLength(1));
    expect(repo.uploads, ['d1']);
    c.removePhoto(state().draft.photos.single);
    expect(state().draft.photos, isEmpty);
  });

  test('publish creates the match as the signed-in organizer', () async {
    final c = start(completeDraft());
    final id = await c.publish();

    final match = repo.matchOf(id)!;
    expect(match.status, MatchStatus.published);
    expect(match.organizer.uid, 'raj');
    expect(match.organizer.username, 'raj10');
    expect(match.currentPlayers, 0);
  });

  test('publish with missing fields jumps to the first bad step', () async {
    final c = start(completeDraft().copyWith(venue: null));
    c.goTo(CreateMatchStep.review);
    await expectLater(c.publish(), throwsA(isA<ValidationFailure>()));
    expect(state().step, CreateMatchStep.venue);
    expect(repo.matchOf('d1'), isNull);
  });
}
