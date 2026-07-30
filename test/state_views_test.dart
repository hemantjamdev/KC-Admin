import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kc_admin/src/core/widgets/app_state_views.dart';

void main() {
  group('Generic App State Views Tests', () {
    testWidgets('AppLoadingState renders non-shimmer indicator cleanly', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLoadingState(type: AppLoadingType.list, useShimmer: false),
          ),
        ),
      );

      expect(find.byType(AppLoadingState), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets(
      'AppEmptyState renders title, message, and action button cleanly',
      (tester) async {
        bool actionTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppEmptyState(
                title: 'No Data Found',
                message: 'Try refreshing or changing filters.',
                icon: Icons.inbox_outlined,
                actionLabel: 'Refresh',
                onAction: () {
                  actionTapped = true;
                },
              ),
            ),
          ),
        );

        expect(find.text('No Data Found'), findsOneWidget);
        expect(
          find.text('Try refreshing or changing filters.'),
          findsOneWidget,
        );
        expect(find.text('Refresh'), findsOneWidget);

        await tester.tap(find.text('Refresh'));
        expect(actionTapped, isTrue);
      },
    );

    testWidgets(
      'AppErrorState renders error title, message, and retry button',
      (tester) async {
        bool retryTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppErrorState(
                title: 'Connection Error',
                message: 'Failed to fetch data.',
                onRetry: () {
                  retryTapped = true;
                },
              ),
            ),
          ),
        );

        expect(find.text('Connection Error'), findsOneWidget);
        expect(find.text('Failed to fetch data.'), findsOneWidget);
        expect(find.text('Try Again'), findsOneWidget);

        await tester.tap(find.text('Try Again'));
        expect(retryTapped, isTrue);
      },
    );
  });
}
