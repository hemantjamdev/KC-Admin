import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kc_admin/src/core/widgets/double_back_to_exit_wrapper.dart';

void main() {
  group('DoubleBackToExitWrapper Widget Tests', () {
    testWidgets('Renders child widget cleanly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DoubleBackToExitWrapper(
            child: Scaffold(body: Text('Admin Content')),
          ),
        ),
      );

      expect(find.text('Admin Content'), findsOneWidget);
    });

    testWidgets(
      'DoubleBackToExitWrapper with tab index renders child correctly',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: DoubleBackToExitWrapper(
              currentTabIndex: 0,
              child: Scaffold(body: Text('Home Tab')),
            ),
          ),
        );

        expect(find.text('Home Tab'), findsOneWidget);
      },
    );
  });
}
