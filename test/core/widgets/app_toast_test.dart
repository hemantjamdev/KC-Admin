import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kc_admin/src/core/theme/app_colors.dart';
import 'package:kc_admin/src/core/widgets/app_toast.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  tearDown(() {
    AppToast.dismissCurrent();
  });

  Widget buildTestableWidget(ToastType type) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                AppToast.show(
                  context,
                  'Test message for ${type.name}',
                  type: type,
                );
              },
              child: const Text('Show Toast'),
            );
          },
        ),
      ),
    );
  }

  testWidgets('AppToast displays correct border color for success', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestableWidget(ToastType.success));
    await tester.tap(find.text('Show Toast'));
    await tester.pumpAndSettle();

    expect(find.text('Test message for success'), findsOneWidget);

    final container = tester.widget<Container>(
      find.ancestor(
        of: find.text('Test message for success'),
        matching: find.byType(Container),
      ).first,
    );

    final decoration = container.decoration as BoxDecoration;
    final border = decoration.border as Border;
    expect(border.top.color, equals(AppColors.success));

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('AppToast displays correct border color for error', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestableWidget(ToastType.error));
    await tester.tap(find.text('Show Toast'));
    await tester.pumpAndSettle();

    expect(find.text('Test message for error'), findsOneWidget);

    final container = tester.widget<Container>(
      find.ancestor(
        of: find.text('Test message for error'),
        matching: find.byType(Container),
      ).first,
    );

    final decoration = container.decoration as BoxDecoration;
    final border = decoration.border as Border;
    expect(border.top.color, equals(AppColors.error));

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('AppToast displays correct border color for warning', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestableWidget(ToastType.warning));
    await tester.tap(find.text('Show Toast'));
    await tester.pumpAndSettle();

    expect(find.text('Test message for warning'), findsOneWidget);

    final container = tester.widget<Container>(
      find.ancestor(
        of: find.text('Test message for warning'),
        matching: find.byType(Container),
      ).first,
    );

    final decoration = container.decoration as BoxDecoration;
    final border = decoration.border as Border;
    expect(border.top.color, equals(AppColors.warning));

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('AppToast displays correct border color for info', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestableWidget(ToastType.info));
    await tester.tap(find.text('Show Toast'));
    await tester.pumpAndSettle();

    expect(find.text('Test message for info'), findsOneWidget);

    final container = tester.widget<Container>(
      find.ancestor(
        of: find.text('Test message for info'),
        matching: find.byType(Container),
      ).first,
    );

    final decoration = container.decoration as BoxDecoration;
    final border = decoration.border as Border;
    expect(border.top.color, equals(AppColors.brandGreen700));

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
