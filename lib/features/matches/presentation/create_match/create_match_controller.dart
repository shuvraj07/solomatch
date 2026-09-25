import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/session/session_provider.dart';
import '../../../../core/errors/app_failure.dart';
import '../../data/match_providers.dart';
import '../../domain/create_match_step.dart';
import '../../domain/match_draft.dart';
import '../../domain/match_validator.dart';
import 'create_match_state.dart';

/// Drives the multi-step create flow for one draft.
///
/// Methods throw [AppFailure]s with user-facing messages; the screen shows
/// them. [now] is injectable so tests control "the current time".
class CreateMatchController extends Notifier<CreateMatchState> {
  CreateMatchController(this._initial, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final MatchDraft _initial;
  final DateTime Function() _now;

  @override
  CreateMatchState build() => CreateMatchState(draft: _initial);

  void update(MatchDraft Function(MatchDraft d) change) {
    state = state.copyWith(draft: change(state.draft), dirty: true);
  }

  bool _skip(CreateMatchStep s) =>
      state.draft.booking != null && s.setByBooking;

  void back() {
    var previous = state.step.previous;
    while (previous != null && _skip(previous)) {
      previous = previous.previous;
    }
    if (previous != null) state = state.copyWith(step: previous);
  }

  void goTo(CreateMatchStep step) => state = state.copyWith(step: step);

  /// Validates the current step, then advances.
  void next() {
    final problem = MatchValidator.validateStep(
      state.step,
      state.draft,
      now: _now(),
    );
    if (problem != null) throw ValidationFailure(problem);
    var next = state.step.next;
    while (next != null && _skip(next)) {
      next = next.next;
    }
    if (next != null) state = state.copyWith(step: next);
  }

  Future<void> saveDraft() => _busy(() async {
    await ref.read(matchRepositoryProvider).saveDraft(state.draft);
    if (ref.mounted) state = state.copyWith(dirty: false);
  });

  Future<void> addPhoto(Uint8List bytes) => _busy(() async {
    if (state.draft.photos.length >= MatchValidator.maxPhotos) {
      throw const ValidationFailure('Up to ${MatchValidator.maxPhotos} photos');
    }
    final url = await ref
        .read(matchRepositoryProvider)
        .uploadMatchPhoto(
          organizerId: state.draft.organizerId,
          matchId: state.draft.id,
          bytes: bytes,
        );
    if (ref.mounted) {
      update((d) => d.copyWith(photos: [...d.photos, url]));
    }
  });

  void removePhoto(String url) => update(
    (d) => d.copyWith(
      photos: [
        for (final p in d.photos)
          if (p != url) p,
      ],
    ),
  );

  /// Publishes and returns the new match's ID. If something is missing,
  /// jumps to that step and throws.
  Future<String> publish() async {
    final draft = state.draft;
    final invalid = MatchValidator.firstInvalidStep(draft, now: _now());
    if (invalid != null) {
      state = state.copyWith(step: invalid);
      throw ValidationFailure(
        MatchValidator.validateStep(invalid, draft, now: _now())!,
      );
    }
    if (ref.read(currentProfileProvider) == null) {
      throw const AuthFailure('You are signed out.');
    }

    await _busy(() => ref.read(matchRepositoryProvider).publish(draft));
    if (ref.mounted) state = state.copyWith(dirty: false);
    return draft.id;
  }

  Future<void> _busy(Future<void> Function() action) async {
    if (state.busy) return;
    state = state.copyWith(busy: true);
    try {
      await action();
    } finally {
      if (ref.mounted) state = state.copyWith(busy: false);
    }
  }
}

/// One controller per draft being edited.
final createMatchControllerProvider = NotifierProvider.autoDispose
    .family<CreateMatchController, CreateMatchState, MatchDraft>(
      CreateMatchController.new,
    );
