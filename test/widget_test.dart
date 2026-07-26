import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kc_admin/src/app/app.dart';

void main() {
  testWidgets('Admin app startup smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: KcAdminApp()));
    await tester.pump();
    expect(find.byType(KcAdminApp), findsOneWidget);
  });
}
