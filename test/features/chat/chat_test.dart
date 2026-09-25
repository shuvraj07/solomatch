import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solomatch/features/chat/domain/chat_models.dart';
import 'package:solomatch/features/match_requests/data/match_request_mapper.dart';
import 'package:solomatch/features/match_requests/domain/roster_entry.dart';
import 'package:solomatch/shared/models/position_group.dart';

import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_chat_repository.dart';
import '../../fakes/fake_match_repository.dart';
import '../../fakes/fake_match_request_repository.dart';
import '../../fakes/fake_profile_repository.dart';
import '../../fakes/match_test_data.dart';
import '../../fakes/test_data.dart';
import '../../helpers/pump_app.dart';

final amit = testProfile(uid: 'amit', username: 'amit', fullName: 'Amit Karki');

Conversation groupChat({Map<String, DateTime> readAt = const {}}) =>
    Conversation(
      id: 'match_m1',
      type: ConversationType.group,
      matchId: 'm1',
      title: 'Saturday Night Football',
      participantIds: const ['raj', 'amit', 'sita'],
      participants: const {
        'raj': ChatMember(name: 'Raj Shrestha'),
        'amit': ChatMember(name: 'Amit Karki'),
        'sita': ChatMember(name: 'Sita Rai'),
      },
      readAt: readAt,
    );

void main() {
  group('Conversation', () {
    test('unread only when someone else wrote after my last read', () {
      final t = DateTime(2026, 9, 25, 18);
      final c = groupChat().copyWith(
        lastMessageText: 'hi',
        lastMessageSenderId: 'sita',
        lastMessageAt: t,
      );
      expect(c.isUnreadFor('amit'), isTrue);
      expect(c.copyWith(readAt: {'amit': t}).isUnreadFor('amit'), isFalse);
      expect(c.isUnreadFor('sita'), isFalse); // own message
    });

    test('private chat name is the other person; seenBy excludes me', () {
      const dm = Conversation(
        id: 'dm_m1_amit',
        type: ConversationType.direct,
        matchId: 'm1',
        title: 'Saturday Night Football',
        participantIds: ['raj', 'amit'],
        participants: {
          'raj': ChatMember(name: 'Raj Shrestha'),
          'amit': ChatMember(name: 'Amit Karki'),
        },
      );
      expect(dm.displayName('amit'), 'Raj Shrestha');
      expect(dm.displayName('raj'), 'Amit Karki');
      final t = DateTime(2026, 9, 25);
      expect(dm.copyWith(readAt: {'raj': t, 'amit': t}).seenBy(t, 'amit'), 1);
    });
  });

  group('screens', () {
    late FakeChatRepository chat;
    late FakeMatchRepository matches;
    late FakeMatchRequestRepository requests;

    setUp(() {
      chat = FakeChatRepository([groupChat()]);
      matches = FakeMatchRepository(matches: [testMatch(currentPlayers: 1)]);
      requests = FakeMatchRequestRepository(matches);
    });

    Future<void> pumpAs(WidgetTester tester, String uid) => pumpApp(
      tester,
      auth: FakeAuthRepository(signedIn: testUser.copyWith(uid: uid)),
      profiles: FakeProfileRepository(
        profiles: [
          testProfile(),
          amit,
          testProfile(uid: 'sita', username: 'sita', fullName: 'Sita Rai'),
        ],
      ),
      matches: matches,
      requests: requests,
      chat: chat,
    );

    testWidgets('Messages tab: live list, unread badge and dot', (
      tester,
    ) async {
      await pumpAs(tester, 'amit');
      await tester.tapVisible(find.bySemanticsLabel('Messages'));
      expect(find.text('Saturday Night Football'), findsOneWidget);
      expect(find.text('Say hi to your teammates 👋'), findsOneWidget);

      chat.receive('match_m1', 'sita', 'Who has the ball?');
      await tester.pumpAndSettle();
      expect(find.text('Sita Rai: Who has the ball?'), findsNothing);
      expect(find.text('Who has the ball?'), findsOneWidget);
      expect(find.byKey(const Key('unreadDot_match_m1')), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // tab badge
    });

    testWidgets('chat: send, receive live, read receipts, marks read', (
      tester,
    ) async {
      chat.receive('match_m1', 'sita', 'Who has the ball?');
      await pumpAs(tester, 'amit');
      await tester.tapVisible(find.bySemanticsLabel('Messages'));
      await tester.tapVisible(find.byKey(const Key('conversation_match_m1')));

      // Opening the chat moved my read marker → no longer unread.
      expect(chat.conversation('match_m1')!.isUnreadFor('amit'), isFalse);
      expect(find.text('Who has the ball?'), findsOneWidget);
      expect(find.text('Sita Rai'), findsOneWidget); // sender label in group

      await tester.enterText(find.byKey(const Key('chatInput')), 'I do ⚽');
      await tester.tap(find.byKey(const Key('sendButton')));
      await tester.pumpAndSettle();
      expect(find.text('I do ⚽'), findsOneWidget);
      expect(chat.messagesOf('match_m1').last.senderId, 'amit');

      // Two teammates read it.
      chat
        ..readBy('match_m1', 'sita')
        ..readBy('match_m1', 'raj');
      await tester.pumpAndSettle();
      expect(find.textContaining('Seen by 2'), findsOneWidget);

      // A reply arrives while the chat is open.
      chat.receive('match_m1', 'raj', 'See you at 6');
      await tester.pumpAndSettle();
      expect(find.text('See you at 6'), findsOneWidget);
      expect(chat.conversation('match_m1')!.isUnreadFor('amit'), isFalse);
    });

    testWidgets('match page: group chat for roster, message organizer', (
      tester,
    ) async {
      requests.seedRoster('m1', [
        RosterEntry(
          player: MatchRequestMapper.cardFromProfile(amit),
          group: PositionGroup.mid,
        ),
      ]);
      await requests.requestToJoin(
        match: matches.matchOf('m1')!,
        player: amit,
        preferredGroup: PositionGroup.mid,
      );
      chat.directAllowed['m1'] = {'amit'};

      await pumpAs(tester, 'amit');
      await tester.tapVisible(find.text('⚽ Saturday Night Football'));
      expect(find.byKey(const Key('groupChatButton')), findsOneWidget);

      await tester.tapVisible(find.byKey(const Key('messageOrganizerButton')));
      expect(chat.conversation('dm_m1_amit'), isNotNull);
      expect(find.text('Raj Shrestha'), findsOneWidget); // chat title
      expect(find.text('Start the conversation 👋'), findsOneWidget);
    });

    testWidgets('no chat buttons for someone not involved', (tester) async {
      await pumpAs(tester, 'sita');
      await tester.tapVisible(find.text('⚽ Saturday Night Football'));
      expect(find.byKey(const Key('groupChatButton')), findsNothing);
      expect(find.byKey(const Key('messageOrganizerButton')), findsNothing);
    });
  });
}
