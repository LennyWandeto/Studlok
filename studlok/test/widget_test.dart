import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studlok/main.dart';

void main() {
  testWidgets('app shows a loading state on launch while the routing decision resolves', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StudlokApp());

    // AppRouter awaits native bridge calls to decide where to land; there's
    // no platform channel in a widget test, so it stays on this loading
    // state rather than resolving — which is exactly what should render on
    // the very first frame regardless.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
