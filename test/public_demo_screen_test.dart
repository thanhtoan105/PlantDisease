import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_ai_disease_flutter/features/public_demo/screens/public_demo_screen.dart';

void main() {
  testWidgets('public demo shell renders core portfolio actions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PublicDemoScreen(),
      ),
    );

    expect(find.text('Plant AI Disease Detection'), findsOneWidget);
    expect(find.text('Try the web demo'), findsOneWidget);
    expect(find.text('Open full app'), findsWidgets);
    expect(find.textContaining('Web inference preview'), findsOneWidget);
  });
}
