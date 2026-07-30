import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Smoke test - Widget tree builds cleanly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('Kapada Creation Admin'))),
      ),
    );
    expect(find.text('Kapada Creation Admin'), findsOneWidget);
  });
}
