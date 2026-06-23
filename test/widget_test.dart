import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:robo_app/main.dart';

void main() {
  testWidgets('Smoke test - App inicia corretamente',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RoboApp());

    // Verify that the app title is shown.
    expect(find.text('Motiva Robô'), findsOneWidget);
  });
}
