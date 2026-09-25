import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solomatch/app/app.dart';

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: SoloMatchApp()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('starts on Home', (tester) async {
    await pumpApp(tester);
    expect(find.text('Find your next match ⚽'), findsOneWidget);
  });

  testWidgets('bottom navigation switches tabs', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.bySemanticsLabel('Discover'));
    await tester.pumpAndSettle();
    expect(find.text('Discover matches'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Messages'));
    await tester.pumpAndSettle();
    expect(find.text('No conversations yet'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Your football profile'), findsOneWidget);
  });

  testWidgets('Create Match button opens the create flow', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('createMatchButton')));
    await tester.pumpAndSettle();
    expect(find.text('Post a match'), findsOneWidget);
  });
}
