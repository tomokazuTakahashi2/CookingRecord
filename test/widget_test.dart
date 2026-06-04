// Basic widget smoke test.
//
// The full app depends on sqflite (a platform channel) which isn't available
// in the default test environment, so this verifies a self-contained widget
// renders correctly instead of pumping the whole app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a basic widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Text('自炊記録')),
      ),
    );

    expect(find.text('自炊記録'), findsOneWidget);
  });
}
