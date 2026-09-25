import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../fakes/fake_auth_repository.dart';
import '../fakes/fake_profile_repository.dart';
import '../fakes/test_data.dart';
import '../helpers/pump_app.dart';

Future<void> pumpSignedIn(WidgetTester tester) => pumpApp(
  tester,
  auth: FakeAuthRepository(signedIn: testUser),
  profiles: FakeProfileRepository(profiles: [testProfile()]),
);

void main() {
  testWidgets('starts on Home', (tester) async {
    await pumpSignedIn(tester);
    expect(find.text('Find your next match ⚽'), findsOneWidget);
  });

  testWidgets('bottom navigation switches tabs', (tester) async {
    await pumpSignedIn(tester);

    await tester.tap(find.bySemanticsLabel('Discover'));
    await tester.pumpAndSettle();
    expect(find.text('Discover matches'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Messages'));
    await tester.pumpAndSettle();
    expect(find.text('No conversations yet'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Raj Shrestha'), findsOneWidget);
    expect(find.text('@raj10 · Kathmandu'), findsOneWidget);
  });

  testWidgets('Create Match button opens the create flow', (tester) async {
    await pumpSignedIn(tester);

    await tester.tap(find.byKey(const Key('createMatchButton')));
    await tester.pumpAndSettle();
    expect(find.text('Post a match'), findsOneWidget);
  });
}
