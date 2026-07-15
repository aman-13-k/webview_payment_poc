import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newprj1/main.dart';

void main() {
  testWidgets('Bottom Navigation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // 1. Verify Main Screen with Bottom Navigation is shown immediately
    expect(find.text('Shop'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Shop'), findsNWidgets(2)); // AppBar + Nav Label
    expect(find.text('Rewards'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // 2. Test Navigation to Rewards
    await tester.tap(find.text('Rewards'));
    await tester.pumpAndSettle();
    expect(find.text('Your Rewards'), findsOneWidget);
    expect(find.text('Rewards'), findsNWidgets(2));

    // 3. Test Navigation to Profile
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('User Profile'), findsOneWidget);
    expect(find.text('Profile'), findsNWidgets(2));
  });
}
