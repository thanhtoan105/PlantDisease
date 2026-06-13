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
    expect(find.text('Preview upload flow'), findsOneWidget);
    expect(find.text('Open authenticated app'), findsOneWidget);
    expect(find.text('Open full app'), findsOneWidget);
    expect(find.textContaining('Web inference preview'), findsOneWidget);
  });

  testWidgets('public demo shell renders image upload controls',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PublicDemoScreen(),
      ),
    );

    expect(find.text('Upload a leaf image'), findsOneWidget);
    expect(find.text('Click to choose a leaf image'), findsOneWidget);
    expect(find.text('Choose leaf image'), findsNothing);
    expect(find.text('Detect Disease'), findsOneWidget);
    expect(find.text('JPG, PNG, or WebP up to 5 MB.'), findsOneWidget);

    final detectButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Detect Disease'),
    );
    expect(detectButton.onPressed, isNull);
  });

  testWidgets('public demo shell can render a selected image preview',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PublicDemoScreen(
          initialSelection: PublicDemoImageSelection(
            fileName: 'leaf.png',
            bytes: _onePixelPng,
          ),
        ),
      ),
    );

    expect(find.text('leaf.png'), findsOneWidget);
    expect(find.text('Remove image'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    final detectButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Detect Disease'),
    );
    expect(detectButton.onPressed, isNotNull);
  });
}

const List<int> _onePixelPng = [
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];
